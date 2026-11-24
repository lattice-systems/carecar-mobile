import 'package:flutter/widgets.dart';

import '../../../l10n/app_localizations.dart';
import '../../../nucleo/diseno/componentes/aviso.dart';
import '../../../nucleo/diseno/componentes/tono.dart';

/// Cuanto se espera una respuesta antes de avisar que el servidor tarda.
///
/// El backend de Azure se apaga sin trafico y tarda ~35 s en despertar
/// (V2-M01.12). Con una respuesta normal, menos de un segundo, el aviso no
/// aparece nunca.
///
/// **Hay otra copia de este umbral en `lib/widgets/espera_servidor.dart`**, el
/// de la v1, y no se puede compartir: la regla R3 prohibe que el codigo v2
/// importe `lib/widgets`. Las dos deben decir lo mismo hasta que la v1 se
/// retire en V2-T01.07. Su lugar natural seria `lib/nucleo/`.
const umbralEsperaServidor = Duration(seconds: 8);

/// Avisa que el servidor esta despertando · V2-M01.12, portado a la v2.
///
/// **Informa, no es un error**: la peticion sigue en curso y el cliente no
/// tiene nada que hacer salvo esperar. Sin este aviso ve un boton girando
/// durante medio minuto y concluye que la app se colgo.
class AvisoEsperaServidor extends StatelessWidget {
  const AvisoEsperaServidor({super.key});

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    return Aviso(
      tono: Tono.informacion,
      titulo: textos.accesoServidorDespertandoTitulo,
      mensaje: textos.accesoServidorDespertandoMensaje,
    );
  }
}
