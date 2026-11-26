const { BASE, ES_FECHA, problema, noEncontrado, paginar } = require('../comun/http');

module.exports = function registrarValuacion(servidor, db, vehiculoDelCliente, emitirEvento) {
  // ── valuacion formal ──
  // V2-M26 · como el contrato: una valuacion abierta por vehiculo, la oferta
  // vencida y la cita cancelada se calculan al consultar y la inspeccion usa la
  // misma agenda y las mismas reglas de cupo que POST /citas. El ERP esta
  // congelado, asi que la oferta se captura con el emisor de prueba.
  db.defaults({ valuaciones: [], valuacionSemillaEstimaciones: [], valuacionSemillaOfertas: [] }).write();

  const TOMAS = [
    'FRENTE',
    'TRASERA',
    'LATERAL_IZQUIERDO',
    'LATERAL_DERECHO',
    'INTERIOR_DELANTERO',
    'INTERIOR_TRASERO',
    'TABLERO_KM',
    'CAJUELA',
  ];
  const ABIERTAS = ['SOLICITADA', 'CITA_AGENDADA', 'OFERTADA'];
  const DIAS_VIGENCIA = 7;
  const DIAS_PARA_REAGENDAR = 7;
  const TAMANO_MAXIMO = 8 * 1024 * 1024;
  // Como el backend: entre 8 y 20 MB es un 400 y arriba de 20 MB, un 413.
  const TAMANO_DE_CORTE = 20 * 1024 * 1024;
  const MS_POR_DIA = 24 * 60 * 60 * 1000;
  // Hora de la agencia (America/Mexico_City, sin horario de verano).
  const DESFASE_AGENCIA_MS = 6 * 60 * 60 * 1000;
  // PNG de 1x1 para las fotos subidas: el simulador no guarda las imagenes.
  const PNG_DE_PRUEBA = Buffer.from(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==',
    'base64'
  );

  const enLaAgencia = (momento) => new Date(new Date(momento).getTime() - DESFASE_AGENCIA_MS).toISOString();
  const hoy = () => enLaAgencia(Date.now()).slice(0, 10);
  const sumarDias = (dia, n) => new Date(Date.parse(dia) + n * MS_POR_DIA).toISOString().slice(0, 10);
  const siguienteId = (coleccion) => {
    const ids = db.get(coleccion).value().map((x) => x.id);
    return ids.length ? Math.max(...ids) + 1 : 1;
  };

  const comoEstimacion = (e) => {
    const { clienteId, parametroId, ...contrato } = e;
    return contrato;
  };

  // La semilla trae fechas relativas a hoy: estimaciones del March en varios
  // meses para la grafica y una valuacion del Jetta con oferta vigente. Se
  // suman a las colecciones de otros modulos sin editar sus semillas.
  function sembrar() {
    // Las franjas de la semilla de citas ya pasaron: sin otras no habria como
    // probar la inspeccion.
    const franjas = db.get('franjas').value();
    if (!franjas.some((f) => f.fecha > hoy() && f.cupoDisponible > 0)) {
      for (const dias of [2, 3, 4]) {
        db.get('franjas')
          .push({
            id: siguienteId('franjas'),
            fecha: sumarDias(hoy(), dias),
            horaInicio: '09:00',
            horaFin: '10:00',
            cupoDisponible: 2,
          })
          .write();
      }
    }
    for (const { mesesAtras, ...e } of db.get('valuacionSemillaEstimaciones').value()) {
      if (db.get('estimacionesTomaCuenta').find({ id: e.id }).value()) continue;
      const ahora = new Date();
      const dia = mesesAtras === 0 ? ahora.getUTCDate() : 10;
      db.get('estimacionesTomaCuenta')
        .push({
          ...e,
          creadaEn: new Date(Date.UTC(ahora.getUTCFullYear(), ahora.getUTCMonth() - mesesAtras, dia, 18)).toISOString(),
          modeloCatalogoId: null,
          modeloDestino: null,
          precioDestino: null,
        })
        .write();
    }
    for (const s of db.get('valuacionSemillaOfertas').value()) {
      if (db.get('valuaciones').find({ id: s.id }).value()) continue;
      const fecha = sumarDias(hoy(), -2);
      if (!db.get('citas').find({ id: s.citaId }).value()) {
        db.get('citas')
          .push({
            id: s.citaId,
            clienteId: s.clienteId,
            vehiculoId: s.vehiculoId,
            franjaId: null,
            fecha,
            horaInicio: '10:00',
            horaFin: '11:00',
            estado: 'CONFIRMADA',
            motivo: 'valuacion',
          })
          .write();
      }
      db.get('valuaciones')
        .push({
          id: s.id,
          clienteId: s.clienteId,
          estimacionId: s.estimacionId,
          vehiculoId: s.vehiculoId,
          estado: 'OFERTADA',
          creadaEn: new Date(Date.now() - 6 * MS_POR_DIA).toISOString(),
          fotos: [],
          citaId: s.citaId,
          oferta: {
            monto: s.monto,
            vigenciaHasta: sumarDias(hoy(), s.diasVigencia),
            nota: s.nota,
            ofertadaEn: new Date(Date.now() - MS_POR_DIA).toISOString(),
          },
          respondidaEn: null,
          asesor: s.asesor,
        })
        .write();
    }
  }
  sembrar();

  const guardar = (v, cambios) => db.get('valuaciones').find({ id: v.id }).assign(cambios).write();

  // El estado al dia: sin su cita vuelve a SOLICITADA y una oferta cuya
  // vigencia paso es VENCIDA.
  function alDia(v) {
    let cita = v.citaId == null ? null : db.get('citas').find({ id: v.citaId }).value();
    if (v.estado === 'CITA_AGENDADA' && (!cita || cita.estado === 'CANCELADA')) {
      guardar(v, { estado: 'SOLICITADA', citaId: null });
      return { ...v, estado: 'SOLICITADA', citaId: null, cita: null };
    }
    if (cita && cita.estado === 'CANCELADA') cita = null;
    const vencida = v.estado === 'OFERTADA' && v.oferta && v.oferta.vigenciaHasta < hoy();
    return { ...v, estado: vencida ? 'VENCIDA' : v.estado, cita };
  }

  const puedeAgendar = (v) =>
    v.estado === 'SOLICITADA' ||
    (v.estado === 'CITA_AGENDADA' && v.cita && v.cita.fecha < sumarDias(hoy(), -DIAS_PARA_REAGENDAR));

  function comoValuacion(guardada) {
    const v = alDia(guardada);
    const estimacion = db.get('estimacionesTomaCuenta').find({ id: v.estimacionId }).value();
    return {
      id: v.id,
      estado: v.estado,
      creadaEn: v.creadaEn,
      vehiculoId: v.vehiculoId,
      estimacion: comoEstimacion(estimacion),
      fotos: [...v.fotos]
        .sort((a, b) => TOMAS.indexOf(a.toma) - TOMAS.indexOf(b.toma))
        .map((f) => ({
          toma: f.toma,
          url: `/api/v1/archivos/valuacion-fotos/${f.archivoId}?firma=mock`,
          subidaEn: f.subidaEn,
        })),
      puedeAgendar: Boolean(puedeAgendar(v)),
      cita: v.cita
        ? { citaId: v.cita.id, fecha: v.cita.fecha, horaInicio: v.cita.horaInicio, horaFin: v.cita.horaFin }
        : null,
      oferta: v.oferta ?? null,
      respondidaEn: v.respondidaEn ?? null,
      asesor: v.asesor ?? null,
    };
  }

  function valuacionDelCliente(req) {
    const v = db.get('valuaciones').find({ id: Number(req.params.valuacionId) }).value();
    return v && v.clienteId === req.sesion.clienteId ? v : null;
  }

  const conflicto = (req, res, codigo, mensaje) => problema(req, res, 409, mensaje, codigo);
  const datosInvalidos = (req, res, mensaje) => problema(req, res, 400, mensaje, 'DATOS_INVALIDOS');

  servidor.get(`${BASE}/valuaciones`, (req, res) => {
    const propias = db
      .get('valuaciones')
      .filter({ clienteId: req.sesion.clienteId })
      .value()
      .slice()
      .sort((a, b) => b.creadaEn.localeCompare(a.creadaEn) || b.id - a.id)
      .map(comoValuacion);
    paginar(req, res, propias);
  });

  servidor.post(`${BASE}/valuaciones`, (req, res) => {
    const id = (req.body || {}).estimacionTomaCuentaId;
    if (!Number.isInteger(id)) return datosInvalidos(req, res, 'estimacionTomaCuentaId es obligatorio');
    const estimacion = db.get('estimacionesTomaCuenta').find({ id }).value();
    if (!estimacion || estimacion.clienteId !== req.sesion.clienteId) return noEncontrado(req, res);
    if (estimacion.vehiculoId == null) {
      return problema(req, res, 422, 'Esa valuacion se pide en la agencia', 'VALUACION_SIN_VEHICULO');
    }
    if (!vehiculoDelCliente(req, estimacion.vehiculoId)) return noEncontrado(req, res);

    const abierta = db
      .get('valuaciones')
      .filter({ clienteId: req.sesion.clienteId, vehiculoId: estimacion.vehiculoId })
      .value()
      .find((v) => ABIERTAS.includes(alDia(v).estado));
    if (abierta) return res.jsonp(comoValuacion(db.get('valuaciones').find({ id: abierta.id }).value()));

    const nueva = {
      id: siguienteId('valuaciones'),
      clienteId: req.sesion.clienteId,
      estimacionId: estimacion.id,
      vehiculoId: estimacion.vehiculoId,
      estado: 'SOLICITADA',
      creadaEn: new Date().toISOString(),
      fotos: [],
      citaId: null,
      oferta: null,
      respondidaEn: null,
      asesor: null,
    };
    db.get('valuaciones').push(nueva).write();
    res.status(201).jsonp(comoValuacion(nueva));
  });

  servidor.get(`${BASE}/valuaciones/:valuacionId`, (req, res) => {
    const v = valuacionDelCliente(req);
    if (!v) return noEncontrado(req, res);
    res.jsonp(comoValuacion(v));
  });

  // V2-M26.02 · sin multer: del multipart solo se revisa que venga el campo
  // `imagen` con un JPEG o un PNG de hasta 8 MB.
  servidor.post(`${BASE}/valuaciones/:valuacionId/fotos/:toma`, (req, res) => {
    const v = valuacionDelCliente(req);
    if (!v) return noEncontrado(req, res);
    if (!TOMAS.includes(req.params.toma)) return datosInvalidos(req, res, 'La toma no existe');
    if (!['SOLICITADA', 'CITA_AGENDADA'].includes(alDia(v).estado)) {
      return conflicto(req, res, 'VALUACION_CERRADA', 'La valuación ya no admite fotos');
    }
    const partes = [];
    let recibido = 0;
    req.on('data', (parte) => {
      recibido += parte.length;
      if (recibido <= TAMANO_MAXIMO + 4096) partes.push(parte);
    });
    req.on('end', () => {
      const cuerpo = Buffer.concat(partes).toString('latin1');
      const campo = cuerpo.indexOf('name="imagen"');
      const inicio = campo < 0 ? -1 : cuerpo.indexOf('\r\n\r\n', campo) + 4;
      const magia = inicio < 4 ? '' : cuerpo.slice(inicio, inicio + 4);
      const esImagen = magia.startsWith('\xff\xd8') || magia === '\x89PNG';
      if (recibido > TAMANO_DE_CORTE) {
        return problema(req, res, 413, 'El archivo es demasiado grande');
      }
      if (!esImagen || recibido > TAMANO_MAXIMO + 4096) {
        return datosInvalidos(req, res, 'La foto debe ser una imagen JPEG o PNG de hasta 8 MB');
      }
      const archivoIds = db.get('valuaciones').value().flatMap((x) => x.fotos.map((f) => f.archivoId));
      const foto = {
        toma: req.params.toma,
        archivoId: archivoIds.length ? Math.max(...archivoIds) + 1 : 1,
        subidaEn: new Date().toISOString(),
      };
      // Se vuelve a leer: otra toma pudo llegar mientras subia esta.
      const actual = db.get('valuaciones').find({ id: v.id }).value();
      guardar(actual, { fotos: [...actual.fotos.filter((f) => f.toma !== foto.toma), foto] });
      res.jsonp(comoValuacion(db.get('valuaciones').find({ id: v.id }).value()));
    });
  });

  // V2-M26.03 · las mismas reglas de cupo que POST /citas, con motivo valuacion.
  servidor.post(`${BASE}/valuaciones/:valuacionId/cita`, (req, res) => {
    const v = valuacionDelCliente(req);
    if (!v) return noEncontrado(req, res);
    const { franjaId, fecha } = req.body || {};
    if (!Number.isInteger(Number(franjaId)) || !ES_FECHA.test(fecha || '')) {
      return datosInvalidos(req, res, 'Faltan franjaId o fecha (AAAA-MM-DD)');
    }
    if (!puedeAgendar(alDia(v))) {
      return conflicto(req, res, 'VALUACION_NO_AGENDABLE', 'La valuación ya tiene cita o ya no se puede agendar');
    }
    const franja = db.get('franjas').find({ id: Number(franjaId) }).value();
    if (!franja || franja.fecha !== fecha) return noEncontrado(req, res);
    if (franja.cupoDisponible < 1) {
      return conflicto(req, res, 'FRANJA_SIN_CUPO', 'La franja ya no tiene cupo');
    }
    const yaReservada = db
      .get('citas')
      .value()
      .some((c) => c.estado === 'CONFIRMADA' && c.fecha === fecha && c.vehiculoId === v.vehiculoId);
    if (yaReservada) {
      return conflicto(req, res, 'CITA_DUPLICADA', 'Ya tienes una cita para ese vehiculo ese dia');
    }
    const cita = {
      id: siguienteId('citas'),
      clienteId: req.sesion.clienteId,
      vehiculoId: v.vehiculoId,
      franjaId: franja.id,
      fecha,
      horaInicio: franja.horaInicio,
      horaFin: franja.horaFin,
      estado: 'CONFIRMADA',
      motivo: 'valuacion',
    };
    db.get('citas').push(cita).write();
    db.get('franjas').find({ id: franja.id }).assign({ cupoDisponible: franja.cupoDisponible - 1 }).write();
    guardar(v, { estado: 'CITA_AGENDADA', citaId: cita.id });
    const { clienteId, ...cuerpo } = cita;
    res.status(201).jsonp(cuerpo);
  });

  // V2-M26.04 · repetir la misma decision con el mismo monto no cambia nada.
  servidor.post(`${BASE}/valuaciones/:valuacionId/respuesta`, (req, res) => {
    const v = valuacionDelCliente(req);
    if (!v) return noEncontrado(req, res);
    const { aceptada, monto } = req.body || {};
    if (typeof aceptada !== 'boolean' || typeof monto !== 'number') {
      return datosInvalidos(req, res, 'Faltan aceptada o monto');
    }
    const { estado } = alDia(v);
    const mismoMonto = Boolean(v.oferta) && v.oferta.monto === monto;
    const decision = aceptada ? 'ACEPTADA' : 'RECHAZADA';
    if (mismoMonto && estado === decision) return res.jsonp(comoValuacion(v));
    if (estado === 'VENCIDA') return conflicto(req, res, 'OFERTA_VENCIDA', 'La oferta venció');
    if (estado !== 'OFERTADA' || !mismoMonto) {
      return conflicto(req, res, 'OFERTA_NO_DISPONIBLE', 'No hay una oferta que responder con ese monto');
    }
    guardar(v, { estado: decision, respondidaEn: new Date().toISOString() });
    res.jsonp(comoValuacion(db.get('valuaciones').find({ id: v.id }).value()));
  });

  // V2-M26.05 · un punto por mes (hora de la agencia) con la estimacion mas
  // reciente de ese mes. Los meses sin estimacion no se inventan.
  servidor.get(`${BASE}/vehiculos/:vehiculoId/valor-estimado`, (req, res) => {
    const vehiculo = vehiculoDelCliente(req, req.params.vehiculoId);
    if (!vehiculo) return noEncontrado(req, res);
    const meses = req.query.meses === undefined ? 12 : Number(req.query.meses);
    if (!Number.isInteger(meses) || meses < 1 || meses > 36) {
      return datosInvalidos(req, res, 'meses va de 1 a 36');
    }
    const [anio, mes] = hoy().split('-').map(Number);
    const desde = new Date(Date.UTC(anio, mes - meses, 1)).toISOString().slice(0, 7);
    const porMes = new Map();
    const estimaciones = db
      .get('estimacionesTomaCuenta')
      .filter({ clienteId: req.sesion.clienteId, vehiculoId: vehiculo.id })
      .value()
      .slice()
      .sort((a, b) => a.creadaEn.localeCompare(b.creadaEn) || a.id - b.id);
    for (const e of estimaciones) {
      const clave = enLaAgencia(e.creadaEn).slice(0, 7);
      if (clave >= desde) porMes.set(clave, e);
    }
    res.jsonp({
      vehiculoId: vehiculo.id,
      puntos: [...porMes.keys()].sort().map((clave) => {
        const e = porMes.get(clave);
        return {
          mes: clave,
          estimacionTomaCuentaId: e.id,
          creadaEn: e.creadaEn,
          minimo: e.minimo,
          maximo: e.maximo,
          medio: Math.round(((e.minimo + e.maximo) / 2) * 100) / 100,
          km: e.km,
          estado: e.estado,
        };
      }),
    });
  });

  // Fuera de la base y sin token, como la URL firmada del backend.
  servidor.get('/api/v1/archivos/valuacion-fotos/:id', (req, res) => {
    res.set('Content-Type', 'image/png').send(PNG_DE_PRUEBA);
  });

  // ── emisor de prueba (fuera del contrato, sin token) ──

  // V2-M26.04 · ventas captura o renueva la oferta de una valuacion con cita,
  // sin esperar su fecha, y avisa al cliente con `valuacion.oferta` sin monto.
  servidor.post('/__mock/valuaciones/:valuacionId/oferta', (req, res) => {
    const v = db.get('valuaciones').find({ id: Number(req.params.valuacionId) }).value();
    if (!v) return noEncontrado(req, res);
    const { monto, vigenciaHasta = sumarDias(hoy(), DIAS_VIGENCIA), nota = null } = req.body || {};
    if (typeof monto !== 'number' || monto <= 0 || !ES_FECHA.test(vigenciaHasta)) {
      return datosInvalidos(req, res, 'Faltan monto o vigenciaHasta (AAAA-MM-DD)');
    }
    const { estado, cita } = alDia(v);
    if (!cita || ['ACEPTADA', 'RECHAZADA'].includes(estado)) {
      return conflicto(req, res, 'OFERTA_NO_DISPONIBLE', 'Solo se oferta una valuación con cita y sin respuesta');
    }
    const oferta = { monto, vigenciaHasta, nota, ofertadaEn: new Date().toISOString() };
    guardar(v, { estado: 'OFERTADA', oferta, asesor: v.asesor ?? 'Vera Vendedora' });
    emitirEvento(v.clienteId, 'valuacion.oferta', { valuacionId: v.id, vehiculoId: v.vehiculoId, vigenciaHasta });
    res.jsonp(comoValuacion(db.get('valuaciones').find({ id: v.id }).value()));
  });
};
