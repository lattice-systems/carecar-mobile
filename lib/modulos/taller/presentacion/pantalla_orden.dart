import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:lucide_icons_flutter/lucide_icons_300.dart';

import '../../../api/excepciones.dart';
import '../../../l10n/app_localizations.dart';
import '../../../nucleo/diseno/componentes/aviso.dart';
import '../../../nucleo/diseno/componentes/boton.dart';
import '../../../nucleo/diseno/componentes/encabezado_grande.dart';
import '../../../nucleo/diseno/componentes/esqueleto.dart';
import '../../../nucleo/diseno/componentes/estado_error.dart';
import '../../../nucleo/diseno/componentes/grupo_lista.dart';
import '../../../nucleo/diseno/componentes/linea_de_tiempo.dart';
import '../../../nucleo/diseno/componentes/tono.dart';
import '../../../nucleo/diseno/tokens/espaciado.dart';
import '../../../nucleo/diseno/tokens/radios.dart';
import '../../../nucleo/diseno/tokens/tokens_pista.dart';
import '../../historial/historial.dart';
import '../dominio/etapa_taller.dart';
import '../dominio/orden_taller.dart';
import 'formato_taller.dart';
import 'proveedores_taller.dart';
import 'rutas_taller.dart';

/// La orden en el taller (V2-M04.02): etapa actual con su avance, entrega
/// estimada y asesor, la linea de tiempo con la hora de cada etapa (la actual
/// respira) y los accesos a la inspeccion y a los trabajos adicionales. Si hay
/// trabajos por aprobar lo avisa arriba. Se actualiza sola con los avisos en
/// vivo (V2-M04.03). Lista para entrega avisa con el total y el horario para
/// recogerla (V2-M04.06); lista o entregada abre su ticket y el historial
/// (V2-M04.07). Resuelve esqueleto, datos, error y sin conexion; se recarga
/// jalando hacia abajo.
class PantallaOrden extends ConsumerWidget {
  const PantallaOrden({required this.ordenId, super.key});

  final int ordenId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textos = AppLocalizations.of(context);
    final orden = ref.watch(ordenTallerProvider(ordenId));

    final Widget contenido = orden.when(
      skipLoadingOnReload: true,
      loading: () => const SliverToBoxAdapter(child: _Cargando()),
      error: (error, _) => SliverFillRemaining(
        child: EstadoError(
          causa: error is SinConexion
              ? CausaError.sinConexion
              : CausaError.generico,
          textoReintentar: textos.tallerReintentar,
          alReintentar: () => ref.invalidate(ordenTallerProvider(ordenId)),
        ),
      ),
      data: (o) => SliverToBoxAdapter(child: _Orden(orden: o)),
    );

    return Scaffold(
      backgroundColor: TokensPista.de(context).colores.fondo,
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(ordenTallerProvider(ordenId).future),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            EncabezadoGrande(
              titulo: textos.tallerOrdenTitulo,
              subtitulo: orden.value?.vehiculo,
              translucido: true,
            ),
            contenido,
            const SliverToBoxAdapter(child: SizedBox(height: Espaciado.e6)),
          ],
        ),
      ),
    );
  }
}

class _Orden extends StatelessWidget {
  const _Orden({required this.orden});

