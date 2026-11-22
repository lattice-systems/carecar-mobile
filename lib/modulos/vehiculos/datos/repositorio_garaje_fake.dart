import '../dominio/repositorio_garaje.dart';
import '../dominio/vehiculo_garaje.dart';

/// Garaje en memoria para pruebas y desarrollo. Con `fallar: true` lanza una
/// excepcion para probar el estado de error.
class RepositorioGarajeFake implements RepositorioGaraje {
  RepositorioGarajeFake({
    this.fallar = false,
    this.datos = const [
      VehiculoGaraje(
        id: 1,
        modelo: 'CX-5',
        anio: 2024,
        marca: 'Mazda',
        placas: 'ABC-123',
        kilometraje: 12500,
      ),
      VehiculoGaraje(id: 2, modelo: 'Mazda 3', anio: 2022),
    ],
  });

  final bool fallar;
  final List<VehiculoGaraje> datos;

  @override
  Future<List<VehiculoGaraje>> vehiculos() async {
    if (fallar) throw Exception('Fallo simulado del garaje');
    return datos;
  }
}
