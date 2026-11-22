/// Aviso de ejemplo. Dart puro: sin Flutter ni red.
class Aviso {
  const Aviso({
    required this.id,
    required this.titulo,
    required this.detalle,
    this.urgente = false,
  });

  final int id;
  final String titulo;
  final String detalle;
  final bool urgente;

  /// Regla de dominio de ejemplo: los urgentes primero, y a igualdad, por
  /// titulo. No modifica la lista recibida.
  static List<Aviso> ordenar(Iterable<Aviso> avisos) {
    final lista = avisos.toList();
    lista.sort((a, b) {
      if (a.urgente != b.urgente) return a.urgente ? -1 : 1;
      return a.titulo.compareTo(b.titulo);
    });
    return lista;
  }
}
