import 'package:carecar_mobile/api/excepciones.dart';
import 'package:carecar_mobile/modulos/ayuda/datos/repositorio_sucursales_fake.dart';
import 'package:carecar_mobile/modulos/ayuda/dominio/repositorio_sucursales.dart';
import 'package:carecar_mobile/modulos/ayuda/dominio/sucursal.dart';
import 'package:carecar_mobile/modulos/ayuda/presentacion/pantalla_sucursales.dart';
import 'package:carecar_mobile/modulos/ayuda/presentacion/proveedores_ayuda.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/estado_error.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/estado_vacio.dart';
import 'package:carecar_mobile/nucleo/mapas/mapas.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../ayudas/tema_pista.dart';

class _Repo implements RepositorioSucursales {
  _Repo(this.alPedir);
  final Future<List<Sucursal>> Function() alPedir;

  @override
  Future<List<Sucursal>> sucursales() => alPedir();
}

const _norte = Sucursal(
  id: 2,
  nombre: 'CareCar Norte',
  direccion: 'Av. Norte 450, León, Gto.',
  latitud: 21.1527,
  longitud: -101.6894,
  abiertaAhora: false,
  horarios: [
    HorarioDeDepartamento(
      departamento: Departamento.ventas,
      dias: [1, 2, 3, 4, 5, 6],
      abre: '10:00',
      cierra: '20:00',
      abiertoAhora: false,
    ),
  ],
);

Widget _app(
  RepositorioSucursales repo, {
  Future<bool> Function(Uri)? abrir,
  Escenario escenario = Escenario.claro,
  Locale idioma = const Locale('es'),
}) => ProviderScope(
  overrides: [
    repositorioSucursalesProvider.overrideWithValue(repo),
    fuenteTeselasProvider.overrideWithValue(TeselasLisas()),
    configuracionTeselasProvider.overrideWithValue(
      ConfiguracionTeselas.openStreetMapDesarrollo,
    ),
    abrirEnlaceDeSucursalProvider.overrideWithValue(
      abrir ?? (_) async => true,
    ),
  ],
  child: conTemaPista(
    const PantallaSucursales(),
    escenario: escenario,
    idioma: idioma,
  ),
);

