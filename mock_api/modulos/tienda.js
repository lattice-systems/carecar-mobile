const { BASE, problema, noEncontrado, paginar, sinContrato } = require('../comun/http');

module.exports = function registrarTienda(servidor, db, vehiculoDelCliente, emitirEvento) {
  // ── tienda ──
  // V2-M14 · productos compatibles, apartados y pedidos con las reglas del
  // backend: apartado de 48 horas (o hasta el final del dia siguiente a la
  // cita), 3 pedidos sin entregar, 10 renglones y 10 piezas por renglon. La
  // `existencia` ya no cuenta las piezas apartadas. No hay proceso programado:
  // cada consulta vence primero lo pasado de hora y sigue a la cita ligada.
  // La semilla tambien llena los `db.json` creados antes de la tienda.
  // V2-M14.04: el pago en la app vive en `pagosApp` (modulo de pagos). Un
  // pedido pagado ya no vence ni se cancela desde la app, y uno con un pago
  // esperando el 3-D Secure tampoco vence mientras espera.
  db.defaults(require('../semillas/tienda.json')).write();

  const MS_VIGENCIA = 48 * 60 * 60 * 1000;
  const MAX_ABIERTOS = 3;
  const MAX_RENGLONES = 10;
  const MAX_PIEZAS = 10;
  const CATEGORIAS = ['accesorio', 'refaccion', 'cuidado'];
  const ABIERTOS = ['apartado', 'listo'];

  const ahora = () => new Date().toISOString();
  const redondear = (n) => Math.round(n * 100) / 100;
  const producto = (id) => db.get('productosTienda').find({ id: Number(id) }).value();
  const rechazar = (req, res, status, codigo, mensaje) => problema(req, res, status, mensaje, codigo);
  const datosInvalidos = (req, res, mensaje) => rechazar(req, res, 400, 'DATOS_INVALIDOS', mensaje);

  function leQueda(p, vehiculo) {
    if (p.universal) return true;
    const nombre = `${vehiculo.tipo ?? ''} ${vehiculo.modelo}`.toLowerCase();
    return p.compatibilidad.some(
      (c) => nombre.includes(c.modelo.toLowerCase()) && vehiculo.anio >= c.anioDesde && vehiculo.anio <= c.anioHasta
    );
  }

  const publicoProducto = (p, vehiculo) => ({ ...p, ...(vehiculo ? { compatible: leQueda(p, vehiculo) } : {}) });

  const MS_PAGO_PENDIENTE = 15 * 60 * 1000;
  const pagoDe = (pedido) => db.get('pagosApp').find({ pedidoId: pedido.id, estado: 'PAGADO' }).value();
  const pagoEnCurso = (pedido) =>
    db
      .get('pagosApp')
      .find((p) => p.pedidoId === pedido.id && p.estado === 'PENDIENTE' && Date.parse(p.creadoEn) > Date.now() - MS_PAGO_PENDIENTE)
      .value();

  // El Pago con que quedo pagado, como lo publica el modulo de pagos.
  const publicoPagoDePedido = (p) => ({
    id: p.id,
    ordenId: null,
    pedidoId: p.pedidoId,
    vehiculoId: null,
    monto: p.monto,
    moneda: p.moneda,
    medio: p.medio,
    marca: p.marca ?? null,
    ultimos4: p.ultimos4 ?? null,
    tipoTarjeta: p.tipoTarjeta ?? null,
    estado: p.estado,
    motivoFallo: null,
    requiereAutenticacion: false,
    referencia: p.referencia,
    simulado: p.simulado,
    metodoPagoId: p.metodoPagoId ?? null,
    perfilFiscalId: p.perfilFiscalId ?? null,
    pagadoEn: p.pagadoEn ?? null,
    creadoEn: p.creadoEn,
  });

  const publicoPedido = ({ clienteId, llave, ...p }) => {
    const pago = pagoDe(p);
    const vencido = p.venceEn && Date.parse(p.venceEn) <= Date.now();
    return {
      ...p,
      pagable: ABIERTOS.includes(p.estado) && !pago && !vencido && p.total > 0,
      pago: pago ? publicoPagoDePedido(pago) : null,
      pagadoEn: pago ? pago.pagadoEn : null,
    };
  };

  function moverExistencia(renglones, signo) {
    for (const r of renglones) {
      const p = producto(r.productoId);
      if (p) db.get('productosTienda').find({ id: p.id }).assign({ existencia: p.existencia + signo * r.cantidad }).write();
    }
  }

  function guardar(pedido, cambios, quitar = []) {
    const nuevo = { ...pedido, ...cambios };
    for (const campo of quitar) delete nuevo[campo];
    db.get('pedidosTienda').remove({ id: pedido.id }).write();
    db.get('pedidosTienda').push(nuevo).write();
    return nuevo;
  }

  const avisar = (pedido) =>
    emitirEvento(pedido.clienteId, 'pedido.estado', { pedidoId: pedido.id, estado: pedido.estado });

  function cancelar(pedido, motivo) {
    moverExistencia(pedido.renglones, 1);
    const nuevo = guardar(
      pedido,
      { estado: 'cancelado', canceladoEn: ahora(), motivoCancelacion: motivo },
      ['venceEn']
    );
    avisar(nuevo);
    return nuevo;
  }

  // Fin del dia siguiente a la cita, en la hora local del simulador.
  function venceConCita(fecha) {
    const [anio, mes, dia] = fecha.split('-').map(Number);
    return new Date(anio, mes - 1, dia + 1, 23, 59, 59).toISOString();
  }

  const venceEnMostrador = () => new Date(Date.now() + MS_VIGENCIA).toISOString();

  function citaDisponible(cita) {
    return cita.estado === 'CONFIRMADA' && new Date(`${cita.fecha}T${cita.horaInicio}`).getTime() >= Date.now();
  }

  const comoCitaDePedido = (c) => ({ id: c.id, fecha: c.fecha, hora: c.horaInicio, vehiculoId: c.vehiculoId });

  // La cita manda: si se cancelo, el pedido vuelve a mostrador; si cambio de
  // fecha, la vigencia se mueve con ella. Despues vence lo pasado de hora.
  function alDia(clienteId) {
    const abiertos = db
      .get('pedidosTienda')
      .filter((p) => p.clienteId === clienteId && ABIERTOS.includes(p.estado))
      .value();
    for (let pedido of [...abiertos]) {
      if (pedido.cita) {
        const cita = db.get('citas').find({ id: pedido.cita.id }).value();
        if (!cita || cita.estado === 'CANCELADA') {
          pedido = guardar(pedido, { entrega: 'mostrador', venceEn: venceEnMostrador() }, ['cita']);
          avisar(pedido);
        } else if (cita.fecha !== pedido.cita.fecha || cita.horaInicio !== pedido.cita.hora) {
          pedido = guardar(pedido, { cita: comoCitaDePedido(cita), venceEn: venceConCita(cita.fecha) });
          avisar(pedido);
        }
      }
      if (pagoDe(pedido) || pagoEnCurso(pedido)) continue;
      if (Date.parse(pedido.venceEn) <= Date.now()) cancelar(pedido, 'vencido');
    }
  }

  // La cita para instalar los renglones, o `null` si ya respondio el error.
  function citaParaInstalar(req, res, citaId, renglones) {
    const cita = db.get('citas').find({ id: Number(citaId) }).value();
    if (!cita || cita.clienteId !== req.sesion.clienteId) {
      noEncontrado(req, res);
      return null;
    }
    if (!citaDisponible(cita)) {
      rechazar(req, res, 409, 'CITA_NO_DISPONIBLE', 'La cita está cancelada o ya pasó');
      return null;
    }
    const vehiculo = db.get('vehiculos').find({ id: cita.vehiculoId }).value();
    if (!vehiculo || renglones.some((r) => !leQueda(producto(r.productoId), vehiculo))) {
      rechazar(req, res, 422, 'PRODUCTO_INCOMPATIBLE', 'Algún producto no le queda al vehículo de la cita');
      return null;
    }
    return cita;
  }

  function pedidoDelCliente(req, res) {
    alDia(req.sesion.clienteId);
    const pedido = db.get('pedidosTienda').find({ id: Number(req.params.pedidoId) }).value();
    if (!pedido || pedido.clienteId !== req.sesion.clienteId) {
      noEncontrado(req, res);
      return null;
    }
    return pedido;
  }

  // V2-M14.01 · publicados por nombre; con vehiculo, solo lo que le queda.
  servidor.get(`${BASE}/tienda/productos`, (req, res) => {
    const { vehiculoId, categoria, q = '' } = req.query;
    if (categoria !== undefined && !CATEGORIAS.includes(categoria)) {
      return datosInvalidos(req, res, 'categoria no es valida');
    }
    if (String(q).length > 80) return datosInvalidos(req, res, 'q admite 80 caracteres');
    let vehiculo = null;
    if (vehiculoId !== undefined) {
      vehiculo = vehiculoDelCliente(req, vehiculoId);
      if (!vehiculo) return noEncontrado(req, res);
    }
    alDia(req.sesion.clienteId);
    const buscado = String(q).trim().toLowerCase();
    const lista = db
      .get('productosTienda')
      .value()
      .filter(
        (p) =>
          (!vehiculo || leQueda(p, vehiculo)) &&
          (!categoria || p.categoria === categoria) &&
          (!buscado || p.nombre.toLowerCase().includes(buscado) || p.codigo.toLowerCase().includes(buscado))
      )
      .sort((a, b) => a.nombre.localeCompare(b.nombre, 'es'))
      .map((p) => publicoProducto(p, vehiculo));
    paginar(req, res, lista);
  });

  servidor.get(`${BASE}/tienda/productos/:productoId`, (req, res) => {
    let vehiculo = null;
    if (req.query.vehiculoId !== undefined) {
      vehiculo = vehiculoDelCliente(req, req.query.vehiculoId);
      if (!vehiculo) return noEncontrado(req, res);
    }
    alDia(req.sesion.clienteId);
    const p = producto(req.params.productoId);
    if (!p) return noEncontrado(req, res);
    res.jsonp(publicoProducto(p, vehiculo));
  });

  // V2-M14.02 y V2-M14.03 · aparta todos los renglones o ninguno.
  servidor.post(`${BASE}/tienda/pedidos`, (req, res) => {
    const clienteId = req.sesion.clienteId;
    const llave = req.get('Idempotency-Key') || '';
    if (llave.length < 8 || llave.length > 64) {
      return datosInvalidos(req, res, 'Idempotency-Key es obligatoria, de 8 a 64 caracteres');
    }
    alDia(clienteId);
    const repetido = db.get('pedidosTienda').find({ clienteId, llave }).value();
    if (repetido) return res.jsonp(publicoPedido(repetido));

    const { renglones, entrega, citaId } = req.body || {};
    const bienFormados =
      Array.isArray(renglones) &&
      renglones.length >= 1 &&
      renglones.length <= MAX_RENGLONES &&
      renglones.every(
        (r) => Number.isInteger(r?.productoId) && Number.isInteger(r?.cantidad) && r.cantidad >= 1 && r.cantidad <= MAX_PIEZAS
      ) &&
      new Set(renglones.map((r) => r.productoId)).size === renglones.length;
    if (!bienFormados) return datosInvalidos(req, res, 'Revisa los renglones del pedido');
    if (!['mostrador', 'cita'].includes(entrega) || (entrega === 'cita' && !Number.isInteger(citaId))) {
      return datosInvalidos(req, res, 'entrega es mostrador o cita, y con cita va citaId');
    }
    if (renglones.some((r) => !producto(r.productoId))) return noEncontrado(req, res);

    let cita = null;
    if (entrega === 'cita') {
      cita = citaParaInstalar(req, res, citaId, renglones);
      if (!cita) return;
    }
    const abiertos = db
      .get('pedidosTienda')
      .filter((p) => p.clienteId === clienteId && ABIERTOS.includes(p.estado))
      .value();
    if (abiertos.length >= MAX_ABIERTOS) {
      return rechazar(req, res, 409, 'LIMITE_APARTADOS', 'Ya tienes 3 pedidos sin entregar');
    }
    if (renglones.some((r) => producto(r.productoId).existencia < r.cantidad)) {
      return rechazar(req, res, 409, 'SIN_EXISTENCIA', 'No alcanzan las piezas');
    }

    const detalle = renglones.map((r) => {
      const p = producto(r.productoId);
      return { productoId: p.id, nombre: p.nombre, cantidad: r.cantidad, precio: p.precio, importe: redondear(p.precio * r.cantidad) };
    });
    const ids = db.get('pedidosTienda').map('id').value();
    const pedido = {
      id: ids.length ? Math.max(...ids) + 1 : 1,
      clienteId,
      llave,
      estado: 'apartado',
      entrega,
      total: redondear(detalle.reduce((suma, r) => suma + r.importe, 0)),
      creadoEn: ahora(),
      venceEn: cita ? venceConCita(cita.fecha) : venceEnMostrador(),
      ...(cita ? { cita: comoCitaDePedido(cita) } : {}),
      renglones: detalle,
    };
    db.get('pedidosTienda').push(pedido).write();
    moverExistencia(detalle, -1);
    avisar(pedido);
    res.status(201).jsonp(publicoPedido(pedido));
  });

  // V2-M14.05 · el mas reciente primero.
  servidor.get(`${BASE}/tienda/pedidos`, (req, res) => {
    alDia(req.sesion.clienteId);
    const propios = db.get('pedidosTienda').filter({ clienteId: req.sesion.clienteId }).value();
    paginar(req, res, [...propios].sort((a, b) => b.id - a.id).map(publicoPedido));
  });

  servidor.get(`${BASE}/tienda/pedidos/:pedidoId`, (req, res) => {
    const pedido = pedidoDelCliente(req, res);
    if (pedido) res.jsonp(publicoPedido(pedido));
  });

  servidor.post(`${BASE}/tienda/pedidos/:pedidoId/cancelar`, (req, res) => {
    const pedido = pedidoDelCliente(req, res);
    if (!pedido) return;
    if (pedido.estado === 'entregado') {
      return rechazar(req, res, 409, 'PEDIDO_NO_CANCELABLE', 'El pedido ya se entregó');
    }
    if (pedido.estado !== 'cancelado' && pagoDe(pedido)) {
      return rechazar(req, res, 409, 'PEDIDO_PAGADO', 'El pedido ya está pagado: se cancela en el mostrador');
    }
    res.jsonp(publicoPedido(pedido.estado === 'cancelado' ? pedido : cancelar(pedido, 'cliente')));
  });

  servidor.put(`${BASE}/tienda/pedidos/:pedidoId/instalacion`, (req, res) => {
    const pedido = pedidoDelCliente(req, res);
    if (!pedido) return;
    const citaId = req.body?.citaId ?? null;
    if (citaId !== null && !Number.isInteger(citaId)) return datosInvalidos(req, res, 'citaId no es valido');
    if (!ABIERTOS.includes(pedido.estado)) {
      return rechazar(req, res, 409, 'PEDIDO_NO_MODIFICABLE', 'El pedido ya se entregó o se canceló');
    }
    if (citaId === null) {
      const enMostrador = guardar(pedido, { entrega: 'mostrador', venceEn: venceEnMostrador() }, ['cita']);
      return res.jsonp(publicoPedido(enMostrador));
    }
    const cita = citaParaInstalar(req, res, citaId, pedido.renglones);
    if (!cita) return;
    const enCita = guardar(pedido, { entrega: 'cita', cita: comoCitaDePedido(cita), venceEn: venceConCita(cita.fecha) });
    res.jsonp(publicoPedido(enCita));
  });

  // Fuera del contrato (sin token): la agencia marca listo, entregado o cancela.
  // Sirve para ver el pedido cambiar en vivo en la app.
  servidor.post('/__mock/pedidos/:pedidoId/estado', (req, res) => {
    const pedido = db.get('pedidosTienda').find({ id: Number(req.params.pedidoId) }).value();
    if (!pedido) return sinContrato(res, 404, 'No existe ese pedido');
    const { estado } = req.body || {};
    const desde = { listo: ['apartado'], entregado: ['listo'], cancelado: ABIERTOS };
    if (!desde[estado]) return sinContrato(res, 400, 'estado es listo, entregado o cancelado');
    if (!desde[estado].includes(pedido.estado)) {
      return sinContrato(res, 409, `Un pedido ${pedido.estado} no pasa a ${estado}`);
    }
    if (estado === 'cancelado') return res.json(publicoPedido(cancelar(pedido, 'agencia')));
    const cambios =
      estado === 'listo'
        ? {
            estado,
            listoEn: ahora(),
            // Quedan al menos 48 horas para recogerlo.
            venceEn: [pedido.venceEn, venceEnMostrador()].sort()[1],
          }
        : { estado, entregadoEn: ahora() };
    const nuevo = guardar(pedido, cambios, estado === 'entregado' ? ['venceEn'] : []);
    avisar(nuevo);
    res.json(publicoPedido(nuevo));
  });
};
