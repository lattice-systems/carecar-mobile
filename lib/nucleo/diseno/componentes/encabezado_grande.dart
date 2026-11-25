import 'dart:math' as math;
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../tokens/espaciado.dart';
import '../tokens/tokens_pista.dart';
import 'boton_regresar.dart';

/// Encabezado de pantalla con título grande que se recoge al desplazar.
///
/// Es un sliver: va dentro de un `CustomScrollView`. Tiene dos partes, siempre
/// las mismas en todas las pantallas:
///
/// - **La barra** (56 de alto, fija): a la izquierda el [BotonRegresar] si
///   `conRegreso`, a la derecha las `acciones` (botones circulares o un
///   `GrupoAccionesPildora`). Al recogerse muestra el título pequeño entre
///   ambos.
/// - **El título grande**, alineado a la izquierda, con el `subtitulo` debajo.
///   Se desliza hacia arriba por debajo de la barra y se desvanece mientras el
///   título pequeño aparece; recogido del todo, el subtítulo ya no se arma.
///
/// Las alturas se miden con el tamaño de letra del sistema y el ancho
/// disponible, así que a 200 % el título (hasta dos líneas) no se corta.
///
/// Con `translucido` la barra recogida deja ver el contenido que pasa por
/// debajo, desenfocado y teñido con el fondo; el fondo baja apenas a 92 % de
/// opacidad: asoma color, pero el texto de abajo no se lee a través del título.
class EncabezadoGrande extends StatelessWidget {
  const EncabezadoGrande({
    required this.titulo,
    super.key,
    this.subtitulo,
    this.acciones = const [],
    this.translucido = false,
    this.conRegreso = false,
  });

  final String titulo;
  final String? subtitulo;

  /// Botones al final de la barra, cada uno con su zona táctil de 48.
  final List<Widget> acciones;

  /// Barra recogida translúcida con desenfoque.
  final bool translucido;

  /// Pone un [BotonRegresar] al inicio de la barra; para las pantallas raíz de
  /// un módulo, que se abren desde el menú o un enlace.
  final bool conRegreso;

  @override
  Widget build(BuildContext context) {
    final ancho = math.min(
      MediaQuery.sizeOf(context).width,
      Espaciado.anchoMaximoContenido,
    );
    return SliverPersistentHeader(
      pinned: true,
      delegate: _Delegado(
        titulo: titulo,
        subtitulo: subtitulo,
        acciones: acciones,
        translucido: translucido,
        conRegreso: conRegreso,
        escala: MediaQuery.textScalerOf(context),
        tokens: TokensPista.de(context),
        arriba: MediaQuery.paddingOf(context).top,
        anchoTexto: ancho - 2 * Espaciado.margenTelefono,
        direccion: Directionality.of(context),
      ),
    );
  }
}

class _Delegado extends SliverPersistentHeaderDelegate {
  _Delegado({
    required this.titulo,
    required this.subtitulo,
    required this.acciones,
    required this.translucido,
    required this.conRegreso,
    required this.escala,
    required this.tokens,
    required this.arriba,
    required this.anchoTexto,
    required this.direccion,
  }) {
    _medirBloque();
  }

  final String titulo;
  final String? subtitulo;
  final List<Widget> acciones;
  final bool translucido;
  final bool conRegreso;
  final TextScaler escala;
  final TokensPista tokens;
  final double arriba;

  /// Ancho de una línea del título grande.
  final double anchoTexto;
  final TextDirection direccion;

  /// Alto de la barra fija, sin la zona del reloj.
  static const double _alturaBarra = Espaciado.e14;

  /// Aire bajo el título grande.
  static const double _aireAbajo = Espaciado.e3;
  static const double _desenfoque = 30;

  late final double _altoBloque;

  double _medir(TextStyle estilo, String texto, int lineas) {
    final pintor = TextPainter(
      text: TextSpan(text: texto, style: estilo),
      textDirection: direccion,
      textScaler: escala,
      maxLines: lineas,
    )..layout(maxWidth: math.max(1, anchoTexto));
    final alto = pintor.height;
    pintor.dispose();
    return alto;
  }

  void _medirBloque() {
    final t = tokens.tipografia;
    var alto = _medir(t.titulo1, titulo, 2);
    if (subtitulo != null) {
      alto += Espaciado.e1 + _medir(t.cuerpoChico, subtitulo!, 2);
    }
    _altoBloque = alto;
  }

