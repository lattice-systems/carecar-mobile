import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:lucide_icons_flutter/lucide_icons_300.dart';

import '../../../l10n/app_localizations.dart';
import '../../../nucleo/diseno/componentes/aviso.dart';
import '../../../nucleo/diseno/componentes/fila_acciones.dart';
import '../../../nucleo/diseno/componentes/grupo_lista.dart';
import '../../../nucleo/diseno/componentes/linea_de_tiempo.dart';
import '../../../nucleo/diseno/componentes/marco_pantalla.dart';
import '../../../nucleo/diseno/componentes/tono.dart';
import '../../../nucleo/diseno/tokens/espaciado.dart';
import '../../../nucleo/diseno/tokens/tokens_pista.dart';
import '../../vehiculos/vehiculos.dart' show vehiculoProvider;
import '../dominio/solicitud_asistencia.dart';
import 'estilo_solicitud.dart';
import 'rutas_asistencia.dart';
import 'seguimiento_solicitud.dart';

/// La solicitud de ayuda ya enviada: folio, resumen y un recordatorio de que
/// la ubicacion solo se comparte mientras esta abierta (V2-M11.01).
///
/// Sirve para la que se acaba de crear y para la que ya estaba abierta;
/// [yaAbierta] agrega el aviso que lo explica. No muestra las coordenadas: el
/// folio basta para el cliente y la ubicacion no se repite en pantalla.
///
/// Sigue el estado de la solicitud (V2-M11.04): una linea de tiempo recibida,
/// en camino y atendida (o cancelada) que cambia sola con el evento
/// `asistencia.estado` y que se puede actualizar a mano. Mientras esta en
/// pantalla escucha el canal de eventos; al salir lo suelta.
class VistaSolicitud extends ConsumerWidget {
  const VistaSolicitud({
    required this.solicitud,
    required this.yaAbierta,
    super.key,
  });

  final SolicitudAsistencia solicitud;
  final bool yaAbierta;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textos = AppLocalizations.of(context);
    final tokens = TokensPista.de(context);
    final c = tokens.colores;
    final t = tokens.tipografia;
    final tipo = textos.nombreDeTipo(solicitud.tipo);
    final folio = textos.asistenciaSolicitudFolio(solicitud.id);
    final vehiculo = ref
        .watch(vehiculoProvider(solicitud.vehiculoId))
        .asData
        ?.value;
    final seguimiento = ref.watch(seguimientoSolicitudProvider(solicitud.id));
    final estado = seguimiento.estado ?? solicitud.estado;
    final nombreEstado = textos.nombreDeEstado(estado);
    final comentario = solicitud.comentario;

