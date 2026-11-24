import 'package:flutter/material.dart';

import '../tokens/espaciado.dart';
import '../tokens/radios.dart';
import '../tokens/tokens_pista.dart';
import 'rebote_tactil.dart';

/// Una fila de un [GrupoLista].
///
/// `icono` se dibuja sobre un cuadro redondeado de `colorIcono` (por defecto el
/// acento). Con `alToque` la fila entera es tocable y muestra un chevron. El
/// lector de pantalla recibe un solo nodo con titulo y subtitulo.
class FilaGrupo {
  const FilaGrupo({
    required this.titulo,
    this.subtitulo,
    this.icono,
    this.colorIcono,
    this.fin,
    this.alToque,
  });

  final String titulo;
  final String? subtitulo;
  final IconData? icono;
  final Color? colorIcono;

  /// Texto o adorno antes del chevron, por ejemplo un valor.
  final Widget? fin;
  final VoidCallback? alToque;
}

/// Lista agrupada tipo "inset": una tarjeta redondeada con filas separadas por
/// lineas finas que empiezan despues del icono.
///
/// `encabezado` y `pie` son textos opcionales fuera de la tarjeta. Sin bordes
/// duros: la tarjeta se separa del fondo por superficie y sombra suave.
class GrupoLista extends StatelessWidget {
  const GrupoLista({required this.filas, super.key, this.encabezado, this.pie});

  final List<FilaGrupo> filas;
  final String? encabezado;
  final String? pie;

  static const double _cuadroIcono = 32;

  @override
  Widget build(BuildContext context) {
    final tokens = TokensPista.de(context);
    final c = tokens.colores;
    final t = tokens.tipografia;
    final alineaDivisor = filas.any((f) => f.icono != null);
    final sangria =
        Espaciado.e4 + (alineaDivisor ? _cuadroIcono + Espaciado.e3 : 0);

    final hijos = <Widget>[];
    for (var i = 0; i < filas.length; i++) {
      hijos.add(_Fila(fila: filas[i], tokens: tokens));
      if (i < filas.length - 1) {
        hijos.add(
          Padding(
            padding: EdgeInsetsDirectional.only(start: sangria),
            child: Divider(height: 1, thickness: 1, color: c.borde),
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (encabezado != null)
          Semantics(
            header: true,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                Espaciado.e4,
                0,
                Espaciado.e4,
                Espaciado.e2,
              ),
              child: Text(
                encabezado!,
                style: t.etiqueta.copyWith(color: c.textoSecundario),
              ),
            ),
          ),
        DecoratedBox(
          decoration: BoxDecoration(
            color: c.superficie,
            borderRadius: Radios.bordeTarjeta,
            boxShadow: tokens.sombras,
          ),
          child: ClipRRect(
            borderRadius: Radios.bordeTarjeta,
            child: Material(
              type: MaterialType.transparency,
              child: Column(children: hijos),
            ),
          ),
        ),
        if (pie != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              Espaciado.e4,
              Espaciado.e2,
              Espaciado.e4,
              0,
            ),
            child: Text(
              pie!,
              style: t.cuerpoChico.copyWith(color: c.textoSecundario),
            ),
          ),
      ],
    );
  }
}

class _Fila extends StatelessWidget {
  const _Fila({required this.fila, required this.tokens});

  final FilaGrupo fila;
  final TokensPista tokens;

  @override
  Widget build(BuildContext context) {
    final c = tokens.colores;
    final t = tokens.tipografia;
    final tocable = fila.alToque != null;

    final contenido = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 56),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Espaciado.e4,
          vertical: Espaciado.e2,
        ),
        child: Row(
          children: [
            if (fila.icono != null) ...[
              ExcludeSemantics(
                child: Container(
                  width: GrupoLista._cuadroIcono,
                  height: GrupoLista._cuadroIcono,
                  decoration: BoxDecoration(
                    color: fila.colorIcono ?? c.acento,
                    borderRadius: Radios.bordeControl,
                  ),
                  child: Icon(fila.icono, size: 20, color: c.sobreAcento),
                ),
              ),
              const SizedBox(width: Espaciado.e3),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    fila.titulo,
                    style: t.cuerpoFuerte.copyWith(color: c.texto),
                  ),
                  if (fila.subtitulo != null)
                    Text(
                      fila.subtitulo!,
                      style: t.cuerpoChico.copyWith(color: c.textoSecundario),
                    ),
                ],
              ),
            ),
            if (fila.fin != null) ...[
              const SizedBox(width: Espaciado.e3),
              Flexible(child: fila.fin!),
            ],
            if (tocable) ...[
              const SizedBox(width: Espaciado.e2),
              ExcludeSemantics(
                child: Icon(Icons.chevron_right, color: c.textoTerciario),
              ),
            ],
          ],
        ),
      ),
    );

    return Semantics(
      container: true,
      button: tocable,
      label: fila.subtitulo == null
          ? fila.titulo
          : '${fila.titulo}. ${fila.subtitulo}',
      onTap: fila.alToque,
      excludeSemantics: true,
      child: tocable
          ? ReboteTactil(
              habilitado: true,
              child: InkWell(
                onTap: fila.alToque,
                splashFactory: NoSplash.splashFactory,
                child: contenido,
              ),
            )
          : contenido,
    );
  }
}
