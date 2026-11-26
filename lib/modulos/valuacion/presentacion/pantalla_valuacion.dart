import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../api/excepciones.dart';
import '../../../l10n/app_localizations.dart';
import '../../../nucleo/diseno/componentes/aviso.dart';
import '../../../nucleo/diseno/componentes/boton_pildora.dart';
import '../../../nucleo/diseno/componentes/deslizar_para_confirmar.dart';
import '../../../nucleo/diseno/componentes/dialogo.dart';
import '../../../nucleo/diseno/componentes/estado_vacio.dart';
import '../../../nucleo/diseno/componentes/galeria_fotos.dart';
import '../../../nucleo/diseno/componentes/linea_de_tiempo.dart';
import '../../../nucleo/diseno/componentes/marco_pantalla.dart';
import '../../../nucleo/diseno/componentes/tarjeta_metrica.dart';
import '../../../nucleo/diseno/componentes/tarjeta_resumen.dart';
import '../../../nucleo/diseno/componentes/tono.dart';
import '../../../nucleo/diseno/tokens/espaciado.dart';
import '../../../nucleo/diseno/tokens/tokens_pista.dart';
import '../../citas/citas.dart';
import '../dominio/repositorio_valuacion.dart';
import '../dominio/valuacion.dart';
import 'formato_valuacion.dart';
import 'piezas_valuacion.dart';
import 'proveedores_valuacion.dart';
import 'rutas_valuacion.dart';

/// El detalle de una valuacion formal (V2-M26.01 a V2-M26.04): el auto, el
/// rango estimado con la leyenda no vinculante, el avance en tres pasos, las
/// fotos subidas, la cita y el asesor. Con una oferta vigente deja aceptarla
/// deslizando o rechazarla con confirmacion. Se actualiza sola cuando llega
/// la oferta. Resuelve cargando, datos, no encontrada, error y sin conexion.
class PantallaValuacion extends ConsumerStatefulWidget {
  const PantallaValuacion({required this.valuacionId, super.key});

  final int valuacionId;

  @override
  ConsumerState<PantallaValuacion> createState() => _PantallaValuacionState();
}

class _PantallaValuacionState extends ConsumerState<PantallaValuacion> {
  bool _respondiendo = false;
  String? _fallo;

  ValuacionNotifier get _notifier =>
      ref.read(valuacionProvider(widget.valuacionId).notifier);

  Future<void> _responder({
    required bool aceptada,
    required double monto,
  }) async {
    if (_respondiendo) return;
    final t = AppLocalizations.of(context);
    setState(() {
      _respondiendo = true;
      _fallo = null;
    });
    String? fallo;
    try {
      await _notifier.responder(aceptada: aceptada, monto: monto);
    } on ValuacionRechazada catch (rechazo) {
      fallo = rechazo.motivo == MotivoRechazoValuacion.ofertaVencida
          ? t.valuacionRespuestaVencida
          : t.valuacionRespuestaNoDisponible;
    } on SinConexion {
      fallo = t.valuacionSinConexionAccion;
    } on Object {
      fallo = t.valuacionRespuestaError;
    }
    if (!mounted) return;
    setState(() {
      _respondiendo = false;
      _fallo = fallo;
    });
  }

  Future<void> _confirmarRechazo(double monto) async {
    final t = AppLocalizations.of(context);
    final confirmado = await mostrarDialogo<bool>(
      context,
      builder: (dialogo) => Dialogo(
        titulo: t.valuacionRechazarTitulo,
        mensaje: t.valuacionRechazarMensaje(pesosValuacion(monto)),
        textoPrincipal: t.valuacionRechazarConfirmar,
        alPrincipal: () => Navigator.of(dialogo).pop(true),
        textoSecundario: t.valuacionRechazarCancelar,
        alSecundario: () => Navigator.of(dialogo).pop(false),
        peligro: true,
      ),
    );
    if (confirmado ?? false) {
      await _responder(aceptada: false, monto: monto);
    }
  }

