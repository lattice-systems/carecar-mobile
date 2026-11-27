// V2-M27.03 · contactar a la agencia por el medio que prefiera.
import 'package:carecar_mobile/config/agencia.dart';
import 'package:carecar_mobile/modulos/ayuda/ayuda.dart';
import 'package:carecar_mobile/modulos/ayuda/datos/repositorio_sucursales_fake.dart';
import 'package:carecar_mobile/modulos/ayuda/dominio/repositorio_sucursales.dart';
import 'package:carecar_mobile/nucleo/diseno/tema_pista.dart';
import 'package:carecar_mobile/l10n/idiomas.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../ayudas/tema_pista.dart';

class _Repo implements RepositorioSucursales {
  _Repo(this.alPedir);
  final Future<List<Sucursal>> Function() alPedir;

  @override
  Future<List<Sucursal>> sucursales() => alPedir();
}

const _norte = Sucursal(
  id: 2,
  nombre: 'CareCar Norte con un nombre bastante largo para la prueba',
  direccion:
      'Boulevard Adolfo López Mateos Poniente 4521, Colonia Jardines de los '
      'Naranjos, 37358 León de los Aldama, Guanajuato',
  latitud: 21.1527,
  longitud: -101.6894,
  telefono: '+52 477 999 8877',
  correo: 'norte-con-un-correo-bastante-largo@carecar.example.com',
  abiertaAhora: false,
);

Widget _app(
  RepositorioSucursales repo, {
  Future<bool> Function(Uri)? abrir,
  Escenario escenario = Escenario.claro,
  double ancho = 360,
  Locale idioma = idiomaBase,
  void Function(String)? alIrA,
}) {
  final enrutador = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (_, _) => Center(
          child: SizedBox(width: ancho, child: const PantallaContacto()),
        ),
      ),
      GoRoute(
        path: rutaSucursales,
        builder: (_, _) {
          alIrA?.call(rutaSucursales);
          return const Scaffold(body: Text('pantalla de sucursales'));
        },
      ),
    ],
  );
  return ProviderScope(
    overrides: [
      repositorioSucursalesProvider.overrideWithValue(repo),
      abrirEnlaceDeSucursalProvider.overrideWithValue(
        abrir ?? (_) async => true,
      ),
    ],
    child: MaterialApp.router(
      routerConfig: enrutador,
      theme: escenario == Escenario.oscuro
          ? TemaPista.oscuro()
          : TemaPista.claro(),
      locale: idioma,
      localizationsDelegates: delegadasDeIdioma,
      supportedLocales: idiomasSoportados,
      builder: (context, hijo) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(
            escenario == Escenario.letraGrande ? 2 : 1,
          ),
        ),
        child: hijo!,
      ),
    ),
  );
}

void _vista(WidgetTester tester, Size tamano) {
  tester.view
    ..devicePixelRatio = 1
    ..physicalSize = tamano;
  addTearDown(tester.view.reset);
}

