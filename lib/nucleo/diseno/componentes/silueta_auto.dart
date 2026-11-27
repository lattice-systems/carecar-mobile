import 'package:flutter/material.dart';

/// Silueta de un auto de perfil, dibujada con trazos (sin imágenes).
///
/// Sirve de ilustración cuando el vehículo aún no tiene foto. Respeta la
/// proporción 400 × 140; ocupa el ancho que le den.
class SiluetaAuto extends StatelessWidget {
  const SiluetaAuto({
    required this.carroceria,
    required this.cristal,
    required this.llanta,
    super.key,
  });

  /// Color de la carrocería.
  final Color carroceria;

  /// Color de las ventanas y los detalles oscuros.
  final Color cristal;

  /// Color de las llantas.
  final Color llanta;

  static const double _ancho = 400;
  static const double _alto = 140;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: AspectRatio(
      aspectRatio: _ancho / _alto,
      child: CustomPaint(
        painter: _PintorAuto(
          carroceria: carroceria,
          cristal: cristal,
          llanta: llanta,
        ),
      ),
    ),
  );
}

class _PintorAuto extends CustomPainter {
  const _PintorAuto({
    required this.carroceria,
    required this.cristal,
    required this.llanta,
  });

  final Color carroceria;
  final Color cristal;
  final Color llanta;

  static const _ruedaTrasera = Offset(94, 104);
  static const _ruedaDelantera = Offset(308, 104);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(
      size.width / SiluetaAuto._ancho,
      size.height / SiluetaAuto._alto,
    );

    // Sombra en el piso.
    canvas.drawOval(
      const Rect.fromLTWH(40, 120, 330, 14),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.22)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );

    // Carrocería: cajuela, techo curvo y cofre largo.
    final cuerpo = Path()
      ..moveTo(18, 106)
      ..lineTo(18, 86)
      ..cubicTo(18, 76, 38, 72, 68, 68)
      ..cubicTo(100, 64, 120, 40, 152, 30)
      ..cubicTo(186, 20, 236, 20, 264, 32)
      ..cubicTo(292, 44, 322, 62, 360, 70)
      ..cubicTo(380, 74, 386, 84, 386, 98)
      ..lineTo(386, 106)
      ..close();
    // Los arcos de las ruedas se recortan del cuerpo.
    var recortado = cuerpo;
    for (final rueda in [_ruedaTrasera, _ruedaDelantera]) {
      recortado = Path.combine(
        PathOperation.difference,
        recortado,
        Path()..addOval(Rect.fromCircle(center: rueda, radius: 34)),
      );
    }
    canvas.drawPath(recortado, Paint()..color = carroceria);

    // Ventanas: una trasera y una delantera, con la columna en medio.
    final ventanaTrasera = Path()
      ..moveTo(112, 64)
      ..cubicTo(128, 48, 146, 38, 164, 34)
      ..lineTo(198, 34)
      ..lineTo(198, 64)
      ..close();
    final ventanaDelantera = Path()
      ..moveTo(210, 34)
      ..cubicTo(236, 33, 256, 38, 272, 46)
      ..cubicTo(288, 54, 304, 60, 316, 64)
      ..lineTo(210, 64)
      ..close();
    final pintaCristal = Paint()..color = cristal;
    canvas
      ..drawPath(ventanaTrasera, pintaCristal)
      ..drawPath(ventanaDelantera, pintaCristal);

    // Línea de cintura y faros.
    final linea = Paint()
      ..color = cristal.withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    canvas
      ..drawLine(const Offset(40, 80), const Offset(66, 80), linea)
      ..drawLine(const Offset(130, 80), const Offset(264, 80), linea)
      ..drawLine(const Offset(350, 80), const Offset(372, 82), linea);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(354, 86, 28, 8),
        const Radius.circular(4),
      ),
      pintaCristal,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(18, 88, 12, 8),
        const Radius.circular(3),
      ),
      pintaCristal,
    );

    // Llantas con rin.
    for (final rueda in [_ruedaTrasera, _ruedaDelantera]) {
      canvas
        ..drawCircle(rueda, 27, Paint()..color = llanta)
        ..drawCircle(rueda, 15, Paint()..color = carroceria)
        ..drawCircle(rueda, 5, Paint()..color = llanta);
    }
  }

  @override
  bool shouldRepaint(_PintorAuto anterior) =>
      anterior.carroceria != carroceria ||
      anterior.cristal != cristal ||
      anterior.llanta != llanta;
}
