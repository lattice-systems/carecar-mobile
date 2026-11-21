import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Rebote al tocar: la tarjeta se hunde un poco y regresa con resorte.
///
/// Es el gesto «magnetico» de las animaciones tipo GSAP, sin tocar el ripple de
/// Material de lo que lleva dentro.
class Rebote extends StatefulWidget {
  const Rebote({required this.child, super.key});

  final Widget child;

  @override
  State<Rebote> createState() => _ReboteState();
}

class _ReboteState extends State<Rebote> {
  bool _abajo = false;

  void _mover(bool abajo) {
    if (_abajo == abajo) return;
    if (abajo) HapticFeedback.selectionClick();
    setState(() => _abajo = abajo);
  }

  @override
  Widget build(BuildContext context) => Listener(
    onPointerDown: (_) => _mover(true),
    onPointerUp: (_) => _mover(false),
    onPointerCancel: (_) => _mover(false),
    child: AnimatedScale(
      scale: _abajo ? 0.965 : 1,
      duration: Duration(milliseconds: _abajo ? 90 : 420),
      curve: _abajo ? Curves.easeOut : Curves.elasticOut,
      child: widget.child,
    ),
  );
}

/// Numero que cuenta desde cero hasta [valor] al aparecer.
class NumeroAnimado extends StatelessWidget {
  const NumeroAnimado({
    required this.valor,
    required this.construir,
    this.duracion = const Duration(milliseconds: 1100),
    super.key,
  });

  final int valor;
  final Duration duracion;
  final Widget Function(int) construir;

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween(begin: 0, end: valor.toDouble()),
    duration: duracion,
    curve: Curves.easeOutExpo,
    builder: (_, v, _) => construir(v.round()),
  );
}

/// Animaciones que nunca terminan (destellos, brillo de carga).
///
/// Se apagan cuando el sistema pide reducir el movimiento y en las pruebas
/// (`test/flutter_test_config.dart`), porque `pumpAndSettle` no termina con una
/// animacion infinita.
abstract final class Movimiento {
  static bool continuo = true;

  static bool permitido(BuildContext context) =>
      continuo && !MediaQuery.disableAnimationsOf(context);
}

extension MovimientoContinuo on Widget {
  /// Aplica [animar] solo si el movimiento continuo esta permitido; si no,
  /// devuelve el widget quieto.
  Widget siempre(BuildContext context, Widget Function(Widget) animar) =>
      Movimiento.permitido(context) ? animar(this) : this;
}
