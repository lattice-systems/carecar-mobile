import 'coordenada.dart';
import 'errores_mapas.dart';
import 'geocodificador.dart';
import 'proveedor_ubicacion.dart';

/// [ProveedorUbicacion] para pruebas: no toca el sistema.
///
/// Con [error] fallan las lecturas; con [permisoTrasPedir] se simula lo que
/// responde la persona al diálogo.
class UbicacionFalsa implements ProveedorUbicacion {
  UbicacionFalsa({
    this.posicion = const Coordenada(19.4326, -99.1332),
    this.error,
    PermisoUbicacion permiso = PermisoUbicacion.concedido,
    PermisoUbicacion? permisoTrasPedir,
  }) : _permiso = permiso,
       _permisoTrasPedir = permisoTrasPedir ?? permiso;

  Coordenada posicion;
  ErrorUbicacion? error;
  PermisoUbicacion _permiso;
  final PermisoUbicacion _permisoTrasPedir;

  /// Cuántas veces se pidió la posición y el permiso.
  int consultasDePosicion = 0;
  int peticionesDePermiso = 0;

  @override
  Future<PermisoUbicacion> estadoDelPermiso() async => _permiso;

  @override
  Future<PermisoUbicacion> pedirPermiso() async {
    peticionesDePermiso++;
    return _permiso = _permisoTrasPedir;
  }

  @override
  Future<Coordenada> posicionActual({
    Duration limite = const Duration(seconds: 15),
  }) async {
    consultasDePosicion++;
    final e = error;
    if (e != null) throw e;
    return posicion;
  }
}

/// [Geocodificador] para pruebas, con tablas fijas.
class GeocodificadorFalso implements Geocodificador {
  GeocodificadorFalso({
    this.coordenadasPorDireccion = const {},
    this.direccionesPorCoordenada = const {},
    this.error,
  });

  Map<String, Coordenada> coordenadasPorDireccion;
  Map<Coordenada, Direccion> direccionesPorCoordenada;
  ErrorGeocodificacion? error;

  @override
  Future<Coordenada?> coordenadasDe(String direccion) async {
    final e = error;
    if (e != null) throw e;
    return coordenadasPorDireccion[direccion];
  }

  @override
  Future<Direccion?> direccionDe(Coordenada coordenada) async {
    final e = error;
    if (e != null) throw e;
    return direccionesPorCoordenada[coordenada];
  }
}