    return MarcoPantalla(
      icono: LucideIcons300.lifeBuoy,
      titulo: folio,
      subtitulo: estado == EstadoSolicitud.recibida
          ? textos.asistenciaSolicitudRecibida
          : nombreEstado,
      conRegreso: true,
      alRefrescar: ref
          .read(seguimientoSolicitudProvider(solicitud.id).notifier)
          .refrescar,
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(Espaciado.e4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FilaAcciones(
                  principal: AccionPantalla(
                    texto: textos.asistenciaSolicitudVerGuias,
                    icono: LucideIcons300.bookOpen,
                    alPresionar: () => context.go(rutaAsistenciaGuias),
                  ),
                  secundaria: AccionPantalla(
                    texto: seguimiento.actualizando
                        ? textos.asistenciaSeguimientoActualizando
                        : textos.asistenciaSeguimientoActualizar,
                    icono: LucideIcons300.refreshCw,
                    alPresionar: seguimiento.actualizando
                        ? null
                        : ref
                              .read(
                                seguimientoSolicitudProvider(solicitud.id)
                                    .notifier,
                              )
                              .refrescar,
                  ),
                ),
                const SizedBox(height: Espaciado.e6),
                if (yaAbierta) ...[
                  Aviso(mensaje: textos.asistenciaSolicitudYaAbierta),
                  const SizedBox(height: Espaciado.e4),
                ],
                if (seguimiento.fallo) ...[
                  Aviso(
                    mensaje: textos.asistenciaSeguimientoFallo,
                    tono: Tono.advertencia,
                  ),
                  const SizedBox(height: Espaciado.e4),
                ],
                if (!estado.abierta) ...[
                  Aviso(
                    mensaje: textos.asistenciaSeguimientoUbicacionCerrada,
                    tono: estado == EstadoSolicitud.atendida
                        ? Tono.exito
                        : Tono.informacion,
                  ),
                  const SizedBox(height: Espaciado.e4),
                ],
                Semantics(
                  header: true,
                  child: Text(
                    textos.asistenciaSeguimientoEncabezado,
                    style: t.titulo3.copyWith(color: c.texto),
                  ),
                ),
                const SizedBox(height: Espaciado.e2),
                Semantics(
                  liveRegion: true,
                  label: textos.asistenciaEstadoActual(nombreEstado),
                  excludeSemantics: true,
                  child: Text(
                    nombreEstado,
                    style: t.cuerpoFuerte.copyWith(color: c.acento),
                  ),
                ),
                const SizedBox(height: Espaciado.e4),
                LineaDeTiempo(
                  pasos: _pasos(
                    textos,
                    estado,
                    DateFormat.Hm(Localizations.localeOf(context).toString())
                        .format(solicitud.creadaEn.toLocal()),
                  ),
                ),
                const SizedBox(height: Espaciado.e5),
                Text(
                  textos.asistenciaSolicitudTexto,
                  style: t.cuerpo.copyWith(color: c.textoSecundario),
                ),
                const SizedBox(height: Espaciado.e5),
                GrupoLista(
                  filas: [
                    if (vehiculo != null)
                      FilaGrupo(
                        titulo: textos.asistenciaSolicitudVehiculo,
                        subtitulo: vehiculo.titulo,
                        icono: LucideIcons300.car,
                      ),
                    FilaGrupo(
                      titulo: textos.asistenciaSolicitudProblema,
                      subtitulo: tipo,
                      icono: solicitud.tipo.icono,
                    ),
                    FilaGrupo(
                      titulo: textos.asistenciaSolicitudUbicacion,
                      subtitulo: solicitud.ubicacion == null
                          ? textos.asistenciaSolicitudUbicacionNoCompartida
                          : textos.asistenciaSolicitudUbicacionCompartida,
                      icono: LucideIcons300.mapPin,
                    ),
                    if (comentario != null)
                      FilaGrupo(
                        titulo: textos.asistenciaSolicitudComentario,
                        subtitulo: comentario,
                        icono: LucideIcons300.textAlignStart,
                      ),
                  ],
                ),
                const SizedBox(height: Espaciado.e4),
                Text(
                  textos.asistenciaSolicitudPrivacidad,
                  style: t.cuerpoChico.copyWith(color: c.textoTerciario),
                ),
                const SizedBox(height: Espaciado.e6),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Los pasos de la solicitud segun su estado. Una cancelada corta la linea en
/// «Cancelada»: nunca llego a «Atendida».
List<PasoLinea> _pasos(
  AppLocalizations textos,
  EstadoSolicitud estado,
  String horaDeRecibida,
) {
  PasoLinea paso(EstadoSolicitud de, EstadoPaso situacion, {String? hora}) =>
      PasoLinea(
        titulo: textos.nombreDeEstado(de),
        estado: situacion,
        hora: hora,
        nota: situacion == EstadoPaso.actual ? textos.notaDeEstado(de) : null,
      );

  return switch (estado) {
    EstadoSolicitud.recibida => [
      paso(EstadoSolicitud.recibida, EstadoPaso.actual, hora: horaDeRecibida),
      paso(EstadoSolicitud.enCamino, EstadoPaso.pendiente),
      paso(EstadoSolicitud.atendida, EstadoPaso.pendiente),
    ],
    EstadoSolicitud.enCamino => [
      paso(EstadoSolicitud.recibida, EstadoPaso.hecho, hora: horaDeRecibida),
      paso(EstadoSolicitud.enCamino, EstadoPaso.actual),
      paso(EstadoSolicitud.atendida, EstadoPaso.pendiente),
    ],
    EstadoSolicitud.atendida => [
      paso(EstadoSolicitud.recibida, EstadoPaso.hecho, hora: horaDeRecibida),
      paso(EstadoSolicitud.enCamino, EstadoPaso.hecho),
      paso(EstadoSolicitud.atendida, EstadoPaso.actual),
    ],
    EstadoSolicitud.cancelada => [
      paso(EstadoSolicitud.recibida, EstadoPaso.hecho, hora: horaDeRecibida),
      paso(EstadoSolicitud.cancelada, EstadoPaso.actual),
    ],
  };
}
