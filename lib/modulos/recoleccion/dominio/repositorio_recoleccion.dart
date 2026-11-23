import 'cotizacion_recoleccion.dart';
import 'direccion_guardada.dart';

/// Contrato que la presentación usa para las direcciones y la cotización de
/// recolección (V2-M17.01 y V2-M17.02).
abstract interface class RepositorioRecoleccion {
  /// Las direcciones del cliente, por orden de alta. Solo las propias.
  Future<List<DireccionGuardada>> direcciones();

  /// Guarda una dirección nueva.
  ///
  /// Lanza `FueraDeCobertura` si el pin queda fuera de la zona.
  Future<DireccionGuardada> guardar(BorradorDireccion borrador);

  /// Reemplaza los datos de la dirección `id`.
  ///
  /// Lanza `FueraDeCobertura` si el pin nuevo queda fuera de la zona.
  Future<DireccionGuardada> editar(int id, BorradorDireccion borrador);

  /// Borra la dirección `id`.
  ///
  /// Lanza `DireccionEnUso` si ya tiene traslados.
  Future<void> borrar(int id);

  /// Costo y franjas de recoger y entregar en `direccionId` el día `fecha`.
  ///
  /// Lanza `FueraDeCobertura` si la dirección ya no está en la zona.
  Future<CotizacionRecoleccion> cotizar({
    required int direccionId,
    required DateTime fecha,
  });
}
