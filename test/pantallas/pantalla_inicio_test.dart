import 'package:carecar_mobile/pantallas/pantalla_inicio.dart';
import 'package:carecar_mobile/sesion/almacen_sesion.dart';
import 'package:carecar_mobile/sesion/controlador_sesion.dart';
import 'package:carecar_mobile/tema/tema_carecar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../ayudas/api_falsa.dart';

Future<ControladorSesion> _sesionIniciada({bool temporal = false}) async {
  final controlador = ControladorSesion(
    temporal ? ApiFalsa.conContrasenaTemporal() : ApiFalsa(),
    AlmacenEnMemoria(),
  );
  await controlador.iniciarSesion(usuario: 'cliente1', contrasena: 'x');
  return controlador;
}

Future<void> _montar(
  WidgetTester tester,
  ControladorSesion controlador, {
  VoidCallback? alCerrarSesion,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: TemaCareCar.claro,
      home: PantallaInicio(
        controlador: controlador,
        alCerrarSesion: alCerrarSesion ?? () {},
      ),
    ),
  );
}

void main() {
  testWidgets('confirma que la sesion quedo iniciada', (tester) async {
    await _montar(tester, await _sesionIniciada());

    expect(find.text('Sesión iniciada'), findsOneWidget);
  });

  testWidgets('cerrar sesion borra el token y avisa', (tester) async {
    var avisos = 0;
    final controlador = await _sesionIniciada();
    await _montar(tester, controlador, alCerrarSesion: () => avisos++);

    await tester.tap(find.byKey(PantallaInicio.botonCerrarSesion));
    await tester.pumpAndSettle();

    expect(controlador.haySesion, isFalse);
    expect(avisos, 1);
  });

  testWidgets('con contrasena temporal avisa que hay que cambiarla', (
    tester,
  ) async {
    await _montar(tester, await _sesionIniciada(temporal: true));

    expect(find.textContaining('temporal'), findsOneWidget);
  });

  testWidgets('con contrasena definitiva no muestra ese aviso', (tester) async {
    await _montar(tester, await _sesionIniciada());

    expect(find.textContaining('temporal'), findsNothing);
  });
}