  // Al volver de otra pantalla la cita o las fotos pudieron cambiar.
  Future<void> _abrir(String ruta) async {
    await context.push(ruta);
    if (mounted) await _notifier.recargar();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final titulo = t.valuacionDetalleTitulo;

    return ref
        .watch(valuacionProvider(widget.valuacionId))
        .when(
          skipLoadingOnReload: true,
          loading: () => MarcoPantalla.estado(
            titulo: titulo,
            conRegreso: true,
            estado: const EsqueletoValuacion(altos: [96, 120, 180]),
          ),
          error: (error, _) => MarcoPantalla.estado(
            titulo: titulo,
            conRegreso: true,
            estado: error is NoEncontrado
                ? EstadoVacio(
                    titulo: t.valuacionNoEncontradaTitulo,
                    mensaje: t.valuacionNoEncontradaMensaje,
                    icono: Icons.search_off_rounded,
                    textoAccion: t.valuacionMisTitulo,
                    alAccion: () => context.go(rutaValuaciones),
                  )
                : ErrorValuacion(
                    error: error,
                    alReintentar: () =>
                        ref.invalidate(valuacionProvider(widget.valuacionId)),
                  ),
          ),
          data: (valuacion) => MarcoPantalla(
            titulo: titulo,
            conRegreso: true,
            alRefrescar: () =>
                ref.refresh(valuacionProvider(widget.valuacionId).future),
            slivers: [
              SliverToBoxAdapter(child: _contenido(context, valuacion)),
            ],
          ),
        );
  }

