import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:lucide_icons_flutter/lucide_icons_300.dart';

import '../../../api/excepciones.dart';
import '../../../api/modelos/traslado.dart';
import '../../../l10n/app_localizations.dart';
import '../../../nucleo/diseno/componentes/aviso.dart';
import '../../../nucleo/diseno/componentes/esqueleto.dart';
import '../../../nucleo/diseno/componentes/estado_error.dart';
import '../../../nucleo/diseno/componentes/estado_vacio.dart';
import '../../../nucleo/diseno/componentes/fila_acciones.dart';
import '../../../nucleo/diseno/componentes/grupo_lista.dart';
import '../../../nucleo/diseno/componentes/linea_de_tiempo.dart';
import '../../../nucleo/diseno/componentes/mapa.dart';
import '../../../nucleo/diseno/componentes/marco_pantalla.dart';
import '../../../nucleo/diseno/componentes/tono.dart';
import '../../../nucleo/diseno/tokens/espaciado.dart';
import '../../../nucleo/diseno/tokens/tokens_pista.dart';
import '../../../nucleo/mapas/mapas.dart';
import 'estilo_seguimiento.dart';
import 'rutas_recoleccion.dart';
import 'seguimiento_traslado.dart';

/// Seguimiento de un traslado de recolección (V2-M17.03): en qué paso va, su
/// franja y, solo cuando el chofer va en camino o de regreso, dónde está.
///
/// El estado y la posición cambian solos con los eventos
/// `traslado.estado` y `traslado.ubicacion`; jalar o «Actualizar» vuelve a
/// consultar. Resuelve los cinco estados: cargando, datos, no encontrado,
/// error con reintento y sin conexión. Mientras está abierta escucha el canal
/// de eventos; al salir lo suelta.
class PantallaSeguimientoTraslado extends ConsumerWidget {
  const PantallaSeguimientoTraslado({required this.trasladoId, super.key});

  final int trasladoId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textos = AppLocalizations.of(context);
    final proveedor = seguimientoTrasladoProvider(trasladoId);
    final estado = ref.watch(proveedor);
    final traslado = estado.value;

    if (traslado == null) {
      final error = estado.error;
      return MarcoPantalla.estado(
        titulo: textos.recoleccionSeguimientoTitulo,
        conRegreso: true,
        estado: switch (error) {
          null => const _Cargando(),
          NoEncontrado() => EstadoVacio(
            titulo: textos.recoleccionSeguimientoNoEncontradoTitulo,
            mensaje: textos.recoleccionSeguimientoNoEncontradoMensaje,
            icono: LucideIcons300.truck,
          ),
          _ => EstadoError(
            causa: error is SinConexion
                ? CausaError.sinConexion
                : CausaError.generico,
            alReintentar: () => ref.invalidate(proveedor),
          ),
        },
      );
    }

    return _Contenido(
      traslado: traslado,
      actualizando: estado.isLoading,
      fallo: estado.hasError,
      alActualizar: ref.read(proveedor.notifier).refrescar,
    );
  }
}

class _Cargando extends StatelessWidget {
  const _Cargando();

  @override
  Widget build(BuildContext context) => Semantics(
    label: AppLocalizations.of(context).recoleccionSeguimientoCargando,
    liveRegion: true,
    child: const SingleChildScrollView(
      physics: NeverScrollableScrollPhysics(),
      child: Padding(
        padding: EdgeInsets.all(Espaciado.e4),
        child: Column(
          children: [
            Esqueleto(alto: 240, radio: 28),
            SizedBox(height: Espaciado.e4),
            Esqueleto(alto: 72, radio: 16),
            SizedBox(height: Espaciado.e3),
            Esqueleto(alto: 72, radio: 16),
          ],
        ),
      ),
    ),
  );
}

class _Contenido extends ConsumerWidget {
  const _Contenido({
    required this.traslado,
    required this.actualizando,
    required this.fallo,
    required this.alActualizar,
  });

  final TrasladoDetalle traslado;
  final bool actualizando;
  final bool fallo;
  final Future<void> Function() alActualizar;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textos = AppLocalizations.of(context);
    final tokens = TokensPista.de(context);
    final c = tokens.colores;
    final t = tokens.tipografia;
    final estado = traslado.estado;
    final nombre = textos.nombreDeEstadoTraslado(estado);
    final titulo = textos.tituloDeTraslado(traslado);
    final chofer = traslado.ubicacionChofer;
    final hayChecklist =
        estado != EstadoTraslado.programado &&
        estado != EstadoTraslado.cancelado;
    final localidad = Localizations.localeOf(context).toString();

