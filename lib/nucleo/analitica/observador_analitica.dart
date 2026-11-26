import 'dart:async';
import 'dart:ui' show ErrorCallback, FrameTiming;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'analitica.dart';

class ObservadorAnalitica extends StatefulWidget {
  const ObservadorAnalitica({
    required this.analitica,
    required this.reloj,
    required this.construir,
    super.key,
  });

  final Analitica analitica;
  final Stopwatch reloj;
  final Widget Function(VoidCallback primeraPantalla) construir;

  @override
  State<ObservadorAnalitica> createState() => _ObservadorAnaliticaState();
}

class _ObservadorAnaliticaState extends State<ObservadorAnalitica> {
  final _ultimosErrores = <String, int>{};
  late final FlutterExceptionHandler? _flutterAnterior;
  late final ErrorCallback? _asincronoAnterior;
  late final FlutterExceptionHandler _flutter;
  late final ErrorCallback _asincrono;
  int? _revision;
  int? _arranque;
  int? _primeraPantalla;
  int _medidos = 0;
  int _perdidos = 0;
  double _hz = 60;
  Timer? _temporizador;

  @override
  void initState() {
    super.initState();
    if (kDebugMode) return;
    final binding = WidgetsBinding.instance;
    final dispatcher = binding.platformDispatcher;
    _flutterAnterior = FlutterError.onError;
    _asincronoAnterior = dispatcher.onError;
    _flutter = (error) {
      _registrarError('ERROR_FLUTTER');
      _flutterAnterior?.call(error);
    };
    _asincrono = (error, traza) {
      _registrarError('ERROR_ASINCRONO');
      return _asincronoAnterior?.call(error, traza) ?? false;
    };
    FlutterError.onError = _flutter;
    dispatcher.onError = _asincrono;

    if (widget.analitica.habilitada) {
      _revision = widget.analitica.revision;
      binding.addTimingsCallback(_medirCuadros);
      binding.addPostFrameCallback((_) {
        if (mounted && _revision != null)
          _arranque = widget.reloj.elapsedMilliseconds;
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _hz = View.of(context).display.refreshRate;
  }

  void _registrarError(String tipo) {
    if (!widget.analitica.habilitada) return;
    final ahora = widget.reloj.elapsedMilliseconds;
    final anterior = _ultimosErrores[tipo];
    if (anterior != null && ahora - anterior < 5000) return;
    _ultimosErrores[tipo] = ahora;
    unawaited(widget.analitica.registrar({'tipo': tipo}));
  }

  void _marcarPrimeraPantalla() {
    if (_revision == null || _primeraPantalla != null) return;
    _primeraPantalla = widget.reloj.elapsedMilliseconds;
    _temporizador = Timer(const Duration(seconds: 5), _finalizarMuestra);
  }

  void _medirCuadros(List<FrameTiming> cuadros) {
    if (!widget.analitica.habilitada ||
        widget.analitica.revision != _revision) {
      _detenerMedicion();
      return;
    }
    for (final cuadro in cuadros) {
      if (_medidos == 120) break;
      _medidos++;
      _perdidos += estimarCuadrosPerdidos(
        cuadro.buildDuration,
        cuadro.rasterDuration,
        _hz,
      );
    }
    if (_medidos == 120 && _primeraPantalla != null) _finalizarMuestra();
  }

  void _finalizarMuestra() {
    final permiso = _revision;
    _detenerMedicion();
    final arranque = _arranque;
    final primera = _primeraPantalla;
    if (arranque == null ||
        primera == null ||
        _medidos == 0 ||
        widget.analitica.revision != permiso)
      return;
    unawaited(
      widget.analitica.registrar({
        'tipo': 'RENDIMIENTO',
        'arranqueMs': arranque.clamp(0, 600000),
        'primeraPantallaMs': primera.clamp(0, 600000),
        'cuadrosMedidos': _medidos,
        'cuadrosPerdidos': _perdidos.clamp(0, 60000),
      }),
    );
  }

  void _detenerMedicion() {
    if (_revision != null)
      WidgetsBinding.instance.removeTimingsCallback(_medirCuadros);
    _revision = null;
    _temporizador?.cancel();
  }

  @override
  void dispose() {
    _detenerMedicion();
    if (!kDebugMode) {
      final dispatcher = WidgetsBinding.instance.platformDispatcher;
      if (FlutterError.onError == _flutter)
        FlutterError.onError = _flutterAnterior;
      if (dispatcher.onError == _asincrono)
        dispatcher.onError = _asincronoAnterior;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      widget.construir(_marcarPrimeraPantalla);
}
