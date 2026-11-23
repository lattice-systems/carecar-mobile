import 'package:carecar_mobile/modulos/citas/citas.dart';
import 'package:carecar_mobile/nucleo/navegacion/rutas.dart';
import 'package:carecar_mobile/pantallas/pantalla_login.dart';
import 'package:carecar_mobile/sesion/almacen_sesion.dart';
import 'package:carecar_mobile/sesion/controlador_sesion.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../ayudas/api_falsa.dart';
import '../../ayudas/app_enrutada.dart';

Future<ApiFalsa> _montar(WidgetTester tester, {bool conSesion = true}) async {
  final api = ApiFalsa();
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
  test('el camino lleva el id de la cita', () {
    expect(rutaComprobanteCita(7), '/citas/7/comprobante');
  });

  testWidgets('/citas/7/comprobante con sesion pide el comprobante 7', (
    tester,
  ) async {
    final api = await _montar(tester);
    enrutadorDe(tester).go(rutaComprobanteCita(7));
    await tester.pumpAndSettle();
    expect(find.byType(PantallaComprobanteCita), findsOneWidget);
    expect(find.byType(QrImageView), findsOneWidget);
    expect(api.comprobantesDeCitaPedidos, [7]);
  });

  testWidgets('/citas/7/comprobante sin sesion manda al acceso', (
    tester,
  ) async {
    await _montar(tester, conSesion: false);
    enrutadorDe(tester).go(rutaComprobanteCita(7));
    await tester.pumpAndSettle();
    expect(find.byType(PantallaLogin), findsOneWidget);
    expect(find.byType(PantallaComprobanteCita), findsNothing);
  });

  testWidgets('un id que no es numero no abre el comprobante', (tester) async {
    await _montar(tester);
    enrutadorDe(tester).go('/citas/abc/comprobante');
    await tester.pumpAndSettle();
    expect(find.byType(PantallaComprobanteCita), findsNothing);
  });

  test('el comprobante no es una ruta publica', () {
    expect(Rutas.publicas.contains(rutaComprobanteCita(7)), isFalse);
  });
}
