import 'package:flutter/material.dart';

import '../../../../nucleo/diseno/componentes/tono.dart';
import '../../../../nucleo/diseno/tokens/espaciado.dart';
import '../../../../nucleo/diseno/tokens/radios.dart';
import '../../../../nucleo/diseno/tokens/tokens_pista.dart';
import 'cuadro_fecha.dart';

/// Una fila de [GrupoCitas].
class FilaCita {
  const FilaCita({
    required this.fecha,
    required this.tono,
    required this.titulo,
    required this.etiquetaSemantica,
    this.subtitulo,
    this.fin,
    this.alToque,
  });

  /// Día que se dibuja en el cuadro de color.
  final DateTime fecha;
  final Tono tono;
  final String titulo;
  final String? subtitulo;

  /// Lo que anuncia el lector de pantalla: fecha, vehículo y estado juntos.
  final String etiquetaSemantica;

  /// Insignia de estado al final de la fila.
  final Widget? fin;
  final VoidCallback? alToque;
}

/// Lista agrupada en tarjeta redondeada, con el [CuadroFecha] a la izquierda.
///
/// Mismo lenguaje que `GrupoLista` (tarjeta de superficie, divisores
/// alineados con el texto, encabezado pequeño arriba), pero con un cuadro de
/// fecha en lugar del icono. Se queda en el módulo de citas hasta que el
/// sistema de diseño admita un widget al inicio de `FilaGrupo`.
class GrupoCitas extends StatelessWidget {
  const GrupoCitas({required this.filas, super.key, this.encabezado});

  final List<FilaCita> filas;
  final String? encabezado;

  static const double _anchoCuadro = 52;

  @override
  Widget build(BuildContext context) {
    final tokens = TokensPista.de(context);
    final c = tokens.colores;
    final t = tokens.tipografia;

    final hijos = <Widget>[];
    for (var i = 0; i < filas.length; i++) {
      hijos.add(_Fila(fila: filas[i]));
      if (i < filas.length - 1) {
        hijos.add(
          Padding(
            padding: const EdgeInsetsDirectional.only(
              start: Espaciado.e4 + _anchoCuadro + Espaciado.e3,
            ),
            child: Divider(height: 1, thickness: 1, color: c.borde),
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (encabezado != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              Espaciado.e4,
              Espaciado.e6,
              Espaciado.e4,
              Espaciado.e3,
            ),
            child: Semantics(
              header: true,
              child: Text(
                encabezado!,
                style: t.titulo2.copyWith(color: c.texto),
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Espaciado.e4),
          child: DecoratedBox(
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
        ),
      ],
    );
  }
}

class _Fila extends StatelessWidget {
  const _Fila({required this.fila});

  final FilaCita fila;

  @override
  Widget build(BuildContext context) {
    final tokens = TokensPista.de(context);
    final c = tokens.colores;
    final t = tokens.tipografia;
    final tocable = fila.alToque != null;

    final contenido = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 72),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Espaciado.e4,
          vertical: Espaciado.e3,
        ),
        child: Row(
          children: [
            CuadroFecha(fecha: fila.fecha, tono: fila.tono),
            const SizedBox(width: Espaciado.e3),
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
      label: fila.etiquetaSemantica,
      onTap: fila.alToque,
      excludeSemantics: true,
      child: tocable
          ? InkWell(onTap: fila.alToque, child: contenido)
          : contenido,
    );
  }
}
