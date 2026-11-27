import 'package:carecar_mobile/api/excepciones.dart';
import 'package:carecar_mobile/api/modelos/modelos.dart';
import 'package:carecar_mobile/modulos/catalogo/catalogo.dart';
import 'package:carecar_mobile/modulos/catalogo/datos/repositorio_toma_a_cuenta_api.dart';
import 'package:carecar_mobile/modulos/valuacion/datos/repositorio_valuacion_fake.dart';
import 'package:carecar_mobile/modulos/valuacion/valuacion.dart';
import 'package:carecar_mobile/nucleo/api/proveedores_api.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/aviso.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/barra_pantalla.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/boton_regresar.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/estado_error.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/estado_vacio.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/grupo_lista.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/marco_pantalla.dart';
import 'package:carecar_mobile/sesion/almacen_sesion.dart';
import 'package:carecar_mobile/sesion/controlador_sesion.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons_300.dart';

import '../../ayudas/api_falsa.dart';
import '../../ayudas/app_enrutada.dart';
import '../../ayudas/auditoria_accesibilidad.dart';
import '../../ayudas/tema_pista.dart';
import '../valuacion/ayudas_valuacion.dart' show sustitutos;

const _leyenda =
    'Estimación no vinculante. No es una oferta de compra: el valor final lo '
    'define la agencia cuando revise tu auto.';

EstimacionTomaCuenta _estimacion(
  int id, {
  String modelo = 'March',
  double minimo = 100000,
  double maximo = 120000,
  String? destino,
  double? precio,
  int? vehiculoId,
}) => EstimacionTomaCuenta(
  id: id,
  vehiculoId: vehiculoId,
  creadaEn: DateTime.utc(2026, 11, 22, 12),
  marca: 'Nissan',
  modelo: modelo,
  anio: 2020,
  km: 48000,
  estado: EstadoVehiculo.bueno,
  modeloDestino: destino,
  precioDestino: precio,
  minimo: minimo,
  maximo: maximo,
  supuestos: const SupuestosEstimacion(
    valorBase: 260000,
    edadAnios: 6,
    kmEsperado: 90000,
    ajusteKm: 1,
    ajusteEstado: 1,
    margen: 0.08,
  ),
);

Widget _app(
  ApiFalsa api, {
  Escenario escenario = Escenario.claro,
  double ancho = 360,
}) => ProviderScope(
  overrides: [carecarApiProvider.overrideWithValue(api)],
  child: conTemaPista(
    const PantallaMisEstimaciones(),
    escenario: escenario,
    ancho: ancho,
  ),
);

/// Una fila por estimación: cada una lleva el icono de la calculadora.
final _filas = find.byIcon(LucideIcons300.calculator);

