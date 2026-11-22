import 'package:flutter/material.dart';

import '../tokens/radios.dart';
import '../tokens/tokens_pista.dart';
import 'galeria_fotos.dart';

/// Compara dos fotos con una barra que se arrastra: a la izquierda se ve el
/// antes y a la derecha el despues.
///
/// Para el lector de pantalla es un control deslizante que dice cuanto se ve
/// del antes, y se mueve de 10 en 10 por ciento con subir y bajar.
class ComparacionAntesDespues extends StatefulWidget {
  const ComparacionAntesDespues({
    required this.antes,
    required this.despues,
    super.key,
    this.alto = 220,
    this.inicial = 0.5,
  }) : assert(inicial >= 0 && inicial <= 1, 'inicial va de 0 a 1');

  final FotoGaleria antes;
  final FotoGaleria despues;
  final double alto;
  final double inicial;

  static const barra = Key('comparacion_barra');

  @override
  State<ComparacionAntesDespues> createState() =>
      _ComparacionAntesDespuesState();
}

class _ComparacionAntesDespuesState extends State<ComparacionAntesDespues> {
  static const double _paso = 0.1;
  static const double _zonaTactil = 48;

  late double _posicion = widget.inicial;

  void _mover(double p) => setState(() => _posicion = p.clamp(0, 1));

  @override
  Widget build(BuildContext context) {
    final c = TokensPista.de(context).colores;
    final porcentaje = (_posicion * 100).round();

    return Semantics(
      container: true,
      slider: true,
      label:
          'Comparacion. ${widget.antes.descripcion} contra '
          '${widget.despues.descripcion}',
      value: '$porcentaje % del antes',
      increasedValue: '${((_posicion + _paso).clamp(0, 1) * 100).round()} %',
      decreasedValue: '${((_posicion - _paso).clamp(0, 1) * 100).round()} %',
      onIncrease: () => _mover(_posicion + _paso),
      onDecrease: () => _mover(_posicion - _paso),
      excludeSemantics: true,
      child: ClipRRect(
        borderRadius: Radios.bordeTarjeta,
        child: SizedBox(
          height: widget.alto,
          child: LayoutBuilder(
            builder: (context, caja) {
              final ancho = caja.maxWidth;
              final x = ancho * _posicion;
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onHorizontalDragUpdate: (d) =>
                    _mover(_posicion + d.delta.dx / ancho),
                onTapDown: (d) => _mover(d.localPosition.dx / ancho),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image(image: widget.despues.imagen, fit: BoxFit.cover),
                    ClipRect(
                      clipper: _RecorteIzquierdo(x),
                      child: Image(
                        image: widget.antes.imagen,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      left: x - _zonaTactil / 2,
                      top: 0,
                      bottom: 0,
                      width: _zonaTactil,
                      child: Center(
                        key: ComparacionAntesDespues.barra,
                        child: Container(
                          width: 3,
                          color: c.superficie,
                          child: Align(
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: c.superficie,
                                shape: BoxShape.circle,
                                border: Border.all(color: c.borde),
                              ),
                              child: Icon(
                                Icons.unfold_more,
                                size: 18,
                                color: c.texto,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _RecorteIzquierdo extends CustomClipper<Rect> {
  const _RecorteIzquierdo(this.x);

  final double x;

  @override
  Rect getClip(Size size) => Rect.fromLTRB(0, 0, x, size.height);

  @override
  bool shouldReclip(_RecorteIzquierdo anterior) => anterior.x != x;
}
