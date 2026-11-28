import 'base_local.dart';

/// [BaseLocal] en memoria, para las pruebas de los módulos que la usan.
///
/// Cumple el mismo contrato que la real (`test/nucleo/base_local/
/// contrato_base_local.dart`), así que sirve para probar sin SQLCipher ni
/// archivos.
class BaseLocalEnMemoria implements BaseLocal {
  BaseLocalEnMemoria({DateTime Function()? reloj})
    : _reloj = reloj ?? DateTime.now;

  final DateTime Function() _reloj;
  final Map<(String, String), CopiaLocal> _copias = {};

  /// Cuántas veces se llamó [borrarTodo]. Para probar que se enganchó al cierre
  /// de sesión.
  int borrados = 0;

  @override
  Future<void> guardar({
    required String coleccion,
    required String clave,
    required String contenido,
  }) async {
    _copias[(coleccion, clave)] = CopiaLocal(
      coleccion: coleccion,
      clave: clave,
      contenido: contenido,
      actualizadoEn: _reloj(),
    );
  }

  @override
  Future<CopiaLocal?> leer({
    required String coleccion,
    required String clave,
  }) async => _copias[(coleccion, clave)];

  @override
  Future<List<CopiaLocal>> listar({required String coleccion}) async => [
    for (final copia in _copias.values)
      if (copia.coleccion == coleccion) copia,
  ];

  @override
  Future<void> borrarTodo() async {
    borrados++;
    _copias.clear();
  }

  @override
  Future<void> cerrar() async {}
}
