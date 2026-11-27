import 'package:carecar_mobile/modulos/citas/citas.dart';
import 'package:carecar_mobile/nucleo/navegacion/rutas.dart';
import 'package:carecar_mobile/sesion/almacen_sesion.dart';
import 'package:carecar_mobile/sesion/controlador_sesion.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../ayudas/api_falsa.dart';
import '../../ayudas/app_enrutada.dart';

Future<void> _montar(WidgetTester tester, {bool conSesion = true}) async {
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
  testWidgets('/citas/agendar con sesion abre el flujo de agendar', (
    tester,
  ) async {
    await _montar(tester);
    enrutadorDe(tester).go(rutaAgendarCita);
    await tester.pumpAndSettle();
    expect(find.byType(PantallaAgendarCita), findsOneWidget);
  });

  testWidgets('/citas/agendar sin sesion manda al acceso', (tester) async {
    await _montar(tester, conSesion: false);
    enrutadorDe(tester).go(rutaAgendarCita);
    await tester.pumpAndSettle();
    expect(pantallaDeAcceso, findsOneWidget);
    expect(find.byType(PantallaAgendarCita), findsNothing);
  });

  test('agendar no es una ruta publica', () {
    expect(Rutas.publicas.contains(rutaAgendarCita), isFalse);
  });

  testWidgets('la ruta con vehiculo y motivo los pasa a la pantalla', (
    tester,
  ) async {
    await _montar(tester);
    enrutadorDe(tester)
        .go(rutaAgendarCitaCon(vehiculoId: 2, motivo: MotivoCita.revision));
    await tester.pumpAndSettle();
    final pantalla = tester.widget<PantallaAgendarCita>(
      find.byType(PantallaAgendarCita),
    );
    expect(pantalla.vehiculoInicial, 2);
    expect(pantalla.motivoInicial, MotivoCita.revision);
  });

  test('la ruta precargada lleva vehiculo y motivo en la consulta', () {
    expect(
      rutaAgendarCitaCon(vehiculoId: 2, motivo: MotivoCita.revision),
      '/citas/agendar?vehiculo=2&motivo=revision',
    );
  });

  testWidgets('datos raros en la consulta se ignoran', (tester) async {
    await _montar(tester);
    enrutadorDe(tester).go('$rutaAgendarCita?vehiculo=x&motivo=nada');
    await tester.pumpAndSettle();
    final pantalla = tester.widget<PantallaAgendarCita>(
      find.byType(PantallaAgendarCita),
    );
    expect(pantalla.vehiculoInicial, isNull);
    expect(pantalla.motivoInicial, isNull);
  });
}
