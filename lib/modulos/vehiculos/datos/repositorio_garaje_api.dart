import '../../../api/carecar_api.dart';
import '../../../api/modelos/vehiculo.dart';
import '../dominio/repositorio_garaje.dart';
import '../dominio/vehiculo_garaje.dart';

/// Lee el garaje de `GET /vehiculos` y lo traduce a modelos de dominio.
///
/// Las excepciones de la API (`SinConexion`, `ExcepcionApi`) pasan tal cual: la
/// presentacion decide como mostrarlas. Sin conexion, la API del nucleo ya
/// devuelve la ultima copia guardada.
class RepositorioGarajeApi implements RepositorioGaraje {
  const RepositorioGarajeApi(this._api);

  final CarecarApi _api;

  @override
  Future<List<VehiculoGaraje>> vehiculos() async {
    final dto = await _api.misVehiculos();
    return dto.map(_aVehiculo).toList(growable: false);
  }

  static VehiculoGaraje _aVehiculo(Vehiculo v) => VehiculoGaraje(
    id: v.id,
    modelo: v.modelo,
    anio: v.anio,
    marca: v.marca,
    placas: v.placas,
    kilometraje: v.kilometraje,
  );
}
