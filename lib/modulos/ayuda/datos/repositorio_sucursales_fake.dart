import '../dominio/repositorio_sucursales.dart';
import '../dominio/sucursal.dart';

/// Repositorio en memoria para pruebas y para el flavor sin red. Con `error`
/// falla como lo haría la API (por ejemplo con `SinConexion`).
class RepositorioSucursalesFake implements RepositorioSucursales {
  RepositorioSucursalesFake({this.error, List<Sucursal>? sucursales})
    : _sucursales = sucursales ?? ejemplo;

  /// Lo que se lanza en cada llamada; nulo no falla.
  final Object? error;
  final List<Sucursal> _sucursales;

  /// Datos de ejemplo: una sucursal con tres departamentos.
  static const ejemplo = [
    Sucursal(
      id: 1,
      nombre: 'CareCar León',
      direccion: 'Blvd. Ejemplo 100, Col. Centro, 37000 León, Gto.',
      latitud: 21.125,
      longitud: -101.686,
      telefono: '+52 477 000 0000',
      correo: 'contacto@agencia.example.com',
      abiertaAhora: true,
      horarios: [
        HorarioDeDepartamento(
          departamento: Departamento.ventas,
          dias: [1, 2, 3, 4, 5, 6],
          abre: '09:00',
          cierra: '19:00',
          abiertoAhora: true,
        ),
        HorarioDeDepartamento(
          departamento: Departamento.servicio,
          dias: [1, 2, 3, 4, 5],
          abre: '08:00',
          cierra: '18:00',
          abiertoAhora: true,
        ),
        HorarioDeDepartamento(
          departamento: Departamento.refacciones,
          dias: [1, 2, 3, 4, 5],
          abre: '09:00',
          cierra: '17:00',
          abiertoAhora: false,
        ),
      ],
    ),
  ];

  @override
  Future<List<Sucursal>> sucursales() async {
    final fallo = error;
    if (fallo != null) throw fallo;
    return _sucursales;
  }
}
