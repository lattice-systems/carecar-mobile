import 'dart:async';

import 'package:carecar_mobile/nucleo/seguridad/detector_integridad.dart';
import 'package:carecar_mobile/nucleo/seguridad/politica_datos_locales.dart';
import 'package:flutter_test/flutter_test.dart';

class _Colgado implements DetectorIntegridad {
  @override
  Future<bool> estaComprometido() => Completer<bool>().future;
}

void main() {
  group('evaluarIntegridad', () {
    test('equipo con root o jailbreak es comprometido', () async {
      expect(
        await evaluarIntegridad(
          const DetectorIntegridadFalso(comprometido: true),
        ),
        EstadoIntegridad.comprometido,
      );
    });

    test('equipo limpio es integro', () async {
      expect(
        await evaluarIntegridad(const DetectorIntegridadFalso()),
        EstadoIntegridad.integro,
      );
    });

    test('si la deteccion lanza, no rompe y queda desconocido', () async {
      expect(
        await evaluarIntegridad(
          DetectorIntegridadFalso(error: StateError('plugin ausente')),
        ),
        EstadoIntegridad.desconocido,
      );
    });

    test('si la deteccion se cuelga, vence el limite y queda desconocido', () {
      expect(
        evaluarIntegridad(_Colgado(), limite: const Duration(milliseconds: 20)),
        completion(EstadoIntegridad.desconocido),
      );
    });
  });

  group('PoliticaDatosLocales', () {
    test('permite el cache salvo en equipo comprometido', () {
      final p = PoliticaDatosLocales();
      expect(p.permiteCacheLocal, isTrue);
      p.actualizar(EstadoIntegridad.integro);
      expect(p.permiteCacheLocal, isTrue);
      p.actualizar(EstadoIntegridad.comprometido);
      expect(p.permiteCacheLocal, isFalse);
      expect(p.equipoComprometido, isTrue);
    });

    test('avisa a quien escucha solo cuando cambia', () {
      final p = PoliticaDatosLocales();
      var avisos = 0;
      p.addListener(() => avisos++);
      p.actualizar(EstadoIntegridad.comprometido);
      p.actualizar(EstadoIntegridad.comprometido);
      expect(avisos, 1);
    });
  });
}
