import 'package:flutter/material.dart';

import 'colores.dart';
import 'elevacion.dart';
import 'tipografia.dart';

/// Todos los tokens del sistema de diseno v2 «Pista» como extension del tema.
///
/// Los componentes la leen con `TokensPista.de(context)`.
@immutable
class TokensPista extends ThemeExtension<TokensPista> {
  const TokensPista({
    required this.brillo,
    required this.colores,
    required this.tipografia,
  });

  static final TokensPista claro = TokensPista(
    brillo: Brightness.light,
    colores: PaletaColores.claro,
    tipografia: Tipografia.crear(color: PaletaColores.claro.texto),
  );

  static final TokensPista oscuro = TokensPista(
    brillo: Brightness.dark,
    colores: PaletaColores.oscuro,
    tipografia: Tipografia.crear(color: PaletaColores.oscuro.texto),
  );

  final Brightness brillo;
  final PaletaColores colores;
  final Tipografia tipografia;

  List<BoxShadow> get sombras => Elevacion.sombras(brillo);

  Color superficieNivel(int nivel) {
    return Elevacion.superficie(colores, brillo, nivel: nivel);
  }

  static TokensPista de(BuildContext context) {
    final tokens = Theme.of(context).extension<TokensPista>();
    assert(
      tokens != null,
      'Falta TokensPista en el tema. Usa TemaPista.claro() o TemaPista.oscuro().',
    );
    return tokens!;
  }

  @override
  TokensPista copyWith({
    Brightness? brillo,
    PaletaColores? colores,
    Tipografia? tipografia,
  }) {
    return TokensPista(
      brillo: brillo ?? this.brillo,
      colores: colores ?? this.colores,
      tipografia: tipografia ?? this.tipografia,
    );
  }

  @override
  TokensPista lerp(ThemeExtension<TokensPista>? other, double t) {
    if (other is! TokensPista) return this;
    return TokensPista(
      brillo: t < 0.5 ? brillo : other.brillo,
      colores: colores.lerp(other.colores, t),
      tipografia: t < 0.5 ? tipografia : other.tipografia,
    );
  }
}
