import 'package:carecar_mobile/nucleo/diseno/tokens/radios.dart';
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
  // El marco limita el contenido a 640 de ancho, así que la lista queda más
  // alta; con pantalla alta todo se construye sin desplazar.
  tester.view.physicalSize = const Size(800, 2400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
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
    expect(find.text('Cambiar una llanta'), findsWidgets);
    expect(find.text('Pasar corriente'), findsWidgets);
    expect(find.text('Qué hacer en un choque'), findsWidgets);
    expect(find.textContaining('sin conexión'), findsWidgets);
  });

  testWidgets('la lista trae titulo grande y la tarjeta de ayuda explicada', (
    tester,
  ) async {
    await _montar(tester);
    enrutadorDe(tester).go(rutaAsistenciaGuias);
    await tester.pumpAndSettle();
    expect(find.text('Emergencias'), findsWidgets);
    expect(find.text('¿Necesitas ayuda ahora?'), findsOneWidget);
    expect(find.textContaining('comparte tu ubicación'), findsOneWidget);
    expect(find.text('Guías'), findsOneWidget);
  });

  testWidgets('la tarjeta de ayuda lleva a las llamadas rapidas', (
    tester,
  ) async {
    await _montar(tester);
    enrutadorDe(tester).go(rutaAsistenciaGuias);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Llamar a la agencia o al 911'));
    await tester.tap(find.text('Llamar a la agencia o al 911'));
    await tester.pumpAndSettle();
    expect(find.byType(PantallaLlamarRapido), findsOneWidget);
  });

  testWidgets('cada guia sale una sola vez, en la lista', (tester) async {
    await _montar(tester);
    enrutadorDe(tester).go(rutaAsistenciaGuias);
    await tester.pumpAndSettle();
    // Antes salian dos veces: como portada de color y como fila de la lista.
    expect(find.text('Cambiar una llanta'), findsOneWidget);
    expect(find.text('Pasar corriente'), findsOneWidget);
    expect(find.text('Qué hacer en un choque'), findsOneWidget);
  });

  testWidgets('la tarjeta de ayuda redondea sus cuatro esquinas', (
    tester,
  ) async {
    await _montar(tester);
    enrutadorDe(tester).go(rutaAsistenciaGuias);
    await tester.pumpAndSettle();
    // Usaba el radio de las hojas, que solo redondea arriba.
    final caja = tester.widget<DecoratedBox>(
      find
          .ancestor(
            of: find.text('¿Necesitas ayuda ahora?'),
            matching: find.byType(DecoratedBox),
          )
          .first,
    );
    expect(
      (caja.decoration as BoxDecoration).borderRadius,
      Radios.bordeTarjeta,
    );
  });

  testWidgets('al tocar una guia de la lista se abre', (tester) async {
    await _montar(tester);
    enrutadorDe(tester).go(rutaAsistenciaGuias);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Pasar corriente'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pasar corriente'));
    await tester.pumpAndSettle();
    expect(find.byType(PantallaGuia), findsOneWidget);
    expect(find.text('Paso 1 de 6'), findsOneWidget);
    expect(find.text('6 pasos · sin conexión'), findsOneWidget);
  });

  testWidgets('al tocar una guia se abren sus pasos numerados', (tester) async {
    await _montar(tester);
    enrutadorDe(tester).go(rutaAsistenciaGuias);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Cambiar una llanta').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cambiar una llanta').last);
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
    enrutadorDe(tester).go(rutaAsistenciaGuias);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    enrutadorDe(tester).go(rutaGuiaDeEmergencia(TipoGuia.corriente));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.byType(Scaffold), findsWidgets);
  });
}
