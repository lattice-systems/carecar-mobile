import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../api/excepciones.dart';
import '../../../l10n/app_localizations.dart';
import '../../../nucleo/diseno/componentes/boton_pildora.dart';
import '../../../nucleo/diseno/componentes/cabecera_portada.dart';
import '../../../nucleo/diseno/componentes/esqueleto.dart';
import '../../../nucleo/diseno/componentes/estado_error.dart';
import '../../../nucleo/diseno/componentes/grupo_lista.dart';
import '../../../nucleo/diseno/componentes/visor_pdf.dart';
import '../../../nucleo/diseno/tokens/espaciado.dart';
import '../../../nucleo/diseno/tokens/tokens_pista.dart';
import '../dominio/comprobante_de_cita.dart';
import 'boton_agregar_a_wallet.dart';
import 'componentes/marco_pantalla_cita.dart';
import 'proveedores_citas.dart';

/// Comprobante de una cita con su QR para recepcion rapida (V2-M02.11).
///
/// El QR lleva el id de la cita firmado por el backend; recepcion lo escanea
/// y la cita se reconoce sin buscarla. Va como portada (estilo portada del
/// sistema de diseno), con «Agregar a Wallet» y «Ver PDF» como pildoras. Desde
/// aqui tambien se abre el PDF que entrega `GET /citas/{id}/ticket`. Resuelve
/// los cinco estados: cargando, datos, error con reintento y sin conexion (no
/// hay "vacio": una cita sin comprobante es un error).
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

    return comprobante.when(
      skipLoadingOnReload: true,
      loading: () => MarcoPantallaCita.estado(
        titulo: textos.citasComprobanteTitulo,
        estado: const _Cargando(),
      ),
      error: (error, _) => MarcoPantallaCita.estado(
        titulo: textos.citasComprobanteTitulo,
        estado: EstadoError(
          causa: error is SinConexion
              ? CausaError.sinConexion
              : CausaError.generico,
          alReintentar: () => ref.invalidate(comprobanteCitaProvider(citaId)),
        ),
      ),
      data: (datos) => MarcoPantallaCita(
        titulo: textos.citasComprobanteTitulo,
        slivers: [
          SliverToBoxAdapter(
            child: _Comprobante(datos: datos, fabricaVisorPdf: fabricaVisorPdf),
          ),
        ],
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
            Esqueleto(alto: 280, radio: 28),
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

  static const double _lado = 240;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textos = AppLocalizations.of(context);
    final c = TokensPista.de(context).colores;
    final fecha = DateFormat.yMMMMEEEEd(
      Localizations.localeOf(context).toString(),
    ).format(datos.fecha);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CabeceraPortada(
          titulo: textos.citasComprobanteFolio(datos.citaId),
          subtitulo: textos.citasComprobanteCuando(
            datos.fecha,
            datos.horaInicio,
            datos.horaFin,
          ),
          descripcion: textos.citasComprobanteQrDescripcion,
          lado: _lado,
          portada: _PortadaQr(codigo: datos.codigo, lado: _lado),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Espaciado.e4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              BotonAgregarAWallet(citaId: datos.citaId, pildora: true),
              const SizedBox(height: Espaciado.e2),
              BotonPildora(
                texto: textos.citasComprobanteVerPdf,
                icono: Icons.picture_as_pdf_outlined,
                variante: VarianteBotonPildora.tonal,
                expandido: true,
                alPresionar: () => _abrirPdf(context, ref),
              ),
            ],
          ),
        ),
        const SizedBox(height: Espaciado.e6),
        GrupoLista(
          encabezado: textos.citasComprobanteDetalles,
          filas: [
            if (datos.vehiculoNombre != null)
              FilaGrupo(
                titulo: textos.citasResumenVehiculo,
                subtitulo: datos.vehiculoNombre,
                icono: Icons.directions_car_filled_outlined,
                colorIcono: c.acento,
              ),
            FilaGrupo(
              titulo: textos.citasResumenFecha,
              subtitulo: fecha,
              icono: Icons.calendar_today_outlined,
              colorIcono: c.marca,
            ),
            FilaGrupo(
              titulo: textos.citasResumenHorario,
              subtitulo: textos.citasResumenHorarioValor(
                datos.horaInicio,
                datos.horaFin,
              ),
              icono: Icons.schedule_outlined,
              colorIcono: c.advertencia,
            ),
            FilaGrupo(
              titulo: textos.citasComprobanteRecepcion,
              subtitulo: textos.citasComprobanteIndicacion,
              icono: Icons.qr_code_scanner_rounded,
              colorIcono: c.exito,
            ),
          ],
        ),
      ],
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

/// El QR sobre blanco, que es la portada del comprobante.
///
/// Un QR se lee mejor negro sobre blanco en cualquier tema: el contraste lo
/// exige el escaner, no el tema. `CabeceraPortada` pinta la portada dos veces
/// (la pieza y el fondo desenfocado); el codigo solo se dibuja en la pieza, de
/// lado exacto, y el fondo recibe un tinte liso para no repetir el QR.
class _PortadaQr extends StatelessWidget {
  const _PortadaQr({required this.codigo, required this.lado});

  final String codigo;
  final double lado;

  @override
  Widget build(BuildContext context) {
    final c = TokensPista.de(context).colores;
    return LayoutBuilder(
      builder: (context, caja) {
        final esPieza = caja.maxHeight <= lado + 0.5;
        if (!esPieza) return ColoredBox(color: c.acentoSuave);
        return ColoredBox(
          color: Colors.white,
          child: Center(
            child: ExcludeSemantics(
              child: QrImageView(
                key: ValueKey('qr-comprobante:$codigo'),
                data: codigo,
                size: lado - 2 * Espaciado.e4,
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
        );
      },
    );
  }
}
