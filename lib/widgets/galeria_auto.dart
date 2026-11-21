import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../tema/tema_carecar.dart';
import 'foto_auto.dart';
import 'movimiento.dart';

/// Rutas de las fotos extra de un modelo (`assets/autos/galeria/<clave>_n.jpg`).
///
/// Si el manifiesto no se puede leer (pruebas), devuelve lista vacia.
Future<List<String>> fotosDeGaleria(String? modelo) async {
  final clave = claveDeModelo(modelo);
  if (clave == null) return const [];
  try {
    final manifiesto = await AssetManifest.loadFromAssetBundle(rootBundle);
    final rutas =
        manifiesto
            .listAssets()
            .where(
              (a) =>
                  a.startsWith('assets/autos/galeria/${clave}_') &&
                  a.endsWith('.jpg'),
            )
            .toList()
          ..sort();
    return rutas;
  } catch (_) {
    return const [];
  }
}

/// Galeria de un modelo: foto principal + fotos de otros angulos, con flechas,
/// deslizar con el dedo y vista a pantalla completa con zoom.
class GaleriaAuto extends StatefulWidget {
  const GaleriaAuto({
    required this.modelo,
    required this.alto,
    this.url,
    this.radio = 16,
    this.extras,
    super.key,
  });

  /// Fotos extra ya conocidas (pruebas); si es null se leen del manifiesto.
  final List<String>? extras;
  final String? modelo;
  final String? url;
  final double alto;
  final double radio;

  static const flechaSiguiente = Key('galeria_siguiente');
  static const flechaAnterior = Key('galeria_anterior');
  static const contador = Key('galeria_contador');

  @override
  State<GaleriaAuto> createState() => _GaleriaAutoState();
}

class _GaleriaAutoState extends State<GaleriaAuto> {
  final _controlador = PageController();
  List<String> _extras = const [];
  int _actual = 0;

  int get _total => 1 + _extras.length;

  @override
  void initState() {
    super.initState();
    if (widget.extras != null) {
      _extras = widget.extras!;
      return;
    }
    fotosDeGaleria(widget.modelo).then((r) {
      if (mounted && r.isNotEmpty) setState(() => _extras = r);
    });
  }

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  ImageProvider? _proveedor(int i) {
    if (i == 0) {
      final f = fotoDeModelo(widget.modelo);
      if (f != null) return AssetImage(f);
      return widget.url != null ? NetworkImage(widget.url!) : null;
    }
    return AssetImage(_extras[i - 1]);
  }

  void _precargar(int i) {
    if (i < 0 || i >= _total) return;
    final p = _proveedor(i);
    if (p != null) precacheImage(p, context, onError: (_, _) {});
  }

