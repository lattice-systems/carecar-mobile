import 'package:flutter/material.dart';

import '../../../nucleo/diseno/componentes/esqueleto.dart';
import '../../../nucleo/diseno/tokens/espaciado.dart';

/// Esqueleto de carga de las pantallas de pagos: bloques de los altos dados.
/// No se desplaza ni se desborda con letra grande. El lector de pantalla oye
/// `etiqueta`.
class EsqueletoPagos extends StatelessWidget {
  const EsqueletoPagos({
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

/// Se construye cuando el final de la lista entra en pantalla y pide la pagina
/// siguiente una sola vez. Mientras llega se ve un indicador.
class CargarAlLlegar extends StatefulWidget {
  const CargarAlLlegar({
    required this.etiqueta,
    required this.alLlegar,
    super.key,
  });

  final String etiqueta;
  final VoidCallback alLlegar;

  @override
  State<CargarAlLlegar> createState() => _CargarAlLlegarState();
}

class _CargarAlLlegarState extends State<CargarAlLlegar> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.alLlegar();
    });
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(Espaciado.e4),
    child: Center(
      child: Semantics(
        label: widget.etiqueta,
        child: const SizedBox.square(
          dimension: Espaciado.e6,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    ),
  );
}