Future<void> _montar(
  WidgetTester tester,
  RepositorioSucursales repo, {
  Future<bool> Function(Uri)? abrir,
  Size tamano = const Size(360, 1200),
  Escenario escenario = Escenario.claro,
  double ancho = 360,
  Locale idioma = idiomaBase,
}) async {
  _vista(tester, tamano);
  await tester.pumpWidget(
    _app(
      repo,
      abrir: abrir,
      escenario: escenario,
      ancho: ancho,
      idioma: idioma,
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('muestra llamar, correo y la sucursal principal', (tester) async {
    await _montar(tester, RepositorioSucursalesFake());

    expect(find.text('Contacto'), findsOneWidget);
    expect(find.text('Llamar a la agencia'), findsOneWidget);
    expect(find.text('+52 477 000 0000'), findsOneWidget);
    expect(find.text('Escribir un correo'), findsOneWidget);
    expect(find.text('contacto@agencia.example.com'), findsOneWidget);
    expect(find.text('Sucursales y horarios'), findsOneWidget);
    expect(find.textContaining('CareCar León'), findsOneWidget);
    expect(find.text('Abierto ahora'), findsOneWidget);
  });

  testWidgets('llamar abre el marcador con el teléfono de la sucursal', (
    tester,
  ) async {
    Uri? abierto;
    await _montar(
      tester,
      _Repo(() async => const [_norte]),
      abrir: (enlace) async {
        abierto = enlace;
        return true;
      },
    );

    await tester.tap(find.text('Llamar a la agencia'));
    await tester.pumpAndSettle();

    expect(abierto.toString(), 'tel:+524779998877');
  });

  testWidgets('escribir abre la app de correo con mailto', (tester) async {
    Uri? abierto;
    await _montar(
      tester,
      RepositorioSucursalesFake(),
      abrir: (enlace) async {
        abierto = enlace;
        return true;
      },
    );

    await tester.tap(find.text('Escribir un correo'));
    await tester.pumpAndSettle();

    expect(abierto.toString(), 'mailto:contacto@agencia.example.com');
  });

  testWidgets('si no hay marcador avisa sin cerrar la pantalla', (
    tester,
  ) async {
    await _montar(
      tester,
      RepositorioSucursalesFake(),
      abrir: (_) async => false,
    );

    await tester.tap(find.text('Llamar a la agencia'));
    await tester.pumpAndSettle();

    expect(find.text('No pudimos abrir el marcador del teléfono.'), findsOne);
    expect(find.text('Contacto'), findsOneWidget);
  });

  testWidgets('si no hay app de correo avisa y da el correo', (tester) async {
    await _montar(
      tester,
      RepositorioSucursalesFake(),
      abrir: (_) async => throw Exception('sin correo'),
    );

    await tester.tap(find.text('Escribir un correo'));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'No pudimos abrir tu app de correo. Escríbenos a '
        'contacto@agencia.example.com.',
      ),
      findsOne,
    );
  });

  testWidgets('sin sucursales usa los datos de la agencia y sigue sirviendo', (
    tester,
  ) async {
    Uri? abierto;
    await _montar(
      tester,
      RepositorioSucursalesFake(sucursales: []),
      abrir: (enlace) async {
        abierto = enlace;
        return true;
      },
    );

    expect(find.text(Agencia.telefono), findsOneWidget);
    expect(find.text('Mapa, horarios y cómo llegar'), findsOneWidget);
    expect(find.text('Abierto ahora'), findsNothing);

    await tester.tap(find.text('Llamar a la agencia'));
    await tester.pumpAndSettle();
    expect(abierto!.scheme, 'tel');
  });

  testWidgets('si la lectura falla también usa la agencia', (tester) async {
    await _montar(tester, _Repo(() async => throw Exception('caído')));

    expect(find.text(Agencia.telefono), findsOneWidget);
    expect(find.text(Agencia.correo), findsOneWidget);
  });

  testWidgets('la fila de sucursales lleva a /sucursales', (tester) async {
    var fue = false;
    _vista(tester, const Size(360, 1200));
    await tester.pumpWidget(
      _app(RepositorioSucursalesFake(), alIrA: (_) => fue = true),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Sucursales y horarios'));
    await tester.pumpAndSettle();

    expect(fue, isTrue);
    expect(find.text('pantalla de sucursales'), findsOneWidget);
  });

  testWidgets('en inglés traduce títulos y filas', (tester) async {
    await _montar(
      tester,
      RepositorioSucursalesFake(),
      idioma: const Locale('en'),
    );

    expect(find.text('Contact'), findsOneWidget);
    expect(find.text('Call the agency'), findsOneWidget);
    expect(find.text('Send an email'), findsOneWidget);
    expect(find.text('Branches and hours'), findsOneWidget);
    expect(find.text('Contacto'), findsNothing);
  });

  group('diseño', () {
    for (final escenario in Escenario.values) {
      testWidgets('320x568 sin desbordar con textos largos ($escenario)', (
        tester,
      ) async {
        await _montar(
          tester,
          _Repo(() async => const [_norte]),
          tamano: const Size(320, 568),
          escenario: escenario,
          ancho: 320,
        );
        expect(tester.takeException(), isNull);

        for (var i = 0; i < 20; i++) {
          if (find.text('Sucursales y horarios').evaluate().isNotEmpty) break;
          await tester.dragFrom(const Offset(160, 540), const Offset(0, -200));
          await tester.pump();
          expect(tester.takeException(), isNull);
        }
        await tester.pumpAndSettle();
        expect(find.text('Sucursales y horarios'), findsOneWidget);
      });
    }

    testWidgets('pantalla ancha sin desbordar', (tester) async {
      await _montar(
        tester,
        RepositorioSucursalesFake(),
        tamano: const Size(1024, 768),
        ancho: 1024,
      );
      expect(tester.takeException(), isNull);
      expect(find.text('Llamar a la agencia'), findsOneWidget);
    });

    testWidgets('al desplazar, el título pequeño toma el lugar del grande', (
      tester,
    ) async {
      await _montar(
        tester,
        _Repo(() async => const [_norte]),
        tamano: const Size(320, 480),
        escenario: Escenario.letraGrande,
        ancho: 320,
      );
      await tester.dragFrom(const Offset(160, 450), const Offset(0, -900));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Contacto').hitTestable(), findsOneWidget);
    });

    testWidgets('el lector de pantalla lee cada fila con su detalle', (
      tester,
    ) async {
      final semantica = tester.ensureSemantics();
      await _montar(tester, RepositorioSucursalesFake());

      expect(
        find.bySemanticsLabel(RegExp('Llamar a la agencia.*477 000 0000')),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel(RegExp('Escribir un correo.*agencia.example')),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel(RegExp('Sucursales y horarios.*CareCar León')),
        findsOneWidget,
      );
      semantica.dispose();
    });
  });
}
