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
import '../dominio/tienda.dart';
import 'formato_tienda.dart';
import 'piezas_tienda.dart';
import 'proveedores_tienda.dart';
import 'rutas_tienda.dart';

/// Mis pedidos (V2-M14.05), del más reciente al más antiguo, con su estado y
/// cuándo vence. Se actualiza solo con `pedido.estado`. Resuelve cargando,
/// datos, vacío, error y sin conexión; se recarga jalando hacia abajo.
class PantallaMisPedidos extends ConsumerWidget {
  const PantallaMisPedidos({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final titulo = t.tiendaMisPedidos;

    return ref
        .watch(misPedidosProvider)
        .when(
          skipLoadingOnReload: true,
          loading: () => MarcoPantalla.estado(
            titulo: titulo,
            conRegreso: true,
            estado: const EsqueletoTienda(altos: [112, 112, 112]),
          ),
          error: (error, _) => MarcoPantalla.estado(
            titulo: titulo,
            conRegreso: true,
            estado: ErrorTienda(
              error: error,
              alReintentar: () => ref.invalidate(misPedidosProvider),
            ),
          ),
          data: (lista) => lista.elementos.isEmpty
              ? MarcoPantalla.estado(
                  titulo: titulo,
                  conRegreso: true,
                  estado: EstadoVacio(
                    titulo: t.tiendaPedidosVacioTitulo,
                    mensaje: t.tiendaPedidosVacioMensaje,
                    icono: LucideIcons300.receiptText,
                    textoAccion: t.tiendaIrALaTienda,
                    alAccion: () => context.push(rutaTienda),
                  ),
                )
              : MarcoPantalla(
                  titulo: titulo,
                  conRegreso: true,
                  alRefrescar: () => ref.refresh(misPedidosProvider.future),
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Espaciado.e4,
                      ),
                      sliver: SliverList.list(
                        children: [
                          const SizedBox(height: Espaciado.e2),
                          for (final pedido in lista.elementos) ...[
                            _TarjetaPedido(pedido),
                            const SizedBox(height: Espaciado.e3),
                          ],
                          if (lista.errorAlCargarMas) ...[
                            Aviso(
                              mensaje: t.tiendaErrorMas,
                              tono: Tono.peligro,
                            ),
                            const SizedBox(height: Espaciado.e3),
                          ],
                          if (lista.hayMas)
                            BotonPildora(
                              texto: t.tiendaVerMas,
                              variante: VarianteBotonPildora.tonal,
                              expandido: true,
                              cargando: lista.cargandoMas,
                              alPresionar: () => ref
                                  .read(misPedidosProvider.notifier)
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

class _TarjetaPedido extends StatelessWidget {
  const _TarjetaPedido(this.pedido);

  final Pedido pedido;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final vence = pedido.venceEn;
    return TarjetaResumen(
      titulo: t.tiendaPedidoTitulo(pedido.id),
      subtitulo: t.tiendaPedidoResumen(
        pesosTienda(pedido.total),
        pedido.piezas,
      ),
      detalle: pedido.pagado
          ? t.tiendaPagado
          : vence == null || !pedido.abierto
          ? null
          : t.tiendaVence(momentoTienda(context, vence)),
      icono: LucideIcons300.shoppingBag,
      estado: textoEstadoPedido(t, pedido.estado),
      tonoEstado: tonoEstadoPedido(pedido.estado),
      alToque: () => context.push(rutaPedido(pedido.id)),
    );
  }
}
