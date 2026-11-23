import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../api/excepciones.dart';
import '../../../l10n/app_localizations.dart';
import '../../../manuales/guardar_pdf.dart';
import '../../../manuales/servicio_manuales.dart';
import '../../../nucleo/diseno/componentes/aviso.dart';
import '../../../nucleo/diseno/componentes/cabecera_portada.dart';
import '../../../nucleo/diseno/componentes/esqueleto.dart';
import '../../../nucleo/diseno/componentes/estado_error.dart';
import '../../../nucleo/diseno/componentes/estado_vacio.dart';
import '../../../nucleo/diseno/componentes/tono.dart';
import '../../../nucleo/diseno/componentes/visor_pdf.dart';
import '../../../nucleo/diseno/tokens/espaciado.dart';
import '../../../nucleo/diseno/tokens/tokens_pista.dart';
import 'portada_vehiculo.dart';
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
  });

  final int vehiculoId;
  final FabricaVisorPdf? fabricaVisor;

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
      appBar: AppBar(
        // Con manual el titulo vive en la portada; sin el, en la barra.
        title: doc == null ? Text(textos.vehiculosManualTitulo) : null,
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: manual.when(
        skipLoadingOnReload: true,
        loading: () => const _Cargando(),
        error: (error, _) => EstadoError(
          causa: error is SinConexion
              ? CausaError.sinConexion
              : CausaError.generico,
          alReintentar: () => ref.invalidate(manualProvider(widget.vehiculoId)),
        ),
        data: (m) => m == null
            ? EstadoVacio(
                titulo: textos.vehiculosManualVacioTitulo,
                mensaje: textos.vehiculosManualVacioMensaje,
                icono: Icons.menu_book_outlined,
              )
            : Column(
                children: [
                  Flexible(
                    flex: 3,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          CabeceraPortada(
                            titulo: textos.vehiculosManualTitulo,
                            subtitulo: m.titulo,
                            descripcion: textos.vehiculosManualDescripcion(
                              m.titulo,
                            ),
                            lado: 120,
                            portada: PortadaVehiculo(
                              tinte: TokensPista.de(context).colores.acento,
                              icono: Icons.menu_book_rounded,
                            ),
                            principal: AccionPortada(
                              texto: textos.vehiculosBotonDescargar,
                              icono: Icons.download_outlined,
                              alPresionar: () => _descargar(m),
                            ),
                            secundaria: AccionPortada(
                              texto: textos.vehiculosBotonCompartir,
                              icono: Icons.share_outlined,
                              alPresionar: () => _compartir(m),
                            ),
                          ),
                          if (_guardado != null)
                            Padding(
                              padding: const EdgeInsets.all(Espaciado.e3),
                              child: Aviso(
                                mensaje: _guardado!
                                    ? textos.vehiculosManualGuardado
                                    : textos.vehiculosManualGuardadoError,
                                tono: _guardado! ? Tono.exito : Tono.peligro,
                                alCerrar: () =>
                                    setState(() => _guardado = null),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(flex: 4, child: _visor(m, textos)),
                ],
              ),
      ),
    );
  }

  Widget _visor(DocumentoManual m, AppLocalizations textos) {
    final descripcion = textos.vehiculosManualDescripcion(m.titulo);
    Future<Uint8List> cargar() async => m.bytes;
    final fabrica = widget.fabricaVisor;
    return fabrica == null
        ? VisorPdf(cargar: cargar, descripcion: descripcion)
        : VisorPdf(cargar: cargar, descripcion: descripcion, fabrica: fabrica);
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
