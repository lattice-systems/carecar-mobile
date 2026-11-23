import 'package:flutter/foundation.dart' show precisionErrorTolerance;
import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../tokens/espaciado.dart';
import '../tokens/movimiento.dart';
import '../tokens/tokens_pista.dart';

/// Seccion con titulo grande, enlace "Ver todo" opcional y un carrusel
/// horizontal de tarjetas que se alinea a la tarjeta mas cercana al soltar.
///
/// Cada elemento de `hijos` recibe `anchoTarjeta` de ancho; el carrusel mide
/// `alto`, que debe dar cabida a la tarjeta con letra al 200 %. El titulo se
/// anuncia como encabezado y el enlace como "Ver todo: titulo".
class Estante extends StatelessWidget {
  const Estante({
    required this.titulo,
    required this.hijos,
    super.key,
    this.alVerTodo,
    this.anchoTarjeta = 160,
    this.alto = 200,
  });

  final String titulo;
  final List<Widget> hijos;
  final VoidCallback? alVerTodo;
  final double anchoTarjeta;
  final double alto;

  static const double _separacion = Espaciado.e3;

  @override
  Widget build(BuildContext context) {
    final tokens = TokensPista.de(context);
    final c = tokens.colores;
    final t = tokens.tipografia;
    final paso = anchoTarjeta + _separacion;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Espaciado.e4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Semantics(
                  header: true,
                  child: Text(
                    titulo,
                    style: t.titulo2.copyWith(color: c.texto),
                  ),
                ),
              ),
              if (alVerTodo != null)
                Semantics(
                  button: true,
                  label: AppLocalizations.of(context).estanteVerTodoDe(titulo),
                  onTap: alVerTodo,
                  excludeSemantics: true,
                  child: InkWell(
                    onTap: alVerTodo,
                    borderRadius: BorderRadius.circular(Espaciado.e2),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        minHeight: Espaciado.objetivoTactilMinimo,
                        minWidth: Espaciado.objetivoTactilMinimo,
                      ),
                      child: Center(
                        widthFactor: 1,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: Espaciado.e2,
                          ),
                          child: Text(
                            AppLocalizations.of(context).estanteVerTodo,
                            style: t.cuerpoFuerte.copyWith(color: c.acento),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: Espaciado.e3),
        SizedBox(
          height: alto,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: _FisicaImantada(paso: paso),
            padding: const EdgeInsets.symmetric(horizontal: Espaciado.e4),
            itemCount: hijos.length,
            separatorBuilder: (_, _) => const SizedBox(width: _separacion),
            itemBuilder: (_, i) =>
                SizedBox(width: anchoTarjeta, child: hijos[i]),
          ),
        ),
      ],
    );
  }
}

/// Al soltar, termina el desplazamiento exactamente en una tarjeta, con el
/// resorte del sistema de diseno.
class _FisicaImantada extends ScrollPhysics {
  const _FisicaImantada({required this.paso, super.parent});

  final double paso;

  @override
  _FisicaImantada applyTo(ScrollPhysics? ancestor) =>
      _FisicaImantada(paso: paso, parent: buildParent(ancestor));

  @override
  SpringDescription get spring => Movimiento.resorte;

  double _destino(ScrollMetrics m, double velocidad) {
    final actual = m.pixels / paso;
    var indice = velocidad > 0
        ? actual.ceilToDouble()
        : (velocidad < 0 ? actual.floorToDouble() : actual.roundToDouble());
    if (velocidad.abs() < toleranceFor(m).velocity) {
      indice = actual.roundToDouble();
    }
    return (indice * paso).clamp(m.minScrollExtent, m.maxScrollExtent);
  }

  @override
  Simulation? createBallisticSimulation(
    ScrollMetrics posicion,
    double velocidad,
  ) {
    if ((velocidad <= 0 && posicion.pixels <= posicion.minScrollExtent) ||
        (velocidad >= 0 && posicion.pixels >= posicion.maxScrollExtent)) {
      return super.createBallisticSimulation(posicion, velocidad);
    }
    final destino = _destino(posicion, velocidad);
    if ((destino - posicion.pixels).abs() < precisionErrorTolerance) {
      return null;
    }
    return ScrollSpringSimulation(
      spring,
      posicion.pixels,
      destino,
      velocidad,
      tolerance: toleranceFor(posicion),
    );
  }

  @override
  bool get allowImplicitScrolling => false;
}
