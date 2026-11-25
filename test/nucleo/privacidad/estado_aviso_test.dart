import 'package:carecar_mobile/nucleo/privacidad/estado_aviso.dart';
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
    addTearDown(controlador.dispose);
    c = ProviderContainer(
      overrides: [controladorSesionProvider.overrideWithValue(controlador)],
    );
    addTearDown(c.dispose);
  });

  group('EstadoAviso (V2-M22.01)', () {
    test('solo bloquea mientras se verifica o falta aceptar', () {
      expect({
        for (final e in EstadoAviso.values) e: e.porAceptar,
      }, {
        EstadoAviso.noRequerido: false,
        EstadoAviso.verificando: true,
        EstadoAviso.pendiente: true,
        EstadoAviso.aceptado: false,
      });
    });
  });

  group('estadoAvisoProvider', () {
    test('arranca sin requerir nada: sin verificador no se bloquea a nadie', () {
      expect(c.read(estadoAvisoProvider), EstadoAviso.noRequerido);
    });

    test('cada paso del verificador queda en el estado', () {
      final notificador = c.read(estadoAvisoProvider.notifier);

      notificador.verificando();
      expect(c.read(estadoAvisoProvider), EstadoAviso.verificando);
      notificador.pendiente();
      expect(c.read(estadoAvisoProvider), EstadoAviso.pendiente);
      notificador.aceptado();
      expect(c.read(estadoAvisoProvider), EstadoAviso.aceptado);
      notificador.noRequerido();
      expect(c.read(estadoAvisoProvider), EstadoAviso.noRequerido);
    });

    test('al cerrar la sesion se olvida lo de la cuenta anterior', () async {
      await controlador.iniciarSesion(correo: 'a@b.mx', contrasena: 'x');
      c.read(estadoAvisoProvider);
      c.read(estadoAvisoProvider.notifier).aceptado();
      expect(c.read(estadoAvisoProvider), EstadoAviso.aceptado);

      await controlador.cerrarSesion();

      expect(c.read(estadoAvisoProvider), EstadoAviso.noRequerido);
    });
  });
}
