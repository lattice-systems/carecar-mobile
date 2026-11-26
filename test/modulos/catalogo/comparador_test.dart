import 'package:carecar_mobile/api/excepciones.dart';
import 'package:carecar_mobile/api/modelos/modelos.dart';
import 'package:carecar_mobile/modulos/catalogo/catalogo.dart';
import 'package:carecar_mobile/nucleo/api/proveedores_api.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/estado_error.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/estado_vacio.dart';
import 'package:carecar_mobile/sesion/almacen_sesion.dart';
import 'package:carecar_mobile/sesion/controlador_sesion.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../ayudas/api_falsa.dart';
import '../../ayudas/app_enrutada.dart';
import '../../ayudas/auditoria_accesibilidad.dart';
import '../../ayudas/tema_pista.dart';

Map<String, Object?> _modelo(
  int id,
  String nombre, {
  double? precio,
  List<Map<String, Object?>> ficha = const [],
}) => {
  'id': id,
  'marca': 'Nissan',
  'modelo': nombre,
  'anio': 2025,
  'precioDesde': precio,
  'activo': true,
  'imagenes': <Object?>[],
  'versiones': <Object?>[],
  'especificaciones': ficha,
};

Map<String, Object?> _dato(String etiqueta, String valor) => {
  'etiqueta': etiqueta,
  'valor': valor,
};

ApiFalsa _api() => ApiFalsa()
  ..modelosCatalogo = [for (final j in _todos) ModeloCatalogo.fromJson(j)]
  ..detallesCatalogo = {
    for (final j in _todos) j['id']! as int: DetalleModeloCatalogo.fromJson(j),
  };

final _todos = [
  _modelo(
    1,
    'Versa',
    precio: 369900,
    ficha: [_dato('Motor', '1.6 L'), _dato('Puertas', '4')],
  ),
  _modelo(
    2,
    'Kicks',
    precio: 429900,
    ficha: [_dato('motor ', '1.6 L'), _dato('Cajuela', '432 L')],
  ),
  _modelo(3, 'Sentra'),
];

Widget _app(
  ApiFalsa api,
  List<int> ids, {
  Escenario escenario = Escenario.claro,
}) => ProviderScope(
  overrides: [carecarApiProvider.overrideWithValue(api)],
  child: conTemaPista(PantallaComparador(ids: ids), escenario: escenario),
);

