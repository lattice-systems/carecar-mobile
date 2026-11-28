import 'package:carecar_mobile/api/carecar_api.dart';
import 'package:carecar_mobile/api/excepciones.dart';
import 'package:carecar_mobile/api/modelos/modelo_catalogo.dart';
import 'package:carecar_mobile/modulos/catalogo/catalogo.dart';
import 'package:carecar_mobile/modulos/catalogo/datos/repositorio_catalogo_api.dart';
import 'package:carecar_mobile/modulos/catalogo/dominio/repositorio_catalogo.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/boton_cerrar.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/boton_regresar.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/estado_error.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/estado_vacio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../ayudas/tema_pista.dart';

class _Repo implements RepositorioCatalogo {
  _Repo(this.alPedir);
  final Future<List<ModeloVigente>> Function() alPedir;
  @override
  Future<List<ModeloVigente>> modelos() => alPedir();

  @override
  Future<DetalleModelo> detalle(int id) => throw UnimplementedError();
}

class _ApiConCatalogo implements CarecarApi {
  _ApiConCatalogo(this.respuesta);
  final List<ModeloCatalogo> respuesta;

  @override
  Future<List<ModeloCatalogo>> catalogo() async => respuesta;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Widget _app(
  RepositorioCatalogo repo, {
  Escenario escenario = Escenario.claro,
}) => ProviderScope(
  overrides: [repositorioCatalogoProvider.overrideWithValue(repo)],
  child: conTemaPista(const PantallaCatalogo(), escenario: escenario),
);

const _cx5 = ModeloVigente(
  id: 1,
  nombre: 'CX-5',
  marca: 'Mazda',
  anio: 2024,
  version: 'Signature',
  precioDesde: 450000,
);

void main() {
  group('ModeloVigente', () {
    test('arma el titulo con marca, modelo y anio', () {
      expect(_cx5.titulo, 'Mazda CX-5 2024');
    });

    test('sin marca ni anio usa solo el modelo', () {
      const m = ModeloVigente(nombre: 'Mazda 3');
      expect(m.titulo, 'Mazda 3');
    });

    test('no arma textos para pantalla: eso es de la presentacion', () {
      // El dominio no conoce el idioma. El precio y las frases se arman en la
      // pantalla con AppLocalizations.
      expect(_cx5.precioDesde, 450000);
      expect(_cx5.version, 'Signature');
    });
  });

  group('RepositorioCatalogoApi', () {
    test('traduce el DTO a modelos de dominio', () async {
      final repo = RepositorioCatalogoApi(
        _ApiConCatalogo(const [
          ModeloCatalogo(
            id: 7,
            modelo: 'CX-30',
            marca: 'Mazda',
            anio: 2025,
            precioDesde: 400000,
            imagenUrl: 'https://x/y.png',
          ),
        ]),
      );
      final lista = await repo.modelos();
      expect(lista, hasLength(1));
      expect(lista.single.nombre, 'CX-30');
      expect(lista.single.titulo, 'Mazda CX-30 2025');
      expect(lista.single.imagenUrl, 'https://x/y.png');
    });

    test('un catalogo vacio da una lista vacia', () async {
      final repo = RepositorioCatalogoApi(_ApiConCatalogo(const []));
      expect(await repo.modelos(), isEmpty);
    });
  });

  group('PantallaCatalogo', () {
    testWidgets('es raíz de pestaña: sin regresar ni cerrar', (tester) async {
      await tester.pumpWidget(_app(_Repo(() async => const [_cx5])));
      await tester.pumpAndSettle();

      expect(find.byType(BotonRegresar), findsNothing);
      expect(find.byType(BotonCerrar), findsNothing);
    });

    testWidgets('muestra foto, nombre y precio desde de cada modelo', (
      tester,
    ) async {
      await tester.pumpWidget(_app(_Repo(() async => const [_cx5])));
      await tester.pumpAndSettle();
      expect(find.text('Mazda CX-5 2024'), findsOneWidget);
      expect(find.text(r'Signature · Desde $450,000'), findsOneWidget);
    });

    testWidgets('en ingles traduce titulo, precio y estado vacio', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            repositorioCatalogoProvider.overrideWithValue(
              _Repo(() async => const [_cx5]),
            ),
          ],
          child: conTemaPista(
            const PantallaCatalogo(),
            idioma: const Locale('en'),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Catalog'), findsOneWidget);
      expect(find.text(r'Signature · From $450,000'), findsOneWidget);
      expect(find.text('Catalogo'), findsNothing);
    });

    testWidgets('se ve en los tres escenarios sin desbordar', (tester) async {
      for (final escenario in Escenario.values) {
        await tester.pumpWidget(
          _app(_Repo(() async => const [_cx5, _cx5]), escenario: escenario),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('mientras carga muestra el esqueleto y lo anuncia', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(_Repo(() => Future.delayed(const Duration(seconds: 5), () => []))),
      );
      expect(find.bySemanticsLabel('Cargando catálogo'), findsOneWidget);
      await tester.pump(const Duration(seconds: 6));
    });

    testWidgets('sin modelos muestra el estado vacio', (tester) async {
      await tester.pumpWidget(_app(_Repo(() async => const [])));
      await tester.pumpAndSettle();
      expect(find.byType(EstadoVacio), findsOneWidget);
      expect(find.text('Aún no hay modelos'), findsOneWidget);
    });

    testWidgets('un fallo muestra el error y reintenta', (tester) async {
      var intentos = 0;
      await tester.pumpWidget(
        _app(
          _Repo(() async {
            intentos++;
            if (intentos == 1) throw Exception('fallo');
            return const [_cx5];
          }),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(EstadoError), findsOneWidget);
      expect(find.text('No pudimos cargar esto'), findsOneWidget);

      await tester.tap(find.text('Reintentar'));
      await tester.pumpAndSettle();
      expect(intentos, 2);
      expect(find.text('Mazda CX-5 2024'), findsOneWidget);
    });

    testWidgets('sin conexion lo dice distinto', (tester) async {
      await tester.pumpWidget(
        _app(_Repo(() async => throw const SinConexion())),
      );
      await tester.pumpAndSettle();
      expect(find.text('Sin conexión'), findsOneWidget);
    });

    testWidgets('jalar hacia abajo recarga el catalogo', (tester) async {
      var cargas = 0;
      await tester.pumpWidget(
        _app(
          _Repo(() async {
            cargas++;
            return const [_cx5];
          }),
        ),
      );
      await tester.pumpAndSettle();
      await tester.fling(
        find.byType(CustomScrollView),
        const Offset(0, 400),
        1000,
      );
      await tester.pumpAndSettle();
      expect(cargas, 2);
    });
  });

  test('exporta su ruta', () {
    expect(rutaCatalogo, '/catalogo');
    expect(rutasCatalogo, isNotEmpty);
  });
}
