import 'package:flutter/material.dart';

import '../../../nucleo/diseno/tokens/radios.dart';
import '../../../nucleo/diseno/tokens/tokens_pista.dart';

/// Tinte de la portada de un auto segun el nombre de su color.
///
/// Solo devuelve colores de los tokens del sistema (nada de colores sueltos):
/// el rojo usa `peligro`, el verde `exito`, el amarillo/naranja/dorado
/// `advertencia`, el azul `acento`, y los neutros (blanco, plata, gris, negro)
/// `textoSecundario`. Un color desconocido o ausente cae en `marca`.
Color tinteDeColor(TokensPista tokens, String? nombre) {
  final c = tokens.colores;
  final n = (nombre ?? '').toLowerCase();
  bool es(List<String> claves) => claves.any(n.contains);
  if (es(['rojo', 'red', 'vino', 'burgundy', 'guinda'])) return c.peligro;
  if (es(['verde', 'green'])) return c.exito;
  if (es(['amarillo', 'yellow', 'naranja', 'orange', 'dorado', 'gold'])) {
    return c.advertencia;
  }
  if (es(['azul', 'blue'])) return c.acento;
  if (es([
    'blanco',
    'white',
    'plata',
    'silver',
    'gris',
    'gray',
    'grey',
    'negro',
    'black',
  ])) {
    return c.textoSecundario;
  }
  return c.marca;
}

/// Arte cuadrado del auto, tipo "portada de album": cuadro redondeado con el
/// degradado del tinte y la silueta del auto al centro. Es decorativo; quien lo
/// usa le pone la descripcion para el lector de pantalla.
class PortadaVehiculo extends StatelessWidget {
  const PortadaVehiculo({required this.tinte, super.key, this.lado});

  final Color tinte;

  /// Si es `null` ocupa todo el cuadro que le den.
  final double? lado;

  @override
  Widget build(BuildContext context) {
    final c = TokensPista.de(context).colores;
    final arte = DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Radios.hoja),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [tinte, Color.lerp(tinte, c.fondo, 0.45)!],
        ),
      ),
      child: Center(
        child: FittedBox(
          fit: BoxFit.contain,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Icon(
              Icons.directions_car_filled_rounded,
              size: 120,
              color: c.sobreAcento.withValues(alpha: 0.92),
            ),
          ),
        ),
      ),
    );
    return ExcludeSemantics(
      child: lado == null
          ? arte
          : SizedBox(width: lado, height: lado, child: arte),
    );
  }
}
