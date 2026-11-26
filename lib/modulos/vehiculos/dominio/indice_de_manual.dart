/// Texto de una página del manual, para la búsqueda offline (V2-M02.03).
class PaginaDeManual {
  const PaginaDeManual(this.pagina, this.texto);

  /// Número de página (desde 1), el que entiende el visor.
  final int pagina;
  final String texto;
}

/// Una coincidencia de la búsqueda: la página y un fragmento que la rodea.
class ResultadoBusquedaManual {
  const ResultadoBusquedaManual({
    required this.pagina,
    required this.fragmento,
  });

  final int pagina;
  final String fragmento;
}

/// Índice de texto del manual de un modelo y año. Permite buscar sin conexión y
/// sin un motor de PDF: el texto se extrajo antes (ver `tool/generar_indice_manuales.py`).
class IndiceDeManual {
  const IndiceDeManual({required this.manual, required this.paginas});

  final String manual;
  final List<PaginaDeManual> paginas;

  /// Las páginas que contienen [consulta], en orden y sin repetir, con un
  /// fragmento alrededor. Una consulta de menos de dos letras no busca.
  List<ResultadoBusquedaManual> buscar(String consulta) {
    final aguja = _normalizar(consulta.trim());
    if (aguja.length < 2) return const [];
    final resultados = <ResultadoBusquedaManual>[];
    for (final pagina in paginas) {
      final i = _normalizar(pagina.texto).indexOf(aguja);
      if (i >= 0) {
        resultados.add(
          ResultadoBusquedaManual(
            pagina: pagina.pagina,
            fragmento: _fragmento(pagina.texto, i, aguja.length),
          ),
        );
      }
    }
    return resultados;
  }

  /// Un trozo del texto original alrededor de la coincidencia. La
  /// normalización conserva la posición de cada carácter, así que el índice de
  /// la aguja sirve igual sobre el texto original.
  static String _fragmento(String texto, int inicio, int largo) {
    const margen = 40;
    final desde = (inicio - margen).clamp(0, texto.length);
    final hasta = (inicio + largo + margen).clamp(0, texto.length);
    final nucleo = texto.substring(desde, hasta).trim();
    final antes = desde > 0 ? '… ' : '';
    final despues = hasta < texto.length ? ' …' : '';
    return '$antes$nucleo$despues';
  }

  /// Minúsculas y vocales sin acento, carácter por carácter (no cambia el
  /// largo), para buscar sin que estorben mayúsculas ni tildes.
  static String _normalizar(String texto) {
    const acentos = {
      'á': 'a',
      'é': 'e',
      'í': 'i',
      'ó': 'o',
      'ú': 'u',
      'ü': 'u',
    };
    final minusculas = texto.toLowerCase();
    final buffer = StringBuffer();
    for (final caracter in minusculas.split('')) {
      buffer.write(acentos[caracter] ?? caracter);
    }
    return buffer.toString();
  }
}
