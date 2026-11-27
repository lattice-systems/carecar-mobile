import '../dominio/pagos.dart';
import '../dominio/repositorio_pagos.dart';
import '../dominio/tarjetas.dart';

/// Repositorio de pagos en memoria para pruebas y desarrollo. Cobra como el
/// procesador simulado: decide por la tarjeta de prueba, repetir la llave
/// devuelve el mismo intento, `tok_sim_3ds` espera la confirmacion y la
/// tarjeta se guarda al quedar pagado si se pidio. Cobra ordenes y pedidos de
/// la tienda igual.
class RepositorioPagosFake implements RepositorioPagos {
  RepositorioPagosFake({
    Map<int, OrdenPorPagar> ordenes = const {},
    Map<int, PedidoPorPagar> pedidos = const {},
    List<Pago> pagos = const [],
    List<MetodoPago> metodos = const [],
    this.falla,
    this.fallaAlPagar,
    this.ahora,
  }) : _ordenes = Map.of(ordenes),
       _pedidos = Map.of(pedidos),
       _pagos = List.of(pagos),
       _metodos = List.of(metodos);

  final Map<int, OrdenPorPagar> _ordenes;
  final Map<int, PedidoPorPagar> _pedidos;
  final List<Pago> _pagos;
  final List<MetodoPago> _metodos;

  /// Si no es nulo, toda lectura falla con esto.
  Object? falla;

  /// Si no es nulo, pagar y autenticar fallan con esto.
  Object? fallaAlPagar;

  final DateTime Function()? ahora;

  final llavesRecibidas = <String>[];
  final mediosRecibidos = <MedioElegido>[];
  final perfilesRecibidos = <int?>[];
  final autenticaciones = <bool>[];
  final paginasPedidas = <int>[];
  final borrados = <int>[];

  final _porLlave = <String, int>{};
  final _tokenDelPago = <int, String>{};
  final _guardarDelPago = <int, TarjetaNueva>{};

  List<Pago> get pagosActuales => List.unmodifiable(_pagos);
  List<MetodoPago> get metodosActuales => List.unmodifiable(_metodos);

  DateTime get _ahora => ahora?.call() ?? DateTime.utc(2026, 11, 26, 18);

  void _quizasFallar() {
    final error = falla;
    if (error != null) throw error;
  }

  void _quizasFallarAlPagar() {
    final error = fallaAlPagar;
    if (error != null) throw error;
  }

  @override
  Future<OrdenPorPagar> orden(int ordenId) async {
    _quizasFallar();
    final orden = _ordenes[ordenId];
    if (orden == null) throw StateError('No hay orden $ordenId');
    final pagado = _pagos
        .where((p) => p.ordenId == ordenId && p.estado == EstadoPago.pagado)
        .firstOrNull;
    return OrdenPorPagar(
      ordenId: orden.ordenId,
      vehiculoId: orden.vehiculoId,
      fecha: orden.fecha,
      totalManoDeObra: orden.totalManoDeObra,
      totalRefacciones: orden.totalRefacciones,
      subtotal: orden.subtotal,
      iva: orden.iva,
      total: orden.total,
      pagable: orden.pagable && pagado == null,
      pago: pagado ?? orden.pago,
    );
  }

  @override
  Future<PedidoPorPagar> pedido(int pedidoId) async {
    _quizasFallar();
    final pedido = _pedidos[pedidoId];
    if (pedido == null) throw StateError('No hay pedido $pedidoId');
    final pagado = _pagos
        .where((p) => p.pedidoId == pedidoId && p.estado == EstadoPago.pagado)
        .firstOrNull;
    return PedidoPorPagar(
      pedidoId: pedido.pedidoId,
      total: pedido.total,
      pagable: pedido.pagable && pagado == null,
      pago: pagado ?? pedido.pago,
    );
  }

  @override
  Future<Pago> pagar(
    int ordenId, {
    required String llave,
    required MedioElegido medio,
    int? perfilFiscalId,
  }) async {
    _quizasFallarAlPagar();
    final repetido = _registrar(llave, medio, perfilFiscalId);
    if (repetido != null) return repetido;
    final orden = await this.orden(ordenId);
    if (!orden.pagable) {
      throw const PagoRechazado(MotivoRechazoPago.ordenNoPagable);
    }
    if (_pagos.any(
      (p) => p.ordenId == ordenId && p.estado == EstadoPago.pendiente,
    )) {
      throw const PagoRechazado(MotivoRechazoPago.pagoEnCurso);
    }
    return _cobrar(
      llave,
      medio,
      perfilFiscalId,
      ordenId: ordenId,
      vehiculoId: orden.vehiculoId,
      monto: orden.total,
    );
  }

