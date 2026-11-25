import 'package:flutter/material.dart';

import '../tokens/espaciado.dart';
import 'boton_pildora.dart';

/// Una acción de [FilaAcciones].
class AccionPantalla {
  const AccionPantalla({
    required this.texto,
    required this.alPresionar,
    this.icono,
  });

  final String texto;
  final VoidCallback? alPresionar;
  final IconData? icono;
}

/// Las acciones de una pantalla justo bajo su encabezado: una principal (botón
/// lleno) y, si hace falta, una secundaria (vidrio).
///
/// Es el único lugar donde una pantalla pone «lo que se puede hacer aquí»: así
/// el botón principal está siempre en el mismo sitio y con el mismo aspecto.
/// Dos acciones se reparten la fila; con una sola, con `apiladas` o con letra
/// grande, van una debajo de la otra para no desbordar.
class FilaAcciones extends StatelessWidget {
  const FilaAcciones({
    required this.principal,
    super.key,
    this.secundaria,
    this.apiladas = false,
  });

  final AccionPantalla principal;
  final AccionPantalla? secundaria;

  /// Una debajo de la otra aunque haya espacio; para textos largos o para el
  /// cierre de un flujo.
  final bool apiladas;

  @override
  Widget build(BuildContext context) {
    final letraGrande = MediaQuery.textScalerOf(context).scale(1) > 1.3;
    final botones = <Widget>[
      BotonPildora(
        texto: principal.texto,
        icono: principal.icono,
        alPresionar: principal.alPresionar,
        expandido: true,
      ),
      if (secundaria != null)
        BotonPildora(
          texto: secundaria!.texto,
          icono: secundaria!.icono,
          alPresionar: secundaria!.alPresionar,
          variante: VarianteBotonPildora.vidrio,
          expandido: true,
        ),
    ];
    if (apiladas || letraGrande || botones.length == 1) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < botones.length; i++) ...[
            if (i > 0) const SizedBox(height: Espaciado.e2),
            botones[i],
          ],
        ],
      );
    }
    return Row(
      children: [
        Expanded(child: botones[0]),
        const SizedBox(width: Espaciado.e3),
        Expanded(child: botones[1]),
      ],
    );
  }
}
