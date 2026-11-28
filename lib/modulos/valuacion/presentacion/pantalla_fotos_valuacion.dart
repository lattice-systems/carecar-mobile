import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lucide_icons_flutter/lucide_icons_300.dart';

import '../../../api/excepciones.dart';
import '../../../l10n/app_localizations.dart';
import '../../../nucleo/camara/selector_foto.dart';
import '../../../nucleo/diseno/componentes/aviso.dart';
import '../../../nucleo/diseno/componentes/boton_pildora.dart';
import '../../../nucleo/diseno/componentes/estado_vacio.dart';
import '../../../nucleo/diseno/componentes/marco_pantalla.dart';
import '../../../nucleo/diseno/componentes/tono.dart';
import '../../../nucleo/diseno/tokens/espaciado.dart';
import '../../../nucleo/diseno/tokens/radios.dart';
import '../../../nucleo/diseno/tokens/tokens_pista.dart';
import '../dominio/valuacion.dart';
import 'formato_valuacion.dart';
import 'piezas_valuacion.dart';
import 'proveedores_valuacion.dart';
import 'silueta_toma.dart';

/// Las fotos guiadas (V2-M26.02): las 8 tomas en orden, cada una con su
/// silueta, su instruccion y la foto ya subida. Cada foto se sube sola al
/// tomarla o elegirla; si falla, se queda en pantalla con «Reintentar» y las
/// demas no se pierden. Sin permiso, explica y abre los ajustes. Una
/// valuacion cerrada no ofrece subir.
class PantallaFotosValuacion extends ConsumerStatefulWidget {
  const PantallaFotosValuacion({required this.valuacionId, super.key});

  final int valuacionId;

  @override
  ConsumerState<PantallaFotosValuacion> createState() =>
      _PantallaFotosValuacionState();
}

