import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../api/excepciones.dart';
import '../../../l10n/app_localizations.dart';
import '../../../nucleo/diseno/componentes/aviso.dart';
import '../../../nucleo/diseno/componentes/esqueleto.dart';
import '../../../nucleo/diseno/componentes/estado_error.dart';
import '../../../nucleo/diseno/componentes/estado_vacio.dart';
import '../../../nucleo/diseno/componentes/fila_acciones.dart';
import '../../../nucleo/diseno/componentes/grupo_lista.dart';
import '../../../nucleo/diseno/componentes/marco_pantalla.dart';
import '../../../nucleo/diseno/componentes/tarjeta_resumen.dart';
import '../../../nucleo/diseno/componentes/tono.dart';
import '../../../nucleo/diseno/tokens/espaciado.dart';
import '../../../nucleo/diseno/tokens/tokens_pista.dart';
import '../../../nucleo/eventos/proveedores_eventos.dart';
import '../../citas/citas.dart';
import '../dominio/plan_mantenimiento.dart';
import 'formato_mantenimiento.dart';
import 'proveedores_mantenimiento.dart';
import 'rutas_mantenimiento.dart';
import 'tarjeta_proximo_servicio.dart';

/// Plan de mantenimiento de un vehículo (V2-M05.01 y V2-M05.02): el próximo
/// servicio en una tarjeta de resumen (cuánto falta, fecha estimada y por qué
/// toca, con una barra del avance de kilometraje), el kilometraje vigente y la
/// lista de servicios del modelo con su estado (hecho, pendiente, próximo o
/// vencido).
///
/// «Agendar este servicio» abre Agendar cita con el vehículo y el motivo
/// mantenimiento ya elegidos (V2-M05.04). Resuelve los cinco estados:
/// cargando, datos, vacío (el modelo no tiene plan), error con reintento y sin
/// conexión.
class PantallaPlanMantenimiento extends ConsumerStatefulWidget {
  const PantallaPlanMantenimiento({required this.vehiculoId, super.key});

  final int vehiculoId;

  @override
  ConsumerState<PantallaPlanMantenimiento> createState() =>
      _EstadoPantallaPlanMantenimiento();
}

