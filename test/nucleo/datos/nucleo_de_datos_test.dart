import 'package:carecar_mobile/api/modelos/problema.dart';
import 'package:carecar_mobile/nucleo/datos/fallo.dart';
import 'package:carecar_mobile/nucleo/datos/reintento.dart';
import 'package:carecar_mobile/nucleo/datos/vista_asincrona.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/esqueleto.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/estado_error.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/estado_vacio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../ayudas/fallos_de_prueba.dart';
import '../../ayudas/repositorio_falso.dart';
import '../../ayudas/tema_pista.dart';

/// V2-T01.08 · criterio 5: una prueba por estado y por tipo de error, **de
/// punta a punta**.
///
/// Las piezas ya estan probadas por separado. Esto comprueba que encajan: un
/// repositorio falso que usa [RepositorioBase], detras de un proveedor de
/// Riverpod, pintado por [VistaAsincrona], hasta lo que el usuario alcanza a
/// leer en la pantalla.
///
/// Es la prueba que un modulo puede copiar para su propia pantalla cambiando
/// el tipo y el repositorio.
void main() {
  late RepositorioFalso<List<String>> repositorio;
  late FutureProvider<List<String>> vehiculos;

  setUp(() {
    repositorio = RepositorioFalso<List<String>>(['Sentra 2026']);
    vehiculos = FutureProvider<List<String>>((ref) => repositorio.leer());
  });

  Future<void> montar(WidgetTester tester) => tester.pumpWidget(
    ProviderScope(
      // La misma politica que instala `main.dart`: sin ella Riverpod
      // reintentaria hasta un 404, diez veces.
      retry: reintentoDelNucleo,
      child: conTemaPista(
        Consumer(
          builder: (context, ref, _) => VistaAsincrona<List<String>>(
            estado: ref.watch(vehiculos),
            cargando: (_) => const Esqueleto(alto: 72),
            datos: (_, lista) => Text(lista.join(', ')),
            vacio: (_) => const EstadoVacio(titulo: 'Aun no tienes vehiculos'),
            alReintentar: () => ref.invalidate(vehiculos),
          ),
        ),
      ),
    ),
  );

  group('los cinco estados', () {
    testWidgets('1 · cargando', (tester) async {
      repositorio.latencia = const Duration(milliseconds: 60);

      await montar(tester);
      await tester.pump();

      expect(find.byType(Esqueleto), findsOneWidget);
      expect(find.text('Sentra 2026'), findsNothing);

      await tester.pumpAndSettle();
      expect(find.text('Sentra 2026'), findsOneWidget);
    });

    testWidgets('2 · datos', (tester) async {
      await montar(tester);
      await tester.pumpAndSettle();

      expect(find.text('Sentra 2026'), findsOneWidget);
      expect(find.byType(EstadoError), findsNothing);
      expect(find.byType(EstadoVacio), findsNothing);
    });

    testWidgets('3 · vacio', (tester) async {
      repositorio.valor = [];

      await montar(tester);
      await tester.pumpAndSettle();

      expect(find.byType(EstadoVacio), findsOneWidget);
      expect(find.text('Aun no tienes vehiculos'), findsOneWidget);
    });

    testWidgets('4 · error', (tester) async {
      repositorio.falla = Fallos.servidor();

      await montar(tester);
      await tester.pumpAndSettle();

      final error = tester.widget<EstadoError>(find.byType(EstadoError));
      expect(error.causa, CausaError.generico);
    });

    testWidgets('5 · sin conexion', (tester) async {
      repositorio.falla = Fallos.sinConexion();

      await montar(tester);
      await tester.pumpAndSettle();

      final error = tester.widget<EstadoError>(find.byType(EstadoError));
      expect(error.causa, CausaError.sinConexion);
      expect(find.text('Sin conexion'), findsOneWidget);
    });
  });

  group('cada tipo de error llega tipado a la pantalla', () {
    final casos = <String, (Fallo, CausaError)>{
      'sin conexion': (Fallos.sinConexion(), CausaError.sinConexion),
      'sesion terminada (401)': (Fallos.sesionTerminada(), CausaError.generico),
      'cuenta desactivada (403)': (
        Fallos.cuentaDesactivada(),
        CausaError.generico,
      ),
      'no encontrado (404)': (Fallos.noEncontrado(), CausaError.generico),
      'conflicto (409)': (
        Fallos.conflicto(CodigoProblema.franjaSinCupo),
        CausaError.generico,
      ),
      'validacion (400)': (Fallos.validacion(), CausaError.generico),
      'servidor (5xx)': (Fallos.servidor(), CausaError.generico),
      'demasiados intentos (429)': (
        Fallos.demasiadosIntentos(),
        CausaError.generico,
      ),
    };

    casos.forEach((nombre, caso) {
      final (fallo, causaEsperada) = caso;

      testWidgets(nombre, (tester) async {
        repositorio.falla = fallo;

        await montar(tester);
        await tester.pumpAndSettle();

        expect(find.byType(EstadoError), findsOneWidget);
        final error = tester.widget<EstadoError>(find.byType(EstadoError));
        expect(error.causa, causaEsperada);
        // Siempre hay salida: nunca una pantalla en blanco.
        expect(find.text('Reintentar'), findsOneWidget);
      });
    });
  });

  group('nunca se filtra el detalle tecnico (RIC-14)', () {
    testWidgets('un 400 no enseña el nombre del campo', (tester) async {
      // El `message` real de este fallo es «contrasenaNueva: must not be
      // blank», escrito para quien programa.
      repositorio.falla = Fallos.validacion();

      await montar(tester);
      await tester.pumpAndSettle();

      expect(find.textContaining('contrasenaNueva'), findsNothing);
      expect(find.textContaining('Revisa los datos'), findsOneWidget);
    });

    testWidgets('un 5xx no enseña la excepcion de Java', (tester) async {
      repositorio.falla = Fallos.servidor();

      await montar(tester);
      await tester.pumpAndSettle();

      expect(find.textContaining('NullPointerException'), findsNothing);
    });

    testWidgets('un bug nuestro tampoco se enseña', (tester) async {
      // No es un error del contrato: es el mapeo de un DTO reventando.
      repositorio.reventarUnaVez(
        ArgumentError('contrasenaNueva: must not be null'),
      );

      await montar(tester);
      await tester.pumpAndSettle();

      expect(find.byType(EstadoError), findsOneWidget);
      expect(find.textContaining('contrasenaNueva'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });

  group('reintentar cierra el ciclo', () {
    testWidgets('un fallo que no se reintenta deja el error, y el boton lo '
        'resuelve', (tester) async {
      // Un 404 no se reintenta solo, asi que el usuario si ve el error y el
      // boton es la unica salida.
      repositorio.fallarUnaVez(Fallos.noEncontrado());

      await montar(tester);
      await tester.pumpAndSettle();
      expect(find.byType(EstadoError), findsOneWidget);
      expect(repositorio.llamadas, 1);

      await tester.tap(find.text('Reintentar'));
      await tester.pumpAndSettle();

      expect(find.text('Sentra 2026'), findsOneWidget);
      expect(find.byType(EstadoError), findsNothing);
      expect(repositorio.llamadas, 2);
    });

    testWidgets('un fallo pasajero se arregla solo, sin que el usuario haga '
        'nada', (tester) async {
      // Un 5xx si se reintenta: Riverpod vuelve a pedir y la pantalla pasa
      // del error a los datos sola. Es el comportamiento que descubrio esta
      // historia y conviene tenerlo fijado.
      repositorio.fallarUnaVez(Fallos.servidor());

      await montar(tester);
      await tester.pumpAndSettle();

      expect(find.text('Sentra 2026'), findsOneWidget);
      expect(find.byType(EstadoError), findsNothing);
      expect(repositorio.llamadas, 2);
    });
  });
}
