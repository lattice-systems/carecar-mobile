import 'dart:async';

import 'package:flutter/material.dart';

import '../tema/tema_carecar.dart';
import '../widgets/logo_carecar.dart';

/// Cortina de arranque: telon con la marca que se abre sobre la pantalla
/// siguiente cuando termina la restauracion de sesion.
///
/// Mientras `listo` es falso se ve solo el telon. Cuando `listo` es verdadero
/// y paso `duracionMinima`, se construye `siguiente` por debajo y el telon sube
/// en ~600 ms. Con `duracionMinima` en cero (pruebas) o con animaciones
/// desactivadas en el sistema, el cambio es directo, sin cortina.
class CortinaArranque extends StatefulWidget {
  const CortinaArranque({
    required this.listo,
    required this.siguiente,
    this.duracionMinima = const Duration(milliseconds: 1200),
    super.key,
  });

  final bool listo;
  final WidgetBuilder siguiente;
  final Duration duracionMinima;

  static const logo = Key('arranque_logo');

  @override
  State<CortinaArranque> createState() => _CortinaArranqueState();
}

class _CortinaArranqueState extends State<CortinaArranque>
    with SingleTickerProviderStateMixin {
  late final AnimationController _apertura = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 600),
  );
  late final bool _conMinimo = widget.duracionMinima > Duration.zero;
  Timer? _temporizador;
  late bool _minimoCumplido = !_conMinimo;
  bool _terminada = false;
  bool _sinAnimar = false;

  @override
  void initState() {
    super.initState();
    if (_conMinimo) {
      _temporizador = Timer(widget.duracionMinima, () {
        if (!mounted) return;
        _minimoCumplido = true;
        _intentarAbrir();
      });
    }
    _apertura.addStatusListener((e) {
      if (e == AnimationStatus.completed && mounted) {
        setState(() => _terminada = true);
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sinAnimar = MediaQuery.disableAnimationsOf(context);
    _intentarAbrir();
  }

  @override
  void didUpdateWidget(covariant CortinaArranque oldWidget) {
    super.didUpdateWidget(oldWidget);
    _intentarAbrir();
  }

  void _intentarAbrir() {
    if (!widget.listo || !_minimoCumplido || _terminada) return;
    if (_apertura.isAnimating || _apertura.isCompleted) return;
    if (!_conMinimo || _sinAnimar) {
      _terminada = true;
      // Evita setState durante build: se aplica al terminar el cuadro.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() {});
      });
      return;
    }
    _apertura.forward();
    setState(() {});
  }

  @override
  void dispose() {
    _temporizador?.cancel();
    _apertura.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_terminada) return widget.siguiente(context);
    final abierta = widget.listo && _minimoCumplido;
    return Stack(
      fit: StackFit.expand,
      children: [
        if (abierta) widget.siguiente(context),
        AnimatedBuilder(
          animation: _apertura,
          builder: (context, hijo) {
            final alto = MediaQuery.sizeOf(context).height;
            final t = Curves.easeInOutCubic.transform(_apertura.value);
            return Transform.translate(
              offset: Offset(0, -alto * t),
              child: hijo,
            );
          },
          child: const _Telon(),
        ),
      ],
    );
  }
}

class _Telon extends StatelessWidget {
  const _Telon();

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [TemaCareCar.azulAgencia, TemaCareCar.azulProfundo],
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            const Positioned(top: -70, right: -60, child: _Destello(220)),
            const Positioned(bottom: -90, left: -80, child: _Destello(260)),
            Center(
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 900),
                curve: Curves.elasticOut,
                builder: (context, v, hijo) => Opacity(
                  opacity: v.clamp(0.0, 1.0),
                  child: Transform.scale(scale: 0.7 + 0.3 * v, child: hijo),
                ),
                child: const _Marca(),
              ),
            ),
            const Positioned(left: 56, right: 56, bottom: 64, child: _Carga()),
          ],
        ),
      ),
    );
  }
}

class _Destello extends StatelessWidget {
  const _Destello(this.tamano);
  final double tamano;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: tamano,
      height: tamano,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            TemaCareCar.turquesa.withValues(alpha: 0.22),
            TemaCareCar.turquesa.withValues(alpha: 0),
          ],
        ),
      ),
    );
  }
}

class _Marca extends StatelessWidget {
  const _Marca();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const LogoCareCar(
          tamano: 112,
          vertical: true,
          llaveIcono: CortinaArranque.logo,
        ),
        const SizedBox(height: 6),
        Text(
          'Posventa Agencia360',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.72),
            fontSize: 14,
            letterSpacing: 0.6,
          ),
        ),
      ],
    );
  }
}

class _Carga extends StatelessWidget {
  const _Carga();

  @override
  Widget build(BuildContext context) {
    // Barra indeterminada solo si el sistema permite movimiento continuo.
    final animar = !MediaQuery.disableAnimationsOf(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: SizedBox(
            height: 3,
            child: LinearProgressIndicator(
              value: animar ? null : 0.4,
              backgroundColor: Colors.white.withValues(alpha: 0.15),
              valueColor: const AlwaysStoppedAnimation(TemaCareCar.turquesa),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Cargando…',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
