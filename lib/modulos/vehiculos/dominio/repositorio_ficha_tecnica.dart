import 'ficha_tecnica_vehiculo.dart';
import 'vehiculo_garaje.dart';

/// Contrato que la presentacion usa para leer la ficha tecnica.
abstract interface class RepositorioFichaTecnica {
  /// Ficha del vehiculo, o `null` si ni la agencia ni la app la tienen.
  Future<FichaTecnicaVehiculo?> ficha(VehiculoGaraje vehiculo);
}
