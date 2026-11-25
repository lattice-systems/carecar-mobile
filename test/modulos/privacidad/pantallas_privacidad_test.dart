import 'dart:async';

import 'package:carecar_mobile/modulos/privacidad/dominio/privacidad.dart';
import 'package:carecar_mobile/modulos/privacidad/presentacion/pantalla_aceptar_aviso.dart';
import 'package:carecar_mobile/modulos/privacidad/presentacion/pantalla_aviso_privacidad.dart';
import 'package:carecar_mobile/modulos/privacidad/presentacion/proveedores_privacidad.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/boton_pildora.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/estado_error.dart';
import 'package:carecar_mobile/nucleo/privacidad/estado_aviso.dart';
import 'package:carecar_mobile/nucleo/sesion/proveedores_sesion.dart';
import 'package:carecar_mobile/sesion/almacen_sesion.dart';
import 'package:carecar_mobile/sesion/controlador_sesion.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../ayudas/api_falsa.dart';
import '../../ayudas/auditoria_accesibilidad.dart';
import '../../ayudas/tema_pista.dart';
import 'repositorio_privacidad_falso.dart';

AvisoDePrivacidad _aviso({
  int id = 3,
  int version = 2,
  bool aceptado = false,
  DateTime? aceptadoEn,
  String texto = 'Primer párrafo del aviso.\n\nSegundo párrafo del aviso.',
}) => AvisoDePrivacidad(
  id: id,
  version: version,
  texto: texto,
  vigenteDesde: DateTime.utc(2026, 11, 25, 18),
  aceptado: aceptado,
  aceptadoEn: aceptadoEn,
);

late ControladorSesion _sesion;

Widget _escena(RepositorioPrivacidadFalso repo, Widget hijo) => ProviderScope(
  overrides: [
    repositorioPrivacidadProvider.overrideWithValue(repo),
    controladorSesionProvider.overrideWithValue(_sesion),
  ],
  child: hijo,
);

Widget _app(
  Widget pantalla,
  RepositorioPrivacidadFalso repo, {
  Escenario escenario = Escenario.claro,
}) => _escena(repo, conTemaPista(pantalla, escenario: escenario));

void _prueba(String descripcion, Future<void> Function(WidgetTester) cuerpo) =>
    testWidgets(descripcion, (tester) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      _sesion = ControladorSesion(ApiFalsa(), AlmacenEnMemoria());
      addTearDown(_sesion.dispose);
      await cuerpo(tester);
    });

ProviderContainer _contenedor(WidgetTester tester) =>
    ProviderScope.containerOf(tester.element(find.byType(MaterialApp)));

/// Deja correr los cuadros que hacen falta para que se vea lo que ya llegó,
/// sin esperar a lo que sigue pendiente (un esqueleto nunca "se asienta").
Future<void> _dejarCorrer(WidgetTester tester) async {
  for (var i = 0; i < 3; i++) {
    await tester.pump();
  }
}

BotonPildora _botonAceptar(WidgetTester tester) => tester.widget<BotonPildora>(
  find.ancestor(
    of: find.textContaining(RegExp('Acepto el aviso|Guardando')),
    matching: find.byType(BotonPildora),
  ),
);

