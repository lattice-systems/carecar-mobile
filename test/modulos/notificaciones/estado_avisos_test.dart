import 'package:carecar_mobile/modulos/notificaciones/notificaciones.dart';
import 'package:carecar_mobile/nucleo/avisos/explicacion_de_avisos.dart';
import 'package:carecar_mobile/nucleo/idioma/proveedores_idioma.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../ayudas/avisos_del_sistema_falso.dart';

/// V2-M06.01 · el permiso de avisos, explicado antes de pedirlo.
///
/// Lo que se decide aqui: que **nunca se pida sin explicar**, que **negarlo no
/// rompa nada** y que despues se pueda **reactivar desde Ajustes**.
void main() {
  late AvisosDelSistemaFalso sistema;

  Future<ProviderContainer> contenedor(Map<String, Object> guardado) async {
    SharedPreferences.setMockInitialValues(guardado);
    final prefs = await SharedPreferences.getInstance();
    sistema = AvisosDelSistemaFalso();
    final c = ProviderContainer(
      overrides: [
        preferenciasProvider.overrideWithValue(prefs),
        avisosDelSistemaProvider.overrideWithValue(sistema),
      ],
    );
    addTearDown(c.dispose);
    return c;
  }

  group('el permiso de avisos', () {
    test('nace sin preguntar: a nadie se le ha explicado', () async {
      final c = await contenedor({});
      expect(c.read(permisoDeAvisosProvider), EstadoAvisos.sinPreguntar);
      // Lo que importa del criterio: la app no toco el sistema sola.
      expect(sistema.vecesQueSePidio, 0);
    });

    test('aceptar en la pantalla previa si pide el permiso', () async {
      final c = await contenedor({});

      final concedido = await c.read(permisoDeAvisosProvider.notifier).pedir();

      expect(concedido, isTrue);
      expect(sistema.vecesQueSePidio, 1);
      expect(c.read(permisoDeAvisosProvider), EstadoAvisos.permitidos);
    });

    test('si el sistema lo niega queda negado, y la app sigue', () async {
      final c = await contenedor({});
      sistema.concede = false;

      final concedido = await c.read(permisoDeAvisosProvider.notifier).pedir();

      expect(concedido, isFalse);
      expect(c.read(permisoDeAvisosProvider), EstadoAvisos.negados);
    });

    test('«ahora no» queda negado sin molestar al sistema', () async {
      final c = await contenedor({});

      await c.read(permisoDeAvisosProvider.notifier).ahoraNo();

      expect(c.read(permisoDeAvisosProvider), EstadoAvisos.negados);
      expect(sistema.vecesQueSePidio, 0);
    });

    test('lo respondido se recuerda al volver a abrir la app', () async {
      final c = await contenedor({
        claveAvisosRespondido: true,
        claveAvisosPermitidos: true,
      });
      expect(c.read(permisoDeAvisosProvider), EstadoAvisos.permitidos);
    });

    test('Ajustes puede mandar a la pantalla del sistema', () async {
      final c = await contenedor({
        claveAvisosRespondido: true,
        claveAvisosPermitidos: false,
      });

      await c.read(permisoDeAvisosProvider.notifier).abrirAjustes();

      expect(sistema.vecesQueSeAbrieronAjustes, 1);
    });
  });
}
