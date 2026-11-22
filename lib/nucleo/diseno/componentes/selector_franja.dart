import 'package:flutter/material.dart';

import '../tokens/espaciado.dart';
import '../tokens/tokens_pista.dart';
import 'chip_pista.dart';

/// Una franja horaria con su cupo. `cupo` nulo significa que no se muestra
/// cuantos lugares quedan. Con `cupo` en cero la franja no se puede elegir.
class FranjaHoraria {
  const FranjaHoraria({required this.etiqueta, this.cupo});

  /// Hora ya formateada, por ejemplo "09:00".
  final String etiqueta;
  final int? cupo;

  bool get disponible => cupo == null || cupo! > 0;

  String get _texto {
    if (cupo == null) return etiqueta;
    if (cupo == 0) return '$etiqueta · sin cupo';
    return '$etiqueta · ${cupo == 1 ? '1 lugar' : '$cupo lugares'}';
  }
}

/// Elige una franja horaria de un dia.
///
/// Es controlado: quien lo usa guarda `seleccionada` (el indice) y lo cambia
/// en `alSeleccionar`. Las franjas sin cupo quedan deshabilitadas y lo dicen
/// con texto, no solo con color. Sin franjas explica por que no hay.
class SelectorFranja extends StatelessWidget {
  const SelectorFranja({
    required this.franjas,
    required this.seleccionada,
    required this.alSeleccionar,
    super.key,
    this.mensajeVacio = 'No hay horarios para este dia.',
  });

  final List<FranjaHoraria> franjas;
  final int? seleccionada;
  final ValueChanged<int> alSeleccionar;
  final String mensajeVacio;

  @override
  Widget build(BuildContext context) {
    final tokens = TokensPista.de(context);
    final c = tokens.colores;
    final t = tokens.tipografia;

    if (franjas.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: Espaciado.e3),
        child: Text(
          mensajeVacio,
          style: t.cuerpoChico.copyWith(color: c.textoSecundario),
        ),
      );
    }

    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: 'Horarios disponibles',
      child: Wrap(
        spacing: Espaciado.e2,
        runSpacing: Espaciado.e1,
        children: [
          for (var i = 0; i < franjas.length; i++)
            ChipPista(
              texto: franjas[i]._texto,
              seleccionado: seleccionada == i,
              alCambiar: franjas[i].disponible ? (_) => alSeleccionar(i) : null,
            ),
        ],
      ),
    );
  }
}
