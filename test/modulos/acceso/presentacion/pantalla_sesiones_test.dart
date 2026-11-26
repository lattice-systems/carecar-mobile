import 'package:carecar_mobile/modulos/acceso/acceso.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/dialogo.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/esqueleto.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/estado_error.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/estado_vacio.dart';
import 'package:carecar_mobile/nucleo/sesion/proveedores_sesion.dart';
import 'package:carecar_mobile/sesion/almacen_sesion.dart';
import 'package:carecar_mobile/sesion/controlador_sesion.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../ayudas/api_falsa.dart';
import '../../../ayudas/fallos_de_prueba.dart';
import '../../../ayudas/tema_pista.dart';

/// V2-M01.09 · «ver y cerrar mis sesiones abiertas en otros celulares».
///
/// Esta pantalla responde una pregunta de seguridad: «¿quién está dentro de mi
/// cuenta ahora?». Por eso lo que más se prueba aquí no es que la lista se
/// pinte, sino que **no diga nunca que una sesión se cerró cuando no se
/// cerró**, y que cerrar todas avise antes de que también cierra esta.
void main() {
  final ahora = DateTime.utc(2026, 11, 26, 12, 0);

  SesionDeLaCuenta sesion({
    int id = 9,
    String? dispositivo = 'Pixel 7 · Android 14',
    DateTime? ultimoUso,
    DateTime? iniciadaEn,
  }) => SesionDeLaCuenta(
    id: id,
    dispositivo: dispositivo,
    ultimoUso: ultimoUso,
    iniciadaEn: iniciadaEn,
    expiraEn: ahora.add(const Duration(days: 30)),
  );

  ControladorSesion sesionLocal(ApiFalsa api) =>
      ControladorSesion(api, AlmacenEnMemoria());

  Widget app(
    RepositorioAccesoFake repo, {
    ControladorSesion? local,
    Escenario escenario = Escenario.claro,
  }) => ProviderScope(
    overrides: [
      repositorioAccesoProvider.overrideWithValue(repo),
      relojAccesoProvider.overrideWithValue(() => ahora),
      controladorSesionProvider.overrideWithValue(
        local ?? sesionLocal(ApiFalsa()),
      ),
    ],
    child: conTemaPista(const PantallaSesiones(), escenario: escenario),
  );

  void prueba(String descripcion, Future<void> Function(WidgetTester) cuerpo) =>
      testWidgets(descripcion, (tester) async {
        tester.view.physicalSize = const Size(800, 4000);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        // Con el arbol de semantica prendido: las etiquetas de los botones de
        // cerrar son parte de lo que se prueba, no un adorno.
        // Se libera **dentro** del cuerpo y no con `addTearDown`: Flutter
        // revisa que no queden manejadores vivos antes de correr los
        // `tearDown`, asi que soltarlo ahi llega tarde y falla toda prueba.
        final semantica = tester.ensureSemantics();
        try {
          await cuerpo(tester);
        } finally {
          semantica.dispose();
        }
      });

  /// Toca la fila de esa sesion y confirma el dialogo.
  ///
  /// La accion es la fila completa, no un boton al final: `GrupoLista` no deja
  /// que el lector de pantalla alcance lo que va en `fin`, asi que un boton
  /// ahi seria inalcanzable. Por eso tambien hay confirmacion: una fila que
  /// echa a un dispositivo con un solo toque se dispararia sin querer.
  Future<void> cerrarLaFilaDe(WidgetTester tester, String nombre) async {
    // La etiqueta de la fila junta titulo, subtitulo y lo hablado del `fin`,
    // asi que se busca por coincidencia y no por igualdad.
    await tester.tap(
      find.bySemanticsLabel(RegExp('Cerrar la sesión de $nombre')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cerrar').last);
    await tester.pumpAndSettle();
  }

  group('los cinco estados', () {
    prueba('mientras carga muestra esqueleto', (tester) async {
      final repo = RepositorioAccesoFake()
        ..esperar = Future<void>.delayed(const Duration(milliseconds: 50));

      await tester.pumpWidget(app(repo));
      await tester.pump();

      expect(find.byType(Esqueleto), findsWidgets);

      await tester.pumpAndSettle();
    });

    prueba('sin sesiones muestra el estado vacio', (tester) async {
      await tester.pumpWidget(app(RepositorioAccesoFake()));
      await tester.pumpAndSettle();

      expect(find.byType(EstadoVacio), findsOneWidget);
    });

    prueba('un fallo de red ofrece reintentar', (tester) async {
      final repo = RepositorioAccesoFake()
        ..fallaAlLeerSesiones = Fallos.sinConexion();

      await tester.pumpWidget(app(repo));
      await tester.pumpAndSettle();

      expect(find.byType(EstadoError), findsOneWidget);

      // Reintentar vuelve a pedir: ahora el servidor contesta.
      repo
        ..fallaAlLeerSesiones = null
        ..sesionesAbiertas = [sesion(ultimoUso: ahora)];
      await tester.tap(find.byType(EstadoError));
      await tester.pumpAndSettle();
    });
  });

  group('lo que dice cada fila', () {
    prueba('el nombre del equipo y hace cuanto se uso', (tester) async {
      final repo = RepositorioAccesoFake()
        ..sesionesAbiertas = [
          sesion(ultimoUso: ahora.subtract(const Duration(minutes: 5))),
        ];

      await tester.pumpWidget(app(repo));
      await tester.pumpAndSettle();

      expect(find.text('Pixel 7 · Android 14'), findsOneWidget);
      expect(find.text('Hace 5 minutos'), findsOneWidget);
    });

    prueba('una sesion sin nombre no se queda en blanco', (tester) async {
      // Toda sesion abierta antes de esta historia llega asi.
      final repo = RepositorioAccesoFake()
        ..sesionesAbiertas = [sesion(dispositivo: null, ultimoUso: ahora)];

      await tester.pumpWidget(app(repo));
      await tester.pumpAndSettle();

      expect(find.text('Dispositivo sin nombre'), findsOneWidget);
    });

    prueba('sin fecha alguna dice que no hay actividad', (tester) async {
      final repo = RepositorioAccesoFake()
        ..sesionesAbiertas = [sesion(ultimoUso: null, iniciadaEn: null)];

      await tester.pumpWidget(app(repo));
      await tester.pumpAndSettle();

      expect(find.text('Sin actividad registrada'), findsOneWidget);
    });

    prueba('una sesion recien abierta usa su inicio, no «sin actividad»', (
      tester,
    ) async {
      // Es la de este mismo celular: nunca se ha refrescado.
      final repo = RepositorioAccesoFake()
        ..sesionesAbiertas = [
          sesion(
            ultimoUso: null,
            iniciadaEn: ahora.subtract(const Duration(hours: 2)),
          ),
        ];

      await tester.pumpWidget(app(repo));
      await tester.pumpAndSettle();

      expect(find.text('Hace 2 horas'), findsOneWidget);
      expect(find.text('Sin actividad registrada'), findsNothing);
    });
  });

  group('cerrar una sesion', () {
    prueba('la quita de la lista y lo confirma', (tester) async {
      final repo = RepositorioAccesoFake()
        ..sesionesAbiertas = [
          sesion(id: 9, dispositivo: 'Pixel 7', ultimoUso: ahora),
          sesion(id: 4, dispositivo: 'iPhone 14', ultimoUso: ahora),
        ];

      await tester.pumpWidget(app(repo));
      await tester.pumpAndSettle();

      await cerrarLaFilaDe(tester, 'Pixel 7');

      expect(repo.sesionesCerradas, [9]);
      expect(find.text('Pixel 7'), findsNothing);
      expect(find.text('iPhone 14'), findsOneWidget);
      expect(find.text('Listo, esa sesión se cerró.'), findsOneWidget);
    });

    prueba('cancelar deja la sesion abierta', (tester) async {
      // La direccion peligrosa: si el dialogo cerrara al cancelar, un toque
      // sin querer echaria a un dispositivo del cliente.
      final repo = RepositorioAccesoFake()
        ..sesionesAbiertas = [
          sesion(id: 9, dispositivo: 'Pixel 7', ultimoUso: ahora),
        ];

      await tester.pumpWidget(app(repo));
      await tester.pumpAndSettle();

      await tester.tap(
        find.bySemanticsLabel(RegExp('Cerrar la sesión de Pixel 7')),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();

      expect(repo.sesionesCerradas, isEmpty);
      expect(find.text('Pixel 7'), findsOneWidget);
    });

    prueba('si el id ya cambio, lo dice y la sesion sigue ahi', (tester) async {
      // El caso que no puede mentir: el servidor contesta 404 porque la otra
      // sesion se refresco y tiene otro id, asi que **sigue abierta**.
      final repo = RepositorioAccesoFake()
        ..sesionesAbiertas = [sesion(id: 9, dispositivo: 'Pixel 7')]
        ..fallaAlCerrar = Fallos.noEncontrado();

      await tester.pumpWidget(app(repo));
      await tester.pumpAndSettle();

      await cerrarLaFilaDe(tester, 'Pixel 7');

      expect(
        find.text(
          'Esa sesión cambió mientras la veías. Revisa la lista e inténtalo otra vez.',
        ),
        findsOneWidget,
      );
      expect(find.text('Pixel 7'), findsOneWidget);
      expect(find.text('Listo, esa sesión se cerró.'), findsNothing);
    });

    prueba('sin conexion no la quita ni dice que se cerro', (tester) async {
      final repo = RepositorioAccesoFake()
        ..sesionesAbiertas = [sesion(id: 9, dispositivo: 'Pixel 7')]
        ..fallaAlCerrar = Fallos.sinConexion();

      await tester.pumpWidget(app(repo));
      await tester.pumpAndSettle();

      await cerrarLaFilaDe(tester, 'Pixel 7');

      expect(find.text('Pixel 7'), findsOneWidget);
      expect(
        find.text('No pudimos cerrar esa sesión. Inténtalo otra vez.'),
        findsOneWidget,
      );
    });
  });

  group('cerrar todas', () {
    prueba('pregunta antes y avisa que incluye este telefono', (tester) async {
      final repo = RepositorioAccesoFake()
        ..sesionesAbiertas = [sesion(ultimoUso: ahora)];

      await tester.pumpWidget(app(repo));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cerrar todas las sesiones'));
      await tester.pumpAndSettle();

      expect(find.byType(Dialogo), findsOneWidget);
      expect(
        find.text(
          'Se cerrarán en todos tus dispositivos, incluido este. Tendrás que '
          'entrar otra vez.',
        ),
        findsOneWidget,
      );
      // Todavia no se toco el servidor.
      expect(repo.cerroTodas, isFalse);
    });

    prueba('cancelar no cierra nada', (tester) async {
      final repo = RepositorioAccesoFake()
        ..sesionesAbiertas = [sesion(ultimoUso: ahora)];

      await tester.pumpWidget(app(repo));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cerrar todas las sesiones'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();

      expect(repo.cerroTodas, isFalse);
      expect(find.byType(Dialogo), findsNothing);
    });

    prueba('al confirmar cierra en el servidor y tambien aqui', (tester) async {
      // Cerrar todas incluye la sesion de este celular: si la app se quedara
      // dentro, seguiria usando un access token de una cuenta que ya revoco
      // todo, y el cliente creeria que no se cerro.
      final api = ApiFalsa();
      final local = sesionLocal(api);
      await local.iniciarSesion(
        correo: 'cliente1@example.com',
        contrasena: 'CareCar2026',
      );
      expect(local.estado, isA<Autenticada>());

      final repo = RepositorioAccesoFake()
        ..sesionesAbiertas = [sesion(ultimoUso: ahora)];

      await tester.pumpWidget(app(repo, local: local));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cerrar todas las sesiones'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cerrar todas'));
      await tester.pumpAndSettle();

      expect(repo.cerroTodas, isTrue);
      expect(local.estado, isA<SinSesion>());
    });
  });
}
