import 'tienda.dart';

/// Por qué el servidor no dejó hacer algo. La pantalla lo explica en vez de
/// mostrar un error genérico.
enum MotivoRechazoPedido {
  /// Ya no alcanzan las piezas.
  sinExistencia,

  /// La cita elegida está cancelada o ya pasó.
  citaNoDisponible,

  /// Ya hay 3 pedidos sin entregar.
  limiteApartados,

  /// El pedido ya se entregó.
  noCancelable,

  /// El pedido ya se entregó o se canceló.
  noModificable,

  /// Algún producto no le queda al vehículo de la cita.
  productoIncompatible,
}

/// Fallo esperado de un pedido.
class PedidoRechazado implements Exception {
  const PedidoRechazado(this.motivo);

  final MotivoRechazoPedido motivo;

  @override
  String toString() => 'PedidoRechazado(${motivo.name})';
}

/// Lo que el módulo `tienda` necesita de la API (V2-M14).
///
/// Un recurso ajeno o inexistente falla con `NoEncontrado`.
abstract interface class RepositorioTienda {
  /// Productos publicados. Con [vehiculoId] solo los universales y los que le
  /// quedan a ese vehículo.
  Future<PaginaDeProductos> productos({
    int? vehiculoId,
    CategoriaProducto? categoria,
    String? texto,
    int pagina = 0,
    int tamano = 20,
  });

  /// Con [vehiculoId], el producto dice si le queda.
  Future<Producto> producto(int productoId, {int? vehiculoId});

  /// Aparta el carrito. Repetir la misma [llave] devuelve el pedido ya
  /// creado. Lanza [PedidoRechazado].
  Future<Pedido> apartar(Carrito carrito, {required String llave});

  Future<PaginaDePedidos> pedidos({int pagina = 0, int tamano = 20});

  Future<Pedido> pedido(int pedidoId);

  /// Libera las piezas. Lanza [PedidoRechazado] con `noCancelable`.
  Future<Pedido> cancelar(int pedidoId);

  /// Con [citaId] se instala en esa cita y sin él vuelve a mostrador. Lanza
  /// [PedidoRechazado].
  Future<Pedido> cambiarInstalacion(int pedidoId, int? citaId);
}