Future<void> _montar(
  WidgetTester tester,
  RepositorioSucursales repo, {
  Future<bool> Function(Uri)? abrir,
}) async {
  await tester.pumpWidget(_app(repo, abrir: abrir));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('muestra la sucursal, si está abierta y sus horarios', (
    tester,
  ) async {
    await _montar(tester, RepositorioSucursalesFake());

    expect(find.text('Sucursales'), findsOneWidget);
    expect(find.text('CareCar León'), findsOneWidget);
    expect(find.text('Abierto ahora'), findsOneWidget);
    expect(
      find.text('Blvd. Ejemplo 100, Col. Centro, 37000 León, Gto.'),
      findsOneWidget,
    );
    expect(find.text('Servicio'), findsOneWidget);
    expect(find.text('lun a vie: 08:00 a 18:00'), findsOneWidget);
    expect(find.text('lun a sáb: 09:00 a 19:00'), findsOneWidget);
  });

  testWidgets('una sucursal cerrada lo dice', (tester) async {
    await _montar(tester, _Repo(() async => const [_norte]));

    expect(find.text('Cerrado'), findsWidgets);
    expect(find.text('Abierto ahora'), findsNothing);
  });

  testWidgets('con varias sucursales se elige cuál ver en el mapa', (
    tester,
  ) async {
    await _montar(
      tester,
      RepositorioSucursalesFake(
        sucursales: [...RepositorioSucursalesFake.ejemplo, _norte],
      ),
    );
    expect(find.text('Todas las sucursales'), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('ubicación de CareCar León')), findsOne);

    await tester.tap(find.text('Av. Norte 450, León, Gto.').last);
    await tester.pumpAndSettle();

    expect(
      find.bySemanticsLabel(RegExp('ubicación de CareCar Norte')),
      findsOne,
    );
  });

  testWidgets('una sola sucursal no muestra la lista de todas', (tester) async {
    await _montar(tester, RepositorioSucursalesFake());

    expect(find.text('Todas las sucursales'), findsNothing);
  });

  testWidgets('Llamar abre el marcador con tel:', (tester) async {
    Uri? abierto;
    await _montar(
      tester,
      RepositorioSucursalesFake(),
      abrir: (enlace) async {
        abierto = enlace;
        return true;
      },
    );

    await tester.tap(find.text('Llamar'));
    await tester.pumpAndSettle();

    expect(abierto.toString(), 'tel:+524770000000');
  });

  testWidgets('Cómo llegar abre la app de mapas', (tester) async {
    Uri? abierto;
    await _montar(
      tester,
      RepositorioSucursalesFake(),
      abrir: (enlace) async {
        abierto = enlace;
        return true;
      },
    );

    await tester.tap(find.text('Cómo llegar'));
    await tester.pumpAndSettle();

    expect(abierto!.scheme, 'geo');
    expect(abierto.toString(), contains('21.125,-101.686'));
  });

  testWidgets('si no se puede abrir el marcador avisa sin cerrar la pantalla', (
    tester,
  ) async {
    await _montar(
      tester,
      RepositorioSucursalesFake(),
      abrir: (_) async => false,
    );

    await tester.tap(find.text('Llamar'));
    await tester.pumpAndSettle();

    expect(find.text('No pudimos abrir el marcador del teléfono.'), findsOne);
    expect(find.text('CareCar León'), findsOneWidget);
  });

  testWidgets('si no se puede abrir el mapa avisa', (tester) async {
    await _montar(
      tester,
      RepositorioSucursalesFake(),
      abrir: (_) async => throw Exception('sin app de mapas'),
    );

    await tester.tap(find.text('Cómo llegar'));
    await tester.pumpAndSettle();

    expect(find.text('No pudimos abrir la app de mapas.'), findsOne);
  });

  testWidgets('una sucursal sin teléfono no ofrece Llamar', (tester) async {
    await _montar(tester, _Repo(() async => const [_norte]));

    expect(find.text('Llamar'), findsNothing);
    expect(find.text('Cómo llegar'), findsOneWidget);
  });

  testWidgets('sin sucursales muestra el estado vacío', (tester) async {
    await _montar(tester, _Repo(() async => const []));

    expect(find.byType(EstadoVacio), findsOneWidget);
    expect(find.text('Aún no hay sucursales'), findsOneWidget);
  });

  testWidgets('mientras carga muestra el esqueleto y lo anuncia', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(_Repo(() => Future.delayed(const Duration(seconds: 5), () => []))),
    );

    expect(find.bySemanticsLabel('Cargando sucursales'), findsOneWidget);
    await tester.pump(const Duration(seconds: 6));
  });

  testWidgets('un fallo muestra el error y reintenta', (tester) async {
    var intentos = 0;
    await _montar(
      tester,
      _Repo(() async {
        intentos++;
        if (intentos == 1) throw Exception('fallo');
        return const [_norte];
      }),
    );
    expect(find.byType(EstadoError), findsOneWidget);

    await tester.tap(find.text('Reintentar'));
    await tester.pumpAndSettle();

    expect(intentos, 2);
    expect(find.text('CareCar Norte'), findsWidgets);
  });

  testWidgets('sin conexión lo dice distinto', (tester) async {
    await _montar(tester, _Repo(() async => throw const SinConexion()));

    expect(find.text('Sin conexión'), findsOneWidget);
  });

  testWidgets('en inglés traduce días, departamentos y botones', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(RepositorioSucursalesFake(), idioma: const Locale('en')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Branches'), findsOneWidget);
    expect(find.text('Open now'), findsOneWidget);
    expect(find.text('Mon to Fri: 08:00 to 18:00'), findsOneWidget);
    expect(find.text('Get directions'), findsOneWidget);
    expect(find.text('Sucursales'), findsNothing);
  });

  testWidgets('se ve en claro, oscuro y letra al 200 % sin desbordar', (
    tester,
  ) async {
    for (final escenario in Escenario.values) {
      await tester.pumpWidget(
        _app(
          RepositorioSucursalesFake(
            sucursales: [...RepositorioSucursalesFake.ejemplo, _norte],
          ),
          escenario: escenario,
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: '$escenario');
    }
  });

  group('sucursalPrincipalProvider', () {
    Future<Sucursal?> leer(RepositorioSucursales repo) {
      final contenedor = ProviderContainer(
        overrides: [repositorioSucursalesProvider.overrideWithValue(repo)],
      );
      addTearDown(contenedor.dispose);
      return contenedor.read(sucursalPrincipalProvider.future);
    }

    test('es la primera que manda el servidor', () async {
      final principal = await leer(
        RepositorioSucursalesFake(sucursales: [_norte]),
      );

      expect(principal!.nombre, 'CareCar Norte');
    });

    test('sin sucursales es nula', () async {
      expect(await leer(RepositorioSucursalesFake(sucursales: [])), isNull);
    });
  });
}
