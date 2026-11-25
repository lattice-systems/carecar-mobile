import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../api/excepciones.dart';
import '../../../l10n/app_localizations.dart';
import '../../../manuales/guardar_pdf.dart';
import '../../../manuales/servicio_manuales.dart';
import '../../../nucleo/diseno/componentes/aviso.dart';
import '../../../nucleo/diseno/componentes/barra_pantalla.dart';
import '../../../nucleo/diseno/componentes/esqueleto.dart';
import '../../../nucleo/diseno/componentes/estado_error.dart';
import '../../../nucleo/diseno/componentes/estado_vacio.dart';
import '../../../nucleo/diseno/componentes/grupo_acciones_pildora.dart';
import '../../../nucleo/diseno/componentes/tono.dart';
import '../../../nucleo/diseno/componentes/visor_pdf.dart';
import '../../../nucleo/diseno/tokens/espaciado.dart';
import '../../../nucleo/diseno/tokens/tokens_pista.dart';
import 'proveedores_vehiculos.dart';

/// Manual del vehiculo por su modelo y ano (V2-M02.03): visor de PDF con zoom
/// de pellizco, descarga y compartir.
///
/// El manual sale de la agencia y, si no hay o no hay red, del PDF incluido en
/// la app. Resuelve los cinco estados. `fabricaVisor` solo existe para probar
/// sin el motor nativo de PDF.
class PantallaManual extends ConsumerStatefulWidget {
  const PantallaManual({
    required this.vehiculoId,
    super.key,
    this.fabricaVisor,
    this.paginaInicial,
  });

  final int vehiculoId;
  final FabricaVisorPdf? fabricaVisor;

  /// Pagina en la que abre el manual (V2-M24.04, la que cito el asistente).
  final int? paginaInicial;

  @override
  ConsumerState<PantallaManual> createState() => _PantallaManualState();
}

class _PantallaManualState extends ConsumerState<PantallaManual> {
  /// `null` sin aviso; verdadero = guardado, falso = fallo al guardar.
  bool? _guardado;

  Future<void> _descargar(DocumentoManual manual) async {
    bool? resultado;
    try {
      final r = await ref.read(guardarManualProvider)(
        manual.bytes,
        manual.titulo,
      );
      resultado = r == ResultadoGuardado.guardado ? true : null;
    } on Exception {
      resultado = false;
    }
    if (mounted) setState(() => _guardado = resultado);
  }

  Future<void> _compartir(DocumentoManual manual) => ref.read(
    compartirManualProvider,
  )(manual.bytes, nombreArchivoPdf(manual.titulo));

  @override
  Widget build(BuildContext context) {
    final manual = ref.watch(manualProvider(widget.vehiculoId));
    final textos = AppLocalizations.of(context);
    final doc = manual.asData?.value;

    return Scaffold(
      backgroundColor: TokensPista.de(context).colores.fondo,
      body: Column(
        children: [
          // El visor necesita todo el alto posible: la pantalla es una barra
          // fija con las acciones del documento, no un encabezado grande.
          BarraPantalla(
            titulo: textos.vehiculosManualTitulo,
            subtitulo: doc?.titulo,
            acciones: [
              if (doc != null)
                GrupoAccionesPildora(
                  acciones: [
                    AccionIcono(
                      icono: Icons.download_outlined,
                      etiqueta: textos.vehiculosBotonDescargar,
                      alPresionar: () => _descargar(doc),
                    ),
                    AccionIcono(
                      icono: Icons.share_outlined,
                      etiqueta: textos.vehiculosBotonCompartir,
                      alPresionar: () => _compartir(doc),
                    ),
                  ],
                ),
            ],
          ),
          if (_guardado != null)
            Padding(
              padding: const EdgeInsets.all(Espaciado.e3),
              child: Aviso(
                mensaje: _guardado!
                    ? textos.vehiculosManualGuardado
                    : textos.vehiculosManualGuardadoError,
                tono: _guardado! ? Tono.exito : Tono.peligro,
                alCerrar: () => setState(() => _guardado = null),
              ),
            ),
          Expanded(
            child: manual.when(
              skipLoadingOnReload: true,
              loading: () => const _Cargando(),
              error: (error, _) => EstadoError(
                causa: error is SinConexion
                    ? CausaError.sinConexion
                    : CausaError.generico,
                alReintentar: () =>
                    ref.invalidate(manualProvider(widget.vehiculoId)),
              ),
              data: (m) => m == null
                  ? EstadoVacio(
                      titulo: textos.vehiculosManualVacioTitulo,
                      mensaje: textos.vehiculosManualVacioMensaje,
                      icono: Icons.menu_book_outlined,
                    )
                  : _visor(m, textos),
            ),
          ),
        ],
      ),
    );
  }

  Widget _visor(DocumentoManual m, AppLocalizations textos) {
    final descripcion = textos.vehiculosManualDescripcion(m.titulo);
    Future<Uint8List> cargar() async => m.bytes;
    final fabrica = widget.fabricaVisor;
    final pagina = widget.paginaInicial ?? 1;
    return fabrica == null
        ? VisorPdf(
            cargar: cargar,
            descripcion: descripcion,
            paginaInicial: pagina,
          )
        : VisorPdf(
            cargar: cargar,
            descripcion: descripcion,
            fabrica: fabrica,
            paginaInicial: pagina,
          );
  }
}

class _Cargando extends StatelessWidget {
  const _Cargando();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: AppLocalizations.of(context).vehiculosManualCargando,
      liveRegion: true,
      child: const Padding(
        padding: EdgeInsets.all(Espaciado.e4),
        child: Column(
          children: [
            Expanded(child: Esqueleto(alto: double.infinity)),
            SizedBox(height: Espaciado.e3),
            Esqueleto.linea(),
          ],
        ),
      ),
    );
  }
}
