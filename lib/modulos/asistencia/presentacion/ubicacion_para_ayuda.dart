import '../../../nucleo/mapas/mapas.dart';

/// Por que no se pudo compartir la ubicacion; cada motivo tiene su mensaje.
enum MotivoSinUbicacion {
  permisoDenegado,
  permisoBloqueado,
  servicioApagado,
  tiempoAgotado,
}

/// Resultado de pedir la ubicacion para una solicitud de ayuda.
sealed class ResultadoUbicacion {
  const ResultadoUbicacion();
}

class UbicacionObtenida extends ResultadoUbicacion {
  const UbicacionObtenida(this.coordenada);

  final Coordenada coordenada;
}

class UbicacionNoDisponible extends ResultadoUbicacion {
  const UbicacionNoDisponible(this.motivo);

  final MotivoSinUbicacion motivo;
}

/// Pide permiso si hace falta y lee la posicion **una vez**, en primer plano.
///
/// Nunca lanza: todo fallo de ubicacion se vuelve un [UbicacionNoDisponible]
/// para que la pantalla ofrezca enviar la solicitud sin ubicacion. Nada se
/// guarda aqui ni se escribe en logs.
Future<ResultadoUbicacion> obtenerUbicacionParaAyuda(
  ProveedorUbicacion proveedor,
) async {
  try {
    var permiso = await proveedor.estadoDelPermiso();
    if (permiso == PermisoUbicacion.denegado) {
      permiso = await proveedor.pedirPermiso();
    }
    switch (permiso) {
      case PermisoUbicacion.denegadoParaSiempre:
        return const UbicacionNoDisponible(MotivoSinUbicacion.permisoBloqueado);
      case PermisoUbicacion.denegado:
        return const UbicacionNoDisponible(MotivoSinUbicacion.permisoDenegado);
      case PermisoUbicacion.concedido:
        return UbicacionObtenida(await proveedor.posicionActual());
    }
  } on ErrorUbicacion catch (error) {
    return UbicacionNoDisponible(switch (error) {
      UbicacionPermisoDenegado() => MotivoSinUbicacion.permisoDenegado,
      UbicacionPermisoDenegadoParaSiempre() =>
        MotivoSinUbicacion.permisoBloqueado,
      UbicacionServicioApagado() => MotivoSinUbicacion.servicioApagado,
      UbicacionTiempoAgotado() => MotivoSinUbicacion.tiempoAgotado,
    });
  }
}
