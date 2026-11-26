/// Dominio de la tienda de refacciones y accesorios (V2-M14). Dart puro.
library;

/// Piezas de un mismo producto que caben en un pedido.
const maximoPiezasPorRenglon = 10;

/// Productos distintos que caben en un pedido.
const maximoRenglones = 10;

enum CategoriaProducto { accesorio, refaccion, cuidado }

enum EntregaPedido { mostrador, cita }

enum EstadoPedido { apartado, listo, entregado, cancelado }

enum MotivoCancelacion { cliente, vencido, agencia }

/// Modelo y años a los que les queda un producto.
class CompatibilidadProducto {
  const CompatibilidadProducto({
    required this.modelo,
    required this.anioDesde,
    required this.anioHasta,
  });

  final String modelo;
  final int anioDesde;
  final int anioHasta;
}

/// Un producto publicado en la app (V2-M14.01).
class Producto {
  const Producto({
    required this.id,
    required this.codigo,
    required this.nombre,
    required this.categoria,
    required this.precio,
    required this.existencia,
    required this.universal,
    this.compatibilidad = const [],
    this.descripcion,
    this.fotoUrl,
    this.compatible,
  });

  final int id;
  final String codigo;
  final String nombre;
  final String? descripcion;

  /// Nula si el servidor manda una categoría que la app no conoce.
  final CategoriaProducto? categoria;

  /// Precio final en pesos.
  final double precio;
  final String? fotoUrl;

  /// Piezas disponibles. Las apartadas ya no cuentan.
  final int existencia;

  /// Le queda a cualquier vehículo.
  final bool universal;
  final List<CompatibilidadProducto> compatibilidad;

  /// Solo viene cuando se consultó con un vehículo.
  final bool? compatible;

  bool get agotado => existencia <= 0;

  /// Las piezas que se pueden pedir en un renglón.
  int get maximoPorRenglon => existencia.clamp(0, maximoPiezasPorRenglon);
}

class PaginaDeProductos {
  const PaginaDeProductos({
    required this.productos,
    required this.pagina,
    required this.hayMas,
  });

  final List<Producto> productos;
  final int pagina;
  final bool hayMas;
}

/// La cita en la que se instala un pedido (V2-M14.03).
class CitaDePedido {
  const CitaDePedido({
    required this.id,
    required this.fecha,
    required this.hora,
    required this.vehiculoId,
  });

  final int id;
  final DateTime fecha;
  final String hora;
  final int vehiculoId;
}

class RenglonPedido {
  const RenglonPedido({
    required this.productoId,
    required this.nombre,
    required this.cantidad,
    required this.precio,
    required this.importe,
  });

  final int productoId;
  final String nombre;
  final int cantidad;
  final double precio;
  final double importe;
}

/// Un pedido de la tienda (V2-M14.02 y V2-M14.05).
class Pedido {
  const Pedido({
    required this.id,
    required this.estado,
    required this.entrega,
    required this.total,
    required this.creadoEn,
    required this.renglones,
    this.venceEn,
    this.listoEn,
    this.entregadoEn,
    this.canceladoEn,
    this.motivoCancelacion,
    this.cita,
  });

  final int id;
  final EstadoPedido estado;
  final EntregaPedido entrega;
  final double total;
  final DateTime creadoEn;

  /// Solo en apartado y listo. Pasada esa hora se cancela solo.
  final DateTime? venceEn;
  final DateTime? listoEn;
  final DateTime? entregadoEn;
  final DateTime? canceladoEn;
  final MotivoCancelacion? motivoCancelacion;
  final CitaDePedido? cita;
  final List<RenglonPedido> renglones;

  /// Sin entregar ni cancelar: se puede cancelar y cambiar la instalación.
  bool get abierto =>
      estado == EstadoPedido.apartado || estado == EstadoPedido.listo;

  int get piezas => renglones.fold(0, (suma, r) => suma + r.cantidad);
}

class PaginaDePedidos {
  const PaginaDePedidos({
    required this.pedidos,
    required this.pagina,
    required this.hayMas,
  });

  final List<Pedido> pedidos;
  final int pagina;
  final bool hayMas;
}

/// Un producto en el carrito.
class RenglonCarrito {
  const RenglonCarrito({required this.producto, required this.cantidad});

  final Producto producto;
  final int cantidad;

  double get importe => producto.precio * cantidad;
}

/// Lo que se va a apartar. Vive solo en memoria.
class Carrito {
  const Carrito({
    this.renglones = const [],
    this.entrega = EntregaPedido.mostrador,
    this.citaId,
  });

  final List<RenglonCarrito> renglones;
  final EntregaPedido entrega;

  /// La cita elegida; solo cuenta si la entrega es en cita.
  final int? citaId;

  bool get vacio => renglones.isEmpty;

  bool get lleno => renglones.length >= maximoRenglones;

  double get total => renglones.fold(0, (suma, r) => suma + r.importe);

  int get piezas => renglones.fold(0, (suma, r) => suma + r.cantidad);

  /// Con instalación hace falta haber elegido la cita.
  bool get listoParaApartar =>
      !vacio && (entrega == EntregaPedido.mostrador || citaId != null);

  RenglonCarrito? renglonDe(int productoId) {
    for (final r in renglones) {
      if (r.producto.id == productoId) return r;
    }
    return null;
  }

  /// Suma [cantidad] piezas sin pasar de la existencia ni de 10. Devuelve el
  /// mismo carrito si ya no cabe otro producto o está agotado.
  Carrito agregar(Producto producto, int cantidad) {
    final actual = renglonDe(producto.id);
    if (producto.agotado || (actual == null && lleno)) return this;
    final total = ((actual?.cantidad ?? 0) + cantidad).clamp(
      1,
      producto.maximoPorRenglon,
    );
    final nuevo = RenglonCarrito(producto: producto, cantidad: total);
    return _con(
      actual == null
          ? [...renglones, nuevo]
          : [for (final r in renglones) r == actual ? nuevo : r],
    );
  }

  Carrito conCantidad(int productoId, int cantidad) => _con([
    for (final r in renglones)
      r.producto.id == productoId
          ? RenglonCarrito(
              producto: r.producto,
              cantidad: cantidad.clamp(1, maximoPiezasPorRenglon),
            )
          : r,
  ]);

  Carrito sin(int productoId) =>
      _con([...renglones.where((r) => r.producto.id != productoId)]);

  Carrito paraMostrador() => Carrito(renglones: renglones);

  Carrito paraCita(int? citaId) => Carrito(
    renglones: renglones,
    entrega: EntregaPedido.cita,
    citaId: citaId,
  );

  Carrito _con(List<RenglonCarrito> nuevos) =>
      Carrito(renglones: nuevos, entrega: entrega, citaId: citaId);

  /// Distingue un carrito de otro: de aquí sale si un reintento reusa la
  /// llave del apartado.
  String get huella {
    final partes = [for (final r in renglones) '${r.producto.id}x${r.cantidad}']
      ..sort();
    final destino = entrega == EntregaPedido.cita ? 'cita$citaId' : 'mostrador';
    return '${partes.join(',')}|$destino';
  }
}
