/// Lo que recepcion necesita ver de una cita: el codigo del QR y los datos.
///
/// Dart puro. `codigo` es el id de la cita firmado por el backend; la app lo
/// dibuja tal cual en el QR y nunca lo firma ni lo interpreta.
class ComprobanteDeCita {
  const ComprobanteDeCita({
    required this.citaId,
    required this.codigo,
    required this.fecha,
    required this.horaInicio,
    required this.horaFin,
    this.vehiculoNombre,
  });

  final int citaId;
  final String codigo;
  final DateTime fecha;
  final String horaInicio;
  final String horaFin;

  /// Nulo si el backend no lo manda.
  final String? vehiculoNombre;
}