    final actualizar = AccionPantalla(
      texto: textos.recoleccionSeguimientoActualizar,
      icono: LucideIcons300.refreshCw,
      alPresionar: actualizando ? null : alActualizar,
    );

    return MarcoPantalla(
      titulo: titulo,
      subtitulo: nombre,
      conRegreso: true,
      alRefrescar: alActualizar,
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(Espaciado.e4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sin checklist (aun no hay) la unica accion es actualizar.
                if (hayChecklist)
                  FilaAcciones(
                    principal: AccionPantalla(
                      texto: textos.recoleccionSeguimientoVerChecklist,
                      icono: LucideIcons300.clipboardCheck,
                      alPresionar: () =>
                          context.push(rutaChecklistTraslado(traslado.id)),
                    ),
                    secundaria: actualizar,
                  )
                else
                  FilaAcciones(principal: actualizar),
                const SizedBox(height: Espaciado.e5),
                if (fallo) ...[
                  Aviso(
                    mensaje: textos.recoleccionSeguimientoFalloAlActualizar,
                    tono: Tono.advertencia,
                  ),
                  const SizedBox(height: Espaciado.e4),
                ],
                GrupoLista(
                  filas: [
                    FilaGrupo(
                      titulo: titulo,
                      subtitulo: textos.recoleccionSeguimientoVentana(
                        traslado.fecha,
                        traslado.ventanaInicio,
                        traslado.ventanaFin,
                      ),
                      icono: LucideIcons300.clock,
                      colorIcono: c.marca,
                    ),
                  ],
                ),
                if (estado.muestraChofer && chofer != null) ...[
                  const SizedBox(height: Espaciado.e5),
                  Semantics(
                    header: true,
                    child: Text(
                      textos.recoleccionSeguimientoMapaEncabezado,
                      style: t.titulo3.copyWith(color: c.texto),
                    ),
                  ),
                  const SizedBox(height: Espaciado.e3),
                  Mapa(
                    teselas: ref.watch(configuracionTeselasProvider),
                    descripcion: textos.recoleccionSeguimientoMapaDescripcion(
                      '${chofer.lat}',
                      '${chofer.lng}',
                    ),
                    enMovimiento: MarcadorEnMovimiento(
                      posicion: Coordenada(chofer.lat, chofer.lng),
                      etiqueta: textos.recoleccionSeguimientoMarcadorChofer,
                    ),
                  ),
                  const SizedBox(height: Espaciado.e2),
                  Text(
                    textos.recoleccionSeguimientoActualizadaEn(
                      DateFormat.Hm(localidad)
                          .format(chofer.actualizadaEn.toLocal()),
                    ),
                    style: t.cuerpoChico.copyWith(color: c.textoSecundario),
                  ),
                ],
                const SizedBox(height: Espaciado.e5),
                Semantics(
                  header: true,
                  child: Text(
                    textos.recoleccionSeguimientoLineaEncabezado,
                    style: t.titulo3.copyWith(color: c.texto),
                  ),
                ),
                const SizedBox(height: Espaciado.e2),
                Semantics(
                  liveRegion: true,
                  child: Text(
                    nombre,
                    style: t.cuerpoFuerte.copyWith(color: c.acento),
                  ),
                ),
                const SizedBox(height: Espaciado.e4),
                LineaDeTiempo(pasos: _pasos(textos, estado)),
                const SizedBox(height: Espaciado.e6),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Los pasos del traslado. Uno cancelado corta la línea en «Cancelado».
List<PasoLinea> _pasos(AppLocalizations textos, EstadoTraslado estado) {
  PasoLinea paso(EstadoTraslado de, EstadoPaso situacion) => PasoLinea(
    titulo: textos.nombreDeEstadoTraslado(de),
    estado: situacion,
    nota: situacion == EstadoPaso.actual
        ? textos.notaDeEstadoTraslado(de)
        : null,
  );

  if (estado == EstadoTraslado.cancelado) {
    return [
      paso(EstadoTraslado.programado, EstadoPaso.hecho),
      paso(EstadoTraslado.cancelado, EstadoPaso.actual),
    ];
  }
  final actual = pasosDeTraslado.indexOf(estado);
  return [
    for (var i = 0; i < pasosDeTraslado.length; i++)
      paso(
        pasosDeTraslado[i],
        i < actual
            ? EstadoPaso.hecho
            : i == actual
            ? EstadoPaso.actual
            : EstadoPaso.pendiente,
      ),
  ];
}
