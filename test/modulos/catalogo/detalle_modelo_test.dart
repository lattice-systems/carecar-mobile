import 'package:carecar_mobile/api/excepciones.dart';
import 'package:carecar_mobile/api/modelos/modelos.dart';
import 'package:carecar_mobile/modulos/catalogo/catalogo.dart';
import 'package:carecar_mobile/modulos/catalogo/datos/repositorio_catalogo_api.dart';
import 'package:carecar_mobile/nucleo/api/proveedores_api.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/estado_error.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/estado_vacio.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/galeria_fotos.dart';
import 'package:carecar_mobile/nucleo/navegacion/rutas.dart';
import 'package:carecar_mobile/sesion/almacen_sesion.dart';
import 'package:carecar_mobile/sesion/controlador_sesion.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../ayudas/api_falsa.dart';
import '../../ayudas/app_enrutada.dart';
import '../../ayudas/auditoria_accesibilidad.dart';
import '../../ayudas/tema_pista.dart';

const _json = <String, Object?>{
  'id': 2,
  'marca': 'Nissan',
  'modelo': 'Versa',
  'anio': 2025,
  'version': 'Advance',
  'precioDesde': 369900,
  'imagenUrl': 'https://img.example/portada.png',
  'descripcion': 'Sedan compacto.',
  'activo': true,
  'imagenes': [
    {'id': 9, 'url': 'https://img.example/b.png', 'orden': 1, 'color': 'Rojo'},
    {
      'id': 8,
      'url': 'https://img.example/a.png',
      'orden': 0,
      'descripcion': 'Frente blanco',
    },
  ],
  'versiones': [
    {'id': 1, 'nombre': 'Sense', 'precioDesde': 329900},
    {'id': 2, 'nombre': 'Advance', 'precioDesde': 369900},
    {'id': 3, 'nombre': 'Exclusive'},
  ],
  'especificaciones': [
    {'etiqueta': 'Motor', 'valor': '1.6 L', 'orden': 0},
  ],
};

const _vacio = <String, Object?>{
  'id': 6,
  'marca': 'Nissan',
  'modelo': 'Sentra',
  'anio': 2025,
  'activo': true,
  'imagenes': <Object?>[],
  'versiones': <Object?>[],
  'especificaciones': <Object?>[],
};

Widget _app(ApiFalsa api, int id, {Escenario escenario = Escenario.claro}) =>
    ProviderScope(
      overrides: [carecarApiProvider.overrideWithValue(api)],
      child: conTemaPista(
        PantallaDetalleModelo(modeloId: id),
        escenario: escenario,
      ),
    );

