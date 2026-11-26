import 'package:flutter/material.dart';

import 'package:lucide_icons_flutter/lucide_icons_300.dart';

import '../tokens/espaciado.dart';
import '../tokens/tokens_pista.dart';
import 'rebote_tactil.dart';

/// Fila de una lista: titulo, subtitulo opcional, adorno al inicio y al final.
///
/// Con `alToque` toda la fila es zona tactil de al menos 48 y muestra un
/// chevron si `conChevron`. El lector de pantalla recibe un solo nodo con
/// titulo y subtitulo.
class FilaLista extends StatelessWidget {
  const FilaLista({
    required this.titulo,
    super.key,
    this.subtitulo,
    this.inicio,
    this.fin,
    this.alToque,
    this.conChevron = true,
    this.conDivisor = true,
  });

  final String titulo;
  final String? subtitulo;
  final Widget? inicio;
  final Widget? fin;
  final VoidCallback? alToque;
  final bool conChevron;
  final bool conDivisor;

  @override
  Widget build(BuildContext context) {
    final tokens = TokensPista.de(context);
    final c = tokens.colores;
    final t = tokens.tipografia;
    final tocable = alToque != null;

    final contenido = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 56),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Espaciado.e4,
          vertical: Espaciado.e2,
        ),
        child: Row(
          children: [
            if (inicio != null) ...[
              inicio!,
              const SizedBox(width: Espaciado.e3),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(titulo, style: t.cuerpoFuerte.copyWith(color: c.texto)),
                  if (subtitulo != null)
                    Text(
                      subtitulo!,
                      style: t.cuerpoChico.copyWith(color: c.textoSecundario),
                    ),
                ],
              ),
            ),
            if (fin != null) ...[const SizedBox(width: Espaciado.e3), fin!],
            if (tocable && conChevron) ...[
              const SizedBox(width: Espaciado.e2),
              ExcludeSemantics(
                child: Icon(
                  LucideIcons300.chevronRight,
                  color: c.textoSecundario,
                ),
              ),
            ],
          ],
        ),
      ),
    );

    final fila = tocable
        ? ReboteTactil(
            habilitado: true,
            child: InkWell(
              onTap: alToque,
              splashFactory: NoSplash.splashFactory,
              child: contenido,
            ),
          )
        : contenido;

    return Semantics(
      container: true,
      button: tocable,
      label: subtitulo == null ? titulo : '$titulo. $subtitulo',
      onTap: alToque,
      excludeSemantics: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: conDivisor
              ? Border(bottom: BorderSide(color: c.borde))
              : null,
        ),
        child: Material(type: MaterialType.transparency, child: fila),
      ),
    );
  }
}
