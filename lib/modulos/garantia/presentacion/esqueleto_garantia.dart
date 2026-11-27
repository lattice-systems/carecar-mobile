import 'package:flutter/widgets.dart';

import '../../../nucleo/diseno/componentes/esqueleto.dart';
import '../../../nucleo/diseno/tokens/espaciado.dart';

/// Esqueleto de carga de las pantallas de garantia: bloques de los altos
/// dados. No se desplaza ni se desborda con letra grande.
class EsqueletoGarantia extends StatelessWidget {
  const EsqueletoGarantia({required this.altos, super.key});

  final List<double> altos;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
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
  );
}