class _PantallaFotosValuacionState
    extends ConsumerState<PantallaFotosValuacion> {
  bool _sinPermiso = false;
  bool _sinCamara = false;
  bool _cerrada = false;

  Future<void> _elegir(TomaValuacion toma, OrigenFoto origen) async {
    final FotoElegida? foto;
    try {
      foto = await ref.read(selectorValuacionProvider).elegir(origen);
    } on PermisoFotoDenegado {
      if (mounted) setState(() => _sinPermiso = true);
      return;
    } on Object {
      if (mounted) setState(() => _sinCamara = true);
      return;
    }
    if (foto == null || !mounted) return;
    setState(() {
      _sinPermiso = false;
      _sinCamara = false;
    });
    final subidas = ref.read(
      subidasValuacionProvider(widget.valuacionId).notifier,
    );
    final derecha = await ref.read(enderezarFotoProvider)(foto);
    if (!mounted) return;
    await _enviar(subidas.subir(toma, derecha));
  }

  Future<void> _enviar(Future<bool> subida) async {
    final admitida = await subida;
    if (!admitida && mounted) setState(() => _cerrada = true);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final titulo = t.valuacionFotosGuiadasTitulo;
    final subidas = ref.watch(subidasValuacionProvider(widget.valuacionId));

    return ref
        .watch(valuacionProvider(widget.valuacionId))
        .when(
          skipLoadingOnReload: true,
          loading: () => MarcoPantalla.estado(
            icono: LucideIcons300.camera,
            titulo: titulo,
            conRegreso: true,
            estado: const EsqueletoValuacion(altos: [240, 240]),
          ),
          error: (error, _) => MarcoPantalla.estado(
            icono: LucideIcons300.camera,
            titulo: titulo,
            conRegreso: true,
            estado: error is NoEncontrado
                ? EstadoVacio(
                    titulo: t.valuacionNoEncontradaTitulo,
                    mensaje: t.valuacionNoEncontradaMensaje,
                    icono: LucideIcons300.searchX,
                  )
                : ErrorValuacion(
                    error: error,
                    alReintentar: () =>
                        ref.invalidate(valuacionProvider(widget.valuacionId)),
                  ),
          ),
          data: (valuacion) => _contenido(context, valuacion, subidas),
        );
  }

  Widget _contenido(
    BuildContext context,
    Valuacion valuacion,
    Map<TomaValuacion, SubidaPendiente> subidas,
  ) {
    final t = AppLocalizations.of(context);
    final admite = valuacion.estado.admiteFotos;
    final aviso = _sinPermiso
        ? t.valuacionFotosSinPermiso
        : _sinCamara
        ? t.valuacionFotosSinCamara
        : null;

    return MarcoPantalla(
      icono: LucideIcons300.camera,
      titulo: t.valuacionFotosGuiadasTitulo,
      subtitulo: t.valuacionFotosAvance(
        valuacion.fotos.length,
        TomaValuacion.values.length,
      ),
      conRegreso: true,
      alRefrescar: () =>
          ref.refresh(valuacionProvider(widget.valuacionId).future),
      barraInferior: aviso == null
          ? null
          : BarraInferior(
              hijos: [
                Aviso(mensaje: aviso, tono: Tono.advertencia),
                if (_sinPermiso) ...[
                  const SizedBox(height: Espaciado.e2),
                  BotonPildora(
                    texto: t.valuacionFotosAbrirAjustes,
                    expandido: true,
                    alPresionar: () =>
                        ref.read(selectorValuacionProvider).abrirAjustes(),
                  ),
                ],
              ],
            ),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: Espaciado.e4),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: Espaciado.e2),
                if (!admite || _cerrada)
                  Aviso(
                    mensaje: t.valuacionFotosCerrada,
                    tono: Tono.advertencia,
                  )
                else
                  Aviso(mensaje: t.valuacionFotosPrivacidad),
                for (final toma in TomaValuacion.values) ...[
                  const SizedBox(height: Espaciado.e3),
                  _TarjetaToma(
                    toma: toma,
                    foto: valuacion.fotoDe(toma),
                    pendiente: subidas[toma],
                    admite: admite,
                    alElegir: (origen) => _elegir(toma, origen),
                    alReintentar: () => _enviar(
                      ref
                          .read(
                            subidasValuacionProvider(widget.valuacionId)
                                .notifier,
                          )
                          .reintentar(toma),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _TarjetaToma extends ConsumerWidget {
  const _TarjetaToma({
    required this.toma,
    required this.foto,
    required this.pendiente,
    required this.admite,
    required this.alElegir,
    required this.alReintentar,
  });

  final TomaValuacion toma;
  final FotoValuacion? foto;
  final SubidaPendiente? pendiente;
  final bool admite;
  final ValueChanged<OrigenFoto> alElegir;
  final VoidCallback alReintentar;

  static const double _altoFoto = 180;

  // La misma lista en cada repintado: asi la imagen no se vuelve a decodificar.
  static Uint8List _bytes(List<int> bytes) =>
      bytes is Uint8List ? bytes : Uint8List.fromList(bytes);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final tokens = TokensPista.de(context);
    final c = tokens.colores;
    final nombre = nombreToma(t, toma);
    final enCurso = pendiente;
    final subiendo = enCurso?.subiendo ?? false;

    final ImageProvider? imagen = enCurso != null
        ? MemoryImage(_bytes(enCurso.foto.bytes))
        : foto == null
        ? null
        : ref.watch(imagenValuacionProvider)(foto!.url);

    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: nombre,
      child: SuperficieValuacion(
        hijo: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
              header: true,
              child: Text(
                t.valuacionTomaNumero(toma.index + 1, nombre),
                style: tokens.tipografia.titulo3.copyWith(color: c.texto),
              ),
            ),
            const SizedBox(height: Espaciado.e2),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Espaciado.e8),
              child: SiluetaToma(toma: toma),
            ),
            const SizedBox(height: Espaciado.e2),
            Text(
              instruccionToma(t, toma),
              style: tokens.tipografia.cuerpo.copyWith(
                color: c.textoSecundario,
              ),
            ),
            if (imagen != null) ...[
              const SizedBox(height: Espaciado.e3),
              ClipRRect(
                borderRadius: Radios.bordeControl,
                child: Image(
                  image: imagen,
                  height: _altoFoto,
                  fit: BoxFit.cover,
                  gaplessPlayback: true,
                  semanticLabel: enCurso == null
                      ? t.valuacionFotoSubida(nombre)
                      : t.valuacionFotoPorSubir(nombre),
                  errorBuilder: (_, _, _) => ColoredBox(
                    color: c.superficieHundida,
                    child: SizedBox(
                      height: _altoFoto,
                      child: Icon(
                        LucideIcons300.imageOff,
                        color: c.textoTerciario,
                      ),
                    ),
                  ),
                ),
              ),
            ],
            if (subiendo) ...[
              const SizedBox(height: Espaciado.e2),
              Semantics(
                liveRegion: true,
                child: Text(
                  t.valuacionFotoSubiendo,
                  style: tokens.tipografia.cuerpoChico.copyWith(
                    color: c.textoSecundario,
                  ),
                ),
              ),
            ],
            if (enCurso != null && !subiendo) ...[
              const SizedBox(height: Espaciado.e3),
              Aviso(
                mensaje: switch (enCurso.fallo) {
                  SinConexion() => t.valuacionFotoSinConexion,
                  // Arriba de 20 MB el servidor corta con 413.
                  DatosInvalidos() ||
                  ErrorDelServidor(status: 413) => t.valuacionFotoInvalida,
                  _ => t.valuacionFotoError,
                },
                tono: Tono.peligro,
              ),
              if (admite) ...[
                const SizedBox(height: Espaciado.e2),
                BotonPildora(
                  texto: t.valuacionReintentar,
                  icono: LucideIcons300.refreshCw,
                  expandido: true,
                  alPresionar: alReintentar,
                ),
              ],
            ],
            if (admite) ...[
              const SizedBox(height: Espaciado.e3),
              BotonPildora(
                texto: t.valuacionFotoTomar,
                icono: LucideIcons300.camera,
                variante: VarianteBotonPildora.tonal,
                expandido: true,
                cargando: subiendo,
                alPresionar: () => alElegir(OrigenFoto.camara),
              ),
              const SizedBox(height: Espaciado.e2),
              BotonPildora(
                texto: t.valuacionFotoGaleria,
                icono: LucideIcons300.images,
                variante: VarianteBotonPildora.vidrio,
                expandido: true,
                alPresionar: subiendo
                    ? null
                    : () => alElegir(OrigenFoto.galeria),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
