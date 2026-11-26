import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../nucleo/api/proveedores_api.dart';
import '../../../nucleo/eventos/eventos_en_vivo.dart';
import '../../../nucleo/eventos/proveedores_eventos.dart';
import '../../../nucleo/sesion/proveedores_sesion.dart';
import '../../citas/citas.dart';
import '../../vehiculos/vehiculos.dart';
import '../datos/repositorio_tienda_api.dart';
import '../dominio/repositorio_tienda.dart';
import '../dominio/tienda.dart';

/// Repositorio del módulo. En pruebas:
/// `repositorioTiendaProvider.overrideWithValue(RepositorioTiendaFake())`.
final repositorioTiendaProvider = Provider<RepositorioTienda>(
  (ref) => RepositorioTiendaApi(ref.watch(apiClienteProvider)),
  retry: (_, _) => null,
  name: 'repositorioTiendaProvider',
);

/// De quién son el carrito y el auto elegido: cuando cambia la sesión, se
/// vacían. En pruebas se sustituye.
final duenoSesionTiendaProvider = Provider<Object?>(
  (ref) => ref.watch(estadoSesionProvider),
  name: 'duenoSesionTiendaProvider',
);

/// Imagen de un producto. La dirección puede venir relativa. En pruebas se
/// sustituye por una en memoria para no salir a la red.
final imagenTiendaProvider = Provider<ImageProvider Function(String)>((ref) {
  final base = ref.watch(apiClienteProvider).config.base;
  return (url) => NetworkImage(base.resolve(url).toString());
}, name: 'imagenTiendaProvider');

/// Aviso en vivo de que un pedido cambió de estado (V2-M14.05).
const eventoPedidoEstado = 'pedido.estado';

/// Cuántos productos o pedidos se piden por página.
final tamanoPaginaTiendaProvider = Provider<int>(
  (ref) => 20,
  name: 'tamanoPaginaTiendaProvider',
);

/// El auto que la persona eligió en la tienda. `elegido` falso quiere decir
/// que todavía no elige y se usa su primer auto.
typedef EleccionDeAuto = ({bool elegido, int? vehiculoId});

class EleccionDeAutoNotifier extends Notifier<EleccionDeAuto> {
  @override
  EleccionDeAuto build() {
    ref.watch(duenoSesionTiendaProvider);
    return (elegido: false, vehiculoId: null);
  }

  /// Nulo es «Todos los productos».
  void elegir(int? vehiculoId) =>
      state = (elegido: true, vehiculoId: vehiculoId);
}

final eleccionDeAutoProvider =
    NotifierProvider<EleccionDeAutoNotifier, EleccionDeAuto>(
      EleccionDeAutoNotifier.new,
      name: 'eleccionDeAutoProvider',
    );

/// Con qué vehículo se filtra la tienda (V2-M14.01). Nulo muestra todo,
/// también si el garaje no se pudo leer.
final vehiculoTiendaProvider = FutureProvider.autoDispose<int?>(
  (ref) async {
    final eleccion = ref.watch(eleccionDeAutoProvider);
    if (eleccion.elegido) return eleccion.vehiculoId;
    try {
      final garaje = await ref.watch(garajeProvider.future);
      return garaje.firstOrNull?.id;
    } on Object {
      return null;
    }
  },
  retry: (_, _) => null,
  name: 'vehiculoTiendaProvider',
);

const _sinTexto = '';

/// La categoría y el texto buscado.
typedef FiltroTienda = ({CategoriaProducto? categoria, String texto});

class FiltroTiendaNotifier extends Notifier<FiltroTienda> {
  @override
  FiltroTienda build() => (categoria: null, texto: _sinTexto);

  void categoria(CategoriaProducto? categoria) =>
      state = (categoria: categoria, texto: state.texto);

  void buscar(String texto) {
    if (texto.trim() != state.texto) {
      state = (categoria: state.categoria, texto: texto.trim());
    }
  }

  void limpiar() => state = (categoria: null, texto: _sinTexto);
}

final filtroTiendaProvider =
    NotifierProvider.autoDispose<FiltroTiendaNotifier, FiltroTienda>(
      FiltroTiendaNotifier.new,
      name: 'filtroTiendaProvider',
    );

