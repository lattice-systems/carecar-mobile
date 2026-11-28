/// Una copia de datos del cliente guardada en el teléfono (V2-M21.01).
///
/// El contenido es texto (JSON, normalmente) y no un modelo: la base local no
/// conoce los datos de ningún módulo. Cada módulo decide qué guarda y cómo lo
/// codifica; así un módulo nuevo no obliga a cambiar el esquema del núcleo.
class CopiaLocal {
  const CopiaLocal({
    required this.coleccion,
    required this.clave,
    required this.contenido,
    required this.actualizadoEn,
  });

  /// A qué familia de datos pertenece (`vehiculos`, `citas`…).
  final String coleccion;

  /// Identifica la copia dentro de su [coleccion].
  final String clave;

  final String contenido;

  /// Cuándo se guardó. Es lo que alimenta el sello «actualizado hace X» de
  /// V2-M21.02. `1970-01-01` significa que no se sabe (copias de antes de que
  /// el esquema guardara la hora).
  final DateTime actualizadoEn;
}

/// La base local cifrada de los datos del cliente (V2-M21.01, ADR 0005).
///
/// Los módulos dependen de **esta interfaz** y nunca de `drift`: si el equipo
/// cambia de motor, cambia una clase. En pruebas se usa `BaseLocalEnMemoria`.
///
/// Todo lo que haya aquí es copia de lo que tiene el servidor: se puede perder
/// sin perder nada del cliente. Por eso, ante cualquier duda (llave perdida,
/// archivo dañado, esquema de una versión futura) la base se **descarta y se
/// recrea** en vez de dar datos a medias.
///
/// Se borra entera al cerrar sesión ([borrarTodo]).
abstract interface class BaseLocal {
  /// Guarda [contenido] y lo marca con la hora de ahora; si ya había una copia
  /// con esa [coleccion] y [clave], la reemplaza.
  Future<void> guardar({
    required String coleccion,
    required String clave,
    required String contenido,
  });

  /// La copia guardada, o `null` si no hay.
  Future<CopiaLocal?> leer({required String coleccion, required String clave});

  /// Todas las copias de [coleccion] (vacía si no hay).
  Future<List<CopiaLocal>> listar({required String coleccion});

  /// Borra **todos** los datos del cliente y olvida la llave con que se
  /// cifraron. La base queda lista para usarse de nuevo, vacía.
  Future<void> borrarTodo();

  /// Suelta los recursos. No borra datos.
  Future<void> cerrar();
}

/// La base local no se pudo abrir (el almacenamiento seguro no entregó la
/// llave, o el motor cifrado no está disponible).
///
/// Nunca se cae a una base sin cifrar: quien guarda copias debe tratarlo como
/// «sin copia local» y seguir con la red.
class BaseLocalNoDisponible implements Exception {
  const BaseLocalNoDisponible(this.motivo);

  final String motivo;

  @override
  String toString() => 'BaseLocalNoDisponible: $motivo';
}
