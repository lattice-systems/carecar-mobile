const { BASE, ES_FECHA, problema, noEncontrado, sinContrato } = require('../comun/http');

module.exports = function registrarRecoleccion(servidor, db, emitirEvento) {
  // ── recoleccion ──
  // V2-M17.01 y V2-M17.02 · direcciones guardadas, cotizacion y traslados.
  // El backend real decide la cobertura con la geometria de la agencia; aqui es
  // un circulo de 15 km alrededor del centro de Leon, Guanajuato, suficiente
  // para probar el 422 desde la app (un pin en la Ciudad de Mexico queda fuera).
  db.defaults({ direcciones: [], traslados: [] }).write();

  const CENTRO_COBERTURA = { lat: 21.125, lng: -101.686 };
  const RADIO_COBERTURA_KM = 15;
  const TARIFA_BASE = 80;
  const TARIFA_POR_KM = 8;
  const VENTANA_RECOGER = { inicio: '07:00', fin: '09:00' };
  const VENTANA_ENTREGAR = { inicio: '17:00', fin: '19:00' };

  function distanciaKm(a, b) {
    const rad = (g) => (g * Math.PI) / 180;
    const dLat = rad(b.lat - a.lat);
    const dLng = rad(b.lng - a.lng);
    const h =
      Math.sin(dLat / 2) ** 2 +
      Math.cos(rad(a.lat)) * Math.cos(rad(b.lat)) * Math.sin(dLng / 2) ** 2;
    return 2 * 6371 * Math.asin(Math.sqrt(h));
  }

  function enCobertura(direccion) {
    return distanciaKm(CENTRO_COBERTURA, direccion) <= RADIO_COBERTURA_KM;
  }

  const costoPorTraslado = (direccion) =>
    Math.round((TARIFA_BASE + TARIFA_POR_KM * distanciaKm(CENTRO_COBERTURA, direccion)) * 100) / 100;

  const fueraDeCobertura = (req, res) =>
    problema(
      req,
      res,
      422,
      'La direccion queda fuera de la zona de cobertura',
      'FUERA_DE_COBERTURA'
    );

  function direccionDelCliente(req, id) {
    const d = db.get('direcciones').find({ id: Number(id) }).value();
    return d && d.clienteId === req.sesion.clienteId ? d : null;
  }

  const comoDireccion = (d) => ({
    id: d.id,
    alias: d.alias,
    calle: d.calle,
    colonia: d.colonia,
    cp: d.cp,
    ciudad: d.ciudad,
    lat: d.lat,
    lng: d.lng,
  });

  // Valida el cuerpo de NuevaDireccion con las mismas reglas del contrato.
  function validarDireccion(cuerpo) {
    const c = cuerpo || {};
    const texto = (v, max) => typeof v === 'string' && v.trim().length > 0 && v.trim().length <= max;
    const numero = (v, min, max) => typeof v === 'number' && v >= min && v <= max;
    if (
      !texto(c.alias, 40) ||
      !texto(c.calle, 120) ||
      !texto(c.colonia, 80) ||
      !/^[0-9]{5}$/.test(String(c.cp || '')) ||
      !texto(c.ciudad, 80) ||
      !numero(c.lat, -90, 90) ||
      !numero(c.lng, -180, 180)
    ) {
      return null;
    }
    return {
      alias: c.alias.trim(),
      calle: c.calle.trim(),
      colonia: c.colonia.trim(),
      cp: c.cp,
      ciudad: c.ciudad.trim(),
      lat: c.lat,
      lng: c.lng,
    };
  }

  servidor.get(`${BASE}/direcciones`, (req, res) => {
    const propias = db.get('direcciones').filter({ clienteId: req.sesion.clienteId }).value();
    res.jsonp(propias.map(comoDireccion));
  });

  servidor.post(`${BASE}/direcciones`, (req, res) => {
    const datos = validarDireccion(req.body);
    if (!datos) return problema(req, res, 400, 'Datos de direccion invalidos', 'DATOS_INVALIDOS');
    if (!enCobertura(datos)) return fueraDeCobertura(req, res);

    const ids = db.get('direcciones').value().map((d) => d.id);
    const direccion = {
      id: ids.length ? Math.max(...ids) + 1 : 1,
      clienteId: req.sesion.clienteId,
      ...datos,
    };
    db.get('direcciones').push(direccion).write();
    res.status(201).jsonp(comoDireccion(direccion));
  });

  servidor.put(`${BASE}/direcciones/:direccionId`, (req, res) => {
    const existente = direccionDelCliente(req, req.params.direccionId);
    if (!existente) return noEncontrado(req, res);
    const datos = validarDireccion(req.body);
    if (!datos) return problema(req, res, 400, 'Datos de direccion invalidos', 'DATOS_INVALIDOS');
    if (!enCobertura(datos)) return fueraDeCobertura(req, res);

    db.get('direcciones').find({ id: existente.id }).assign(datos).write();
    res.jsonp(comoDireccion(db.get('direcciones').find({ id: existente.id }).value()));
  });

  servidor.delete(`${BASE}/direcciones/:direccionId`, (req, res) => {
    const existente = direccionDelCliente(req, req.params.direccionId);
    if (!existente) return noEncontrado(req, res);
    const enUso = db.get('traslados').value().some((t) => t.direccionId === existente.id);
    if (enUso) {
      return problema(
        req,
        res,
        409,
        'La direccion ya tiene traslados y no se puede borrar',
        'DIRECCION_EN_USO'
      );
    }
    db.get('direcciones').remove({ id: existente.id }).write();
    res.status(204).end();
  });

  servidor.get(`${BASE}/recoleccion/cotizacion`, (req, res) => {
    const { direccionId, fecha } = req.query;
    if (!/^\d+$/.test(direccionId || '') || !ES_FECHA.test(fecha || '')) {
      return problema(
        req,
        res,
        400,
        'direccionId y fecha (AAAA-MM-DD) son obligatorios',
        'DATOS_INVALIDOS'
      );
    }
    const hoy = new Date().toISOString().slice(0, 10);
    if (fecha < hoy) {
      return problema(req, res, 400, 'La fecha no puede ser anterior a hoy', 'DATOS_INVALIDOS');
    }
    const direccion = direccionDelCliente(req, direccionId);
    if (!direccion) return noEncontrado(req, res);
    if (!enCobertura(direccion)) return fueraDeCobertura(req, res);

    const costo = costoPorTraslado(direccion);
    res.jsonp({
      direccionId: direccion.id,
      fecha,
      costoPorTraslado: costo,
      costoTotal: Math.round(costo * 2 * 100) / 100,
      recoleccion: VENTANA_RECOGER,
      entrega: VENTANA_ENTREGAR,
    });
  });

  // Crea los dos traslados de una cita (recoger y entregar) y arma la
  // `RecoleccionCita` que devuelve POST /citas.
  // V2-M17.03 y V2-M17.04 · seguimiento del traslado y checklist. Un traslado
  // ajeno (de la cita de otro cliente) responde 404 como inexistente. La ubicacion
  // del chofer solo viaja en en_camino y de_regreso, igual que el backend real.
  const ESTADOS_TRASLADO = [
    'programado',
    'en_camino',
    'recogido',
    'en_taller',
    'de_regreso',
    'entregado',
    'cancelado',
  ];
  const checklists = new Map(); // trasladoId -> checklist
  const NIVELES_GASOLINA = ['vacio', 'un_cuarto', 'medio', 'tres_cuartos', 'lleno'];

  function trasladoDelCliente(req, id) {
    const t = db.get('traslados').find({ id: Number(id) }).value();
    if (!t) return null;
    const cita = db.get('citas').find({ id: t.citaId }).value();
    return cita && cita.clienteId === req.sesion.clienteId ? t : null;
  }

  const comoTraslado = (t) => ({
    id: t.id,
    citaId: t.citaId,
    tipo: t.tipo,
    estado: t.estado,
    costo: t.costo,
    fecha: t.fecha,
    ventanaInicio: t.ventanaInicio,
    ventanaFin: t.ventanaFin,
    ...(['en_camino', 'de_regreso'].includes(t.estado) && t.ubicacionChofer
      ? { ubicacionChofer: t.ubicacionChofer }
      : {}),
  });

  function clienteDeTraslado(t) {
    const cita = db.get('citas').find({ id: t.citaId }).value();
    return cita ? cita.clienteId : null;
  }

  // Cambia el estado, descarta la ubicacion si ya no corresponde y avisa por SSE.
  function cambiarEstadoTraslado(t, estado) {
    const cambios = { estado };
    if (!['en_camino', 'de_regreso'].includes(estado)) cambios.ubicacionChofer = null;
    db.get('traslados').find({ id: t.id }).assign(cambios).write();
    emitirEvento(clienteDeTraslado(t), 'traslado.estado', {
      trasladoId: t.id,
      citaId: t.citaId,
      tipo: t.tipo,
      estado,
    });
  }

  // Cancelar una cita cancela sus traslados que aun no salen.
  function cancelarTrasladosProgramados(cita) {
    db.get('traslados')
      .filter({ citaId: cita.id, estado: 'programado' })
      .value()
      .forEach((t) => cambiarEstadoTraslado(t, 'cancelado'));
  }

  servidor.get(`${BASE}/traslados/:id`, (req, res) => {
    const t = trasladoDelCliente(req, req.params.id);
    if (!t) return noEncontrado(req, res);
    res.jsonp(comoTraslado(t));
  });

  servidor.get(`${BASE}/traslados/:id/checklist`, (req, res) => {
    const t = trasladoDelCliente(req, req.params.id);
    if (!t) return noEncontrado(req, res);
    const checklist = checklists.get(t.id);
    if (!checklist) return noEncontrado(req, res);
    // Las URLs firmadas del backend real duran 15 minutos; aqui la firma es un
    // parametro de relleno que cambia en cada peticion.
    const firma = `firma=${Date.now().toString(36)}`;
    res.jsonp({
      ...checklist,
      fotos: checklist.fotos.map((f) => `${f}?${firma}`),
      ...(checklist.firmaUrl ? { firmaUrl: `${checklist.firmaUrl}?${firma}` } : {}),
    });
  });

  function crearTraslados(cita, direccion) {
    const costo = costoPorTraslado(direccion);
    const ids = db.get('traslados').value().map((t) => t.id);
    let siguiente = ids.length ? Math.max(...ids) + 1 : 1;
    const nuevos = [
      ['recoger', VENTANA_RECOGER],
      ['entregar', VENTANA_ENTREGAR],
    ].map(([tipo, ventana]) => ({
      id: siguiente++,
      citaId: cita.id,
      direccionId: direccion.id,
      tipo,
      estado: 'programado',
      costo,
      fecha: cita.fecha,
      ventanaInicio: ventana.inicio,
      ventanaFin: ventana.fin,
    }));
    nuevos.forEach((t) => db.get('traslados').push(t).write());
    return {
      direccionId: direccion.id,
      costoTotal: Math.round(costo * 2 * 100) / 100,
      traslados: nuevos.map((t) => ({
        id: t.id,
        tipo: t.tipo,
        estado: t.estado,
        costo: t.costo,
        fecha: t.fecha,
        ventanaInicio: t.ventanaInicio,
        ventanaFin: t.ventanaFin,
      })),
    };
  }

  servidor.post('/__mock/traslados/:id/estado', (req, res) => {
    const t = db.get('traslados').find({ id: Number(req.params.id) }).value();
    const { estado } = req.body || {};
    if (!t) return sinContrato(res, 404, 'No existe el traslado');
    if (!ESTADOS_TRASLADO.includes(estado)) return sinContrato(res, 400, 'Estado invalido');
    cambiarEstadoTraslado(t, estado);
    // Al recoger y al entregar el chofer deja su checklist.
    if (estado === 'recogido' || estado === 'entregado') {
      const base = `https://picsum.photos/seed/traslado${t.id}-${estado}`;
      checklists.set(t.id, {
        trasladoId: t.id,
        km: 45200,
        gasolina: 'medio',
        notas: estado === 'recogido' ? 'Rayon leve en la salpicadera derecha.' : null,
        fotos: [1, 2, 3].map((n) => `${base}-${n}/800/600`),
        firmaUrl: `${base}-firma/400/200`,
        registradoEn: new Date().toISOString(),
      });
    }
    res.json(comoTraslado(db.get('traslados').find({ id: t.id }).value()));
  });

  servidor.post('/__mock/traslados/:id/ubicacion', (req, res) => {
    const t = db.get('traslados').find({ id: Number(req.params.id) }).value();
    const { lat, lng } = req.body || {};
    if (!t) return sinContrato(res, 404, 'No existe el traslado');
    if (typeof lat !== 'number' || typeof lng !== 'number') {
      return sinContrato(res, 400, 'lat y lng son numeros');
    }
    const actualizadaEn = new Date().toISOString();
    db.get('traslados').find({ id: t.id }).assign({ ubicacionChofer: { lat, lng, actualizadaEn } }).write();
    // El chofer solo se comparte en en_camino y de_regreso.
    if (['en_camino', 'de_regreso'].includes(t.estado)) {
      emitirEvento(clienteDeTraslado(t), 'traslado.ubicacion', {
        trasladoId: t.id,
        lat,
        lng,
        actualizadaEn,
      });
    }
    res.json({ trasladoId: t.id, lat, lng, actualizadaEn });
  });

  servidor.post('/__mock/traslados/:id/checklist', (req, res) => {
    const t = db.get('traslados').find({ id: Number(req.params.id) }).value();
    const { km, gasolina, notas } = req.body || {};
    if (!t) return sinContrato(res, 404, 'No existe el traslado');
    if (!Number.isInteger(km) || !NIVELES_GASOLINA.includes(gasolina)) {
      return sinContrato(res, 400, 'km entero y gasolina del contrato');
    }
    const base = `https://picsum.photos/seed/traslado${t.id}-manual`;
    checklists.set(t.id, {
      trasladoId: t.id,
      km,
      gasolina,
      notas: notas ?? null,
      fotos: [1, 2].map((n) => `${base}-${n}/800/600`),
      firmaUrl: `${base}-firma/400/200`,
      registradoEn: new Date().toISOString(),
    });
    res.status(201).json(checklists.get(t.id));
  });

  return { direccionDelCliente, enCobertura, fueraDeCobertura, crearTraslados, cancelarTrasladosProgramados };
};
