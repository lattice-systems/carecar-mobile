import 'package:flutter/material.dart' show DateUtils;

import '../dominio/cita_agendada.dart';
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
class RepositorioCitasFake implements RepositorioCitas {
  RepositorioCitasFake({
    this.franjas,
    this.error,
    this.franjasLlenas = const {},
  });

  /// Franjas fijas; si es nulo se generan por rango.
  final List<FranjaDisponible>? franjas;

  /// Si no es nulo, `disponibilidad` y `agendar` lo lanzan.
  final Object? error;

  /// Ids de franja que ya no tienen lugar.
  final Set<int> franjasLlenas;

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
  }) async {
    final falla = error;
    if (falla != null) throw falla;
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
    );
    _agendadas.add(cita);
    return cita;
  }
}
