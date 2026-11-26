import 'package:carecar_mobile/api/excepciones.dart';
import 'package:carecar_mobile/modulos/acceso/datos/repositorio_acceso_fake.dart';
import 'package:carecar_mobile/modulos/acceso/presentacion/pantalla_cambiar_contrasena.dart';
import 'package:carecar_mobile/modulos/acceso/presentacion/proveedores_acceso.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/aviso.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/tono.dart';
import 'package:carecar_mobile/nucleo/navegacion/proveedores_navegacion.dart';
import 'package:carecar_mobile/nucleo/sesion/proveedores_sesion.dart';
import 'package:carecar_mobile/sesion/almacen_sesion.dart';
import 'package:carecar_mobile/sesion/controlador_sesion.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../ayudas/api_falsa.dart';
import '../../../ayudas/tema_pista.dart';

/// V2-M01.03 · la pantalla del cambio obligatorio.
///
/// Los tres criterios: no se puede ir a otra pantalla hasta cambiarla, las
/// reglas se muestran **en vivo**, y no se acepta la temporal como nueva.
void main() {
  late RepositorioAccesoFake repositorio;
  late ProviderContainer contenedor;

  setUp(() => repositorio = RepositorioAccesoFake());

  Future<void> montar(WidgetTester tester) async {
    final sesion = ControladorSesion(ApiFalsa(), AlmacenEnMemoria());
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          controladorSesionProvider.overrideWithValue(sesion),
          repositorioAccesoProvider.overrideWithValue(repositorio),
        ],
        child: conTemaPista(
          Consumer(
            builder: (context, ref, _) {
              contenedor = ProviderScope.containerOf(context);
              return const PantallaCambiarContrasena();
            },
          ),
        ),
      ),
    );
  }

  Future<void> llenar(
    WidgetTester tester, {
    String actual = 'Temporal123',
    String nueva = 'carecar2026',
    String? confirmar,
  }) async {
    await tester.enterText(
      find.byKey(PantallaCambiarContrasena.campoActual),
      actual,
    );
    await tester.enterText(
      find.byKey(PantallaCambiarContrasena.campoNueva),
      nueva,
    );
    await tester.enterText(
      find.byKey(PantallaCambiarContrasena.campoConfirmar),
      confirmar ?? nueva,
    );
    await tester.pump();
  }

  /// La pantalla es mas alta que el viewport de prueba, asi que el boton
  /// queda bajo el pliegue y hay que desplazarse: `tap` a ciegas no lo
  /// alcanza y la prueba pasaria sin probar nada.
  Future<void> guardar(WidgetTester tester) async {
    final boton = find.byKey(PantallaCambiarContrasena.botonGuardar);
    await tester.ensureVisible(boton);
    await tester.pump();
    await tester.tap(boton);
    await tester.pumpAndSettle();
  }

  group('las reglas se ven en vivo', () {
    testWidgets('al abrir se enseñan, sin reclamar nada todavia', (
      tester,
    ) async {
      await montar(tester);

      expect(find.text('De 8 a 72 caracteres'), findsOneWidget);
      expect(find.text('Al menos una letra'), findsOneWidget);
      expect(find.text('Al menos un número'), findsOneWidget);
      expect(find.text('Distinta de la temporal'), findsOneWidget);
      // Nadie ha escrito: no hay error que mostrar.
      expect(find.byKey(PantallaCambiarContrasena.avisoDeError), findsNothing);
    });

    testWidgets('se van marcando mientras se escribe', (tester) async {
      await montar(tester);

      await tester.enterText(
        find.byKey(PantallaCambiarContrasena.campoNueva),
        'care',
      );
      await tester.pump();
      var reglas = tester.widget<ListaDeReglas>(find.byType(ListaDeReglas));
      expect(reglas.revision.tieneLetra, isTrue);
      expect(reglas.revision.tieneNumero, isFalse);
      expect(reglas.revision.largoSuficiente, isFalse);

      await tester.enterText(
        find.byKey(PantallaCambiarContrasena.campoNueva),
        'carecar2026',
      );
      await tester.pump();
      reglas = tester.widget<ListaDeReglas>(find.byType(ListaDeReglas));
      expect(reglas.revision.cumpleTodo, isTrue);
    });
  });

  group('no deja guardar lo que el servidor va a rechazar', () {
    testWidgets('con las reglas sin cumplir no llama al repositorio', (
      tester,
    ) async {
      await montar(tester);
      await llenar(tester, nueva: 'corta1');
      await guardar(tester);

      expect(repositorio.llamadas, 0);
    });

    testWidgets('la temporal como nueva no se acepta', (tester) async {
      await montar(tester);
      await llenar(tester, actual: 'Temporal123', nueva: 'Temporal123');
      await guardar(tester);

      expect(repositorio.llamadas, 0);
      final reglas = tester.widget<ListaDeReglas>(find.byType(ListaDeReglas));
      expect(reglas.revision.esDistintaDeLaActual, isFalse);
    });

    testWidgets('si la confirmacion no coincide, avisa y no llama', (
      tester,
    ) async {
      await montar(tester);
      await llenar(tester, nueva: 'carecar2026', confirmar: 'carecar2027');
      await guardar(tester);

      expect(repositorio.llamadas, 0);
      expect(find.text('Las dos contraseñas no son iguales.'), findsOneWidget);
    });
  });

  group('al guardar bien', () {
    testWidgets('manda lo que se escribio y marca la contrasena cambiada', (
      tester,
    ) async {
      await montar(tester);
      expect(contenedor.read(contrasenaCambiadaProvider), isFalse);

      await llenar(tester);
      await guardar(tester);

      expect(repositorio.llamadas, 1);
      expect(repositorio.ultimaActual, 'Temporal123');
      expect(repositorio.ultimaNueva, 'carecar2026');
      // Sin esta marca el guardia mandaria al cambio una y otra vez, porque
      // el contrato no devuelve una sesion nueva.
      expect(contenedor.read(contrasenaCambiadaProvider), isTrue);
    });

    testWidgets('dos toques seguidos no mandan dos peticiones', (tester) async {
      await montar(tester);
      await llenar(tester);

      final boton = find.byKey(PantallaCambiarContrasena.botonGuardar);
      await tester.ensureVisible(boton);
      await tester.pump();
      await tester.tap(boton);
      await tester.pump();
      await tester.tap(boton);
      await tester.pumpAndSettle();

      expect(repositorio.llamadas, 1);
    });
  });

  group('cuando el servidor rechaza', () {
    testWidgets('un 400 se muestra como error y no marca nada', (tester) async {
      repositorio.falla = const DatosInvalidos('Revisa los datos.');
      await montar(tester);
      await llenar(tester);
      await guardar(tester);

      final aviso = tester.widget<Aviso>(
        find.byKey(PantallaCambiarContrasena.avisoDeError),
      );
      expect(aviso.tono, Tono.peligro);
      expect(contenedor.read(contrasenaCambiadaProvider), isFalse);
    });

    testWidgets('sin conexion es advertencia, no error', (tester) async {
      repositorio.falla = const SinConexion();
      await montar(tester);
      await llenar(tester);
      await guardar(tester);

      final aviso = tester.widget<Aviso>(
        find.byKey(PantallaCambiarContrasena.avisoDeError),
      );
      expect(aviso.tono, Tono.advertencia);
      expect(find.text('Sin conexión'), findsOneWidget);
    });
  });

  group('la unica salida es cerrar sesion', () {
    testWidgets('no hay boton de regresar ni de omitir', (tester) async {
      await montar(tester);

      // El criterio es que no se pueda ir a otra pantalla hasta cambiarla.
      expect(find.textContaining('mitir'), findsNothing);
      expect(find.textContaining('espués'), findsNothing);
      expect(find.byType(BackButton), findsNothing);
      expect(
        find.byKey(PantallaCambiarContrasena.botonCerrarSesion),
        findsOneWidget,
      );
    });
  });
}
