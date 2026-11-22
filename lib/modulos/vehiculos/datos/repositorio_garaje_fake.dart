import '../dominio/repositorio_garaje.dart';
import '../dominio/vehiculo_garaje.dart';

/// Garaje en memoria para pruebas y desarrollo. Con `fallar: true` lanza una
/// excepcion para probar el estado de error. Sin `datos` trae dos autos de
/// ejemplo: el primero con todo, el segundo con lo minimo.
class RepositorioGarajeFake implements RepositorioGaraje {
  RepositorioGarajeFake({this.fallar = false, List<VehiculoGaraje>? datos})
    : datos = datos ?? _ejemplo();

  final bool fallar;
  final List<VehiculoGaraje> datos;

  static List<VehiculoGaraje> _ejemplo() => [
    VehiculoGaraje(
      id: 1,
      modelo: 'CX-5',
      anio: 2024,
      marca: 'Mazda',
      placas: 'ABC-123',
      kilometraje: 12500,
      vin: 'JM3KFBDM0R0123456',
      color: 'Rojo',
      version: 'Signature',
      kilometrajeActualizadoEn: DateTime(2026, 10, 20),
    ),
    const VehiculoGaraje(
      id: 2,
      modelo: 'Mazda 3',
      anio: 2022,
      vin: 'JM1BPAC70N1654321',
    ),
  ];

  @override
  Future<List<VehiculoGaraje>> vehiculos() async {
    if (fallar) throw Exception('Fallo simulado del garaje');
    return datos;
  }
}
