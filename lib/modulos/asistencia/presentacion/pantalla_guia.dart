import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons_300.dart';
import 'package:flutter/semantics.dart';

import '../../../l10n/app_localizations.dart';
import '../../../nucleo/diseno/componentes/marco_pantalla.dart';
import '../../../nucleo/diseno/tokens/espaciado.dart';
import '../../../nucleo/diseno/tokens/radios.dart';
import '../../../nucleo/diseno/tokens/tokens_pista.dart';
import '../dominio/guia_emergencia.dart';
import 'estilo_guias.dart';
import 'textos_guias.dart';

/// Pasos de una guia de emergencia (V2-M11.03).
///
/// El encabezado dice de que guia se trata y cuantos pasos tiene; debajo, los
/// pasos como lista numerada grande, con el color de la guia. Cada paso es un solo nodo para el lector de pantalla
/// ("Paso 2 de 5" y su texto) y los nodos van en orden. Aun no hay accion de
/// llamar a la agencia (V2-M11.02), asi que no se muestra el boton.
class PantallaGuia extends StatelessWidget {
  const PantallaGuia({required this.guia, super.key});

  final GuiaEmergencia guia;

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final tokens = TokensPista.de(context);
    final c = tokens.colores;
    final color = guia.tipo.color(c);
    final titulo = textos.tituloDeGuia(guia.tipo);

    return MarcoPantalla(
      icono: LucideIcons300.bookOpen,
      titulo: titulo,
      subtitulo: textos.asistenciaGuiaSubtituloSinConexion(guia.pasos),
      conRegreso: true,
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(Espaciado.e4),
          // Pocos pasos: se arman todos para que el lector de pantalla tenga
          // la guia completa en orden, sin esperar a que se desplace.
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var numero = 1; numero <= guia.pasos; numero++) ...[
                  if (numero > 1) const SizedBox(height: Espaciado.e6),
                  _Paso(guia: guia, numero: numero, color: color),
                ],
                const SizedBox(height: Espaciado.e8),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Paso extends StatelessWidget {
  const _Paso({required this.guia, required this.numero, required this.color});

  final GuiaEmergencia guia;
  final int numero;
  final Color color;

  static const double _circulo = 40;

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final tokens = TokensPista.de(context);
    final c = tokens.colores;
    final t = tokens.tipografia;

    return Semantics(
      container: true,
      sortKey: OrdinalSortKey(numero.toDouble()),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ExcludeSemantics(
            child: Container(
              width: _circulo,
              height: _circulo,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Color.alphaBlend(
                  color.withValues(alpha: 0.2),
                  c.superficie,
                ),
                borderRadius: BorderRadius.circular(Radios.pildora),
              ),
              child: Text(
                numero.toString(),
                style: t.titulo3.copyWith(color: color),
              ),
            ),
          ),
          const SizedBox(width: Espaciado.e4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  textos.asistenciaGuiaPasoNumero(numero, guia.pasos),
                  style: t.cuerpoFuerte.copyWith(color: c.texto),
                ),
                const SizedBox(height: Espaciado.e1),
                Text(
                  textos.pasoDeGuia(guia.tipo, numero),
                  style: t.cuerpo.copyWith(color: c.textoSecundario),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
