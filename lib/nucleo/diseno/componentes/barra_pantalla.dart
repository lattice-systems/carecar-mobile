import 'package:flutter/material.dart';

import '../tokens/espaciado.dart';
import '../tokens/tokens_pista.dart';
import 'boton_regresar.dart';

/// Barra fija de una pantalla que no se desplaza como lista (visor de PDF,
/// mapa, pestañas): regreso a la izquierda, título con subtítulo en medio y las
/// `acciones` a la derecha.
///
/// Es la versión quieta de [EncabezadoGrande]: mismos botones, mismo margen y
/// misma tipografía del título recogido, así que al pasar de una pantalla a la
/// otra nada se mueve. Respeta la zona del reloj. Crece con la letra del
/// sistema (el título pasa a dos líneas) en vez de recortarse.
class BarraPantalla extends StatelessWidget {
  const BarraPantalla({
    required this.titulo,
    super.key,
    this.subtitulo,
    this.acciones = const [],
    this.conRegreso = true,
  });

  final String titulo;
  final String? subtitulo;

  /// Botones al final de la barra, cada uno con su zona táctil de 48.
  final List<Widget> acciones;

  /// Pone «Regresar» al inicio; casi siempre sí (es una pantalla de detalle).
  final bool conRegreso;

  @override
  Widget build(BuildContext context) {
    final tokens = TokensPista.de(context);
    final c = tokens.colores;
    final t = tokens.tipografia;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: c.fondo,
        border: Border(bottom: BorderSide(color: c.borde)),
      ),
      child: SafeArea(
        bottom: false,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: Espaciado.e14),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Espaciado.margenTelefono,
              vertical: Espaciado.e1,
            ),
            child: Row(
              children: [
                if (conRegreso) ...[
                  const BotonRegresar(),
                  const SizedBox(width: Espaciado.e3),
                ],
                Expanded(
                  child: Semantics(
                    header: true,
                    container: true,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          titulo,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: t.titulo3.copyWith(color: c.texto),
                        ),
                        if (subtitulo != null)
                          Text(
                            subtitulo!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: t.cuerpoChico.copyWith(
                              color: c.textoSecundario,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                for (var i = 0; i < acciones.length; i++) ...[
                  if (i == 0) const SizedBox(width: Espaciado.e3),
                  if (i > 0) const SizedBox(width: Espaciado.e2),
                  acciones[i],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
