import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons_300.dart';

import '../../../api/excepciones.dart';
import '../../../l10n/app_localizations.dart';
import '../../../nucleo/diseno/componentes/aviso.dart';
import '../../../nucleo/diseno/componentes/boton_pildora.dart';
import '../../../nucleo/diseno/componentes/estado_error.dart';
import '../../../nucleo/diseno/componentes/estado_vacio.dart';
import '../../../nucleo/diseno/componentes/grupo_lista.dart';
import '../../../nucleo/diseno/componentes/insignia.dart';
import '../../../nucleo/diseno/componentes/marco_pantalla.dart';
import '../../../nucleo/diseno/componentes/tarjeta_metrica.dart';
import '../../../nucleo/diseno/componentes/tono.dart';
import '../../../nucleo/diseno/tokens/espaciado.dart';
import '../../../nucleo/diseno/tokens/tokens_pista.dart';
import '../../historial/historial.dart' show rutaTicketServicio;
import '../../tienda/tienda.dart' show rutaPedido;
import '../dominio/pagos.dart';
import 'confirmar_con_el_banco.dart';
import 'esqueleto_pagos.dart';
import 'formato_pagos.dart';
import 'proveedores_pagos.dart';
import 'seccion_factura.dart';

/// Un pago (V2-M08.02 y V2-M08.07): estado, monto, con que, cuando, la
/// referencia y, si fallo, por que. Si sigue esperando al banco simulado se
/// puede confirmar desde aqui. Lleva al ticket de la orden o al pedido de la
/// tienda (V2-M14.04). Abajo, su factura simulada: descargarla o timbrarla
/// (V2-M08.06). Se actualiza solo con `pago.confirmado` y `factura.timbrada`.
/// Resuelve esqueleto, datos, no encontrado, error y sin conexion.
class PantallaPago extends ConsumerWidget {
  const PantallaPago({required this.pagoId, super.key});

  final int pagoId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textos = AppLocalizations.of(context);
    final titulo = textos.pagosPagoTitulo;
    Widget estado(Widget hijo) => MarcoPantalla.estado(
      icono: LucideIcons300.receipt,
      titulo: titulo,
      conRegreso: true,
      estado: hijo,
    );

    return ref
        .watch(pagoProvider(pagoId))
        .when(
          skipLoadingOnReload: true,
          loading: () => estado(
            EsqueletoPagos(
              altos: const [96, 200],
              etiqueta: textos.pagosCargando,
            ),
          ),
          error: (error, _) => estado(
            error is NoEncontrado
                ? EstadoVacio(
                    titulo: textos.pagosNoEncontradoTitulo,
                    mensaje: textos.pagosNoEncontradoMensaje,
                    icono: LucideIcons300.searchX,
                  )
                : EstadoError(
                    causa: error is SinConexion
                        ? CausaError.sinConexion
                        : CausaError.generico,
                    textoReintentar: textos.pagosReintentar,
                    alReintentar: () => ref.invalidate(pagoProvider(pagoId)),
                  ),
          ),
          data: (pago) => MarcoPantalla(
            icono: LucideIcons300.receipt,
            titulo: titulo,
            subtitulo: textoObjetivoPago(textos, pago),
            conRegreso: true,
            alRefrescar: () => ref.refresh(pagoProvider(pagoId).future),
            slivers: [
              SliverToBoxAdapter(child: _Pago(pago: pago)),
              SliverToBoxAdapter(child: SeccionFactura(pago: pago)),
            ],
          ),
        );
  }
}

class _Pago extends ConsumerStatefulWidget {
  const _Pago({required this.pago});

  final Pago pago;

  @override
  ConsumerState<_Pago> createState() => _EstadoPago();
}

class _EstadoPago extends ConsumerState<_Pago> {
  bool _confirmando = false;
  String? _error;

