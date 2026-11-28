import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../tokens/espaciado.dart';
import '../tokens/movimiento.dart';
import '../tokens/tokens_pista.dart';

/// La marca de la app: la doble C (Care + Car) en un cuadro del color de
/// acento y el nombre «CareCar» (V2-T02.27).
///
/// Va en el acceso, el inicio y la pantalla de carga. [tamano] es el lado del
/// ícono; el nombre se escala con él. Con [vertical] el nombre va debajo del
/// ícono (pantalla de carga). Con [animar] las dos C se trazan al aparecer:
/// primero la de fuera y luego la de dentro; con «reducir movimiento» ya
/// salen completas.
///
/// El ícono se dibuja en código (no es una imagen) para poder trazarlo; la
/// misma figura está en `assets/marca/carecar-icono.svg` para el ícono de la
/// app. Para el lector de pantalla es un solo texto, «CareCar».
class MarcaCareCar extends StatefulWidget {
  const MarcaCareCar({
    this.tamano = 32,
    this.color,
    this.vertical = false,
    this.animar = false,
    this.llaveIcono,
    super.key,
  });

  final double tamano;

  /// Color del nombre; por omisión, el de texto del tema.
  final Color? color;
  final bool vertical;
  final bool animar;
  final Key? llaveIcono;

  static const nombre = 'CareCar';

  @override
  State<MarcaCareCar> createState() => _MarcaCareCarState();
}

class _MarcaCareCarState extends State<MarcaCareCar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _trazo = AnimationController(
    vsync: this,
    duration: Movimiento.portada.duracion,
    value: widget.animar ? 0 : 1,
  );
  bool _iniciada = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_iniciada || !widget.animar) return;
    _iniciada = true;
    if (MediaQuery.disableAnimationsOf(context)) {
      _trazo.value = 1;
    } else {
      _trazo.forward();
    }
  }

  @override
  void dispose() {
    _trazo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = TokensPista.de(context);
    final tamano = widget.tamano;
    final icono = SizedBox.square(
      key: widget.llaveIcono,
      dimension: tamano,
      child: AnimatedBuilder(
        animation: _trazo,
        builder: (context, _) => CustomPaint(
          painter: PintorDobleC(
            fondo: tokens.colores.acento,
            trazo: _trazo.value,
          ),
        ),
      ),
    );
    final estilo = tamano > 64
        ? tokens.tipografia.titulo1
        : tamano > 32
        ? tokens.tipografia.titulo2
        : tokens.tipografia.titulo3;
    // El nombre es parte de la marca, como una imagen: no crece con la letra
    // grande del sistema (con 200 % ya no cabía junto al botón del perfil).
    final texto = MediaQuery.withNoTextScaling(
      child: Text(
        MarcaCareCar.nombre,
        style: estilo.copyWith(color: widget.color ?? tokens.colores.texto),
      ),
    );
    return Semantics(
      label: MarcaCareCar.nombre,
      excludeSemantics: true,
      child: widget.vertical
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                icono,
                const SizedBox(height: Espaciado.e4),
                texto,
              ],
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                icono,
                SizedBox(width: math.max(Espaciado.e2, tamano * 0.3)),
                texto,
              ],
            ),
    );
  }
}

/// La doble C sobre un cuadro redondeado, en una caja de 512 × 512 como el
/// SVG. [trazo] va de 0 (nada) a 1 (completa): la C de fuera ocupa el primer
/// 70 % del recorrido y la de dentro empieza a la mitad.
class PintorDobleC extends CustomPainter {
  PintorDobleC({required this.fondo, this.trazo = 1});

  final Color fondo;
  final double trazo;

  // Las C abren hacia la derecha: empiezan arriba a la derecha y giran en
  // contra de las manecillas hasta abajo a la derecha.
  static const _inicioFuera = -42.4 * math.pi / 180;
  static const _barridoFuera = -275.2 * math.pi / 180;
  static const _inicioDentro = -44.0 * math.pi / 180;
  static const _barridoDentro = -272.0 * math.pi / 180;

  @override
  void paint(Canvas canvas, Size size) {
    final k = size.width / 512;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(112 * k)),
      Paint()..color = fondo,
    );
    final centro = Offset(256 * k, 256 * k);
    final pincel = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 40 * k
      ..strokeCap = StrokeCap.round;

    final fuera = Movimiento.curvaDeTrazo.transform(
      (trazo / 0.7).clamp(0.0, 1.0),
    );
    final dentro = Movimiento.curvaDeTrazo.transform(
      ((trazo - 0.5) / 0.5).clamp(0.0, 1.0),
    );
    if (fuera > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: centro, radius: 150 * k),
        _inicioFuera,
        _barridoFuera * fuera,
        false,
        pincel..color = Colors.white,
      );
    }
    if (dentro > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: centro, radius: 86 * k),
        _inicioDentro,
        _barridoDentro * dentro,
        false,
        pincel..color = Colors.white.withValues(alpha: 0.55),
      );
    }
  }

  @override
  bool shouldRepaint(PintorDobleC anterior) =>
      anterior.trazo != trazo || anterior.fondo != fondo;
}
