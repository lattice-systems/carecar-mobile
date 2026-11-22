import 'package:carecar_mobile/api/excepciones.dart';
import 'package:carecar_mobile/api/modelos/disponibilidad.dart';
import 'package:carecar_mobile/api/modelos/cita.dart';
import 'package:carecar_mobile/modulos/citas/datos/repositorio_citas_api.dart';
import 'package:carecar_mobile/modulos/citas/datos/repositorio_citas_fake.dart';
import 'package:carecar_mobile/modulos/citas/dominio/disponibilidad_taller.dart';
import 'package:carecar_mobile/modulos/citas/dominio/fallos_agenda.dart';
import 'package:carecar_mobile/modulos/citas/dominio/motivo_cita.dart';
import 'package:carecar_mobile/api/modelos/problema.dart';
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
      final taller = await RepositorioCitasApi(api)
          .disponibilidad(desde: desde, hasta: hasta);
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

  group('agendar', () {
    final franja = FranjaDisponible(
      franjaId: 6,
      fecha: DateTime(2026, 11, 24),
      horaInicio: '09:00',
      horaFin: '10:00',
      cupo: 2,
    );
    Cita cita({int id = 1, EstadoCita estado = EstadoCita.confirmada}) => Cita(
      id: id,
      vehiculoId: 1,
      franjaId: 6,
      fecha: DateTime(2026, 11, 24),
      horaInicio: '09:00',
      horaFin: '10:00',
      estado: estado,
      motivo: 'mantenimiento',
    );
    Problema problema(CodigoProblema codigo) => Problema(
      timestamp: '',
      status: 409,
      error: 'Conflict',
      message: 'x',
      path: '/citas',
      codigo: codigo,
    );

    test('manda vehiculo, franja, fecha y motivo y traduce la cita', () async {
      final api = ApiFalsa()..alAgendar = (_) async => cita(id: 7);
      final agendada = await RepositorioCitasApi(api).agendar(
        vehiculoId: 1,
        franja: franja,
        motivo: MotivoCita.mantenimiento,
      );
      final enviada = api.citasAgendadas.single;
      expect(enviada.vehiculoId, 1);
      expect(enviada.franjaId, 6);
      expect(enviada.fecha, DateTime(2026, 11, 24));
      expect(enviada.motivo, 'mantenimiento');
      expect(agendada.id, 7);
      expect(agendada.horaInicio, '09:00');
    });

    test('409 FRANJA_SIN_CUPO se vuelve FranjaSinCupo', () {
      final api = ApiFalsa()
        ..alAgendar = (_) async => throw Conflicto(
          'x',
          problema: problema(CodigoProblema.franjaSinCupo),
        );
      expect(
        RepositorioCitasApi(api)
            .agendar(vehiculoId: 1, franja: franja, motivo: MotivoCita.otro),
        throwsA(isA<FranjaSinCupo>()),
      );
    });

    test('otro 409 con cita confirmada igual se vuelve CitaDuplicada', () {
      final api = ApiFalsa()
        ..alAgendar = (_) async =>
            throw const Conflicto('x')
              ..alPedirCitas = () async => [cita(id: 3)];
      expect(
        RepositorioCitasApi(api)
            .agendar(vehiculoId: 1, franja: franja, motivo: MotivoCita.otro),
        throwsA(isA<CitaDuplicada>().having((e) => e.existente.id, 'id', 3)),
      );
    });

    test('un 409 que no se reconoce pasa tal cual', () {
      final api = ApiFalsa()
        ..alAgendar = (_) async => throw const Conflicto('x');
      expect(
        RepositorioCitasApi(api)
            .agendar(vehiculoId: 1, franja: franja, motivo: MotivoCita.otro),
        throwsA(isA<Conflicto>()),
      );
    });

    test('el fake agenda, descuenta y detecta la duplicada', () async {
      final repo = RepositorioCitasFake();
      final taller = await repo.disponibilidad(desde: desde, hasta: hasta);
      final f = taller.franjasDe(DateTime(2026, 11, 24)).first;
      final agendada = await repo.agendar(
        vehiculoId: 1,
        franja: f,
        motivo: MotivoCita.revision,
      );
      expect(agendada.motivo, MotivoCita.revision);
      expect(
        repo.agendar(vehiculoId: 1, franja: f, motivo: MotivoCita.revision),
        throwsA(isA<CitaDuplicada>()),
      );
    });

    test('el fake responde sin cupo para las franjas llenas', () {
      final repo = RepositorioCitasFake(franjasLlenas: {6});
      expect(
        repo.agendar(vehiculoId: 1, franja: franja, motivo: MotivoCita.otro),
        throwsA(isA<FranjaSinCupo>()),
      );
    });
  });
}
