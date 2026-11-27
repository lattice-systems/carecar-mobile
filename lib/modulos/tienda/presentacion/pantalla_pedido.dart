import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:lucide_icons_flutter/lucide_icons_300.dart';

import '../../../api/excepciones.dart';
import '../../../l10n/app_localizations.dart';
import '../../../nucleo/diseno/componentes/aviso.dart';
import '../../../nucleo/diseno/componentes/boton.dart';
import '../../../nucleo/diseno/componentes/boton_pildora.dart';
import '../../../nucleo/diseno/componentes/dialogo.dart';
import '../../../nucleo/diseno/componentes/estado_vacio.dart';
import '../../../nucleo/diseno/componentes/grupo_lista.dart';
import '../../../nucleo/diseno/componentes/hoja_inferior.dart';
import '../../../nucleo/diseno/componentes/linea_de_tiempo.dart';
import '../../../nucleo/diseno/componentes/marco_pantalla.dart';
import '../../../nucleo/diseno/componentes/tarjeta_metrica.dart';
import '../../../nucleo/diseno/componentes/tarjeta_resumen.dart';
import '../../../nucleo/diseno/componentes/tono.dart';
import '../../../nucleo/diseno/tokens/espaciado.dart';
import '../../citas/citas.dart';
import '../../pagos/pagos.dart' show rutaPagarPedido;
import '../../vehiculos/vehiculos.dart';
import '../dominio/tienda.dart';
import 'formato_tienda.dart';
import 'piezas_tienda.dart';
import 'proveedores_tienda.dart';
import 'rutas_tienda.dart';

/// El detalle de un pedido (V2-M14.05): estado, avance con sus horas, cuándo
/// vence y productos. Mientras está abierto deja cancelarlo (V2-M14.02) y
/// elegir en qué cita se instala (V2-M14.03). Si se puede, se paga en la app
/// con la pantalla de pago de `pagos`. Ya pagado dice con qué y solo se
/// cancela en el mostrador (V2-M14.04). Se actualiza solo con su aviso
/// `pedido.estado` y con su `pago.confirmado`.
class PantallaPedido extends ConsumerStatefulWidget {
  const PantallaPedido({
    required this.pedidoId,
    this.pagarAlAbrir = false,
    super.key,
  });

  final int pedidoId;

  /// Abre el pago al llegar, como «Pagar ahora» al apartar.
  final bool pagarAlAbrir;

  static const botonPagar = Key('tienda_pagar_pedido');

  @override
  ConsumerState<PantallaPedido> createState() => _PantallaPedidoState();
}

class _PantallaPedidoState extends ConsumerState<PantallaPedido> {
  bool _guardando = false;

  PedidoNotifier get _notifier =>
      ref.read(pedidoTiendaProvider(widget.pedidoId).notifier);