/// Lo que una lista paginada ya cargó.
class ListaPaginada<T> {
  const ListaPaginada({
    required this.elementos,
    required this.pagina,
    required this.hayMas,
    this.cargandoMas = false,
    this.errorAlCargarMas = false,
  });

  final List<T> elementos;

  /// Última página cargada, empezando en 0.
  final int pagina;
  final bool hayMas;
  final bool cargandoMas;
  final bool errorAlCargarMas;

  ListaPaginada<T> copiaCon({
    required bool cargandoMas,
    required bool errorAlCargarMas,
  }) => ListaPaginada(
    elementos: elementos,
    pagina: pagina,
    hayMas: hayMas,
    cargandoMas: cargandoMas,
    errorAlCargarMas: errorAlCargarMas,
  );
}

bool _cambiaronPedidos(EventoEnVivo evento) =>
    evento.nombre == eventoPedidoEstado || evento.nombre == eventoReconectado;

/// Base de las listas de la tienda. Un cambio de pedido (que mueve existencia)
/// o la vuelta del canal las vuelven a pedir sin pasar por carga; si esa
/// recarga falla, se queda lo que se ve.
abstract class _ListaEnVivo<T> extends AsyncNotifier<ListaPaginada<T>> {
  var _turno = 0;

  Future<ListaPaginada<T>> pedirPagina(int pagina);

  @override
  Future<ListaPaginada<T>> build() {
    ref.listen(eventosProvider, (_, evento) {
      if (evento case AsyncData(:final value) when _cambiaronPedidos(value)) {
        recargar();
      }
    });
    return pedirPagina(0);
  }

  /// Vuelve a pedir las páginas que ya estaban en pantalla.
  Future<void> recargar() async {
    final turno = ++_turno;
    try {
      final hasta = state.value?.pagina ?? 0;
      var ultima = await pedirPagina(0);
      final elementos = [...ultima.elementos];
      while (ultima.pagina < hasta && ultima.hayMas) {
        ultima = await pedirPagina(ultima.pagina + 1);
        elementos.addAll(ultima.elementos);
      }
      if (!ref.mounted || turno != _turno) return;
      state = AsyncData(
        ListaPaginada(
          elementos: elementos,
          pagina: ultima.pagina,
          hayMas: ultima.hayMas,
        ),
      );
    } on Object {
      return;
    }
  }

  /// Pide la página siguiente. Si falla, conserva lo cargado y lo marca.
  Future<void> cargarMas() async {
    final actual = state.value;
    if (actual == null || !actual.hayMas || actual.cargandoMas) return;
    final turno = ++_turno;
    state = AsyncData(
      actual.copiaCon(cargandoMas: true, errorAlCargarMas: false),
    );
    try {
      final pagina = await pedirPagina(actual.pagina + 1);
      if (!ref.mounted || turno != _turno) return;
      state = AsyncData(
        ListaPaginada(
          elementos: [...actual.elementos, ...pagina.elementos],
          pagina: pagina.pagina,
          hayMas: pagina.hayMas,
        ),
      );
    } on Object {
      if (!ref.mounted || turno != _turno) return;
      state = AsyncData(
        actual.copiaCon(cargandoMas: false, errorAlCargarMas: true),
      );
    }
  }
}

/// Los productos con el auto y los filtros elegidos (V2-M14.01).
class ProductosNotifier extends _ListaEnVivo<Producto> {
  @override
  Future<ListaPaginada<Producto>> build() async {
    ref.watch(repositorioTiendaProvider);
    ref.watch(filtroTiendaProvider);
    await ref.watch(vehiculoTiendaProvider.future);
    return super.build();
  }

  @override
  Future<ListaPaginada<Producto>> pedirPagina(int pagina) async {
    final filtro = ref.read(filtroTiendaProvider);
    final respuesta = await ref
        .read(repositorioTiendaProvider)
        .productos(
          vehiculoId: await ref.read(vehiculoTiendaProvider.future),
          categoria: filtro.categoria,
          texto: filtro.texto,
          pagina: pagina,
          tamano: ref.read(tamanoPaginaTiendaProvider),
        );
    return ListaPaginada(
      elementos: respuesta.productos,
      pagina: respuesta.pagina,
      hayMas: respuesta.hayMas,
    );
  }
}

