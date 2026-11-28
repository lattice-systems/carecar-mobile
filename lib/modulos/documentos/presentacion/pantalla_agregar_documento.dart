import 'dart:typed_data';

import 'package:flutter/foundation.dart' show compute;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons_300.dart';

import '../../../l10n/app_localizations.dart';
import '../../../nucleo/diseno/componentes/boton.dart';
import '../../../nucleo/diseno/componentes/esqueleto.dart';
import '../../../nucleo/diseno/componentes/marco_pantalla.dart';
import '../../../nucleo/diseno/componentes/selector.dart';
import '../../../nucleo/diseno/tokens/espaciado.dart';
import '../datos/preparar_foto_documento.dart';
import '../dominio/documento_vehiculo.dart';
import 'formato_documentos.dart';
import 'proveedores_documentos.dart';

class PantallaAgregarDocumento extends ConsumerStatefulWidget {
  const PantallaAgregarDocumento({required this.vehiculoId, super.key});
  final int vehiculoId;

  @override
  ConsumerState<PantallaAgregarDocumento> createState() =>
      _PantallaAgregarDocumentoState();
}

class _PantallaAgregarDocumentoState
    extends ConsumerState<PantallaAgregarDocumento> {
  TipoDocumento _tipo = TipoDocumento.poliza;
  DateTime? _venceEn;
  Uint8List? _foto;
  bool _preparando = false;
  bool _guardando = false;
  double _progreso = 0;
  String? _error;

  Future<void> _elegir(ImageSource fuente) async {
    if (_preparando || _guardando) return;
    setState(() {
      _preparando = true;
      _error = null;
    });
    try {
      final archivo = await ImagePicker().pickImage(
        source: fuente,
        maxWidth: 2400,
        maxHeight: 2400,
      );
      if (archivo == null || !mounted) return;
      final foto = await compute(
        prepararFotoDocumento,
        await archivo.readAsBytes(),
      );
      if (mounted) setState(() => _foto = foto);
    } on FormatException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } on Object {
      if (mounted) {
        setState(
          () => _error = AppLocalizations.of(context).documentosErrorFoto,
        );
      }
    } finally {
      if (mounted) setState(() => _preparando = false);
    }
  }

  Future<void> _fecha() async {
    final fecha = await showDatePicker(
      context: context,
      firstDate: DateTime(1900),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
      initialDate: _venceEn ?? DateTime.now(),
    );
    if (fecha != null && mounted) setState(() => _venceEn = fecha);
  }

  Future<void> _guardar() async {
    if (_guardando || _preparando) return;
    final textos = AppLocalizations.of(context);
    final foto = _foto;
    if (foto == null) {
      setState(() => _error = AppLocalizations.of(context).documentosFaltaFoto);
      return;
    }
    setState(() {
      _guardando = true;
      _progreso = 0;
      _error = null;
    });
    try {
      await ref
          .read(repositorioDocumentosApiProvider)
          .subir(
            vehiculoId: widget.vehiculoId,
            tipo: _tipo,
            titulo: _tipo == TipoDocumento.otro
                ? textos.documentosTipoOtro
                : null,
            venceEn: _venceEn,
            bytes: foto,
            alProgreso: (progreso) {
              if (!mounted || !_guardando) return;
              final porcentaje = (progreso * 100).floor();
              if (porcentaje != (_progreso * 100).floor()) {
                setState(() => _progreso = progreso);
              }
            },
          );
      if (mounted) {
        ref.invalidate(documentosProvider(widget.vehiculoId));
        context.pop();
      }
    } on Object {
      if (mounted) {
        setState(
          () => _error = AppLocalizations.of(context).documentosErrorGuardar,
        );
      }
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    return MarcoPantalla(
      titulo: textos.documentosAgregar,
      conRegreso: true,
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(Espaciado.e4),
          sliver: SliverList.list(
            children: [
              Selector<TipoDocumento>(
                etiqueta: textos.documentosTipo,
                valor: _tipo,
                opciones: [
                  for (final tipo in TipoDocumento.values)
                    OpcionSelector(valor: tipo, texto: textoTipo(textos, tipo)),
                ],
                alCambiar: _guardando || _preparando
                    ? null
                    : (tipo) {
                        if (tipo != null) setState(() => _tipo = tipo);
                      },
              ),
              const SizedBox(height: Espaciado.e3),
              Boton(
                texto: textos.documentosCamara,
                icono: LucideIcons300.camera,
                variante: VarianteBoton.secundario,
                alPresionar: _guardando || _preparando
                    ? null
                    : () => _elegir(ImageSource.camera),
                anchoCompleto: true,
              ),
              Boton(
                texto: textos.documentosGaleria,
                icono: LucideIcons300.images,
                variante: VarianteBoton.secundario,
                alPresionar: _guardando || _preparando
                    ? null
                    : () => _elegir(ImageSource.gallery),
                anchoCompleto: true,
              ),
              if (_preparando) const Esqueleto(alto: 64),
              if (_foto case final foto?)
                Image.memory(
                  foto,
                  height: 200,
                  fit: BoxFit.contain,
                  semanticLabel: textos.documentosVistaPrevia,
                ),
              Boton(
                texto: _venceEn == null
                    ? textos.documentosAgregarFecha
                    : fechaDocumento(context, _venceEn!),
                icono: LucideIcons300.calendarDays,
                variante: VarianteBoton.secundario,
                alPresionar: _guardando || _preparando ? null : _fecha,
                anchoCompleto: true,
              ),
              if (_guardando)
                LinearProgressIndicator(
                  value: _progreso,
                  semanticsLabel: textos.documentosProgreso,
                  semanticsValue: '${(_progreso * 100).floor()} %',
                ),
              if (_error != null)
                Semantics(liveRegion: true, child: Text(_error!)),
              Boton(
                texto: textos.documentosGuardar,
                alPresionar: _preparando ? null : _guardar,
                cargando: _guardando,
                anchoCompleto: true,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
