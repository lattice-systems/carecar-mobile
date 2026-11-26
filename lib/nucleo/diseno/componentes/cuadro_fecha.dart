import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../tokens/espaciado.dart';
import '../tokens/radios.dart';
import '../tokens/tokens_pista.dart';
import 'tono.dart';

/// El día y el mes de una cita en un cuadro pleno del [tono].
///
/// Es el mismo cuadro que el de icono de `TarjetaResumen` y de `GrupoLista`
/// (color pleno del tono y texto `sobreAcento`, que pasa contraste en claro y
/// en oscuro), con la fecha en lugar del icono: así la fecha de una cita se ve
/// igual en el inicio y en la lista de citas. Mide 40 de ancho, como el cuadro
/// de icono de una tarjeta, y por eso sirve de `visual` de `TarjetaResumen`.
///
/// El color sale del estado, pero el estado también se dice con texto en la
/// fila: el color nunca va solo. Es decorativo para el lector de pantalla; la
/// fila o la tarjeta ya leen la fecha completa.
class CuadroFecha extends StatelessWidget {
  const CuadroFecha({
    required this.fecha,
    super.key,
    this.tono = Tono.informacion,
  });

  final DateTime fecha;
  final Tono tono;

  /// Ancho del cuadro; el alto sale del texto.
  static const double ancho = 40;

  @override
  Widget build(BuildContext context) {
    final tokens = TokensPista.de(context);
    final c = tokens.colores;
    final t = tokens.tipografia;
    final idioma = Localizations.localeOf(context).toString();
    // «sept.» se escribe «SEPT»: sin el punto de la abreviatura.
    final mes = DateFormat.MMM(idioma).format(fecha).replaceAll('.', '');

    return ExcludeSemantics(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: ColoresTono.de(tono, c).frente,
          borderRadius: Radios.bordeControl,
        ),
        child: SizedBox(
          width: ancho,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: Espaciado.e1),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  fecha.day.toString(),
                  style: t.titulo3.copyWith(
                    color: c.sobreAcento,
                    fontWeight: FontWeight.w700,
                    height: 1.1,
                  ),
                ),
                Text(
                  mes.toUpperCase(),
                  style: t.micro.copyWith(color: c.sobreAcento),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
