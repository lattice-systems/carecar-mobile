import 'package:flutter/widgets.dart';

import '../../../nucleo/diseno/componentes/esqueleto.dart';
import '../../../nucleo/diseno/tokens/espaciado.dart';

/// Esqueleto de carga de las pantallas de lealtad: bloques de los altos
/// dados. No se desplaza ni se desborda con letra grande. El lector de
/// pantalla oye `etiqueta`.
class EsqueletoLealtad extends StatelessWidget {
  const EsqueletoLealtad({
    required this.altos,
    required this.etiqueta,
    super.key,
  });

  final List<double> altos;
  final String etiqueta;

  @override
  Widget build(BuildContext context) => Semantics(
    label: etiqueta,
    liveRegion: true,
    child: SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(Espaciado.e4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < altos.length; i++) ...[
            if (i > 0) const SizedBox(height: Espaciado.e3),
            Esqueleto(alto: altos[i]),
          ],
        ],
      ),
    ),
  );
}
