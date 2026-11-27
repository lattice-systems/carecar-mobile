import 'package:flutter/material.dart';

import 'package:lucide_icons_flutter/lucide_icons_300.dart';

import '../tokens/espaciado.dart';
import '../tokens/radios.dart';
import '../tokens/tokens_pista.dart';
import 'rebote_tactil.dart';

/// Una fila de un [GrupoLista].
///
/// `icono` se dibuja sobre un cuadro redondeado de `colorIcono` (por defecto el
/// acento). Con `alToque` la fila entera es tocable y muestra un chevron, salvo
/// que `conChevron` sea falso (una fila con interruptor responde al toque pero
/// no lleva a otra pantalla). El lector de pantalla recibe un solo nodo con
/// titulo, subtitulo y `etiquetaFin`; el `fin` no se lee, asi que una cifra
/// que importa va tambien en `etiquetaFin` dicha en palabras. `llave` identifica
/// la fila (pruebas y anclas de desplazamiento).
class FilaGrupo {
  const FilaGrupo({
    required this.titulo,
    this.subtitulo,
    this.icono,
    this.colorIcono,
    this.fin,
    this.etiquetaFin,
    this.alToque,
    this.conChevron,
    this.llave,
  });

  final String titulo;
  final String? subtitulo;
  final IconData? icono;
  final Color? colorIcono;

  /// Texto o adorno antes del chevron, por ejemplo un valor.
  final Widget? fin;

  /// Lo que oye el lector del `fin`, por ejemplo «Ganaste 230 puntos» por
  /// «+230»; nulo si el `fin` es solo adorno.
  final String? etiquetaFin;
  final VoidCallback? alToque;

  /// Si la fila muestra la flecha; por omisión, la muestra cuando es tocable.
  final bool? conChevron;
  final Key? llave;
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
  static const double _escalaQueApila = 1.5;

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
    // Desde letra grande el `fin` no cabe al lado sin partir palabras del
    // título, así que baja y el texto recibe todo el ancho.
    final apilado =
        MediaQuery.textScalerOf(context).scale(16) >=
        16 * GrupoLista._escalaQueApila;

    final contenido = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 56),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Espaciado.e4,
          vertical: Espaciado.e2,
        ),
        child: LayoutBuilder(
          builder: (context, caja) => Row(
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
                    if (apilado && fila.fin != null) ...[
                      const SizedBox(height: Espaciado.e1),
                      fila.fin!,
                    ],
                  ],
                ),
              ),
              if (!apilado && fila.fin != null) ...[
                const SizedBox(width: Espaciado.e3),
                // El `fin` toma su ancho natural, hasta la mitad de la fila, y
                // el texto el resto. Antes los dos repartian el espacio libre
                // a partes iguales y el texto se partia aunque cupiera.
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: caja.maxWidth / 2),
                  child: fila.fin!,
                ),
              ],
              if (fila.conChevron ?? tocable) ...[
                const SizedBox(width: Espaciado.e2),
                ExcludeSemantics(
                  child: Icon(
                    LucideIcons300.chevronRight,
                    color: c.textoTerciario,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );

    return Semantics(
      key: fila.llave,
      container: true,
      button: tocable,
      label: [fila.titulo, ?fila.subtitulo, ?fila.etiquetaFin].join('. '),
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
