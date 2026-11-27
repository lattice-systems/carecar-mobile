import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:lucide_icons_flutter/lucide_icons_300.dart';

import '../../../api/excepciones.dart';
import '../../../l10n/app_localizations.dart';
import '../../../nucleo/diseno/componentes/aviso.dart';
import '../../../nucleo/diseno/componentes/boton_pildora.dart';
import '../../../nucleo/diseno/componentes/calendario.dart';
import '../../../nucleo/diseno/componentes/estado_error.dart';
import '../../../nucleo/diseno/componentes/estado_vacio.dart';
import '../../../nucleo/diseno/componentes/fila_acciones.dart';
import '../../../nucleo/diseno/componentes/marco_pantalla.dart';
import '../../../nucleo/diseno/componentes/resultado_pantalla.dart';
import '../../../nucleo/diseno/componentes/selector_franja.dart';
import '../../../nucleo/diseno/componentes/tono.dart';
import '../../../nucleo/diseno/tokens/espaciado.dart';
import '../../../nucleo/diseno/tokens/radios.dart';
import '../../../nucleo/diseno/tokens/tokens_pista.dart';
import '../../citas/citas.dart';
import '../dominio/campana_seguridad.dart';
import '../dominio/repositorio_garantia.dart';
import 'esqueleto_garantia.dart';
import 'formato_garantia.dart';
import 'proveedores_garantia.dart';

/// Agenda la atencion de una campana de seguridad (V2-M10.03): el cliente
/// elige dia y horario con cupo del taller y confirma. La cita nace con motivo
/// campana y la campana queda agendada. Si el horario se lleno, el auto ya
/// tiene cita ese dia o la campana ya estaba agendada, lo explica sin perder
/// lo elegido. Al terminar muestra el dia y la hora y lleva al comprobante.
class PantallaAgendarCampana extends ConsumerStatefulWidget {
  const PantallaAgendarCampana({
    required this.vehiculoId,
    required this.campanaId,
    super.key,
  });

  final int vehiculoId;
  final int campanaId;

  @override
  ConsumerState<PantallaAgendarCampana> createState() =>
      _PantallaAgendarCampanaState();
}

