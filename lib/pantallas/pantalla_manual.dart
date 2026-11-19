import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';

import '../api/modelos/vehiculo.dart';
import '../manuales/servicio_manuales.dart';
import '../tema/tema_carecar.dart';
import '../widgets/aviso.dart';
import '../widgets/pagina_carecar.dart';

class PantallaManual extends StatefulWidget {
  const PantallaManual({
    required this.vehiculo,
    required this.alCerrarSesion,
    this.servicio,
    super.key,
  });
  final Vehiculo vehiculo;
  final VoidCallback alCerrarSesion;
  final ServicioManuales? servicio;
  @override
  State<PantallaManual> createState() => _PantallaManualState();
}

class _PantallaManualState extends State<PantallaManual> {
  late final ServicioManuales _servicio = widget.servicio ?? ManualesLocales();
  DocumentoManual? _datos;
  String? _falloCarga;
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    try {
      final datos = await _servicio.cargar(widget.vehiculo);
      if (mounted) {
        setState(() {
          _datos = datos;
          _cargando = false;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _falloCarga = error is FalloManual
              ? error.mensaje
              : 'No se pudo cargar el PDF. Intenta de nuevo.';
          _cargando = false;
        });
      }
    }
  }

  PdfControllerPinch? _pdf;
  String? _falloPdf;
  int _pagina = 1;
  int _total = 0;
  int _intento = 0;

  @override
  void dispose() {
    _pdf?.dispose();
    super.dispose();
  }

  void _reintentar() {
    _pdf?.dispose();
    setState(() {
      _pdf = null;
      _falloPdf = null;
      _pagina = 1;
      _total = 0;
      _intento++;
      _datos = null;
      _falloCarga = null;
      _cargando = true;
    });
    _cargar();
  }

  Widget _error(String mensaje) => Center(
    child: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(TemaCareCar.espacioSecciones),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Aviso.informacion(titulo: mensaje),
            const SizedBox(height: TemaCareCar.espacioCampos),
            OutlinedButton(
              onPressed: _reintentar,
              child: const Text('Reintentar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).maybePop(),
              child: const Text('Volver al detalle'),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _visor(DocumentoManual documento) {
    if (_falloPdf != null) return _error(_falloPdf!);
    _pdf ??= PdfControllerPinch(
      document: PdfDocument.openData(documento.bytes),
    );
    return Column(
      children: [
        Expanded(
          child: PdfViewPinch(
            key: ValueKey(_intento),
            controller: _pdf!,
            onDocumentLoaded: (pdf) {
              if (mounted) {
                setState(() => _total = pdf.pagesCount);
              }
            },
            onPageChanged: (pagina) {
              if (mounted) {
                setState(() => _pagina = pagina);
              }
            },
            onDocumentError: (error) {
              if (mounted) {
                setState(
                  () =>
                      _falloPdf = 'No se pudo cargar el PDF. Intenta de nuevo.',
                );
              }
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Text(
            _total == 0
                ? 'Cargando PDF…'
                : 'Página $_pagina de $_total · Pellizca para ampliar',
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) => PaginaCareCar(
    titulo: _datos != null
        ? 'Manual — ${_datos!.titulo}'
        : 'Manual del propietario',
    expandir: true,
    alCerrarSesion: widget.alCerrarSesion,
    contenido: _cargando
        ? const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Cargando manual…'),
              ],
            ),
          )
        : _falloCarga != null
        ? _error(_falloCarga!)
        : _visor(_datos!),
  );
}