final productosTiendaProvider =
    AsyncNotifierProvider.autoDispose<
      ProductosNotifier,
      ListaPaginada<Producto>
    >(
      ProductosNotifier.new,
      // El reintento es del usuario (botón de EstadoError), no automático.
      retry: (_, _) => null,
      name: 'productosTiendaProvider',
    );

/// Un producto, con su compatibilidad si se pide para un vehículo.
final productoTiendaProvider = FutureProvider.autoDispose
    .family<Producto, ({int productoId, int? vehiculoId})>(
      (ref, clave) {
        ref.listen(eventosProvider, (_, evento) {
          if (evento case AsyncData(:final value)
              when _cambiaronPedidos(value)) {
            ref.invalidateSelf();
          }
        });
        return ref
            .watch(repositorioTiendaProvider)
            .producto(clave.productoId, vehiculoId: clave.vehiculoId);
      },
      retry: (_, _) => null,
      name: 'productoTiendaProvider',
    );

/// Mis pedidos (V2-M14.05), del más reciente al más antiguo.
class MisPedidosNotifier extends _ListaEnVivo<Pedido> {
  @override
  Future<ListaPaginada<Pedido>> build() {
    ref.watch(repositorioTiendaProvider);
    return super.build();
  }

  @override
  Future<ListaPaginada<Pedido>> pedirPagina(int pagina) async {
    final respuesta = await ref
        .read(repositorioTiendaProvider)
        .pedidos(pagina: pagina, tamano: ref.read(tamanoPaginaTiendaProvider));
    return ListaPaginada(
      elementos: respuesta.pedidos,
      pagina: respuesta.pagina,
      hayMas: respuesta.hayMas,
    );
  }
}

final misPedidosProvider =
    AsyncNotifierProvider.autoDispose<
      MisPedidosNotifier,
      ListaPaginada<Pedido>
    >(
      MisPedidosNotifier.new,
      retry: (_, _) => null,
      name: 'misPedidosProvider',
    );

/// Un pedido. Su aviso `pedido.estado` o la vuelta del canal lo vuelven a
/// pedir sin pasar por carga.
class PedidoNotifier extends AsyncNotifier<Pedido> {
  PedidoNotifier(this.pedidoId);

  final int pedidoId;
  var _turno = 0;

  @override
  Future<Pedido> build() {
    ref.listen(eventosProvider, (_, evento) {
      if (evento case AsyncData(:final value)
          when value.nombre == eventoReconectado ||
              (value.nombre == eventoPedidoEstado &&
                  value.datos['pedidoId'] == pedidoId)) {
        recargar();
      }
    });
    return ref.watch(repositorioTiendaProvider).pedido(pedidoId);
  }

  /// Vuelve a pedirlo sin pasar por carga; si falla, se queda el que se ve.
  Future<void> recargar() async {
    final turno = ++_turno;
    try {
      final nuevo = await ref.read(repositorioTiendaProvider).pedido(pedidoId);
      if (ref.mounted && turno == _turno) state = AsyncData(nuevo);
    } on Object {
      return;
    }
  }

  /// Cancela y libera las piezas (V2-M14.02). Lanza [PedidoRechazado].
  Future<void> cancelar() =>
      _cambiar((repositorio) => repositorio.cancelar(pedidoId));

  /// Lo liga a una cita o, con nulo, lo regresa a mostrador (V2-M14.03).
  Future<void> cambiarInstalacion(int? citaId) => _cambiar(
    (repositorio) => repositorio.cambiarInstalacion(pedidoId, citaId),
  );

  // Si el servidor no lo deja, el pedido en pantalla ya está viejo: se vuelve
  // a pedir y el rechazo sube a quien llamó.
  Future<void> _cambiar(
    Future<Pedido> Function(RepositorioTienda) pedir,
  ) async {
    // Que la respuesta llegue aunque se salga de la pantalla.
    final enlace = ref.keepAlive();
    try {
      final nuevo = await pedir(ref.read(repositorioTiendaProvider));
      if (!ref.mounted) return;
      _turno++;
      state = AsyncData(nuevo);
      ref
        ..invalidate(misPedidosProvider)
        ..invalidate(productosTiendaProvider)
        ..invalidate(productoTiendaProvider);
    } on PedidoRechazado {
      if (ref.mounted) await recargar();
      rethrow;
    } finally {
      enlace.close();
    }
  }
}

