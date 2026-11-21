/// Una pagina de resultados (`PaginaServicios`, `PaginaCitas` del contrato).
class Pagina<T> {
  const Pagina({
    required this.contenido,
    this.pagina = 0,
    this.totalPaginas = 1,
  });

  final List<T> contenido;

  /// Indice de esta pagina, empezando en 0.
  final int pagina;
  final int totalPaginas;

  /// Si quedan paginas por pedir despues de esta.
  bool get hayMas => pagina + 1 < totalPaginas;
}
