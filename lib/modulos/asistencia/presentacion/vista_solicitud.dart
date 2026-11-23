import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../../nucleo/diseno/componentes/aviso.dart';
import '../../../nucleo/diseno/componentes/barra_portada.dart';
import '../../../nucleo/diseno/componentes/cabecera_portada.dart';
import '../../../nucleo/diseno/componentes/grupo_lista.dart';
import '../../../nucleo/diseno/tokens/espaciado.dart';
import '../../../nucleo/diseno/tokens/tokens_pista.dart';
import '../../vehiculos/vehiculos.dart' show vehiculoProvider;
import '../dominio/solicitud_asistencia.dart';
import 'estilo_solicitud.dart';
import 'rutas_asistencia.dart';

/// La solicitud de ayuda ya enviada: folio, resumen y un recordatorio de que
/// la ubicacion solo se comparte mientras esta abierta (V2-M11.01).
///
/// Sirve para la que se acaba de crear y para la que ya estaba abierta;
/// [yaAbierta] agrega el aviso que lo explica. No muestra las coordenadas: el
/// folio basta para el cliente y la ubicacion no se repite en pantalla.
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
    final comentario = solicitud.comentario;

    return Scaffold(
      backgroundColor: c.fondo,
      extendBodyBehindAppBar: true,
      appBar: const BarraPortada(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CabeceraPortada(
              titulo: folio,
              subtitulo: solicitud.estado == EstadoSolicitud.recibida
                  ? textos.asistenciaSolicitudRecibida
                  : tipo,
              descripcion: '$folio, $tipo',
              tinte: c.peligro,
              portada: ColoredBox(
                color: c.superficieElevada,
                child: Icon(solicitud.tipo.icono, size: 120, color: c.peligro),
              ),
              principal: AccionPortada(
                texto: textos.asistenciaSolicitudVerGuias,
                icono: Icons.menu_book_outlined,
                alPresionar: () => context.go(rutaAsistenciaGuias),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(Espaciado.e4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (yaAbierta) ...[
                    Aviso(mensaje: textos.asistenciaSolicitudYaAbierta),
                    const SizedBox(height: Espaciado.e4),
                  ],
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
                          icono: Icons.directions_car_outlined,
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
                        icono: Icons.location_on_outlined,
                      ),
                      if (comentario != null)
                        FilaGrupo(
                          titulo: textos.asistenciaSolicitudComentario,
                          subtitulo: comentario,
                          icono: Icons.notes_outlined,
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
          ],
        ),
      ),
    );
  }
}
