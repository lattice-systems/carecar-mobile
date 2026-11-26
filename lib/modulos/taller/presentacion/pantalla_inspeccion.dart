import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lucide_icons_flutter/lucide_icons_300.dart';

import '../../../api/excepciones.dart';
import '../../../l10n/app_localizations.dart';
import '../../../nucleo/diseno/componentes/aviso.dart';
import '../../../nucleo/diseno/componentes/esqueleto.dart';
import '../../../nucleo/diseno/componentes/estado_error.dart';
import '../../../nucleo/diseno/componentes/estado_vacio.dart';
import '../../../nucleo/diseno/componentes/galeria_fotos.dart';
import '../../../nucleo/diseno/componentes/grupo_lista.dart';
import '../../../nucleo/diseno/componentes/marco_pantalla.dart';
import '../../../nucleo/diseno/componentes/semaforo.dart';
import '../../../nucleo/diseno/componentes/tono.dart';
import '../../../nucleo/diseno/tokens/espaciado.dart';
import '../../../nucleo/diseno/tokens/tokens_pista.dart';
import '../dominio/orden_taller.dart';
import 'formato_taller.dart';
import 'proveedores_taller.dart';

/// Inspeccion multipunto de la orden (V2-M04.04): cada punto con su semaforo
/// (icono y texto, no solo color) y el comentario del tecnico, sus fotos en una
/// galeria que se amplia con zoom y sus videos, que se abren en el reproductor
/// del telefono. Al final, las fotos y videos de la orden que no son de un
/// punto. Resuelve esqueleto, datos, vacio, error y sin conexion.
class PantallaInspeccion extends ConsumerStatefulWidget {
  const PantallaInspeccion({required this.ordenId, super.key});

  final int ordenId;

  @override
  ConsumerState<PantallaInspeccion> createState() => _EstadoInspeccion();
}

class _EstadoInspeccion extends ConsumerState<PantallaInspeccion> {
  bool _videoFallo = false;

  Future<void> _abrirVideo(Evidencia video) async {
    setState(() => _videoFallo = false);
    bool abierto;
    try {
      abierto = await ref.read(abrirVideoProvider)(video.url);
    } on Object {
      abierto = false;
    }
    if (mounted && !abierto) setState(() => _videoFallo = true);
  }

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final orden = ref.watch(ordenTallerProvider(widget.ordenId));

    final Widget contenido = orden.when(
      skipLoadingOnReload: true,
      loading: () => const SliverToBoxAdapter(child: _Cargando()),
      error: (error, _) => SliverFillRemaining(
        child: EstadoError(
          causa: error is SinConexion
              ? CausaError.sinConexion
              : CausaError.generico,
          textoReintentar: textos.tallerReintentar,
          alReintentar: () =>
              ref.invalidate(ordenTallerProvider(widget.ordenId)),
        ),
      ),
      data: (o) => o.inspeccion.isEmpty && o.evidencias.isEmpty
          ? SliverFillRemaining(
              child: EstadoVacio(
                titulo: textos.tallerInspeccionVacia,
                mensaje: textos.tallerInspeccionVaciaMensaje,
                icono: LucideIcons300.clipboardCheck,
              ),
            )
          : SliverToBoxAdapter(
              child: _Inspeccion(
                orden: o,
                videoFallo: _videoFallo,
                alAbrirVideo: _abrirVideo,
              ),
            ),
    );

    return MarcoPantalla(
      titulo: textos.tallerInspeccionTitulo,
      subtitulo: orden.value?.vehiculo,
      conRegreso: true,
      alRefrescar: () =>
          ref.refresh(ordenTallerProvider(widget.ordenId).future),
      slivers: [contenido],
    );
  }
}

class _Inspeccion extends ConsumerWidget {
  const _Inspeccion({
    required this.orden,
    required this.videoFallo,
    required this.alAbrirVideo,
  });

  final OrdenEnVivo orden;
  final bool videoFallo;
  final ValueChanged<Evidencia> alAbrirVideo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textos = AppLocalizations.of(context);
    final t = TokensPista.de(context).tipografia;
    final imagen = ref.watch(imagenEvidenciaProvider);

    List<Widget> evidencias(List<Evidencia> todas, String descripcion) {
      final fotos = todas.where((e) => e.tipo == TipoEvidencia.foto).toList();
      final videos = todas.where((e) => e.tipo == TipoEvidencia.video).toList();
      return [
        if (fotos.isNotEmpty) ...[
          const SizedBox(height: Espaciado.e3),
          GaleriaFotos(
            alto: 200,
            fotos: [
              for (final foto in fotos)
                FotoGaleria(imagen: imagen(foto.url), descripcion: descripcion),
            ],
          ),
        ],
        if (videos.isNotEmpty) ...[
          const SizedBox(height: Espaciado.e3),
          GrupoLista(
            filas: [
              for (final (i, video) in videos.indexed)
                FilaGrupo(
                  titulo: textos.tallerInspeccionVerVideo(i + 1),
                  subtitulo: textos.tallerInspeccionVideoAbre,
                  icono: LucideIcons300.circlePlay,
                  colorIcono: TokensPista.de(context).colores.acento,
                  alToque: () => alAbrirVideo(video),
                ),
            ],
          ),
        ],
      ];
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Espaciado.margenTelefono),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (videoFallo) ...[
            Aviso(
              mensaje: textos.tallerInspeccionVideoError,
              tono: Tono.peligro,
            ),
            const SizedBox(height: Espaciado.e4),
          ],
          for (final punto in orden.inspeccion) ...[
            Semaforo(
              punto: punto.punto,
              estado: semaforoDe(punto.resultado),
              detalle: punto.comentario,
            ),
            ...evidencias(
              punto.evidencias,
              textos.tallerInspeccionFotoDe(punto.punto),
            ),
            const SizedBox(height: Espaciado.e5),
          ],
          if (orden.evidencias.isNotEmpty) ...[
            Text(textos.tallerInspeccionDeLaOrden, style: t.titulo3),
            ...evidencias(
              orden.evidencias,
              textos.tallerInspeccionFotoDeLaOrden,
            ),
          ],
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
        Esqueleto(alto: 64),
        SizedBox(height: Espaciado.e3),
        Esqueleto(alto: 200),
        SizedBox(height: Espaciado.e5),
        Esqueleto(alto: 64),
      ],
    ),
  );
}
