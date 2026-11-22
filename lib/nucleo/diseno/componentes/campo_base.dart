import 'package:flutter/material.dart';

import '../tokens/espaciado.dart';
import '../tokens/radios.dart';
import '../tokens/tokens_pista.dart';

/// Envoltura comun de campo y selector: etiqueta siempre visible arriba, el
/// control, y debajo la ayuda o el error.
///
/// El error reemplaza a la ayuda y lleva icono, para no depender solo del
/// color. Se anuncia como region viva.
class CampoBase extends StatelessWidget {
  const CampoBase({
    required this.etiqueta,
    required this.hijo,
    super.key,
    this.ayuda,
    this.error,
    this.habilitado = true,
  });

  final String etiqueta;
  final Widget hijo;
  final String? ayuda;
  final String? error;
  final bool habilitado;

  static const double _tamanoIcono = 16;

  /// Decoracion de borde compartida por campo y selector.
  static InputDecoration decoracion(
    BuildContext context, {
    String? sugerencia,
    bool conError = false,
    Widget? sufijo,
  }) {
    final tokens = TokensPista.de(context);
    final c = tokens.colores;
    OutlineInputBorder borde(Color color, double ancho) => OutlineInputBorder(
      borderRadius: Radios.bordeControl,
      borderSide: BorderSide(color: color, width: ancho),
    );
    return InputDecoration(
      hintText: sugerencia,
      hintStyle: tokens.tipografia.cuerpo.copyWith(color: c.textoTerciario),
      suffixIcon: sufijo,
      filled: true,
      fillColor: c.superficie,
      isDense: false,
      constraints: const BoxConstraints(minHeight: 48),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: Espaciado.e4,
        vertical: Espaciado.e3,
      ),
      enabledBorder: borde(conError ? c.peligro : c.borde, conError ? 2 : 1),
      focusedBorder: borde(conError ? c.peligro : c.acento, 2),
      disabledBorder: borde(c.borde, 1),
      errorBorder: borde(c.peligro, 2),
      focusedErrorBorder: borde(c.peligro, 2),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = TokensPista.de(context);
    final c = tokens.colores;
    final t = tokens.tipografia;
    final colorEtiqueta = habilitado ? c.texto : c.textoTerciario;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(etiqueta, style: t.etiqueta.copyWith(color: colorEtiqueta)),
        const SizedBox(height: Espaciado.e2),
        hijo,
        if (error != null) ...[
          const SizedBox(height: Espaciado.e2),
          Semantics(
            liveRegion: true,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.error_outline, size: _tamanoIcono, color: c.peligro),
                const SizedBox(width: Espaciado.e1),
                Expanded(
                  child: Text(
                    error!,
                    style: t.cuerpoChico.copyWith(color: c.peligro),
                  ),
                ),
              ],
            ),
          ),
        ] else if (ayuda != null) ...[
          const SizedBox(height: Espaciado.e2),
          Text(ayuda!, style: t.cuerpoChico.copyWith(color: c.textoSecundario)),
        ],
      ],
    );
  }
}
