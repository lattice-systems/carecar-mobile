import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:lucide_icons_flutter/lucide_icons_300.dart';

import '../../../api/excepciones.dart';
import '../../../l10n/app_localizations.dart';
import '../../../nucleo/diseno/componentes/aviso.dart';
import '../../../nucleo/diseno/componentes/boton_pildora.dart';
import '../../../nucleo/diseno/componentes/esqueleto.dart';
import '../../../nucleo/diseno/componentes/estado_error.dart';
import '../../../nucleo/diseno/componentes/grupo_lista.dart';
import '../../../nucleo/diseno/componentes/insignia.dart';
import '../../../nucleo/diseno/componentes/marco_pantalla.dart';
import '../../../nucleo/diseno/componentes/tono.dart';
import '../../../nucleo/diseno/tokens/espaciado.dart';
import '../../../nucleo/diseno/tokens/tokens_pista.dart';
import '../../pagos/pagos.dart' show rutaPagarOrden;
import '../dominio/ticket_servicio.dart';
import '../../../nucleo/diseno/componentes/boton_circular.dart';
import 'formato_historial.dart';
import 'proveedores_historial.dart';

/// Ticket de una orden de servicio (V2-M02.06): mano de obra y refacciones,
/// cada renglon con cantidad por precio e importe, y los totales donde la mano
/// de obra mas las refacciones dan el total. El PDF se descarga y se comparte
/// con la hoja del sistema. Si ya se pago dice con que y su referencia; si se
/// puede pagar en la app lleva a pagarla (V2-M08.02) y al volver se recarga.
/// Resuelve esqueleto, datos, error y sin conexion.
class PantallaTicket extends ConsumerStatefulWidget {
  const PantallaTicket({required this.servicioId, super.key});

  final int servicioId;

  @override
  ConsumerState<PantallaTicket> createState() => _EstadoPantallaTicket();
}

class _EstadoPantallaTicket extends ConsumerState<PantallaTicket> {
  bool _compartiendo = false;
  bool _errorAlCompartir = false;

  Future<void> _compartir(TicketServicio ticket) async {
    setState(() {
      _compartiendo = true;
      _errorAlCompartir = false;
    });
    try {
      final pdf = await ref
          .read(repositorioHistorialProvider)
          .ticketPdf(ticket.id);
      await ref.read(compartirTicketProvider)(pdf, ticket.nombrePdf);
    } on Object {
      if (mounted) setState(() => _errorAlCompartir = true);
    } finally {
      if (mounted) setState(() => _compartiendo = false);
    }
  }

  Future<void> _pagar(TicketServicio ticket) async {
    await context.push(rutaPagarOrden(ticket.id));
    if (mounted) ref.invalidate(ticketServicioProvider(widget.servicioId));
  }

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final ticket = ref.watch(ticketServicioProvider(widget.servicioId));
    final conRutas = GoRouter.maybeOf(context) != null;
    final datos = ticket.value;

    final Widget contenido = ticket.when(
      skipLoadingOnReload: true,
      loading: () => const SliverToBoxAdapter(child: _Cargando()),
      error: (error, _) => SliverFillRemaining(
        child: EstadoError(
          causa: error is SinConexion
              ? CausaError.sinConexion
              : CausaError.generico,
          textoReintentar: textos.historialReintentar,
          alReintentar: () =>
              ref.invalidate(ticketServicioProvider(widget.servicioId)),
        ),
      ),
      data: (t) => SliverToBoxAdapter(
        child: _Ticket(
          ticket: t,
          compartiendo: _compartiendo,
          errorAlCompartir: _errorAlCompartir,
          alCompartir: () => _compartir(t),
          alPagar: conRutas && t.pagable ? () => _pagar(t) : null,
        ),
      ),
    );

    return MarcoPantalla(
      titulo: textos.historialTicketTitulo,
      subtitulo: datos == null ? null : fechaDe(context, datos.fecha),
      conRegreso: true,
      alRefrescar: () =>
          ref.refresh(ticketServicioProvider(widget.servicioId).future),
      acciones: [
        if (datos != null)
          BotonCircular(
            etiqueta: textos.historialTicketCompartir,
            icono: LucideIcons300.share,
            alPresionar: _compartiendo ? null : () => _compartir(datos),
          ),
      ],
      slivers: [contenido],
    );
  }
}

class _Ticket extends StatelessWidget {
  const _Ticket({
    required this.ticket,
    required this.compartiendo,
    required this.errorAlCompartir,
    required this.alCompartir,
    this.alPagar,
  });

  final TicketServicio ticket;
  final bool compartiendo;
  final bool errorAlCompartir;
  final VoidCallback alCompartir;

  /// Lleva a pagar la orden; nulo si no se puede pagar en la app.
  final VoidCallback? alPagar;

  static const botonPagar = Key('ticket_pagar');

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final tokens = TokensPista.de(context);
    final c = tokens.colores;
    final t = tokens.tipografia;
    final idioma = Localizations.localeOf(context).toString();
    String dinero(double valor) => monedaDe(context, valor);

    FilaGrupo renglon(RenglonTicketServicio r) => FilaGrupo(
      titulo: r.concepto,
      subtitulo: textos.historialTicketCantidadPorPrecio(
        r.cantidad,
        dinero(r.precio),
      ),
      fin: Text(dinero(r.importe), style: t.cuerpoFuerte),
    );

