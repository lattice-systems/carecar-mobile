import 'dart:async';

import 'package:carecar_mobile/modulos/privacidad/dominio/arco.dart';
import 'package:carecar_mobile/modulos/privacidad/presentacion/pantalla_eliminar_cuenta.dart';
import 'package:carecar_mobile/modulos/privacidad/presentacion/proveedores_arco.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/aviso.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/campo_texto.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/deslizar_para_confirmar.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/tono.dart';
import 'package:carecar_mobile/nucleo/sesion/proveedores_sesion.dart';
import 'package:carecar_mobile/sesion/almacen_sesion.dart';
import 'package:carecar_mobile/sesion/controlador_sesion.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../ayudas/api_falsa.dart';
import '../../ayudas/auditoria_accesibilidad.dart';
import '../../ayudas/tema_pista.dart';
import 'repositorio_arco_falso.dart';

late ControladorSesion _sesion;

Widget _escena(RepositorioArcoFalso repo, Widget hijo) => ProviderScope(
  // Una escena nueva en cada llamada: sin llave, Flutter reusaría el estado de
  // la anterior (el texto escrito, el último fallo).
  key: UniqueKey(),
  overrides: [
    repositorioArcoProvider.overrideWithValue(repo),
    controladorSesionProvider.overrideWithValue(_sesion),
  ],
  child: hijo,
);

Widget _app(
  RepositorioArcoFalso repo, {
  Escenario escenario = Escenario.claro,
}) => _escena(
  repo,
  conTemaPista(const PantallaEliminarCuenta(), escenario: escenario),
);

