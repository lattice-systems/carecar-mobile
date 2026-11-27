import 'package:carecar_mobile/nucleo/avisos/explicacion_de_avisos.dart';
import 'package:carecar_mobile/nucleo/idioma/proveedores_idioma.dart';
import 'package:carecar_mobile/nucleo/sesion/proveedores_sesion.dart';
import 'package:carecar_mobile/sesion/almacen_sesion.dart';
import 'package:carecar_mobile/sesion/controlador_sesion.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../ayudas/api_falsa.dart';

/// V2-M06.01 · cuándo toca explicar los avisos.
///
/// La decisión importante está probada aquí y es la que vuelve esta compuerta
/// inofensiva: **sin la clave puesta no falta nada**. Así ninguna prueba del
/// equipo que arranque la app con preferencias vacías se topa con ella.
void main() {
  late ControladorSesion sesion;

  Future<ProviderContainer> contenedor(Map<String, Object> guardado) async {
    SharedPreferences.setMockInitialValues(guardado);
    final prefs = await SharedPreferences.getInstance();
    sesion = ControladorSesion(ApiFalsa(), AlmacenEnMemoria());
    addTearDown(sesion.dispose);
    final c = ProviderContainer(
      overrides: [
        preferenciasProvider.overrideWithValue(prefs),
        controladorSesionProvider.overrideWithValue(sesion),
      ],
    );
    addTearDown(c.dispose);
    return c;
  }

  test('con preferencias vacías no falta explicar nada', () async {
    final c = await contenedor({});
    expect(c.read(avisosPorExplicarProvider), isFalse);
  });

  test('entrar a la cuenta es lo que lo pone pendiente', () async {
    final c = await contenedor({});
    // La compuerta se escucha desde que arranca, como hace el enrutador.
    expect(c.read(avisosPorExplicarProvider), isFalse);

    await sesion.iniciarSesion(
      correo: 'cliente1@example.com',
      contrasena: 'CareCar2026',
    );

    expect(c.read(avisosPorExplicarProvider), isTrue);
  });

  test('quien ya contestó no vuelve a pasar por la explicación', () async {
    final c = await contenedor({claveAvisosRespondido: true});
    expect(c.read(avisosPorExplicarProvider), isFalse);

    await sesion.iniciarSesion(
      correo: 'cliente1@example.com',
      contrasena: 'CareCar2026',
    );

    // El permiso es del teléfono, no de la cuenta: cambiar de cuenta en el
    // mismo equipo no vuelve a explicar.
    expect(c.read(avisosPorExplicarProvider), isFalse);
  });

  test('pendiente de antes, se recuerda al reabrir la app', () async {
    final c = await contenedor({claveAvisosPorExplicar: true});
    expect(c.read(avisosPorExplicarProvider), isTrue);
  });

  test('contestar cierra la compuerta', () async {
    final c = await contenedor({claveAvisosPorExplicar: true});

    c.read(avisosPorExplicarProvider.notifier).listo();

    expect(c.read(avisosPorExplicarProvider), isFalse);
  });
}
