import '../../../api/excepciones.dart';
import '../../../nucleo/api/api_cliente.dart';
import '../dominio/ficha_tecnica_vehiculo.dart';
import '../dominio/repositorio_ficha_tecnica.dart';
import '../dominio/vehiculo_garaje.dart';
import 'ficha_tecnica_local.dart';

/// Lee `GET /vehiculos/{id}/ficha-tecnica` con el cliente del nucleo.
///
/// Si la agencia aun no la tiene (404 o secciones vacias) o no hay red, usa el respaldo local. Si
/// tampoco hay respaldo: con 404 devuelve `null` (estado vacio) y con otro
/// fallo deja pasar la excepcion para que la pantalla ofrezca reintentar.
class RepositorioFichaTecnicaApi implements RepositorioFichaTecnica {
  const RepositorioFichaTecnicaApi(this._cliente);

  final ApiCliente _cliente;

  @override
  Future<FichaTecnicaVehiculo?> ficha(VehiculoGaraje vehiculo) async {
    try {
      final ficha = await _cliente.obtener(
        '/vehiculos/${vehiculo.id}/ficha-tecnica',
        FichaTecnicaVehiculo.fromJson,
      );
      // El backend responde 200 con secciones vacias si aun no tiene datos de
      // ese modelo y ano: se trata igual que un 404.
      if (ficha.secciones.isNotEmpty) return ficha;
      return FichaTecnicaLocal.de(vehiculo);
    } on ExcepcionApi catch (e) {
      final respaldo = FichaTecnicaLocal.de(vehiculo);
      if (respaldo != null) return respaldo;
      if (e is NoEncontrado) return null;
      rethrow;
    }
  }
}