void _prueba(String descripcion, Future<void> Function(WidgetTester) cuerpo) =>
    testWidgets(descripcion, (tester) async {
      tester.view.physicalSize = const Size(800, 3200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      _sesion = ControladorSesion(ApiFalsa(), AlmacenEnMemoria());
      addTearDown(_sesion.dispose);
      await _sesion.iniciarSesion(correo: 'a@b.mx', contrasena: 'x');
      await cuerpo(tester);
    });

Future<void> _dejarCorrer(WidgetTester tester) async {
  for (var i = 0; i < 4; i++) {
    await tester.pump();
  }
}

Future<void> _escribir(WidgetTester tester, String contrasena) async {
  await tester.enterText(find.byType(TextField), contrasena);
  await tester.pump();
}

Future<void> _deslizar(WidgetTester tester) async {
  final perilla = find.byKey(const ValueKey('perilla'));
  await tester.ensureVisible(perilla);
  await tester.pump();
  await tester.drag(perilla, const Offset(700, 0));
  await _dejarCorrer(tester);
}

/// Si se puede confirmar: el control de deslizar solo tiene acción con una
/// contraseña escrita y sin una petición en curso.
bool _sePuedeEliminar(WidgetTester tester) =>
    tester
        .widget<DeslizarParaConfirmar>(find.byType(DeslizarParaConfirmar))
        .alConfirmar !=
    null;

void main() {
  group('PantallaEliminarCuenta (V2-M22.03)', () {
    _prueba(
      'explica que no se puede deshacer, que se borra y que se conserva',
      (tester) async {
        await tester.pumpWidget(_app(RepositorioArcoFalso()));
        await _dejarCorrer(tester);

        expect(find.text('Eliminar mi cuenta'), findsOneWidget);
        expect(find.textContaining('No se puede deshacer'), findsOneWidget);
        expect(find.text('Qué se borra'), findsOneWidget);
        expect(
          find.textContaining('Tu nombre, correo y teléfono'),
          findsOneWidget,
        );
        expect(find.textContaining('Tus direcciones'), findsOneWidget);
        expect(find.textContaining('bitácora de gastos'), findsOneWidget);
        expect(find.text('Qué conservamos'), findsOneWidget);
        expect(find.textContaining('historial de servicio'), findsOneWidget);
        expect(find.textContaining('aviso de privacidad'), findsOneWidget);
      },
    );

    _prueba('no deja eliminar hasta escribir la contraseña', (tester) async {
      await tester.pumpWidget(_app(RepositorioArcoFalso()));
      await _dejarCorrer(tester);

      expect(find.byType(CampoContrasena), findsOneWidget);
      expect(_sePuedeEliminar(tester), isFalse);
      expect(
        tester
            .widget<DeslizarParaConfirmar>(find.byType(DeslizarParaConfirmar))
            .peligro,
        isTrue,
      );

      await _escribir(tester, 'Secreta123');
      expect(_sePuedeEliminar(tester), isTrue);

      await _escribir(tester, '');
      expect(_sePuedeEliminar(tester), isFalse);
    });

    _prueba(
      'deslizar pide la cancelacion con esa contraseña y cierra la sesion',
      (tester) async {
        final repo = RepositorioArcoFalso();
        await tester.pumpWidget(_app(repo));
        await _dejarCorrer(tester);
        expect(_sesion.estado, isA<Autenticada>());

        await _escribir(tester, 'Secreta123');
        await _deslizar(tester);

        expect(repo.cancelaciones, ['Secreta123']);
        expect(_sesion.estado, isA<SinSesion>());
        // El aviso sobrevive a la pantalla: vive en el mensajero de la app.
        expect(
          find.text('Tu cuenta se eliminó. Gracias por usar CareCar.'),
          findsOneWidget,
        );
      },
    );

    _prueba('deslizar sin contraseña no pide nada', (tester) async {
      final repo = RepositorioArcoFalso();
      await tester.pumpWidget(_app(repo));
      await _dejarCorrer(tester);

      await _deslizar(tester);

      expect(repo.cancelaciones, isEmpty);
      expect(_sesion.estado, isA<Autenticada>());
    });

    _prueba('mientras elimina lo dice y no deja pedir otra vez', (
      tester,
    ) async {
      final repo = RepositorioArcoFalso()..esperaAlCancelar = Completer<void>();
      await tester.pumpWidget(_app(repo));
      await _dejarCorrer(tester);
      await _escribir(tester, 'Secreta123');

      await _deslizar(tester);

      expect(find.text('Eliminando tu cuenta…'), findsOneWidget);
      expect(find.byType(DeslizarParaConfirmar), findsNothing);
      expect(tester.widget<TextField>(find.byType(TextField)).enabled, isFalse);
      expect(repo.cancelaciones, ['Secreta123']);
      expect(_sesion.estado, isA<Autenticada>());

      repo.esperaAlCancelar!.complete();
      await _dejarCorrer(tester);
      expect(_sesion.estado, isA<SinSesion>());
      expect(repo.cancelaciones, ['Secreta123']);
    });

    _prueba(
      'si sales de la pantalla mientras elimina, la sesion se cierra igual',
      (tester) async {
        final repo = RepositorioArcoFalso()
          ..esperaAlCancelar = Completer<void>();
        final mostrar = ValueNotifier(true);
        addTearDown(mostrar.dispose);
        await tester.pumpWidget(
          _escena(
            repo,
            conTemaPista(
              ValueListenableBuilder<bool>(
                valueListenable: mostrar,
                builder: (_, visible, _) =>
                    visible ? const PantallaEliminarCuenta() : const SizedBox(),
              ),
            ),
          ),
        );
        await _dejarCorrer(tester);
        await _escribir(tester, 'Secreta123');
        await _deslizar(tester);

        mostrar.value = false;
        await _dejarCorrer(tester);
        repo.esperaAlCancelar!.complete();
        await _dejarCorrer(tester);

        // La cuenta ya no existe en el servidor: la sesion no puede quedar abierta.
        expect(_sesion.estado, isA<SinSesion>());
        expect(tester.takeException(), isNull);
      },
    );

    _prueba(
      'una contraseña incorrecta lo dice en el campo y deja intentar otra',
      (tester) async {
        final repo = RepositorioArcoFalso()
          ..alCancelar = const ContrasenaIncorrecta();
        await tester.pumpWidget(_app(repo));
        await _dejarCorrer(tester);
        await _escribir(tester, 'mala');

        await _deslizar(tester);

        expect(find.text('La contraseña no es correcta.'), findsOneWidget);
        expect(_sesion.estado, isA<Autenticada>());
        expect(find.text('Eliminando tu cuenta…'), findsNothing);
        expect(_sePuedeEliminar(tester), isTrue);

        repo.alCancelar = null;
        await _escribir(tester, 'Secreta123');
        // Al volver a escribir se quita el error de la contraseña anterior.
        expect(find.text('La contraseña no es correcta.'), findsNothing);
        await _deslizar(tester);

        expect(repo.cancelaciones, ['mala', 'Secreta123']);
        expect(_sesion.estado, isA<SinSesion>());
      },
    );

    _prueba('el bloqueo dice cuántos minutos esperar', (tester) async {
      final casos = <Duration?, String>{
        const Duration(minutes: 15):
            'Demasiados intentos. Intenta de nuevo en 15 minutos.',
        const Duration(seconds: 61):
            'Demasiados intentos. Intenta de nuevo en 2 minutos.',
        const Duration(seconds: 45):
            'Demasiados intentos. Intenta de nuevo en 1 minuto.',
        // Medio segundo no es «0 minutos»; un tiempo que no corre, tampoco.
        const Duration(milliseconds: 500):
            'Demasiados intentos. Intenta de nuevo en 1 minuto.',
        Duration.zero: 'Demasiados intentos. Intenta de nuevo más tarde.',
        null: 'Demasiados intentos. Intenta de nuevo más tarde.',
      };
      for (final MapEntry(key: espera, value: texto) in casos.entries) {
        final repo = RepositorioArcoFalso()
          ..alCancelar = CancelacionBloqueada(espera);
        await tester.pumpWidget(_app(repo));
        await _dejarCorrer(tester);
        await _escribir(tester, 'mala');

        await _deslizar(tester);

        expect(find.text(texto), findsOneWidget, reason: '$espera');
        expect(_sesion.estado, isA<Autenticada>(), reason: '$espera');
        // El bloqueo no es una contraseña equivocada: el campo no lo dice.
        expect(find.text('La contraseña no es correcta.'), findsNothing);
      }
    });

    _prueba('sin conexion y error del servidor avisan y dejan reintentar', (
      tester,
    ) async {
      final casos = <FalloArco, (String, Tono)>{
        const ArcoSinConexion(): (
          'Sin conexión. Revisa tu internet e inténtalo de nuevo.',
          Tono.advertencia,
        ),
        const ArcoNoDisponible(): (
          'No pudimos eliminar tu cuenta. Inténtalo de nuevo.',
          Tono.peligro,
        ),
      };
      for (final MapEntry(key: fallo, value: (texto, tono)) in casos.entries) {
        final repo = RepositorioArcoFalso()..alCancelar = fallo;
        await tester.pumpWidget(_app(repo));
        await _dejarCorrer(tester);
        await _escribir(tester, 'Secreta123');

        await _deslizar(tester);

        expect(find.text(texto), findsOneWidget, reason: '$fallo');
        expect(tester.widget<Aviso>(find.byType(Aviso).last).tono, tono);
        expect(_sesion.estado, isA<Autenticada>(), reason: '$fallo');
        expect(_sePuedeEliminar(tester), isTrue, reason: '$fallo');
        expect(find.text('La contraseña no es correcta.'), findsNothing);

        // Al reintentar, el aviso anterior se quita mientras se vuelve a pedir.
        repo
          ..alCancelar = null
          ..esperaAlCancelar = Completer<void>();
        await _deslizar(tester);

        expect(find.text(texto), findsNothing, reason: '$fallo');
        expect(find.text('Eliminando tu cuenta…'), findsOneWidget);
        repo.esperaAlCancelar!.complete();
        await _dejarCorrer(tester);
        expect(_sesion.estado, isA<SinSesion>(), reason: '$fallo');
        await _sesion.iniciarSesion(correo: 'a@b.mx', contrasena: 'x');
      }
    });

    _prueba(
      'si la cuenta ya estaba cerrada, lo da por hecho y cierra la sesion',
      (tester) async {
        final repo = RepositorioArcoFalso()
          ..alCancelar = const CuentaYaCerrada();
        await tester.pumpWidget(_app(repo));
        await _dejarCorrer(tester);
        await _escribir(tester, 'Secreta123');

        await _deslizar(tester);

        expect(_sesion.estado, isA<SinSesion>());
        expect(
          find.text('Tu cuenta se eliminó. Gracias por usar CareCar.'),
          findsOneWidget,
        );
      },
    );

    _prueba('con lector de pantalla, un boton pide confirmar en un dialogo', (
      tester,
    ) async {
      final repo = RepositorioArcoFalso();
      await tester.pumpWidget(
        _escena(
          repo,
          conTemaPista(
            // Como con TalkBack o VoiceOver: deslizar deja de ser el gesto.
            Builder(
              builder: (context) => MediaQuery(
                data: MediaQuery.of(context)
                    .copyWith(accessibleNavigation: true),
                child: const PantallaEliminarCuenta(),
              ),
            ),
          ),
        ),
      );
      await _dejarCorrer(tester);
      await _escribir(tester, 'Secreta123');

      await tester.tap(find.text('Desliza para eliminar mi cuenta'));
      await tester.pumpAndSettle();

      expect(
        find.textContaining('Se borran tus datos personales'),
        findsOneWidget,
      );
      expect(repo.cancelaciones, isEmpty);

      await tester.tap(find.text('Confirmar'));
      await _dejarCorrer(tester);

      expect(repo.cancelaciones, ['Secreta123']);
      expect(_sesion.estado, isA<SinSesion>());
    });

    _prueba('pasa la auditoria de accesibilidad en los tres escenarios', (
      tester,
    ) async {
      for (final escenario in Escenario.values) {
        await tester.pumpWidget(
          _app(RepositorioArcoFalso(), escenario: escenario),
        );
        await _dejarCorrer(tester);
        await auditarAccesibilidad(tester);
        expect(tester.takeException(), isNull, reason: '$escenario');
      }
    });
  });
}
