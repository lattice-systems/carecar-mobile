import 'package:flutter/material.dart';

import '../../../nucleo/diseno/componentes/silueta_auto.dart';
import '../../../nucleo/diseno/tokens/colores.dart';
import '../../../nucleo/diseno/tokens/espaciado.dart';
import '../../../nucleo/diseno/tokens/tokens_pista.dart';
import '../dominio/valuacion.dart';

/// La silueta de una toma guiada (V2-M26.02): como debe verse la foto antes
/// de abrir la camara del sistema. Es una ilustracion de este dominio, no un
/// componente del sistema de diseno. Los laterales reutilizan [SiluetaAuto];
/// el izquierdo va en espejo. Es decorativa: la instruccion lo dice en texto.
class SiluetaToma extends StatelessWidget {
  const SiluetaToma({required this.toma, super.key});

  final TomaValuacion toma;

  // El lienzo de los trazos propios, con la proporcion de [SiluetaAuto].
  static const _lienzo = Size(400, 140);

  @override
  Widget build(BuildContext context) {
    final c = TokensPista.de(context).colores;

    final lateral = SiluetaAuto(
      carroceria: c.textoSecundario,
      cristal: c.superficieHundida,
      llanta: c.texto,
    );

    return ExcludeSemantics(
      child: switch (toma) {
        TomaValuacion.lateralDerecho => lateral,
        TomaValuacion.lateralIzquierdo => Transform.flip(
          flipX: true,
          child: lateral,
        ),
        _ => AspectRatio(
          aspectRatio: _lienzo.width / _lienzo.height,
          child: CustomPaint(painter: _PintorToma(toma, c)),
        ),
      },
    );
  }
}

class _PintorToma extends CustomPainter {
  const _PintorToma(this.toma, this.colores);

  final TomaValuacion toma;
  final PaletaColores colores;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(
      size.width / SiluetaToma._lienzo.width,
      size.height / SiluetaToma._lienzo.height,
    );
    final trazo = Paint()
      ..color = colores.textoSecundario
      ..style = PaintingStyle.stroke
      ..strokeWidth = Espaciado.e1
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    void caja(double x, double y, double ancho, double alto, double radio) =>
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(x, y, ancho, alto),
            Radius.circular(radio),
          ),
          trazo,
        );
    void linea(double x1, double y1, double x2, double y2) =>
        canvas.drawLine(Offset(x1, y1), Offset(x2, y2), trazo);

    switch (toma) {
      case TomaValuacion.frente || TomaValuacion.trasera:
        // Cabina, carroceria y llantas vistas de frente.
        canvas.drawPath(
          Path()
            ..moveTo(130, 62)
            ..lineTo(152, 22)
            ..lineTo(248, 22)
            ..lineTo(270, 62),
          trazo,
        );
        caja(108, 62, 184, 54, 16);
        caja(118, 116, 34, 16, 6);
        caja(248, 116, 34, 16, 6);
        // Placa.
        caja(172, 94, 56, 14, 3);
        if (toma == TomaValuacion.frente) {
          // Faros redondos y parrilla.
          canvas
            ..drawCircle(const Offset(134, 82), 10, trazo)
            ..drawCircle(const Offset(266, 82), 10, trazo);
          caja(168, 72, 64, 14, 6);
        } else {
          // Calaveras alargadas y la tapa de la cajuela.
          caja(116, 74, 34, 14, 4);
          caja(250, 74, 34, 14, 4);
          linea(160, 68, 240, 68);
        }
      case TomaValuacion.interiorDelantero:
        // Dos asientos y el volante.
        caja(86, 18, 80, 74, 20);
        caja(80, 96, 92, 26, 10);
        caja(234, 18, 80, 74, 20);
        caja(228, 96, 92, 26, 10);
        canvas
          ..drawCircle(const Offset(126, 86), 30, trazo)
          ..drawCircle(const Offset(126, 86), 8, trazo);
      case TomaValuacion.interiorTrasero:
        // La banca corrida con tres respaldos.
        caja(70, 24, 78, 70, 18);
        caja(161, 24, 78, 70, 18);
        caja(252, 24, 78, 70, 18);
        caja(60, 98, 280, 28, 12);
      case TomaValuacion.tableroKm:
        // Dos relojes y el odometro en medio.
        canvas
          ..drawCircle(const Offset(110, 70), 48, trazo)
          ..drawCircle(const Offset(290, 70), 48, trazo);
        linea(110, 70, 138, 44);
        linea(290, 70, 264, 50);
        caja(172, 56, 56, 28, 6);
      case TomaValuacion.cajuela:
        // La tapa abierta y el hueco de carga.
        canvas.drawPath(
          Path()
            ..moveTo(96, 58)
            ..lineTo(124, 14)
            ..lineTo(276, 14)
            ..lineTo(304, 58),
          trazo,
        );
        caja(84, 58, 232, 70, 14);
        linea(112, 82, 288, 82);
      case TomaValuacion.lateralIzquierdo || TomaValuacion.lateralDerecho:
        break;
    }
  }

  @override
  bool shouldRepaint(_PintorToma anterior) =>
      anterior.toma != toma || anterior.colores != colores;
}
