import 'modelo_vigente.dart';

/// Contrato que la presentacion usa para leer el catalogo.
abstract interface class RepositorioCatalogo {
  Future<List<ModeloVigente>> modelos();
}
