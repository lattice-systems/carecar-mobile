import 'package:flutter/material.dart';

import 'package:lucide_icons_flutter/lucide_icons_300.dart';

import 'aviso.dart';

/// Cuanto se espera una respuesta antes de avisar que el servidor tarda.
///
/// El backend se apaga sin trafico y tarda ~35 s en despertar (V2-M01.12). Con
/// una respuesta normal (< 1 s) el aviso nunca aparece.
const umbralServidorDespertando = Duration(seconds: 8);

/// Texto corto del aviso, para donde no cabe una caja (la cortina de arranque).
const textoServidorDespertando =
    'Despertando el servidor… Puede tardar hasta un minuto.';

/// Aviso de que el servidor esta despertando. Informa, no es un error: la
/// peticion sigue en curso y no hace falta que el cliente haga nada.
class AvisoServidorDespertando extends StatelessWidget {
  const AvisoServidorDespertando({super.key});

  @override
  Widget build(BuildContext context) {
    return const Aviso.informacion(
      titulo: 'Despertando el servidor…',
      detalle:
          'La primera vez después de un rato puede tardar hasta un minuto.',
      icono: LucideIcons300.hourglass,
    );
  }
}