void _pantallaAlta(WidgetTester tester) {
  tester.view.physicalSize = const Size(800, 3000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

void main() {
  test('el repositorio traduce la pagina guardada a dominio', () async {
    final api = ApiFalsa()
      ..estimaciones = [
        for (var i = 1; i <= 25; i++)
          _estimacion(i, destino: 'Nissan Versa 2025', precio: 369900),
      ];
    final repo = RepositorioTomaACuentaApi(api);
    final primera = await repo.guardadas();
    expect(primera.estimaciones, hasLength(20));
    expect(primera.pagina, 0);
    expect(primera.hayMas, isTrue);
    expect(primera.estimaciones.first.titulo, 'Nissan March 2020');
    expect(primera.estimaciones.first.precioDestino, 369900);

    final segunda = await repo.guardadas(pagina: 1);
    expect(segunda.estimaciones, hasLength(5));
    expect(segunda.hayMas, isFalse);
  });

  testWidgets('lista las estimaciones con su fecha, rango y modelo', (
    tester,
  ) async {
    _pantallaAlta(tester);
    final api = ApiFalsa()
      ..estimaciones = [
        _estimacion(2, destino: 'Nissan Versa 2025', precio: 369900),
        _estimacion(1, modelo: 'Versa', minimo: 90000, maximo: 99000),
      ];
    await tester.pumpWidget(_app(api));
    await tester.pumpAndSettle();

    expect(_filas, findsNWidgets(2));
    expect(find.text('Nissan March 2020'), findsOneWidget);
    expect(find.text('Nissan Versa 2020'), findsOneWidget);
    expect(
      find.textContaining(r'$100,000 a $120,000 · Contra: Nissan Versa 2025'),
      findsOneWidget,
    );
    expect(find.textContaining(r'$90,000 a $99,000'), findsOneWidget);
    expect(find.textContaining('22 nov 2026'), findsNWidgets(2));
    expect(find.text('Ver más'), findsNothing);
  });

  testWidgets(
    'usa el marco del sistema: regreso, título grande y lista agrupada',
    (tester) async {
      _pantallaAlta(tester);
      final api = ApiFalsa()
        ..estimaciones = [_estimacion(2), _estimacion(1, modelo: 'Versa')];
      await tester.pumpWidget(_app(api));
      await tester.pumpAndSettle();

      expect(find.byType(MarcoPantalla), findsOneWidget);
      expect(find.byType(BotonRegresar), findsOneWidget);
      expect(find.byType(GrupoLista), findsOneWidget);
      expect(find.byType(BarraPantalla), findsNothing);
      // «Mis valuaciones» sigue a un toque, en la barra del marco.
      expect(find.bySemanticsLabel('Mis valuaciones'), findsOneWidget);
    },
  );

  testWidgets('tocar una abre el detalle guardado con la leyenda', (
    tester,
  ) async {
    _pantallaAlta(tester);
    final api = ApiFalsa()
      ..estimaciones = [
        _estimacion(2, destino: 'Nissan Versa 2025', precio: 369900),
      ];
    await tester.pumpWidget(_app(api));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Nissan March 2020'));
    await tester.pumpAndSettle();

    expect(find.text(_leyenda), findsOneWidget);
    expect(find.text('Estimación de toma a cuenta'), findsOneWidget);
    expect(find.text('Diferencia a pagar'), findsOneWidget);
    expect(find.text(r'$249,900 a $269,900'), findsOneWidget);
    expect(find.textContaining('un auto de 6 años'), findsOneWidget);
  });

  testWidgets('una estimacion sin modelo no muestra la diferencia', (
    tester,
  ) async {
    _pantallaAlta(tester);
    final api = ApiFalsa()..estimaciones = [_estimacion(1)];
    await tester.pumpWidget(_app(api));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Nissan March 2020'));
    await tester.pumpAndSettle();
    expect(find.text('Diferencia a pagar'), findsNothing);
    expect(find.text(_leyenda), findsOneWidget);
  });

  testWidgets('pide las paginas de a una con Ver mas', (tester) async {
    _pantallaAlta(tester);
    final api = ApiFalsa()
      ..estimaciones = [
        for (var i = 1; i <= 25; i++) _estimacion(i, modelo: 'Modelo $i'),
      ];
    await tester.pumpWidget(_app(api));
    await tester.pumpAndSettle();
    expect(_filas, findsNWidgets(20));

    await tester.ensureVisible(find.text('Ver más'));
    await tester.tap(find.text('Ver más'));
    await tester.pumpAndSettle();
    expect(_filas, findsNWidgets(25));
    expect(find.text('Ver más'), findsNothing);
  });

  testWidgets('si falla la siguiente pagina avisa y deja reintentar', (
    tester,
  ) async {
    _pantallaAlta(tester);
    final api = _ApiQueFallaLaSegunda()
      ..estimaciones = [
        for (var i = 1; i <= 25; i++) _estimacion(i, modelo: 'Modelo $i'),
      ];
    await tester.pumpWidget(_app(api));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Ver más'));
    await tester.tap(find.text('Ver más'));
    await tester.pumpAndSettle();

    expect(_filas, findsNWidgets(20));
    expect(find.byType(Aviso), findsOneWidget);
    expect(find.text('Ver más'), findsOneWidget);

    api.cae = false;
    await tester.tap(find.text('Ver más'));
    await tester.pumpAndSettle();
    expect(_filas, findsNWidgets(25));
    expect(find.byType(Aviso), findsNothing);
  });

  testWidgets('sin estimaciones explica y ofrece calcular una', (tester) async {
    await tester.pumpWidget(_app(ApiFalsa()));
    await tester.pumpAndSettle();
    expect(find.byType(EstadoVacio), findsOneWidget);
    expect(find.text('Aún no tienes estimaciones'), findsOneWidget);
    expect(find.text('Calcular una estimación'), findsOneWidget);
    expect(find.byType(BotonRegresar), findsOneWidget);
  });

  testWidgets('sin conexion ofrece reintentar y recupera', (tester) async {
    _pantallaAlta(tester);
    final api = _ApiSinRed()..estimaciones = [_estimacion(1)];
    await tester.pumpWidget(_app(api));
    await tester.pumpAndSettle();
    expect(find.byType(EstadoError), findsOneWidget);

    api.caida = false;
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();
    expect(find.text('Nissan March 2020'), findsOneWidget);
  });

  testWidgets('mientras carga lo anuncia', (tester) async {
    await tester.pumpWidget(_app(ApiFalsa()));
    expect(find.bySemanticsLabel('Cargando tus estimaciones'), findsOneWidget);
    await tester.pumpAndSettle();
  });

  testWidgets('se ve en claro, oscuro y letra grande sin desbordar', (
    tester,
  ) async {
    _pantallaAlta(tester);
    for (final e in Escenario.values) {
      final api = ApiFalsa()
        ..estimaciones = [
          _estimacion(1, destino: 'Nissan Versa 2025', precio: 369900),
        ];
      await tester.pumpWidget(_app(api, escenario: e));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Nissan March 2020'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text(_leyenda), findsOneWidget);
      // Se cierra la hoja para que el siguiente escenario parta limpio.
      tester.state<NavigatorState>(find.byType(Navigator).first).pop();
      await tester.pumpAndSettle();
    }
  });

  testWidgets('pasa las guias de accesibilidad', (tester) async {
    _pantallaAlta(tester);
    final api = ApiFalsa()
      ..estimaciones = [
        _estimacion(2, destino: 'Nissan Versa 2025', precio: 369900),
        _estimacion(1),
      ];
    await tester.pumpWidget(_app(api));
    await tester.pumpAndSettle();
    await auditarAccesibilidad(tester);
  });

  testWidgets('en 320 de ancho pasa las guias en los tres escenarios', (
    tester,
  ) async {
    telefonoChicoYAlto(tester);
    for (final escenario in Escenario.values) {
      final api = ApiFalsa()
        ..estimaciones = [
          _estimacion(2, destino: 'Nissan Versa 2025', precio: 369900),
          _estimacion(1),
        ];
      await tester.pumpWidget(
        _app(api, escenario: escenario, ancho: anchoTelefonoChico),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: escenario.name);
      await auditarAccesibilidad(tester);
    }
  });

  group('valuacion formal (V2-M26)', () {
    Future<RepositorioValuacionFake> abrirDetalle(
      WidgetTester tester, {
      int? vehiculoId = 5,
      MotivoRechazoValuacion? rechazo,
    }) async {
      _pantallaAlta(tester);
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(disableAnimations: true);
      addTearDown(
        tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
      );
      tester.platformDispatcher.localesTestValue = const [Locale('es')];
      addTearDown(tester.platformDispatcher.clearLocalesTestValue);
      final api = ApiFalsa()
        ..estimaciones = [_estimacion(7, vehiculoId: vehiculoId)];
      api.alPedirVehiculos = () async => [];
      final repo = RepositorioValuacionFake(rechazo: rechazo);
      final sesion = ControladorSesion(api, AlmacenEnMemoria());
      addTearDown(sesion.dispose);
      await sesion.iniciarSesion(correo: 'a@b.mx', contrasena: 'CareCar2026');
      await tester.pumpWidget(
        AppEnrutadaDePrueba(
          api: api,
          controlador: sesion,
          idioma: const Locale('es'),
          overrides: sustitutos(repositorio: repo),
        ),
      );
      await tester.pumpAndSettle();
      enrutadorDe(tester).go(rutaMisEstimaciones);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Nissan March 2020'));
      await tester.pumpAndSettle();
      return repo;
    }

    testWidgets('pedirla desde el detalle cierra la hoja y la abre', (
      tester,
    ) async {
      final repo = await abrirDetalle(tester);
      await tester.tap(find.text('Pedir valuación formal'));
      await tester.pumpAndSettle();

      expect(repo.pedidas, [7]);
      expect(find.byType(PantallaValuacion), findsOneWidget);
      expect(find.text(_leyenda), findsOneWidget);
    });

    testWidgets('una capturada a mano explica que se pide en la agencia', (
      tester,
    ) async {
      await abrirDetalle(
        tester,
        vehiculoId: null,
        rechazo: MotivoRechazoValuacion.sinVehiculo,
      );
      expect(find.text('Ver cómo cambia el valor'), findsNothing);
      await tester.tap(find.text('Pedir valuación formal'));
      await tester.pumpAndSettle();

      expect(
        find.textContaining('pide la valuación en la agencia'),
        findsOneWidget,
      );
      expect(find.byType(PantallaValuacion), findsNothing);
    });

    testWidgets('la hecha con un vehiculo lleva al valor en el tiempo', (
      tester,
    ) async {
      await abrirDetalle(tester);
      await tester.tap(find.text('Ver cómo cambia el valor'));
      await tester.pumpAndSettle();

      expect(
        tester
            .widget<PantallaValorVehiculo>(find.byType(PantallaValorVehiculo))
            .vehiculoId,
        5,
      );
    });

    testWidgets('desde la barra se abren Mis valuaciones', (tester) async {
      await abrirDetalle(tester);
      tester.state<NavigatorState>(find.byType(Navigator).first).pop();
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Mis valuaciones'));
      await tester.pumpAndSettle();

      expect(find.byType(PantallaMisValuaciones), findsOneWidget);
    });
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

    testWidgets('la calculadora abre las estimaciones guardadas', (
      tester,
    ) async {
      final api = ApiFalsa();
      api.alPedirVehiculos = () async => [];
      api.estimaciones = [_estimacion(1)];
      await montar(tester, api);
      enrutadorDe(tester).go(rutaCalculadora);
      await tester.pumpAndSettle();

      // El enrutador de prueba sigue el idioma del sistema: ingles.
      await tester.tap(find.byTooltip('My estimates'));
      await tester.pumpAndSettle();
      expect(find.byType(PantallaMisEstimaciones), findsOneWidget);
      expect(enrutadorDe(tester).state.uri.toString(), rutaMisEstimaciones);
      expect(find.text('Nissan March 2020'), findsOneWidget);
    });

    testWidgets('desde el vacio se llega a la calculadora', (tester) async {
      final api = ApiFalsa()..alPedirVehiculos = () async => [];
      await montar(tester, api);
      enrutadorDe(tester).go(rutaMisEstimaciones);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Calculate an estimate'));
      await tester.pumpAndSettle();
      expect(find.byType(PantallaCalculadora), findsOneWidget);
    });

    test('la ruta de estimaciones no es publica', () {
      expect(rutaMisEstimaciones, '/catalogo/estimaciones');
    });
  });
}

class _ApiSinRed extends ApiFalsa {
  bool caida = true;

  @override
  Future<Pagina<EstimacionTomaCuenta>> paginaDeEstimaciones({
    int pagina = 0,
    int tamano = 20,
  }) {
    if (caida) throw const SinConexion();
    return super.paginaDeEstimaciones(pagina: pagina, tamano: tamano);
  }
}

class _ApiQueFallaLaSegunda extends ApiFalsa {
  bool cae = true;

  @override
  Future<Pagina<EstimacionTomaCuenta>> paginaDeEstimaciones({
    int pagina = 0,
    int tamano = 20,
  }) {
    if (pagina > 0 && cae) throw const SinConexion();
    return super.paginaDeEstimaciones(pagina: pagina, tamano: tamano);
  }
}
