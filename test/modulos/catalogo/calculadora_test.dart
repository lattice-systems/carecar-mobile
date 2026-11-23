import 'dart:async';

import 'package:carecar_mobile/api/excepciones.dart';
import 'package:carecar_mobile/api/modelos/modelos.dart';
import 'package:carecar_mobile/modulos/catalogo/catalogo.dart';
import 'package:carecar_mobile/modulos/catalogo/datos/repositorio_toma_a_cuenta_api.dart';
import 'package:carecar_mobile/nucleo/api/proveedores_api.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/aviso.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/tarjeta_metrica.dart';
import 'package:carecar_mobile/sesion/almacen_sesion.dart';
import 'package:carecar_mobile/sesion/controlador_sesion.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../ayudas/api_falsa.dart';
import '../../ayudas/app_enrutada.dart';
import '../../ayudas/auditoria_accesibilidad.dart';
import '../../ayudas/tema_pista.dart';

const _leyenda =
    'Estimación no vinculante. No es una oferta de compra: el valor final lo '
    'define la agencia cuando revise tu auto.';

ApiFalsa _api({int? kmDelMarch = 48000}) {
  final api = ApiFalsa();
  api.alPedirVehiculos = () async => [
    Vehiculo(
      id: 5,
      vin: 'VIN5',
      marca: 'Nissan',
      modelo: 'March',
      anio: 2020,
      kilometraje: kmDelMarch,
    ),
    const Vehiculo(
      id: 6,
      vin: 'VIN6',
      marca: 'Volkswagen',
      modelo: 'Jetta',
      anio: 2018,
    ),
  ];
  api.detallesCatalogo = {
    2: DetalleModeloCatalogo.fromJson(const {
      'id': 2,
      'marca': 'Nissan',
      'modelo': 'Versa',
      'anio': 2025,
      'activo': true,
    }),
  };
  return api;
}

Widget _app(
  ApiFalsa api, {
  int? modeloId,
  Escenario escenario = Escenario.claro,
}) => ProviderScope(
  overrides: [carecarApiProvider.overrideWithValue(api)],
  child: conTemaPista(
    PantallaCalculadora(modeloId: modeloId),
    escenario: escenario,
  ),
);

