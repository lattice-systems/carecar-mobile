import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:lucide_icons_flutter/lucide_icons_300.dart';

import '../../../l10n/app_localizations.dart';
import '../../../nucleo/diseno/componentes/chip_pista.dart';
import '../../../nucleo/diseno/componentes/rebote_tactil.dart';
import '../../../nucleo/diseno/componentes/superficie_liquida.dart';
import '../../../nucleo/diseno/tokens/espaciado.dart';
import '../../../nucleo/diseno/tokens/tokens_pista.dart';
import 'rutas_asistente.dart';

/// Entrada al asistente desde el detalle del vehiculo (V2-M24.10), con el
/// vidrio de la propuesta: tarjeta translucida con borde de luz, el ✦ del
/// asistente y dos preguntas sugeridas. Tocar la tarjeta abre el asistente;
/// tocar una pregunta lo abre y la envia.
class TarjetaAsistente extends StatelessWidget {
  const TarjetaAsistente({required this.vehiculoId, super.key});

  final int vehiculoId;

  static const double _alfaVidrio = 0.06;
  static const double _alfaBorde = 0.14;
  static const double _tamanoInsignia = 36;

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final tokens = TokensPista.de(context);
    final c = tokens.colores;
    final t = tokens.tipografia;
    void abrir([String? pregunta]) =>
        context.push(rutaAsistente(vehiculoId, pregunta: pregunta));

    return Semantics(
      container: true,
      child: ReboteTactil(
        alPulsar: abrir,
        child: SuperficieLiquida(
          intensidadDesenfoque: 0,
          colorFondo: c.texto.withValues(alpha: _alfaVidrio),
          colorBorde: c.texto.withValues(alpha: _alfaBorde),
          padding: const EdgeInsets.all(Espaciado.e4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MergeSemantics(
                child: Semantics(
                  button: true,
                  onTap: abrir,
                  child: Row(
                    children: [
                      Container(
                        width: _tamanoInsignia,
                        height: _tamanoInsignia,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: c.acentoSuave,
                        ),
                        child: Icon(
                          LucideIcons300.sparkles,
                          size: 18,
                          color: c.acento,
                        ),
                      ),
                      const SizedBox(width: Espaciado.e3),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              textos.asistenteTitulo,
                              style: t.titulo3.copyWith(color: c.texto),
                            ),
                            const SizedBox(height: Espaciado.e1),
                            Text(
                              textos.asistenteVacioMensaje,
                              style: t.cuerpoChico.copyWith(
                                color: c.textoSecundario,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ExcludeSemantics(
                        child: Icon(
                          LucideIcons300.chevronRight,
                          color: c.textoTerciario,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: Espaciado.e3),
              Wrap(
                spacing: Espaciado.e2,
                children: [
                  for (final pregunta in [
                    textos.asistentePreguntaLlantas,
                    textos.asistentePreguntaTestigos,
                  ])
                    ChipPista(
                      texto: pregunta,
                      seleccionado: false,
                      alCambiar: (_) => abrir(pregunta),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
