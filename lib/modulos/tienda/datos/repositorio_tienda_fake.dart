import '../../../api/excepciones.dart';
import '../dominio/repositorio_tienda.dart';
import '../dominio/tienda.dart';

/// Tienda en memoria para pruebas. Apartar descuenta existencia, cancelar la
/// devuelve y repetir la llave devuelve el mismo pedido.
class RepositorioTiendaFake implements RepositorioTienda {
  RepositorioTiendaFake({
    List<Producto> productos = const [],
    List<Pedido> pedidos = const [],
    this.compatiblesPorVehiculo = const {},
    this.falla,
    DateTime Function()? reloj,
  }) : productosActuales = [...productos],
       pedidosActuales = [...pedidos],
       _reloj = reloj ?? DateTime.now;

  List<Producto> productosActuales;
  List<Pedido> pedidosActuales;

  /// Qué productos no universales le quedan a cada vehículo.
  Map<int, Set<int>> compatiblesPorVehiculo;

  /// Falla cualquier llamada mientras no sea nulo.
  Object? falla;

  /// Falla solo al apartar, cancelar o cambiar la instalación.
  Object? fallaAlGuardar;

  /// El servidor crea el pedido pero la respuesta se pierde una vez.
  bool perderRespuestaAlApartar = false;

  final DateTime Function() _reloj;

  final consultas =
      <({int? vehiculoId, CategoriaProducto? categoria, String? texto})>[];
  final llavesRecibidas = <String>[];
  final carritosRecibidos = <Carrito>[];
  final cancelados = <int>[];
  final instalaciones = <({int pedidoId, int? citaId})>[];
  final _porLlave = <String, int>{};

  void _quizaFalla([Object? otra]) {
    final error = falla ?? otra;
    if (error != null) throw error;
  }

  bool _leQueda(Producto p, int vehiculoId) =>
      p.universal ||
      (compatiblesPorVehiculo[vehiculoId]?.contains(p.id) ?? false);

  Producto _con(Producto p, {int? existencia, bool? compatible}) => Producto(
    id: p.id,
    codigo: p.codigo,
    nombre: p.nombre,
    descripcion: p.descripcion,
    categoria: p.categoria,
    precio: p.precio,
    fotoUrl: p.fotoUrl,
    existencia: existencia ?? p.existencia,
    universal: p.universal,
    compatibilidad: p.compatibilidad,
    compatible: compatible,
  );

  List<T> _trozo<T>(List<T> todo, int pagina, int tamano) =>
      todo.skip(pagina * tamano).take(tamano).toList();

  @override
  Future<PaginaDeProductos> productos({
    int? vehiculoId,
    CategoriaProducto? categoria,
    String? texto,
    int pagina = 0,
    int tamano = 20,
  }) async {
    consultas.add((vehiculoId: vehiculoId, categoria: categoria, texto: texto));
    _quizaFalla();
    final buscado = (texto ?? '').trim().toLowerCase();
    final todos = [
      for (final p in productosActuales)
        if ((vehiculoId == null || _leQueda(p, vehiculoId)) &&
            (categoria == null || p.categoria == categoria) &&
            (buscado.isEmpty ||
                p.nombre.toLowerCase().contains(buscado) ||
                p.codigo.toLowerCase().contains(buscado)))
          _con(p, compatible: vehiculoId == null ? null : true),
    ];
    return PaginaDeProductos(
      productos: _trozo(todos, pagina, tamano),
      pagina: pagina,
      hayMas: (pagina + 1) * tamano < todos.length,
    );
  }

  @override
  Future<Producto> producto(int productoId, {int? vehiculoId}) async {
    _quizaFalla();
    final p = productosActuales.where((p) => p.id == productoId).firstOrNull;
    if (p == null) throw const NoEncontrado('No existe');
    return _con(
      p,
      compatible: vehiculoId == null ? null : _leQueda(p, vehiculoId),
    );
  }

