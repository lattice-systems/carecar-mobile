import 'dart:typed_data';

/// El derecho ARCO que se ejerce (LFPDPPP): acceso, rectificación,
/// cancelación u oposición. La app hoy ofrece el acceso (V2-M22.02).
enum TipoArco { acceso, rectificacion, cancelacion, oposicion }

/// En qué va una solicitud.
enum EstadoArco {
  /// Se está preparando; tarda unos segundos.
  pendiente,

  /// Ya se atendió. En el acceso, el archivo se puede descargar.
  resuelta,

  /// No se pudo preparar. Se puede volver a pedir.
  fallida,

  /// El archivo ya no está disponible. Se puede pedir otro.
  vencida,
}

/// Una solicitud de derechos ARCO de esta cuenta (V2-M22.02).
class SolicitudDeArco {
  const SolicitudDeArco({
    required this.id,
    required this.tipo,
    required this.estado,
    required this.creadaEn,
    this.resueltaEn,
    this.venceEn,
  });

  final int id;
  final TipoArco tipo;
  final EstadoArco estado;
  final DateTime creadaEn;
  final DateTime? resueltaEn;

  /// Hasta cuándo se puede descargar el archivo.
  final DateTime? venceEn;

  /// Si hay un archivo que descargar.
  bool get puedeDescargar =>
      tipo == TipoArco.acceso && estado == EstadoArco.resuelta;
}

/// Por qué no se pudo pedir, listar o descargar. La pantalla decide el texto.
sealed class FalloArco implements Exception {
  const FalloArco();
}

/// No hay conexión con el servidor.
class ArcoSinConexion extends FalloArco {
  const ArcoSinConexion();
}

/// El archivo no existe, es de otra cuenta, todavía no está listo o venció
/// (404 al descargar).
class ArchivoArcoNoDisponible extends FalloArco {
  const ArchivoArcoNoDisponible();
}

/// Cualquier otro error del servidor.
class ArcoNoDisponible extends FalloArco {
  const ArcoNoDisponible();
}

/// Lo que el módulo necesita del backend para los derechos ARCO (V2-M22.02).
abstract interface class RepositorioArco {
  /// Las últimas solicitudes de la cuenta, más recientes primero. Falla con un
  /// [FalloArco].
  Future<List<SolicitudDeArco>> solicitudes();

  /// Pide una copia de los datos. Si ya había una pendiente, devuelve esa.
  /// Falla con un [FalloArco].
  Future<SolicitudDeArco> pedirAcceso();

  /// El archivo JSON de una solicitud de acceso resuelta. Falla con
  /// [ArchivoArcoNoDisponible] si ya no está, o con otro [FalloArco].
  Future<Uint8List> descargar(int solicitudId);
}
