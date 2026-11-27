import 'package:carecar_mobile/modulos/historial/datos/repositorio_historial_fake.dart';
import 'package:carecar_mobile/modulos/historial/historial.dart';
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
  await tester.pumpWidget(
    AppEnrutadaDePrueba(
      api: api,
      controlador: sesion,
      overrides: [
        repositorioHistorialProvider.overrideWithValue(
          RepositorioHistorialFake(),
        ),
      ],
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('/historial/:vehiculoId abre el historial del vehiculo', (
    tester,
  ) async {
    await _montar(tester);
    enrutadorDe(tester).go(rutaHistorialVehiculo(1));
    await tester.pumpAndSettle();
    expect(find.byType(PantallaHistorial), findsOneWidget);
  });

  testWidgets('tocar una orden abre su ticket', (tester) async {
    await _montar(tester);
    enrutadorDe(tester).go(rutaHistorialVehiculo(1));
    await tester.pumpAndSettle();

    await tester.tap(find.text(r'$1,282.00'));
    await tester.pumpAndSettle();

    expect(find.byType(PantallaTicket), findsOneWidget);
  });

  testWidgets('el ticket tambien llega por enlace', (tester) async {
    await _montar(tester);
    enrutadorDe(tester).go(rutaTicketServicio(1, 21));
    await tester.pumpAndSettle();
    expect(find.byType(PantallaTicket), findsOneWidget);
  });

  testWidgets('sin sesion manda al inicio de sesion', (tester) async {
    await _montar(tester, conSesion: false);
    enrutadorDe(tester).go(rutaHistorialVehiculo(1));
    await tester.pumpAndSettle();
    expect(pantallaDeAcceso, findsOneWidget);
  });
}