  @override
  void initState() {
    super.initState();
    if (widget.pagarAlAbrir) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _pagar();
      });
    }
  }

  /// Abre el pago del pedido. Al volver se vuelve a pedir sin pasar por carga,
  /// por si el aviso en vivo no llegó.
  Future<void> _pagar() async {
    await context.push(rutaPagarPedido(widget.pedidoId));
    if (!mounted) return;
    ref.invalidate(misPedidosProvider);
    await _notifier.recargar();
  }

  Future<void> _hacer(Future<void> Function() accion) async {
    if (_guardando) return;
    final t = AppLocalizations.of(context);
    setState(() => _guardando = true);
    Object? fallo;
    try {
      await accion();
    } on Object catch (error) {
      fallo = error;
    }
    if (!mounted) return;
    setState(() => _guardando = false);
    if (fallo != null) {
      await avisarFalloTienda(
        context,
        titulo: t.tiendaNoSeCambioTitulo,
        mensaje: textoFallo(t, fallo, sinConexion: t.tiendaAccionSinConexion),
      );
    }
  }

  Future<void> _confirmarCancelacion() async {
    final t = AppLocalizations.of(context);
    final confirmado = await mostrarDialogo<bool>(
      context,
      builder: (dialogo) => Dialogo(
        titulo: t.tiendaCancelarTitulo,
        mensaje: t.tiendaCancelarMensaje,
        textoPrincipal: t.tiendaCancelarConfirmar,
        alPrincipal: () => Navigator.of(dialogo).pop(true),
        textoSecundario: t.tiendaCancelarVolver,
        alSecundario: () => Navigator.of(dialogo).pop(false),
        peligro: true,
      ),
    );
    if (confirmado ?? false) await _hacer(_notifier.cancelar);
  }

  Future<void> _elegirCita(Pedido pedido) async {
    final citaId = await mostrarHojaInferior<int>(
      context,
      titulo: AppLocalizations.of(context).tiendaElegirCita,
      builder: (_) => _HojaDeCitas(elegida: pedido.cita?.id),
    );
    if (citaId == null || citaId == pedido.cita?.id || !mounted) return;
    await _hacer(() => _notifier.cambiarInstalacion(citaId));
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final titulo = t.tiendaDetalleTitulo;

    return ref
        .watch(pedidoTiendaProvider(widget.pedidoId))
        .when(
          skipLoadingOnReload: true,
          loading: () => MarcoPantalla.estado(
            titulo: titulo,
            conRegreso: true,
            estado: const EsqueletoTienda(altos: [96, 180, 120]),
          ),
          error: (error, _) => MarcoPantalla.estado(
            titulo: titulo,
            conRegreso: true,
            estado: error is NoEncontrado
                ? EstadoVacio(
                    titulo: t.tiendaPedidoNoEncontradoTitulo,
                    mensaje: t.tiendaPedidoNoEncontradoMensaje,
                    icono: LucideIcons300.searchX,
                    textoAccion: t.tiendaMisPedidos,
                    alAccion: () => context.go(rutaMisPedidos),
                  )
                : ErrorTienda(
                    error: error,
                    alReintentar: () =>
                        ref.invalidate(pedidoTiendaProvider(widget.pedidoId)),
                  ),
          ),
          data: (pedido) => MarcoPantalla(
            titulo: titulo,
            conRegreso: true,
            barraInferior: pedido.pagable
                ? BarraInferior(
                    hijos: [
                      Boton(
                        key: PantallaPedido.botonPagar,
                        texto: t.tiendaPagar(pesosTienda(pedido.total)),
                        anchoCompleto: true,
                        alPresionar: _guardando ? null : _pagar,
                      ),
                    ],
                  )
                : null,
            alRefrescar: () =>
                ref.refresh(pedidoTiendaProvider(widget.pedidoId).future),
            slivers: [SliverToBoxAdapter(child: _contenido(context, pedido))],
          ),
        );
  }

  Widget _contenido(BuildContext context, Pedido pedido) {
    final t = AppLocalizations.of(context);
    final vence = pedido.venceEn;
    final pagadoEn = pedido.pagadoEn;
    final motivo = pedido.motivoCancelacion;
    final comoSePaga = pedido.pagable
        ? t.tiendaPagoEnAppOCaja
        : t.tiendaPagoEnCaja;
    const lados = EdgeInsets.symmetric(horizontal: Espaciado.e4);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: lados.add(const EdgeInsets.only(top: Espaciado.e2)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TarjetaResumen(
                titulo: t.tiendaPedidoTitulo(pedido.id),
                subtitulo: motivo == null
                    ? null
                    : textoMotivoCancelacion(t, motivo),
                icono: LucideIcons300.shoppingBag,
                estado: textoEstadoPedido(t, pedido.estado),
                tonoEstado: tonoEstadoPedido(pedido.estado),
              ),
              if (pagadoEn != null) ...[
                const SizedBox(height: Espaciado.e3),
                Aviso(
                  titulo: t.tiendaPagadoAviso(
                    textoPagoDePedido(t, pedido.pago),
                  ),
                  mensaje: t.tiendaPagadoMensaje(
                    momentoTienda(context, pagadoEn),
                  ),
                  tono: Tono.exito,
                ),
              ] else if (pedido.abierto) ...[
                const SizedBox(height: Espaciado.e3),
                if (vence != null)
                  Aviso(
                    titulo: comoSePaga,
                    mensaje: t.tiendaVenceDetalle(
                      momentoTienda(context, vence),
                    ),
                    tono: Tono.advertencia,
                  )
                else
                  Aviso(mensaje: comoSePaga),
              ],
            ],
          ),
        ),
        SeccionPantalla(
          titulo: t.tiendaAvanceTitulo,
          hijo: LineaDeTiempo(pasos: _pasos(context, pedido)),
        ),
        SeccionPantalla(
          titulo: t.tiendaProductosTitulo,
          hijo: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GrupoLista(
                filas: [
                  for (final r in pedido.renglones)
                    FilaGrupo(
                      titulo: r.nombre,
                      subtitulo: t.tiendaRenglonDetalle(
                        r.cantidad,
                        pesosTienda(r.precio),
                      ),
                      fin: Text(pesosTienda(r.importe)),
                      etiquetaFin: pesosTienda(r.importe),
                    ),
                ],
              ),
              const SizedBox(height: Espaciado.e3),
              TarjetaMetrica(
                etiqueta: t.tiendaTotal,
                cifra: pesosTienda(pedido.total),
              ),
            ],
          ),
        ),
        if (pedido.abierto || pedido.cita != null)
          _instalacion(context, pedido),
        if (pedido.cancelableEnLaApp)
          Padding(
            padding: lados.add(const EdgeInsets.only(top: Espaciado.e6)),
            child: BotonPildora(
              texto: t.tiendaCancelarPedido,
              variante: VarianteBotonPildora.peligro,
              expandido: true,
              cargando: _guardando,
              alPresionar: _confirmarCancelacion,
            ),
          )
        else if (pedido.abierto)
          Padding(
            padding: lados.add(const EdgeInsets.only(top: Espaciado.e6)),
            child: Aviso(mensaje: t.tiendaPagadoCancelarEnMostrador),
          ),
      ],
    );
  }

  Widget _instalacion(BuildContext context, Pedido pedido) {
    final t = AppLocalizations.of(context);
    final garaje = ref.watch(garajeProvider).value ?? const <VehiculoGaraje>[];
    final cita = pedido.cita;
    final enCita = pedido.entrega == EntregaPedido.cita && cita != null;

    return SeccionPantalla(
      titulo: t.tiendaInstalacionTitulo,
      hijo: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TarjetaResumen(
            titulo: enCita ? t.tiendaSeInstala : t.tiendaSeRecoge,
            subtitulo: enCita
                ? diaYHoraTienda(context, cita.fecha, cita.hora)
                : null,
            detalle: enCita ? nombreDeAuto(garaje, cita.vehiculoId) : null,
            icono: enCita ? LucideIcons300.wrench : LucideIcons300.store,
          ),
          if (pedido.abierto) ...[
            const SizedBox(height: Espaciado.e2),
            BotonPildora(
              texto: enCita ? t.tiendaCambiarCita : t.tiendaEntregaCita,
              variante: VarianteBotonPildora.tonal,
              expandido: true,
              alPresionar: _guardando ? null : () => _elegirCita(pedido),
            ),
            if (enCita) ...[
              const SizedBox(height: Espaciado.e2),
              BotonPildora(
                texto: t.tiendaEntregaMostrador,
                variante: VarianteBotonPildora.vidrio,
                expandido: true,
                alPresionar: _guardando
                    ? null
                    : () => _hacer(() => _notifier.cambiarInstalacion(null)),
              ),
            ],
          ],
        ],
      ),
    );
  }

  /// Apartado, listo y entregado con su hora; un cancelado termina donde se
  /// canceló.
  List<PasoLinea> _pasos(BuildContext context, Pedido p) {
    final t = AppLocalizations.of(context);
    String? hora(DateTime? momento) =>
        momento == null ? null : momentoTienda(context, momento);
    PasoLinea paso(EstadoPedido estado, DateTime? momento, EstadoPaso como) =>
        PasoLinea(
          titulo: textoEstadoPedido(t, estado),
          nota: hora(momento),
          estado: como,
        );

    if (p.estado == EstadoPedido.cancelado) {
      return [
        paso(EstadoPedido.apartado, p.creadoEn, EstadoPaso.hecho),
        if (p.listoEn != null)
          paso(EstadoPedido.listo, p.listoEn, EstadoPaso.hecho),
        paso(EstadoPedido.cancelado, p.canceladoEn, EstadoPaso.actual),
      ];
    }
    final actual = [
      EstadoPedido.apartado,
      EstadoPedido.listo,
      EstadoPedido.entregado,
    ].indexOf(p.estado);
    EstadoPaso como(int i) => i < actual || p.estado == EstadoPedido.entregado
        ? EstadoPaso.hecho
        : i == actual
        ? EstadoPaso.actual
        : EstadoPaso.pendiente;
    return [
      paso(EstadoPedido.apartado, p.creadoEn, como(0)),
      paso(EstadoPedido.listo, p.listoEn, como(1)),
      paso(EstadoPedido.entregado, p.entregadoEn, como(2)),
    ];
  }
}

