import 'package:carecar_mobile/api/excepciones.dart';
import 'package:carecar_mobile/api/modelos/disponibilidad.dart';
import 'package:carecar_mobile/api/modelos/cita.dart';
import 'package:carecar_mobile/modulos/citas/datos/repositorio_citas_api.dart';
import 'package:carecar_mobile/modulos/citas/datos/repositorio_citas_fake.dart';
import 'package:carecar_mobile/modulos/citas/dominio/cita_cliente.dart';
import 'package:carecar_mobile/modulos/citas/dominio/disponibilidad_taller.dart';
import 'package:carecar_mobile/modulos/citas/dominio/fallos_agenda.dart';
import 'package:carecar_mobile/modulos/citas/dominio/motivo_cita.dart';
import 'package:carecar_mobile/api/modelos/problema.dart';
import 'package:carecar_mobile/api/modelos/recoleccion_cita.dart';
import 'package:carecar_mobile/api/modelos/traslado.dart';
import 'package:carecar_mobile/modulos/recoleccion/recoleccion.dart';
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

    test('divide una agenda de 61 días en rangos inclusivos válidos', () async {
      final rangos = <(DateTime, DateTime)>[];
      final api = ApiFalsa()
        ..alPedirDisponibilidad = (inicio, fin) async {
          rangos.add((inicio, fin));
          return [
            Disponibilidad(
              fecha: fin,
              franjaId: 1,
              horaInicio: '09:00',
              horaFin: '10:00',
              cupoDisponible: 2,
            ),
          ];
        };
      final fin = DateTime(2027, 1, 22);
      final taller = await RepositorioCitasApi(api)
          .disponibilidad(desde: desde, hasta: fin);
      expect(rangos, [(desde, hasta), (DateTime(2026, 12, 24), fin)]);
      expect(taller.tieneCupo(hasta), isTrue);
      expect(taller.tieneCupo(fin), isTrue);
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
        ..alAgendar = ((_) async => throw const Conflicto('x'))
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

  group('misCitas', () {
    Cita cita(int id, EstadoCita estado) => Cita(
      id: id,
      vehiculoId: 1,
      franjaId: 6,
      fecha: DateTime(2026, 11, 24),
      horaInicio: '09:00',
      horaFin: '10:00',
      estado: estado,
      vehiculoNombre: 'Mazda CX-5 2024',
      motivo: 'revision',
    );

    test('pide la pagina y traduce los cuatro estados', () async {
      final api = ApiFalsa()
        ..alPedirCitas = () async => [
          cita(1, EstadoCita.confirmada),
          cita(2, EstadoCita.atendida),
          cita(3, EstadoCita.noAsistio),
          cita(4, EstadoCita.cancelada),
          cita(5, EstadoCita.desconocido),
        ];
      final pagina = await RepositorioCitasApi(api)
          .misCitas(pagina: 0, tamano: 2);
      expect(pagina.citas.map((c) => c.id), [1, 2]);
      expect(pagina.hayMas, isTrue);
      final todas = await RepositorioCitasApi(api).misCitas(tamano: 10);
      expect(todas.citas.map((c) => c.estado), [
        EstadoDeCita.confirmada,
        EstadoDeCita.atendida,
        EstadoDeCita.noAsistio,
        EstadoDeCita.cancelada,
        EstadoDeCita.desconocido,
      ]);
      expect(todas.hayMas, isFalse);
      expect(todas.citas.first.vehiculoNombre, 'Mazda CX-5 2024');
      expect(todas.citas.first.motivo, MotivoCita.revision);
      expect(todas.citas.first.franjaId, 6);
    });

    test(
      'trae la recoleccion de la cita con el estado de cada traslado',
      () async {
        TrasladoCita traslado(int id, String tipo, String estado) =>
            TrasladoCita(
              id: id,
              tipo: tipo,
              estado: estado,
              costo: 150,
              fecha: DateTime(2026, 11, 24),
              ventanaInicio: '07:00',
              ventanaFin: '09:00',
            );
        final api = ApiFalsa()
          ..alPedirCitas = () async => [
            Cita(
              id: 1,
              vehiculoId: 1,
              fecha: DateTime(2026, 11, 24),
              horaInicio: '09:00',
              horaFin: '10:00',
              estado: EstadoCita.confirmada,
              recoleccion: RecoleccionCita(
                direccionId: 3,
                costoTotal: 300,
                traslados: [
                  traslado(7, 'recoger', 'en_camino'),
                  traslado(8, 'entregar', 'programado'),
                  traslado(9, 'otro', 'programado'),
                ],
              ),
            ),
            cita(2, EstadoCita.confirmada),
          ];

        final todas = await RepositorioCitasApi(api).misCitas(tamano: 10);

        final recoleccion = todas.citas.first.recoleccion!;
        expect(recoleccion.direccionId, 3);
        expect(recoleccion.costoTotal, 300);
        expect(recoleccion.recoger!.id, 7);
        expect(recoleccion.recoger!.estado, EstadoTraslado.enCamino);
        expect(recoleccion.entregar!.estado, EstadoTraslado.programado);
        expect(recoleccion.traslados, hasLength(2));
        expect(todas.citas.last.recoleccion, isNull);
      },
    );

    test('deja pasar SinConexion', () {
      final api = ApiFalsa()
        ..alPedirCitas = () async => throw const SinConexion();
      expect(RepositorioCitasApi(api).misCitas(), throwsA(isA<SinConexion>()));
    });
  });

  group('cancelar', () {
    test('llama a la API y devuelve la cita cancelada', () async {
      final api = ApiFalsa();
      final cita = await RepositorioCitasApi(api).cancelar(4);
      expect(api.citasCanceladas, [4]);
      expect(cita.estado, EstadoDeCita.cancelada);
    });

    test('un 409 se vuelve CitaNoModificable', () {
      final api = ApiFalsa()
        ..alCancelar = (_) async => throw const Conflicto('x');
      expect(
        RepositorioCitasApi(api).cancelar(4),
        throwsA(isA<CitaNoModificable>()),
      );
    });
  });

  group('reprogramar', () {
    final nueva = FranjaDisponible(
      franjaId: 8,
      fecha: DateTime(2026, 11, 26),
      horaInicio: '11:00',
      horaFin: '12:00',
      cupo: 1,
    );

    test('manda franja y fecha y devuelve la cita movida', () async {
      final api = ApiFalsa()
        ..alReprogramar = (id, franja, fecha) async => Cita(
          id: id,
          vehiculoId: 1,
          franjaId: franja,
          fecha: fecha,
          horaInicio: '11:00',
          horaFin: '12:00',
          estado: EstadoCita.confirmada,
        );
      final cita = await RepositorioCitasApi(api)
          .reprogramar(citaId: 4, franja: nueva);
      expect(api.citasReprogramadas.single.franjaId, 8);
      expect(api.citasReprogramadas.single.fecha, DateTime(2026, 11, 26));
      expect(cita.horaInicio, '11:00');
      expect(cita.fecha, DateTime(2026, 11, 26));
    });

    test('409 FRANJA_SIN_CUPO se vuelve FranjaSinCupo', () {
      final api = ApiFalsa()
        ..alReprogramar = (_, _, _) async => throw Conflicto(
          'x',
          problema: Problema(
            timestamp: '',
            status: 409,
            error: 'Conflict',
            message: 'x',
            path: '/citas',
            codigo: CodigoProblema.franjaSinCupo,
          ),
        );
      expect(
        RepositorioCitasApi(api).reprogramar(citaId: 4, franja: nueva),
        throwsA(isA<FranjaSinCupo>()),
      );
    });

    test('otro 409 se vuelve CitaNoModificable', () {
      final api = ApiFalsa()
        ..alReprogramar = (_, _, _) async => throw const Conflicto('x');
      expect(
        RepositorioCitasApi(api).reprogramar(citaId: 4, franja: nueva),
        throwsA(isA<CitaNoModificable>()),
      );
    });
  });

  group('RepositorioCitasFake de mis citas', () {
    final hoy = DateTime(2026, 11, 23, 12);
    CitaCliente cita(int id, {EstadoDeCita? estado, int dia = 26}) =>
        CitaCliente(
          id: id,
          vehiculoId: 1,
          franjaId: 1,
          fecha: DateTime(2026, 11, dia),
          horaInicio: '09:00',
          horaFin: '10:00',
          estado: estado ?? EstadoDeCita.confirmada,
        );

    test('pagina sus citas', () async {
      final repo = RepositorioCitasFake(
        citas: [for (var i = 1; i <= 5; i++) cita(i)],
      );
      final p0 = await repo.misCitas(pagina: 0, tamano: 2);
      final p2 = await repo.misCitas(pagina: 2, tamano: 2);
      expect(p0.citas.map((c) => c.id), [1, 2]);
      expect(p0.hayMas, isTrue);
      expect(p2.citas.map((c) => c.id), [5]);
      expect(p2.hayMas, isFalse);
    });

    test('cancelar cambia el estado', () async {
      final repo = RepositorioCitasFake(citas: [cita(1)], reloj: () => hoy);
      final cancelada = await repo.cancelar(1);
      expect(cancelada.estado, EstadoDeCita.cancelada);
      expect(
        (await repo.misCitas()).citas.single.estado,
        EstadoDeCita.cancelada,
      );
    });

    test('cancelar libera el cupo de la franja', () async {
      final repo = RepositorioCitasFake(reloj: () => hoy);
      final antes = await repo.disponibilidad(desde: desde, hasta: hasta);
      final franja = antes.franjasDe(DateTime(2026, 11, 26)).first;
      await repo.agendar(
        vehiculoId: 1,
        franja: franja,
        motivo: MotivoCita.revision,
      );
      final lleno = await repo.disponibilidad(desde: desde, hasta: hasta);
      expect(
        lleno.franjasDe(DateTime(2026, 11, 26)).first.cupo,
        franja.cupo - 1,
      );
      await repo.cancelar(1);
      final libre = await repo.disponibilidad(desde: desde, hasta: hasta);
      expect(libre.franjasDe(DateTime(2026, 11, 26)).first.cupo, franja.cupo);
    });

    test('cancelar una cita que no esta confirmada o ya paso falla', () async {
      final repo = RepositorioCitasFake(
        citas: [
          cita(1, estado: EstadoDeCita.atendida),
          cita(2, dia: 20),
        ],
        reloj: () => hoy,
      );
      expect(repo.cancelar(1), throwsA(isA<CitaNoModificable>()));
      expect(repo.cancelar(2), throwsA(isA<CitaNoModificable>()));
    });

    test('reprogramar mueve la cita y libera la franja anterior', () async {
      final repo = RepositorioCitasFake(
        franjas: [
          FranjaDisponible(
            franjaId: 1,
            fecha: DateTime(2026, 11, 26),
            horaInicio: '09:00',
            horaFin: '10:00',
            cupo: 1,
          ),
          FranjaDisponible(
            franjaId: 2,
            fecha: DateTime(2026, 11, 27),
            horaInicio: '11:00',
            horaFin: '12:00',
            cupo: 1,
          ),
        ],
        citas: [cita(1)],
        reloj: () => hoy,
      );
      final antes = await repo.disponibilidad(desde: desde, hasta: hasta);
      final nueva = antes.franjasDe(DateTime(2026, 11, 27)).single;
      final movida = await repo.reprogramar(citaId: 1, franja: nueva);
      expect(movida.fecha, DateTime(2026, 11, 27));
      expect(movida.horaInicio, '11:00');
      expect(movida.franjaId, 2);
      final despues = await repo.disponibilidad(desde: desde, hasta: hasta);
      expect(despues.tieneCupo(DateTime(2026, 11, 27)), isFalse);
      expect(despues.tieneCupo(DateTime(2026, 11, 26)), isTrue);
    });

    test('reprogramar a una franja llena lanza FranjaSinCupo', () {
      final repo = RepositorioCitasFake(
        citas: [cita(1)],
        franjasLlenas: {2},
        reloj: () => hoy,
      );
      final llena = FranjaDisponible(
        franjaId: 2,
        fecha: DateTime(2026, 11, 27),
        horaInicio: '11:00',
        horaFin: '12:00',
        cupo: 1,
      );
      expect(
        repo.reprogramar(citaId: 1, franja: llena),
        throwsA(isA<FranjaSinCupo>()),
      );
    });

    test('puede fallar a pedido', () {
      final repo = RepositorioCitasFake(error: const SinConexion());
      expect(repo.misCitas(), throwsA(isA<SinConexion>()));
      expect(repo.cancelar(1), throwsA(isA<SinConexion>()));
    });
  });

  group('comprobante', () {
    test('RepositorioCitasApi traduce el comprobante y su codigo', () async {
      final api = ApiFalsa()
        ..alPedirComprobanteDeCita = (id) async => ComprobanteCita(
          citaId: id,
          codigo: 'CC1.$id.firma',
          fecha: DateTime(2026, 11, 24),
          horaInicio: '09:00',
          horaFin: '10:00',
          vehiculoNombre: 'Mazda CX-5 2024',
        );
      final c = await RepositorioCitasApi(api).comprobante(7);
      expect(api.comprobantesDeCitaPedidos, [7]);
      expect(c.citaId, 7);
      expect(c.codigo, 'CC1.7.firma');
      expect(c.vehiculoNombre, 'Mazda CX-5 2024');
    });

    test('RepositorioCitasApi baja el PDF del ticket de la cita', () async {
      final api = ApiFalsa();
      final bytes = await RepositorioCitasApi(api).ticketPdf(7);
      expect(api.ticketsDeCitaPedidos, [7]);
      expect(bytes, isNotEmpty);
    });

    test('el fake arma el comprobante de una cita agendada', () async {
      final repo = RepositorioCitasFake();
      final f = FranjaDisponible(
        franjaId: 1,
        fecha: DateTime(2026, 11, 24),
        horaInicio: '11:00',
        horaFin: '12:00',
        cupo: 2,
      );
      final cita = await repo.agendar(
        vehiculoId: 1,
        franja: f,
        motivo: MotivoCita.otro,
      );
      final c = await repo.comprobante(cita.id);
      expect(c.codigo, isNotEmpty);
      expect(c.horaInicio, '11:00');
    });

    test('el fake puede fallar a pedido', () {
      final repo = RepositorioCitasFake(error: const SinConexion());
      expect(repo.comprobante(1), throwsA(isA<SinConexion>()));
      expect(repo.ticketPdf(1), throwsA(isA<SinConexion>()));
    });
  });
  group('agendar con recoleccion (V2-M17.02)', () {
    final franja = FranjaDisponible(
      franjaId: 6,
      fecha: DateTime(2026, 11, 24),
      horaInicio: '09:00',
      horaFin: '10:00',
      cupo: 2,
    );
    Cita citaConRecoleccion() => Cita(
      id: 7,
      vehiculoId: 1,
      franjaId: 6,
      fecha: DateTime(2026, 11, 24),
      horaInicio: '09:00',
      horaFin: '10:00',
      estado: EstadoCita.confirmada,
      recoleccion: RecoleccionCita(
        direccionId: 3,
        costoTotal: 300,
        traslados: [
          TrasladoCita(
            id: 1,
            tipo: 'recoger',
            estado: 'programado',
            costo: 150,
            fecha: DateTime(2026, 11, 24),
            ventanaInicio: '07:00',
            ventanaFin: '09:00',
          ),
          TrasladoCita(
            id: 2,
            tipo: 'entregar',
            estado: 'programado',
            costo: 150,
            fecha: DateTime(2026, 11, 24),
            ventanaInicio: '17:00',
            ventanaFin: '19:00',
          ),
        ],
      ),
    );

    test('manda recoleccion.direccionId y traduce los traslados', () async {
      final api = ApiFalsa()..alAgendar = (_) async => citaConRecoleccion();
      final agendada = await RepositorioCitasApi(api).agendar(
        vehiculoId: 1,
        franja: franja,
        motivo: MotivoCita.otro,
        direccionRecoleccionId: 3,
      );
      expect(api.citasAgendadas.single.recoleccionDireccionId, 3);
      final r = agendada.recoleccion!;
      expect(r.direccionId, 3);
      expect(r.costoTotal, 300);
      expect(r.recoger!.ventanaFin, '09:00');
      expect(r.entregar!.ventanaInicio, '17:00');
    });

    test('sin recoleccion no manda la clave y la cita no la trae', () async {
      final api = ApiFalsa();
      final agendada = await RepositorioCitasApi(api)
          .agendar(vehiculoId: 1, franja: franja, motivo: MotivoCita.otro);
      expect(api.citasAgendadas.single.recoleccionDireccionId, isNull);
      expect(agendada.recoleccion, isNull);
    });

    test('un 422 FUERA_DE_COBERTURA se vuelve FueraDeCobertura', () {
      final api = ApiFalsa()
        ..alAgendar = (_) async => throw const SolicitudRechazada(
          'fuera',
          problema: Problema(
            timestamp: 't',
            status: 422,
            error: 'Error',
            message: 'fuera',
            path: '/citas',
            codigo: CodigoProblema.fueraDeCobertura,
          ),
        );
      expect(
        RepositorioCitasApi(api).agendar(
          vehiculoId: 1,
          franja: franja,
          motivo: MotivoCita.otro,
          direccionRecoleccionId: 3,
        ),
        throwsA(isA<FueraDeCobertura>()),
      );
    });

    test('un 422 de otro codigo pasa como SolicitudRechazada', () {
      final api = ApiFalsa()
        ..alAgendar = (_) async => throw const SolicitudRechazada('otro');
      expect(
        RepositorioCitasApi(api).agendar(
          vehiculoId: 1,
          franja: franja,
          motivo: MotivoCita.otro,
          direccionRecoleccionId: 3,
        ),
        throwsA(isA<SolicitudRechazada>()),
      );
    });

    test('un 404 de direccion ajena pasa como NoEncontrado', () {
      final api = ApiFalsa()
        ..alAgendar = (_) async => throw const NoEncontrado('no existe');
      expect(
        RepositorioCitasApi(api).agendar(
          vehiculoId: 1,
          franja: franja,
          motivo: MotivoCita.otro,
          direccionRecoleccionId: 99,
        ),
        throwsA(isA<NoEncontrado>()),
      );
    });

    test('el fake crea los dos traslados con el costo configurado', () async {
      final repo = RepositorioCitasFake(costoPorTraslado: 120);
      final agendada = await repo.agendar(
        vehiculoId: 1,
        franja: FranjaDisponible(
          franjaId: 1,
          fecha: DateTime(2026, 11, 24),
          horaInicio: '09:00',
          horaFin: '10:00',
          cupo: 2,
        ),
        motivo: MotivoCita.otro,
        direccionRecoleccionId: 3,
      );
      final r = agendada.recoleccion!;
      expect(r.traslados, hasLength(2));
      expect(r.costoTotal, 240);
      expect(r.recoger!.tipo, TipoTraslado.recoger);
    });

    test('el fake rechaza una direccion fuera de cobertura', () {
      final repo = RepositorioCitasFake(direccionesFueraDeCobertura: const {5});
      expect(
        repo.agendar(
          vehiculoId: 1,
          franja: FranjaDisponible(
            franjaId: 1,
            fecha: DateTime(2026, 11, 24),
            horaInicio: '09:00',
            horaFin: '10:00',
            cupo: 2,
          ),
          motivo: MotivoCita.otro,
          direccionRecoleccionId: 5,
        ),
        throwsA(isA<FueraDeCobertura>()),
      );
    });
  });
}
