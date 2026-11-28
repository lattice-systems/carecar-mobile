import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lucide_icons_flutter/lucide_icons_300.dart';

import '../../../api/excepciones.dart';
import '../../../l10n/app_localizations.dart';
import '../../../nucleo/diseno/componentes/esqueleto.dart';
import '../../../nucleo/diseno/componentes/estado_error.dart';
import '../../../nucleo/diseno/componentes/estado_vacio.dart';
import '../../../nucleo/diseno/tokens/espaciado.dart';
import '../dominio/disponibilidad_taller.dart';
import '../../../nucleo/diseno/componentes/marco_pantalla.dart';
import 'componentes/seleccion_dia_horario.dart';
import 'proveedores_citas.dart';

/// Calendario con la disponibilidad del taller (V2-M02.07).
///
/// Los dias sin cupo salen deshabilitados; al elegir un dia se listan sus
/// franjas con los lugares que quedan. Resuelve los cinco estados: cargando con
/// esqueleto, datos, vacio, error con reintento y sin conexion. Se puede
/// recargar jalando hacia abajo.
class PantallaDisponibilidad extends ConsumerStatefulWidget {
  const PantallaDisponibilidad({super.key});

  @override
  ConsumerState<PantallaDisponibilidad> createState() =>
      _EstadoPantallaDisponibilidad();
}

class _EstadoPantallaDisponibilidad
    extends ConsumerState<PantallaDisponibilidad> {
  DateTime? _mes;
  DateTime? _dia;
  int? _franja;

  @override
  Widget build(BuildContext context) {
    final disponibilidad = ref.watch(disponibilidadProvider);
    final textos = AppLocalizations.of(context);

    return disponibilidad.when(
      skipLoadingOnReload: true,
      loading: () => MarcoPantalla.estado(
        icono: LucideIcons300.clock,
        titulo: textos.citasTitulo,
        estado: const _Cargando(),
      ),
      error: (error, _) => MarcoPantalla.estado(
        icono: LucideIcons300.clock,
        titulo: textos.citasTitulo,
        estado: EstadoError(
          causa: error is SinConexion
              ? CausaError.sinConexion
              : CausaError.generico,
          alReintentar: () => ref.invalidate(disponibilidadProvider),
        ),
      ),
      data: (taller) => taller.sinCupoEnTodoElRango
          ? MarcoPantalla.estado(
              icono: LucideIcons300.clock,
              titulo: textos.citasTitulo,
              estado: EstadoVacio(
                titulo: textos.citasVacioTitulo,
                mensaje: textos.citasVacioMensaje,
                icono: LucideIcons300.calendarX,
              ),
            )
          : MarcoPantalla(
              icono: LucideIcons300.clock,
              titulo: textos.citasTitulo,
              alRefrescar: () => ref.refresh(disponibilidadProvider.future),
              slivers: [SliverToBoxAdapter(child: _contenido(context, taller))],
            ),
    );
  }

  Widget _contenido(BuildContext context, DisponibilidadTaller taller) {
    final rango = ref.watch(rangoAgendableProvider);
    final dia = _dia;
    final franjas = dia == null
        ? const <FranjaDisponible>[]
        : taller.franjasDe(dia);

    return SeleccionDiaHorario(
      taller: taller,
      rango: rango,
      mes: _mes ?? rango.desde,
      dia: dia,
      franjas: franjas,
      franjaSeleccionada: _franja,
      alCambiarMes: (mes) => setState(() => _mes = mes),
      alElegirDia: (d) => setState(() {
        _dia = d;
        _franja = null;
      }),
      alElegirFranja: (i) => setState(() => _franja = i),
    );
  }
}

class _Cargando extends StatelessWidget {
  const _Cargando();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: AppLocalizations.of(context).citasCargando,
      liveRegion: true,
      child: const SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.all(Espaciado.e4),
          child: Column(
            children: [
              Esqueleto(alto: 320),
              SizedBox(height: Espaciado.e3),
              Esqueleto(alto: 56),
            ],
          ),
        ),
      ),
    );
  }
}
