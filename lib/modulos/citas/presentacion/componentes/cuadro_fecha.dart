import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../nucleo/diseno/componentes/tono.dart';
import '../../../../nucleo/diseno/tokens/espaciado.dart';
import '../../../../nucleo/diseno/tokens/radios.dart';
import '../../../../nucleo/diseno/tokens/tokens_pista.dart';

/// Cuadro de color con el día y el mes de una cita, a la izquierda de su fila.
///
/// El color sale del [Tono] del estado (fondo suave y texto del mismo tono,
/// que ya cumplen contraste), pero el estado también se dice con texto en la
/// fila: el color nunca va solo. Es decorativo para el lector de pantalla; la
/// fila ya lee la fecha completa.
class CuadroFecha extends StatelessWidget {
  const CuadroFecha({required this.fecha, required this.tono, super.key});

  final DateTime fecha;
  final Tono tono;

  static const double _ancho = 52;

  @override
  Widget build(BuildContext context) {
    final tokens = TokensPista.de(context);
    final colores = ColoresTono.de(tono, tokens.colores);
    final t = tokens.tipografia;
    final idioma = Localizations.localeOf(context).toString();
    final mes = DateFormat.MMM(idioma).format(fecha).toUpperCase();

    return ExcludeSemantics(
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: _ancho),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colores.fondo,
            borderRadius: Radios.bordeControl,
          ),
          child: Padding(
            padding: const EdgeInsets.all(Espaciado.e2),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${fecha.day}',
                  style: t.titulo2.copyWith(color: colores.frente),
                ),
                Text(
                  mes.replaceAll('.', ''),
                  style: t.micro.copyWith(color: colores.frente),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
