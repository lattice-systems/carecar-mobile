/// El cambio de correo que está esperando su código · V2-M01.07.
///
/// Dart puro. No trae el correo nuevo: quien pidió el cambio lo acaba de
/// escribir y la pantalla ya lo tiene; repetirlo solo sería un dato personal
/// más dando vueltas.
class CambioDeCorreoPendiente {
  const CambioDeCorreoPendiente({required this.id, required this.expira});

  final int id;

  /// A los 15 minutos de pedirlo, igual que el código de recuperación.
  final DateTime expira;

  /// Si ya no tiene sentido mandar el código.
  ///
  /// Sirve para no gastar un viaje condenado y para poder ofrecer pedir otro
  /// antes de que la persona escriba seis dígitos para nada. Compara en UTC:
  /// el servidor manda un instante y el reloj de la pantalla es local.
  bool yaVencio(DateTime ahora) => !ahora.toUtc().isBefore(expira.toUtc());
}