  void _ir(int i) {
    if (i < 0 || i >= _total) return;
    _precargar(i);
    if (Movimiento.permitido(context)) {
      _controlador.animateToPage(
        i,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    } else {
      _controlador.jumpToPage(i);
    }
  }

  Widget _foto(int i, {BoxFit ajuste = BoxFit.cover}) {
    final p = _proveedor(i);
    if (p == null) {
      return Container(
        key: FotoAuto.marcador,
        color: TemaCareCar.azulSuave,
        child: const Icon(
          Icons.directions_car_outlined,
          size: 56,
          color: TemaCareCar.azulAgencia,
        ),
      );
    }
    return Image(
      image: p,
      fit: ajuste,
      width: double.infinity,
      height: double.infinity,
      gaplessPlayback: true,
      semanticLabel: 'Foto ${i + 1} de $_total de ${widget.modelo}',
      errorBuilder: (_, _, _) => Container(color: TemaCareCar.azulSuave),
    );
  }

  Future<void> _abrirCompleta() async {
    final nueva = await Navigator.of(context).push<int>(
      PageRouteBuilder<int>(
        opaque: false,
        barrierColor: Colors.black,
        transitionsBuilder: (_, a, _, hijo) =>
            FadeTransition(opacity: a, child: hijo),
        pageBuilder: (_, _, _) => _VisorCompleto(
          total: _total,
          inicial: _actual,
          constructor: (i) => _foto(i, ajuste: BoxFit.contain),
          titulo: widget.modelo ?? '',
        ),
      ),
    );
    if (nueva != null && mounted && _controlador.hasClients) {
      _controlador.jumpToPage(nueva);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hay = _total > 1;
    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.radio),
      child: SizedBox(
        height: widget.alto,
        width: double.infinity,
        child: Stack(
          children: [
            PageView.builder(
              controller: _controlador,
              itemCount: _total,
              onPageChanged: (i) {
                setState(() => _actual = i);
                _precargar(i + 1);
                _precargar(i - 1);
              },
              itemBuilder: (_, i) =>
                  GestureDetector(onTap: _abrirCompleta, child: _foto(i)),
            ),
            if (hay) ...[
              if (_actual > 0)
                Positioned(
                  left: 8,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: _Flecha(
                      clave: GaleriaAuto.flechaAnterior,
                      icono: LucideIcons.chevronLeft,
                      etiqueta: 'Foto anterior',
                      alPulsar: () => _ir(_actual - 1),
                    ),
                  ),
                ),
              if (_actual < _total - 1)
                Positioned(
                  right: 8,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: _Flecha(
                      clave: GaleriaAuto.flechaSiguiente,
                      icono: LucideIcons.chevronRight,
                      etiqueta: 'Foto siguiente',
                      alPulsar: () => _ir(_actual + 1),
                    ),
                  ),
                ),
              Positioned(
                right: 10,
                bottom: 10,
                child: _Contador(
                  clave: GaleriaAuto.contador,
                  texto: '${_actual + 1} / $_total',
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Contador extends StatelessWidget {
  const _Contador({required this.texto, this.clave});
  final String texto;
  final Key? clave;

  @override
  Widget build(BuildContext context) => Container(
    key: clave,
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: Colors.black54,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(
      texto,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}

class _Flecha extends StatelessWidget {
  const _Flecha({
    required this.icono,
    required this.etiqueta,
    required this.alPulsar,
    this.clave,
  });

  final IconData icono;
  final String etiqueta;
  final VoidCallback alPulsar;
  final Key? clave;

  @override
  Widget build(BuildContext context) {
    final boton = Semantics(
      button: true,
      label: etiqueta,
      child: GestureDetector(
        key: clave,
        onTap: alPulsar,
        child: Container(
          width: 44,
          height: 44,
          decoration: const BoxDecoration(
            color: Colors.black45,
            shape: BoxShape.circle,
          ),
          child: Icon(icono, color: Colors.white, size: 24),
        ),
      ),
    );
    return Movimiento.permitido(context)
        ? boton
              .animate()
              .fadeIn(duration: 200.ms)
              .scale(
                begin: const Offset(0.85, 0.85),
                duration: 200.ms,
                curve: Curves.easeOut,
              )
        : boton;
  }
}

/// Pantalla completa con zoom y las mismas flechas.
class _VisorCompleto extends StatefulWidget {
  const _VisorCompleto({
    required this.total,
    required this.inicial,
    required this.constructor,
    required this.titulo,
  });

  final int total;
  final int inicial;
  final Widget Function(int) constructor;
  final String titulo;

  @override
  State<_VisorCompleto> createState() => _VisorCompletoState();
}

class _VisorCompletoState extends State<_VisorCompleto> {
  late final PageController _c = PageController(initialPage: widget.inicial);
  late int _actual = widget.inicial;

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _ir(int i) {
    if (Movimiento.permitido(context)) {
      _c.animateToPage(
        i,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    } else {
      _c.jumpToPage(i);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.black,
    body: Stack(
      children: [
        PageView.builder(
          controller: _c,
          itemCount: widget.total,
          onPageChanged: (i) => setState(() => _actual = i),
          itemBuilder: (_, i) => InteractiveViewer(
            minScale: 1,
            maxScale: 4,
            child: Center(child: widget.constructor(i)),
          ),
        ),
        if (_actual > 0)
          Positioned(
            left: 8,
            top: 0,
            bottom: 0,
            child: Center(
              child: _Flecha(
                icono: LucideIcons.chevronLeft,
                etiqueta: 'Foto anterior',
                alPulsar: () => _ir(_actual - 1),
              ),
            ),
          ),
        if (_actual < widget.total - 1)
          Positioned(
            right: 8,
            top: 0,
            bottom: 0,
            child: Center(
              child: _Flecha(
                icono: LucideIcons.chevronRight,
                etiqueta: 'Foto siguiente',
                alPulsar: () => _ir(_actual + 1),
              ),
            ),
          ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                _Contador(texto: '${_actual + 1} / ${widget.total}'),
                const Spacer(),
                _Flecha(
                  icono: LucideIcons.x,
                  etiqueta: 'Cerrar',
                  alPulsar: () => Navigator.of(context).pop(_actual),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
