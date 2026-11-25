import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../api/excepciones.dart';
import '../../../l10n/app_localizations.dart';
import '../../../nucleo/diseno/componentes/aviso.dart';
import '../../../nucleo/diseno/componentes/boton_pildora.dart';
import '../../../nucleo/diseno/componentes/encabezado_grande.dart';
import '../../../nucleo/diseno/componentes/esqueleto.dart';
import '../../../nucleo/diseno/componentes/estado_error.dart';
import '../../../nucleo/diseno/componentes/grupo_lista.dart';
import '../../../nucleo/diseno/componentes/insignia.dart';
import '../../../nucleo/diseno/componentes/tono.dart';
import '../../../nucleo/diseno/tokens/espaciado.dart';
import '../../../nucleo/diseno/tokens/tokens_pista.dart';
import '../dominio/ticket_servicio.dart';
import '../../../nucleo/diseno/componentes/boton_circular.dart';
import 'formato_historial.dart';
import 'proveedores_historial.dart';

/// Ticket de una orden de servicio (V2-M02.06): mano de obra y refacciones,
/// cada renglon con cantidad por precio e importe, y los totales donde la mano
/// de obra mas las refacciones dan el total. El PDF se descarga y se comparte
/// con la hoja del sistema. Resuelve esqueleto, datos, error y sin conexion.
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

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final ticket = ref.watch(ticketServicioProvider(widget.servicioId));
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
        ),
      ),
    );

    return Scaffold(
      backgroundColor: TokensPista.de(context).colores.fondo,
      body: RefreshIndicator(
        onRefresh: () =>
            ref.refresh(ticketServicioProvider(widget.servicioId).future),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            EncabezadoGrande(
              titulo: textos.historialTicketTitulo,
              subtitulo: datos == null ? null : fechaDe(context, datos.fecha),
              translucido: true,
              acciones: [
                if (datos != null)
                  BotonCircular(
                    etiqueta: textos.historialTicketCompartir,
                    icono: Icons.ios_share_rounded,
                    alPresionar: _compartiendo ? null : () => _compartir(datos),
                  ),
              ],
            ),
            contenido,
            const SliverToBoxAdapter(child: SizedBox(height: Espaciado.e6)),
          ],
        ),
      ),
    );
  }
}

class _Ticket extends StatelessWidget {
  const _Ticket({
    required this.ticket,
    required this.compartiendo,
    required this.errorAlCompartir,
    required this.alCompartir,
  });

  final TicketServicio ticket;
  final bool compartiendo;
  final bool errorAlCompartir;
  final VoidCallback alCompartir;

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
                icono: Icons.event_outlined,
                colorIcono: c.acento,
              ),
              FilaGrupo(
                titulo: ticket.fechaCierre == null
                    ? textos.historialSinCierre
                    : fechaHoraDe(context, ticket.fechaCierre!),
                subtitulo: textos.historialTicketCierre,
                icono: Icons.task_alt_rounded,
                colorIcono: c.exito,
              ),
              FilaGrupo(
                titulo: textos.historialTicketKilometrajeValor(
                  NumberFormat.decimalPattern(
                    idioma.startsWith('es') ? 'es_MX' : 'en_US',
                  ).format(ticket.kilometraje),
                ),
                subtitulo: textos.historialTicketKilometraje,
                icono: Icons.speed_rounded,
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
          const SizedBox(height: Espaciado.e4),
          BotonPildora(
            texto: textos.historialTicketCompartir,
            icono: Icons.picture_as_pdf_outlined,
            expandido: true,
            alPresionar: compartiendo ? null : alCompartir,
          ),
        ],
      ),
    );
  }
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
