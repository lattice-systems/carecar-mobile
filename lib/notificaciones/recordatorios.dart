/// Calculo puro de los recordatorios de una cita: cuando y con que texto.
///
/// No depende del plugin ni de la zona horaria: trabaja con la hora de pared
/// de la agencia (America/Mexico_City), asi se prueba sin dispositivo.
library;

import '../api/modelos/cita.dart';

/// Un aviso listo para programar.
class Recordatorio {
  const Recordatorio({
    required this.id,
    required this.cuando,
    required this.titulo,
    required this.cuerpo,
  });

  final int id;

  /// Hora de pared en la zona de la agencia.
  final DateTime cuando;
  final String titulo;
  final String cuerpo;
}

/// Ids deterministas: cada cita reserva un bloque de 10.
///
/// Se limita a 31 bits porque Android usa enteros de 32 con signo.
abstract final class IdsNotificacion {
  static int _base(int citaId) => (citaId % 200000000) * 10;

  /// Aviso inmediato de cita agendada.
  static int confirmacion(int citaId) => _base(citaId);

  /// Recordatorio 24 h antes.
  static int dia(int citaId) => _base(citaId) + 1;

  /// Recordatorio 2 h antes.
  static int dosHoras(int citaId) => _base(citaId) + 2;

  /// Los ids programados de una cita (los que se cancelan).
  static List<int> recordatorios(int citaId) => [dia(citaId), dosHoras(citaId)];
}

/// Inicio de la cita como hora de pared, o null si `horaInicio` no se lee.
DateTime? inicioDeCita(Cita cita) {
  final partes = cita.horaInicio.split(':');
  if (partes.length < 2) return null;
  final hora = int.tryParse(partes[0]);
  final minuto = int.tryParse(partes[1]);
  if (hora == null || minuto == null) return null;
  return DateTime(
    cita.fecha.year,
    cita.fecha.month,
    cita.fecha.day,
    hora,
    minuto,
  );
}

String _dos(int n) => n.toString().padLeft(2, '0');

String _horaCorta(DateTime f) => '${_dos(f.hour)}:${_dos(f.minute)}';

String _sufijo(String? vehiculo) =>
    vehiculo == null || vehiculo.trim().isEmpty ? '' : ' · ${vehiculo.trim()}';

/// Recordatorios de 24 h y 2 h de una cita confirmada, sin los que ya pasaron.
List<Recordatorio> recordatoriosDe(
  Cita cita, {
  required DateTime ahora,
  String? vehiculo,
}) {
  if (cita.estado != EstadoCita.confirmada) return const [];
  final inicio = inicioDeCita(cita);
  if (inicio == null) return const [];
  final nombre = vehiculo ?? cita.vehiculoNombre;
  final hora = _horaCorta(inicio);
  final candidatos = [
    Recordatorio(
      id: IdsNotificacion.dia(cita.id),
      cuando: inicio.subtract(const Duration(hours: 24)),
      titulo: 'Recordatorio de cita',
      cuerpo: 'Tu cita en Agencia360 es mañana a las $hora${_sufijo(nombre)}',
    ),
    Recordatorio(
      id: IdsNotificacion.dosHoras(cita.id),
      cuando: inicio.subtract(const Duration(hours: 2)),
      titulo: 'Tu cita es pronto',
      cuerpo: 'Tu cita en Agencia360 es hoy a las $hora${_sufijo(nombre)}',
    ),
  ];
  return [
    for (final r in candidatos)
      if (r.cuando.isAfter(ahora)) r,
  ];
}

/// Texto del aviso inmediato al agendar.
({String titulo, String cuerpo}) textoConfirmacion(
  Cita cita, {
  String? vehiculo,
}) {
  final inicio = inicioDeCita(cita);
  final f = cita.fecha;
  final fecha = '${_dos(f.day)}/${_dos(f.month)}/${f.year}';
  final hora = inicio == null ? cita.horaInicio : _horaCorta(inicio);
  return (
    titulo: 'Cita agendada',
    cuerpo:
        'Te esperamos el $fecha a las $hora'
        '${_sufijo(vehiculo ?? cita.vehiculoNombre)}. '
        'Te recordaremos un día y dos horas antes.',
  );
}
