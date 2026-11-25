import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../../nucleo/diseno/componentes/esqueleto.dart';
import '../../../nucleo/diseno/componentes/estado_error.dart';
import '../../../nucleo/diseno/componentes/estado_vacio.dart';
import '../../../nucleo/diseno/componentes/grupo_lista.dart';
import '../../../nucleo/diseno/componentes/insignia.dart';
import '../../../nucleo/diseno/componentes/tono.dart';
import '../../../nucleo/diseno/tokens/espaciado.dart';
import '../../../nucleo/diseno/tokens/tokens_pista.dart';
import '../dominio/estreno.dart';
import 'componentes_estreno.dart';
import 'proveedores_estreno.dart';

/// Mis solicitudes de estreno (V2-M16.04): tipo, modelo, estado con texto y
/// el vendedor cuando ya hay uno.
class PantallaMisSolicitudes extends ConsumerWidget {
  const PantallaMisSolicitudes({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textos = AppLocalizations.of(context);
    final c = TokensPista.de(context).colores;
    final pagina = ref.watch(misSolicitudesProvider);

    return Scaffold(
      backgroundColor: c.fondo,
      appBar: AppBar(title: Text(textos.estrenoMisSolicitudes)),
      body: SafeArea(
        child: pagina.when(
          loading: () => Semantics(
            label: textos.estrenoCargando,
            liveRegion: true,
            child: const Padding(
              padding: EdgeInsets.all(Espaciado.e4),
              child: Column(
                children: [
                  Esqueleto(alto: 72),
                  SizedBox(height: Espaciado.e3),
                  Esqueleto(alto: 72),
                ],
              ),
            ),
          ),
          error: (error, _) => EstadoError(
            causa: error is EstrenoSinConexion
                ? CausaError.sinConexion
                : CausaError.generico,
            alReintentar: () => ref.invalidate(misSolicitudesProvider),
          ),
          data: (p) => p.solicitudes.isEmpty
              ? EstadoVacio(
                  titulo: textos.estrenoVacioTitulo,
                  mensaje: textos.estrenoVacioMensaje,
                  icono: Icons.directions_car_filled_outlined,
                )
              : RefreshIndicator(
                  onRefresh: () => ref.refresh(misSolicitudesProvider.future),
                  child: ListView(
                    padding: const EdgeInsets.all(Espaciado.e4),
                    children: [
                      GrupoLista(
                        filas: [
                          for (final s in p.solicitudes)
                            _fila(context, textos, s),
                        ],
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  FilaGrupo _fila(
    BuildContext context,
    AppLocalizations textos,
    SolicitudDeEstreno s,
  ) {
    final c = TokensPista.de(context).colores;
    final tipo = s.tipo == TipoSolicitud.pruebaManejo
        ? textos.estrenoPruebaTitulo
        : textos.estrenoCotizacionTitulo;
    final detalle = [
      tipo,
      if (s.fecha != null) diaCortoEstreno(context, s.fecha!),
      if (s.cotizacion != null)
        '${pesosEstreno.format(s.cotizacion!.mensualidad)} · '
            '${textos.estrenoMeses(s.cotizacion!.plazoMeses)}',
      if (s.vendedor != null) textos.estrenoTeAtiende(s.vendedor!),
    ].join(' · ');
    final (estado, tono) = switch (s.estado) {
      EstadoSolicitud.recibida => (
        textos.estrenoEstadoRecibida,
        Tono.informacion,
      ),
      EstadoSolicitud.enAtencion => (
        textos.estrenoEstadoEnAtencion,
        Tono.exito,
      ),
      EstadoSolicitud.cerrada => (textos.estrenoEstadoCerrada, Tono.neutro),
    };
    return FilaGrupo(
      titulo: s.modelo,
      subtitulo: detalle,
      icono: s.tipo == TipoSolicitud.pruebaManejo
          ? Icons.directions_car_outlined
          : Icons.request_quote_outlined,
      colorIcono: c.acento,
      fin: Insignia(texto: estado, tono: tono),
    );
  }
}
