import '../../../api/excepciones.dart';
import '../../../api/modelos/problema.dart';
import '../../../nucleo/api/api_cliente.dart';
import '../dominio/repositorio_tienda.dart';
import '../dominio/tienda.dart';
import 'lectura_tienda.dart';

/// Las rutas `Tienda` del contrato con el cliente del núcleo. Las excepciones
/// de la API pasan tal cual: solo se traducen, por su código, los rechazos que
/// las pantallas explican.
class RepositorioTiendaApi implements RepositorioTienda {
  const RepositorioTiendaApi(this._cliente);

  final ApiCliente _cliente;

  static const _lectura = LecturaTienda();

  @override
  Future<PaginaDeProductos> productos({
    int? vehiculoId,
    CategoriaProducto? categoria,
    String? texto,
    int pagina = 0,
    int tamano = 20,
  }) async {
    final buscado = texto?.trim() ?? '';
    final p = await _cliente.obtenerPagina(
      '/tienda/productos',
      _lectura.producto,
      pagina: pagina,
      tamano: tamano,
      consulta: {
        'vehiculoId': vehiculoId?.toString(),
        'categoria': categoria?.name,
        'q': buscado.isEmpty ? null : buscado,
      },
    );
    return PaginaDeProductos(
      productos: p.contenido,
      pagina: p.pagina,
      hayMas: p.hayMas,
    );
  }

  @override
  Future<Producto> producto(int productoId, {int? vehiculoId}) =>
      _cliente.obtener(
        '/tienda/productos/$productoId',
        _lectura.producto,
        consulta: {'vehiculoId': vehiculoId?.toString()},
      );

  @override
  Future<Pedido> apartar(Carrito carrito, {required String llave}) =>
      _traduciendo(
        () => _cliente.enviar(
          '/tienda/pedidos',
          encabezados: {'Idempotency-Key': llave},
          cuerpo: {
            'renglones': [
              for (final r in carrito.renglones)
                {'productoId': r.producto.id, 'cantidad': r.cantidad},
            ],
            'entrega': carrito.entrega.name,
            if (carrito.entrega == EntregaPedido.cita) 'citaId': carrito.citaId,
          },
          leer: _lectura.pedido,
        ),
      );

  @override
  Future<PaginaDePedidos> pedidos({int pagina = 0, int tamano = 20}) async {
    final p = await _cliente.obtenerPagina(
      '/tienda/pedidos',
      _lectura.pedido,
      pagina: pagina,
      tamano: tamano,
    );
    return PaginaDePedidos(
      pedidos: p.contenido,
      pagina: p.pagina,
      hayMas: p.hayMas,
    );
  }

  @override
  Future<Pedido> pedido(int pedidoId) =>
      _cliente.obtener('/tienda/pedidos/$pedidoId', _lectura.pedido);

  @override
  Future<Pedido> cancelar(int pedidoId) => _traduciendo(
    () => _cliente.enviar(
      '/tienda/pedidos/$pedidoId/cancelar',
      cuerpo: null,
      leer: _lectura.pedido,
    ),
  );

  @override
  Future<Pedido> cambiarInstalacion(int pedidoId, int? citaId) => _traduciendo(
    () => _cliente.actualizar(
      '/tienda/pedidos/$pedidoId/instalacion',
      cuerpo: {'citaId': citaId},
      leer: _lectura.pedido,
    ),
  );

  Future<T> _traduciendo<T>(Future<T> Function() pedir) async {
    try {
      return await pedir();
    } on Conflicto catch (e) {
      throw _rechazo(e) ?? e;
    } on SolicitudRechazada catch (e) {
      throw _rechazo(e) ?? e;
    }
  }

  static PedidoRechazado? _rechazo(ExcepcionApi error) {
    final motivo = switch (error.problema?.codigo) {
      CodigoProblema.sinExistencia => MotivoRechazoPedido.sinExistencia,
      CodigoProblema.citaNoDisponible => MotivoRechazoPedido.citaNoDisponible,
      CodigoProblema.limiteApartados => MotivoRechazoPedido.limiteApartados,
      CodigoProblema.pedidoNoCancelable => MotivoRechazoPedido.noCancelable,
      CodigoProblema.pedidoNoModificable => MotivoRechazoPedido.noModificable,
      CodigoProblema.productoIncompatible =>
        MotivoRechazoPedido.productoIncompatible,
      CodigoProblema.pedidoPagado => MotivoRechazoPedido.pagado,
      _ => null,
    };
    return motivo == null ? null : PedidoRechazado(motivo);
  }
}
