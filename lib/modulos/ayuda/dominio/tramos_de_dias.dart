/// Un tramo de días seguidos, ISO: 1 lunes a 7 domingo.
typedef TramoDeDias = ({int desde, int hasta});

/// Junta los días en tramos seguidos para escribir «lun a vie» y no cinco
/// días. Ordena, quita repetidos y descarta lo que no está de 1 a 7.
List<TramoDeDias> tramosDeDias(Iterable<int> dias) {
  final ordenados = ({
    for (final d in dias)
      if (d >= 1 && d <= 7) d,
  }.toList()..sort());
  final tramos = <TramoDeDias>[];
  for (final dia in ordenados) {
    if (tramos.isNotEmpty && tramos.last.hasta == dia - 1) {
      tramos.last = (desde: tramos.last.desde, hasta: dia);
    } else {
      tramos.add((desde: dia, hasta: dia));
    }
  }
  return tramos;
}
