import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:pdfx/pdfx.dart';

import '../api/carecar_api.dart';
import '../api/modelos/vehiculo.dart';
import '../manuales/servicio_manuales.dart';
import '../tema/tema_carecar.dart';
import '../widgets/movimiento.dart';
import '../widgets/aviso.dart';
import '../widgets/pagina_carecar.dart';

class PantallaManual extends StatefulWidget {
  const PantallaManual({
    required this.vehiculo,
    required this.alCerrarSesion,
    this.servicio,
    this.api,
    this.etiqueta = 'Manual',
    super.key,
  });
  final Vehiculo vehiculo;
  final VoidCallback alCerrarSesion;
  final ServicioManuales? servicio;

  /// Con la API se busca primero el manual que publica la agencia.
  final CarecarApi? api;

  /// Antes del nombre en el titulo: «Manual» o «Ticket».
  final String etiqueta;
  @override
  State<PantallaManual> createState() => _PantallaManualState();
}

class _PantallaManualState extends State<PantallaManual> {
  late final ServicioManuales _servicio =
      widget.servicio ??
      (widget.api == null
          ? ManualesLocales()
          : ManualesDeLaAgencia(api: widget.api!));
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
            ShadButton.outline(
              onPressed: _reintentar,
              child: const Text('Reintentar'),
            ),
            ShadButton.link(
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
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              gradient: TemaCareCar.degradadoMarca,
              borderRadius: BorderRadius.circular(99),
            ),
            child: Text(
              _total == 0
                  ? 'Cargando PDF…'
                  : 'Página $_pagina de $_total · Pellizca para ampliar',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ).animate().fadeIn().slideY(begin: 0.5),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) => PaginaCareCar(
    titulo: _datos != null
        ? '${widget.etiqueta} — ${_datos!.titulo}'
        : 'Manual del propietario',
    expandir: true,
    alCerrarSesion: widget.alCerrarSesion,
    contenido: _cargando
        ? const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _IconoCargando(),
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

class _IconoCargando extends StatelessWidget {
  const _IconoCargando();

  @override
  Widget build(BuildContext context) =>
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: TemaCareCar.azulSuave,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.menu_book_rounded,
          size: 40,
          color: TemaCareCar.azulAgencia,
        ),
      ).siempre(
        context,
        (w) => w
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .scaleXY(begin: 0.92, end: 1.05, duration: 700.ms),
      );
}
