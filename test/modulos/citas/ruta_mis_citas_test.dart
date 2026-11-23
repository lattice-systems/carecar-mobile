import 'package:carecar_mobile/api/modelos/cita.dart';
import 'package:carecar_mobile/modulos/citas/citas.dart';
import 'package:carecar_mobile/nucleo/navegacion/rutas.dart';
import 'package:carecar_mobile/pantallas/pantalla_login.dart';
import 'package:carecar_mobile/sesion/almacen_sesion.dart';
import 'package:carecar_mobile/sesion/controlador_sesion.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../ayudas/api_falsa.dart';
import '../../ayudas/app_enrutada.dart';

Future<ApiFalsa> _montar(WidgetTester tester, {bool conSesion = true}) async {
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
  return api;
}

void main() {
  testWidgets('/citas con sesion abre mis citas con las del servidor', (
    tester,
  ) async {
    await _montar(tester);
    enrutadorDe(tester).go(rutaMisCitas);
    await tester.pumpAndSettle();
    expect(find.byType(PantallaMisCitas), findsOneWidget);
    expect(find.text('Confirmed'), findsOneWidget);
  });

  testWidgets('/citas sin sesion manda al acceso', (tester) async {
    await _montar(tester, conSesion: false);
    enrutadorDe(tester).go(rutaMisCitas);
    await tester.pumpAndSettle();
    expect(find.byType(PantallaLogin), findsOneWidget);
    expect(find.byType(PantallaMisCitas), findsNothing);
  });

  test('mis citas no es una ruta publica', () {
    expect(Rutas.publicas.contains(rutaMisCitas), isFalse);
  });
}
