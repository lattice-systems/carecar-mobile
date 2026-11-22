import 'package:flutter/material.dart';

import '../movimiento_contexto.dart';
import '../tokens/espaciado.dart';
import '../tokens/movimiento.dart';
import '../tokens/radios.dart';
import '../tokens/tokens_pista.dart';

/// Opcion seleccionable, para filtros y elecciones cortas.
///
/// Con `alCambiar` nulo queda deshabilitado. Siempre deja una zona tactil de
/// al menos 48 de alto. Avisa "seleccionado" al lector de pantalla.
class ChipPista extends StatelessWidget {
  const ChipPista({
    required this.texto,
    required this.seleccionado,
    required this.alCambiar,
    super.key,
    this.icono,
  });

  final String texto;
  final bool seleccionado;
  final ValueChanged<bool>? alCambiar;
  final IconData? icono;

  static const double _alto = 36;
  static const double _zonaTactil = 48;
  static const double _tamanoIcono = 16;

  @override
  Widget build(BuildContext context) {
    final tokens = TokensPista.de(context);
    final c = tokens.colores;
    final habilitado = alCambiar != null;

    final fondo = seleccionado ? c.acentoSuave : c.superficie;
    final frente = !habilitado
        ? c.textoTerciario
        : (seleccionado ? c.acento : c.texto);
    final borde = seleccionado ? c.acento : c.borde;
    final letra = tokens.tipografia.etiqueta.copyWith(color: frente);

    return Semantics(
      button: true,
      selected: seleccionado,
      enabled: habilitado,
      label: texto,
      onTap: habilitado ? () => alCambiar!(!seleccionado) : null,
      excludeSemantics: true,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: _zonaTactil),
        child: Center(
          widthFactor: 1,
          child: AnimatedContainer(
            duration: context.movimiento(Movimiento.rapido).duracion,
            constraints: const BoxConstraints(minHeight: _alto),
            decoration: BoxDecoration(
              color: fondo,
              borderRadius: Radios.bordePildora,
              border: Border.all(color: borde),
            ),
            child: Material(
              type: MaterialType.transparency,
              child: InkWell(
                borderRadius: Radios.bordePildora,
                onTap: habilitado ? () => alCambiar!(!seleccionado) : null,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Espaciado.e3,
                    vertical: Espaciado.e2,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (seleccionado || icono != null) ...[
                        Icon(
                          seleccionado ? Icons.check : icono,
                          size: _tamanoIcono,
                          color: frente,
                        ),
                        const SizedBox(width: Espaciado.e1),
                      ],
                      Flexible(child: Text(texto, style: letra)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
