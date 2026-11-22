import 'package:flutter/material.dart';

import '../movimiento_contexto.dart';
import '../tokens/espaciado.dart';
import '../tokens/movimiento.dart';
import '../tokens/tokens_pista.dart';

/// Barra de pestanas del sistema de diseno v2.
///
/// Es controlada: quien la usa guarda `indice` y lo cambia en `alCambiar`. Cada
/// pestana mide al menos 48 de alto y avisa su posicion ("2 de 4") y si esta
/// seleccionada. Si no caben, se desplazan en horizontal.
class Pestanas extends StatelessWidget {
  const Pestanas({
    required this.etiquetas,
    required this.indice,
    required this.alCambiar,
    super.key,
  }) : assert(etiquetas.length > 0, 'Se necesita al menos una pestana');

  final List<String> etiquetas;
  final int indice;
  final ValueChanged<int> alCambiar;

  static const double _altoMinimo = 48;
  static const double _anchoIndicador = 3;

  @override
  Widget build(BuildContext context) {
    final tokens = TokensPista.de(context);
    final c = tokens.colores;

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: c.borde)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: IntrinsicHeight(
          child: Row(
            children: [
              for (var i = 0; i < etiquetas.length; i++)
                _Pestana(
                  texto: etiquetas[i],
                  posicion: i + 1,
                  total: etiquetas.length,
                  seleccionada: i == indice,
                  alToque: () => alCambiar(i),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Pestana extends StatelessWidget {
  const _Pestana({
    required this.texto,
    required this.posicion,
    required this.total,
    required this.seleccionada,
    required this.alToque,
  });

  final String texto;
  final int posicion;
  final int total;
  final bool seleccionada;
  final VoidCallback alToque;

  @override
  Widget build(BuildContext context) {
    final tokens = TokensPista.de(context);
    final c = tokens.colores;
    final t = tokens.tipografia;
    final movimiento = context.movimiento(Movimiento.base);

    return Semantics(
      button: true,
      selected: seleccionada,
      label: '$texto, $posicion de $total',
      excludeSemantics: true,
      onTap: alToque,
      child: InkWell(
        onTap: alToque,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: Pestanas._altoMinimo,
            minWidth: 72,
          ),
          child: AnimatedContainer(
            duration: movimiento.duracion,
            curve: movimiento.curva,
            padding: const EdgeInsets.symmetric(horizontal: Espaciado.e4),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: seleccionada ? c.acento : Colors.transparent,
                  width: Pestanas._anchoIndicador,
                ),
              ),
            ),
            child: Text(
              texto,
              style: (seleccionada ? t.cuerpoFuerte : t.cuerpo).copyWith(
                color: seleccionada ? c.acento : c.textoSecundario,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
