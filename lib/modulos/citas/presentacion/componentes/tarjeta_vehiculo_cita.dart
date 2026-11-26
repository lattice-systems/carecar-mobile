import 'package:flutter/material.dart';

import 'package:lucide_icons_flutter/lucide_icons_300.dart';

import '../../../../nucleo/diseno/movimiento_contexto.dart';
import '../../../../nucleo/diseno/tokens/espaciado.dart';
import '../../../../nucleo/diseno/tokens/movimiento.dart';
import '../../../../nucleo/diseno/tokens/radios.dart';
import '../../../../nucleo/diseno/tokens/tokens_pista.dart';

/// Tarjeta tipo portada para elegir el vehículo de la cita.
///
/// Pieza cuadrada con la silueta del auto sobre un tinte del acento, el
/// nombre debajo y una marca de selección. Va dentro de un `Estante`, que le
/// da el tamaño. Seleccionada: borde del acento y palomita; el estado también
/// lo dice el lector de pantalla (`selected`), no solo el color.
class TarjetaVehiculoCita extends StatelessWidget {
  const TarjetaVehiculoCita({
    required this.nombre,
    required this.seleccionada,
    required this.alElegir,
    super.key,
  });

  final String nombre;
  final bool seleccionada;
  final VoidCallback alElegir;

  @override
  Widget build(BuildContext context) {
    final tokens = TokensPista.de(context);
    final c = tokens.colores;
    final t = tokens.tipografia;
    final duracion = context.movimiento(Movimiento.rapido).duracion;

    return Semantics(
      button: true,
      selected: seleccionada,
      label: nombre,
      onTap: alElegir,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: alElegir,
        child: AnimatedContainer(
          duration: duracion,
          decoration: BoxDecoration(
            color: c.superficie,
            borderRadius: Radios.bordeTarjeta,
            border: Border.all(
              color: seleccionada ? c.acento : c.borde,
              width: seleccionada ? 2 : 1,
            ),
            boxShadow: tokens.sombras,
          ),
          padding: const EdgeInsets.all(Espaciado.e3),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: c.acentoSuave,
                          borderRadius: Radios.bordeControl,
                        ),
                        child: Center(
                          child: Icon(
                            LucideIcons300.carFront,
                            size: 44,
                            color: c.acento,
                          ),
                        ),
                      ),
                    ),
                    if (seleccionada)
                      Positioned(
                        top: Espaciado.e2,
                        right: Espaciado.e2,
                        child: Icon(
                          LucideIcons300.circleCheck,
                          size: 24,
                          color: c.acento,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: Espaciado.e2),
              Text(
                nombre,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: t.cuerpoFuerte.copyWith(color: c.texto),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
