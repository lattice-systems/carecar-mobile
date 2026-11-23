import 'dart:typed_data';

import 'package:flutter/material.dart' show DateUtils;

import '../../recoleccion/recoleccion.dart';
import '../dominio/cita_agendada.dart';
import '../dominio/cita_cliente.dart';
import '../dominio/comprobante_de_cita.dart';
import '../dominio/disponibilidad_taller.dart';
import '../dominio/fallos_agenda.dart';
import '../dominio/motivo_cita.dart';
import '../dominio/repositorio_citas.dart';

/// Repositorio con datos en memoria para pruebas y desarrollo.
///
/// Sin `franjas`, genera tres franjas de lunes a viernes en el rango pedido y
/// deja sin cupo los dias que terminan en 0 o 5, para ver dias deshabilitados.
/// Las fechas salen del rango que pide la pantalla (que parte de "hoy"), no de
/// una semilla fija: el flujo de agendar se ve siempre con dias futuros.
/// Con `error` falla a pedido, como lo haria la red.
///
/// `agendar` descuenta cupo, rechaza las `franjasLlenas` con `FranjaSinCupo` y
/// responde `CitaDuplicada` si ya hay cita del mismo vehiculo ese dia.
///
/// `citas` es la semilla de `misCitas`; `cancelar` y `reprogramar` solo
/// aceptan citas confirmadas que empiezan despues de `reloj()`, y liberan el
/// cupo de la franja anterior como lo hace el servidor.
class RepositorioCitasFake implements RepositorioCitas {
  RepositorioCitasFake({
    this.franjas,
    this.error,
    this.franjasLlenas = const {},
    List<CitaCliente> citas = const [],
    DateTime Function()? reloj,
    this.costoPorTraslado = 150,
    this.direccionesFueraDeCobertura = const {},
  }) : _citas = [...citas],
       _reloj = reloj ?? DateTime.now;

  /// Franjas fijas; si es nulo se generan por rango.
  final List<FranjaDisponible>? franjas;

  /// Si no es nulo, `disponibilidad` y `agendar` lo lanzan.
  final Object? error;

  /// Ids de franja que ya no tienen lugar.
  final Set<int> franjasLlenas;

  /// Pesos de cada traslado cuando la cita se agenda con recoleccion.
  final double costoPorTraslado;

  /// Ids de direccion que el servidor rechaza con `FueraDeCobertura`.
  final Set<int> direccionesFueraDeCobertura;

  final List<CitaCliente> _citas;
  final DateTime Function() _reloj;
  final _agendadas = <CitaAgendada>[];
  final _usados = <int, int>{};

  @override
  Future<DisponibilidadTaller> disponibilidad({
    required DateTime desde,
    required DateTime hasta,
  }) async {
    final falla = error;
    if (falla != null) throw falla;
    final inicio = DateTime(desde.year, desde.month, desde.day);
    final fin = DateTime(hasta.year, hasta.month, hasta.day);
    final fijas = franjas;
    if (fijas != null) {
      return DisponibilidadTaller(
        fijas
            .where((f) => !f.fecha.isBefore(inicio) && !f.fecha.isAfter(fin))
            .map(_descontada),
      );
    }
    final generadas = <FranjaDisponible>[];
    var id = 1;
    for (
      var dia = inicio;
      !dia.isAfter(fin);
      dia = DateTime(dia.year, dia.month, dia.day + 1)
    ) {
      final laboral = dia.weekday <= DateTime.friday;
      if (!laboral || dia.day % 5 == 0) continue;
      for (final (hora, cupo) in const [
        ('09:00', 3),
        ('11:00', 1),
        ('15:00', 2),
      ]) {
        generadas.add(
          FranjaDisponible(
            franjaId: id++,
            fecha: dia,
            horaInicio: hora,
            horaFin:
                '${(int.parse(hora.substring(0, 2)) + 1).toString().padLeft(2, '0')}:00',
            cupo: cupo,
          ),
        );
      }
    }
    return DisponibilidadTaller(generadas.map(_descontada));
  }

  FranjaDisponible _descontada(FranjaDisponible f) {
    final cupo = franjasLlenas.contains(f.franjaId)
        ? 0
        : f.cupo - (_usados[f.franjaId] ?? 0);
    return FranjaDisponible(
      franjaId: f.franjaId,
      fecha: f.fecha,
      horaInicio: f.horaInicio,
      horaFin: f.horaFin,
      cupo: cupo < 0 ? 0 : cupo,
    );
  }

