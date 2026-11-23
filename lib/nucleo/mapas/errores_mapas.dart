/// Motivos por los que no se pudo leer la posición del teléfono.
///
/// Jerarquía cerrada: un `switch` sobre [ErrorUbicacion] debe cubrir los cuatro
/// casos, y cada pantalla decide su mensaje y su acción (abrir ajustes,
/// reintentar, escribir la dirección a mano).
sealed class ErrorUbicacion implements Exception {
  const ErrorUbicacion(this.mensaje);

  /// Texto para registros y pruebas; la pantalla usa sus propios textos.
  final String mensaje;

  @override
  String toString() => '$runtimeType: $mensaje';
}

/// La persona rechazó el permiso; se puede volver a pedir.
final class UbicacionPermisoDenegado extends ErrorUbicacion {
  const UbicacionPermisoDenegado() : super('Se negó el permiso de ubicación.');
}

/// El sistema ya no mostrará el diálogo; solo se arregla desde Ajustes.
final class UbicacionPermisoDenegadoParaSiempre extends ErrorUbicacion {
  const UbicacionPermisoDenegadoParaSiempre()
    : super('El permiso de ubicación está bloqueado en Ajustes.');
}

/// El GPS o los servicios de ubicación del teléfono están apagados.
final class UbicacionServicioApagado extends ErrorUbicacion {
  const UbicacionServicioApagado()
    : super('Los servicios de ubicación están apagados.');
}

/// No llegó una posición dentro del límite de espera.
final class UbicacionTiempoAgotado extends ErrorUbicacion {
  const UbicacionTiempoAgotado() : super('No se obtuvo la ubicación a tiempo.');
}

/// Falló el servicio que convierte direcciones y coordenadas (sin red, sin
/// servicio del sistema). "Sin resultados" no es un error: se devuelve `null`.
class ErrorGeocodificacion implements Exception {
  const ErrorGeocodificacion(this.mensaje);

  final String mensaje;

  @override
  String toString() => 'ErrorGeocodificacion: $mensaje';
}
