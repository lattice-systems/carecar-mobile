import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../api/carecar_api.dart';
import '../api/modelos/vehiculo.dart';
import '../manuales/guardar_pdf.dart';
import '../manuales/servicio_manuales.dart';
import '../tema/tema_carecar.dart';
import '../widgets/movimiento.dart';
import '../widgets/aviso.dart';
import '../widgets/dialogos.dart';
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
  // Notifiers y no `setState`: pasar de pagina solo repinta el contador, no la
  // pantalla entera (encabezado incluido), y el scroll del PDF no se traba.
  final ValueNotifier<int> _pagina = ValueNotifier(1);
  final ValueNotifier<int> _total = ValueNotifier(0);
  int _intento = 0;

  @override
  void dispose() {
    _pdf?.dispose();
    _pagina.dispose();
    _total.dispose();
    super.dispose();
  }

  void _reintentar() {
    _pdf?.dispose();
    setState(() {
      _pdf = null;
      _falloPdf = null;
      _pagina.value = 1;
      _total.value = 0;
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

  Future<void> _descargar(DocumentoManual documento) async {
    try {
      final r = await guardarPdf(documento.bytes, documento.titulo);
      if (!mounted || r == ResultadoGuardado.cancelado) return;
      mostrarToast(context, 'Manual guardado', exito: true);
    } catch (_) {
      if (mounted) {
        mostrarToast(context, 'No se pudo guardar el PDF.', error: true);
      }
    }
  }

  Widget _visor(DocumentoManual documento) {
    if (_falloPdf != null) return _error(_falloPdf!);
    _pdf ??= PdfControllerPinch(
      document: PdfDocument.openData(documento.bytes),
    );
    return Column(
      children: [
        Expanded(
          // Aislado: lo que se repinta al hacer scroll no toca el resto.
          child: RepaintBoundary(
            child: PdfViewPinch(
              key: ValueKey(_intento),
              controller: _pdf!,
              onDocumentLoaded: (pdf) {
                if (mounted) _total.value = pdf.pagesCount;
              },
              onPageChanged: (pagina) {
                if (mounted) _pagina.value = pagina;
              },
              onDocumentError: (error) {
                if (mounted) {
                  setState(
                    () => _falloPdf =
                        'No se pudo cargar el PDF. Intenta de nuevo.',
                  );
                }
              },
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(child: _contador()),
              const SizedBox(width: 8),
              ShadButton(
                leading: const Icon(Icons.download),
                onPressed: () => _descargar(documento),
                child: const Text('Descargar PDF'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _contador() => ValueListenableBuilder<int>(
    valueListenable: _total,
    builder: (context, total, _) => ValueListenableBuilder<int>(
      valueListenable: _pagina,
      builder: (context, pagina, _) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: TemaCareCar.degradadoMarca,
          borderRadius: BorderRadius.circular(99),
        ),
        child: Text(
          total == 0 ? 'Cargando PDF…' : 'Página $pagina de $total',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ),
  );

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