  @override
  Future<CitaAgendada> agendar({
    required int vehiculoId,
    required FranjaDisponible franja,
    required MotivoCita motivo,
    int? direccionRecoleccionId,
  }) async {
    final falla = error;
    if (falla != null) throw falla;
    if (direccionesFueraDeCobertura.contains(direccionRecoleccionId)) {
      throw const FueraDeCobertura();
    }
    for (final c in _agendadas) {
      if (c.vehiculoId == vehiculoId &&
          DateUtils.isSameDay(c.fecha, franja.fecha)) {
        throw CitaDuplicada(c);
      }
    }
    if (_descontada(franja).cupo == 0) throw const FranjaSinCupo();
    _usados[franja.franjaId] = (_usados[franja.franjaId] ?? 0) + 1;
    final cita = CitaAgendada(
      id: _agendadas.length + 1,
      vehiculoId: vehiculoId,
      fecha: franja.fecha,
      horaInicio: franja.horaInicio,
      horaFin: franja.horaFin,
      motivo: motivo,
      recoleccion: direccionRecoleccionId == null
          ? null
          : _recoleccion(direccionRecoleccionId, franja.fecha),
    );
    _agendadas.add(cita);
    _citas.add(
      CitaCliente(
        id: cita.id,
        vehiculoId: vehiculoId,
        franjaId: franja.franjaId,
        fecha: cita.fecha,
        horaInicio: cita.horaInicio,
        horaFin: cita.horaFin,
        estado: EstadoDeCita.confirmada,
        motivo: motivo,
      ),
    );
    return cita;
  }

  RecoleccionAgendada _recoleccion(int direccionId, DateTime fecha) =>
      RecoleccionAgendada(
        direccionId: direccionId,
        costoTotal: costoPorTraslado * 2,
        traslados: [
          TrasladoAgendado(
            id: 1,
            tipo: TipoTraslado.recoger,
            costo: costoPorTraslado,
            fecha: fecha,
            ventanaInicio: '07:00',
            ventanaFin: '09:00',
          ),
          TrasladoAgendado(
            id: 2,
            tipo: TipoTraslado.entregar,
            costo: costoPorTraslado,
            fecha: fecha,
            ventanaInicio: '17:00',
            ventanaFin: '19:00',
          ),
        ],
      );

  @override
  Future<PaginaDeCitas> misCitas({int pagina = 0, int tamano = 20}) async {
    final falla = error;
    if (falla != null) throw falla;
    final inicio = (pagina * tamano).clamp(0, _citas.length);
    final fin = (inicio + tamano).clamp(0, _citas.length);
    return PaginaDeCitas(
      citas: _citas.sublist(inicio, fin),
      pagina: pagina,
      totalPaginas: _citas.isEmpty ? 0 : (_citas.length / tamano).ceil(),
    );
  }

  @override
  Future<CitaCliente> cancelar(int citaId) async {
    final falla = error;
    if (falla != null) throw falla;
    final i = _modificable(citaId);
    _liberar(_citas[i].franjaId);
    return _citas[i] = _con(_citas[i], estado: EstadoDeCita.cancelada);
  }

  @override
  Future<CitaCliente> reprogramar({
    required int citaId,
    required FranjaDisponible franja,
  }) async {
    final falla = error;
    if (falla != null) throw falla;
    final i = _modificable(citaId);
    if (_descontada(franja).cupo == 0) throw const FranjaSinCupo();
    _liberar(_citas[i].franjaId);
    _usados[franja.franjaId] = (_usados[franja.franjaId] ?? 0) + 1;
    return _citas[i] = _con(
      _citas[i],
      franjaId: franja.franjaId,
      fecha: franja.fecha,
      horaInicio: franja.horaInicio,
      horaFin: franja.horaFin,
    );
  }

  int _modificable(int citaId) {
    final i = _citas.indexWhere((c) => c.id == citaId);
    if (i < 0 || !_citas[i].sePuedeModificar(_reloj())) {
      throw const CitaNoModificable();
    }
    return i;
  }

  void _liberar(int? franjaId) {
    if (franjaId == null) return;
    final usados = _usados[franjaId] ?? 0;
    _usados[franjaId] = usados > 0 ? usados - 1 : 0;
  }

  static CitaCliente _con(
    CitaCliente c, {
    EstadoDeCita? estado,
    int? franjaId,
    DateTime? fecha,
    String? horaInicio,
    String? horaFin,
  }) => CitaCliente(
    id: c.id,
    vehiculoId: c.vehiculoId,
    franjaId: franjaId ?? c.franjaId,
    vehiculoNombre: c.vehiculoNombre,
    fecha: fecha ?? c.fecha,
    horaInicio: horaInicio ?? c.horaInicio,
    horaFin: horaFin ?? c.horaFin,
    estado: estado ?? c.estado,
    motivo: c.motivo,
  );

  @override
  Future<ComprobanteDeCita> comprobante(int citaId) async {
    final falla = error;
    if (falla != null) throw falla;
    final agendada = _agendadas.where((c) => c.id == citaId).firstOrNull;
    return ComprobanteDeCita(
      citaId: citaId,
      codigo: 'CC1.$citaId.firma',
      fecha: agendada?.fecha ?? DateTime(2026, 11, 24),
      horaInicio: agendada?.horaInicio ?? '09:00',
      horaFin: agendada?.horaFin ?? '10:00',
      vehiculoNombre: 'Mazda CX-5 2024',
    );
  }

  @override
  Future<Uint8List> ticketPdf(int citaId) async {
    final falla = error;
    if (falla != null) throw falla;
    return Uint8List.fromList('%PDF-1.4\n%%EOF\n'.codeUnits);
  }
}
