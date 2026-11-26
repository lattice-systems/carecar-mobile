import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lucide_icons_flutter/lucide_icons_300.dart';

import '../../../l10n/app_localizations.dart';
import '../../../nucleo/diseno/componentes/barra_pantalla.dart';
import '../../../nucleo/diseno/componentes/aviso.dart';
import '../../../nucleo/diseno/componentes/boton_pildora.dart';
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
/// el vendedor cuando ya hay uno. La primera pagina la trae el proveedor; las
/// siguientes, «Ver mas», se suman aqui de una en una.
class PantallaMisSolicitudes extends ConsumerStatefulWidget {
  const PantallaMisSolicitudes({super.key});

  @override
  ConsumerState<PantallaMisSolicitudes> createState() =>
      _PantallaMisSolicitudesState();
}

class _PantallaMisSolicitudesState
    extends ConsumerState<PantallaMisSolicitudes> {
  /// Lo que han traido los «Ver mas», detras de la primera pagina.
  final _siguientes = <SolicitudDeEstreno>[];
  int? _ultimaPagina;
  bool? _hayMas;
  bool _cargandoMas = false;
  bool _falloMas = false;

  Future<void> _verMas(PaginaDeSolicitudes primera) async {
    setState(() {
      _cargandoMas = true;
      _falloMas = false;
    });
    try {
      final pagina = await ref
          .read(repositorioEstrenoProvider)
          .solicitudes(pagina: (_ultimaPagina ?? primera.pagina) + 1);
      if (!mounted) return;
      setState(() {
        _siguientes.addAll(pagina.solicitudes);
        _ultimaPagina = pagina.pagina;
        _hayMas = pagina.hayMas;
        _cargandoMas = false;
      });
    } on FalloEstreno {
      if (!mounted) return;
      setState(() {
        _cargandoMas = false;
        _falloMas = true;
      });
    }
  }

  /// Jalar para recargar vuelve a la primera pagina.
  Future<void> _recargar() {
    setState(() {
      _siguientes.clear();
      _ultimaPagina = null;
      _hayMas = null;
      _falloMas = false;
    });
    return ref.refresh(misSolicitudesProvider.future);
  }

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final c = TokensPista.de(context).colores;
    final pagina = ref.watch(misSolicitudesProvider);

    return Scaffold(
      backgroundColor: c.fondo,
      body: Column(
        children: [
          BarraPantalla(titulo: textos.estrenoMisSolicitudes),
          Expanded(
            child: SafeArea(
              top: false,
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
                        icono: LucideIcons300.carFront,
                      )
                    : RefreshIndicator(
                        onRefresh: _recargar,
                        child: ListView(
                          // Siempre desplazable para que jalar a recargar funcione
                          // con pocas filas.
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(Espaciado.e4),
                          children: [
                            GrupoLista(
                              filas: [
                                for (final s in [
                                  ...p.solicitudes,
                                  ..._siguientes,
                                ])
                                  _fila(context, textos, s),
                              ],
                            ),
                            if (_falloMas) ...[
                              const SizedBox(height: Espaciado.e3),
                              Aviso(
                                mensaje: textos.estrenoErrorMas,
                                tono: Tono.peligro,
                              ),
                            ],
                            if (_hayMas ?? p.hayMas) ...[
                              const SizedBox(height: Espaciado.e3),
                              BotonPildora(
                                texto: _cargandoMas
                                    ? textos.estrenoCargandoMas
                                    : textos.estrenoVerMas,
                                variante: VarianteBotonPildora.vidrio,
                                expandido: true,
                                alPresionar: _cargandoMas
                                    ? null
                                    : () => _verMas(p),
                              ),
                            ],
                          ],
                        ),
                      ),
              ),
            ),
          ),
        ],
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
    final datos = [
      tipo,
      if (s.fecha != null) diaCortoEstreno(context, s.fecha!),
      if (s.cotizacion != null)
        '${pesosEstreno.format(s.cotizacion!.mensualidad)} · '
            '${textos.estrenoMeses(s.cotizacion!.plazoMeses)}',
    ].join(' · ');
    // Quien atiende va en su propia linea, no pegado al resto.
    final detalle = [
      datos,
      if (s.vendedor != null) textos.estrenoTeAtiende(s.vendedor!),
    ].join('\n');
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
          ? LucideIcons300.car
          : LucideIcons300.fileText,
      colorIcono: c.acento,
      fin: Insignia(texto: estado, tono: tono),
    );
  }
}
