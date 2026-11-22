import 'package:carecar_mobile/api/modelos/modelo_catalogo.dart';
import 'package:carecar_mobile/modulos/catalogo/catalogo.dart';
import 'package:carecar_mobile/nucleo/navegacion/rutas.dart';
import 'package:carecar_mobile/pantallas/pantalla_login.dart';
import 'package:carecar_mobile/sesion/almacen_sesion.dart';
import 'package:carecar_mobile/sesion/controlador_sesion.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../ayudas/api_falsa.dart';
import '../../ayudas/app_enrutada.dart';

Future<ApiFalsa> _montar(WidgetTester tester, {bool conSesion = true}) async {
  final api = ApiFalsa()
    ..modelosCatalogo = const [
      ModeloCatalogo(
        id: 1,
        modelo: 'CX-5',
        marca: 'Mazda',
        anio: 2024,
        precioDesde: 450000,
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
  testWidgets('/catalogo con sesion muestra el catalogo de la API', (
    tester,
  ) async {
    await _montar(tester);
    enrutadorDe(tester).go(rutaCatalogo);
    await tester.pumpAndSettle();
    expect(find.byType(PantallaCatalogo), findsOneWidget);
    expect(find.text('Mazda CX-5 2024'), findsOneWidget);
  });

  testWidgets('/catalogo sin sesion manda al acceso', (tester) async {
    await _montar(tester, conSesion: false);
    enrutadorDe(tester).go(rutaCatalogo);
    await tester.pumpAndSettle();
    expect(find.byType(PantallaLogin), findsOneWidget);
    expect(find.byType(PantallaCatalogo), findsNothing);
  });

  test('el catalogo no es una ruta publica', () {
    expect(Rutas.publicas.contains(rutaCatalogo), isFalse);
  });
}
