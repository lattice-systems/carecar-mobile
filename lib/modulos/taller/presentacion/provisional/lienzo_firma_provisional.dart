// PROVISIONAL: se reemplaza por LienzoFirma del sistema de diseno
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../nucleo/diseno/tokens/radios.dart';
import '../../../../nucleo/diseno/tokens/tokens_pista.dart';

const _tinta = Color(0xFF111827);
const _grosor = 3.0;

/// Trazos de la firma que el cliente dibuja con el dedo.
class ControladorFirma extends ChangeNotifier {
  final List<List<Offset>> _trazos = [];

  List<List<Offset>> get trazos => [
    for (final trazo in _trazos) List.unmodifiable(trazo),
  ];

  bool get vacia => _trazos.every((trazo) => trazo.length < 2);

  void _empezar(Offset punto) {
    _trazos.add([punto]);
    notifyListeners();
  }

  void _seguir(Offset punto) {
    if (_trazos.isEmpty) return;
    _trazos.last.add(punto);
    notifyListeners();
  }

  void limpiar() {
    _trazos.clear();
    notifyListeners();
  }
}

/// Area blanca donde el cliente firma con el dedo. La tinta es oscura en claro
/// y en oscuro, como en la [Firma] del sistema.
class LienzoFirmaProvisional extends StatelessWidget {
  const LienzoFirmaProvisional({
    required this.controlador,
    super.key,
    this.alto = 180,
  });

  final ControladorFirma controlador;
  final double alto;

  static const area = Key('lienzo_firma');

  @override
  Widget build(BuildContext context) {
    final c = TokensPista.de(context).colores;
    return Semantics(
      label: AppLocalizations.of(context).tallerFirmaArea,
      child: Container(
        key: area,
        height: alto,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: Radios.bordeTarjeta,
          border: Border.all(color: c.contornoControl),
        ),
        child: ClipRRect(
          borderRadius: Radios.bordeTarjeta,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            dragStartBehavior: DragStartBehavior.down,
            onPanStart: (d) => controlador._empezar(d.localPosition),
            onPanUpdate: (d) => controlador._seguir(d.localPosition),
            child: ListenableBuilder(
              listenable: controlador,
              builder: (context, _) => CustomPaint(
                painter: _Trazos(controlador.trazos),
                size: Size.infinite,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Trazos extends CustomPainter {
  const _Trazos(this.trazos);

  final List<List<Offset>> trazos;

  @override
  void paint(Canvas canvas, Size size) => pintarTrazos(canvas, trazos);

  @override
  bool shouldRepaint(_Trazos anterior) => true;
}

void pintarTrazos(Canvas canvas, List<List<Offset>> trazos) {
  final pincel = Paint()
    ..color = _tinta
    ..strokeWidth = _grosor
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round
    ..style = PaintingStyle.stroke;
  for (final trazo in trazos) {
    if (trazo.length < 2) continue;
    final camino = Path()..moveTo(trazo.first.dx, trazo.first.dy);
    for (final punto in trazo.skip(1)) {
      camino.lineTo(punto.dx, punto.dy);
    }
    canvas.drawPath(camino, pincel);
  }
}

/// La firma como PNG sobre fondo blanco, del tamano del lienzo.
Future<Uint8List> exportarFirmaPng(
  List<List<Offset>> trazos,
  Size tamano,
) async {
  final grabadora = ui.PictureRecorder();
  final lienzo = Canvas(grabadora)
    ..drawRect(Offset.zero & tamano, Paint()..color = Colors.white);
  pintarTrazos(lienzo, trazos);
  final imagen = await grabadora.endRecording().toImage(
    tamano.width.ceil(),
    tamano.height.ceil(),
  );
  final datos = await imagen.toByteData(format: ui.ImageByteFormat.png);
  imagen.dispose();
  if (datos == null) throw StateError('No se pudo guardar la firma');
  return datos.buffer.asUint8List();
}
