import 'package:flutter/material.dart';

import '../tokens/espaciado.dart';
import '../tokens/radios.dart';
import '../tokens/tokens_pista.dart';
import 'tono.dart';

/// Etiqueta corta de estado, no interactiva. Ejemplo: "En proceso".
///
/// Con `conIcono` suma el icono del tono para no depender solo del color.
class Insignia extends StatelessWidget {
  const Insignia({
    required this.texto,
    super.key,
    this.tono = Tono.neutro,
    this.conIcono = false,
  });

  final String texto;
  final Tono tono;
  final bool conIcono;

  static const double _tamanoIcono = 14;

  @override
  Widget build(BuildContext context) {
    final tokens = TokensPista.de(context);
    final colores = ColoresTono.de(tono, tokens.colores);
    final letra = tokens.tipografia.etiqueta.copyWith(color: colores.frente);

    return Semantics(
      container: true,
      label: texto,
      excludeSemantics: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colores.fondo,
          borderRadius: Radios.bordePildora,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Espaciado.e2,
            vertical: Espaciado.e1,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (conIcono) ...[
                Icon(colores.icono, size: _tamanoIcono, color: colores.frente),
                const SizedBox(width: Espaciado.e1),
              ],
              Flexible(child: Text(texto, style: letra)),
            ],
          ),
        ),
      ),
    );
  }
}
