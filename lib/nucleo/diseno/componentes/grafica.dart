import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../movimiento_contexto.dart';
import '../tokens/espaciado.dart';
import '../tokens/movimiento.dart';
import '../tokens/radios.dart';
import '../tokens/tokens_pista.dart';
import 'boton.dart';

enum TipoGrafica { barras, lineas }

/// Un dato de una [Grafica]: la etiqueta del eje y su valor.
class PuntoGrafica {
  const PuntoGrafica({required this.etiqueta, required this.valor});

  final String etiqueta;
  final double valor;
}

/// Grafica de barras o lineas del sistema de diseno v2.
///
/// El dibujo no es legible para un lector de pantalla, asi que cada grafica
/// trae una tabla con los mismos datos. La tabla se muestra sola cuando hay un
/// lector activo, y cualquiera puede alternarla con el boton de abajo.
/// `formatoValor` da formato a las cifras de la tabla, por ejemplo con pesos.
class Grafica extends StatefulWidget {
  const Grafica({
    required this.titulo,
    required this.puntos,
    super.key,
    this.tipo = TipoGrafica.barras,
    this.formatoValor,
    this.mensajeVacio,
    this.alto = 180,
  });

  final String titulo;
  final List<PuntoGrafica> puntos;
  final TipoGrafica tipo;
  final String Function(double valor)? formatoValor;
  final String? mensajeVacio;
  final double alto;

  @override
  State<Grafica> createState() => _GraficaState();
}

class _GraficaState extends State<Grafica> {
  bool _verTabla = false;

