import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:lucide_icons_flutter/lucide_icons_300.dart';

import '../../../l10n/app_localizations.dart';
import '../../../nucleo/diseno/componentes/aviso.dart';
import '../../../nucleo/diseno/componentes/boton.dart';
import '../../../nucleo/diseno/componentes/boton_pildora.dart';
import '../../../nucleo/diseno/componentes/chip_pista.dart';
import '../../../nucleo/diseno/componentes/esqueleto.dart';
import '../../../nucleo/diseno/componentes/estado_vacio.dart';
import '../../../nucleo/diseno/componentes/fila_acciones.dart';
import '../../../nucleo/diseno/componentes/marco_pantalla.dart';
import '../../../nucleo/diseno/componentes/resultado_pantalla.dart';
import '../../../nucleo/diseno/componentes/selector.dart';
import '../../../nucleo/diseno/componentes/tarjeta_metrica.dart';
import '../../../nucleo/diseno/componentes/tono.dart';
import '../../../nucleo/diseno/tokens/espaciado.dart';
import '../../../nucleo/diseno/tokens/tokens_pista.dart';
import '../../vehiculos/vehiculos.dart';
import '../dominio/repositorio_tienda.dart';
import '../dominio/tienda.dart';
import 'formato_tienda.dart';
import 'piezas_tienda.dart';
import 'proveedores_tienda.dart';
import 'rutas_tienda.dart';

/// El carrito y el apartado (V2-M14.02): cantidades, recoger en mostrador o
/// instalar en una cita (V2-M14.03) y cierre con la fecha en que vence. Se
/// paga en la app desde el pedido o en caja al recoger (V2-M14.04).
class PantallaCarrito extends ConsumerStatefulWidget {
  const PantallaCarrito({super.key});

  @override
  ConsumerState<PantallaCarrito> createState() => _PantallaCarritoState();
}

class _PantallaCarritoState extends ConsumerState<PantallaCarrito> {
  bool _apartando = false;
  Pedido? _apartado;

  Future<void> _apartar() async {
    if (_apartando) return;
    final t = AppLocalizations.of(context);
    setState(() => _apartando = true);
    Object? fallo;
    Pedido? pedido;
    try {
      pedido = await ref.read(carritoProvider.notifier).apartar();
    } on Object catch (error) {
      fallo = error;
    }
    if (!mounted) return;
    setState(() {
      _apartando = false;
      _apartado = pedido;
    });
    if (fallo == null) return;
    final conLimite =
        fallo is PedidoRechazado &&
        fallo.motivo == MotivoRechazoPedido.limiteApartados;
    final verPedidos = await avisarFalloTienda(
      context,
      titulo: t.tiendaNoSeApartoTitulo,
      mensaje: textoFallo(t, fallo, sinConexion: t.tiendaApartarSinConexion),
      textoSecundario: conLimite ? t.tiendaMisPedidos : null,
    );
    if (verPedidos && mounted) await context.push(rutaMisPedidos);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final apartado = _apartado;
    if (apartado != null) return _cierre(context, apartado);

    final carrito = ref.watch(carritoProvider);
    if (carrito.vacio) {
      return MarcoPantalla.estado(
        titulo: t.tiendaCarritoTitulo,
        conRegreso: true,
        estado: EstadoVacio(
          titulo: t.tiendaCarritoVacioTitulo,
          mensaje: t.tiendaCarritoVacioMensaje,
          icono: LucideIcons300.shoppingBag,
          textoAccion: t.tiendaIrALaTienda,
          alAccion: () => context.go(rutaTienda),
        ),
      );
    }

    return MarcoPantalla(
      titulo: t.tiendaCarritoTitulo,
      conRegreso: true,
      barraInferior: BarraInferior(
        hijos: [
          Boton(
            texto: t.tiendaApartar,
            anchoCompleto: true,
            cargando: _apartando,
            alPresionar: carrito.listoParaApartar ? _apartar : null,
          ),
        ],
      ),
      slivers: [
        SliverToBoxAdapter(
          // Mientras se aparta no se cambia nada.
          child: AbsorbPointer(
            absorbing: _apartando,
            child: _contenido(context, carrito),
          ),
        ),
      ],
    );
  }

  Widget _cierre(BuildContext context, Pedido pedido) {
    final t = AppLocalizations.of(context);
    final vence = pedido.venceEn;
    if (pedido.pagable) {
      return ResultadoPantalla(
        titulo: t.tiendaApartadoTitulo,
        mensaje: vence == null
            ? t.tiendaPagoEnAppOCaja
            : t.tiendaApartadoMensaje(momentoTienda(context, vence)),
        principal: AccionPantalla(
          texto: t.tiendaPagarAhora,
          alPresionar: () =>
              context.pushReplacement(rutaPedidoPagando(pedido.id)),
        ),
        secundaria: AccionPantalla(
          texto: t.tiendaPagarEnCaja,
          alPresionar: () => context.pushReplacement(rutaPedido(pedido.id)),
        ),
      );
    }
    return ResultadoPantalla(
      titulo: t.tiendaApartadoTitulo,
      mensaje: vence == null
          ? t.tiendaPagoEnCaja
          : t.tiendaApartadoMensaje(momentoTienda(context, vence)),
      principal: AccionPantalla(
        texto: t.tiendaVerMiPedido,
        alPresionar: () => context.pushReplacement(rutaPedido(pedido.id)),
      ),
      secundaria: AccionPantalla(
        texto: t.tiendaSeguirComprando,
        alPresionar: () => context.go(rutaTienda),
      ),
    );
  }

