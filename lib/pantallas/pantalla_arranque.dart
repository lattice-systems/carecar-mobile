import 'dart:async';

import 'package:flutter/material.dart';

import '../nucleo/diseno/componentes/marca_carecar.dart';
import '../nucleo/diseno/tema_pista.dart';
import '../nucleo/diseno/tokens/tokens_pista.dart';
import '../widgets/espera_servidor.dart';

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
    this.alTerminar,
    this.duracionMinima = const Duration(milliseconds: 1200),
    super.key,
  });

  final bool listo;
  final WidgetBuilder siguiente;
  final VoidCallback? alTerminar;
  final Duration duracionMinima;

  static const logo = Key('arranque_logo');
  static const avisoServidorDespertando = Key('arranque_aviso_despertando');

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
  bool _notificada = false;

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
    if (_terminada) {
      final notificar = widget.alTerminar;
      if (!_notificada && notificar != null) {
        _notificada = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) notificar();
        });
      }
      return widget.siguiente(context);
    }
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

/// El telón: el azul de la marca, liso, con la doble C que se traza al
/// centro y la carga abajo (V2-T02.27). Lleva su propio tema Pista porque
/// aparece antes que el resto de la app.
class _Telon extends StatelessWidget {
  const _Telon();

  @override
  Widget build(BuildContext context) {
    final tema = MediaQuery.platformBrightnessOf(context) == Brightness.dark
        ? TemaPista.oscuro()
        : TemaPista.claro();
    return Theme(
      data: tema,
      child: Builder(
        builder: (context) {
          final c = TokensPista.de(context).colores;
          return Material(
            color: c.acento,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Center(child: _Marca(color: c.sobreAcento)),
                Positioned(
                  left: 56,
                  right: 56,
                  bottom: 64,
                  child: _Carga(color: c.sobreAcento),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Marca extends StatelessWidget {
  const _Marca({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    final t = TokensPista.de(context).tipografia;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        MarcaCareCar(
          tamano: 96,
          vertical: true,
          animar: true,
          color: color,
          llaveIcono: CortinaArranque.logo,
        ),
        const SizedBox(height: 6),
        Text(
          'de Agencia360',
          style: t.cuerpoChico.copyWith(color: color.withValues(alpha: 0.72)),
        ),
      ],
    );
  }
}

class _Carga extends StatefulWidget {
  const _Carga({required this.color});

  final Color color;

  @override
  State<_Carga> createState() => _CargaState();
}

class _CargaState extends State<_Carga> {
  Timer? _temporizador;
  bool _servidorTarda = false;

  @override
  void initState() {
    super.initState();
    _temporizador = Timer(umbralServidorDespertando, () {
      if (mounted) setState(() => _servidorTarda = true);
    });
  }

  @override
  void dispose() {
    _temporizador?.cancel();
    super.dispose();
  }

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
              backgroundColor: widget.color.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation(widget.color),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          _servidorTarda ? textoServidorDespertando : 'Cargando…',
          key: _servidorTarda ? CortinaArranque.avisoServidorDespertando : null,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: widget.color.withValues(alpha: 0.75),
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
