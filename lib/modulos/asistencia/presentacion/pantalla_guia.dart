import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

import '../../../l10n/app_localizations.dart';
import '../../../nucleo/diseno/tokens/espaciado.dart';
import '../../../nucleo/diseno/tokens/tokens_pista.dart';
import '../dominio/guia_emergencia.dart';
import 'textos_guias.dart';

/// Pasos de una guia de emergencia (V2-M11.03).
///
/// Cada paso es un solo nodo para el lector de pantalla ("Paso 2 de 5" y su
/// texto) y los nodos van en orden, asi se escucha la guia de principio a fin.
class PantallaGuia extends StatelessWidget {
  const PantallaGuia({required this.guia, super.key});

  final GuiaEmergencia guia;

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final t = TokensPista.de(context);

    return Scaffold(
      appBar: AppBar(title: Text(textos.tituloDeGuia(guia.tipo))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(Espaciado.e4),
        // Pocos pasos: se arman todos para que el lector de pantalla tenga la
        // guia completa en orden, sin esperar a que se desplace.
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var numero = 1; numero <= guia.pasos; numero++) ...[
              if (numero > 1) const SizedBox(height: Espaciado.e5),
              Semantics(
                container: true,
                sortKey: OrdinalSortKey(numero.toDouble()),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      textos.asistenciaGuiaPasoNumero(numero, guia.pasos),
                      style: t.tipografia.etiqueta.copyWith(
                        color: t.colores.acento,
                      ),
                    ),
                    const SizedBox(height: Espaciado.e1),
                    Text(
                      textos.pasoDeGuia(guia.tipo, numero),
                      style: t.tipografia.cuerpo.copyWith(
                        color: t.colores.texto,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
