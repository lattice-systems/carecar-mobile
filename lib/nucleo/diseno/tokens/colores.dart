import 'dart:ui';

/// Paleta semantica del sistema de diseno v2. Ningun componente debe usar
/// hexadecimales directos, solo estos tokens.
class PaletaColores {
  const PaletaColores({
    required this.fondo,
    required this.superficie,
    required this.superficieElevada,
    required this.superficieHundida,
    required this.borde,
    required this.texto,
    required this.textoSecundario,
    required this.textoTerciario,
    required this.acento,
    required this.sobreAcento,
    required this.marca,
    required this.exito,
    required this.advertencia,
    required this.peligro,
    required this.velo,
    required this.acentoSuave,
    required this.exitoSuave,
    required this.advertenciaSuave,
    required this.peligroSuave,
  });

  /// Construye la paleta y calcula las variantes suaves de los colores de
  /// estado como una mezcla de poca opacidad sobre la superficie.
  factory PaletaColores._base({
    required Color fondo,
    required Color superficie,
    required Color superficieElevada,
    required Color superficieHundida,
    required Color borde,
    required Color texto,
    required Color textoSecundario,
    required Color textoTerciario,
    required Color acento,
    required Color sobreAcento,
    required Color marca,
    required Color exito,
    required Color advertencia,
    required Color peligro,
    required Color velo,
  }) {
    Color suave(Color c) => _mezclar(c, superficie, _opacidadSuave);
    return PaletaColores(
      fondo: fondo,
      superficie: superficie,
      superficieElevada: superficieElevada,
      superficieHundida: superficieHundida,
      borde: borde,
      texto: texto,
      textoSecundario: textoSecundario,
      textoTerciario: textoTerciario,
      acento: acento,
      sobreAcento: sobreAcento,
      marca: marca,
      exito: exito,
      advertencia: advertencia,
      peligro: peligro,
      velo: velo,
      acentoSuave: suave(acento),
      exitoSuave: suave(exito),
      advertenciaSuave: suave(advertencia),
      peligroSuave: suave(peligro),
    );
  }

  static const double _opacidadSuave = 0.12;

  static Color _mezclar(Color frente, Color fondo, double opacidad) {
    return Color.alphaBlend(frente.withValues(alpha: opacidad), fondo);
  }

  static final PaletaColores claro = PaletaColores._base(
    fondo: const Color(0xFFF6F7F9),
    superficie: const Color(0xFFFFFFFF),
    superficieElevada: const Color(0xFFFFFFFF),
    superficieHundida: const Color(0xFFEEF0F3),
    borde: const Color(0xFFE3E6EB),
    texto: const Color(0xFF0B0D12),
    textoSecundario: const Color(0xFF5B6270),
    textoTerciario: const Color(0xFF8A909C),
    acento: const Color(0xFF2457F5),
    sobreAcento: const Color(0xFFFFFFFF),
    marca: const Color(0xFF1D3557),
    exito: const Color(0xFF117857),
    advertencia: const Color(0xFFA25608),
    peligro: const Color(0xFFC6291D),
    velo: const Color(0x7A0B0D12),
  );

  static final PaletaColores oscuro = PaletaColores._base(
    fondo: const Color(0xFF0A0B0E),
    superficie: const Color(0xFF14161B),
    superficieElevada: const Color(0xFF1C1F26),
    superficieHundida: const Color(0xFF07080A),
    borde: const Color(0xFF262A33),
    texto: const Color(0xFFF3F4F6),
    textoSecundario: const Color(0xFFA3A9B5),
    textoTerciario: const Color(0xFF6B7280),
    acento: const Color(0xFF5B8CFF),
    sobreAcento: const Color(0xFF0A0B0E),
    marca: const Color(0xFF8FB0DA),
    exito: const Color(0xFF34C38F),
    advertencia: const Color(0xFFF5A524),
    peligro: const Color(0xFFF97066),
    velo: const Color(0xA3000000),
  );

  final Color fondo;
  final Color superficie;
  final Color superficieElevada;
  final Color superficieHundida;
  final Color borde;
  final Color texto;
  final Color textoSecundario;
  final Color textoTerciario;
  final Color acento;
  final Color sobreAcento;
  final Color marca;
  final Color exito;
  final Color advertencia;
  final Color peligro;
  final Color velo;
  final Color acentoSuave;
  final Color exitoSuave;
  final Color advertenciaSuave;
  final Color peligroSuave;

  PaletaColores copyWith({
    Color? fondo,
    Color? superficie,
    Color? superficieElevada,
    Color? superficieHundida,
    Color? borde,
    Color? texto,
    Color? textoSecundario,
    Color? textoTerciario,
    Color? acento,
    Color? sobreAcento,
    Color? marca,
    Color? exito,
    Color? advertencia,
    Color? peligro,
    Color? velo,
    Color? acentoSuave,
    Color? exitoSuave,
    Color? advertenciaSuave,
    Color? peligroSuave,
  }) {
    return PaletaColores(
      fondo: fondo ?? this.fondo,
      superficie: superficie ?? this.superficie,
      superficieElevada: superficieElevada ?? this.superficieElevada,
      superficieHundida: superficieHundida ?? this.superficieHundida,
      borde: borde ?? this.borde,
      texto: texto ?? this.texto,
      textoSecundario: textoSecundario ?? this.textoSecundario,
      textoTerciario: textoTerciario ?? this.textoTerciario,
      acento: acento ?? this.acento,
      sobreAcento: sobreAcento ?? this.sobreAcento,
      marca: marca ?? this.marca,
      exito: exito ?? this.exito,
      advertencia: advertencia ?? this.advertencia,
      peligro: peligro ?? this.peligro,
      velo: velo ?? this.velo,
      acentoSuave: acentoSuave ?? this.acentoSuave,
      exitoSuave: exitoSuave ?? this.exitoSuave,
      advertenciaSuave: advertenciaSuave ?? this.advertenciaSuave,
      peligroSuave: peligroSuave ?? this.peligroSuave,
    );
  }

  PaletaColores lerp(PaletaColores otra, double t) {
    Color c(Color a, Color b) => Color.lerp(a, b, t)!;
    return PaletaColores(
      fondo: c(fondo, otra.fondo),
      superficie: c(superficie, otra.superficie),
      superficieElevada: c(superficieElevada, otra.superficieElevada),
      superficieHundida: c(superficieHundida, otra.superficieHundida),
      borde: c(borde, otra.borde),
      texto: c(texto, otra.texto),
      textoSecundario: c(textoSecundario, otra.textoSecundario),
      textoTerciario: c(textoTerciario, otra.textoTerciario),
      acento: c(acento, otra.acento),
      sobreAcento: c(sobreAcento, otra.sobreAcento),
      marca: c(marca, otra.marca),
      exito: c(exito, otra.exito),
      advertencia: c(advertencia, otra.advertencia),
      peligro: c(peligro, otra.peligro),
      velo: c(velo, otra.velo),
      acentoSuave: c(acentoSuave, otra.acentoSuave),
      exitoSuave: c(exitoSuave, otra.exitoSuave),
      advertenciaSuave: c(advertenciaSuave, otra.advertenciaSuave),
      peligroSuave: c(peligroSuave, otra.peligroSuave),
    );
  }
}
