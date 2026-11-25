import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../api/excepciones.dart';
import '../../../l10n/app_localizations.dart';
import '../../../nucleo/diseno/componentes/boton_pildora.dart';
import '../../../nucleo/diseno/componentes/esqueleto.dart';
import '../../../nucleo/diseno/componentes/estado_error.dart';
import '../../../nucleo/diseno/componentes/grupo_lista.dart';
import '../../../nucleo/diseno/componentes/visor_pdf.dart';
import '../../../nucleo/diseno/tokens/espaciado.dart';
import '../../../nucleo/diseno/tokens/radios.dart';
import '../../../nucleo/diseno/tokens/tokens_pista.dart';
import '../../recoleccion/recoleccion.dart';
import '../dominio/comprobante_de_cita.dart';
import 'boton_agregar_a_wallet.dart';
import 'boton_agregar_al_calendario.dart';
import 'componentes/grupo_recoleccion_cita.dart';
import '../../../nucleo/diseno/componentes/marco_pantalla.dart';
import 'proveedores_citas.dart';

/// Comprobante de una cita con su QR para recepcion rapida (V2-M02.11).
///
/// El QR lleva el id de la cita firmado por el backend; recepcion lo escanea
/// y la cita se reconoce sin buscarla. El QR es el contenido de la pantalla:
/// va en su tarjeta blanca bajo el encabezado, con «Agregar a Wallet» y «Ver
/// PDF» como pildoras. Desde
/// aqui tambien se abre el PDF que entrega `GET /citas/{id}/ticket`. Resuelve
/// los cinco estados: cargando, datos, error con reintento y sin conexion (no
/// hay "vacio": una cita sin comprobante es un error).
class PantallaComprobanteCita extends ConsumerWidget {
  const PantallaComprobanteCita({
    required this.citaId,
    super.key,
    this.fabricaVisorPdf,
    this.recoleccion,
  });

  final int citaId;

  /// Los traslados de la cita cuando se agendo con recoleccion (V2-M17.02).
  /// El comprobante del servidor no los trae: llegan de la confirmacion.
  final RecoleccionAgendada? recoleccion;

  /// Sustituye el motor de PDF (solo pruebas); nulo usa el del sistema.
  final FabricaVisorPdf? fabricaVisorPdf;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textos = AppLocalizations.of(context);
    final comprobante = ref.watch(comprobanteCitaProvider(citaId));

    return comprobante.when(
      skipLoadingOnReload: true,
      loading: () => MarcoPantalla.estado(
        titulo: textos.citasComprobanteTitulo,
        estado: const _Cargando(),
      ),
      error: (error, _) => MarcoPantalla.estado(
        titulo: textos.citasComprobanteTitulo,
        estado: EstadoError(
          causa: error is SinConexion
              ? CausaError.sinConexion
              : CausaError.generico,
          alReintentar: () => ref.invalidate(comprobanteCitaProvider(citaId)),
        ),
      ),
      data: (datos) => MarcoPantalla(
        titulo: textos.citasComprobanteFolio(datos.citaId),
        subtitulo: textos.citasComprobanteCuando(
          datos.fecha,
          datos.horaInicio,
          datos.horaFin,
        ),
        slivers: [
          SliverToBoxAdapter(
            child: _Comprobante(
              datos: datos,
              fabricaVisorPdf: fabricaVisorPdf,
              recoleccion: recoleccion,
            ),
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
      child: const SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.all(Espaciado.e4),
          child: Column(
            children: [
              Esqueleto(alto: 280, radio: 28),
              SizedBox(height: Espaciado.e3),
              Esqueleto(alto: 56),
            ],
          ),
        ),
      ),
    );
  }
}

class _Comprobante extends ConsumerWidget {
  const _Comprobante({
    required this.datos,
    this.fabricaVisorPdf,
    this.recoleccion,
  });

  final ComprobanteDeCita datos;
  final FabricaVisorPdf? fabricaVisorPdf;
  final RecoleccionAgendada? recoleccion;

  static const double _lado = 220;

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
        Padding(
          padding: const EdgeInsets.fromLTRB(
            Espaciado.e4,
            Espaciado.e2,
            Espaciado.e4,
            Espaciado.e5,
          ),
          child: _TarjetaQr(codigo: datos.codigo, lado: _lado),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Espaciado.e4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              BotonAgregarAWallet(citaId: datos.citaId, pildora: true),
              const SizedBox(height: Espaciado.e2),
              BotonAgregarAlCalendario(cita: datos),
              const SizedBox(height: Espaciado.e2),
              BotonPildora(
                texto: textos.citasComprobanteVerPdf,
                icono: Icons.picture_as_pdf_outlined,
                variante: VarianteBotonPildora.vidrio,
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
        if (recoleccion != null) ...[
          const SizedBox(height: Espaciado.e4),
          GrupoRecoleccionCita(recoleccion: recoleccion!),
        ],
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

/// El QR sobre su tarjeta blanca, centrado.
///
/// Un QR se lee mejor negro sobre blanco en cualquier tema: el contraste lo
/// exige el escaner, no el tema; por eso la tarjeta es blanca tambien en
/// oscuro. Para el lector de pantalla es una imagen con su descripcion.
class _TarjetaQr extends StatelessWidget {
  const _TarjetaQr({required this.codigo, required this.lado});

  final String codigo;
  final double lado;

  @override
  Widget build(BuildContext context) {
    final tokens = TokensPista.de(context);
    final textos = AppLocalizations.of(context);
    return Center(
      child: Semantics(
        image: true,
        label: textos.citasComprobanteQrDescripcion,
        excludeSemantics: true,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(Radios.hoja),
            boxShadow: tokens.sombras,
          ),
          child: Padding(
            padding: const EdgeInsets.all(Espaciado.e5),
            child: QrImageView(
              key: ValueKey('qr-comprobante:$codigo'),
              data: codigo,
              size: lado,
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
    );
  }
}
