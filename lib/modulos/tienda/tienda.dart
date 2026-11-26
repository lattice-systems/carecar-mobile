/// Contrato público del módulo `tienda` (V2-M14: tienda de refacciones y
/// accesorios).
///
/// Otros módulos y la app solo importan este archivo. El módulo no importa
/// `catalogo`, que es quien lo usa para su entrada.
library;

export 'dominio/repositorio_tienda.dart'
    show MotivoRechazoPedido, PedidoRechazado, RepositorioTienda;
export 'dominio/tienda.dart'
    show
        Carrito,
        CategoriaProducto,
        CitaDePedido,
        CompatibilidadProducto,
        EntregaPedido,
        EstadoPedido,
        MotivoCancelacion,
        PaginaDePedidos,
        PaginaDeProductos,
        Pedido,
        Producto,
        RenglonCarrito,
        RenglonPedido;
export 'presentacion/pantalla_carrito.dart' show PantallaCarrito;
export 'presentacion/pantalla_mis_pedidos.dart' show PantallaMisPedidos;
export 'presentacion/pantalla_pedido.dart' show PantallaPedido;
export 'presentacion/pantalla_producto.dart' show PantallaProducto;
export 'presentacion/pantalla_tienda.dart' show PantallaTienda;
export 'presentacion/proveedores_tienda.dart' show repositorioTiendaProvider;
export 'presentacion/rutas_tienda.dart'
    show
        rutaCarrito,
        rutaMisPedidos,
        rutaPedido,
        rutaProducto,
        rutaTienda,
        rutaTiendaDe,
        rutasTienda;
