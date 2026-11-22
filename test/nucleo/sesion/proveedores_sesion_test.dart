import 'package:carecar_mobile/nucleo/sesion/proveedores_sesion.dart';
import 'package:carecar_mobile/sesion/almacen_sesion.dart';
import 'package:carecar_mobile/sesion/controlador_sesion.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../ayudas/api_falsa.dart';

void main() {
  late ControladorSesion controlador;
  late ProviderContainer c;

  setUp(() {
    controlador = ControladorSesion(ApiFalsa(), AlmacenEnMemoria());
    c = ProviderContainer(
      overrides: [controladorSesionProvider.overrideWithValue(controlador)],
    );
    addTearDown(c.dispose);
  });

  test('expone el controlador v1 inyectado', () {
    expect(c.read(controladorSesionProvider), same(controlador));
  });

  test('el estado empieza sin sesion y sigue al controlador', () async {
    expect(c.read(estadoSesionProvider), isA<SinSesion>());
    final vistos = <EstadoSesion>[];
    c.listen(estadoSesionProvider, (_, nuevo) => vistos.add(nuevo));

    await controlador.iniciarSesion(correo: 'a@b.mx', contrasena: 'Secreta1!');

    expect(c.read(estadoSesionProvider), isA<Autenticada>());
    expect(vistos.first, isA<Autenticando>());
  });

  test('sin inyectar, falla diciendo como inyectarlo', () {
    final vacio = ProviderContainer();
    addTearDown(vacio.dispose);
    expect(
      () => vacio.read(controladorSesionProvider),
      throwsA(isA<Exception>()),
    );
  });
}
