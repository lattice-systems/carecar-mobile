import 'package:flutter/material.dart';

import '../../../../nucleo/diseno/tokens/radios.dart';
import '../../../../nucleo/diseno/tokens/tokens_pista.dart';

/// Arte cuadrado del plan, tipo «portada de álbum»: cuadro redondeado con el
/// degradado del tinte y una llave de servicio al centro. Es decorativo; quien
/// lo usa le pone la descripción para el lector de pantalla.
class PortadaMantenimiento extends StatelessWidget {
  const PortadaMantenimiento({required this.tinte, super.key});

  final Color tinte;

  @override
  Widget build(BuildContext context) {
    final c = TokensPista.de(context).colores;
    return ExcludeSemantics(
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Radios.hoja),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [tinte, Color.lerp(tinte, c.fondo, 0.45)!],
          ),
        ),
        child: Center(
          child: FittedBox(
            fit: BoxFit.contain,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Icon(
                Icons.build_circle_outlined,
                size: 120,
                color: c.sobreAcento.withValues(alpha: 0.92),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