  final OrdenEnVivo orden;

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final tokens = TokensPista.de(context);
    final c = tokens.colores;
    final t = tokens.tipografia;
    final pendientes = orden.pendientes.length;
    final entrega = orden.entregaEstimada;
    final cerrada = orden.lista || orden.entregada;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Espaciado.margenTelefono),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (orden.lista) ...[
            Aviso(
              titulo: textos.tallerOrdenListoTitulo,
              mensaje: textoHorarioEntrega(context, orden.horarioEntrega),
              tono: Tono.exito,
            ),
            const SizedBox(height: Espaciado.e4),
          ],
          if (orden.entregada) ...[
            Aviso(
              titulo: textos.tallerOrdenEntregadaTitulo,
              mensaje: textos.tallerOrdenEntregadaMensaje,
              tono: Tono.exito,
            ),
            const SizedBox(height: Espaciado.e4),
          ],
          if (pendientes > 0 && !cerrada) ...[
            Aviso(
              titulo: textos.tallerOrdenAvisoPendientes(pendientes),
              mensaje: textos.tallerOrdenAvisoMensaje,
              tono: Tono.advertencia,
            ),
            const SizedBox(height: Espaciado.e2),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: Boton(
                texto: textos.tallerOrdenRevisar,
                variante: VarianteBoton.secundario,
                alPresionar: () =>
                    context.push(rutaAdicionalesTaller(orden.id)),
              ),
            ),
            const SizedBox(height: Espaciado.e4),
          ],
          GrupoLista(
            filas: [
              FilaGrupo(
                titulo: textoEtapa(textos, orden.etapa),
                subtitulo: textos.tallerOrdenEtapaActual,
                icono: LucideIcons300.wrench,
                colorIcono: c.acento,
                fin: Text(
                  textos.tallerTarjetaAvance(orden.avance),
                  style: t.etiqueta.copyWith(color: c.textoSecundario),
                ),
              ),
              FilaGrupo(
                titulo: entrega == null
                    ? textos.tallerOrdenSinEntrega
                    : horaTaller(context, entrega),
                subtitulo: textos.tallerOrdenEntregaEstimada,
                icono: LucideIcons300.clock,
                colorIcono: c.marca,
              ),
              if (orden.asesor case final asesor?)
                FilaGrupo(
                  titulo: asesor,
                  subtitulo: textos.tallerOrdenAsesor,
                  icono: LucideIcons300.headset,
                  colorIcono: c.exito,
                ),
              if (cerrada)
                FilaGrupo(
                  titulo: monedaTaller(context, orden.totalEstimado),
                  subtitulo: textos.tallerOrdenTotalAPagar,
                  icono: LucideIcons300.banknote,
                  colorIcono: c.exito,
                ),
            ],
          ),
          const SizedBox(height: Espaciado.e3),
          BarraAvance(avance: orden.avance),
          const SizedBox(height: Espaciado.e6),
          Text(textos.tallerOrdenLineaDeTiempo, style: t.titulo3),
          const SizedBox(height: Espaciado.e3),
          LineaDeTiempo(pasos: _pasos(context, orden)),
          const SizedBox(height: Espaciado.e6),
          GrupoLista(
            filas: [
              FilaGrupo(
                titulo: textos.tallerOrdenInspeccion,
                subtitulo: textos.tallerOrdenInspeccionResumen(
                  orden.inspeccion.length,
                ),
                icono: LucideIcons300.clipboardCheck,
                colorIcono: c.acento,
                alToque: () => context.push(rutaInspeccionTaller(orden.id)),
              ),
              FilaGrupo(
                titulo: textos.tallerOrdenAdicionales,
                subtitulo: textos.tallerOrdenAdicionalesResumen(pendientes),
                icono: LucideIcons300.hammer,
                colorIcono: pendientes > 0 ? c.advertencia : c.marca,
                alToque: () => context.push(rutaAdicionalesTaller(orden.id)),
              ),
              if (cerrada)
                FilaGrupo(
                  titulo: textos.tallerOrdenVerTicket,
                  subtitulo: textos.tallerOrdenVerTicketResumen,
                  icono: LucideIcons300.receiptText,
                  colorIcono: c.marca,
                  alToque: () => context.push(
                    rutaTicketServicio(orden.vehiculoId, orden.id),
                  ),
                ),
              if (orden.entregada)
                FilaGrupo(
                  titulo: textos.tallerOrdenVerHistorial,
                  icono: LucideIcons300.history,
                  colorIcono: c.marca,
                  alToque: () =>
                      context.push(rutaHistorialVehiculo(orden.vehiculoId)),
                ),
            ],
          ),
        ],
      ),
    );
  }

  static List<PasoLinea> _pasos(BuildContext context, OrdenEnVivo orden) {
    final textos = AppLocalizations.of(context);
    final entrega = orden.entregaEstimada;
    String? nota(PasoLineaTaller paso) {
      if (paso.estado != EstadoEtapa.actual || entrega == null) {
        return paso.nota;
      }
      final hora = horaTaller(context, entrega);
      return paso.nota == null
          ? textos.tallerOrdenNotaEntrega(hora)
          : textos.tallerOrdenNotaYEntrega(paso.nota!, hora);
    }

    return [
      for (final paso in orden.lineaDeTiempo())
        PasoLinea(
          titulo: textoEtapa(textos, paso.etapa),
          estado: switch (paso.estado) {
            EstadoEtapa.hecha => EstadoPaso.hecho,
            EstadoEtapa.actual => EstadoPaso.actual,
            EstadoEtapa.pendiente => EstadoPaso.pendiente,
          },
          hora: paso.inicio == null
              ? null
              : horaCortaTaller(context, paso.inicio!),
          nota: nota(paso),
        ),
    ];
  }
}

/// Barra del avance de la orden, de 0 a 100. El lector de pantalla dice el
/// porcentaje.
class BarraAvance extends StatelessWidget {
  const BarraAvance({required this.avance, super.key});

  final int avance;

  @override
  Widget build(BuildContext context) {
    final c = TokensPista.de(context).colores;
    return Semantics(
      label: AppLocalizations.of(context).tallerTarjetaAvance(avance),
      excludeSemantics: true,
      child: ClipRRect(
        borderRadius: Radios.bordePildora,
        child: LinearProgressIndicator(
          value: avance.clamp(0, 100) / 100,
          minHeight: Espaciado.e2,
          color: c.acento,
          backgroundColor: c.superficieHundida,
        ),
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
        Esqueleto(alto: 160),
        SizedBox(height: Espaciado.e4),
        Esqueleto(alto: 240),
        SizedBox(height: Espaciado.e4),
        Esqueleto(alto: 120),
      ],
    ),
  );
}
