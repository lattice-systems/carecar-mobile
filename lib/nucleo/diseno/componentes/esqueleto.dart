import 'package:flutter/material.dart';

import '../movimiento_contexto.dart';
import '../tokens/movimiento.dart';
import '../tokens/radios.dart';
import '../tokens/tokens_pista.dart';

/// Bloque gris que marca donde va a llegar contenido.
///
/// Late suavemente. Con "reducir movimiento" se queda quieto. No se anuncia al
/// lector de pantalla: quien lo use debe avisar "cargando" una sola vez en el
/// contenedor, no en cada bloque.
class Esqueleto extends StatefulWidget {
  const Esqueleto({
    super.key,
    this.ancho,
    this.alto = 16,
    this.radio = Radios.control,
  });

  /// Una linea de texto: ancho completo y alto de una linea.
  const Esqueleto.linea({super.key, this.ancho, this.alto = 14})
    : radio = Radios.control / 2;

  /// Un circulo, por ejemplo para un avatar.
  const Esqueleto.circulo({super.key, required double diametro})
    : ancho = diametro,
      alto = diametro,
      radio = Radios.pildora;

  final double? ancho;
  final double alto;
  final double radio;

  @override
  State<Esqueleto> createState() => _EsqueletoState();
}

class _EsqueletoState extends State<Esqueleto>
    with SingleTickerProviderStateMixin {
  late final AnimationController _latido = AnimationController(vsync: this);
  bool _arrancado = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reducir = MediaQuery.disableAnimationsOf(context);
    final duracion = context.movimiento(Movimiento.enfatico).duracion * 3;
    _latido.duration = duracion;
    if (reducir) {
      _latido.stop();
      _latido.value = 0;
      _arrancado = false;
    } else if (!_arrancado) {
      _arrancado = true;
      _latido.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _latido.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = TokensPista.de(context).colores;
    final curva = context.movimiento(Movimiento.base).curva;
    return ExcludeSemantics(
      child: AnimatedBuilder(
        animation: _latido,
        builder: (context, _) {
          final color = Color.lerp(
            c.superficieHundida,
            c.borde,
            curva.transform(_latido.value),
          )!;
          return Container(
            width: widget.ancho,
            height: widget.alto,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(widget.radio),
            ),
          );
        },
      ),
    );
  }
}
