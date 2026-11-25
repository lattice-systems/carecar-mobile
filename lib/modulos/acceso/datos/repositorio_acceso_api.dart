import '../../../api/carecar_api.dart';
import '../../../nucleo/datos/repositorio_base.dart';
import '../dominio/repositorio_acceso.dart';

/// Habla con la API real · M01.
///
/// Usa [RepositorioBase] (V2-T01.08), asi que de aqui sale un dato o sale un
/// `Fallo` tipado: lo que la pantalla reciba ya viene clasificado y nunca le
/// llega un error sin tipar que tenga que pintar como «ocurrio un error».
class RepositorioAccesoApi with RepositorioBase implements RepositorioAcceso {
  const RepositorioAccesoApi(this._api);

  final CarecarApi _api;

  @override
  Future<void> cambiarContrasena({
    required String actual,
    required String nueva,
  }) => pedir(() => _api.cambiarContrasena(actual: actual, nueva: nueva));
}