void _pantallaAlta(WidgetTester tester) {
  tester.view.physicalSize = const Size(800, 3000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

DetalleModelo _detalle(int i) {
  final j = _todos[i];
  return DetalleModelo(
    modelo: ModeloVigente(
      id: j['id']! as int,
      nombre: j['modelo']! as String,
      marca: j['marca'] as String?,
      anio: j['anio'] as int?,
      precioDesde: j['precioDesde'] as double?,
    ),
    ficha: [
      for (final d in j['especificaciones']! as List<Map<String, Object?>>)
        DatoFicha(
          etiqueta: d['etiqueta']! as String,
          valor: d['valor']! as String,
        ),
    ],
  );
}

void main() {
  group('filasDeFicha', () {
    test('une las etiquetas sin distinguir mayusculas ni bordes', () {
      final filas = filasDeFicha([_detalle(0), _detalle(1)]);
      expect(filas.map((f) => f.etiqueta), ['Motor', 'Puertas', 'Cajuela']);
      expect(filas[0].valores, ['1.6 L', '1.6 L']);
    });

    test('un modelo sin el dato queda en null', () {
      final filas = filasDeFicha([_detalle(0), _detalle(1)]);
      expect(filas[1].valores, ['4', null]);
      expect(filas[2].valores, [null, '432 L']);
    });

    test('sin ficha no hay filas', () {
      expect(filasDeFicha([_detalle(2)]), isEmpty);
    });
  });

  group('indiceMasBarato', () {
    test('elige el menor precio e ignora los que no tienen', () {
      expect(indiceMasBarato([_detalle(2), _detalle(1), _detalle(0)]), 2);
    });

    test('sin precios o con empate no resalta nada', () {
      expect(indiceMasBarato([_detalle(2), _detalle(2)]), isNull);
      expect(indiceMasBarato([_detalle(0), _detalle(0)]), isNull);
    });
  });

  group('idsDeComparativa', () {
    test('lee de dos a tres ids', () {
      expect(idsDeComparativa('1,2'), [1, 2]);
      expect(idsDeComparativa(' 1, 2 ,3'), [1, 2, 3]);
    });

    test('rechaza lo que no sirve', () {
      expect(idsDeComparativa(null), isEmpty);
      expect(idsDeComparativa(''), isEmpty);
      expect(idsDeComparativa('1'), isEmpty);
      expect(idsDeComparativa('1,2,3,4'), isEmpty);
      expect(idsDeComparativa('1,a'), isEmpty);
      expect(idsDeComparativa('1,1'), isEmpty);
    });
  });

  testWidgets('V2-M03.03: compara tres modelos con precio y ficha', (
    tester,
  ) async {
    _pantallaAlta(tester);
    await tester.pumpWidget(_app(_api(), [1, 2, 3]));
    await tester.pumpAndSettle();

    expect(find.text('Nissan Versa 2025'), findsOneWidget);
    expect(find.text('Nissan Kicks 2025'), findsOneWidget);
    expect(find.text('Nissan Sentra 2025'), findsOneWidget);
    expect(find.text('Precio desde'), findsOneWidget);
    expect(find.text(r'$369,900'), findsOneWidget);
    expect(find.text('Motor'), findsOneWidget);
    expect(find.text('432 L'), findsOneWidget);
    // Sentra no trae precio ni ficha (4 celdas), Versa no trae cajuela y Kicks
    // no trae puertas (2 celdas mas).
    expect(find.text('Sin dato'), findsNWidgets(6));
  });

  testWidgets('resalta el precio mas bajo', (tester) async {
    _pantallaAlta(tester);
    await tester.pumpWidget(_app(_api(), [1, 2]));
    await tester.pumpAndSettle();
    expect(find.text('Precio más bajo'), findsOneWidget);
    expect(
      find.bySemanticsLabel(
        'Precio desde, Nissan Versa 2025: \$369,900, Precio más bajo',
      ),
      findsOneWidget,
    );
  });

  testWidgets('ids que no sirven explican como llegar', (tester) async {
    await tester.pumpWidget(_app(_api(), const []));
    await tester.pumpAndSettle();
    expect(find.byType(EstadoVacio), findsOneWidget);
    expect(find.text('Elige de dos a tres modelos'), findsOneWidget);
  });

  testWidgets('un modelo retirado explica que ya no esta', (tester) async {
    await tester.pumpWidget(_app(_api(), [1, 99]));
    await tester.pumpAndSettle();
    expect(find.text('No encontramos el modelo'), findsOneWidget);
  });

  testWidgets('sin conexion ofrece reintentar y recupera', (tester) async {
    _pantallaAlta(tester);
    final api = _ApiSinRed()..detallesCatalogo = _api().detallesCatalogo;
    await tester.pumpWidget(_app(api, [1, 2]));
    await tester.pumpAndSettle();
    expect(find.byType(EstadoError), findsOneWidget);

    api.caida = false;
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();
    expect(find.text('Nissan Versa 2025'), findsOneWidget);
  });

  testWidgets('mientras carga lo anuncia', (tester) async {
    await tester.pumpWidget(_app(_api(), [1, 2]));
    expect(find.bySemanticsLabel('Cargando la comparativa'), findsOneWidget);
    await tester.pumpAndSettle();
  });

  testWidgets('se ve en claro, oscuro y letra grande sin desbordar', (
    tester,
  ) async {
    _pantallaAlta(tester);
    for (final e in Escenario.values) {
      await tester.pumpWidget(_app(_api(), [1, 2, 3], escenario: e));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Nissan Versa 2025'), findsOneWidget);
    }
  });

  testWidgets('pasa las guias de accesibilidad', (tester) async {
    _pantallaAlta(tester);
    await tester.pumpWidget(_app(_api(), [1, 2, 3]));
    await tester.pumpAndSettle();
    await auditarAccesibilidad(tester);
  });

  group('modo comparar en el catalogo', () {
    Future<void> montar(WidgetTester tester, {ApiFalsa? api}) async {
      _pantallaAlta(tester);
      final a = api ?? _api();
      final sesion = ControladorSesion(a, AlmacenEnMemoria());
      addTearDown(sesion.dispose);
      await sesion.iniciarSesion(correo: 'a@b.mx', contrasena: 'CareCar2026');
      await tester.pumpWidget(AppEnrutadaDePrueba(api: a, controlador: sesion));
      await tester.pumpAndSettle();
      enrutadorDe(tester).go(rutaCatalogo);
      await tester.pumpAndSettle();
    }

    testWidgets('elegir dos modelos y abrir la comparativa', (tester) async {
      await montar(tester);
      // El enrutador de prueba sigue el idioma del sistema: ingles.
      expect(find.byType(Checkbox), findsNothing);
      await tester.tap(find.byTooltip('Compare models'));
      await tester.pumpAndSettle();

      expect(find.byType(Checkbox), findsNWidgets(3));
      expect(find.text('Pick 2 or 3 models'), findsOneWidget);

      await tester.tap(find.text('Compare Nissan Versa 2025'));
      await tester.pumpAndSettle();
      expect(find.text('Pick one more model'), findsOneWidget);

      await tester.tap(find.text('Compare Nissan Kicks 2025'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Compare 2 models'));
      await tester.pumpAndSettle();

      expect(find.byType(PantallaComparador), findsOneWidget);
      expect(
        enrutadorDe(tester).state.uri.toString(),
        rutaComparadorDe([1, 2]),
      );
    });

    testWidgets('con tres elegidos la cuarta casilla se bloquea', (
      tester,
    ) async {
      final api = _api();
      api.modelosCatalogo = [
        ...api.modelosCatalogo,
        ModeloCatalogo.fromJson(_modelo(4, 'March')),
      ];
      await montar(tester, api: api);
      await tester.tap(find.byTooltip('Compare models'));
      await tester.pumpAndSettle();
      for (final n in ['Versa', 'Kicks', 'Sentra']) {
        await tester.tap(find.text('Compare Nissan $n 2025'));
        await tester.pumpAndSettle();
      }
      final cuarta = tester.widget<Checkbox>(find.byType(Checkbox).last);
      expect(cuarta.onChanged, isNull);
    });

    testWidgets('salir de comparar quita las casillas y la seleccion', (
      tester,
    ) async {
      await montar(tester);
      await tester.tap(find.byTooltip('Compare models'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Compare Nissan Versa 2025'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Exit compare mode'));
      await tester.pumpAndSettle();
      expect(find.byType(Checkbox), findsNothing);

      await tester.tap(find.byTooltip('Compare models'));
      await tester.pumpAndSettle();
      expect(find.text('Pick 2 or 3 models'), findsOneWidget);
    });

    testWidgets('con un solo modelo no ofrece comparar', (tester) async {
      final api = _api();
      api.modelosCatalogo = [api.modelosCatalogo.first];
      await montar(tester, api: api);
      expect(find.byTooltip('Compare models'), findsNothing);
    });

    testWidgets('la ruta /catalogo/comparar abre la comparativa', (
      tester,
    ) async {
      await montar(tester);
      enrutadorDe(tester).go(rutaComparadorDe([1, 2, 3]));
      await tester.pumpAndSettle();
      expect(find.byType(PantallaComparador), findsOneWidget);
      expect(find.text('Nissan Sentra 2025'), findsOneWidget);
    });

    testWidgets('una ruta con ids malos no cae en el detalle', (tester) async {
      await montar(tester);
      enrutadorDe(tester).go('$rutaComparador?ids=1');
      await tester.pumpAndSettle();
      expect(find.byType(PantallaComparador), findsOneWidget);
      expect(find.text('Pick two or three models'), findsOneWidget);
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
