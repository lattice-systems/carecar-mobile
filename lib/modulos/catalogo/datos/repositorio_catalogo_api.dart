import '../../../api/carecar_api.dart';
import '../../../api/modelos/modelo_catalogo.dart';
import '../dominio/modelo_vigente.dart';
import '../dominio/repositorio_catalogo.dart';

/// Lee el catalogo de `GET /catalogo` y lo traduce a modelos de dominio.
///
/// Las excepciones de la API (`SinConexion`, `ExcepcionApi`) pasan tal cual: la
/// presentacion decide como mostrarlas.
class RepositorioCatalogoApi implements RepositorioCatalogo {
  const RepositorioCatalogoApi(this._api);

  final CarecarApi _api;

  @override
  Future<List<ModeloVigente>> modelos() async {
    final dto = await _api.catalogo();
    return dto.map(_aModelo).toList(growable: false);
  }

  static ModeloVigente _aModelo(ModeloCatalogo m) => ModeloVigente(
    id: m.id,
    nombre: m.modelo,
    marca: m.marca,
    anio: m.anio,
    version: m.version,
    precioDesde: m.precioDesde,
    imagenUrl: m.imagenUrl,
    descripcion: m.descripcion,
  );
}