  Future<void> _confirmar() async {
    final textos = AppLocalizations.of(context);
    final pago = widget.pago;
    final confirmada = await confirmarConElBanco(
      context,
      monto: pesos(context, pago.monto),
      tarjeta: textoMedio(textos, pago),
    );
    if (!mounted) return;
    setState(() {
      _confirmando = true;
      _error = null;
    });
    try {
      await ref
          .read(pagoProvider(pago.id).notifier)
          .autenticar(confirmada: confirmada);
      ref.invalidate(pagosProvider);
    } on PagoRechazado catch (rechazo) {
      if (!mounted) return;
      setState(() => _error = textoRechazo(textos, rechazo.motivo));
      ref.invalidate(pagoProvider(pago.id));
    } on SinConexion {
      if (!mounted) return;
      setState(() => _error = textos.pagosSinConexion);
    } on Object {
      if (!mounted) return;
      setState(() => _error = textos.pagosErrorPagar);
    } finally {
      if (mounted) setState(() => _confirmando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final tokens = TokensPista.de(context);
    final c = tokens.colores;
    final pago = widget.pago;
    final error = _error;
    final pagado = pago.pagadoEn;
    final ordenId = pago.ordenId;
    final vehiculoId = pago.vehiculoId;
    final pedidoId = pago.pedidoId;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Espaciado.margenTelefono),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Insignia(
              texto: textoEstadoPago(textos, pago.estado),
              tono: tonoEstadoPago(pago.estado),
              conIcono: true,
            ),
          ),
          const SizedBox(height: Espaciado.e3),
          TarjetaMetrica(
            etiqueta: textos.pagosMonto,
            cifra: pesos(context, pago.monto),
            tono: tonoEstadoPago(pago.estado),
          ),
          const SizedBox(height: Espaciado.e4),
          GrupoLista(
            filas: [
              FilaGrupo(
                titulo: textoMedio(textos, pago),
                subtitulo: textos.pagosMedio,
                icono: pago.medio == MedioPago.caja
                    ? LucideIcons300.banknote
                    : LucideIcons300.creditCard,
                colorIcono: c.acento,
              ),
              FilaGrupo(
                titulo: fechaPago(context, pagado ?? pago.creadoEn),
                subtitulo: pagado == null
                    ? textos.pagosFechaIntento
                    : textos.pagosFechaPago,
                icono: LucideIcons300.calendar,
                colorIcono: c.marca,
              ),
              FilaGrupo(
                titulo: pago.referencia,
                subtitulo: textos.pagosReferencia,
                icono: LucideIcons300.hash,
                colorIcono: c.textoSecundario,
              ),
              if (pago.estado == EstadoPago.fallido)
                FilaGrupo(
                  titulo: textoMotivoFallo(textos, pago.motivoFallo),
                  subtitulo: textos.pagosMotivo,
                  icono: LucideIcons300.circleAlert,
                  colorIcono: c.peligro,
                ),
            ],
          ),
          const SizedBox(height: Espaciado.e3),
          Aviso(
            mensaje: pago.simulado
                ? textos.pagosSimuladoCorto
                : textos.pagosEnCaja,
            tono: Tono.informacion,
          ),
          if (error != null) ...[
            const SizedBox(height: Espaciado.e3),
            Aviso(mensaje: error, tono: Tono.peligro),
          ],
          if (pago.requiereAutenticacion) ...[
            const SizedBox(height: Espaciado.e4),
            BotonPildora(
              texto: textos.pagosConfirmarBanco,
              icono: LucideIcons300.shieldCheck,
              expandido: true,
              cargando: _confirmando,
              alPresionar: _confirmando ? null : _confirmar,
            ),
          ],
          if (pedidoId != null) ...[
            const SizedBox(height: Espaciado.e4),
            BotonPildora(
              texto: textos.pagosVerPedido,
              icono: LucideIcons300.shoppingBag,
              variante: VarianteBotonPildora.tonal,
              expandido: true,
              alPresionar: () => context.push(rutaPedido(pedidoId)),
            ),
          ] else if (ordenId != null && vehiculoId != null) ...[
            const SizedBox(height: Espaciado.e4),
            BotonPildora(
              texto: textos.pagosVerTicket,
              icono: LucideIcons300.receiptText,
              variante: VarianteBotonPildora.tonal,
              expandido: true,
              alPresionar: () =>
                  context.push(rutaTicketServicio(vehiculoId, ordenId)),
            ),
          ],
          const SizedBox(height: Espaciado.e4),
        ],
      ),
    );
  }
}
