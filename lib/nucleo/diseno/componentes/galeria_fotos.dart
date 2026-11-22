import 'package:flutter/material.dart';

import '../movimiento_contexto.dart';
import '../tokens/espaciado.dart';
import '../tokens/movimiento.dart';
import '../tokens/radios.dart';
import '../tokens/tokens_pista.dart';

/// Una foto de la galeria. `descripcion` es obligatoria: es lo que lee el
/// lector de pantalla en lugar de la imagen.
class FotoGaleria {
  const FotoGaleria({required this.imagen, required this.descripcion});

  final ImageProvider imagen;
  final String descripcion;
}

/// Galeria de fotos del sistema de diseno v2.
///
/// Se pasa con el dedo o con las flechas, muestra "2 de 5" y al tocar una foto
/// abre el visor a pantalla completa con zoom. Las flechas y el cierre del
/// visor miden 48.
class GaleriaFotos extends StatefulWidget {
  const GaleriaFotos({
    required this.fotos,
    super.key,
    this.alto = 220,
    this.mensajeVacio = 'Aun no hay fotos.',
  });

  final List<FotoGaleria> fotos;
  final double alto;
  final String mensajeVacio;

  static const flechaSiguiente = Key('galeria_siguiente');
  static const flechaAnterior = Key('galeria_anterior');

  @override
  State<GaleriaFotos> createState() => _GaleriaFotosState();
}

class _GaleriaFotosState extends State<GaleriaFotos> {
  final _controlador = PageController();
  int _actual = 0;

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  void _ir(int i) {
    if (i < 0 || i >= widget.fotos.length) return;
    final mov = context.movimiento(Movimiento.base);
    _controlador.animateToPage(i, duration: mov.duracion, curve: mov.curva);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = TokensPista.de(context);
    final c = tokens.colores;
    final t = tokens.tipografia;

    if (widget.fotos.isEmpty) {
      return SizedBox(
        height: widget.alto,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: c.superficieHundida,
            borderRadius: Radios.bordeTarjeta,
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(Espaciado.e4),
              child: Text(
                widget.mensajeVacio,
                textAlign: TextAlign.center,
                style: t.cuerpoChico.copyWith(color: c.textoSecundario),
              ),
            ),
          ),
        ),
      );
    }

    final total = widget.fotos.length;
    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: 'Galeria de fotos, ${_actual + 1} de $total',
      child: Column(
        children: [
          ClipRRect(
            borderRadius: Radios.bordeTarjeta,
            child: SizedBox(
              height: widget.alto,
              child: Stack(
                children: [
                  PageView.builder(
                    controller: _controlador,
                    itemCount: total,
                    onPageChanged: (i) => setState(() => _actual = i),
                    itemBuilder: (context, i) {
                      final foto = widget.fotos[i];
                      return Semantics(
                        image: true,
                        button: true,
                        label: foto.descripcion,
                        onTapHint: 'Ampliar',
                        excludeSemantics: true,
                        child: GestureDetector(
                          onTap: () => mostrarVisorFoto(context, foto),
                          child: Image(
                            image: foto.imagen,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            errorBuilder: (_, _, _) => ColoredBox(
                              color: c.superficieHundida,
                              child: Icon(
                                Icons.broken_image_outlined,
                                color: c.textoTerciario,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  if (total > 1) ...[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: _Flecha(
                        llave: GaleriaFotos.flechaAnterior,
                        icono: Icons.chevron_left,
                        tooltip: 'Foto anterior',
                        alPresionar: _actual > 0
                            ? () => _ir(_actual - 1)
                            : null,
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: _Flecha(
                        llave: GaleriaFotos.flechaSiguiente,
                        icono: Icons.chevron_right,
                        tooltip: 'Foto siguiente',
                        alPresionar: _actual < total - 1
                            ? () => _ir(_actual + 1)
                            : null,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: Espaciado.e2),
          ExcludeSemantics(
            child: Text(
              '${_actual + 1} de $total',
              style: t.etiqueta.copyWith(color: c.textoSecundario),
            ),
          ),
        ],
      ),
    );
  }
}

class _Flecha extends StatelessWidget {
  const _Flecha({
    required this.llave,
    required this.icono,
    required this.tooltip,
    required this.alPresionar,
  });

  final Key llave;
  final IconData icono;
  final String tooltip;
  final VoidCallback? alPresionar;

  @override
  Widget build(BuildContext context) {
    final c = TokensPista.de(context).colores;
    return IconButton(
      key: llave,
      onPressed: alPresionar,
      tooltip: tooltip,
      constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
      style: IconButton.styleFrom(
        backgroundColor: c.superficie.withValues(alpha: 0.85),
        disabledBackgroundColor: Colors.transparent,
        foregroundColor: c.texto,
        disabledForegroundColor: Colors.transparent,
      ),
      icon: Icon(icono),
    );
  }
}

/// Abre una foto a pantalla completa con zoom de pellizco y doble toque.
Future<void> mostrarVisorFoto(BuildContext context, FotoGaleria foto) {
  return Navigator.of(context).push<void>(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => _VisorFoto(foto: foto),
    ),
  );
}

class _VisorFoto extends StatelessWidget {
  const _VisorFoto({required this.foto});

  final FotoGaleria foto;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: Semantics(
              image: true,
              label: foto.descripcion,
              child: InteractiveViewer(
                minScale: 1,
                maxScale: 5,
                child: Center(child: Image(image: foto.imagen)),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(Espaciado.e2),
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                tooltip: 'Cerrar foto',
                constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black54,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.close),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
