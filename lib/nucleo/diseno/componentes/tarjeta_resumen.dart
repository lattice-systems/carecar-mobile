import 'package:flutter/material.dart';

import 'package:lucide_icons_flutter/lucide_icons_300.dart';

import '../tokens/espaciado.dart';
import '../tokens/radios.dart';
import '../tokens/tokens_pista.dart';
import 'insignia.dart';
import 'rebote_tactil.dart';
import 'tono.dart';

/// De qué trata la pantalla, en una tarjeta: un icono sobre un cuadro del tono,
/// el título, hasta dos líneas de detalle, una insignia de estado y, si aplica,
/// una barra de avance.
///
/// Sustituye a las portadas grandes: el icono es pequeño y plano (nada de
/// degradados) y lo que destaca es el dato. Usa la misma superficie y sombra
/// que [GrupoLista], así que convive con las listas de la pantalla sin
/// distinguirse como «otro estilo».
///
/// `visual` sustituye al icono cuando la pieza lo merece (el día de una cita).
/// `tono` colorea el icono y la barra (por omisión, informativo/acento).
/// `progreso` va de 0 a 1; `etiquetaProgreso` es el texto junto a la barra
/// («Faltan 1,550 km»). Con `alToque` toda la tarjeta es un botón con chevron.
/// El lector de pantalla recibe un solo nodo con todos los textos; `pista` le
/// dice qué pasa al tocarla («Ver el avance de tu orden») y `estadoConIcono`
/// suma a la insignia el icono de su tono, para que el estado no dependa solo
/// del color.
class TarjetaResumen extends StatelessWidget {
  const TarjetaResumen({
    required this.titulo,
    super.key,
    this.subtitulo,
    this.detalle,
    this.icono,
    this.visual,
    this.tono = Tono.informacion,
    this.estado,
    this.tonoEstado = Tono.neutro,
    this.estadoConIcono = false,
    this.progreso,
    this.etiquetaProgreso,
    this.alToque,
    this.pista,
  }) : assert(
         progreso == null || (progreso >= 0 && progreso <= 1),
         'El progreso va de 0 a 1',
       );

  final String titulo;
  final String? subtitulo;
  final String? detalle;
  final IconData? icono;

  /// Pieza propia en lugar del icono (por ejemplo, el bloque con el día de una
  /// cita). Debe medir lo mismo que el cuadro del icono: 40 de ancho.
  final Widget? visual;
  final Tono tono;

  /// Texto corto de estado que va como insignia, por ejemplo «En camino».
  final String? estado;
  final Tono tonoEstado;
  final bool estadoConIcono;
  final double? progreso;
  final String? etiquetaProgreso;
  final VoidCallback? alToque;

  /// Lo que anuncia el lector de pantalla sobre el toque.
  final String? pista;

  static const double _cuadroIcono = 40;

  @override
  Widget build(BuildContext context) {
    final tokens = TokensPista.de(context);
    final c = tokens.colores;
    final t = tokens.tipografia;
    final colores = ColoresTono.de(tono, c);

    final cuerpo = Padding(
      padding: const EdgeInsets.all(Espaciado.e4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              if (visual != null || icono != null) ...[
                // Igual que el icono de las filas de [GrupoLista]: cuadro
                // pleno del tono con el icono en `sobreAcento`.
                ExcludeSemantics(
                  child:
                      visual ??
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: colores.frente,
                          borderRadius: Radios.bordeControl,
                        ),
                        child: SizedBox(
                          width: _cuadroIcono,
                          height: _cuadroIcono,
                          child: Icon(icono, size: 24, color: c.sobreAcento),
                        ),
                      ),
                ),
                const SizedBox(width: Espaciado.e3),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(titulo, style: t.titulo3.copyWith(color: c.texto)),
                    if (subtitulo != null)
                      Text(
                        subtitulo!,
                        style: t.cuerpoChico.copyWith(color: c.textoSecundario),
                      ),
                    if (detalle != null)
                      Text(
                        detalle!,
                        style: t.cuerpoChico.copyWith(color: c.textoSecundario),
                      ),
                    if (estado != null) ...[
                      const SizedBox(height: Espaciado.e2),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Insignia(
                          texto: estado!,
                          tono: tonoEstado,
                          conIcono: estadoConIcono,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (alToque != null)
                Padding(
                  padding: const EdgeInsets.only(left: Espaciado.e2),
                  child: Icon(
                    LucideIcons300.chevronRight,
                    color: c.textoTerciario,
                  ),
                ),
            ],
          ),
          if (progreso != null) ...[
            const SizedBox(height: Espaciado.e4),
            _Barra(valor: progreso!, color: colores.frente),
            if (etiquetaProgreso != null) ...[
              const SizedBox(height: Espaciado.e2),
              Text(
                etiquetaProgreso!,
                style: t.cuerpoChico.copyWith(color: c.textoSecundario),
              ),
            ],
          ],
        ],
      ),
    );

    final tarjeta = DecoratedBox(
      decoration: BoxDecoration(
        color: c.superficie,
        borderRadius: Radios.bordeTarjeta,
        boxShadow: tokens.sombras,
      ),
      child: cuerpo,
    );

    final partes = [titulo, ?subtitulo, ?detalle, ?estado, ?etiquetaProgreso];
    return Semantics(
      container: true,
      button: alToque != null,
      label: partes.join(', '),
      hint: pista,
      value: progreso == null ? null : '${(progreso! * 100).round()} %',
      excludeSemantics: true,
      onTap: alToque,
      child: alToque == null
          ? tarjeta
          : ReboteTactil(alPulsar: alToque, child: tarjeta),
    );
  }
}

class _Barra extends StatelessWidget {
  const _Barra({required this.valor, required this.color});

  final double valor;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final c = TokensPista.de(context).colores;
    return ClipRRect(
      borderRadius: Radios.bordePildora,
      child: SizedBox(
        height: 8,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ColoredBox(color: c.superficieHundida),
            FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: valor,
              child: ColoredBox(color: color),
            ),
          ],
        ),
      ),
    );
  }
}
