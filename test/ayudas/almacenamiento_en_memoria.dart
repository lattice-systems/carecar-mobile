import 'package:carecar_mobile/sesion/almacen_seguro.dart';

/// [AlmacenamientoCifrado] en memoria para las pruebas.
///
/// Cuenta lo que se escribe y se borra, y puede fallar a propósito para probar
/// qué pasa cuando el Keystore o el Keychain no responden. Cada operación cede
/// un turno antes de actuar, como el almacenamiento real, para que dos
/// peticiones a la vez se intercalen.
class AlmacenamientoEnMemoria implements AlmacenamientoCifrado {
  final Map<String, String> valores = {};
  int escrituras = 0;
  int borrados = 0;

  /// Si no es nulo, toda operación lo lanza.
  Object? falla;

  @override
  Future<String?> leer(String clave) async {
    await Future<void>.delayed(Duration.zero);
    _fallarSiToca();
    return valores[clave];
  }

  @override
  Future<void> escribir(String clave, String valor) async {
    await Future<void>.delayed(Duration.zero);
    _fallarSiToca();
    escrituras++;
    valores[clave] = valor;
  }

  @override
  Future<void> borrar(String clave) async {
    await Future<void>.delayed(Duration.zero);
    _fallarSiToca();
    borrados++;
    valores.remove(clave);
  }

  void _fallarSiToca() {
    final error = falla;
    if (error != null) throw error;
  }
}