void _pantallaAlta(WidgetTester tester) {
  tester.view.physicalSize = const Size(800, 3000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

void main() {
  group('DetalleModeloCatalogo', () {
    test('lee el detalle completo', () {
      final d = DetalleModeloCatalogo.fromJson(_json);
      expect(d.modelo.marca, 'Nissan');
      expect(d.imagenes, hasLength(2));
      expect(d.versiones[2].precioDesde, isNull);
      expect(d.especificaciones.single.valor, '1.6 L');
    });

    test('sin listas se lee como vacio', () {
      final d = DetalleModeloCatalogo.fromJson(const {'id': 1, 'modelo': 'X'});
      expect(d.imagenes, isEmpty);
      expect(d.versiones, isEmpty);
      expect(d.especificaciones, isEmpty);
    });

    test('toJson y fromJson son inversas', () {
      final d = DetalleModeloCatalogo.fromJson(_json);
      final otra = DetalleModeloCatalogo.fromJson(d.toJson());
      expect(otra.toJson(), d.toJson());
    });
  });

  test('el repositorio traduce el detalle a dominio', () async {
    final api = ApiFalsa()
      ..detallesCatalogo = {2: DetalleModeloCatalogo.fromJson(_json)};
    final d = await RepositorioCatalogoApi(api).detalle(2);
    expect(d.modelo.titulo, 'Nissan Versa 2025');
    expect(d.fotos.map((f) => f.url), hasLength(2));
    expect(d.versiones.map((v) => v.nombre), ['Sense', 'Advance', 'Exclusive']);
    expect(d.ficha.single.etiqueta, 'Motor');
  });

  testWidgets('muestra galeria, versiones y ficha', (tester) async {
    final api = ApiFalsa()
      ..detallesCatalogo = {2: DetalleModeloCatalogo.fromJson(_json)};
    _pantallaAlta(tester);
    await tester.pumpWidget(_app(api, 2));
    await tester.pumpAndSettle();

    expect(find.text('Nissan Versa 2025'), findsOneWidget);
    expect(find.byType(GaleriaFotos), findsOneWidget);
    expect(find.text('Sense'), findsOneWidget);
    expect(find.text(r'Desde $329,900'), findsOneWidget);
    expect(find.text('La que estás viendo'), findsOneWidget);
    expect(find.text('Precio por confirmar'), findsOneWidget);
    expect(find.text('Motor'), findsOneWidget);
    expect(find.text('1.6 L'), findsOneWidget);
  });

  testWidgets('sin galeria, versiones ni ficha no muestra esas secciones', (
    tester,
  ) async {
    final api = ApiFalsa()
      ..detallesCatalogo = {6: DetalleModeloCatalogo.fromJson(_vacio)};
    await tester.pumpWidget(_app(api, 6));
    await tester.pumpAndSettle();

    expect(find.text('Nissan Sentra 2025'), findsOneWidget);
    expect(find.byType(GaleriaFotos), findsNothing);
    expect(find.text('Versiones'), findsNothing);
    expect(find.text('Ficha técnica'), findsNothing);
  });

  testWidgets('un modelo retirado explica que ya no esta', (tester) async {
    await tester.pumpWidget(_app(ApiFalsa(), 99));
    await tester.pumpAndSettle();
    expect(find.byType(EstadoVacio), findsOneWidget);
    expect(find.text('No encontramos el modelo'), findsOneWidget);
  });

  testWidgets('sin conexion ofrece reintentar y recupera', (tester) async {
    final api = _ApiSinRed()
      ..detallesCatalogo = {6: DetalleModeloCatalogo.fromJson(_vacio)};
    await tester.pumpWidget(_app(api, 6));
    await tester.pumpAndSettle();
    expect(find.byType(EstadoError), findsOneWidget);

    api.caida = false;
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();
    expect(find.text('Nissan Sentra 2025'), findsOneWidget);
  });

  testWidgets('mientras carga lo anuncia', (tester) async {
    final api = ApiFalsa()
      ..detallesCatalogo = {6: DetalleModeloCatalogo.fromJson(_vacio)};
    await tester.pumpWidget(_app(api, 6));
    expect(find.bySemanticsLabel('Cargando el modelo'), findsOneWidget);
    await tester.pumpAndSettle();
  });

  testWidgets('se ve en claro, oscuro y letra grande sin desbordar', (
    tester,
  ) async {
    final api = ApiFalsa()
      ..detallesCatalogo = {2: DetalleModeloCatalogo.fromJson(_json)};
    for (final e in Escenario.values) {
      await tester.pumpWidget(_app(api, 2, escenario: e));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Nissan Versa 2025'), findsOneWidget);
    }
  });

  testWidgets('pasa las guias de accesibilidad', (tester) async {
    final api = ApiFalsa()
      ..detallesCatalogo = {2: DetalleModeloCatalogo.fromJson(_json)};
    await tester.pumpWidget(_app(api, 2));
    await tester.pumpAndSettle();
    await auditarAccesibilidad(tester);
  });

  group('rutas', () {
    Future<ApiFalsa> montar(WidgetTester tester) async {
      final api = ApiFalsa()
        ..modelosCatalogo = [ModeloCatalogo.fromJson(_json)]
        ..detallesCatalogo = {
          2: DetalleModeloCatalogo.fromJson(_json),
          1: DetalleModeloCatalogo.fromJson({
            ..._json,
            'id': 1,
            'version': 'Sense',
          }),
        };
      final sesion = ControladorSesion(api, AlmacenEnMemoria());
      addTearDown(sesion.dispose);
      await sesion.iniciarSesion(correo: 'a@b.mx', contrasena: 'CareCar2026');
      await tester.pumpWidget(
        AppEnrutadaDePrueba(api: api, controlador: sesion),
      );
      await tester.pumpAndSettle();
      return api;
    }

    testWidgets('tocar una tarjeta abre su detalle y otra version', (
      tester,
    ) async {
      _pantallaAlta(tester);
      await montar(tester);
      enrutadorDe(tester).go(rutaCatalogo);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Nissan Versa 2025'));
      await tester.pumpAndSettle();
      expect(find.byType(PantallaDetalleModelo), findsOneWidget);

      await tester.tap(find.text('Sense'));
      await tester.pumpAndSettle();
      expect(enrutadorDe(tester).state.uri.toString(), rutaDetalleModelo(1));
    });

    testWidgets('un id que no es numero cae en no encontrado', (tester) async {
      await montar(tester);
      enrutadorDe(tester).go('$rutaCatalogo/abc');
      await tester.pumpAndSettle();
      // El enrutador de prueba sigue el idioma del sistema, que aqui es ingles.
      expect(find.text('We could not find the model'), findsOneWidget);
    });

    test('el detalle no es una ruta publica', () {
      expect(Rutas.publicas.contains(rutaDetalleModelo(1)), isFalse);
    });
  });
}

class _ApiSinRed extends ApiFalsa {
  bool caida = true;

  @override
  Future<DetalleModeloCatalogo> detalleModelo(int id) {
    if (caida) throw const SinConexion();
    return super.detalleModelo(id);
  }
}
