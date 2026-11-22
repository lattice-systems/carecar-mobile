import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../api/excepciones.dart';
import '../../../l10n/app_localizations.dart';
import '../../../nucleo/diseno/componentes/calendario.dart';
import '../../../nucleo/diseno/componentes/esqueleto.dart';
import '../../../nucleo/diseno/componentes/estado_error.dart';
import '../../../nucleo/diseno/componentes/estado_vacio.dart';
import '../../../nucleo/diseno/componentes/selector_franja.dart';
import '../../../nucleo/diseno/tokens/espaciado.dart';
import '../../../nucleo/diseno/tokens/tokens_pista.dart';
import '../dominio/disponibilidad_taller.dart';
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

    return Scaffold(
      appBar: AppBar(title: Text(textos.citasTitulo)),
      body: disponibilidad.when(
        skipLoadingOnReload: true,
        loading: () => const _Cargando(),
        error: (error, _) => EstadoError(
          causa: error is SinConexion
              ? CausaError.sinConexion
              : CausaError.generico,
          alReintentar: () => ref.invalidate(disponibilidadProvider),
        ),
        data: (taller) => taller.sinCupoEnTodoElRango
            ? EstadoVacio(
                titulo: textos.citasVacioTitulo,
                mensaje: textos.citasVacioMensaje,
                icono: Icons.event_busy_outlined,
              )
            : RefreshIndicator(
                onRefresh: () => ref.refresh(disponibilidadProvider.future),
                child: _contenido(context, taller),
              ),
      ),
    );
  }

  Widget _contenido(BuildContext context, DisponibilidadTaller taller) {
    final textos = AppLocalizations.of(context);
    final tokens = TokensPista.de(context);
    final rango = ref.watch(rangoAgendableProvider);
    final dia = _dia;
    final franjas = dia == null
        ? const <FranjaDisponible>[]
        : taller.franjasDe(dia);

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(Espaciado.e4),
      children: [
        Calendario(
          mes: _mes ?? rango.desde,
          seleccionado: dia,
          primerDia: rango.desde,
          ultimoDia: rango.hasta,
          hoy: rango.desde,
          habilitado: taller.tieneCupo,
          alCambiarMes: (mes) => setState(() => _mes = mes),
          alSeleccionar: (d) => setState(() {
            _dia = d;
            _franja = null;
          }),
        ),
        const SizedBox(height: Espaciado.e2),
        Text(
          textos.citasNotaDiasSinCupo,
          style: tokens.tipografia.cuerpoChico.copyWith(
            color: tokens.colores.textoSecundario,
          ),
        ),
        const SizedBox(height: Espaciado.e4),
        if (dia == null)
          Text(
            textos.citasSinDiaElegido,
            style: tokens.tipografia.cuerpo.copyWith(
              color: tokens.colores.textoSecundario,
            ),
          )
        else ...[
          Semantics(
            header: true,
            child: Text(
              textos.citasHorariosDelDia(dia),
              style: tokens.tipografia.cuerpoFuerte.copyWith(
                color: tokens.colores.texto,
              ),
            ),
          ),
          const SizedBox(height: Espaciado.e2),
          SelectorFranja(
            franjas: [
              for (final f in franjas)
                FranjaHoraria(etiqueta: f.horaInicio, cupo: f.cupo),
            ],
            seleccionada: _franja,
            mensajeVacio: textos.citasHorariosVacio,
            alSeleccionar: (i) => setState(() => _franja = i),
          ),
        ],
      ],
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
      child: const Padding(
        padding: EdgeInsets.all(Espaciado.e4),
        child: Column(
          children: [
            Esqueleto(alto: 320),
            SizedBox(height: Espaciado.e3),
            Esqueleto(alto: 56),
          ],
        ),
      ),
    );
  }
}
