import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../tokens/movimiento.dart';

/// Envoltura interactiva con rebote elástico ultra-rápido estilo iOS / Telegram.
///
/// Al presionar, el widget se comprime de inmediato (por defecto al 97.5 %)
/// y genera una pulsación háptica ligera en equipos compatibles (Taptic Engine
/// en iPhone y hápticos en Android). Al soltar, regresa con amortiguación
/// suave sin oscilaciones lentas, logrando una sensación ágil y ligera.
///
/// Si se pasa `alPulsar`, gestiona el evento de toque de forma nativa e instantánea.
/// Respeta la preferencia de «reducir movimiento» del sistema: si está activa,
/// no escala y solo ejecuta la acción con el háptico.
class ReboteTactil extends StatefulWidget {
  const ReboteTactil({
    required this.child,
    this.alPulsar,
    this.escalaAlPresionar = 0.975,
    this.habilitado = true,
    this.activarHaptico = true,
    super.key,
  });

  final Widget child;
  final VoidCallback? alPulsar;
  final double escalaAlPresionar;
  final bool habilitado;
  final bool activarHaptico;

  @override
  State<ReboteTactil> createState() => _ReboteTactilState();
}

class _ReboteTactilState extends State<ReboteTactil>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controlador;
  late Animation<double> _animacion;

  @override
  void initState() {
    super.initState();
    _controlador = AnimationController(
      vsync: this,
      duration: Movimiento.toqueBajada.duracion,
      reverseDuration: Movimiento.toqueSubida.duracion,
    );
    _construirAnimacion();
  }

  void _construirAnimacion() {
    _animacion = Tween<double>(begin: 1.0, end: widget.escalaAlPresionar)
        .animate(
          CurvedAnimation(
            parent: _controlador,
            curve: Movimiento.toqueBajada.curva,
            reverseCurve: Movimiento.toqueSubida.curva,
          ),
        );
  }

  @override
  void didUpdateWidget(ReboteTactil anterior) {
    super.didUpdateWidget(anterior);
    if (anterior.escalaAlPresionar != widget.escalaAlPresionar) {
      _construirAnimacion();
    }
  }

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  void _alPresionarAbajo(PointerDownEvent _) {
    if (!widget.habilitado) return;
    if (widget.activarHaptico) {
      HapticFeedback.lightImpact();
    }
    _controlador.forward();
  }

  void _alPresionarArriba(PointerUpEvent _) {
    if (!widget.habilitado) return;
    _controlador.reverse();
  }

  void _alCancelar(PointerCancelEvent _) {
    if (!widget.habilitado) return;
    _controlador.reverse();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.habilitado) return widget.child;

    final reducir = MediaQuery.disableAnimationsOf(context);
    if (reducir) {
      if (widget.alPulsar != null) {
        return GestureDetector(
          onTap: () {
            if (widget.activarHaptico) HapticFeedback.lightImpact();
            widget.alPulsar?.call();
          },
          behavior: HitTestBehavior.opaque,
          child: widget.child,
        );
      }
      return widget.child;
    }

    Widget contenido = AnimatedBuilder(
      animation: _animacion,
      builder: (context, child) =>
          Transform.scale(scale: _animacion.value, child: child),
      child: widget.child,
    );

    if (widget.alPulsar != null) {
      contenido = GestureDetector(
        onTap: () {
          widget.alPulsar?.call();
        },
        behavior: HitTestBehavior.opaque,
        child: contenido,
      );
    }

    return Listener(
      onPointerDown: _alPresionarAbajo,
      onPointerUp: _alPresionarArriba,
      onPointerCancel: _alCancelar,
      behavior: HitTestBehavior.translucent,
      child: contenido,
    );
  }
}
