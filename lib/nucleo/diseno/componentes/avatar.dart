import 'package:flutter/material.dart';

import '../tokens/tokens_pista.dart';

enum TamanoAvatar { chico, normal, grande }

/// Foto o iniciales de una persona.
///
/// Sin `imagen`, o si falla al cargar, muestra las iniciales de `nombre`. El
/// lector de pantalla dice el nombre completo.
class Avatar extends StatelessWidget {
  const Avatar({
    required this.nombre,
    super.key,
    this.imagen,
    this.tamano = TamanoAvatar.normal,
  });

  final String nombre;
  final ImageProvider? imagen;
  final TamanoAvatar tamano;

  /// Hasta dos letras: la primera de las dos primeras palabras.
  static String iniciales(String nombre) {
    final palabras = nombre
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .take(2);
    return palabras
        .map((p) => String.fromCharCode(p.runes.first))
        .join()
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = TokensPista.de(context);
    final c = tokens.colores;
    final diametro = switch (tamano) {
      TamanoAvatar.chico => 32.0,
      TamanoAvatar.normal => 40.0,
      TamanoAvatar.grande => 64.0,
    };
    final letra =
        (tamano == TamanoAvatar.grande
                ? tokens.tipografia.titulo3
                : tokens.tipografia.etiqueta)
            .copyWith(color: c.acento);

    final texto = Padding(
      padding: EdgeInsets.all(diametro / 8),
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(iniciales(nombre), style: letra, maxLines: 1),
        ),
      ),
    );

    return Semantics(
      image: true,
      label: nombre,
      excludeSemantics: true,
      child: SizedBox.square(
        dimension: diametro,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: c.acentoSuave,
            shape: BoxShape.circle,
          ),
          child: ClipOval(
            child: imagen == null
                ? texto
                : Image(
                    image: imagen!,
                    fit: BoxFit.cover,
                    width: diametro,
                    height: diametro,
                    errorBuilder: (_, _, _) => texto,
                  ),
          ),
        ),
      ),
    );
  }
}