  Widget _contenido(BuildContext context, Valuacion v) {
    final t = AppLocalizations.of(context);
    final fallo = _fallo;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            Espaciado.e4,
            Espaciado.e2,
            Espaciado.e4,
            0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TarjetaResumen(
                titulo: v.estimacion.auto,
                subtitulo: t.valuacionKm(milesValuacion(v.estimacion.km)),
                icono: Icons.directions_car_outlined,
                estado: textoEstadoValuacion(t, v.estado),
                tonoEstado: tonoEstadoValuacion(v.estado),
              ),
              if (fallo != null) ...[
                const SizedBox(height: Espaciado.e3),
                Aviso(mensaje: fallo, tono: Tono.advertencia),
              ],
            ],
          ),
        ),
        if (v.oferta != null) _oferta(context, v, v.oferta!),
        SeccionPantalla(
          titulo: t.valuacionEstimadoTitulo,
          hijo: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TarjetaMetrica(
                etiqueta: t.valuacionEstimadoRango,
                cifra: rangoValuacion(
                  t,
                  v.estimacion.minimo,
                  v.estimacion.maximo,
                ),
                detalle: t.valuacionEstimadaEl(
                  fechaValuacion(context, v.estimacion.creadaEn.toLocal()),
                ),
              ),
              const SizedBox(height: Espaciado.e2),
              Aviso(mensaje: t.calculadoraLeyenda),
            ],
          ),
        ),
        SeccionPantalla(
          titulo: t.valuacionAvanceTitulo,
          hijo: LineaDeTiempo(pasos: _pasos(context, v)),
        ),
        _fotos(context, v),
        if (v.cita != null || v.puedeAgendar) _inspeccion(context, v),
        if (v.asesor != null)
          SeccionPantalla(
            titulo: t.valuacionAsesorTitulo,
            hijo: TarjetaResumen(
              titulo: v.asesor!,
              subtitulo: t.valuacionAsesorDetalle,
              icono: Icons.person_outline_rounded,
            ),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            Espaciado.e4,
            Espaciado.e6,
            Espaciado.e4,
            0,
          ),
          child: BotonPildora(
            texto: t.valuacionVerValor,
            icono: Icons.show_chart_rounded,
            variante: VarianteBotonPildora.tonal,
            expandido: true,
            alPresionar: () => context.push(rutaValorVehiculo(v.vehiculoId)),
          ),
        ),
      ],
    );
  }

  List<PasoLinea> _pasos(BuildContext context, Valuacion v) {
    final t = AppLocalizations.of(context);
    final conOferta = v.oferta != null;
    final conCita = v.cita != null;
    final todas = v.fotos.length == TomaValuacion.values.length;
    final pidiendo = v.estado == EstadoValuacion.solicitada;

    return [
      PasoLinea(
        titulo: t.valuacionPasoFotos,
        nota: t.valuacionFotosAvance(
          v.fotos.length,
          TomaValuacion.values.length,
        ),
        estado: todas
            ? EstadoPaso.hecho
            : pidiendo
            ? EstadoPaso.actual
            : EstadoPaso.pendiente,
      ),
      PasoLinea(
        titulo: t.valuacionPasoInspeccion,
        nota: conCita ? diaValuacion(context, v.cita!.fecha) : null,
        estado: conOferta
            ? EstadoPaso.hecho
            : v.estado == EstadoValuacion.citaAgendada || (pidiendo && todas)
            ? EstadoPaso.actual
            : EstadoPaso.pendiente,
      ),
      PasoLinea(
        titulo: t.valuacionPasoOferta,
        nota: conOferta ? textoEstadoValuacion(t, v.estado) : null,
        estado: !conOferta
            ? EstadoPaso.pendiente
            : v.ofertaPorResponder
            ? EstadoPaso.actual
            : EstadoPaso.hecho,
      ),
    ];
  }

  Widget _oferta(BuildContext context, Valuacion v, OfertaValuacion oferta) {
    final t = AppLocalizations.of(context);
    final tokens = TokensPista.de(context);
    final aviso = switch (v.estado) {
      EstadoValuacion.aceptada => (t.valuacionOfertaAceptada, Tono.exito),
      EstadoValuacion.rechazada => (
        t.valuacionOfertaRechazada,
        Tono.informacion,
      ),
      EstadoValuacion.vencida => (t.valuacionOfertaVencida, Tono.advertencia),
      _ => null,
    };

    return SeccionPantalla(
      titulo: t.valuacionOfertaTitulo,
      hijo: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TarjetaMetrica(
            etiqueta: t.valuacionOfertaEtiqueta,
            cifra: pesosValuacion(oferta.monto),
            detalle: t.valuacionOfertaVigencia(
              fechaValuacion(context, oferta.vigenciaHasta),
            ),
          ),
          if (oferta.nota case final nota?) ...[
            const SizedBox(height: Espaciado.e2),
            Text(
              nota,
              style: tokens.tipografia.cuerpo.copyWith(
                color: tokens.colores.texto,
              ),
            ),
          ],
          if (aviso != null) ...[
            const SizedBox(height: Espaciado.e3),
            Aviso(mensaje: aviso.$1, tono: aviso.$2),
          ],
          if (v.ofertaPorResponder) ...[
            const SizedBox(height: Espaciado.e4),
            DeslizarParaConfirmar(
              texto: t.valuacionAceptar,
              mensajeConfirmacion: t.valuacionAceptarMensaje(
                pesosValuacion(oferta.monto),
              ),
              alConfirmar: _respondiendo
                  ? null
                  : () => _responder(aceptada: true, monto: oferta.monto),
            ),
            const SizedBox(height: Espaciado.e3),
            BotonPildora(
              texto: t.valuacionRechazar,
              variante: VarianteBotonPildora.peligro,
              expandido: true,
              cargando: _respondiendo,
              alPresionar: () => _confirmarRechazo(oferta.monto),
            ),
          ],
        ],
      ),
    );
  }

  Widget _fotos(BuildContext context, Valuacion v) {
    final t = AppLocalizations.of(context);
    final imagen = ref.watch(imagenValuacionProvider);
    return SeccionPantalla(
      titulo: t.valuacionFotosTitulo,
      hijo: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GaleriaFotos(
            // Una foto nueva reinicia la galeria en la primera.
            key: ValueKey(v.fotos.length),
            mensajeVacio: t.valuacionFotosVacio,
            fotos: [
              for (final f in v.fotos)
                FotoGaleria(
                  imagen: imagen(f.url),
                  descripcion: nombreToma(t, f.toma),
                ),
            ],
          ),
          if (v.estado.admiteFotos) ...[
            const SizedBox(height: Espaciado.e3),
            BotonPildora(
              texto: t.valuacionFotosSubir,
              icono: Icons.photo_camera_outlined,
              expandido: true,
              alPresionar: () => _abrir(rutaFotosValuacion(v.id)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _inspeccion(BuildContext context, Valuacion v) {
    final t = AppLocalizations.of(context);
    final cita = v.cita;
    return SeccionPantalla(
      titulo: t.valuacionInspeccionTitulo,
      hijo: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (cita != null) ...[
            TarjetaResumen(
              titulo: diaValuacion(context, cita.fecha),
              subtitulo: t.valuacionInspeccionHorario(
                cita.horaInicio,
                cita.horaFin,
              ),
              icono: Icons.event_available_outlined,
            ),
            const SizedBox(height: Espaciado.e3),
            BotonPildora(
              texto: t.valuacionInspeccionVerCitas,
              variante: VarianteBotonPildora.tonal,
              expandido: true,
              alPresionar: () => _abrir(rutaMisCitas),
            ),
          ],
          // Solo el servidor decide si se puede agendar.
          if (v.puedeAgendar) ...[
            if (cita != null) const SizedBox(height: Espaciado.e3),
            BotonPildora(
              texto: t.valuacionAgendar,
              icono: Icons.event_outlined,
              expandido: true,
              alPresionar: () => _abrir(rutaCitaValuacion(v.id)),
            ),
          ],
        ],
      ),
    );
  }
}