  @override
  double get minExtent => arriba + _alturaBarra;

  @override
  double get maxExtent => minExtent + _altoBloque + _aireAbajo;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final c = tokens.colores;
    final t = tokens.tipografia;
    final rango = math.max(1, maxExtent - minExtent);
    final avance = (shrinkOffset / rango).clamp(0.0, 1.0);
    // El título grande se va en la primera mitad del recorrido y el pequeño
    // llega en la segunda: nunca se ven los dos a la vez.
    final grande = avance < 0.5;
    final opacidadGrande = (1 - 2 * avance).clamp(0.0, 1.0);
    final opacidadChico = (2 * avance - 1).clamp(0.0, 1.0);

    final fondo = translucido
        ? c.fondo.withValues(alpha: 1 - 0.08 * avance)
        : c.fondo;

    final bloque = Padding(
      padding: const EdgeInsets.symmetric(horizontal: Espaciado.margenTelefono),
      child: Opacity(
        opacity: opacidadGrande,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Semantics(
              header: true,
              child: Text(
                titulo,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: t.titulo1.copyWith(color: c.texto),
              ),
            ),
            if (subtitulo != null) ...[
              const SizedBox(height: Espaciado.e1),
              Text(
                subtitulo!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: t.cuerpoChico.copyWith(color: c.textoSecundario),
              ),
            ],
          ],
        ),
      ),
    );

    final barra = Padding(
      padding: EdgeInsets.fromLTRB(
        Espaciado.margenTelefono,
        arriba,
        Espaciado.margenTelefono,
        0,
      ),
      child: SizedBox(
        height: _alturaBarra,
        child: Row(
          children: [
            if (conRegreso) ...[
              const BotonRegresar(),
              const SizedBox(width: Espaciado.e3),
            ],
            Expanded(
              child: grande
                  ? const SizedBox.shrink()
                  : Semantics(
                      header: true,
                      child: Opacity(
                        opacity: opacidadChico,
                        // Aunque aún no se vea, es el encabezado para el lector.
                        alwaysIncludeSemantics: true,
                        child: Text(
                          titulo,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: t.titulo3.copyWith(color: c.texto),
                        ),
                      ),
                    ),
            ),
            for (var i = 0; i < acciones.length; i++) ...[
              if (i > 0) const SizedBox(width: Espaciado.e2),
              acciones[i],
            ],
          ],
        ),
      ),
    );

    // El sliver mide al hijo con un alto máximo, no fijo: se le da el alto
    // exacto que le toca en este punto del desplazamiento.
    final alto = math.max(minExtent, maxExtent - shrinkOffset);
    Widget cuerpo = DecoratedBox(
      decoration: BoxDecoration(
        color: fondo,
        border: Border(
          bottom: BorderSide(color: avance >= 1 ? c.borde : Colors.transparent),
        ),
      ),
      child: Stack(
        children: [
          // El título grande vive bajo la barra y sube con el desplazamiento:
          // la ventana recorta lo que pasa por detrás de la barra.
          Positioned(
            top: minExtent,
            left: 0,
            right: 0,
            bottom: 0,
            child: ClipRect(
              child: OverflowBox(
                alignment: Alignment.topLeft,
                minHeight: 0,
                maxHeight: double.infinity,
                child: Transform.translate(
                  offset: Offset(0, -shrinkOffset),
                  // Recogido del todo ya no se arma: queda la barra.
                  child: grande ? bloque : const SizedBox.shrink(),
                ),
              ),
            ),
          ),
          barra,
        ],
      ),
    );

    cuerpo = SizedBox(height: alto, child: cuerpo);
    return translucido && avance > 0
        ? ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: _desenfoque * avance,
                sigmaY: _desenfoque * avance,
              ),
              child: cuerpo,
            ),
          )
        : cuerpo;
  }

  @override
  bool shouldRebuild(_Delegado anterior) =>
      anterior.titulo != titulo ||
      anterior.subtitulo != subtitulo ||
      anterior.acciones != acciones ||
      anterior.translucido != translucido ||
      anterior.conRegreso != conRegreso ||
      anterior.escala != escala ||
      anterior.tokens != tokens ||
      anterior.arriba != arriba ||
      anterior.anchoTexto != anchoTexto ||
      anterior.direccion != direccion;
}
