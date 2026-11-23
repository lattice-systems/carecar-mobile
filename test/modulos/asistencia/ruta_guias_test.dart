import 'package:carecar_mobile/modulos/asistencia/asistencia.dart';
import 'package:carecar_mobile/nucleo/navegacion/rutas.dart';
import 'package:carecar_mobile/pantallas/pantalla_login.dart';
import 'package:carecar_mobile/sesion/almacen_sesion.dart';
import 'package:carecar_mobile/sesion/controlador_sesion.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../ayudas/api_falsa.dart';
import '../../ayudas/app_enrutada.dart';

Future<void> _montar(WidgetTester tester, {bool conSesion = true}) async {
  // La plataforma de pruebas habla ingles; los textos que se comprueban son es.
  tester.platformDispatcher.localesTestValue = const [Locale('es')];
  addTearDown(tester.platformDispatcher.clearLocalesTestValue);
  final api = ApiFalsa();
  final sesion = ControladorSesion(api, AlmacenEnMemoria());
  addTearDown(sesion.dispose);
  if (conSesion) {
    await sesion.iniciarSesion(correo: 'a@b.mx', contrasena: 'CareCar2026');
  }
  await tester.pumpWidget(AppEnrutadaDePrueba(api: api, controlador: sesion));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('la lista muestra las tres guias sin pedir nada a la red', (
    tester,
  ) async {
    await _montar(tester);
    enrutadorDe(tester).go(rutaAsistenciaGuias);
    await tester.pumpAndSettle();
    expect(find.byType(PantallaGuias), findsOneWidget);
    expect(find.text('Cambiar una llanta'), findsOneWidget);
    expect(find.text('Pasar corriente'), findsOneWidget);
    expect(find.text('Qué hacer en un choque'), findsOneWidget);
    expect(find.textContaining('sin conexión'), findsWidgets);
  });

  testWidgets('al tocar una guia se abren sus pasos numerados', (tester) async {
    await _montar(tester);
    enrutadorDe(tester).go(rutaAsistenciaGuias);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cambiar una llanta'));
    await tester.pumpAndSettle();
    expect(find.byType(PantallaGuia), findsOneWidget);
    expect(find.text('Paso 1 de 5'), findsOneWidget);
  });

  testWidgets('cada paso es un nodo propio y se lee en orden', (tester) async {
    final semantica = tester.ensureSemantics();
    await _montar(tester);
    enrutadorDe(tester).go(rutaGuiaDeEmergencia(TipoGuia.choque));
    await tester.pumpAndSettle();
    final total = guiasDeEmergencia
        .firstWhere((g) => g.tipo == TipoGuia.choque)
        .pasos;
    for (var i = 1; i <= total; i++) {
      expect(find.text('Paso $i de $total'), findsOneWidget);
    }
    final y = [
      for (var i = 1; i <= total; i++)
        tester.getTopLeft(find.text('Paso $i de $total')).dy,
    ];
    expect([...y]..sort(), y);
    semantica.dispose();
  });

  testWidgets('una guia que no existe vuelve a la lista', (tester) async {
    await _montar(tester);
    enrutadorDe(tester).go('$rutaAsistenciaGuias/no-existe');
    await tester.pumpAndSettle();
    expect(find.byType(PantallaGuias), findsOneWidget);
  });

  testWidgets('sin sesion manda al acceso', (tester) async {
    await _montar(tester, conSesion: false);
    enrutadorDe(tester).go(rutaAsistenciaGuias);
    await tester.pumpAndSettle();
    expect(find.byType(PantallaLogin), findsOneWidget);
  });

  test('las guias no son una ruta publica', () {
    expect(Rutas.publicas.contains(rutaAsistenciaGuias), isFalse);
  });

  testWidgets('con letra al 200 % no hay desbordes', (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await _montar(tester);
    enrutadorDe(tester).go(rutaGuiaDeEmergencia(TipoGuia.corriente));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.byType(Scaffold), findsWidgets);
  });
}