    FilaGrupo total(String etiqueta, double valor, {bool fuerte = false}) =>
        FilaGrupo(
          titulo: etiqueta,
          fin: Text(dinero(valor), style: fuerte ? t.titulo3 : t.cuerpo),
        );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Espaciado.margenTelefono),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Insignia(
              texto: textoEstatus(textos, ticket.estatus),
              tono: tonoEstatus(ticket.estatus),
              conIcono: true,
            ),
          ),
          const SizedBox(height: Espaciado.e3),
          GrupoLista(
            filas: [
              FilaGrupo(
                titulo: fechaDe(context, ticket.fecha),
                subtitulo: textos.historialTicketFecha,
                icono: LucideIcons300.calendar,
                colorIcono: c.acento,
              ),
              FilaGrupo(
                titulo: ticket.fechaCierre == null
                    ? textos.historialSinCierre
                    : fechaHoraDe(context, ticket.fechaCierre!),
                subtitulo: textos.historialTicketCierre,
                icono: LucideIcons300.circleCheckBig,
                colorIcono: c.exito,
              ),
              FilaGrupo(
                titulo: textos.historialTicketKilometrajeValor(
                  NumberFormat.decimalPattern(
                    idioma.startsWith('es') ? 'es_MX' : 'en_US',
                  ).format(ticket.kilometraje),
                ),
                subtitulo: textos.historialTicketKilometraje,
                icono: LucideIcons300.gauge,
                colorIcono: c.marca,
              ),
            ],
          ),
          const SizedBox(height: Espaciado.e4),
          GrupoLista(
            encabezado: textos.historialTicketManoDeObra,
            filas: ticket.manoDeObra.isEmpty
                ? [FilaGrupo(titulo: textos.historialTicketSinRenglones)]
                : [for (final r in ticket.manoDeObra) renglon(r)],
          ),
          const SizedBox(height: Espaciado.e4),
          GrupoLista(
            encabezado: textos.historialTicketRefacciones,
            filas: ticket.refacciones.isEmpty
                ? [FilaGrupo(titulo: textos.historialTicketSinRenglones)]
                : [for (final r in ticket.refacciones) renglon(r)],
          ),
          const SizedBox(height: Espaciado.e4),
          GrupoLista(
            encabezado: textos.historialTicketTotales,
            pie: textos.historialTicketPreciosConIva,
            filas: [
              total(textos.historialTicketManoDeObra, ticket.totalManoDeObra),
              total(textos.historialTicketRefacciones, ticket.totalRefacciones),
              total(textos.historialTicketSubtotal, ticket.subtotal),
              total(textos.historialTicketIva, ticket.iva),
              total(textos.historialTicketTotal, ticket.total, fuerte: true),
            ],
          ),
          if (ticket.puntosGanados case final puntos? when puntos > 0)
            Padding(
              padding: const EdgeInsets.only(top: Espaciado.e3),
              child: Aviso(
                mensaje: textos.historialTicketPuntosGanados(
                  NumberFormat.decimalPattern(
                    idioma.startsWith('es') ? 'es_MX' : 'en_US',
                  ).format(puntos),
                ),
                tono: Tono.exito,
              ),
            ),
          if (ticket.pago case final pago?) ...[
            const SizedBox(height: Espaciado.e4),
            GrupoLista(
              encabezado: textos.historialTicketPago,
              filas: [
                FilaGrupo(
                  titulo: textos.historialTicketPagado,
                  subtitulo: _textoPago(context, pago),
                  icono: LucideIcons300.circleCheckBig,
                  colorIcono: c.exito,
                ),
                FilaGrupo(
                  titulo: pago.referencia,
                  subtitulo: textos.historialTicketReferencia,
                  icono: LucideIcons300.hash,
                  colorIcono: c.textoSecundario,
                ),
              ],
            ),
          ],
          if (!ticket.cuadra)
            Padding(
              padding: const EdgeInsets.only(top: Espaciado.e3),
              child: Aviso(
                mensaje: textos.historialTicketNoCuadra,
                tono: Tono.advertencia,
              ),
            ),
          if (errorAlCompartir)
            Padding(
              padding: const EdgeInsets.only(top: Espaciado.e3),
              child: Aviso(
                mensaje: textos.historialTicketCompartirError,
                tono: Tono.peligro,
              ),
            ),
          if (alPagar case final pagar?) ...[
            const SizedBox(height: Espaciado.e4),
            BotonPildora(
              key: botonPagar,
              texto: textos.historialTicketPagar(dinero(ticket.total)),
              icono: LucideIcons300.creditCard,
              expandido: true,
              alPresionar: pagar,
            ),
          ],
          const SizedBox(height: Espaciado.e4),
          BotonPildora(
            texto: textos.historialTicketCompartir,
            icono: LucideIcons300.fileText,
            variante: alPagar == null
                ? VarianteBotonPildora.lleno
                : VarianteBotonPildora.tonal,
            expandido: true,
            alPresionar: compartiendo ? null : alCompartir,
          ),
        ],
      ),
    );
  }
}

/// «Visa •••• 4242 · 26 nov 2026, 12:00» o «En caja · …».
String _textoPago(BuildContext context, PagoDelTicket pago) {
  final textos = AppLocalizations.of(context);
  final marca = switch (pago.marca) {
    'VISA' => 'Visa',
    'MASTERCARD' => 'Mastercard',
    final otra => otra ?? '',
  };
  final medio = pago.enCaja
      ? textos.historialTicketPagadoEnCaja
      : textos.historialTicketTarjeta(marca, pago.ultimos4 ?? '');
  final cuando = pago.pagadoEn;
  return cuando == null
      ? medio
      : textos.historialTicketPagadoDetalle(
          medio,
          fechaHoraDe(context, cuando.toLocal()),
        );
}

class _Cargando extends StatelessWidget {
  const _Cargando();

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.symmetric(horizontal: Espaciado.margenTelefono),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Esqueleto(alto: 140),
        SizedBox(height: Espaciado.e4),
        Esqueleto(alto: 120),
        SizedBox(height: Espaciado.e4),
        Esqueleto(alto: 180),
      ],
    ),
  );
}
