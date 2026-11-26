import 'package:flutter/material.dart';

import '../tokens/colores.dart';

/// Tinte de la tarjeta de un auto según el nombre de su color.
///
/// Solo devuelve colores de los tokens del sistema (nada de colores sueltos):
/// el rojo usa `peligro`, el verde `exito`, el amarillo, naranja y dorado
/// `advertencia`. Los neutros (blanco, plata, gris, negro), el azul, los
/// desconocidos y la ausencia de color usan el `acento`: el auto siempre se ve
/// con el color de la marca de la app salvo que tenga uno propio y claro.
Color tinteDeColorAuto(PaletaColores c, String? nombre) {
  final n = (nombre ?? '').toLowerCase();
  bool es(List<String> claves) => claves.any(n.contains);
  if (es(['rojo', 'red', 'vino', 'burgundy', 'guinda'])) return c.peligro;
  if (es(['verde', 'green'])) return c.exito;
  if (es(['amarillo', 'yellow', 'naranja', 'orange', 'dorado', 'gold'])) {
    return c.advertencia;
  }
  return c.acento;
}
