import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';

import '../tokens/espaciado.dart';
import '../tokens/radios.dart';
import '../tokens/tokens_pista.dart';
import 'esqueleto.dart';
import 'estado_error.dart';

/// Construye el visor de paginas a partir de los bytes del PDF. Se separa para
/// poder probar el resto del componente sin el motor nativo de PDF.
typedef FabricaVisorPdf = Widget Function(
  BuildContext context,
  Uint8List bytes,
  ValueChanged<int> alCargar,
  ValueChanged<int> alCambiarPagina,
);

/// Visor de PDF del sistema de diseno v2: carga, error con reintento, zoom de
/// pellizco y un contador "Pagina 2 de 5".
///
/// `cargar` entrega los bytes, por ejemplo desde la red o un archivo local; el
/// componente no sabe de donde vienen. `descripcion` nombra el documento para
/// el lector de pantalla ("Manual del Mazda CX-5"). Esta primera version no
/// busca texto dentro del PDF: eso lo resuelve V2-M02.03.
class VisorPdf extends StatefulWidget {
  const VisorPdf({
    required this.cargar,
    required this.descripcion,
    super.key,
    this.fabrica = _fabricaPdfx,
  });

  final Future<Uint8List> Function() cargar;
  final String descripcion;
  final FabricaVisorPdf fabrica;

  @override
  State<VisorPdf> createState() => _VisorPdfState();
}

Widget _fabricaPdfx(
  BuildContext context,
  Uint8List bytes,
  ValueChanged<int> alCargar,
  ValueChanged<int> alCambiarPagina,
) {
  return _VisorPdfx(
    bytes: bytes,
    alCargar: alCargar,
    alCambiarPagina: alCambiarPagina,
  );
}

class _VisorPdfState extends State<VisorPdf> {
  late Future<Uint8List> _bytes = widget.cargar();
  int _pagina = 1;
  int _total = 0;

  void _reintentar() {
    setState(() {
      _bytes = widget.cargar();
      _pagina = 1;
      _total = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final tokens = TokensPista.de(context);
    final c = tokens.colores;
    final t = tokens.tipografia;

    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: widget.descripcion,
      child: FutureBuilder<Uint8List>(
        future: _bytes,
        builder: (context, instante) {
          if (instante.hasError) {
            return EstadoError(alReintentar: _reintentar);
          }
          if (!instante.hasData) {
            return const _Cargando();
          }
          return Stack(
            children: [
              Positioned.fill(
                child: widget.fabrica(
                  context,
                  instante.data!,
                  (total) => setState(() => _total = total),
                  (pagina) => setState(() => _pagina = pagina),
                ),
              ),
              if (_total > 0)
                Positioned(
                  bottom: Espaciado.e3,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Semantics(
                      liveRegion: true,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: c.superficieElevada,
                          borderRadius: Radios.bordePildora,
                          border: Border.all(color: c.borde),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: Espaciado.e4,
                            vertical: Espaciado.e2,
                          ),
                          child: Text(
                            'Pagina $_pagina de $_total',
                            style: t.etiqueta.copyWith(color: c.texto),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _Cargando extends StatelessWidget {
  const _Cargando();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Cargando documento',
      liveRegion: true,
      child: const Padding(
        padding: EdgeInsets.all(Espaciado.e4),
        child: Column(
          children: [
            Expanded(child: Esqueleto(alto: double.infinity)),
            SizedBox(height: Espaciado.e3),
            Esqueleto.linea(),
            SizedBox(height: Espaciado.e2),
            Esqueleto.linea(ancho: 160),
          ],
        ),
      ),
    );
  }
}

class _VisorPdfx extends StatefulWidget {
  const _VisorPdfx({
    required this.bytes,
    required this.alCargar,
    required this.alCambiarPagina,
  });

  final Uint8List bytes;
  final ValueChanged<int> alCargar;
  final ValueChanged<int> alCambiarPagina;

  @override
  State<_VisorPdfx> createState() => _VisorPdfxState();
}

class _VisorPdfxState extends State<_VisorPdfx> {
  late final PdfControllerPinch _controlador = PdfControllerPinch(
    document: PdfDocument.openData(widget.bytes),
  );

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PdfViewPinch(
      controller: _controlador,
      onDocumentLoaded: (documento) => widget.alCargar(documento.pagesCount),
      onPageChanged: widget.alCambiarPagina,
    );
  }
}
