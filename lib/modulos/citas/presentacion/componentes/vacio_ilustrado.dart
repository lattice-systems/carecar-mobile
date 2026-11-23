import 'package:flutter/material.dart';

import '../../../../nucleo/diseno/componentes/boton_pildora.dart';
import '../../../../nucleo/diseno/componentes/centrado_desplazable.dart';
import '../../../../nucleo/diseno/tokens/espaciado.dart';
import '../../../../nucleo/diseno/tokens/tokens_pista.dart';

/// Estado vacío con ilustración y una píldora de siguiente paso.
///
/// La ilustración son tres círculos concéntricos del acento con el icono al
/// centro: sin imágenes ni recursos externos. Con letra grande el contenido
/// se desplaza en vez de desbordar.
class VacioIlustrado extends StatelessWidget {
  const VacioIlustrado({
    required this.titulo,
    required this.icono,
    super.key,
    this.mensaje,
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

  static const double _lado = 168;

  @override
  Widget build(BuildContext context) {
    final tokens = TokensPista.de(context);
    final c = tokens.colores;
    final t = tokens.tipografia;

    Widget circulo(double lado, double opacidad) => Container(
      width: lado,
      height: lado,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: c.acento.withValues(alpha: opacidad),
      ),
    );

    return CentradoDesplazable(
      child: Padding(
        padding: const EdgeInsets.all(Espaciado.e6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ExcludeSemantics(
              child: SizedBox(
                width: _lado,
                height: _lado,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    circulo(_lado, 0.06),
                    circulo(_lado * 0.72, 0.10),
                    circulo(_lado * 0.46, 0.16),
                    Icon(icono, size: 40, color: c.acento),
                  ],
                ),
              ),
            ),
            const SizedBox(height: Espaciado.e6),
            Semantics(
              header: true,
              child: Text(
                titulo,
                textAlign: TextAlign.center,
                style: t.titulo2.copyWith(color: c.texto),
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
              const SizedBox(height: Espaciado.e6),
              BotonPildora(texto: textoAccion!, alPresionar: alAccion),
            ],
          ],
        ),
      ),
    );
  }
}