void main() {
  group('PantallaAceptarAviso (V2-M22.01)', () {
    _prueba('muestra la version, la vigencia y el texto por parrafos', (
      tester,
    ) async {
      final repo = RepositorioPrivacidadFalso()..avisos.add(_aviso());
      await tester.pumpWidget(_app(const PantallaAceptarAviso(), repo));
      await _dejarCorrer(tester);

      expect(find.text('Aviso de privacidad'), findsOneWidget);
      expect(find.text('Antes de continuar'), findsOneWidget);
      expect(
        find.text(
          'Lee el aviso de privacidad. Para usar CareCar necesitas aceptarlo.',
        ),
        findsOneWidget,
      );
      expect(find.text('Versión 2'), findsOneWidget);
      expect(find.textContaining('Vigente desde el'), findsOneWidget);
      expect(find.text('Primer párrafo del aviso.'), findsOneWidget);
      expect(find.text('Segundo párrafo del aviso.'), findsOneWidget);
    });

    _prueba('mientras carga no deja aceptar y lo anuncia', (tester) async {
      final repo = RepositorioPrivacidadFalso()
        ..avisos.add(_aviso())
        ..esperaAlLeer = Completer<void>();
      await tester.pumpWidget(_app(const PantallaAceptarAviso(), repo));
      await tester.pump();

      expect(_botonAceptar(tester).alPresionar, isNull);
      expect(
        find.bySemanticsLabel('Cargando el aviso de privacidad'),
        findsOneWidget,
      );
      expect(find.text('Primer párrafo del aviso.'), findsNothing);

      repo.esperaAlLeer!.complete();
      await _dejarCorrer(tester);
      expect(_botonAceptar(tester).alPresionar, isNotNull);
    });

    _prueba('aceptar registra el aviso, abre la puerta y avisa que guarda', (
      tester,
    ) async {
      final repo = RepositorioPrivacidadFalso()
        ..avisos.add(_aviso())
        ..esperaAlAceptar = Completer<void>();
      await tester.pumpWidget(_app(const PantallaAceptarAviso(), repo));
      await _dejarCorrer(tester);
      _contenedor(tester).read(estadoAvisoProvider.notifier).pendiente();

      await tester.tap(find.text('Acepto el aviso de privacidad'));
      await tester.pump();

      expect(repo.aceptados, [3]);
      expect(find.text('Guardando…'), findsOneWidget);
      expect(_botonAceptar(tester).alPresionar, isNull);
      expect(
        _contenedor(tester).read(estadoAvisoProvider),
        EstadoAviso.pendiente,
      );

      repo.esperaAlAceptar!.complete();
      await _dejarCorrer(tester);

      expect(
        _contenedor(tester).read(estadoAvisoProvider),
        EstadoAviso.aceptado,
      );
    });

    _prueba(
      'si la agencia publico otra version, muestra la nueva con un aviso',
      (tester) async {
        final repo = RepositorioPrivacidadFalso()
          ..avisos.addAll([
            _aviso(),
            _aviso(id: 4, version: 3, texto: 'Texto de la versión tres.'),
          ])
          ..fallosAlAceptar.add(const AvisoNoVigente());
        await tester.pumpWidget(_app(const PantallaAceptarAviso(), repo));
        await _dejarCorrer(tester);
        _contenedor(tester).read(estadoAvisoProvider.notifier).pendiente();

        await tester.tap(find.text('Acepto el aviso de privacidad'));
        await _dejarCorrer(tester);

        expect(repo.aceptados, [3]);
        expect(
          find.textContaining('El aviso cambió mientras lo leías'),
          findsOneWidget,
        );
        expect(find.text('Versión 3'), findsOneWidget);
        expect(find.text('Texto de la versión tres.'), findsOneWidget);
        expect(
          _contenedor(tester).read(estadoAvisoProvider),
          EstadoAviso.pendiente,
        );

        // Acepta la nueva, no la vieja.
        await tester.tap(find.text('Acepto el aviso de privacidad'));
        await _dejarCorrer(tester);
        expect(repo.aceptados, [3, 4]);
        expect(
          _contenedor(tester).read(estadoAvisoProvider),
          EstadoAviso.aceptado,
        );
      },
    );

    _prueba('sin conexion al aceptar lo dice y deja reintentar', (
      tester,
    ) async {
      final repo = RepositorioPrivacidadFalso()
        ..avisos.add(_aviso())
        ..fallosAlAceptar.add(const PrivacidadSinConexion());
      await tester.pumpWidget(_app(const PantallaAceptarAviso(), repo));
      await _dejarCorrer(tester);
      _contenedor(tester).read(estadoAvisoProvider.notifier).pendiente();

      await tester.tap(find.text('Acepto el aviso de privacidad'));
      await _dejarCorrer(tester);

      expect(
        find.text('Sin conexión. Conéctate para guardar tu aceptación.'),
        findsOneWidget,
      );
      expect(
        _contenedor(tester).read(estadoAvisoProvider),
        EstadoAviso.pendiente,
      );

      await tester.tap(find.text('Acepto el aviso de privacidad'));
      await _dejarCorrer(tester);

      expect(repo.aceptados, [3, 3]);
      expect(
        find.text('Sin conexión. Conéctate para guardar tu aceptación.'),
        findsNothing,
      );
      expect(
        _contenedor(tester).read(estadoAvisoProvider),
        EstadoAviso.aceptado,
      );
    });

    _prueba('otro error al aceptar no abre la puerta', (tester) async {
      final repo = RepositorioPrivacidadFalso()
        ..avisos.add(_aviso())
        ..fallosAlAceptar.add(const PrivacidadNoDisponible());
      await tester.pumpWidget(_app(const PantallaAceptarAviso(), repo));
      await _dejarCorrer(tester);
      _contenedor(tester).read(estadoAvisoProvider.notifier).pendiente();

      await tester.tap(find.text('Acepto el aviso de privacidad'));
      await _dejarCorrer(tester);

      expect(
        find.text('No pudimos guardar tu aceptación. Intenta de nuevo.'),
        findsOneWidget,
      );
      expect(
        _contenedor(tester).read(estadoAvisoProvider),
        EstadoAviso.pendiente,
      );
    });

    _prueba('si no carga, ofrece reintentar y cerrar sesion', (tester) async {
      final repo = RepositorioPrivacidadFalso()
        ..avisos.addAll([const PrivacidadSinConexion(), _aviso()]);
      await tester.pumpWidget(_app(const PantallaAceptarAviso(), repo));
      await _dejarCorrer(tester);

      expect(find.byType(EstadoError), findsOneWidget);
      expect(_botonAceptar(tester).alPresionar, isNull);
      expect(find.text('No acepto, cerrar sesión'), findsOneWidget);

      await tester.tap(find.text('Reintentar'));
      await _dejarCorrer(tester);

      expect(find.byType(EstadoError), findsNothing);
      expect(find.text('Primer párrafo del aviso.'), findsOneWidget);
      expect(repo.lecturas, 2);
    });

    _prueba('no aceptar cierra la sesion', (tester) async {
      await _sesion.iniciarSesion(correo: 'a@b.mx', contrasena: 'x');
      final repo = RepositorioPrivacidadFalso()..avisos.add(_aviso());
      await tester.pumpWidget(_app(const PantallaAceptarAviso(), repo));
      await _dejarCorrer(tester);
      expect(_sesion.estado, isA<Autenticada>());

      await tester.tap(find.text('No acepto, cerrar sesión'));
      await _dejarCorrer(tester);

      expect(_sesion.estado, isA<SinSesion>());
      expect(repo.aceptados, isEmpty);
    });

    _prueba('si el aviso ya estaba aceptado, abre la puerta sin pedir nada', (
      tester,
    ) async {
      final repo = RepositorioPrivacidadFalso()
        ..avisos.add(
          _aviso(aceptado: true, aceptadoEn: DateTime.utc(2026, 11, 26)),
        );
      await tester.pumpWidget(_app(const PantallaAceptarAviso(), repo));
      // Como lo deja el verificador: preguntando al servidor.
      _contenedor(tester).read(estadoAvisoProvider.notifier).verificando();
      await _dejarCorrer(tester);

      expect(
        _contenedor(tester).read(estadoAvisoProvider),
        EstadoAviso.aceptado,
      );
      expect(repo.aceptados, isEmpty);
    });

    _prueba('si falta aceptar, la puerta pasa de verificando a pendiente', (
      tester,
    ) async {
      final repo = RepositorioPrivacidadFalso()..avisos.add(_aviso());
      await tester.pumpWidget(_app(const PantallaAceptarAviso(), repo));
      _contenedor(tester).read(estadoAvisoProvider.notifier).verificando();
      await _dejarCorrer(tester);

      expect(
        _contenedor(tester).read(estadoAvisoProvider),
        EstadoAviso.pendiente,
      );
    });

    _prueba('claro, oscuro y letra al 200 % sin desbordes', (tester) async {
      for (final escenario in Escenario.values) {
        final repo = RepositorioPrivacidadFalso()..avisos.add(_aviso());
        await tester.pumpWidget(
          _app(const PantallaAceptarAviso(), repo, escenario: escenario),
        );
        await _dejarCorrer(tester);
        expect(tester.takeException(), isNull, reason: '$escenario');
        expect(find.text('Acepto el aviso de privacidad'), findsOneWidget);
      }
    });

    _prueba('pasa la auditoria de accesibilidad', (tester) async {
      for (final escenario in [Escenario.claro, Escenario.oscuro]) {
        final repo = RepositorioPrivacidadFalso()..avisos.add(_aviso());
        await tester.pumpWidget(
          _app(const PantallaAceptarAviso(), repo, escenario: escenario),
        );
        await _dejarCorrer(tester);
        await auditarAccesibilidad(tester);
      }
    });
  });

  group('PantallaAvisoPrivacidad (V2-M22.01)', () {
    _prueba('muestra el aviso y cuando lo acepto', (tester) async {
      final repo = RepositorioPrivacidadFalso()
        ..avisos.add(
          _aviso(aceptado: true, aceptadoEn: DateTime.utc(2026, 11, 26, 15)),
        );
      await tester.pumpWidget(_app(const PantallaAvisoPrivacidad(), repo));
      await _dejarCorrer(tester);

      expect(find.text('Aviso de privacidad'), findsOneWidget);
      expect(find.text('Versión 2'), findsOneWidget);
      expect(find.text('Primer párrafo del aviso.'), findsOneWidget);
      expect(find.textContaining('Lo aceptaste el'), findsOneWidget);
    });

    _prueba('si todavia no lo acepto, manda a la puerta', (tester) async {
      final repo = RepositorioPrivacidadFalso()..avisos.add(_aviso());
      await tester.pumpWidget(_app(const PantallaAvisoPrivacidad(), repo));
      await _dejarCorrer(tester);

      expect(find.textContaining('Lo aceptaste el'), findsNothing);
      expect(
        _contenedor(tester).read(estadoAvisoProvider),
        EstadoAviso.pendiente,
      );
    });

    _prueba('si ya lo acepto, no cambia el estado de la puerta', (
      tester,
    ) async {
      final repo = RepositorioPrivacidadFalso()
        ..avisos.add(
          _aviso(aceptado: true, aceptadoEn: DateTime.utc(2026, 11, 26)),
        );
      await tester.pumpWidget(_app(const PantallaAvisoPrivacidad(), repo));
      await _dejarCorrer(tester);

      expect(
        _contenedor(tester).read(estadoAvisoProvider),
        EstadoAviso.noRequerido,
      );
    });

    _prueba('sin conexion ofrece reintentar', (tester) async {
      // Al abrir se pide dos veces (al montar y al refrescar): las dos fallan.
      final repo = RepositorioPrivacidadFalso()
        ..avisos.addAll([
          const PrivacidadSinConexion(),
          const PrivacidadSinConexion(),
          _aviso(aceptado: true, aceptadoEn: DateTime.utc(2026, 11, 26)),
        ]);
      await tester.pumpWidget(_app(const PantallaAvisoPrivacidad(), repo));
      await _dejarCorrer(tester);

      expect(find.byType(EstadoError), findsOneWidget);

      await tester.tap(find.text('Reintentar'));
      await _dejarCorrer(tester);

      expect(find.byType(EstadoError), findsNothing);
      expect(find.text('Primer párrafo del aviso.'), findsOneWidget);
    });

    _prueba('mientras carga muestra un esqueleto que el lector anuncia', (
      tester,
    ) async {
      final repo = RepositorioPrivacidadFalso()
        ..avisos.add(
          _aviso(aceptado: true, aceptadoEn: DateTime.utc(2026, 11, 26)),
        )
        ..esperaAlLeer = Completer<void>();
      await tester.pumpWidget(_app(const PantallaAvisoPrivacidad(), repo));
      await tester.pump();

      expect(
        find.bySemanticsLabel('Cargando el aviso de privacidad'),
        findsOneWidget,
      );
      repo.esperaAlLeer!.complete();
      await _dejarCorrer(tester);
    });

    _prueba('claro, oscuro y letra al 200 % sin desbordes y accesible', (
      tester,
    ) async {
      for (final escenario in Escenario.values) {
        final repo = RepositorioPrivacidadFalso()
          ..avisos.add(
            _aviso(aceptado: true, aceptadoEn: DateTime.utc(2026, 11, 26)),
          );
        await tester.pumpWidget(
          _app(const PantallaAvisoPrivacidad(), repo, escenario: escenario),
        );
        await _dejarCorrer(tester);
        expect(tester.takeException(), isNull, reason: '$escenario');
        if (escenario != Escenario.letraGrande) {
          await auditarAccesibilidad(tester);
        }
      }
    });
  });
}