final pedidoTiendaProvider = AsyncNotifierProvider.autoDispose
    .family<PedidoNotifier, Pedido, int>(
      PedidoNotifier.new,
      retry: (_, _) => null,
      name: 'pedidoTiendaProvider',
    );

// Tope de páginas de citas que se revisan para el selector.
const _paginasDeCitas = 5;

/// Las citas confirmadas que todavía no empiezan, de la más próxima a la más
/// lejana (V2-M14.03).
final citasParaInstalarProvider = FutureProvider.autoDispose<List<CitaCliente>>(
  (ref) async {
    final repositorio = ref.watch(repositorioCitasProvider);
    final ahora = ref.watch(relojCitasProvider)();
    final proximas = <CitaCliente>[];
    for (var pagina = 0; pagina < _paginasDeCitas; pagina++) {
      final respuesta = await repositorio.misCitas(pagina: pagina, tamano: 100);
      proximas.addAll(respuesta.citas.where((c) => c.esProxima(ahora)));
      if (!respuesta.hayMas) break;
    }
    return proximas..sort((a, b) => a.inicio.compareTo(b.inicio));
  },
  retry: (_, _) => null,
  name: 'citasParaInstalarProvider',
);

String _llaveAlAzar() {
  final azar = Random.secure();
  return [
    for (var i = 0; i < 16; i++)
      azar.nextInt(256).toRadixString(16).padLeft(2, '0'),
  ].join();
}

/// El carrito (V2-M14.02). Vive en memoria y se vacía al cambiar la sesión.
class CarritoNotifier extends Notifier<Carrito> {
  String? _llave;
  String? _huellaDeLaLlave;
  Future<Pedido>? _enCurso;

  @override
  Carrito build() {
    ref.watch(duenoSesionTiendaProvider);
    _llave = null;
    _huellaDeLaLlave = null;
    return const Carrito();
  }

  /// Devuelve `false` si no se pudo sumar nada: carrito lleno, agotado o ya
  /// con todas las piezas posibles.
  bool agregar(Producto producto, int cantidad) {
    final antes = state.piezas;
    state = state.agregar(producto, cantidad);
    return state.piezas > antes;
  }

  void cantidad(int productoId, int cantidad) =>
      state = state.conCantidad(productoId, cantidad);

  void quitar(int productoId) => state = state.sin(productoId);

  void recogerEnMostrador() => state = state.paraMostrador();

  void instalarEnCita(int? citaId) => state = state.paraCita(citaId);

  /// Aparta lo que hay. La llave de idempotencia es la misma mientras el
  /// carrito no cambie, así un reintento no aparta dos veces. Lanza
  /// [PedidoRechazado] y conserva el carrito ante cualquier falla.
  Future<Pedido> apartar() => _enCurso ??= _apartar().whenComplete(() {
    _enCurso = null;
  });

  Future<Pedido> _apartar() async {
    final carrito = state;
    if (_huellaDeLaLlave != carrito.huella) {
      _huellaDeLaLlave = carrito.huella;
      _llave = _llaveAlAzar();
    }
    try {
      final pedido = await ref
          .read(repositorioTiendaProvider)
          .apartar(carrito, llave: _llave!);
      _llave = null;
      _huellaDeLaLlave = null;
      state = const Carrito();
      _refrescar();
      return pedido;
    } on PedidoRechazado {
      // La existencia o la cita que se veían ya no son ciertas.
      _refrescar();
      rethrow;
    }
  }

  void _refrescar() => ref
    ..invalidate(misPedidosProvider)
    ..invalidate(productosTiendaProvider)
    ..invalidate(productoTiendaProvider)
    ..invalidate(citasParaInstalarProvider);
}

final carritoProvider = NotifierProvider<CarritoNotifier, Carrito>(
  CarritoNotifier.new,
  name: 'carritoProvider',
);
