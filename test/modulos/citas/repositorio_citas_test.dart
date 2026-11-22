import 'package:carecar_mobile/api/excepciones.dart';
import 'package:carecar_mobile/api/modelos/disponibilidad.dart';
import 'package:carecar_mobile/modulos/citas/datos/repositorio_citas_api.dart';
import 'package:carecar_mobile/modulos/citas/datos/repositorio_citas_fake.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../ayudas/api_falsa.dart';

void main() {
  final desde = DateTime(2026, 11, 23);
  final hasta = DateTime(2026, 12, 23);

  group('RepositorioCitasApi', () {
    test('pide el rango a la API y traduce las franjas', () async {
      final api = ApiFalsa()
        ..alPedirDisponibilidad = (d, h) async {
          expect(d, desde);
          expect(h, hasta);
          return [
            Disponibilidad(
              fecha: DateTime(2026, 11, 24),
              franjaId: 5,
              horaInicio: '09:00',
              horaFin: '10:00',
              cupoDisponible: 2,
            ),
          ];
        };
      final taller = await RepositorioCitasApi(
        api,
      ).disponibilidad(desde: desde, hasta: hasta);
      expect(taller.tieneCupo(DateTime(2026, 11, 24)), isTrue);
      final franja = taller.franjasDe(DateTime(2026, 11, 24)).single;
      expect(franja.franjaId, 5);
      expect(franja.cupo, 2);
      expect(franja.horaInicio, '09:00');
    });

    test('deja pasar SinConexion para que la pantalla lo explique', () {
      final api = ApiFalsa()
        ..alPedirDisponibilidad = (_, _) async => throw const SinConexion();
      expect(
        RepositorioCitasApi(api).disponibilidad(desde: desde, hasta: hasta),
        throwsA(isA<SinConexion>()),
      );
    });
  });

  group('RepositorioCitasFake', () {
    test('devuelve sus franjas de ejemplo', () async {
      final taller = await RepositorioCitasFake().disponibilidad(
        desde: desde,
        hasta: hasta,
      );
      expect(taller.sinCupoEnTodoElRango, isFalse);
    });

    test('puede fallar a pedido', () {
      final repo = RepositorioCitasFake(error: const SinConexion());
      expect(
        repo.disponibilidad(desde: desde, hasta: hasta),
        throwsA(isA<SinConexion>()),
      );
    });

    test('solo entrega lo que cae dentro del rango pedido', () async {
      final taller = await RepositorioCitasFake().disponibilidad(
        desde: desde,
        hasta: desde,
      );
      expect(taller.tieneCupo(hasta), isFalse);
    });
  });
}