  String _formato(double v) {
    final f = widget.formatoValor;
    if (f != null) return f(v);
    return v == v.roundToDouble() ? v.toInt().toString() : v.toString();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = TokensPista.de(context);
    final c = tokens.colores;
    final t = tokens.tipografia;
    final tablaAuto = MediaQuery.accessibleNavigationOf(context);
    final tabla = _verTabla || tablaAuto;
    final vacia = widget.puntos.isEmpty;

    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: widget.titulo,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            header: true,
            child: Text(
              widget.titulo,
              style: t.cuerpoFuerte.copyWith(color: c.texto),
            ),
          ),
          const SizedBox(height: Espaciado.e3),
          if (vacia)
            Text(
              widget.mensajeVacio ??
                  AppLocalizations.of(context).graficaSinDatos,
              style: t.cuerpoChico.copyWith(color: c.textoSecundario),
            )
          else if (tabla)
            _Tabla(puntos: widget.puntos, formato: _formato)
          else
            ExcludeSemantics(child: _Dibujo(grafica: widget)),
          if (!vacia && !tablaAuto) ...[
            const SizedBox(height: Espaciado.e2),
            Align(
              alignment: Alignment.centerLeft,
              child: Boton(
                texto: _verTabla
                    ? AppLocalizations.of(context).graficaVerGrafica
                    : AppLocalizations.of(context).graficaVerTabla,
                variante: VarianteBoton.terciario,
                tamano: TamanoBoton.chico,
                alPresionar: () => setState(() => _verTabla = !_verTabla),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Tabla extends StatelessWidget {
  const _Tabla({required this.puntos, required this.formato});

  final List<PuntoGrafica> puntos;
  final String Function(double) formato;

  @override
  Widget build(BuildContext context) {
    final tokens = TokensPista.de(context);
    final c = tokens.colores;
    final t = tokens.tipografia;

    return Column(
      children: [
        for (final p in puntos)
          Semantics(
            container: true,
            label: AppLocalizations.of(context)
                .graficaPunto(p.etiqueta, formato(p.valor)),
            excludeSemantics: true,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 48),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: c.borde)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        p.etiqueta,
                        style: t.cuerpo.copyWith(color: c.texto),
                      ),
                    ),
                    const SizedBox(width: Espaciado.e3),
                    Text(
                      formato(p.valor),
                      style: t.cuerpoFuerte.copyWith(color: c.texto),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _Dibujo extends StatelessWidget {
  const _Dibujo({required this.grafica});

  final Grafica grafica;

  @override
  Widget build(BuildContext context) {
    final tokens = TokensPista.de(context);
    final c = tokens.colores;
    final t = tokens.tipografia;
    final movimiento = context.movimiento(Movimiento.enfatico);

    return Column(
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: movimiento.duracion,
          curve: movimiento.curva,
          builder: (context, avance, _) => SizedBox(
            height: grafica.alto,
            width: double.infinity,
            child: CustomPaint(
              painter: _Pintor(
                puntos: grafica.puntos,
                tipo: grafica.tipo,
                avance: avance,
                colorSerie: c.acento,
                colorRejilla: c.borde,
              ),
            ),
          ),
        ),
        const SizedBox(height: Espaciado.e2),
        Row(
          children: [
            for (final p in grafica.puntos)
              Expanded(
                child: Text(
                  p.etiqueta,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: t.etiqueta.copyWith(color: c.textoSecundario),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _Pintor extends CustomPainter {
  _Pintor({
    required this.puntos,
    required this.tipo,
    required this.avance,
    required this.colorSerie,
    required this.colorRejilla,
  });

  final List<PuntoGrafica> puntos;
  final TipoGrafica tipo;
  final double avance;
  final Color colorSerie;
  final Color colorRejilla;

  static const int _lineasRejilla = 3;
  static const double _radioPunto = 4;

  @override
  void paint(Canvas canvas, Size size) {
    var minimo = 0.0;
    var maximo = 0.0;
    for (final p in puntos) {
      if (p.valor < minimo) minimo = p.valor;
      if (p.valor > maximo) maximo = p.valor;
    }
    if (maximo == minimo) maximo = minimo + 1;
    final rango = maximo - minimo;

    double y(double valor) =>
        size.height - ((valor - minimo) / rango) * size.height;

    final rejilla = Paint()
      ..color = colorRejilla
      ..strokeWidth = 1;
    for (var i = 0; i <= _lineasRejilla; i++) {
      final yy = size.height * i / _lineasRejilla;
      canvas.drawLine(Offset(0, yy), Offset(size.width, yy), rejilla);
    }

    final ancho = size.width / puntos.length;
    final cero = y(0);
    final trazo = Paint()..color = colorSerie;

    if (tipo == TipoGrafica.barras) {
      final barra = ancho * 0.6;
      for (var i = 0; i < puntos.length; i++) {
        final x = ancho * i + (ancho - barra) / 2;
        final destino = y(puntos[i].valor);
        final arriba = cero + (destino - cero) * avance;
        canvas.drawRRect(
          RRect.fromLTRBAndCorners(
            x,
            arriba < cero ? arriba : cero,
            x + barra,
            arriba < cero ? cero : arriba,
            topLeft: const Radius.circular(Radios.control / 2),
            topRight: const Radius.circular(Radios.control / 2),
          ),
          trazo,
        );
      }
      return;
    }

    trazo
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final camino = Path();
    final centros = <Offset>[];
    for (var i = 0; i < puntos.length; i++) {
      final x = ancho * i + ancho / 2;
      final yy = cero + (y(puntos[i].valor) - cero) * avance;
      centros.add(Offset(x, yy));
      if (i == 0) {
        camino.moveTo(x, yy);
      } else {
        camino.lineTo(x, yy);
      }
    }
    canvas.drawPath(camino, trazo);
    final relleno = Paint()..color = colorSerie;
    for (final centro in centros) {
      canvas.drawCircle(centro, _radioPunto, relleno);
    }
  }

  @override
  bool shouldRepaint(_Pintor anterior) =>
      anterior.puntos != puntos ||
      anterior.tipo != tipo ||
      anterior.avance != avance ||
      anterior.colorSerie != colorSerie ||
      anterior.colorRejilla != colorRejilla;
}
