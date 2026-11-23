import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../tokens/espaciado.dart';
import '../tokens/radios.dart';
import '../tokens/tokens_pista.dart';

/// Firma de solo lectura, mostrada como imagen.
///
/// Sin `imagen` explica que aun no hay firma. El fondo es siempre claro para
/// que el trazo, que casi siempre es oscuro, se lea tambien en modo oscuro.
class Firma extends StatelessWidget {
  const Firma({
    required this.firmante,
    required this.imagen,
    super.key,
    this.fecha,
    this.alto = 120,
  });

  final String firmante;
  final ImageProvider? imagen;

  /// Texto ya formateado, por ejemplo "12 de noviembre de 2026".
  final String? fecha;
  final double alto;

  @override
  Widget build(BuildContext context) {
    final tokens = TokensPista.de(context);
    final c = tokens.colores;
    final t = tokens.tipografia;
    final pie = fecha == null ? firmante : '$firmante, $fecha';
    final textos = AppLocalizations.of(context);

    return Semantics(
      container: true,
      image: imagen != null,
      label: imagen == null
          ? textos.firmaSinFirma(firmante)
          : textos.firmaDe(pie),
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: alto,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: Radios.bordeTarjeta,
              border: Border.all(color: c.borde),
            ),
            padding: const EdgeInsets.all(Espaciado.e3),
            child: imagen == null
                ? Center(
                    child: Text(
                      textos.firmaAunSinFirma,
                      style: t.cuerpoChico.copyWith(
                        color: const Color(0xFF5B6270),
                      ),
                    ),
                  )
                : Image(
                    image: imagen!,
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) => const Icon(
                      Icons.broken_image_outlined,
                      color: Color(0xFF5B6270),
                    ),
                  ),
          ),
          const SizedBox(height: Espaciado.e2),
          Text(pie, style: t.etiqueta.copyWith(color: c.textoSecundario)),
        ],
      ),
    );
  }
}
