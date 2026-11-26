const { BASE, problema, noEncontrado, paginar } = require('../comun/http');

module.exports = function registrarLealtad(servidor, db, emitirEvento) {
  // ── lealtad y recompensas ──
  // V2-M12 · puntos, niveles, recompensas, canjes y referidos con las reglas
  // propuestas del backend (`app.lealtad.*`): Plata desde 1 500 y Oro desde
  // 4 000 puntos ganados en 12 meses, canje vigente 30 dias, 500 puntos por
  // referido que compra y hasta 10 referidos abiertos. El saldo es la suma de
  // los movimientos; un canje vencido devuelve sus puntos al consultarlo.
  db.defaults({ movimientosPuntos: [], recompensas: [], canjes: [], referidos: [] }).write();

  const NIVELES = [
    { nivel: 'BRONCE', desde: 0 },
    { nivel: 'PLATA', desde: 1500 },
    { nivel: 'ORO', desde: 4000 },
  ];
  const GANADOS = ['SERVICIO', 'REFERIDO', 'AJUSTE'];
  const ABIERTOS = ['REGISTRADO', 'EN_SEGUIMIENTO'];
  const DIAS_VIGENCIA = 30;
  const PUNTOS_REFERIDO = 500;
  const MAX_ABIERTOS = 10;
  const MS_POR_DIA = 24 * 60 * 60 * 1000;
  const LETRAS = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';

  const ahora = () => new Date().toISOString();
  const siguienteId = (coleccion) => {
    const ids = db.get(coleccion).map('id').value();
    return ids.length ? Math.max(...ids) + 1 : 1;
  };
  const codigoReferido = (clienteId) => 'CC' + clienteId.toString(36).toUpperCase().padStart(5, '0');
  const saldo = (clienteId) => db.get('movimientosPuntos').filter({ clienteId }).map('puntos').sum().value();

  function mover(clienteId, puntos, motivo, referenciaTipo = null, referenciaId = null) {
    const movimiento = { id: siguienteId('movimientosPuntos'), clienteId, puntos, motivo, referenciaTipo, referenciaId, creadoEn: ahora() };
    db.get('movimientosPuntos').push(movimiento).write();
    emitirEvento(clienteId, 'puntos.movidos', { puntos, motivo, saldo: saldo(clienteId) });
    return movimiento;
  }

  // Lo que haria el proceso nocturno del backend: vence los canjes pasados de
  // fecha y devuelve sus puntos con un movimiento inverso.
  function vencerCanjes(clienteId) {
    const vencidos = db
      .get('canjes')
      .filter((c) => c.clienteId === clienteId && c.estado === 'VIGENTE' && Date.parse(c.venceEn) <= Date.now())
      .value();
    for (const canje of vencidos) {
      db.get('canjes').find({ id: canje.id }).assign({ estado: 'VENCIDO' }).write();
      const recompensa = db.get('recompensas').find({ id: canje.recompensaId });
      if (recompensa.value() && recompensa.value().existencia != null) {
        recompensa.assign({ existencia: recompensa.value().existencia + 1 }).write();
      }
      mover(clienteId, canje.puntos, 'DEVOLUCION_CANJE', 'CANJE', canje.id);
    }
  }

  const publicoMovimiento = ({ clienteId, ...m }) => m;
  const publicoCanje = ({ clienteId, recompensaId, ...c }) => ({ ...c, usadoEn: c.usadoEn ?? null });
  const publicoReferido = (r) => ({
    id: r.id,
    nombre: r.nombre,
    estado: r.estado,
    puntos: r.estado === 'COMPRO' ? PUNTOS_REFERIDO : 0,
    creadoEn: r.creadoEn,
    recompensadoEn: r.recompensadoEn ?? null,
  });
  const publicaRecompensa = ({ activa, ...r }) => ({ ...r, descripcion: r.descripcion ?? null, existencia: r.existencia ?? null });

  // V2-M12.01 · saldo, nivel por lo ganado en 12 meses y lo que falta.
  servidor.get(`${BASE}/lealtad`, (req, res) => {
    const clienteId = req.sesion.clienteId;
    vencerCanjes(clienteId);
    const desde = Date.now() - 365 * MS_POR_DIA;
    const ganados = db
      .get('movimientosPuntos')
      .filter((m) => m.clienteId === clienteId && m.puntos > 0 && GANADOS.includes(m.motivo) && Date.parse(m.creadoEn) >= desde)
      .map('puntos')
      .sum()
      .value();
    const indice = NIVELES.filter((n) => ganados >= n.desde).length - 1;
    const siguiente = NIVELES[indice + 1];
    res.jsonp({
      saldo: saldo(clienteId),
      nivel: NIVELES[indice].nivel,
      ganados,
      siguienteNivel: siguiente ? siguiente.nivel : null,
      puntosParaSiguiente: siguiente ? siguiente.desde - ganados : 0,
      codigoReferido: codigoReferido(clienteId),
    });
  });

  // V2-M12.05 · movimientos del mas nuevo al mas viejo, paginados.
  servidor.get(`${BASE}/lealtad/movimientos`, (req, res) => {
    const clienteId = req.sesion.clienteId;
    vencerCanjes(clienteId);
    const todos = db
      .get('movimientosPuntos')
      .filter({ clienteId })
      .orderBy(['creadoEn', 'id'], ['desc', 'desc'])
      .map(publicoMovimiento)
      .value();
    paginar(req, res, todos);
  });

  // V2-M12.03 · catalogo de recompensas activas, de la mas barata a la mas cara.
  servidor.get(`${BASE}/lealtad/recompensas`, (req, res) => {
    res.jsonp(db.get('recompensas').filter({ activa: true }).orderBy(['puntos', 'id']).map(publicaRecompensa).value());
  });

  servidor.get(`${BASE}/lealtad/canjes`, (req, res) => {
    const clienteId = req.sesion.clienteId;
    vencerCanjes(clienteId);
    res.jsonp(db.get('canjes').filter({ clienteId }).orderBy(['creadoEn', 'id'], ['desc', 'desc']).map(publicoCanje).value());
  });

  servidor.post(`${BASE}/lealtad/canjes`, (req, res) => {
    const clienteId = req.sesion.clienteId;
    const recompensaId = Number((req.body || {}).recompensaId);
    if (!Number.isInteger(recompensaId)) {
      return problema(req, res, 400, 'Falta recompensaId', 'DATOS_INVALIDOS');
    }
    const recompensa = db.get('recompensas').find({ id: recompensaId, activa: true }).value();
    if (!recompensa) return noEncontrado(req, res);
    if (saldo(clienteId) < recompensa.puntos) {
      return problema(req, res, 409, 'No te alcanzan los puntos', 'SALDO_INSUFICIENTE');
    }
    if (recompensa.existencia === 0) {
      return problema(req, res, 409, 'La recompensa se agoto', 'RECOMPENSA_AGOTADA');
    }
    if (recompensa.existencia != null) {
      db.get('recompensas').find({ id: recompensaId }).assign({ existencia: recompensa.existencia - 1 }).write();
    }
    let codigo;
    do {
      codigo = Array.from({ length: 8 }, () => LETRAS[Math.floor(Math.random() * LETRAS.length)]).join('');
    } while (db.get('canjes').find({ codigo }).value());
    const creadoEn = ahora();
    const canje = {
      id: siguienteId('canjes'),
      clienteId,
      recompensaId,
      codigo,
      recompensa: recompensa.nombre,
      puntos: recompensa.puntos,
      estado: 'VIGENTE',
      venceEn: new Date(Date.now() + DIAS_VIGENCIA * MS_POR_DIA).toISOString(),
      usadoEn: null,
      creadoEn,
    };
    db.get('canjes').push(canje).write();
    mover(clienteId, -recompensa.puntos, 'CANJE', 'CANJE', canje.id);
    res.status(201).jsonp(publicoCanje(canje));
  });

  // V2-M12.04 · mis referidos; se registra uno con nombre, telefono o correo y
  // el consentimiento del amigo.
  servidor.get(`${BASE}/lealtad/referidos`, (req, res) => {
    const clienteId = req.sesion.clienteId;
    res.jsonp(db.get('referidos').filter({ clienteId }).orderBy(['creadoEn', 'id'], ['desc', 'desc']).map(publicoReferido).value());
  });

  servidor.post(`${BASE}/lealtad/referidos`, (req, res) => {
    const clienteId = req.sesion.clienteId;
    const { nombre, telefono, correo, consentimiento } = req.body || {};
    const digitos = telefono ? String(telefono).replace(/\D/g, '') : null;
    const correoNormal = correo ? String(correo).trim().toLowerCase() : null;
    if (!nombre || !String(nombre).trim() || consentimiento !== true || (!digitos && !correoNormal)) {
      return problema(req, res, 400, 'Faltan nombre, contacto o consentimiento', 'DATOS_INVALIDOS');
    }
    if (digitos && digitos.length !== 10) {
      return problema(req, res, 400, 'El telefono debe tener 10 digitos', 'DATOS_INVALIDOS');
    }
    const abiertos = db.get('referidos').filter((r) => r.clienteId === clienteId && ABIERTOS.includes(r.estado)).size().value();
    if (abiertos >= MAX_ABIERTOS) {
      return problema(req, res, 409, 'Ya tienes el maximo de referidos abiertos', 'LIMITE_REFERIDOS');
    }
    const esCliente = correoNormal && db.get('cuentas').find((u) => String(u.correo || '').toLowerCase() === correoNormal).value();
    const yaReferido = db
      .get('referidos')
      .find((r) => (digitos && r.telefono === digitos) || (correoNormal && r.correo === correoNormal))
      .value();
    if (esCliente || yaReferido) {
      return problema(req, res, 409, 'Esa persona ya esta con la agencia', 'REFERIDO_DUPLICADO');
    }
    const referido = {
      id: siguienteId('referidos'),
      clienteId,
      codigo: codigoReferido(clienteId),
      nombre: String(nombre).trim(),
      telefono: digitos,
      correo: correoNormal,
      consentimientoEn: ahora(),
      estado: 'EN_SEGUIMIENTO',
      recompensadoEn: null,
      creadoEn: ahora(),
    };
    db.get('referidos').push(referido).write();
    res.status(201).jsonp(publicoReferido(referido));
  });

  // ── emisor de prueba (fuera del contrato, sin token) ──

  // V2-M12.02 · da puntos al cliente como si se entregara una orden y avisa con
  // `puntos.movidos`. Por omision, 165 puntos de SERVICIO al cliente 1.
  servidor.post('/__mock/puntos', (req, res) => {
    const { clienteId = 1, puntos = 165, motivo = 'SERVICIO', ordenId = null } = req.body || {};
    if (!Number.isInteger(puntos) || puntos <= 0 || !GANADOS.includes(motivo)) {
      return problema(req, res, 400, 'puntos debe ser positivo y motivo SERVICIO, REFERIDO o AJUSTE', 'DATOS_INVALIDOS');
    }
    const movimiento = mover(Number(clienteId), puntos, motivo, ordenId == null ? null : 'ORDEN', ordenId);
    res.status(201).jsonp(publicoMovimiento(movimiento));
  });

  // V2-M12.03 · el personal marca usado un canje vigente.
  servidor.post('/__mock/canjes/:codigo/usar', (req, res) => {
    const codigo = String(req.params.codigo).trim().toUpperCase();
    const canje = db.get('canjes').find({ codigo }).value();
    if (!canje) return noEncontrado(req, res);
    if (canje.estado !== 'VIGENTE') {
      return problema(req, res, 409, 'El canje ya no esta vigente', 'CANJE_NO_VIGENTE');
    }
    db.get('canjes').find({ codigo }).assign({ estado: 'USADO', usadoEn: ahora() }).write();
    res.jsonp(publicoCanje(db.get('canjes').find({ codigo }).value()));
  });

  // V2-M12.04 · la venta del referido se finaliza: el cliente gana 500 puntos
  // una sola vez.
  servidor.post('/__mock/referidos/:id/compro', (req, res) => {
    const referido = db.get('referidos').find({ id: Number(req.params.id) }).value();
    if (!referido) return noEncontrado(req, res);
    if (referido.estado !== 'COMPRO') {
      db.get('referidos').find({ id: referido.id }).assign({ estado: 'COMPRO', recompensadoEn: ahora() }).write();
      mover(referido.clienteId, PUNTOS_REFERIDO, 'REFERIDO', 'REFERIDO', referido.id);
    }
    res.jsonp(publicoReferido(db.get('referidos').find({ id: referido.id }).value()));
  });
};
