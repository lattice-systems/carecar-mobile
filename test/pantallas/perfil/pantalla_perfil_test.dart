// Portado de feat/app-perfil (07a2b5c), adaptado a miPerfil() y PantallaAjustes.
import '../../ayudas/envolver_con_shad.dart';

import 'package:carecar_mobile/api/excepciones.dart';
import 'package:carecar_mobile/api/modelos/modelos.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/avatar.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/boton_regresar.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/control_binario.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/grupo_lista.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/marco_pantalla.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/tarjeta_resumen.dart';
import 'package:carecar_mobile/pantallas/pantalla_ajustes.dart';
import 'package:carecar_mobile/pantallas/pantalla_inicio.dart';
import 'package:carecar_mobile/pantallas/perfil/pantalla_perfil.dart';
import 'package:carecar_mobile/tema/tema_carecar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../ayudas/api_falsa.dart';

Future<void> _montar(
  WidgetTester tester,
  ApiFalsa api, {
  VoidCallback? alCerrarSesion,
  Brightness brillo = Brightness.light,
  double letra = 1,
}) async {
  // La lista es larga y se construye perezosamente: pantalla alta.
  tester.view.physicalSize = const Size(400, 3200);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  tester.platformDispatcher.platformBrightnessTestValue = brillo;
  tester.platformDispatcher.textScaleFactorTestValue = letra;
  addTearDown(tester.platformDispatcher.clearAllTestValues);
  await tester.pumpWidget(
    MaterialAppConShad(
      theme: TemaCareCar.claro,
      home: PantallaAjustes(api: api, alCerrarSesion: alCerrarSesion ?? () {}),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  // V2-T02.24: Ajustes en el lenguaje del resto de la app. Antes traía una
  // cabecera héroe de degradado, etiquetas en MAYÚSCULAS y acentos
  // verdeazulados de la v1.
  group('Ajustes en el lenguaje v2', () {
    testWidgets('abre con el marco del sistema: título grande y regreso', (
      tester,
    ) async {
      await _montar(tester, ApiFalsa());

      expect(find.byType(MarcoPantalla), findsOneWidget);
      expect(find.byType(BotonRegresar), findsOneWidget);
      expect(find.text('Ajustes'), findsWidgets);
      // Sin la cabecera héroe ni su rótulo.
      expect(find.text('MI PERFIL'), findsNothing);
    });

    testWidgets('los grupos llevan su título en minúsculas, no en MAYÚSCULAS', (
      tester,
    ) async {
      await _montar(tester, ApiFalsa());

      for (final grupo in ['Cuenta', 'Notificaciones', 'Ayuda', 'Acerca de']) {
        expect(find.text(grupo), findsOneWidget, reason: grupo);
        expect(find.text(grupo.toUpperCase()), findsNothing, reason: grupo);
      }
      expect(find.byType(GrupoLista), findsNWidgets(5));
    });

    testWidgets(
      'el perfil es una tarjeta de resumen con el avatar del sistema',
      (tester) async {
        await _montar(tester, ApiFalsa());

        expect(find.byType(TarjetaResumen), findsOneWidget);
        expect(find.byType(Avatar), findsOneWidget);
      },
    );

    testWidgets('cerrar sesión está una sola vez (antes también arriba)', (
      tester,
    ) async {
      await _montar(tester, ApiFalsa());

      expect(find.byKey(PantallaInicio.botonCerrarSesion), findsOneWidget);
    });

    testWidgets('tocar la fila de recordatorios cambia el interruptor', (
      tester,
    ) async {
      await _montar(tester, ApiFalsa());
      final fila = find.byKey(PantallaPerfil.interruptorRecordatorios);
      final interruptor = find.descendant(
        of: fila,
        matching: find.byType(Switch),
      );
      bool valor() => tester.widget<Switch>(interruptor).value;

      final antes = valor();
      await tester.tap(fila);
      await tester.pumpAndSettle();

      expect(valor(), !antes);
      expect(
        find.descendant(of: fila, matching: find.byType(ControlInterruptor)),
        findsOneWidget,
      );
    });

    for (final (nombre, brillo, letra) in [
      ('oscuro', Brightness.dark, 1.0),
      ('letra al 200 %', Brightness.light, 2.0),
    ]) {
      testWidgets('se ve sin desbordes en $nombre', (tester) async {
        await _montar(tester, ApiFalsa(), brillo: brillo, letra: letra);

        expect(find.text('María Robles'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  });

  testWidgets('Ajustes ofrece elegir el idioma de la app', (tester) async {
    await _montar(tester, ApiFalsa());

    expect(find.text('Idioma'), findsOneWidget);
    expect(find.text('Automático (idioma del sistema)'), findsOneWidget);
  });

  testWidgets('muestra el nombre, las iniciales y el correo', (tester) async {
    final api = ApiFalsa();
    await _montar(tester, api);

    expect(find.text('María Robles'), findsOneWidget);
    expect(find.text('MR'), findsOneWidget);
    expect(find.text('cliente1@example.com'), findsWidgets);
    expect(api.llamadasAPerfil, 1);
  });

  testWidgets('si falla muestra el error y reintenta', (tester) async {
    var intentos = 0;
    final api = ApiFalsa()
      ..alPedirPerfil = () async {
        intentos++;
        if (intentos == 1) throw const SinConexion();
        return Perfil(
          id: 1,
          nombre: 'María Robles',
          correo: 'cliente1@example.com',
          clienteDesde: DateTime(2024, 3),
        );
      };
    await _montar(tester, api);

    expect(find.text('Sin conexión'), findsOneWidget);
    await tester.tap(find.byKey(PantallaPerfil.botonReintentar));
    await tester.pumpAndSettle();

    expect(intentos, 2);
    expect(find.text('María Robles'), findsOneWidget);
  });

  testWidgets('cerrar sesion pide confirmacion', (tester) async {
    var cierres = 0;
    await _montar(tester, ApiFalsa(), alCerrarSesion: () => cierres++);
    final boton = find.byKey(PantallaInicio.botonCerrarSesion);

    await tester.ensureVisible(boton);
    await tester.pumpAndSettle();
    await tester.tap(boton);
    await tester.pumpAndSettle();
    expect(find.text('¿Cerrar sesión?'), findsOneWidget);

    await tester.tap(find.byKey(PantallaPerfil.botonCancelarCierre));
    await tester.pumpAndSettle();
    expect(cierres, 0);

    await tester.tap(boton);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(PantallaPerfil.botonConfirmarCierre));
    await tester.pumpAndSettle();
    expect(cierres, 1);
  });
}
