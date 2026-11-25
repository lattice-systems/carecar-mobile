import '../../../api/modelos/traslado.dart';
import 'cotizacion_recoleccion.dart';
import 'direccion_guardada.dart';

/// Contrato que la presentación usa para las direcciones, la cotización y el
/// seguimiento de recolección (V2-M17.01 a V2-M17.04).
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

  /// El traslado `id` con su estado y, si va en camino o de regreso, la
  /// ubicación del chofer (`GET /traslados/{id}`).
  ///
  /// Un traslado ajeno o inexistente lanza `NoEncontrado`: el servidor no
  /// distingue los dos casos.
  Future<TrasladoDetalle> traslado(int id);

  /// El checklist del traslado `trasladoId`, o `null` si el chofer aún no lo
  /// registra (404). Las URLs de fotos y firma vienen firmadas y duran 15
  /// minutos: no se guardan, cada llamada pide un checklist nuevo.
  Future<ChecklistTraslado?> checklist(int trasladoId);
}