class _PantallaAgendarCampanaState
    extends ConsumerState<PantallaAgendarCampana> {
  DateTime? _mes;
  DateTime? _dia;
  FranjaDisponible? _franja;
  bool _enviando = false;
  String? _rechazo;
  CitaDeCampana? _cita;

  Future<void> _agendar() async {
    final franja = _franja;
    if (franja == null || _enviando) return;
    final textos = AppLocalizations.of(context);
    setState(() {
      _enviando = true;
      _rechazo = null;
    });
    try {
      final cita = await ref
          .read(campanasProvider(widget.vehiculoId).notifier)
          .agendar(
            campanaId: widget.campanaId,
            franjaId: franja.franjaId,
            fecha: franja.fecha,
          );
      if (!mounted) return;
      setState(() {
        _enviando = false;
        _cita = cita;
      });
    } on AgendaCampanaRechazada catch (rechazo) {
      if (!mounted) return;
      final sinCupo = rechazo.motivo == MotivoRechazoCampana.sinCupo;
      if (sinCupo) ref.invalidate(disponibilidadProvider);
      setState(() {
        _enviando = false;
        if (sinCupo) _franja = null;
        _rechazo = switch (rechazo.motivo) {
          MotivoRechazoCampana.sinCupo => textos.campanasAgendarSinCupo,
          MotivoRechazoCampana.citaDuplicada => textos.campanasAgendarDuplicada,
          MotivoRechazoCampana.yaAgendada => textos.campanasAgendarYaAgendada,
        };
      });
    } on Object {
      if (!mounted) return;
      setState(() {
        _enviando = false;
        _rechazo = textos.campanasAgendarError;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final cita = _cita;
    if (cita != null) return _agendada(context, cita);

    final titulo = textos.campanasAgendarTitulo;
    final campana = ref
        .watch(campanasProvider(widget.vehiculoId))
        .value
        ?.where((c) => c.id == widget.campanaId)
        .firstOrNull;

    return ref
        .watch(disponibilidadProvider)
        .when(
          skipLoadingOnReload: true,
          loading: () => MarcoPantalla.estado(
            titulo: titulo,
            subtitulo: campana?.titulo,
            estado: const EsqueletoGarantia(altos: [320, 96]),
          ),
          error: (error, _) => MarcoPantalla.estado(
            titulo: titulo,
            subtitulo: campana?.titulo,
            estado: EstadoError(
              causa: error is SinConexion
                  ? CausaError.sinConexion
                  : CausaError.generico,
              textoReintentar: textos.garantiaReintentar,
              alReintentar: () => ref.invalidate(disponibilidadProvider),
            ),
          ),
          data: (taller) => taller.sinCupoEnTodoElRango
              ? MarcoPantalla.estado(
                  titulo: titulo,
                  subtitulo: campana?.titulo,
                  estado: EstadoVacio(
                    titulo: textos.campanasAgendarTitulo,
                    mensaje: textos.campanasAgendarSinCupoRango,
                    icono: LucideIcons300.calendarX,
                  ),
                )
              : _formulario(context, taller, campana),
        );
  }

  Widget _formulario(
    BuildContext context,
    DisponibilidadTaller taller,
    CampanaSeguridad? campana,
  ) {
    final textos = AppLocalizations.of(context);
    final tokens = TokensPista.de(context);
    final c = tokens.colores;
    final t = tokens.tipografia;
    final rango = ref.watch(rangoAgendableProvider);
    final dia = _dia;
    final franjas = dia == null
        ? const <FranjaDisponible>[]
        : taller.franjasDe(dia);
    final indice = franjas.indexWhere((f) => f.franjaId == _franja?.franjaId);
    final rechazo = _rechazo;

    return MarcoPantalla(
      titulo: textos.campanasAgendarTitulo,
      subtitulo: campana?.titulo,
      alRefrescar: () async {
        ref.invalidate(disponibilidadProvider);
        await ref.read(disponibilidadProvider.future);
      },
      barraInferior: BarraInferior(
        hijos: [
          if (rechazo != null) ...[
            Aviso(mensaje: rechazo, tono: Tono.advertencia),
            const SizedBox(height: Espaciado.e3),
          ],
          BotonPildora(
            texto: textos.campanasAgendarConfirmar,
            expandido: true,
            cargando: _enviando,
            alPresionar: _franja == null ? null : _agendar,
          ),
        ],
      ),
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SeccionPantalla(
                titulo: textos.campanasAgendarDia,
                conMargen: false,
                hijo: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Espaciado.e3),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: c.superficie,
                      borderRadius: Radios.bordeTarjeta,
                      boxShadow: tokens.sombras,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: Espaciado.e3,
                      ),
                      child: Calendario(
                        mes: _mes ?? rango.desde,
                        seleccionado: dia,
                        primerDia: rango.desde,
                        ultimoDia: rango.hasta,
                        hoy: rango.desde,
                        habilitado: taller.tieneCupo,
                        alCambiarMes: (mes) => setState(() => _mes = mes),
                        alSeleccionar: (elegido) => setState(() {
                          _dia = elegido;
                          _franja = null;
                          _rechazo = null;
                        }),
                      ),
                    ),
                  ),
                ),
              ),
              SeccionPantalla(
                titulo: textos.campanasAgendarHora,
                hijo: dia == null
                    ? Text(
                        textos.campanasAgendarSinDia,
                        style: t.cuerpo.copyWith(color: c.textoSecundario),
                      )
                    : SelectorFranja(
                        franjas: [
                          for (final f in franjas)
                            FranjaHoraria(etiqueta: f.horaInicio, cupo: f.cupo),
                        ],
                        seleccionada: indice < 0 ? null : indice,
                        mensajeVacio: textos.campanasAgendarSinHorarios,
                        alSeleccionar: (i) => setState(() {
                          _franja = franjas[i];
                          _rechazo = null;
                        }),
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _agendada(BuildContext context, CitaDeCampana cita) {
    final textos = AppLocalizations.of(context);
    return ResultadoPantalla(
      titulo: textos.campanasAgendadaTitulo,
      mensaje: textos.campanasAgendadaMensaje(
        diaGarantia(context, cita.fecha),
        cita.horaInicio,
      ),
      principal: AccionPantalla(
        texto: textos.campanasVerComprobante,
        icono: LucideIcons300.qrCode,
        alPresionar: () =>
            context.pushReplacement(rutaComprobanteCita(cita.id)),
      ),
      secundaria: AccionPantalla(
        texto: textos.campanasAgendarVolver,
        alPresionar: () => Navigator.of(context).maybePop(),
      ),
    );
  }
}