void _pantallaAlta(WidgetTester tester) {
  tester.view.physicalSize = const Size(800, 3000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

/// Los campos en el orden en que salen al capturar un auto.
Finder _campo(String etiqueta) => find
    .byType(TextField)
    .at(['Marca', 'Modelo', 'Año', 'Kilometraje'].indexOf(etiqueta));

Future<void> _calcular(WidgetTester tester) async {
  await tester.ensureVisible(find.text('Calcular estimación'));
  await tester.tap(find.text('Calcular estimación'));
  await tester.pumpAndSettle();
}

void main() {
  group('leerKilometraje', () {
    test('acepta digitos con separadores de miles', () {
      expect(leerKilometraje('48000'), 48000);
      expect(leerKilometraje('48,000'), 48000);
      expect(leerKilometraje('48.000'), 48000);
      expect(leerKilometraje(' 48 000 '), 48000);
      expect(leerKilometraje('0'), 0);
      expect(leerKilometraje('999,999'), 999999);
    });

    test('rechaza lo que no sirve', () {
      expect(leerKilometraje(''), isNull);
      expect(leerKilometraje('abc'), isNull);
      expect(leerKilometraje('-5'), isNull);
      expect(leerKilometraje('1,000,000'), isNull);
      expect(leerKilometraje('12k'), isNull);
    });
  });

  group('leerAnio', () {
    test('acepta cuatro cifras entre 1900 y el maximo', () {
      expect(leerAnio('2020', maximo: 2027), 2020);
      expect(leerAnio(' 1900 ', maximo: 2027), 1900);
      expect(leerAnio('2027', maximo: 2027), 2027);
    });

    test('rechaza lo que no sirve', () {
      expect(leerAnio('', maximo: 2027), isNull);
      expect(leerAnio('99', maximo: 2027), isNull);
      expect(leerAnio('1899', maximo: 2027), isNull);
      expect(leerAnio('2028', maximo: 2027), isNull);
      expect(leerAnio('20x0', maximo: 2027), isNull);
    });
  });

  group('RepositorioTomaACuentaApi', () {
    test('un vehiculo viaja por id y traduce el resultado', () async {
      final api = _api();
      final e = await RepositorioTomaACuentaApi(api).estimar(
        const SolicitudDeVehiculo(
          vehiculoId: 5,
          km: 48000,
          estado: EstadoAuto.regular,
          modeloDestinoId: 2,
        ),
      );
      final enviada = api.estimacionesPedidas.single.toJson();
      expect(enviada, {
        'vehiculoId': 5,
        'km': 48000,
        'estado': 'REGULAR',
        'modeloCatalogoId': 2,
      });
      expect(e.minimo, 100000);
      expect(e.estado, EstadoAuto.regular);
      expect(e.margenPorcentaje, 8);
      expect(e.edadAnios, 5);
    });

    test(
      'un auto capturado viaja con marca, modelo y anio sin espacios',
      () async {
        final api = _api();
        await RepositorioTomaACuentaApi(api).estimar(
          const SolicitudCapturada(
            marca: ' Nissan ',
            modelo: 'Versa ',
            anio: 2021,
            km: 1,
            estado: EstadoAuto.excelente,
          ),
        );
        expect(api.estimacionesPedidas.single.toJson(), {
          'marca': 'Nissan',
          'modelo': 'Versa',
          'anio': 2021,
          'km': 1,
          'estado': 'EXCELENTE',
        });
      },
    );
  });

  testWidgets('parte del primer vehiculo con su kilometraje', (tester) async {
    _pantallaAlta(tester);
    await tester.pumpWidget(_app(_api()));
    await tester.pumpAndSettle();
    expect(find.text('Nissan March 2020'), findsOneWidget);
    expect(find.text('48,000'), findsOneWidget);
    expect(find.text('Marca'), findsNothing);
  });

  testWidgets('la leyenda no vinculante se ve siempre', (tester) async {
    _pantallaAlta(tester);
    await tester.pumpWidget(_app(_api()));
    await tester.pumpAndSettle();
    expect(find.text(_leyenda), findsOneWidget);

    await _calcular(tester);
    expect(find.byType(TarjetaMetrica), findsOneWidget);
    expect(find.text(_leyenda), findsOneWidget);
  });

  testWidgets('calcula con el vehiculo y muestra el rango y los supuestos', (
    tester,
  ) async {
    _pantallaAlta(tester);
    final api = _api();
    await tester.pumpWidget(_app(api, modeloId: 2));
    await tester.pumpAndSettle();
    expect(find.text('Contra: Nissan Versa 2025'), findsOneWidget);

    await _calcular(tester);

    final pedida = api.estimacionesPedidas.single.toJson();
    expect(pedida['vehiculoId'], 5);
    expect(pedida['km'], 48000);
    expect(pedida['estado'], 'BUENO');
    expect(pedida['modeloCatalogoId'], 2);
    expect(find.text(r'$100,000 a $120,000'), findsOneWidget);
    expect(
      find.textContaining('un auto de 5 años, con 75,000 km esperados'),
      findsOneWidget,
    );
    expect(find.textContaining('más y menos 8 %'), findsOneWidget);
  });

  testWidgets(
    'cambiar de vehiculo cambia el kilometraje y borra el resultado',
    (tester) async {
      _pantallaAlta(tester);
      await tester.pumpWidget(_app(_api()));
      await tester.pumpAndSettle();
      await _calcular(tester);
      expect(find.byType(TarjetaMetrica), findsOneWidget);

      await tester.tap(find.text('Nissan March 2020'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Volkswagen Jetta 2018').last);
      await tester.pumpAndSettle();
      expect(find.byType(TarjetaMetrica), findsNothing);
    },
  );

  testWidgets('sin vehiculos captura el auto y valida cada campo', (
    tester,
  ) async {
    _pantallaAlta(tester);
    final api = ApiFalsa()..alPedirVehiculos = () async => [];
    await tester.pumpWidget(_app(api));
    await tester.pumpAndSettle();
    expect(find.text('Marca'), findsOneWidget);
    expect(find.text('Otro auto'), findsOneWidget);

    await _calcular(tester);
    expect(find.text('Escribe la marca'), findsOneWidget);
    expect(find.text('Escribe el modelo'), findsOneWidget);
    expect(
      find.textContaining('Escribe un año de cuatro cifras'),
      findsOneWidget,
    );
    expect(find.text('Escribe un kilometraje de 0 a 999,999'), findsOneWidget);
    expect(api.estimacionesPedidas, isEmpty);

    await tester.enterText(_campo('Marca'), 'Nissan');
    await tester.enterText(_campo('Modelo'), 'Versa');
    await tester.enterText(_campo('Año'), '2021');
    await tester.enterText(_campo('Kilometraje'), '30,000');
    await tester.pumpAndSettle();
    await _calcular(tester);

    final pedida = api.estimacionesPedidas.single.toJson();
    expect(pedida['marca'], 'Nissan');
    expect(pedida['modelo'], 'Versa');
    expect(pedida['anio'], 2021);
    expect(pedida['km'], 30000);
    expect(pedida.containsKey('vehiculoId'), isFalse);
  });

  testWidgets('un vehiculo sin kilometraje pide escribirlo', (tester) async {
    _pantallaAlta(tester);
    final api = _api(kmDelMarch: null);
    await tester.pumpWidget(_app(api));
    await tester.pumpAndSettle();
    await _calcular(tester);
    expect(find.text('Escribe un kilometraje de 0 a 999,999'), findsOneWidget);
    expect(api.estimacionesPedidas, isEmpty);
  });

  group('cuando no hay resultado', () {
    Future<void> probar(
      WidgetTester tester,
      Object error,
      String esperado,
    ) async {
      _pantallaAlta(tester);
      final api = _api()..alEstimar = (_) async => throw error;
      await tester.pumpWidget(_app(api));
      await tester.pumpAndSettle();
      await _calcular(tester);
      expect(find.byType(TarjetaMetrica), findsNothing);
      expect(find.textContaining(esperado), findsOneWidget);
      // La leyenda y el boton siguen ahi para poder intentar de nuevo.
      expect(find.text(_leyenda), findsOneWidget);
      expect(find.byType(Aviso), findsNWidgets(2));
    }

    testWidgets('sin parametros explica y ofrece la valuacion formal', (
      tester,
    ) async {
      await probar(
        tester,
        const SinParametrosDeValuacion('x'),
        'Pide una valuación formal en la agencia',
      );
      expect(find.text('Todavía no estimamos ese auto'), findsOneWidget);
    });

    testWidgets('sin conexion', (tester) async {
      await probar(tester, const SinConexion(), 'Sin conexión');
    });

    testWidgets('datos rechazados', (tester) async {
      await probar(tester, const DatosInvalidos('x'), 'Revisa los datos');
    });

    testWidgets('vehiculo o modelo que ya no estan', (tester) async {
      await probar(
        tester,
        const NoEncontrado('x'),
        'No encontramos ese auto o ese modelo',
      );
    });

    testWidgets('error inesperado', (tester) async {
      await probar(tester, const ErrorDelServidor('x'), 'Algo salió mal');
    });
  });

  testWidgets('mientras calcula el boton no responde', (tester) async {
    _pantallaAlta(tester);
    final api = _api();
    final espera = Completer<EstimacionTomaCuenta>();
    api.alEstimar = (_) => espera.future;
    await tester.pumpWidget(_app(api));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Calcular estimación'));
    await tester.tap(find.text('Calcular estimación'));
    await tester.pump();
    await tester.tap(find.byType(FilledButton), warnIfMissed: false);
    await tester.pump();
    expect(api.estimacionesPedidas, hasLength(1));

    espera.complete(
      EstimacionTomaCuenta.fromJson(const {
        'id': 1,
        'creadaEn': '2026-11-22T00:00:00Z',
        'marca': 'Nissan',
        'modelo': 'March',
        'anio': 2020,
        'km': 48000,
        'estado': 'BUENO',
        'minimo': 1000,
        'maximo': 2000,
        'supuestos': {
          'valorBase': 1,
          'edadAnios': 0,
          'kmEsperado': 0,
          'ajusteKm': 1,
          'ajusteEstado': 1,
          'margen': 0.08,
        },
      }),
    );
    await tester.pumpAndSettle();
    expect(find.text(r'$1,000 a $2,000'), findsOneWidget);
  });

  testWidgets('se ve en claro, oscuro y letra grande sin desbordar', (
    tester,
  ) async {
    _pantallaAlta(tester);
    for (final e in Escenario.values) {
      await tester.pumpWidget(_app(_api(), escenario: e));
      await tester.pumpAndSettle();
      await _calcular(tester);
      expect(tester.takeException(), isNull);
      expect(find.byType(TarjetaMetrica), findsOneWidget);
    }
  });

  testWidgets('pasa las guias de accesibilidad con resultado', (tester) async {
    _pantallaAlta(tester);
    await tester.pumpWidget(_app(_api()));
    await tester.pumpAndSettle();
    await _calcular(tester);
    await auditarAccesibilidad(tester);
  });

  group('rutas', () {
    Future<void> montar(WidgetTester tester, ApiFalsa api) async {
      _pantallaAlta(tester);
      final sesion = ControladorSesion(api, AlmacenEnMemoria());
      addTearDown(sesion.dispose);
      await sesion.iniciarSesion(correo: 'a@b.mx', contrasena: 'CareCar2026');
      await tester.pumpWidget(
        AppEnrutadaDePrueba(api: api, controlador: sesion),
      );
      await tester.pumpAndSettle();
    }

    testWidgets(
      'el detalle de un modelo abre la calculadora contra ese modelo',
      (tester) async {
        final api = _api()
          ..detallesCatalogo = {
            2: DetalleModeloCatalogo.fromJson(const {
              'id': 2,
              'marca': 'Nissan',
              'modelo': 'Versa',
              'anio': 2025,
              'activo': true,
            }),
          };
        await montar(tester, api);
        enrutadorDe(tester).go(rutaDetalleModelo(2));
        await tester.pumpAndSettle();

        // El enrutador de prueba sigue el idioma del sistema: ingles.
        await tester.tap(find.text('Estimate my trade-in'));
        await tester.pumpAndSettle();
        expect(find.byType(PantallaCalculadora), findsOneWidget);
        expect(enrutadorDe(tester).state.uri.toString(), rutaCalculadoraDe(2));
        expect(find.text('Toward: Nissan Versa 2025'), findsOneWidget);
      },
    );

    testWidgets('/catalogo/calculadora sin modelo no cae en el detalle', (
      tester,
    ) async {
      await montar(tester, _api());
      enrutadorDe(tester).go(rutaCalculadora);
      await tester.pumpAndSettle();
      expect(find.byType(PantallaCalculadora), findsOneWidget);
      expect(find.textContaining('Toward'), findsNothing);
    });
  });
}