  @override
  Future<Pago> pagarPedido(
    int pedidoId, {
    required String llave,
    required MedioElegido medio,
    int? perfilFiscalId,
  }) async {
    _quizasFallarAlPagar();
    final repetido = _registrar(llave, medio, perfilFiscalId);
    if (repetido != null) return repetido;
    final pedido = await this.pedido(pedidoId);
    if (!pedido.pagable) {
      throw const PagoRechazado(MotivoRechazoPago.pedidoNoPagable);
    }
    if (_pagos.any(
      (p) => p.pedidoId == pedidoId && p.estado == EstadoPago.pendiente,
    )) {
      throw const PagoRechazado(MotivoRechazoPago.pagoEnCurso);
    }
    return _cobrar(
      llave,
      medio,
      perfilFiscalId,
      pedidoId: pedidoId,
      monto: pedido.total,
    );
  }

  /// Anota lo recibido y devuelve el intento ya hecho con esa [llave].
  Pago? _registrar(String llave, MedioElegido medio, int? perfilFiscalId) {
    llavesRecibidas.add(llave);
    mediosRecibidos.add(medio);
    perfilesRecibidos.add(perfilFiscalId);
    final repetido = _porLlave[llave];
    if (repetido == null) return null;
    return _pagos.firstWhere((p) => p.id == repetido);
  }

  Pago _cobrar(
    String llave,
    MedioElegido medio,
    int? perfilFiscalId, {
    required double monto,
    int? ordenId,
    int? pedidoId,
    int? vehiculoId,
  }) {
    final (token, marca, ultimos4, tipo, metodoId) = switch (medio) {
      TarjetaNueva(:final token) => _deToken(token),
      TarjetaGuardada(:final metodoPagoId) => _deMetodo(metodoPagoId),
    };
    final escenario = tarjetasDePrueba
        .where((t) => t.token == token)
        .firstOrNull
        ?.escenario;
    final id = (_pagos.map((p) => p.id).fold(0, (a, b) => a > b ? a : b)) + 1;
    final pago = Pago(
      id: id,
      ordenId: ordenId,
      pedidoId: pedidoId,
      vehiculoId: vehiculoId,
      monto: monto,
      medio: MedioPago.tarjeta,
      marca: marca,
      ultimos4: ultimos4,
      tipoTarjeta: tipo,
      estado: switch (escenario) {
        EscenarioTarjeta.fondosInsuficientes => EstadoPago.fallido,
        EscenarioTarjeta.pideConfirmar ||
        EscenarioTarjeta.confirmacionFalla => EstadoPago.pendiente,
        _ => EstadoPago.pagado,
      },
      motivoFallo: escenario == EscenarioTarjeta.fondosInsuficientes
          ? MotivoFalloPago.fondosInsuficientes
          : null,
      requiereAutenticacion:
          escenario == EscenarioTarjeta.pideConfirmar ||
          escenario == EscenarioTarjeta.confirmacionFalla,
      referencia: 'sim_pi_$id',
      simulado: true,
      metodoPagoId: metodoId,
      perfilFiscalId: perfilFiscalId,
      creadoEn: _ahora,
    );
    _porLlave[llave] = id;
    _tokenDelPago[id] = token;
    if (medio is TarjetaNueva && medio.guardar) _guardarDelPago[id] = medio;
    final guardado = pago.estado == EstadoPago.pagado ? _aprobar(pago) : pago;
    _pagos.insert(0, guardado);
    return guardado;
  }

  @override
  Future<Pago> autenticar(int pagoId, {required bool confirmada}) async {
    _quizasFallarAlPagar();
    autenticaciones.add(confirmada);
    final indice = _pagos.indexWhere((p) => p.id == pagoId);
    if (indice < 0) throw StateError('No hay pago $pagoId');
    final pago = _pagos[indice];
    if (!pago.requiereAutenticacion) {
      throw const PagoRechazado(MotivoRechazoPago.pagoNoPendiente);
    }
    final falla = _tokenDelPago[pagoId] == 'tok_sim_3ds_falla';
    final resuelto = confirmada && !falla
        ? _aprobar(pago)
        : _copia(
            pago,
            estado: EstadoPago.fallido,
            motivoFallo: MotivoFalloPago.autenticacionFallida,
          );
    _pagos[indice] = resuelto;
    return resuelto;
  }

  @override
  Future<Pago> pago(int pagoId) async {
    _quizasFallar();
    return _pagos.firstWhere(
      (p) => p.id == pagoId,
      orElse: () => throw StateError('No hay pago $pagoId'),
    );
  }

