import 'cita_agendada.dart';

/// El taller se quedo sin lugares en la franja mientras el cliente decidia
/// (409 `FRANJA_SIN_CUPO`). La pantalla ofrece franjas cercanas.
class FranjaSinCupo implements Exception {
  const FranjaSinCupo();

  @override
  String toString() => 'FranjaSinCupo';
}

/// El cliente ya tiene una cita confirmada para ese vehiculo y dia (409
/// `CITA_DUPLICADA`). Trae la cita que ya existe para mostrarla.
class CitaDuplicada implements Exception {
  const CitaDuplicada(this.existente);

  final CitaAgendada existente;

  @override
  String toString() => 'CitaDuplicada(${existente.id})';
}

/// La cita ya no se puede cancelar ni reprogramar: dejó de estar confirmada o
/// pasó el plazo (409 `CITA_NO_CANCELABLE`, `FUERA_DE_PLAZO` o el equivalente
/// de reprogramar).
class CitaNoModificable implements Exception {
  const CitaNoModificable();

  @override
  String toString() => 'CitaNoModificable';
}
