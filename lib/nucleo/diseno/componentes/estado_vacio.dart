import 'package:flutter/material.dart';

import 'package:lucide_icons_flutter/lucide_icons_300.dart';

import '../tokens/espaciado.dart';
import '../tokens/tokens_pista.dart';
import 'boton.dart';
import 'centrado_desplazable.dart';

/// Pantalla o zona sin contenido todavia.
///
/// Explica por que esta vacio y, si hay una accion util, la ofrece. Nunca
/// debe quedar una pantalla en blanco.
class EstadoVacio extends StatelessWidget {
  const EstadoVacio({
    required this.titulo,
    super.key,
    this.mensaje,
    this.icono = LucideIcons300.inbox,
    this.textoAccion,
    this.alAccion,
  }) : assert(
         (textoAccion == null) == (alAccion == null),
         'textoAccion y alAccion van juntos',
       );

  final String titulo;
  final String? mensaje;
  final IconData icono;
  final String? textoAccion;
  final VoidCallback? alAccion;

  static const double _tamanoIcono = 48;

  @override
  Widget build(BuildContext context) {
    final tokens = TokensPista.de(context);
    final c = tokens.colores;
    final t = tokens.tipografia;

    return CentradoDesplazable(
      child: Padding(
        padding: const EdgeInsets.all(Espaciado.e6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ExcludeSemantics(
              child: Icon(icono, size: _tamanoIcono, color: c.textoSecundario),
            ),
            const SizedBox(height: Espaciado.e4),
            Semantics(
              header: true,
              child: Text(
                titulo,
                textAlign: TextAlign.center,
                style: t.titulo3.copyWith(color: c.texto),
              ),
            ),
            if (mensaje != null) ...[
              const SizedBox(height: Espaciado.e2),
              Text(
                mensaje!,
                textAlign: TextAlign.center,
                style: t.cuerpo.copyWith(color: c.textoSecundario),
              ),
            ],
            if (textoAccion != null) ...[
              const SizedBox(height: Espaciado.e5),
              Boton(
                texto: textoAccion!,
                alPresionar: alAccion,
                variante: VarianteBoton.secundario,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