/// La hoja con las citas confirmadas futuras. Devuelve la elegida.
class _HojaDeCitas extends ConsumerWidget {
  const _HojaDeCitas({required this.elegida});

  final int? elegida;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final garaje = ref.watch(garajeProvider).value ?? const <VehiculoGaraje>[];

    Widget conSalida(String mensaje, String accion, VoidCallback alPresionar) =>
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Aviso(mensaje: mensaje, tono: Tono.advertencia),
            const SizedBox(height: Espaciado.e3),
            BotonPildora(
              texto: accion,
              variante: VarianteBotonPildora.tonal,
              expandido: true,
              alPresionar: alPresionar,
            ),
          ],
        );

    return ref
        .watch(citasParaInstalarProvider)
        .when(
          loading: () => const EsqueletoTienda(altos: [56, 56]),
          error: (error, _) => conSalida(
            error is SinConexion
                ? t.tiendaAccionSinConexion
                : t.tiendaErrorCitas,
            t.tiendaReintentar,
            () => ref.invalidate(citasParaInstalarProvider),
          ),
          data: (List<CitaCliente> citas) => citas.isEmpty
              ? conSalida(t.tiendaSinCitas, t.tiendaAgendarCita, () {
                  final enrutador = GoRouter.of(context);
                  Navigator.of(context).pop();
                  enrutador.push(rutaAgendarCita);
                })
              : ListaDeCitas(
                  citas: citas,
                  garaje: garaje,
                  elegida: elegida,
                  alElegir: (id) => Navigator.of(context).pop(id),
                ),
        );
  }
}
