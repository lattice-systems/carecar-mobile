import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:lucide_icons_flutter/lucide_icons_300.dart';

import '../../../api/excepciones.dart';
import '../../../l10n/app_localizations.dart';
import '../../../nucleo/diseno/componentes/aviso.dart';
import '../../../nucleo/diseno/componentes/estado_error.dart';
import '../../../nucleo/diseno/componentes/estado_vacio.dart';
import '../../../nucleo/diseno/componentes/fila_acciones.dart';
import '../../../nucleo/diseno/componentes/marco_pantalla.dart';
import '../../../nucleo/diseno/componentes/tono.dart';
import '../../../nucleo/diseno/tokens/espaciado.dart';
import '../../../nucleo/diseno/tokens/tokens_pista.dart';
import '../../citas/citas.dart';
import '../dominio/campana_seguridad.dart';
import 'esqueleto_garantia.dart';
import 'pantalla_campanas.dart';
import 'proveedores_garantia.dart';
import 'rutas_garantia.dart';

/// Detalle de una campana de seguridad (V2-M10.02): su resumen, que pasa y
/// que hacer. Si esta pendiente se agenda desde aqui (V2-M10.03); si ya tiene
/// cita lleva a las citas. Lee la campana de la lista del vehiculo, asi que
/// se actualiza con ella (al agendar o con una campana nueva).
class PantallaCampana extends ConsumerWidget {
  const PantallaCampana({
    required this.vehiculoId,
    required this.campanaId,
    super.key,
  });

  final int vehiculoId;
  final int campanaId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textos = AppLocalizations.of(context);
    final titulo = textos.campanasTitulo;

    return ref
        .watch(campanasProvider(vehiculoId))
        .when(
          skipLoadingOnReload: true,
          loading: () => MarcoPantalla.estado(
            titulo: titulo,
            conRegreso: true,
            estado: const EsqueletoGarantia(altos: [96, 48, 120]),
          ),
          error: (error, _) => MarcoPantalla.estado(
            titulo: titulo,
            conRegreso: true,
            estado: EstadoError(
              causa: error is SinConexion
                  ? CausaError.sinConexion
                  : CausaError.generico,
              textoReintentar: textos.garantiaReintentar,
              alReintentar: () => ref.invalidate(campanasProvider(vehiculoId)),
            ),
          ),
          data: (campanas) {
            final campana = campanas
                .where((c) => c.id == campanaId)
                .firstOrNull;
            if (campana == null) {
              return MarcoPantalla.estado(
                titulo: titulo,
                conRegreso: true,
                estado: EstadoVacio(
                  titulo: textos.campanasNoEncontradaTitulo,
                  mensaje: textos.campanasNoEncontradaMensaje,
                  icono: LucideIcons300.megaphone,
                ),
              );
            }
            return _Detalle(
              campana: campana,
              vehiculoId: vehiculoId,
              alRefrescar: () =>
                  ref.refresh(campanasProvider(vehiculoId).future),
            );
          },
        );
  }
}

class _Detalle extends StatelessWidget {
  const _Detalle({
    required this.campana,
    required this.vehiculoId,
    required this.alRefrescar,
  });

  final CampanaSeguridad campana;
  final int vehiculoId;
  final Future<void> Function() alRefrescar;

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final tokens = TokensPista.de(context);
    final c = tokens.colores;
    final t = tokens.tipografia;
    final accion = switch (campana.estado) {
      EstadoCampana.abierta => AccionPantalla(
        texto: textos.campanasAgendar,
        icono: LucideIcons300.calendarCheck,
        alPresionar: () =>
            context.push(rutaAgendarCampana(vehiculoId, campana.id)),
      ),
      EstadoCampana.agendada => AccionPantalla(
        texto: textos.campanasVerCitas,
        icono: LucideIcons300.calendarDays,
        alPresionar: () => context.push(rutaMisCitas),
      ),
      EstadoCampana.atendida => null,
    };

    return MarcoPantalla(
      titulo: campana.titulo,
      subtitulo: textos.campanasCodigo(campana.codigo),
      conRegreso: true,
      alRefrescar: alRefrescar,
      slivers: [
        SliverList.list(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Espaciado.e4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: Espaciado.e2),
                  if (esCriticaPendiente(campana)) ...[
                    Aviso(
                      mensaje: textos.campanasAvisoCritica,
                      tono: Tono.peligro,
                    ),
                    const SizedBox(height: Espaciado.e4),
                  ],
                  TarjetaCampana(campana: campana),
                  if (accion != null) ...[
                    const SizedBox(height: Espaciado.e4),
                    FilaAcciones(principal: accion),
                  ],
                ],
              ),
            ),
            SeccionPantalla(
              titulo: textos.campanasQuePasa,
              hijo: Text(
                campana.descripcion,
                style: t.cuerpo.copyWith(color: c.texto),
              ),
            ),
            SeccionPantalla(
              titulo: textos.campanasQueHacer,
              hijo: Text(
                campana.queHacer,
                style: t.cuerpo.copyWith(color: c.texto),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