  @override
  Future<PaginaPagos> pagos({int pagina = 0, int tamano = 20}) async {
    _quizasFallar();
    paginasPedidas.add(pagina);
    final desde = pagina * tamano;
    final hasta = desde + tamano > _pagos.length
        ? _pagos.length
        : desde + tamano;
    return PaginaPagos(
      pagos: desde >= _pagos.length ? const [] : _pagos.sublist(desde, hasta),
      pagina: pagina,
      hayMas: hasta < _pagos.length,
    );
  }

  @override
  Future<List<MetodoPago>> metodos() async {
    _quizasFallar();
    return [
      ..._metodos.where((m) => m.predeterminado),
      ..._metodos.where((m) => !m.predeterminado),
    ];
  }

  @override
  Future<MetodoPago> predeterminar(int metodoPagoId) async {
    _quizasFallar();
    final elegido = _metodos.firstWhere((m) => m.id == metodoPagoId);
    for (var i = 0; i < _metodos.length; i++) {
      _metodos[i] = _metodoCon(
        _metodos[i],
        predeterminado: _metodos[i].id == elegido.id,
      );
    }
    return _metodos.firstWhere((m) => m.id == metodoPagoId);
  }

  @override
  Future<void> borrarMetodo(int metodoPagoId) async {
    _quizasFallar();
    borrados.add(metodoPagoId);
    final era = _metodos.firstWhere((m) => m.id == metodoPagoId);
    _metodos.removeWhere((m) => m.id == metodoPagoId);
    if (era.predeterminado && _metodos.isNotEmpty) {
      _metodos[0] = _metodoCon(_metodos[0], predeterminado: true);
    }
  }

  Pago _aprobar(Pago pago) {
    final nueva = _guardarDelPago[pago.id];
    int? metodoId = pago.metodoPagoId;
    if (nueva != null) {
      final ya = _metodos.where(
        (m) => m.ultimos4 == pago.ultimos4 && m.marca == pago.marca,
      );
      if (ya.isNotEmpty) {
        metodoId = ya.first.id;
      } else {
        metodoId =
            (_metodos.map((m) => m.id).fold(0, (a, b) => a > b ? a : b)) + 1;
        _metodos.add(
          MetodoPago(
            id: metodoId,
            marca: pago.marca!,
            ultimos4: pago.ultimos4!,
            tipo: pago.tipoTarjeta,
            mesVence: nueva.mesVence,
            anioVence: nueva.anioVence,
            vencida: false,
            predeterminado: _metodos.isEmpty,
          ),
        );
      }
    }
    return _copia(
      pago,
      estado: EstadoPago.pagado,
      pagadoEn: _ahora,
      metodoPagoId: metodoId,
    );
  }

  (String, String, String, TipoTarjeta?, int?) _deToken(String token) {
    final tarjeta = tarjetasDePrueba.firstWhere(
      (t) => t.token == token,
      orElse: () => throw ArgumentError('Token desconocido: $token'),
    );
    return (token, tarjeta.marca, tarjeta.ultimos4, tarjeta.tipo, null);
  }

  (String, String, String, TipoTarjeta?, int?) _deMetodo(int metodoPagoId) {
    final metodo = _metodos.firstWhere((m) => m.id == metodoPagoId);
    final token =
        tarjetasDePrueba
            .where(
              (t) => t.ultimos4 == metodo.ultimos4 && t.marca == metodo.marca,
            )
            .firstOrNull
            ?.token ??
        'tok_sim_visa';
    return (token, metodo.marca, metodo.ultimos4, metodo.tipo, metodo.id);
  }

  static Pago _copia(
    Pago pago, {
    required EstadoPago estado,
    MotivoFalloPago? motivoFallo,
    DateTime? pagadoEn,
    int? metodoPagoId,
  }) => Pago(
    id: pago.id,
    ordenId: pago.ordenId,
    pedidoId: pago.pedidoId,
    vehiculoId: pago.vehiculoId,
    monto: pago.monto,
    medio: pago.medio,
    marca: pago.marca,
    ultimos4: pago.ultimos4,
    tipoTarjeta: pago.tipoTarjeta,
    estado: estado,
    motivoFallo: motivoFallo,
    requiereAutenticacion: false,
    referencia: pago.referencia,
    simulado: pago.simulado,
    metodoPagoId: metodoPagoId ?? pago.metodoPagoId,
    perfilFiscalId: pago.perfilFiscalId,
    pagadoEn: pagadoEn,
    creadoEn: pago.creadoEn,
  );

  static MetodoPago _metodoCon(MetodoPago m, {required bool predeterminado}) =>
      MetodoPago(
        id: m.id,
        marca: m.marca,
        ultimos4: m.ultimos4,
        tipo: m.tipo,
        mesVence: m.mesVence,
        anioVence: m.anioVence,
        vencida: m.vencida,
        predeterminado: predeterminado,
      );
}
