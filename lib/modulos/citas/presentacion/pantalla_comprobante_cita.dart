import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../api/excepciones.dart';
import '../../../l10n/app_localizations.dart';
import '../../../nucleo/diseno/componentes/boton.dart';
import '../../../nucleo/diseno/componentes/esqueleto.dart';
import '../../../nucleo/diseno/componentes/estado_error.dart';
import '../../../nucleo/diseno/componentes/visor_pdf.dart';
import '../../../nucleo/diseno/tokens/espaciado.dart';
import '../../../nucleo/diseno/tokens/radios.dart';
import '../../../nucleo/diseno/tokens/tokens_pista.dart';
import '../dominio/comprobante_de_cita.dart';
import 'boton_agregar_a_wallet.dart';
import 'proveedores_citas.dart';

/// Comprobante de una cita con su QR para recepcion rapida (V2-M02.11).
///
/// El QR lleva el id de la cita firmado por el backend; recepcion lo escanea
/// y la cita se reconoce sin buscarla. Desde aqui tambien se abre el PDF que
/// entrega `GET /citas/{id}/ticket`. Resuelve los cinco estados: cargando,
/// datos, error con reintento y sin conexion (no hay "vacio": una cita sin
/// comprobante es un error).
class PantallaComprobanteCita extends ConsumerWidget {
  const PantallaComprobanteCita({
    required this.citaId,
    super.key,
    this.fabricaVisorPdf,
  });

  final int citaId;

  /// Sustituye el motor de PDF (solo pruebas); nulo usa el del sistema.
  final FabricaVisorPdf? fabricaVisorPdf;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textos = AppLocalizations.of(context);
    final comprobante = ref.watch(comprobanteCitaProvider(citaId));

    return Scaffold(
      appBar: AppBar(title: Text(textos.citasComprobanteTitulo)),
      body: comprobante.when(
        skipLoadingOnReload: true,
        loading: () => const _Cargando(),
        error: (error, _) => EstadoError(
          causa: error is SinConexion
              ? CausaError.sinConexion
              : CausaError.generico,
          alReintentar: () => ref.invalidate(comprobanteCitaProvider(citaId)),
        ),
        data: (datos) =>
            _Comprobante(datos: datos, fabricaVisorPdf: fabricaVisorPdf),
      ),
    );
  }
}

class _Cargando extends StatelessWidget {
  const _Cargando();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: AppLocalizations.of(context).citasComprobanteCargando,
      liveRegion: true,
      child: const Padding(
        padding: EdgeInsets.all(Espaciado.e4),
        child: Column(
          children: [
            Esqueleto(alto: 280),
            SizedBox(height: Espaciado.e3),
            Esqueleto(alto: 56),
          ],
        ),
      ),
    );
  }
}

class _Comprobante extends ConsumerWidget {
  const _Comprobante({required this.datos, this.fabricaVisorPdf});

  final ComprobanteDeCita datos;
  final FabricaVisorPdf? fabricaVisorPdf;

  static const double _ladoQr = 220;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textos = AppLocalizations.of(context);
    final tokens = TokensPista.de(context);
    final c = tokens.colores;
    final t = tokens.tipografia;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(Espaciado.e4),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: Espaciado.anchoMaximoContenido,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Semantics(
                  image: true,
                  label: textos.citasComprobanteQrDescripcion,
                  child: ExcludeSemantics(
                    // Un QR se lee mejor negro sobre blanco en cualquier tema:
                    // el contraste lo exige el escaner, no el tema.
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: Radios.bordeTarjeta,
                        border: Border.all(color: c.borde),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(Espaciado.e4),
                        child: QrImageView(
                          key: ValueKey('qr-comprobante:${datos.codigo}'),
                          data: datos.codigo,
                          size: _ladoQr,
                          backgroundColor: Colors.white,
                          eyeStyle: const QrEyeStyle(
                            eyeShape: QrEyeShape.square,
                            color: Colors.black,
                          ),
                          dataModuleStyle: const QrDataModuleStyle(
                            dataModuleShape: QrDataModuleShape.square,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: Espaciado.e4),
              Text(
                textos.citasComprobanteFolio(datos.citaId),
                textAlign: TextAlign.center,
                style: t.titulo3.copyWith(color: c.texto),
              ),
              const SizedBox(height: Espaciado.e1),
              Text(
                textos.citasComprobanteCuando(
                  datos.fecha,
                  datos.horaInicio,
                  datos.horaFin,
                ),
                textAlign: TextAlign.center,
                style: t.cuerpo.copyWith(color: c.texto),
              ),
              if (datos.vehiculoNombre != null) ...[
                const SizedBox(height: Espaciado.e1),
                Text(
                  datos.vehiculoNombre!,
                  textAlign: TextAlign.center,
                  style: t.cuerpo.copyWith(color: c.textoSecundario),
                ),
              ],
              const SizedBox(height: Espaciado.e3),
              Text(
                textos.citasComprobanteIndicacion,
                textAlign: TextAlign.center,
                style: t.cuerpo.copyWith(color: c.textoSecundario),
              ),
              const SizedBox(height: Espaciado.e6),
              Boton(
                texto: textos.citasComprobanteVerPdf,
                icono: Icons.picture_as_pdf_outlined,
                variante: VarianteBoton.secundario,
                anchoCompleto: true,
                alPresionar: () => _abrirPdf(context, ref),
              ),
              const SizedBox(height: Espaciado.e3),
              BotonAgregarAWallet(citaId: datos.citaId),
            ],
          ),
        ),
      ),
    );
  }

  void _abrirPdf(BuildContext context, WidgetRef ref) {
    final textos = AppLocalizations.of(context);
    final repositorio = ref.read(repositorioCitasProvider);
    final fabrica = fabricaVisorPdf;
    Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(title: Text(textos.citasComprobanteTitulo)),
          body: fabrica == null
              ? VisorPdf(
                  cargar: () => repositorio.ticketPdf(datos.citaId),
                  descripcion: textos.citasComprobanteVerPdfDescripcion,
                )
              : VisorPdf(
                  cargar: () => repositorio.ticketPdf(datos.citaId),
                  descripcion: textos.citasComprobanteVerPdfDescripcion,
                  fabrica: fabrica,
                ),
        ),
      ),
    );
  }
}
