import 'package:carecar_mobile/modulos/recoleccion/datos/repositorio_recoleccion_fake.dart';
import 'package:carecar_mobile/modulos/recoleccion/recoleccion.dart';
import 'package:carecar_mobile/nucleo/navegacion/rutas.dart';
import 'package:carecar_mobile/pantallas/pantalla_login.dart';
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
        repositorioRecoleccionProvider.overrideWithValue(
          RepositorioRecoleccionFake(),
        ),
      ],
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('/recoleccion/direcciones con sesion abre mis direcciones', (
    tester,
  ) async {
    await _montar(tester);
    enrutadorDe(tester).go(rutaMisDirecciones);
    await tester.pumpAndSettle();
    expect(find.byType(PantallaMisDirecciones), findsOneWidget);
    expect(find.text('You have no addresses yet'), findsOneWidget);
  });

  testWidgets('sin sesion manda al acceso', (tester) async {
    await _montar(tester, conSesion: false);
    enrutadorDe(tester).go(rutaMisDirecciones);
    await tester.pumpAndSettle();
    expect(find.byType(PantallaLogin), findsOneWidget);
    expect(find.byType(PantallaMisDirecciones), findsNothing);
  });

  test('mis direcciones no es una ruta publica', () {
    expect(Rutas.publicas.contains(rutaMisDirecciones), isFalse);
  });
}
