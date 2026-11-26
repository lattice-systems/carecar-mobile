import 'package:carecar_mobile/config/flavor.dart';
import 'package:carecar_mobile/main.dart';
import 'package:carecar_mobile/modulos/citas/presentacion/pantalla_mis_citas.dart';
import 'package:carecar_mobile/modulos/vehiculos/presentacion/pantalla_garaje.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/barra_flotante.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/boton_circular.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/boton_pildora.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/calendario.dart';
import 'package:carecar_mobile/pantallas/pantalla_login.dart';
import 'package:carecar_mobile/sesion/almacen_seguro.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:lucide_icons_flutter/lucide_icons_300.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'V2-T03.03: inicia sesión, abre el garaje, agenda y conserva la cancelación',
    (tester) async {
      const url = String.fromEnvironment(
        'API_BASE_URL',
        defaultValue: 'http://10.0.2.2:3000/api/v1/app',
      );
      expect(
        Uri.parse(url).host,
        anyOf('10.0.2.2', '127.0.0.1'),
        reason: 'Este flujo crea citas de prueba y requiere el mock local.',
      );

      tester.binding.platformDispatcher.localesTestValue = const [
        Locale('es', 'MX'),
      ];
      addTearDown(tester.binding.platformDispatcher.clearLocalesTestValue);
      final almacen = AlmacenSeguro.delSistema();
      await almacen.borrar();
      addTearDown(almacen.borrar);
      await arrancar(Flavor.desarrollo);

      final correo = find.byKey(PantallaLogin.campoCorreo);
      await _esperar(tester, correo);
      await tester.enterText(correo, 'cliente1@example.com');
      await tester.enterText(
        find.byKey(PantallaLogin.campoContrasena),
        'CareCar2026',
      );
      await _tocar(tester, find.byKey(PantallaLogin.botonEntrar));

      await _tocar(
        tester,
        find.byWidgetPredicate(
          (w) =>
              w is BotonPildora &&
              w.texto == 'Acepto el aviso de privacidad' &&
              w.alPresionar != null,
        ),
      );
      final barra = find.byType(BarraFlotante);
      final citas = find.descendant(
        of: barra,
        matching: find.byIcon(LucideIcons300.calendarDays),
      );
      await _tocar(
        tester,
        find.descendant(of: barra, matching: find.byIcon(LucideIcons300.car)),
      );
      await _esperar(tester, find.byType(PantallaGaraje));
      final vehiculo = find.text('Nissan March Sense 2020');
      await _esperar(tester, vehiculo, coincidencias: findsWidgets);
      await _tocar(tester, find.byTooltip('Regresar'));
      await _tocar(tester, citas);
      await _esperar(tester, find.byType(PantallaMisCitas));
      await _tocar(
        tester,
        find.byWidgetPredicate(
          (w) =>
              (w is BotonPildora && w.texto == 'Agendar cita') ||
              (w is BotonCircular && w.etiqueta == 'Agendar cita'),
        ),
      );
      await _tocar(tester, vehiculo);

      final hoy = DateTime.now();
      final manana = DateTime(hoy.year, hoy.month, hoy.day + 1);
      if (manana.month != hoy.month) {
        await _tocar(tester, find.byTooltip('Mes siguiente'));
      }
      await _tocar(
        tester,
        find.descendant(
          of: find.byType(Calendario),
          matching: find.text('${manana.day}'),
        ),
      );
      await _tocar(tester, find.text('09:00 · 2 lugares'));
      await _tocar(tester, find.text('Mantenimiento'));
      await _tocar(tester, find.text('Revisar y confirmar'));
      await _tocar(tester, find.text('Confirmar cita'));
      await _esperar(tester, find.text('Cita confirmada'));
      await _tocar(tester, find.text('Listo'));

      await _tocar(tester, find.text('Cancelar cita'));
      await _tocar(tester, find.text('Sí, cancelar'));
      await _esperar(
        tester,
        find.text('Cita cancelada. El horario quedó libre.'),
      );
      await _tocar(tester, find.byTooltip('Regresar'));
      await _tocar(tester, citas);
      await _esperar(
        tester,
        find.text('Cancelada'),
        coincidencias: findsWidgets,
      );
      expect(find.text('Cancelar cita'), findsNothing);
    },
  );
}

Future<void> _esperar(
  WidgetTester tester,
  Finder control, {
  Matcher coincidencias = findsOneWidget,
}) async {
  final reloj = Stopwatch()..start();
  while (control.evaluate().isEmpty &&
      reloj.elapsed < const Duration(seconds: 20)) {
    await tester.pump(const Duration(milliseconds: 100));
  }
  expect(control, coincidencias);
}

Future<void> _tocar(WidgetTester tester, Finder control) async {
  await _esperar(tester, control);
  await tester.ensureVisible(control);
  await tester.pump();
  await tester.tap(control);
  await tester.pump();
}
