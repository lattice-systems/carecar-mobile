import 'dart:math' as math;
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../tokens/espaciado.dart';
import '../tokens/tokens_pista.dart';

/// Encabezado de pantalla que empieza grande y se encoge al desplazar.
///
/// Es un sliver: va dentro de un `CustomScrollView`. Con el desplazamiento el
/// titulo pasa de `titulo1` a `titulo3` y el subtitulo se desvanece. Las
/// alturas crecen con el tamano de letra del sistema, para que a 200 % el
/// titulo no se corte.
///
/// Con `translucido` la barra contraida deja ver el contenido que pasa por
/// debajo, desenfocado y teñido con el fondo (estilo barra de navegacion
/// compacta); el fondo baja apenas a 92 % de opacidad al contraerse: deja un asomo de
/// color pero el texto de abajo no se lee a traves del titulo.
class EncabezadoGrande extends StatelessWidget {
  const EncabezadoGrande({
    required this.titulo,
    super.key,
    this.subtitulo,
    this.acciones = const [],
    this.translucido = false,
  });

  final String titulo;
  final String? subtitulo;

  /// Botones al final del encabezado, cada uno con su zona tactil de 48.
  final List<Widget> acciones;

  /// Barra contraida translucida con desenfoque.
  final bool translucido;

  @override
  Widget build(BuildContext context) {
    final escala = MediaQuery.textScalerOf(context);
    return SliverPersistentHeader(
      pinned: true,
      delegate: _Delegado(
        titulo: titulo,
        subtitulo: subtitulo,
        acciones: acciones,
        translucido: translucido,
        escala: escala,
        tokens: TokensPista.de(context),
        arriba: MediaQuery.paddingOf(context).top,
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
    required this.escala,
    required this.tokens,
    required this.arriba,
  });

  final String titulo;
  final String? subtitulo;
  final List<Widget> acciones;
  final bool translucido;
  final TextScaler escala;
  final TokensPista tokens;
  final double arriba;

  /// Con letra ampliada el titulo se parte en dos lineas, asi que se reserva
  /// el espacio de las dos para que no se corte ni desborde.
  int get _lineasTitulo => escala.scale(1) > 1.3 ? 2 : 1;

  double get _alturaContraida =>
      math.max(
        56,
        escala.scale(tokens.tipografia.titulo3.fontSize! * 1.5) * _lineasTitulo,
      ) +
      Espaciado.e2;

  double get _alturaExpandida {
    final t = tokens.tipografia;
    final lineaTitulo =
        escala.scale(t.titulo1.fontSize! * 1.25) * _lineasTitulo;
    final lineaSub = subtitulo == null
        ? 0
        : escala.scale(t.cuerpoChico.fontSize! * 1.4);
    return math.max(
      _alturaContraida + Espaciado.e6,
      lineaTitulo + lineaSub + Espaciado.e6 + Espaciado.e4,
    );
  }

  @override
  double get minExtent => _alturaContraida + arriba;

  @override
  double get maxExtent => _alturaExpandida + arriba;

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
    final estiloTitulo = TextStyle.lerp(
      t.titulo1,
      t.titulo3,
      avance,
    )!.copyWith(color: c.texto);

    final fondo = translucido
        ? c.fondo.withValues(alpha: 1 - 0.08 * avance)
        : c.fondo;

    final barra = DecoratedBox(
      decoration: BoxDecoration(
        color: fondo,
        border: Border(
          bottom: BorderSide(color: avance >= 1 ? c.borde : Colors.transparent),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          Espaciado.e4,
          arriba,
          Espaciado.e2,
          Espaciado.e2,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: estiloTitulo,
                  ),
                  if (subtitulo != null && avance < 1)
                    Opacity(
                      opacity: 1 - avance,
                      child: Text(
                        subtitulo!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: t.cuerpoChico.copyWith(color: c.textoSecundario),
                      ),
                    ),
                ],
              ),
            ),
            ...acciones,
          ],
        ),
      ),
    );

    return Semantics(
      container: true,
      header: true,
      child: translucido && avance > 0
          ? ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: _desenfoque * avance,
                  sigmaY: _desenfoque * avance,
                ),
                child: barra,
              ),
            )
          : barra,
    );
  }

  static const double _desenfoque = 30;

  @override
  bool shouldRebuild(_Delegado anterior) =>
      anterior.titulo != titulo ||
      anterior.subtitulo != subtitulo ||
      anterior.acciones != acciones ||
      anterior.translucido != translucido ||
      anterior.escala != escala ||
      anterior.tokens != tokens ||
      anterior.arriba != arriba;
}
