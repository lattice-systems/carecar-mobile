import 'package:flutter/material.dart';

import '../tema/tema_carecar.dart';

/// Etiqueta y valor adaptable a texto grande y a cadenas largas como el VIN.
class DatoLectura extends StatelessWidget {
  const DatoLectura(this.etiqueta, this.valor, {super.key});
  final String etiqueta;
  final String? valor;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          etiqueta,
          style: Theme.of(context).textTheme.labelLarge
              ?.copyWith(color: TemaCareCar.textoSecundario),
        ),
        const SizedBox(height: 4),
        SelectableText(
          valor == null || valor!.trim().isEmpty ? 'No disponible' : valor!,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ],
    ),
  );
}
