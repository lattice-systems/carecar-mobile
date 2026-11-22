import 'package:flutter/painting.dart';

/// Escala tipografica del sistema de diseno v2.
///
/// El texto usa Geist y las cifras Geist Mono. Mientras las fuentes no esten
/// empaquetadas (V2-T02.02) se usan Inter y JetBrainsMono, que ya viven en
/// `assets/fonts`.
class Tipografia {
  const Tipografia._({
    required this.display,
    required this.titulo1,
    required this.titulo2,
    required this.titulo3,
    required this.cuerpo,
    required this.cuerpoFuerte,
    required this.cuerpoChico,
    required this.etiqueta,
    required this.micro,
    required this.cifra,
  });

  static const String familiaTexto = 'Geist';
  static const String familiaCifras = 'GeistMono';
  static const List<String> respaldoTexto = ['Inter'];
  static const List<String> respaldoCifras = ['JetBrainsMono'];

  factory Tipografia.crear({Color? color}) {
    TextStyle texto(
      double tamano,
      double interlineado,
      FontWeight peso,
      double tracking,
    ) {
      return TextStyle(
        fontFamily: familiaTexto,
        fontFamilyFallback: respaldoTexto,
        fontSize: tamano,
        height: interlineado / tamano,
        fontWeight: peso,
        letterSpacing: tamano * tracking,
        color: color,
      );
    }

    return Tipografia._(
      display: texto(40, 44, FontWeight.w600, -0.01),
      titulo1: texto(28, 34, FontWeight.w600, -0.005),
      titulo2: texto(22, 28, FontWeight.w600, 0),
      titulo3: texto(18, 24, FontWeight.w600, 0),
      cuerpo: texto(16, 24, FontWeight.w400, 0),
      cuerpoFuerte: texto(16, 24, FontWeight.w500, 0),
      cuerpoChico: texto(14, 20, FontWeight.w400, 0),
      etiqueta: texto(13, 16, FontWeight.w500, 0.002),
      micro: texto(11, 14, FontWeight.w600, 0.06),
      cifra: TextStyle(
        fontFamily: familiaCifras,
        fontFamilyFallback: respaldoCifras,
        fontSize: 32,
        height: 36 / 32,
        fontWeight: FontWeight.w500,
        letterSpacing: 32 * -0.02,
        fontFeatures: const [FontFeature.tabularFigures()],
        color: color,
      ),
    );
  }

  final TextStyle display;
  final TextStyle titulo1;
  final TextStyle titulo2;
  final TextStyle titulo3;
  final TextStyle cuerpo;
  final TextStyle cuerpoFuerte;
  final TextStyle cuerpoChico;
  final TextStyle etiqueta;

  /// Va en mayusculas, quien lo use debe aplicar `toUpperCase()` al texto.
  final TextStyle micro;
  final TextStyle cifra;

  List<TextStyle> get todos => [
    display,
    titulo1,
    titulo2,
    titulo3,
    cuerpo,
    cuerpoFuerte,
    cuerpoChico,
    etiqueta,
    micro,
    cifra,
  ];
}
