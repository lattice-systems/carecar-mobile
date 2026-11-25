const { BASE, problema, noEncontrado, paginar } = require('../comun/http');

module.exports = function registrarEstreno(servidor, db) {
  // --- Estreno (V2-M16) -------------------------------------------------------
  // Mismos parametros que el backend (V39): 14.99 %, enganche 10 %, 12 a 60 meses.
  const FINANCIAMIENTO = { tasaAnual: 0.1499, engancheMinimoPct: 0.1, plazos: [12, 24, 36, 48, 60] };
  const LEYENDA_ESTRENO = 'Estimación no vinculante. No incluye seguro, comisión por apertura ni IVA '
    + 'de intereses; tu asesor te da la cotización formal.';
  const solicitudesEstreno = [];

  function cotizarEstreno(req, res, modelo, enganche, plazoMeses) {
    if (!modelo.precioDesde) {
      problema(req, res, 409, 'Este modelo aún no tiene precio publicado; pregúntale a un asesor', 'ESTRENO_SIN_PRECIO');
      return null;
    }
    const minimo = Math.ceil(modelo.precioDesde * FINANCIAMIENTO.engancheMinimoPct);
    if (!FINANCIAMIENTO.plazos.includes(plazoMeses)) {
      problema(req, res, 400, `El plazo debe ser uno de ${FINANCIAMIENTO.plazos.join(', ')}`, 'DATOS_INVALIDOS');
      return null;
    }
    if (typeof enganche !== 'number' || enganche < minimo || enganche >= modelo.precioDesde) {
      problema(req, res, 400, `El enganche debe ser de al menos $${minimo} y menor al precio`, 'DATOS_INVALIDOS');
      return null;
    }
    const financiado = modelo.precioDesde - enganche;
    const r = FINANCIAMIENTO.tasaAnual / 12;
    const mensualidad = Math.round(((financiado * r) / (1 - Math.pow(1 + r, -plazoMeses))) * 100) / 100;
    return {
      precio: modelo.precioDesde,
      enganche,
      montoFinanciado: financiado,
      tasaAnual: FINANCIAMIENTO.tasaAnual,
      plazoMeses,
      mensualidad,
      leyenda: LEYENDA_ESTRENO,
    };
  }

  function modeloActivo(id) {
    return db.get('catalogo').find({ id: Number(id), activo: true }).value();
  }

  servidor.post(`${BASE}/estreno/cotizaciones/calculo`, (req, res) => {
    const { modeloCatalogoId, enganche, plazoMeses } = req.body || {};
    const modelo = modeloActivo(modeloCatalogoId);
    if (!modelo) return noEncontrado(req, res);
    const c = cotizarEstreno(req, res, modelo, enganche, plazoMeses);
    if (c) res.json(c);
    return undefined;
  });

  servidor.post(`${BASE}/estreno/solicitudes`, (req, res) => {
    const b = req.body || {};
    const modelo = modeloActivo(b.modeloCatalogoId);
    if (!modelo) return noEncontrado(req, res);
    if (!['PRUEBA_MANEJO', 'COTIZACION'].includes(b.tipo)) {
      return problema(req, res, 400, 'El tipo debe ser PRUEBA_MANEJO o COTIZACION', 'DATOS_INVALIDOS');
    }
    const abierta = solicitudesEstreno.find((s) => s.clienteId === req.sesion.clienteId
      && s.modeloCatalogoId === modelo.id && s.tipo === b.tipo && s.estado !== 'CERRADA');
    if (abierta) {
      return problema(req, res, 409, 'Ya pediste esto para este modelo; un asesor te contactará', 'ESTRENO_DUPLICADA');
    }
    let cotizacion = null;
    if (b.tipo === 'COTIZACION') {
      cotizacion = cotizarEstreno(req, res, modelo, b.enganche, b.plazoMeses);
      if (!cotizacion) return undefined;
    } else if (!b.preferenciaFecha || !['MANANA', 'TARDE'].includes(b.preferenciaFranja)) {
      return problema(req, res, 400, 'Elige un día a partir de mañana y mañana o tarde', 'DATOS_INVALIDOS');
    }
    const solicitud = {
      id: solicitudesEstreno.length + 1,
      clienteId: req.sesion.clienteId,
      tipo: b.tipo,
      modeloCatalogoId: modelo.id,
      modelo: [modelo.marca, modelo.modelo, modelo.anio, modelo.version].filter(Boolean).join(' '),
      // El simulador asigna vendedor al instante.
      estado: 'EN_ATENCION',
      vendedor: 'Vera Vendedora',
      preferenciaFecha: b.preferenciaFecha ?? null,
      preferenciaFranja: b.preferenciaFranja ?? null,
      cotizacion,
      estimacionTomaCuentaId: b.estimacionTomaCuentaId ?? null,
      creadaEn: new Date().toISOString(),
    };
    solicitudesEstreno.unshift(solicitud);
    const { clienteId, ...publica } = solicitud;
    return res.status(201).json(publica);
  });

  servidor.get(`${BASE}/estreno/solicitudes`, (req, res) => {
    const propias = solicitudesEstreno
      .filter((s) => s.clienteId === req.sesion.clienteId)
      .map(({ clienteId, ...publica }) => publica);
    paginar(req, res, propias);
  });
};