class _EstadoPantallaPlanMantenimiento
    extends ConsumerState<PantallaPlanMantenimiento> {
  bool _kmGuardado = false;

  /// Llego `mantenimiento.recordatorio` de este vehiculo (V2-M05.05).
  bool _recordatorio = false;

  Future<void> _registrarKm() async {
    final guardado = await context.push<bool>(
      rutaKilometraje(widget.vehiculoId),
    );
    if (guardado == true && mounted) setState(() => _kmGuardado = true);
  }

  void _agendar() => context.push(
    rutaAgendarCitaCon(
      vehiculoId: widget.vehiculoId,
      motivo: MotivoCita.mantenimiento,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final plan = ref.watch(planMantenimientoProvider(widget.vehiculoId));
    ref.listen(eventosProvider, (_, evento) {
      final datos = evento.value;
      if (datos?.nombre == 'mantenimiento.recordatorio' &&
          datos?.datos['vehiculoId'] == widget.vehiculoId) {
        setState(() => _recordatorio = true);
        // El plan cambio de fondo (km o fecha): se vuelve a pedir.
        ref.invalidate(planMantenimientoProvider(widget.vehiculoId));
      }
    });

    final titulo = textos.mantenimientoTitulo;

    return plan.when(
      skipLoadingOnReload: true,
      loading: () => MarcoPantalla.estado(
        titulo: titulo,
        conRegreso: true,
        estado: const _Cargando(),
      ),
      error: (error, _) => MarcoPantalla.estado(
        titulo: titulo,
        conRegreso: true,
        estado: EstadoError(
          causa: error is SinConexion
              ? CausaError.sinConexion
              : CausaError.generico,
          alReintentar: () =>
              ref.invalidate(planMantenimientoProvider(widget.vehiculoId)),
        ),
      ),
      data: (p) => p.sinPlan
          ? MarcoPantalla.estado(
              titulo: titulo,
              conRegreso: true,
              estado: EstadoVacio(
                titulo: textos.mantenimientoVacioTitulo,
                mensaje: textos.mantenimientoVacioMensaje,
                icono: Icons.build_circle_outlined,
              ),
            )
          : _Plan(
              plan: p,
              vehiculoId: widget.vehiculoId,
              alRefrescar: () => ref.refresh(
                planMantenimientoProvider(widget.vehiculoId).future,
              ),
              kmGuardado: _kmGuardado,
              alCerrarAviso: () => setState(() => _kmGuardado = false),
              recordatorio: _recordatorio,
              alCerrarRecordatorio: () => setState(() => _recordatorio = false),
              alAgendar: _agendar,
              alRegistrarKm: _registrarKm,
            ),
    );
  }
}

class _Plan extends StatelessWidget {
  const _Plan({
    required this.plan,
    required this.vehiculoId,
    required this.alRefrescar,
    required this.kmGuardado,
    required this.alCerrarAviso,
    required this.recordatorio,
    required this.alCerrarRecordatorio,
    required this.alAgendar,
    required this.alRegistrarKm,
  });

  final PlanMantenimiento plan;

  /// El vehículo de la ruta: de él cuelgan el detalle de cada servicio.
  final int vehiculoId;
  final Future<void> Function() alRefrescar;
  final bool kmGuardado;
  final VoidCallback alCerrarAviso;
  final bool recordatorio;
  final VoidCallback alCerrarRecordatorio;
  final VoidCallback alAgendar;
  final VoidCallback alRegistrarKm;

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final c = TokensPista.de(context).colores;
    final proximo = plan.proximo;

    return MarcoPantalla(
      titulo: textos.mantenimientoTitulo,
      conRegreso: true,
      alRefrescar: alRefrescar,
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: Espaciado.e4),
          sliver: SliverList.list(
            children: [
              if (recordatorio) ...[
                const SizedBox(height: Espaciado.e2),
                Aviso(
                  mensaje: textos.mantenimientoRecordatorioEnVivo,
                  tono: Tono.advertencia,
                  alCerrar: alCerrarRecordatorio,
                ),
              ] else if (kmGuardado) ...[
                const SizedBox(height: Espaciado.e2),
                Aviso(
                  mensaje: textos.mantenimientoKmGuardado,
                  tono: Tono.exito,
                  alCerrar: alCerrarAviso,
                ),
              ],
              const SizedBox(height: Espaciado.e2),
              _resumenProximo(context, proximo),
              const SizedBox(height: Espaciado.e4),
              FilaAcciones(
                principal: proximo == null
                    ? AccionPantalla(
                        texto: textos.mantenimientoRegistrarKm,
                        icono: Icons.speed_outlined,
                        alPresionar: alRegistrarKm,
                      )
                    : AccionPantalla(
                        texto: textos.mantenimientoAgendar,
                        icono: Icons.event_available_outlined,
                        alPresionar: alAgendar,
                      ),
                secundaria: proximo == null
                    ? null
                    : AccionPantalla(
                        texto: textos.mantenimientoRegistrarKm,
                        icono: Icons.speed_outlined,
                        alPresionar: alRegistrarKm,
                      ),
              ),
              const SizedBox(height: Espaciado.e6),
              GrupoLista(
                encabezado: textos.mantenimientoEncabezadoKm,
                filas: [
                  FilaGrupo(
                    titulo: plan.kmActual == null
                        ? textos.mantenimientoKmSinDato
                        : textos.mantenimientoKilometros(
                            formatearKm(context, plan.kmActual!),
                          ),
                    subtitulo: _fuenteKm(context, plan),
                    icono: Icons.speed_outlined,
                    colorIcono: c.acento,
                    alToque: alRegistrarKm,
                  ),
                  if (plan.promedioKmDiario != null)
                    FilaGrupo(
                      titulo: textos.mantenimientoPromedio(
                        formatearKm(context, plan.promedioKmDiario!.round()),
                      ),
                      icono: Icons.trending_up,
                      colorIcono: c.marca,
                    ),
                ],
              ),
              const SizedBox(height: Espaciado.e4),
              GrupoLista(
                encabezado: textos.mantenimientoEncabezadoPlan,
                filas: [for (final s in plan.servicios) _fila(context, s)],
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// El próximo servicio en la misma tarjeta que usa el inicio. Sin próximo
  /// servicio estimado falta el kilometraje: es un aviso informativo con el
  /// icono del tablero, no una buena noticia (de ahí que no lleve palomita).
  Widget _resumenProximo(BuildContext context, ProximoServicio? proximo) {
    final textos = AppLocalizations.of(context);
    if (proximo == null) {
      return TarjetaResumen(
        titulo: textos.mantenimientoSinProximoTitulo,
        subtitulo: textos.mantenimientoSinProximoMensaje,
        icono: Icons.speed_outlined,
      );
    }
    return TarjetaProximoServicio(
      proximo: proximo,
      avance: plan.avanceDelProximo,
    );
  }

  /// Quién dejó el km vigente y cuándo; sin dato lo dice.
  String _fuenteKm(BuildContext context, PlanMantenimiento plan) {
    final textos = AppLocalizations.of(context);
    final fecha = plan.kmActualizadoEn;
    if (plan.kmActual == null || fecha == null || plan.kmFuente == null) {
      return textos.mantenimientoKmSinFuente;
    }
    final texto = formatearFecha(context, fecha);
    return switch (plan.kmFuente!) {
      FuenteKm.taller => textos.mantenimientoKmDelTaller(texto),
      FuenteKm.cliente => textos.mantenimientoKmDelCliente(texto),
    };
  }

  FilaGrupo _fila(BuildContext context, ServicioMantenimiento s) {
    final textos = AppLocalizations.of(context);
    final c = TokensPista.de(context).colores;
    final resumen = textos.mantenimientoResumenServicio(
      formatearKm(context, s.km),
      '${s.meses}',
    );
    final estado = s.estado == EstadoServicio.hecho && s.hechoEn != null
        ? textos.mantenimientoHechoEl(formatearFecha(context, s.hechoEn!))
        : textoEstado(textos, s.estado);
    // El estado va en el texto: el lector de pantalla no lee el adorno final.
    final lineaDeEstado = '$estado · $resumen';
    final (icono, color) = switch (s.estado) {
      EstadoServicio.hecho => (Icons.check_rounded, c.exito),
      EstadoServicio.pendiente => (Icons.schedule_outlined, c.marca),
      EstadoServicio.proximo => (Icons.event_outlined, c.acento),
      EstadoServicio.vencido => (Icons.priority_high_rounded, c.peligro),
    };
    return FilaGrupo(
      titulo: s.nombre,
      subtitulo: lineaDeEstado,
      icono: icono,
      colorIcono: color,
      alToque: () => context.push(rutaServicioMantenimiento(vehiculoId, s.id)),
    );
  }
}

class _Cargando extends StatelessWidget {
  const _Cargando();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: AppLocalizations.of(context).mantenimientoCargando,
      liveRegion: true,
      child: const SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
        padding: EdgeInsets.all(Espaciado.e4),
        child: Column(
          children: [
            Esqueleto(alto: 120),
            SizedBox(height: Espaciado.e3),
            Esqueleto(alto: 56),
            SizedBox(height: Espaciado.e3),
            Esqueleto(alto: 56),
          ],
        ),
      ),
    );
  }
}
