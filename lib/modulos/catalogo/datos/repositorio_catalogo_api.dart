import '../../../api/carecar_api.dart';
import '../../../api/modelos/modelo_catalogo.dart';
import '../dominio/detalle_modelo.dart';
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

  @override
  Future<DetalleModelo> detalle(int id) async {
    final dto = await _api.detalleModelo(id);
    return DetalleModelo(
      modelo: _aModelo(dto.modelo),
      fotos: [
        for (final i in dto.imagenes)
          FotoModelo(url: i.url, descripcion: i.descripcion, color: i.color),
      ],
      versiones: [
        for (final v in dto.versiones)
          VersionDeModelo(
            id: v.id,
            nombre: v.nombre,
            precioDesde: v.precioDesde,
          ),
      ],
      ficha: [
        for (final e in dto.especificaciones)
          DatoFicha(etiqueta: e.etiqueta, valor: e.valor),
      ],
    );
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
