import 'dart:convert';

import 'package:share_plus/share_plus.dart';

import '../dominio/evento_de_calendario.dart';

/// Ofrece el evento en la hoja de compartir del sistema, que lo abre en el
/// calendario del telefono. Los bytes viajan en memoria; la app no escribe el
/// `.ics` en disco ni lo conserva.
class EntregaDeEventoDelSistema implements EntregaDeEvento {
  const EntregaDeEventoDelSistema();

  static const tipoIcs = 'text/calendar';

  @override
  Future<void> entregar(String ics, {required int citaId}) async {
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile.fromData(utf8.encode(ics), mimeType: tipoIcs)],
        fileNameOverrides: ['cita-$citaId.ics'],
      ),
    );
  }
}
