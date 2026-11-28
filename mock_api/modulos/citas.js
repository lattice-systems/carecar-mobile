const crypto = require('node:crypto');
const { BASE, ES_FECHA, problema, noEncontrado, paginar } = require('../comun/http');
const SECRETO_DEV = require('../comun/firma');
const construirTicketPdf = require('../comun/ticket_pdf');

module.exports = function registrarCitas(servidor, db, vehiculoDelCliente, recoleccion, promociones) {
  const {
    direccionDelCliente,
    enCobertura,
    fueraDeCobertura,
    crearTraslados,
    cancelarTrasladosProgramados,
  } = recoleccion;

  servidor.get(`${BASE}/agenda/disponibilidad`, (req, res) => {
    const { desde, hasta } = req.query;
    if (!ES_FECHA.test(desde || '') || !ES_FECHA.test(hasta || '')) {
      return problema(req, res, 400, 'Los parametros desde y hasta son obligatorios (AAAA-MM-DD)');
    }
    if (desde > hasta) {
      return problema(req, res, 400, 'El parametro desde no puede ser posterior a hasta');
    }

    // El contrato dice que solo se devuelven franjas con cupo mayor a cero.
    const franjas = db
      .get('franjas')
      .value()
      .filter((f) => f.fecha >= desde && f.fecha <= hasta && f.cupoDisponible > 0)
      .map((f) => ({
        fecha: f.fecha,
        franjaId: f.id,
        horaInicio: f.horaInicio,
        horaFin: f.horaFin,
        cupoDisponible: f.cupoDisponible,
      }));

    res.jsonp(franjas);
  });

  const comoCita = (c) => ({
    id: c.id,
    vehiculoId: c.vehiculoId,
    franjaId: c.franjaId,
    fecha: c.fecha,
    horaInicio: c.horaInicio,
    horaFin: c.horaFin,
    estado: c.estado,
    ...(c.motivo ? { motivo: c.motivo } : {}),
    ...(c.cupon ? { cupon: c.cupon } : {}),
    // V2-M17.03 · GET /citas trae la recoleccion de cada cita (o nada si no la
    // lleva), con el estado vigente de sus traslados, igual que POST /citas.
    ...recoleccionDeCita(c),
  });

  // `{ recoleccion: RecoleccionCita }` con los traslados de la cita tal como estan
  // ahora, o `{}` si la cita no tiene recoleccion.
  function recoleccionDeCita(cita) {
    const traslados = (db.get('traslados').value() || []).filter((t) => t.citaId === cita.id);
    if (traslados.length === 0) return {};
    return {
      recoleccion: {
        direccionId: traslados[0].direccionId,
        costoTotal: Math.round(traslados.reduce((suma, t) => suma + t.costo, 0) * 100) / 100,
        traslados: traslados.map((t) => ({
          id: t.id,
          tipo: t.tipo,
          estado: t.estado,
          costo: t.costo,
          fecha: t.fecha,
          ventanaInicio: t.ventanaInicio,
          ventanaFin: t.ventanaFin,
        })),
      },
    };
  }

  servidor.get(`${BASE}/citas`, (req, res) => {
    const propias = db.get('citas').filter({ clienteId: req.sesion.clienteId }).value();
    paginar(req, res, propias.map(comoCita));
  });

  servidor.post(`${BASE}/citas`, (req, res) => {
    const { vehiculoId, franjaId, fecha, motivo, recoleccion, promocionId } = req.body || {};
    if (!vehiculoId || !franjaId || !ES_FECHA.test(fecha || '')) {
      return problema(req, res, 400, 'Faltan vehiculoId, franjaId o fecha (AAAA-MM-DD)');
    }

    // V2-M17.02 · `recoleccion: { direccionId }` es opcional. Una direccion ajena
    // o inexistente responde 404 y una fuera de cobertura, 422; en los dos casos
    // no se crea ni la cita ni los traslados.
    let direccionRecoleccion = null;
    if (recoleccion != null) {
      if (!Number.isInteger(Number(recoleccion.direccionId))) {
        return problema(req, res, 400, 'recoleccion.direccionId es obligatorio', 'DATOS_INVALIDOS');
      }
      direccionRecoleccion = direccionDelCliente(req, recoleccion.direccionId);
      if (!direccionRecoleccion) return noEncontrado(req, res);
      if (!enCobertura(direccionRecoleccion)) return fueraDeCobertura(req, res);
    }

    const vehiculo = vehiculoDelCliente(req, vehiculoId);
    if (!vehiculo) return noEncontrado(req, res);

    const franja = db.get('franjas').find({ id: Number(franjaId) }).value();
    if (!franja || franja.fecha !== fecha) return noEncontrado(req, res);

    if (franja.cupoDisponible < 1) {
      return problema(req, res, 409, 'La franja ya no tiene cupo', 'FRANJA_SIN_CUPO');
    }

    // "No se puede reservar dos veces" (APP-3.3): mismo vehiculo, mismo dia,
    // como el backend de V2-M02.08, que le pone el codigo CITA_DUPLICADA.
    const yaReservada = db
      .get('citas')
      .value()
      .some(
        (c) =>
          c.clienteId === req.sesion.clienteId &&
          c.estado === 'CONFIRMADA' &&
          c.fecha === fecha &&
          c.vehiculoId === vehiculo.id
      );
    if (yaReservada) {
      return problema(req, res, 409, 'Ya tienes una cita para ese vehiculo ese dia', 'CITA_DUPLICADA');
    }

    const cupon = promocionId == null ? null : promociones.cupon(promocionId, vehiculo);
    if (promocionId != null && !cupon) {
      return problema(req, res, 400, 'La promoción ya no aplica a ese vehículo', 'DATOS_INVALIDOS');
    }

    const ids = db.get('citas').value().map((c) => c.id);
    const cita = {
      id: ids.length ? Math.max(...ids) + 1 : 1,
      clienteId: req.sesion.clienteId,
      vehiculoId: vehiculo.id,
      franjaId: franja.id,
      fecha,
      horaInicio: franja.horaInicio,
      horaFin: franja.horaFin,
      estado: 'CONFIRMADA',
      // V2-M02.08: para que viene el cliente. Opcional.
      ...(typeof motivo === 'string' && motivo.trim() ? { motivo: motivo.trim() } : {}),
      ...(cupon ? { promocionId, cupon } : {}),
    };

    // La cita descuenta capacidad de la franja (APP-3.3).
    db.get('citas').push(cita).write();
    db.get('franjas')
      .find({ id: franja.id })
      .assign({ cupoDisponible: franja.cupoDisponible - 1 })
      .write();

    const cuerpo = comoCita(cita);
    if (direccionRecoleccion) {
      cuerpo.recoleccion = crearTraslados(cita, direccionRecoleccion);
    }
    if (cupon) promociones.uso(promocionId, cita.clienteId, new Date().toISOString());
    res.status(201).jsonp(cuerpo);
  });

  servidor.post(`${BASE}/citas/:citaId/cancelar`, (req, res) => {
    const cita = db.get('citas').find({ id: Number(req.params.citaId) }).value();
    if (!cita || cita.clienteId !== req.sesion.clienteId) return noEncontrado(req, res);

    if (cita.estado !== 'CONFIRMADA') {
      return problema(req, res, 409, 'La cita ya no esta confirmada', 'CITA_NO_CANCELABLE');
    }

    // PO-4 sigue abierta: no sabemos con cuantas horas de anticipacion se puede
    // cancelar. El mock solo valida que la cita no haya pasado. Cuando el PO de
    // el numero, se agrega la ventana aqui.
    const hoy = new Date().toISOString().slice(0, 10);
    if (cita.fecha < hoy) {
      return problema(req, res, 409, 'Fuera del plazo de cancelacion', 'FUERA_DE_PLAZO');
    }

    db.get('citas').find({ id: cita.id }).assign({ estado: 'CANCELADA' }).write();
    cancelarTrasladosProgramados(cita);
    const franja = db.get('franjas').find({ id: cita.franjaId }).value();
    if (franja) {
      db.get('franjas')
        .find({ id: franja.id })
        .assign({ cupoDisponible: franja.cupoDisponible + 1 })
        .write();
    }

    res.jsonp({ ...comoCita(cita), estado: 'CANCELADA' });
  });

  // V2-M02.13 (propuesto, no esta en el contrato v1): cambia una cita confirmada
  // a otra franja sin cancelarla. La franja anterior se libera y la nueva se
  // ocupa en la misma operacion. 409 FRANJA_SIN_CUPO si la nueva se lleno;
  // 409 CITA_NO_REPROGRAMABLE si la cita ya no esta confirmada; 409
  // FUERA_DE_PLAZO si ya paso (misma regla provisional que cancelar, PO-4).
  servidor.post(`${BASE}/citas/:citaId/reprogramar`, (req, res) => {
    const cita = db.get('citas').find({ id: Number(req.params.citaId) }).value();
    if (!cita || cita.clienteId !== req.sesion.clienteId) return noEncontrado(req, res);

    const { franjaId, fecha } = req.body || {};
    if (!franjaId || !ES_FECHA.test(fecha || '')) {
      return problema(req, res, 400, 'Faltan franjaId o fecha (AAAA-MM-DD)');
    }

    if (cita.estado !== 'CONFIRMADA') {
      return problema(req, res, 409, 'La cita ya no esta confirmada', 'CITA_NO_REPROGRAMABLE');
    }
    const hoy = new Date().toISOString().slice(0, 10);
    if (cita.fecha < hoy) {
      return problema(req, res, 409, 'Fuera del plazo para reprogramar', 'FUERA_DE_PLAZO');
    }

    const nueva = db.get('franjas').find({ id: Number(franjaId) }).value();
    if (!nueva || nueva.fecha !== fecha) return noEncontrado(req, res);

    const anterior = db.get('franjas').find({ id: cita.franjaId }).value();
    if (anterior && anterior.id === nueva.id) return res.jsonp(comoCita(cita));

    if (nueva.cupoDisponible < 1) {
      return problema(req, res, 409, 'La franja ya no tiene cupo', 'FRANJA_SIN_CUPO');
    }

    db.get('franjas').find({ id: nueva.id }).assign({ cupoDisponible: nueva.cupoDisponible - 1 }).write();
    if (anterior) {
      db.get('franjas')
        .find({ id: anterior.id })
        .assign({ cupoDisponible: anterior.cupoDisponible + 1 })
        .write();
    }
    db.get('citas')
      .find({ id: cita.id })
      .assign({ franjaId: nueva.id, fecha: nueva.fecha, horaInicio: nueva.horaInicio, horaFin: nueva.horaFin })
      .write();

    res.jsonp(comoCita(db.get('citas').find({ id: cita.id }).value()));
  });

  // V2-M02.11 · comprobante con QR. El backend real firma el id de la cita y
  // lo pone en el PDF del ticket; aqui el mock simula ambas cosas. El codigo
  // tiene la misma forma que el del backend, `CARECAR-CITA:<citaId>.<firma>`;
  // aqui la firma es HMAC-SHA256 con la llave de desarrollo del mock, asi que
  // no la valida el backend real.
  function codigoDeCita(citaId) {
    const firma = crypto
      .createHmac('sha256', SECRETO_DEV)
      .update(`cita:${citaId}`)
      .digest('hex')
      .slice(0, 16);
    return `CARECAR-CITA:${citaId}.${firma}`;
  }

  function citaDelCliente(req) {
    const cita = db.get('citas').find({ id: Number(req.params.citaId) }).value();
    if (!cita || cita.clienteId !== req.sesion.clienteId) return null;
    return cita;
  }

  servidor.get(`${BASE}/citas/:citaId/comprobante`, (req, res) => {
    const cita = citaDelCliente(req);
    if (!cita) return noEncontrado(req, res);
    if (cita.estado === 'CANCELADA') {
      return problema(req, res, 409, 'La cita esta cancelada', 'CITA_CANCELADA');
    }
    const vehiculo = db.get('vehiculos').find({ id: cita.vehiculoId }).value();
    res.jsonp({
      citaId: cita.id,
      codigo: codigoDeCita(cita.id),
      fecha: cita.fecha,
      horaInicio: cita.horaInicio,
      horaFin: cita.horaFin,
      ...(vehiculo ? { vehiculoNombre: `${vehiculo.modelo} ${vehiculo.anio}` } : {}),
    });
  });

  servidor.get(`${BASE}/citas/:citaId/ticket`, (req, res) => {
    const cita = citaDelCliente(req);
    if (!cita) return noEncontrado(req, res);
    const vehiculo = db.get('vehiculos').find({ id: cita.vehiculoId }).value();

    // El PDF real lleva el QR dibujado; el mock imprime el codigo que el QR
    // contendria.
    const pdf = construirTicketPdf([
      'CareCar - Comprobante de cita (API simulada)',
      '',
      `Folio: ${cita.id}`,
      `Fecha: ${cita.fecha}`,
      `Horario: ${cita.horaInicio} a ${cita.horaFin}`,
      `Estado: ${cita.estado}`,
      ...(vehiculo ? [`Vehiculo: ${vehiculo.modelo} ${vehiculo.anio}`] : []),
      '',
      `Codigo QR: ${codigoDeCita(cita.id)}`,
    ]);

    res.set('Content-Type', 'application/pdf');
    res.set('Content-Disposition', `inline; filename="cita-${cita.id}.pdf"`);
    res.send(pdf);
  });

  // ── citas ──
  // V2-M25.03 · pase de Wallet. El backend real firma el .pkpass (Apple) o arma
  // el JWT de "Guardar en Google Wallet"; aqui el mock devuelve un archivo y un
  // enlace falsos que solo ejercitan el flujo de la app. Una cita cancelada
  // responde 409 CITA_CANCELADA: el pase queda vencido.
  servidor.get(`${BASE}/citas/:citaId/pase`, (req, res) => {
    const cita = citaDelCliente(req);
    if (!cita) return noEncontrado(req, res);
    if (cita.estado === 'CANCELADA') {
      return problema(req, res, 409, 'La cita esta cancelada', 'CITA_CANCELADA');
    }
    const plataforma = req.query.plataforma;
    if (plataforma !== 'apple' && plataforma !== 'google') {
      return problema(req, res, 400, 'Plataforma invalida', 'DATOS_INVALIDOS');
    }
    if (plataforma === 'google') {
      return res.jsonp({
        url: `https://pay.google.com/gp/v/save/mock.${cita.id}.firma-falsa`,
      });
    }
    res.set('Content-Type', 'application/vnd.apple.pkpass');
    res.set('Content-Disposition', `attachment; filename="cita-${cita.id}.pkpass"`);
    res.send(Buffer.from(`PKPASS-FALSO cita ${cita.id} ${codigoDeCita(cita.id)}`));
  });
};
