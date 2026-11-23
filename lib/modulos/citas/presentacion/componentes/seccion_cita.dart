import 'package:flutter/material.dart';

import '../../../../nucleo/diseno/tokens/espaciado.dart';
import '../../../../nucleo/diseno/tokens/tokens_pista.dart';

/// Sección grande de una pantalla de citas: título en negrita y su contenido.
///
/// Es el ritmo de «Estilo portada»: títulos que ordenan la pantalla y mucho
/// aire entre bloques. El título es un encabezado para el lector de pantalla.
/// `conMargen` falso deja que el contenido (un estante) llegue a los bordes.
class SeccionCita extends StatelessWidget {
  const SeccionCita({
    required this.titulo,
    required this.hijo,
    super.key,
    this.nota,
    this.conMargen = true,
  });

  final String titulo;
  final Widget hijo;

  /// Texto de apoyo debajo del contenido.
  final String? nota;
  final bool conMargen;

  @override
  Widget build(BuildContext context) {
    final tokens = TokensPista.de(context);
    final c = tokens.colores;
    final t = tokens.tipografia;
    final lateral = conMargen ? Espaciado.e4 : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            Espaciado.e4,
            Espaciado.e6,
            Espaciado.e4,
            Espaciado.e3,
          ),
          child: Semantics(
            header: true,
            child: Text(titulo, style: t.titulo2.copyWith(color: c.texto)),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: lateral),
          child: hijo,
        ),
        if (nota != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              Espaciado.e4,
              Espaciado.e2,
              Espaciado.e4,
              0,
            ),
            child: Text(
              nota!,
              style: t.cuerpoChico.copyWith(color: c.textoSecundario),
            ),
          ),
      ],
    );
  }
}
