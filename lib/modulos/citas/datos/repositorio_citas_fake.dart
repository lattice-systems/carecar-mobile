import '../dominio/disponibilidad_taller.dart';
import '../dominio/repositorio_citas.dart';

/// Repositorio con datos en memoria para pruebas y desarrollo.
///
/// Sin `franjas`, genera tres franjas de lunes a viernes en el rango pedido y
/// deja sin cupo los dias que terminan en 0 o 5, para ver dias deshabilitados.
/// Con `error` falla a pedido, como lo haria la red.
class RepositorioCitasFake implements RepositorioCitas {
  RepositorioCitasFake({this.franjas, this.error});

  /// Franjas fijas; si es nulo se generan por rango.
  final List<FranjaDisponible>? franjas;

  /// Si no es nulo, `disponibilidad` lo lanza.
  final Object? error;

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
        fijas.where((f) => !f.fecha.isBefore(inicio) && !f.fecha.isAfter(fin)),
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
    return DisponibilidadTaller(generadas);
  }
}
