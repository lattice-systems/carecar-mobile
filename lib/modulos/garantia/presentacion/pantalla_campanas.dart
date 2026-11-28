import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:lucide_icons_flutter/lucide_icons_300.dart';

import '../../../api/excepciones.dart';
import '../../../l10n/app_localizations.dart';
import '../../../nucleo/diseno/componentes/aviso.dart';
import '../../../nucleo/diseno/componentes/estado_error.dart';
import '../../../nucleo/diseno/componentes/estado_vacio.dart';
import '../../../nucleo/diseno/componentes/marco_pantalla.dart';
import '../../../nucleo/diseno/componentes/tarjeta_resumen.dart';
import '../../../nucleo/diseno/componentes/tono.dart';
import '../../../nucleo/diseno/tokens/espaciado.dart';
import '../dominio/campana_seguridad.dart';
import 'esqueleto_garantia.dart';
import 'formato_garantia.dart';
import 'proveedores_garantia.dart';
import 'rutas_garantia.dart';

/// Las campanas de seguridad del vehiculo (V2-M10.02): una tarjeta por
/// campana con titulo, codigo, gravedad y estado; al tocarla abre su detalle.
/// Una campana critica pendiente se avisa arriba. Se actualiza sola cuando se
/// publica una campana nueva para el vehiculo (V2-M10.04). Resuelve
/// esqueleto, datos, vacio, error y sin conexion; se recarga jalando hacia
/// abajo.
class PantallaCampanas extends ConsumerWidget {
  const PantallaCampanas({required this.vehiculoId, super.key});

  final int vehiculoId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textos = AppLocalizations.of(context);
    final titulo = textos.campanasTitulo;

    return ref
        .watch(campanasProvider(vehiculoId))
        .when(
          skipLoadingOnReload: true,
          loading: () => MarcoPantalla.estado(
            icono: LucideIcons300.megaphone,
            titulo: titulo,
            conRegreso: true,
            estado: const EsqueletoGarantia(altos: [96, 96]),
          ),
          error: (error, _) => MarcoPantalla.estado(
            icono: LucideIcons300.megaphone,
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
          data: (campanas) => campanas.isEmpty
              ? MarcoPantalla.estado(
                  icono: LucideIcons300.megaphone,
                  titulo: titulo,
                  conRegreso: true,
                  estado: EstadoVacio(
                    titulo: textos.campanasVaciaTitulo,
                    mensaje: textos.campanasVaciaMensaje,
                    icono: LucideIcons300.megaphone,
                  ),
                )
              : MarcoPantalla(
                  icono: LucideIcons300.megaphone,
                  titulo: titulo,
                  subtitulo: textos.campanasAccesoResumen,
                  conRegreso: true,
                  alRefrescar: () =>
                      ref.refresh(campanasProvider(vehiculoId).future),
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Espaciado.e4,
                      ),
                      sliver: SliverList.list(
                        children: [
                          const SizedBox(height: Espaciado.e2),
                          if (campanas.any(esCriticaPendiente)) ...[
                            Aviso(
                              mensaje: textos.campanasAvisoCritica,
                              tono: Tono.peligro,
                            ),
                            const SizedBox(height: Espaciado.e4),
                          ],
                          for (final campana in campanas) ...[
                            TarjetaCampana(
                              campana: campana,
                              alToque: () => context.push(
                                rutaCampanaVehiculo(vehiculoId, campana.id),
                              ),
                            ),
                            const SizedBox(height: Espaciado.e3),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
        );
  }
}

/// Una campana critica que todavia no se agenda ni se atiende.
bool esCriticaPendiente(CampanaSeguridad campana) =>
    campana.abierta && campana.gravedad == GravedadCampana.critica;

/// Una campana como tarjeta de resumen: titulo, codigo, gravedad y estado.
/// Con `alToque` abre su detalle.
class TarjetaCampana extends StatelessWidget {
  const TarjetaCampana({required this.campana, super.key, this.alToque});

  final CampanaSeguridad campana;
  final VoidCallback? alToque;

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    return TarjetaResumen(
      titulo: campana.titulo,
      subtitulo: textos.campanasCodigo(campana.codigo),
      detalle: textoGravedad(textos, campana.gravedad),
      icono: campana.gravedad == GravedadCampana.critica
          ? LucideIcons300.circleAlert
          : LucideIcons300.megaphone,
      tono: tonoGravedad(campana.gravedad),
      estado: textoEstadoCampana(textos, campana.estado),
      tonoEstado: tonoEstadoCampana(campana.estado),
      alToque: alToque,
    );
  }
}
