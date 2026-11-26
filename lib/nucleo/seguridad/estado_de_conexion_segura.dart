import 'package:flutter/foundation.dart';

/// Si el certificado del servidor se rechazó la última vez que la app habló con
/// él (V2-M22.15).
///
/// Lo escribe el cliente de la API (`alVerificarCertificado`) y lo lee el aviso
/// global, que explica el problema en vez de dejar solo «sin conexión». Se
/// limpia con la siguiente respuesta del servidor, aunque sea un error: si hubo
/// respuesta, el certificado valió.
class EstadoDeConexionSegura extends ChangeNotifier {
  bool _noSegura = false;

  /// `true` mientras la última conexión se haya rechazado por su certificado.
  bool get noSegura => _noSegura;

  /// [verificado] es `false` si el certificado se rechazó y `true` si el
  /// servidor respondió.
  void actualizar(bool verificado) {
    final noSegura = !verificado;
    if (noSegura == _noSegura) return;
    _noSegura = noSegura;
    notifyListeners();
  }
}
