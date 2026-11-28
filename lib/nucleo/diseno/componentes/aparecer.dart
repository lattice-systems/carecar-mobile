import 'package:flutter/widgets.dart';

import '../tokens/movimiento.dart';

/// Sube un poco y aparece en el tramo [desde]–[hasta] de [entrada]
/// (V2-T02.27).
///
/// Para portadas (el saludo del inicio, la marca del acceso): varias piezas
/// comparten una misma [entrada] y cada una toma su tramo, así entran una
/// tras otra. Quien crea la animación decide si respeta «reducir movimiento»
/// (con él la deja en 1 y aquí no se mueve nada).
class Aparecer extends StatelessWidget {
  const Aparecer({
    required this.entrada,
    required this.child,
    this.desde = 0,
    this.hasta = 1,
    super.key,
  });

  final Animation<double> entrada;
  final double desde;
  final double hasta;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final tramo = CurvedAnimation(
      parent: entrada,
      curve: Interval(desde, hasta, curve: Movimiento.portada.curva),
    );
    return FadeTransition(
      opacity: tramo,
      child: SlideTransition(
        position: Tween(
          begin: const Offset(0, 0.4),
          end: Offset.zero,
        ).animate(tramo),
        child: child,
      ),
    );
  }
}
