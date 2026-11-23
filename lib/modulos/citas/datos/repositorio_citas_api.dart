import 'dart:typed_data';

import '../../../api/carecar_api.dart';
import '../../../api/excepciones.dart';
import '../../../api/modelos/cita.dart';
import '../../../api/modelos/problema.dart';
import '../dominio/cita_agendada.dart';
import '../dominio/cita_cliente.dart';
import '../dominio/comprobante_de_cita.dart';
import '../dominio/disponibilidad_taller.dart';
import '../dominio/fallos_agenda.dart';
import '../dominio/motivo_cita.dart';
import '../dominio/repositorio_citas.dart';

/// Lee `GET /agenda/disponibilidad` y agenda con `POST /citas`, y lo traduce a
/// modelos de dominio.
///
/// Las excepciones de la API (`SinConexion`, `ExcepcionApi`) pasan tal cual: la
/// presentacion decide como mostrarlas. Solo el 409 se traduce.
class RepositorioCitasApi implements RepositorioCitas {
  const RepositorioCitasApi(this._api);

  final CarecarApi _api;

  @override
  Future<DisponibilidadTaller> disponibilidad({
    required DateTime desde,
    required DateTime hasta,
  }) async {
    final dto = await _api.disponibilidad(desde: desde, hasta: hasta);
    return DisponibilidadTaller(
      dto.map(
        (d) => FranjaDisponible(
          franjaId: d.franjaId,
          fecha: d.fecha,
          horaInicio: d.horaInicio,
          horaFin: d.horaFin,
          cupo: d.cupoDisponible,
        ),
      ),
    );
  }

  @override
  Future<CitaAgendada> agendar({
    required int vehiculoId,
    required FranjaDisponible franja,
    required MotivoCita motivo,
  }) async {
    try {
      final cita = await _api.agendarCita(
        NuevaCita(
          vehiculoId: vehiculoId,
          franjaId: franja.franjaId,
          fecha: franja.fecha,
          motivo: motivo.codigo,
        ),
      );
      return _aDominio(cita);
    } on Conflicto catch (conflicto) {
      if (conflicto.problema?.codigo == CodigoProblema.franjaSinCupo) {
        throw const FranjaSinCupo();
      }
      // Hoy el backend responde el 409 de cita duplicada sin codigo; se
      // reconoce buscando la cita confirmada que ya existe. Cuando llegue
      // `CITA_DUPLICADA` seguira funcionando igual.
      final existente = await _citaExistente(vehiculoId, franja);
      if (existente != null) throw CitaDuplicada(_aDominio(existente));
      rethrow;
    }
  }

  @override
  Future<ComprobanteDeCita> comprobante(int citaId) async {
    final c = await _api.comprobanteDeCita(citaId);
    return ComprobanteDeCita(
      citaId: c.citaId,
      codigo: c.codigo,
      fecha: c.fecha,
      horaInicio: c.horaInicio,
      horaFin: c.horaFin,
      vehiculoNombre: c.vehiculoNombre,
    );
  }

  @override
  Future<Uint8List> ticketPdf(int citaId) => _api.ticketDeCita(citaId);

  Future<Cita?> _citaExistente(int vehiculoId, FranjaDisponible franja) async {
    final citas = await _api.misCitas();
    for (final c in citas) {
      final mismoDia =
          c.fecha.year == franja.fecha.year &&
          c.fecha.month == franja.fecha.month &&
          c.fecha.day == franja.fecha.day;
      if (c.estado == EstadoCita.confirmada &&
          mismoDia &&
          (c.vehiculoId == vehiculoId || c.franjaId == franja.franjaId)) {
        return c;
      }
    }
    return null;
  }

  @override
  Future<PaginaDeCitas> misCitas({int pagina = 0, int tamano = 20}) async {
    final p = await _api.paginaDeCitas(pagina: pagina, tamano: tamano);
    return PaginaDeCitas(
      citas: p.contenido.map(_aCliente).toList(),
      pagina: p.pagina,
      totalPaginas: p.totalPaginas,
    );
  }

  @override
  Future<CitaCliente> cancelar(int citaId) async {
    try {
      return _aCliente(await _api.cancelarCita(citaId));
    } on Conflicto {
      throw const CitaNoModificable();
    }
  }

  @override
  Future<CitaCliente> reprogramar({
    required int citaId,
    required FranjaDisponible franja,
  }) async {
    try {
      final cita = await _api.reprogramarCita(
        citaId,
        franjaId: franja.franjaId,
        fecha: franja.fecha,
      );
      return _aCliente(cita);
    } on Conflicto catch (conflicto) {
      if (conflicto.problema?.codigo == CodigoProblema.franjaSinCupo) {
        throw const FranjaSinCupo();
      }
      throw const CitaNoModificable();
    }
  }

  CitaCliente _aCliente(Cita c) => CitaCliente(
    id: c.id,
    vehiculoId: c.vehiculoId,
    fecha: c.fecha,
    horaInicio: c.horaInicio,
    horaFin: c.horaFin,
    estado: switch (c.estado) {
      EstadoCita.confirmada => EstadoDeCita.confirmada,
      EstadoCita.atendida => EstadoDeCita.atendida,
      EstadoCita.noAsistio => EstadoDeCita.noAsistio,
      EstadoCita.cancelada => EstadoDeCita.cancelada,
      EstadoCita.desconocido => EstadoDeCita.desconocido,
    },
    franjaId: c.franjaId,
    vehiculoNombre: c.vehiculoNombre,
    motivo: MotivoCita.desdeCodigo(c.motivo),
  );

  CitaAgendada _aDominio(Cita c) => CitaAgendada(
    id: c.id,
    vehiculoId: c.vehiculoId,
    fecha: c.fecha,
    horaInicio: c.horaInicio,
    horaFin: c.horaFin,
    motivo: MotivoCita.desdeCodigo(c.motivo),
  );
}
