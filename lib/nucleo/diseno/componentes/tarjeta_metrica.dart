import 'package:flutter/material.dart';

import '../tokens/espaciado.dart';
import '../tokens/radios.dart';
import '../tokens/tokens_pista.dart';
import 'tono.dart';

/// Cifra grande con su etiqueta. Ejemplo: "12 400 km" y "Recorrido del mes".
///
/// La cifra usa la tipografia de cifras con numeros tabulares. `tono` colorea
/// la cifra y suma su icono, para que el estado no dependa solo del color. El
/// lector de pantalla recibe un solo texto: "etiqueta: cifra".
class TarjetaMetrica extends StatelessWidget {
  const TarjetaMetrica({
    required this.cifra,
    required this.etiqueta,
    super.key,
    this.tono,
    this.detalle,
  });

  final String cifra;
  final String etiqueta;
  final Tono? tono;

  /// Texto de apoyo bajo la etiqueta, por ejemplo "vs. mes anterior".
  final String? detalle;

  static const double _tamanoIcono = 18;

  @override
  Widget build(BuildContext context) {
    final tokens = TokensPista.de(context);
    final c = tokens.colores;
    final t = tokens.tipografia;
    final colores = tono == null ? null : ColoresTono.de(tono!, c);
    final colorCifra = colores?.frente ?? c.texto;

    return Semantics(
      container: true,
      label: detalle == null
          ? '$etiqueta: $cifra'
          : '$etiqueta: $cifra, $detalle',
      excludeSemantics: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: c.superficie,
          borderRadius: Radios.bordeTarjeta,
          border: Border.all(color: c.borde),
        ),
        child: Padding(
          padding: const EdgeInsets.all(Espaciado.e4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                etiqueta,
                style: t.etiqueta.copyWith(color: c.textoSecundario),
              ),
              const SizedBox(height: Espaciado.e2),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (colores != null) ...[
                    Icon(
                      colores.icono,
                      size: _tamanoIcono,
                      color: colores.frente,
                    ),
                    const SizedBox(width: Espaciado.e2),
                  ],
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        cifra,
                        maxLines: 1,
                        style: t.cifra.copyWith(color: colorCifra),
                      ),
                    ),
                  ),
                ],
              ),
              if (detalle != null) ...[
                const SizedBox(height: Espaciado.e1),
                Text(
                  detalle!,
                  style: t.cuerpoChico.copyWith(color: c.textoSecundario),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
