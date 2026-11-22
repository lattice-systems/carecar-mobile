import 'package:carecar_mobile/api/modelos/disponibilidad.dart';
import 'package:carecar_mobile/modulos/citas/citas.dart';
import 'package:carecar_mobile/nucleo/navegacion/rutas.dart';
import 'package:carecar_mobile/pantallas/pantalla_login.dart';
import 'package:carecar_mobile/sesion/almacen_sesion.dart';
import 'package:carecar_mobile/sesion/controlador_sesion.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../ayudas/api_falsa.dart';
import '../../ayudas/app_enrutada.dart';

Future<void> _montar(WidgetTester tester, {bool conSesion = true}) async {
  final hoy = DateTime.now();
  final manana = DateTime(hoy.year, hoy.month, hoy.day + 1);
  final api = ApiFalsa()
    ..alPedirDisponibilidad = (_, _) async => [
      Disponibilidad(
        fecha: manana,
        franjaId: 1,
        horaInicio: '09:00',
        horaFin: '10:00',
        cupoDisponible: 2,
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
  testWidgets('/citas/disponibilidad con sesion muestra el calendario', (
    tester,
  ) async {
    await _montar(tester);
    enrutadorDe(tester).go(rutaDisponibilidad);
    await tester.pumpAndSettle();
    expect(find.byType(PantallaDisponibilidad), findsOneWidget);
    expect(find.text('Disponibilidad del taller'), findsOneWidget);
  });

  testWidgets('/citas/disponibilidad sin sesion manda al acceso', (
    tester,
  ) async {
    await _montar(tester, conSesion: false);
    enrutadorDe(tester).go(rutaDisponibilidad);
    await tester.pumpAndSettle();
    expect(find.byType(PantallaLogin), findsOneWidget);
    expect(find.byType(PantallaDisponibilidad), findsNothing);
  });

  test('la disponibilidad no es una ruta publica', () {
    expect(Rutas.publicas.contains(rutaDisponibilidad), isFalse);
  });
}