  Widget _contenido(BuildContext context, Carrito carrito) {
    final t = AppLocalizations.of(context);
    final notifier = ref.read(carritoProvider.notifier);
    final conCita = carrito.entrega == EntregaPedido.cita;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            Espaciado.e4,
            Espaciado.e2,
            Espaciado.e4,
            0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final renglon in carrito.renglones) ...[
                _Renglon(
                  key: ValueKey(renglon.producto.id),
                  renglon: renglon,
                  alCambiar: (cantidad) =>
                      notifier.cantidad(renglon.producto.id, cantidad),
                  alQuitar: () => notifier.quitar(renglon.producto.id),
                ),
                const SizedBox(height: Espaciado.e3),
              ],
            ],
          ),
        ),
        SeccionPantalla(
          titulo: t.tiendaEntregaTitulo,
          hijo: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Wrap(
                spacing: Espaciado.e2,
                children: [
                  ChipPista(
                    texto: t.tiendaEntregaMostrador,
                    seleccionado: !conCita,
                    alCambiar: (_) => notifier.recogerEnMostrador(),
                  ),
                  ChipPista(
                    texto: t.tiendaEntregaCita,
                    seleccionado: conCita,
                    alCambiar: (_) {
                      if (!conCita) notifier.instalarEnCita(null);
                    },
                  ),
                ],
              ),
              if (conCita) ...[
                const SizedBox(height: Espaciado.e3),
                _citas(context, carrito),
              ],
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            Espaciado.e4,
            Espaciado.e6,
            Espaciado.e4,
            0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TarjetaMetrica(
                etiqueta: t.tiendaTotal,
                cifra: pesosTienda(carrito.total),
              ),
              const SizedBox(height: Espaciado.e3),
              Aviso(
                titulo: t.tiendaPagoEnAppOCaja,
                mensaje: conCita
                    ? t.tiendaVigenciaCita
                    : t.tiendaVigenciaMostrador,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _citas(BuildContext context, Carrito carrito) {
    final t = AppLocalizations.of(context);
    final garaje = ref.watch(garajeProvider).value ?? const <VehiculoGaraje>[];
    return ref
        .watch(citasParaInstalarProvider)
        .when(
          loading: () => const Esqueleto(alto: 56),
          error: (error, _) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Aviso(mensaje: t.tiendaErrorCitas, tono: Tono.peligro),
              const SizedBox(height: Espaciado.e2),
              BotonPildora(
                texto: t.tiendaReintentar,
                variante: VarianteBotonPildora.tonal,
                expandido: true,
                alPresionar: () => ref.invalidate(citasParaInstalarProvider),
              ),
            ],
          ),
          data: (citas) => citas.isEmpty
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Aviso(mensaje: t.tiendaSinCitas, tono: Tono.advertencia),
                    const SizedBox(height: Espaciado.e2),
                    BotonPildora(
                      texto: t.tiendaAgendarCita,
                      variante: VarianteBotonPildora.tonal,
                      expandido: true,
                      alPresionar: () => context.push(rutaAgendarCita),
                    ),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(t.tiendaElegirCita, style: _etiqueta(context)),
                    const SizedBox(height: Espaciado.e2),
                    ListaDeCitas(
                      citas: citas,
                      garaje: garaje,
                      elegida: carrito.citaId,
                      alElegir: ref
                          .read(carritoProvider.notifier)
                          .instalarEnCita,
                    ),
                  ],
                ),
        );
  }

  TextStyle _etiqueta(BuildContext context) {
    final tokens = TokensPista.de(context);
    return tokens.tipografia.etiqueta.copyWith(
      color: tokens.colores.textoSecundario,
    );
  }
}

class _Renglon extends StatelessWidget {
  const _Renglon({
    required this.renglon,
    required this.alCambiar,
    required this.alQuitar,
    super.key,
  });

  final RenglonCarrito renglon;
  final ValueChanged<int> alCambiar;
  final VoidCallback alQuitar;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final tokens = TokensPista.de(context);
    final c = tokens.colores;
    final producto = renglon.producto;
    // La existencia pudo bajar desde que se agregó.
    final maximo = producto.maximoPorRenglon > renglon.cantidad
        ? producto.maximoPorRenglon
        : renglon.cantidad;

    return SuperficieTienda(
      hijo: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            producto.nombre,
            style: tokens.tipografia.titulo3.copyWith(color: c.texto),
          ),
          Text(
            t.tiendaPrecioCadaUno(pesosTienda(producto.precio)),
            style: tokens.tipografia.cuerpoChico.copyWith(
              color: c.textoSecundario,
            ),
          ),
          const SizedBox(height: Espaciado.e3),
          Selector<int>(
            key: ValueKey(renglon.cantidad),
            etiqueta: t.tiendaCantidad,
            opciones: [
              for (var i = 1; i <= maximo; i++)
                OpcionSelector(valor: i, texto: i.toString()),
            ],
            valor: renglon.cantidad,
            alCambiar: (valor) => alCambiar(valor ?? renglon.cantidad),
          ),
          const SizedBox(height: Espaciado.e2),
          BotonPildora(
            texto: t.tiendaQuitar,
            icono: LucideIcons300.trash2,
            variante: VarianteBotonPildora.tonal,
            alPresionar: alQuitar,
          ),
        ],
      ),
    );
  }
}
