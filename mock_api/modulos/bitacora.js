const { BASE, ES_FECHA, problema, noEncontrado } = require('../comun/http');

module.exports = function registrarBitacora(servidor, db, vehiculoDelCliente) {
  // ── bitacora ──
  // V2-M18 · gastos del vehiculo (cargas de gasolina y otros). Las estadisticas
  // (km/l, $/km, gasto por mes) las calcula la app. Una carga de gasolina deberia
  // crear tambien una lectura de km de fuente cliente; el mock solo valida el km.
  db.defaults({ gastos: [] }).write();

  const TIPOS_GASTO = ['gasolina', 'estacionamiento', 'casetas', 'lavado', 'otro'];

  const comoGasto = (g) => ({
    id: g.id,
    vehiculoId: g.vehiculoId,
    tipo: g.tipo,
    monto: g.monto,
    litros: g.litros ?? null,
    km: g.km ?? null,
    fecha: g.fecha,
    descripcion: g.descripcion ?? null,
  });

  // El gasto solo si su vehiculo es del cliente de la sesion.
  function gastoDelCliente(req, id) {
    const gasto = db.get('gastos').find({ id: Number(id) }).value();
    return gasto && vehiculoDelCliente(req, gasto.vehiculoId) ? gasto : null;
  }

  // Valida NuevoGasto con las reglas del contrato; devuelve el gasto limpio o null.
  function validarGasto(cuerpo) {
    const c = cuerpo || {};
    const positivo = (v) => typeof v === 'number' && Number.isFinite(v) && v > 0;
    if (!TIPOS_GASTO.includes(c.tipo) || !positivo(c.monto)) return null;
    if (typeof c.fecha !== 'string' || !ES_FECHA.test(c.fecha)) return null;
    if (c.fecha > new Date().toISOString().slice(0, 10)) return null;
    const descripcion = typeof c.descripcion === 'string' ? c.descripcion.trim() : '';
    if (descripcion.length > 200) return null;
    if (c.tipo === 'otro' && descripcion.length === 0) return null;
    const gasto = { tipo: c.tipo, monto: c.monto, fecha: c.fecha };
    if (descripcion) gasto.descripcion = descripcion;
    if (c.tipo === 'gasolina') {
      if (!positivo(c.litros) || !Number.isInteger(c.km) || c.km < 0) return null;
      gasto.litros = c.litros;
      gasto.km = c.km;
    }
    return gasto;
  }

  // Ultima lectura de km conocida: la del taller o la de la ultima carga.
  function ultimaLecturaKm(vehiculo, ignorandoId) {
    const delCliente = db
      .get('gastos')
      .filter((g) => g.vehiculoId === vehiculo.id && g.id !== ignorandoId && g.km != null)
      .map('km')
      .value();
    return Math.max(vehiculo.kilometraje ?? 0, ...delCliente);
  }

  const kmInvalido = (req, res) =>
    problema(req, res, 422, 'El km es menor a la ultima lectura del vehiculo', 'KM_INVALIDO');

  servidor.get(`${BASE}/vehiculos/:vehiculoId/gastos`, (req, res) => {
    const vehiculo = vehiculoDelCliente(req, req.params.vehiculoId);
    if (!vehiculo) return noEncontrado(req, res);
    const { mes } = req.query;
    if (mes !== undefined && !/^\d{4}-(0[1-9]|1[0-2])$/.test(mes)) {
      return problema(req, res, 400, 'mes debe ser AAAA-MM', 'DATOS_INVALIDOS');
    }
    const pagina = Math.max(0, parseInt(req.query.pagina ?? '0', 10) || 0);
    const tamano = Math.min(100, Math.max(1, parseInt(req.query.tamano ?? '20', 10) || 20));
    const todos = db
      .get('gastos')
      .filter((g) => g.vehiculoId === vehiculo.id && (!mes || g.fecha.startsWith(mes)))
      .value()
      .sort((a, b) => (a.fecha === b.fecha ? b.id - a.id : a.fecha < b.fecha ? 1 : -1));
    res.jsonp({
      contenido: todos.slice(pagina * tamano, (pagina + 1) * tamano).map(comoGasto),
      pagina,
      totalPaginas: Math.max(1, Math.ceil(todos.length / tamano)),
    });
  });

  servidor.post(`${BASE}/vehiculos/:vehiculoId/gastos`, (req, res) => {
    const vehiculo = vehiculoDelCliente(req, req.params.vehiculoId);
    if (!vehiculo) return noEncontrado(req, res);
    const datos = validarGasto(req.body);
    if (!datos) return problema(req, res, 400, 'Datos de gasto invalidos', 'DATOS_INVALIDOS');
    if (datos.km !== undefined && datos.km < ultimaLecturaKm(vehiculo)) return kmInvalido(req, res);

    const ids = db.get('gastos').value().map((g) => g.id);
    const gasto = { id: ids.length ? Math.max(...ids) + 1 : 1, vehiculoId: vehiculo.id, ...datos };
    db.get('gastos').push(gasto).write();
    res.status(201).jsonp(comoGasto(gasto));
  });

  servidor.put(`${BASE}/gastos/:gastoId`, (req, res) => {
    const existente = gastoDelCliente(req, req.params.gastoId);
    if (!existente) return noEncontrado(req, res);
    const datos = validarGasto(req.body);
    if (!datos) return problema(req, res, 400, 'Datos de gasto invalidos', 'DATOS_INVALIDOS');
    const vehiculo = vehiculoDelCliente(req, existente.vehiculoId);
    if (datos.km !== undefined && datos.km < ultimaLecturaKm(vehiculo, existente.id)) {
      return kmInvalido(req, res);
    }
    // PUT reemplaza el gasto: se quitan los campos que ya no vienen.
    db.get('gastos')
      .remove({ id: existente.id })
      .write();
    const gasto = { id: existente.id, vehiculoId: existente.vehiculoId, ...datos };
    db.get('gastos').push(gasto).write();
    res.jsonp(comoGasto(gasto));
  });

  servidor.delete(`${BASE}/gastos/:gastoId`, (req, res) => {
    const existente = gastoDelCliente(req, req.params.gastoId);
    if (!existente) return noEncontrado(req, res);
    db.get('gastos').remove({ id: existente.id }).write();
    res.status(204).end();
  });
};