  @override
  Future<Pedido> apartar(Carrito carrito, {required String llave}) async {
    llavesRecibidas.add(llave);
    carritosRecibidos.add(carrito);
    _quizaFalla(fallaAlGuardar);
    final repetido = _porLlave[llave];
    if (repetido != null) return pedido(repetido);

    final ahora = _reloj().toUtc();
    final nuevo = Pedido(
      id: pedidosActuales.fold(0, (m, p) => p.id > m ? p.id : m) + 1,
      estado: EstadoPedido.apartado,
      entrega: carrito.entrega,
      total: carrito.total,
      creadoEn: ahora,
      venceEn: ahora.add(const Duration(hours: 48)),
      renglones: [
        for (final r in carrito.renglones)
          RenglonPedido(
            productoId: r.producto.id,
            nombre: r.producto.nombre,
            cantidad: r.cantidad,
            precio: r.producto.precio,
            importe: r.importe,
          ),
      ],
    );
    pedidosActuales = [nuevo, ...pedidosActuales];
    _porLlave[llave] = nuevo.id;
    _mover(nuevo, -1);
    if (perderRespuestaAlApartar) {
      perderRespuestaAlApartar = false;
      throw const SinConexion();
    }
    return nuevo;
  }

  void _mover(Pedido pedido, int signo) {
    final cantidades = {
      for (final r in pedido.renglones) r.productoId: r.cantidad,
    };
    productosActuales = [
      for (final p in productosActuales)
        cantidades.containsKey(p.id)
            ? _con(p, existencia: p.existencia + signo * cantidades[p.id]!)
            : p,
    ];
  }

  @override
  Future<PaginaDePedidos> pedidos({int pagina = 0, int tamano = 20}) async {
    _quizaFalla();
    return PaginaDePedidos(
      pedidos: _trozo(pedidosActuales, pagina, tamano),
      pagina: pagina,
      hayMas: (pagina + 1) * tamano < pedidosActuales.length,
    );
  }

  @override
  Future<Pedido> pedido(int pedidoId) async {
    _quizaFalla();
    final p = pedidosActuales.where((p) => p.id == pedidoId).firstOrNull;
    if (p == null) throw const NoEncontrado('No existe');
    return p;
  }

  Pedido _guardar(Pedido nuevo) {
    pedidosActuales = [
      for (final p in pedidosActuales) p.id == nuevo.id ? nuevo : p,
    ];
    return nuevo;
  }

  @override
  Future<Pedido> cancelar(int pedidoId) async {
    cancelados.add(pedidoId);
    _quizaFalla(fallaAlGuardar);
    final actual = await pedido(pedidoId);
    if (actual.estado == EstadoPedido.cancelado) return actual;
    if (!actual.abierto) {
      throw const PedidoRechazado(MotivoRechazoPedido.noCancelable);
    }
    _mover(actual, 1);
    return _guardar(
      Pedido(
        id: actual.id,
        estado: EstadoPedido.cancelado,
        entrega: actual.entrega,
        total: actual.total,
        creadoEn: actual.creadoEn,
        listoEn: actual.listoEn,
        canceladoEn: _reloj().toUtc(),
        motivoCancelacion: MotivoCancelacion.cliente,
        cita: actual.cita,
        renglones: actual.renglones,
      ),
    );
  }

  @override
  Future<Pedido> cambiarInstalacion(int pedidoId, int? citaId) async {
    instalaciones.add((pedidoId: pedidoId, citaId: citaId));
    _quizaFalla(fallaAlGuardar);
    final actual = await pedido(pedidoId);
    if (!actual.abierto) {
      throw const PedidoRechazado(MotivoRechazoPedido.noModificable);
    }
    return _guardar(
      Pedido(
        id: actual.id,
        estado: actual.estado,
        entrega: citaId == null ? EntregaPedido.mostrador : EntregaPedido.cita,
        total: actual.total,
        creadoEn: actual.creadoEn,
        venceEn: actual.venceEn,
        listoEn: actual.listoEn,
        cita: citaId == null
            ? null
            : CitaDePedido(
                id: citaId,
                fecha: DateTime(2026, 11, 28),
                hora: '09:00',
                vehiculoId: 5,
              ),
        renglones: actual.renglones,
      ),
    );
  }
}
