import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../l10n/app_localizations.dart';
import '../../../nucleo/diseno/componentes/esqueleto.dart';
import '../../../nucleo/diseno/componentes/insignia.dart';
import '../../../nucleo/diseno/componentes/superficie_liquida.dart';
import '../../../nucleo/diseno/componentes/tono.dart';
import '../../../nucleo/diseno/tokens/espaciado.dart';
import '../../../nucleo/diseno/tokens/tokens_pista.dart';
import '../dominio/privacidad.dart';

/// El día largo («25 de noviembre de 2026») en el idioma de la app. Los
/// instantes del servidor llegan en UTC y se muestran en la hora del teléfono.
String diaDelAviso(BuildContext context, DateTime momento) =>
    DateFormat.yMMMMd(Localizations.localeOf(context).toLanguageTag())
        .format(momento.toLocal());

/// La versión, desde cuándo rige y el texto por párrafos (V2-M22.01).
class TextoDelAviso extends StatelessWidget {
  const TextoDelAviso({required this.aviso, super.key});

  final AvisoDePrivacidad aviso;

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final tokens = TokensPista.de(context);
    final c = tokens.colores;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: Espaciado.e2,
          runSpacing: Espaciado.e1,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Insignia(
              texto: textos.privacidadVersion(aviso.version),
              tono: Tono.informacion,
            ),
            Text(
              textos.privacidadVigenteDesde(
                diaDelAviso(context, aviso.vigenteDesde),
              ),
              style: tokens.tipografia.cuerpoChico.copyWith(
                color: c.textoSecundario,
              ),
            ),
          ],
        ),
        const SizedBox(height: Espaciado.e4),
        SuperficieLiquida(
          padding: const EdgeInsets.all(Espaciado.e4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final (i, parrafo) in aviso.parrafos.indexed) ...[
                if (i > 0) const SizedBox(height: Espaciado.e3),
                Text(
                  parrafo,
                  style: tokens.tipografia.cuerpo.copyWith(color: c.texto),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// Lo que se ve mientras llega el aviso; el lector de pantalla lo anuncia.
class CargandoAviso extends StatelessWidget {
  const CargandoAviso({super.key});

  @override
  Widget build(BuildContext context) => Semantics(
    label: AppLocalizations.of(context).privacidadCargando,
    liveRegion: true,
    child: const Column(
      children: [
        Esqueleto(alto: 28, ancho: 160),
        SizedBox(height: Espaciado.e4),
        Esqueleto(alto: 220),
      ],
    ),
  );
}
