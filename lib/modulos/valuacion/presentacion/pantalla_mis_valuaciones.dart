import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:lucide_icons_flutter/lucide_icons_300.dart';

import '../../../l10n/app_localizations.dart';
import '../../../nucleo/diseno/componentes/aviso.dart';
import '../../../nucleo/diseno/componentes/boton_pildora.dart';
import '../../../nucleo/diseno/componentes/estado_vacio.dart';
import '../../../nucleo/diseno/componentes/marco_pantalla.dart';
import '../../../nucleo/diseno/componentes/tarjeta_resumen.dart';
import '../../../nucleo/diseno/componentes/tono.dart';
import '../../../nucleo/diseno/tokens/espaciado.dart';
import '../dominio/valuacion.dart';
import 'formato_valuacion.dart';
import 'piezas_valuacion.dart';
import 'proveedores_valuacion.dart';
import 'rutas_valuacion.dart';

/// Mis valuaciones (V2-M26.01), de la mas reciente a la mas antigua, con el
/// auto, el estado y, si hay, la oferta y su vigencia. Al tocar una abre su
/// detalle. Se actualiza sola cuando llega una oferta. Resuelve cargando,
/// datos, vacio, error y sin conexion; se recarga jalando hacia abajo.
class PantallaMisValuaciones extends ConsumerWidget {
  const PantallaMisValuaciones({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final titulo = t.valuacionMisTitulo;

    return ref
        .watch(misValuacionesProvider)
        .when(
          skipLoadingOnReload: true,
          loading: () => MarcoPantalla.estado(
            icono: LucideIcons300.badgeDollarSign,
            titulo: titulo,
            conRegreso: true,
            estado: const EsqueletoValuacion(altos: [112, 112, 112]),
          ),
          error: (error, _) => MarcoPantalla.estado(
            icono: LucideIcons300.badgeDollarSign,
            titulo: titulo,
            conRegreso: true,
            estado: ErrorValuacion(
              error: error,
              alReintentar: () => ref.invalidate(misValuacionesProvider),
            ),
          ),
          data: (estado) => estado.valuaciones.isEmpty
              ? MarcoPantalla.estado(
                  icono: LucideIcons300.badgeDollarSign,
                  titulo: titulo,
                  conRegreso: true,
                  estado: EstadoVacio(
                    titulo: t.valuacionMisVacioTitulo,
                    mensaje: t.valuacionMisVacioMensaje,
                    icono: LucideIcons300.badgeCheck,
                    textoAccion: t.valuacionMisVacioAccion,
                    alAccion: () => context.push(rutaDeMisEstimaciones),
                  ),
                )
              : MarcoPantalla(
                  icono: LucideIcons300.badgeDollarSign,
                  titulo: titulo,
                  conRegreso: true,
                  alRefrescar: () => ref.refresh(misValuacionesProvider.future),
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Espaciado.e4,
                      ),
                      sliver: SliverList.list(
                        children: [
                          const SizedBox(height: Espaciado.e2),
                          for (final v in estado.valuaciones) ...[
                            _TarjetaValuacion(v),
                            const SizedBox(height: Espaciado.e3),
                          ],
                          if (estado.errorAlCargarMas) ...[
                            Aviso(
                              mensaje: t.valuacionMisErrorMas,
                              tono: Tono.peligro,
                            ),
                            const SizedBox(height: Espaciado.e3),
                          ],
                          if (estado.hayMas)
                            BotonPildora(
                              texto: t.valuacionMisVerMas,
                              variante: VarianteBotonPildora.tonal,
                              expandido: true,
                              cargando: estado.cargandoMas,
                              alPresionar: () => ref
                                  .read(misValuacionesProvider.notifier)
                                  .cargarMas(),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
        );
  }
}

class _TarjetaValuacion extends StatelessWidget {
  const _TarjetaValuacion(this.valuacion);

  final Valuacion valuacion;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final oferta = valuacion.oferta;
    return TarjetaResumen(
      titulo: valuacion.estimacion.auto,
      subtitulo: t.valuacionPedidaEl(
        fechaValuacion(context, valuacion.creadaEn.toLocal()),
      ),
      detalle: oferta == null
          ? null
          : t.valuacionOfertaConVigencia(
              pesosValuacion(oferta.monto),
              fechaValuacion(context, oferta.vigenciaHasta),
            ),
      icono: LucideIcons300.badgeCheck,
      estado: textoEstadoValuacion(t, valuacion.estado),
      tonoEstado: tonoEstadoValuacion(valuacion.estado),
      alToque: () => context.push(rutaValuacion(valuacion.id)),
    );
  }
}
