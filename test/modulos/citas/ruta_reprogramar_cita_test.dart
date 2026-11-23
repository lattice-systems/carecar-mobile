import 'package:carecar_mobile/api/modelos/cita.dart';
import 'package:carecar_mobile/modulos/citas/citas.dart';
import 'package:carecar_mobile/nucleo/navegacion/rutas.dart';
import 'package:carecar_mobile/pantallas/pantalla_login.dart';
import 'package:carecar_mobile/sesion/almacen_sesion.dart';
import 'package:carecar_mobile/sesion/controlador_sesion.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../ayudas/api_falsa.dart';
import '../../ayudas/app_enrutada.dart';

Future<void> _montar(WidgetTester tester, {bool conSesion = true}) async {
  final api = ApiFalsa()
    ..alPedirCitas = () async => [
      Cita(
        id: 1,
        vehiculoId: 1,
        franjaId: 1,
        fecha: DateTime.now().add(const Duration(days: 3)),
        horaInicio: '09:00',
        horaFin: '10:00',
        estado: EstadoCita.confirmada,
      ),
    ];
  final sesion = ControladorSesion(api, AlmacenEnMemoria());
  addTearDown(sesion.dispose);
  if (conSesion) {
    await sesion.iniciarSesion(correo: 'a@b.mx', contrasena: 'CareCar2026');
  }
  await tester.pumpWidget(AppEnrutadaDePrueba(api: api, controlador: sesion));
  await tester.pumpAndSettle();
}

void main() {
  test('la ruta de reprogramar lleva el id de la cita', () {
    expect(rutaReprogramarCita(7), '/citas/7/reprogramar');
  });

  testWidgets('/citas/1/reprogramar con sesion abre la pantalla', (
    tester,
  ) async {
    await _montar(tester);
    enrutadorDe(tester).go(rutaReprogramarCita(1));
    await tester.pumpAndSettle();
    expect(find.byType(PantallaReprogramarCita), findsOneWidget);
    expect(find.text('Reschedule appointment'), findsWidgets);
  });

  testWidgets('un id que no es numero cae en cita no encontrada', (
    tester,
  ) async {
    await _montar(tester);
    enrutadorDe(tester).go('/citas/abc/reprogramar');
    await tester.pumpAndSettle();
    expect(find.text('We could not find this appointment'), findsOneWidget);
  });

  testWidgets('sin sesion manda al acceso', (tester) async {
    await _montar(tester, conSesion: false);
    enrutadorDe(tester).go(rutaReprogramarCita(1));
    await tester.pumpAndSettle();
    expect(find.byType(PantallaLogin), findsOneWidget);
    expect(find.byType(PantallaReprogramarCita), findsNothing);
  });

  testWidgets('desde mis citas, Reprogramar abre la pantalla de esa cita', (
    tester,
  ) async {
    await _montar(tester);
    enrutadorDe(tester).go(rutaMisCitas);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Reschedule'));
    await tester.pumpAndSettle();
    expect(find.byType(PantallaReprogramarCita), findsOneWidget);
    expect(find.textContaining('Your current appointment'), findsOneWidget);
  });
}
