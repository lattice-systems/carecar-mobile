import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:lucide_icons_flutter/lucide_icons_300.dart';

import '../../../api/excepciones.dart';
import '../../../l10n/app_localizations.dart';
import '../../../nucleo/diseno/componentes/aviso.dart';
import '../../../nucleo/diseno/componentes/boton_pildora.dart';
import '../../../nucleo/diseno/componentes/calendario.dart';
import '../../../nucleo/diseno/componentes/estado_vacio.dart';
import '../../../nucleo/diseno/componentes/fila_acciones.dart';
import '../../../nucleo/diseno/componentes/marco_pantalla.dart';
import '../../../nucleo/diseno/componentes/resultado_pantalla.dart';
import '../../../nucleo/diseno/componentes/selector_franja.dart';
import '../../../nucleo/diseno/componentes/tono.dart';
import '../../../nucleo/diseno/tokens/espaciado.dart';
import '../../../nucleo/diseno/tokens/tokens_pista.dart';
import '../../citas/citas.dart';
import '../dominio/repositorio_valuacion.dart';
import '../dominio/valuacion.dart';
import 'formato_valuacion.dart';
import 'piezas_valuacion.dart';
import 'proveedores_valuacion.dart';

/// Agenda la inspeccion fisica (V2-M26.03): el cliente elige dia y horario con
/// cupo del taller y confirma. La cita nace con motivo valuacion. Si el
/// horario se lleno, el auto ya tiene cita ese dia o la valuacion ya no se
/// puede agendar, lo explica sin perder lo elegido.
class PantallaAgendarInspeccion extends ConsumerStatefulWidget {
  const PantallaAgendarInspeccion({required this.valuacionId, super.key});

  final int valuacionId;

  @override
  ConsumerState<PantallaAgendarInspeccion> createState() =>
      _PantallaAgendarInspeccionState();
}

class _PantallaAgendarInspeccionState
    extends ConsumerState<PantallaAgendarInspeccion> {
  DateTime? _mes;
  DateTime? _dia;
  FranjaDisponible? _franja;
  bool _enviando = false;
  String? _rechazo;
  InspeccionValuacion? _cita;

  Future<void> _agendar() async {
    final franja = _franja;
    if (franja == null || _enviando) return;
    final t = AppLocalizations.of(context);
    setState(() {
      _enviando = true;
      _rechazo = null;
    });
    try {
      final cita = await ref.read(agendarInspeccionProvider)(
        widget.valuacionId,
        franja,
      );
      if (!mounted) return;
      setState(() {
        _enviando = false;
        _cita = cita;
      });
    } on ValuacionRechazada catch (rechazo) {
      if (!mounted) return;
      final sinCupo = rechazo.motivo == MotivoRechazoValuacion.sinCupo;
      if (sinCupo) ref.invalidate(disponibilidadProvider);
      setState(() {
        _enviando = false;
        if (sinCupo) _franja = null;
        _rechazo = switch (rechazo.motivo) {
          MotivoRechazoValuacion.sinCupo => t.valuacionAgendarSinCupo,
          MotivoRechazoValuacion.citaDuplicada => t.valuacionAgendarDuplicada,
          MotivoRechazoValuacion.noAgendable => t.valuacionAgendarNoAgendable,
          _ => t.valuacionAgendarError,
        };
      });
    } on Object catch (error) {
      if (!mounted) return;
      setState(() {
        _enviando = false;
        _rechazo = error is SinConexion
            ? t.valuacionSinConexionAccion
            : t.valuacionAgendarError;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final cita = _cita;
    if (cita != null) return _agendada(context, cita);

    final titulo = t.valuacionAgendar;
    final auto = ref
        .watch(valuacionProvider(widget.valuacionId))
        .value
        ?.estimacion
        .auto;

    return ref
        .watch(disponibilidadProvider)
        .when(
          skipLoadingOnReload: true,
          loading: () => MarcoPantalla.estado(
            icono: LucideIcons300.calendarPlus,
            titulo: titulo,
            subtitulo: auto,
            conRegreso: true,
            estado: const EsqueletoValuacion(altos: [320, 96]),
          ),
          error: (error, _) => MarcoPantalla.estado(
            icono: LucideIcons300.calendarPlus,
            titulo: titulo,
            subtitulo: auto,
            conRegreso: true,
            estado: ErrorValuacion(
              error: error,
              alReintentar: () => ref.invalidate(disponibilidadProvider),
            ),
          ),
          data: (taller) => taller.sinCupoEnTodoElRango
              ? MarcoPantalla.estado(
                  icono: LucideIcons300.calendarPlus,
                  titulo: titulo,
                  subtitulo: auto,
                  conRegreso: true,
                  estado: EstadoVacio(
                    titulo: t.valuacionAgendarVacioTitulo,
                    mensaje: t.valuacionAgendarVacioMensaje,
                    icono: LucideIcons300.calendarX,
                  ),
                )
              : _formulario(context, taller, auto),
        );
  }

  Widget _formulario(
    BuildContext context,
    DisponibilidadTaller taller,
    String? auto,
  ) {
    final t = AppLocalizations.of(context);
    final tokens = TokensPista.de(context);
    final rango = ref.watch(rangoAgendableProvider);
    final dia = _dia;
    final franjas = dia == null
        ? const <FranjaDisponible>[]
        : taller.franjasDe(dia);
    final indice = franjas.indexWhere((f) => f.franjaId == _franja?.franjaId);
    final rechazo = _rechazo;

    return MarcoPantalla(
      icono: LucideIcons300.calendarPlus,
      titulo: t.valuacionAgendar,
      subtitulo: auto,
      conRegreso: true,
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
            texto: t.valuacionAgendarConfirmar,
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
                titulo: t.valuacionAgendarDia,
                // Con 12 de margen y sin relleno, en un telefono de 360 cada
                // dia del calendario conserva sus 48 de ancho.
                conMargen: false,
                hijo: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Espaciado.e3),
                  child: SuperficieValuacion(
                    relleno: 0,
                    hijo: Calendario(
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
              SeccionPantalla(
                titulo: t.valuacionAgendarHorario,
                hijo: dia == null
                    ? Text(
                        t.valuacionAgendarSinDia,
                        style: tokens.tipografia.cuerpo.copyWith(
                          color: tokens.colores.textoSecundario,
                        ),
                      )
                    : SelectorFranja(
                        franjas: [
                          for (final f in franjas)
                            FranjaHoraria(etiqueta: f.horaInicio, cupo: f.cupo),
                        ],
                        seleccionada: indice < 0 ? null : indice,
                        mensajeVacio: t.valuacionAgendarSinHorarios,
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

  Widget _agendada(BuildContext context, InspeccionValuacion cita) {
    final t = AppLocalizations.of(context);
    return ResultadoPantalla(
      titulo: t.valuacionAgendadaTitulo,
      mensaje: t.valuacionAgendadaMensaje(
        diaValuacion(context, cita.fecha),
        cita.horaInicio,
      ),
      principal: AccionPantalla(
        texto: t.valuacionAgendadaVerCitas,
        icono: LucideIcons300.calendar,
        alPresionar: () => context.pushReplacement(rutaMisCitas),
      ),
      secundaria: AccionPantalla(
        texto: t.valuacionAgendadaVolver,
        alPresionar: () => Navigator.of(context).maybePop(),
      ),
    );
  }
}
