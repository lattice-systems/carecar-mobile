import 'detalle_modelo.dart';
import 'modelo_vigente.dart';

/// Contrato que la presentacion usa para leer el catalogo.
abstract interface class RepositorioCatalogo {
  Future<List<ModeloVigente>> modelos();

  /// El detalle de un modelo. Lanza `NoEncontrado` si ya no esta vigente.
  Future<DetalleModelo> detalle(int id);
}
