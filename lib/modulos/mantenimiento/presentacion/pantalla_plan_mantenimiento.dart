import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../api/excepciones.dart';
import '../../../l10n/app_localizations.dart';
import '../../../nucleo/diseno/componentes/aviso.dart';
import '../../../nucleo/diseno/componentes/barra_portada.dart';
import '../../../nucleo/diseno/componentes/boton_pildora.dart';
import '../../../nucleo/diseno/componentes/cabecera_portada.dart';
import '../../../nucleo/diseno/componentes/esqueleto.dart';
import '../../../nucleo/diseno/componentes/estado_error.dart';
import '../../../nucleo/diseno/componentes/estado_vacio.dart';
import '../../../nucleo/diseno/componentes/grupo_lista.dart';
import '../../../nucleo/diseno/componentes/tono.dart';
import '../../../nucleo/diseno/tokens/espaciado.dart';
import '../../../nucleo/diseno/tokens/tokens_pista.dart';
import '../../citas/citas.dart';
import '../dominio/plan_mantenimiento.dart';
import 'componentes/portada_mantenimiento.dart';
import 'formato_mantenimiento.dart';
import 'proveedores_mantenimiento.dart';
import 'rutas_mantenimiento.dart';

/// Plan de mantenimiento de un vehículo en estilo portada (V2-M05.01 y
/// V2-M05.02): el próximo servicio como héroe (cuánto falta, fecha estimada y
/// por qué toca), el kilometraje vigente y la lista de servicios del modelo
/// con su estado (hecho, pendiente, próximo o vencido).
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

  Future<void> _registrarKm() async {
    final guardado = await context.push<bool>(
      rutaKilometraje(widget.vehiculoId),
    );
    if (guardado == true && mounted) setState(() => _kmGuardado = true);
  }

  void _agendar() => context.push(
    localizacionAgendarCita(
      vehiculoId: widget.vehiculoId,
      motivo: MotivoCita.mantenimiento,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final plan = ref.watch(planMantenimientoProvider(widget.vehiculoId));

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: TokensPista.de(context).colores.fondo,
      appBar: BarraPortada(titulo: textos.mantenimientoTitulo),
      body: plan.when(
        skipLoadingOnReload: true,
        loading: () => const _Cargando(),
        error: (error, _) => SafeArea(
          child: EstadoError(
            causa: error is SinConexion
                ? CausaError.sinConexion
                : CausaError.generico,
            alReintentar: () =>
                ref.invalidate(planMantenimientoProvider(widget.vehiculoId)),
          ),
        ),
        data: (p) => p.sinPlan
            ? SafeArea(
                child: EstadoVacio(
                  titulo: textos.mantenimientoVacioTitulo,
                  mensaje: textos.mantenimientoVacioMensaje,
                  icono: Icons.build_circle_outlined,
                ),
              )
            : RefreshIndicator(
                onRefresh: () => ref.refresh(
                  planMantenimientoProvider(widget.vehiculoId).future,
                ),
                child: _Plan(
                  plan: p,
                  kmGuardado: _kmGuardado,
                  alCerrarAviso: () => setState(() => _kmGuardado = false),
                  alAgendar: _agendar,
                  alRegistrarKm: _registrarKm,
                ),
              ),
      ),
    );
  }
}

class _Plan extends StatelessWidget {
  const _Plan({
    required this.plan,
    required this.kmGuardado,
    required this.alCerrarAviso,
    required this.alAgendar,
    required this.alRegistrarKm,
  });

  final PlanMantenimiento plan;
  final bool kmGuardado;
  final VoidCallback alCerrarAviso;
  final VoidCallback alAgendar;
  final VoidCallback alRegistrarKm;

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final c = TokensPista.de(context).colores;
    final proximo = plan.proximo;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: Espaciado.e8),
      children: [
        CabeceraPortada(
          titulo: proximo?.nombre ?? textos.mantenimientoSinProximoTitulo,
          subtitulo: proximo == null
              ? textos.mantenimientoSinProximoMensaje
              : _subtituloProximo(context, proximo),
          descripcion: textos.mantenimientoDescripcionPortada,
          portada: PortadaMantenimiento(tinte: c.acento),
          principal: proximo == null
              ? AccionPortada(
                  texto: textos.mantenimientoRegistrarKm,
                  icono: Icons.speed_outlined,
                  alPresionar: alRegistrarKm,
                )
              : AccionPortada(
                  texto: textos.mantenimientoAgendar,
                  icono: Icons.event_available_outlined,
                  alPresionar: alAgendar,
                ),
          secundaria: proximo == null
              ? null
              : AccionPortada(
                  texto: textos.mantenimientoRegistrarKm,
                  icono: Icons.speed_outlined,
                  alPresionar: alRegistrarKm,
                ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Espaciado.e4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (kmGuardado) ...[
                Aviso(
                  mensaje: textos.mantenimientoKmGuardado,
                  tono: Tono.exito,
                  alCerrar: alCerrarAviso,
                ),
                const SizedBox(height: Espaciado.e4),
              ] else
                const SizedBox(height: Espaciado.e2),
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

  /// Línea del héroe: por qué toca y cuánto falta, o que ya toca.
  String _subtituloProximo(BuildContext context, ProximoServicio proximo) {
    final textos = AppLocalizations.of(context);
    final motivo = switch (proximo.motivo) {
      MotivoProximo.km => textos.mantenimientoMotivoKm,
      MotivoProximo.tiempo => textos.mantenimientoMotivoTiempo,
    };
    final falta = proximo.yaToca
        ? textos.mantenimientoYaToca(formatearKm(context, proximo.kmObjetivo))
        : textos.mantenimientoFaltan(
            formatearKm(context, proximo.faltanKm),
            formatearFecha(context, proximo.fechaEstimada),
          );
    return '$motivo\n$falta';
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
    final (icono, color) = switch (s.estado) {
      EstadoServicio.hecho => (Icons.check_rounded, c.exito),
      EstadoServicio.pendiente => (Icons.schedule_outlined, c.marca),
      EstadoServicio.proximo => (Icons.event_outlined, c.acento),
      EstadoServicio.vencido => (Icons.priority_high_rounded, c.peligro),
    };
    return FilaGrupo(
      titulo: s.nombre,
      subtitulo: '$estado · $resumen',
      icono: icono,
      colorIcono: color,
      alToque: () =>
          context.push(rutaServicioMantenimiento(plan.vehiculoId, s.id)),
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
      child: const SafeArea(
        child: Padding(
          padding: EdgeInsets.all(Espaciado.e4),
          child: Column(
            children: [
              Esqueleto(alto: 240),
              SizedBox(height: Espaciado.e3),
              Esqueleto(alto: 56),
              SizedBox(height: Espaciado.e3),
              Esqueleto(alto: 56),
            ],
          ),
        ),
      ),
    );
  }
}
