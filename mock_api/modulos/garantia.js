const { BASE, problema, noEncontrado } = require('../comun/http');

module.exports = function registrarGarantia(servidor, db, vehiculoDelCliente, emitirEvento) {
  // ── garantia y campanas ──
  // V2-M10 · coberturas de garantia por vehiculo y campanas de seguridad
  // (recalls) del fabricante. Igual que el backend: por vencer a 60 dias o a
  // 1 000 km del limite; el consumo es lo usado del tiempo o del km, lo que
  // vaya mas adelante; la fila de una campana para un vehiculo se crea al
  // consultarla y una cita cancelada la vuelve a abrir.
  db.defaults({ garantias: [], campanasSeguridad: [], campanasVehiculo: [] }).write();

  const DIAS_POR_VENCER = 60;
  const KM_POR_VENCER = 1000;
  const MS_POR_DIA = 24 * 60 * 60 * 1000;
  const GRAVEDADES = ['BAJA', 'MEDIA', 'ALTA', 'CRITICA'];
  const ORDEN_ESTADO = { ABIERTA: 0, AGENDADA: 1, ATENDIDA: 2 };
  const ES_FECHA = /^\d{4}-\d{2}-\d{2}$/;

  const hoy = () => new Date().toISOString().slice(0, 10);
  const dias = (desde, hasta) => Math.round((Date.parse(hasta) - Date.parse(desde)) / MS_POR_DIA);
  const acotar = (n) => Math.max(0, Math.min(100, Math.floor(n)));

  // El km mas alto conocido: el del taller o la ultima lectura del cliente.
  function kmActual(vehiculo) {
    const lecturas = db.get('lecturasKm').filter({ vehiculoId: vehiculo.id }).map('km').value() || [];
    const conocidos = [vehiculo.kilometraje, ...lecturas].filter((km) => Number.isInteger(km));
    return conocidos.length ? Math.max(...conocidos) : null;
  }

  function evaluar(g, km, dia) {
    const vencidaPorFecha = dia > g.venceEn;
    const vencidaPorKm = g.kmLimite != null && km != null && km >= g.kmLimite;
    const diasRestantes = Math.max(0, dias(dia, g.venceEn));
    const kmRestantes = g.kmLimite == null || km == null ? null : Math.max(0, g.kmLimite - km);
    const total = dias(g.iniciaEn, g.venceEn);
    const porTiempo = total <= 0 ? (dia < g.iniciaEn ? 0 : 100) : acotar((dias(g.iniciaEn, dia) * 100) / total);
    const porKm = g.kmLimite == null || km == null ? 0 : acotar((km * 100) / g.kmLimite);
    let estado;
    let limite;
    if (vencidaPorFecha || vencidaPorKm) {
      estado = 'VENCIDA';
      limite = vencidaPorKm && !vencidaPorFecha ? 'km' : 'fecha';
    } else {
      const cerca = diasRestantes <= DIAS_POR_VENCER || (kmRestantes != null && kmRestantes <= KM_POR_VENCER);
      estado = cerca ? 'POR_VENCER' : 'VIGENTE';
      limite = porKm > porTiempo ? 'km' : 'fecha';
    }
    return {
      id: g.id,
      componente: g.componente,
      descripcion: g.descripcion ?? null,
      iniciaEn: g.iniciaEn,
      venceEn: g.venceEn,
      kmLimite: g.kmLimite ?? null,
      diasRestantes,
      kmRestantes,
      consumo: Math.max(porTiempo, porKm),
      estado,
      limite,
    };
  }

  function aplica(campana, vehiculo) {
    return (campana.vehiculoIds || []).includes(vehiculo.id);
  }

  // Crea las filas que falten y reabre las que perdieron su cita.
  function sincronizar(vehiculo) {
    const filas = [];
    for (const campana of db.get('campanasSeguridad').value()) {
      if (!aplica(campana, vehiculo)) continue;
      let fila = db.get('campanasVehiculo').find({ campanaId: campana.id, vehiculoId: vehiculo.id }).value();
      if (!fila) {
        fila = { campanaId: campana.id, vehiculoId: vehiculo.id, estado: 'ABIERTA', citaId: null };
        db.get('campanasVehiculo').push(fila).write();
      }
      if (fila.estado === 'AGENDADA') {
        const cita = db.get('citas').find({ id: fila.citaId }).value();
        if (!cita || cita.estado === 'CANCELADA') {
          db.get('campanasVehiculo')
            .find({ campanaId: campana.id, vehiculoId: vehiculo.id })
            .assign({ estado: 'ABIERTA', citaId: null })
            .write();
          fila = { ...fila, estado: 'ABIERTA', citaId: null };
        }
      }
      filas.push({ campana, fila });
    }
    return filas;
  }

  const comoCampana = ({ campana, fila }) => ({
    id: campana.id,
    codigo: campana.codigo,
    titulo: campana.titulo,
    descripcion: campana.descripcion,
    queHacer: campana.queHacer,
    gravedad: campana.gravedad,
    estado: fila.estado,
    citaId: fila.citaId,
    publicadaEn: campana.publicadaEn,
  });

  servidor.get(`${BASE}/vehiculos/:vehiculoId/garantia`, (req, res) => {
    const vehiculo = vehiculoDelCliente(req, req.params.vehiculoId);
    if (!vehiculo) return noEncontrado(req, res);
    const km = kmActual(vehiculo);
    const dia = hoy();
    const coberturas = db
      .get('garantias')
      .filter({ vehiculoId: vehiculo.id })
      .sortBy(['venceEn', 'id'])
      .value()
      .map((g) => evaluar(g, km, dia));
    res.jsonp({ vehiculoId: vehiculo.id, kmActual: km, coberturas });
  });

  servidor.get(`${BASE}/vehiculos/:vehiculoId/campanas`, (req, res) => {
    const vehiculo = vehiculoDelCliente(req, req.params.vehiculoId);
    if (!vehiculo) return noEncontrado(req, res);
    const campanas = sincronizar(vehiculo)
      .sort(
        (a, b) =>
          ORDEN_ESTADO[a.fila.estado] - ORDEN_ESTADO[b.fila.estado] ||
          GRAVEDADES.indexOf(b.campana.gravedad) - GRAVEDADES.indexOf(a.campana.gravedad)
      )
      .map(comoCampana);
    res.jsonp(campanas);
  });

  // V2-M10.03 · agenda la atencion con las mismas reglas que POST /citas y
  // motivo `campana`. 409 CAMPANA_NO_AGENDABLE si ya tiene cita o se atendio.
  servidor.post(`${BASE}/vehiculos/:vehiculoId/campanas/:campanaId/cita`, (req, res) => {
    const vehiculo = vehiculoDelCliente(req, req.params.vehiculoId);
    if (!vehiculo) return noEncontrado(req, res);
    const { franjaId, fecha } = req.body || {};
    if (!Number.isInteger(Number(franjaId)) || !ES_FECHA.test(fecha || '')) {
      return problema(req, res, 400, 'Faltan franjaId o fecha (AAAA-MM-DD)', 'DATOS_INVALIDOS');
    }
    const actual = sincronizar(vehiculo).find(({ campana }) => campana.id === Number(req.params.campanaId));
    if (!actual) return noEncontrado(req, res);
    if (actual.fila.estado !== 'ABIERTA') {
      return problema(req, res, 409, 'La campaña ya está agendada o atendida', 'CAMPANA_NO_AGENDABLE');
    }
    const franja = db.get('franjas').find({ id: Number(franjaId) }).value();
    if (!franja || franja.fecha !== fecha) return noEncontrado(req, res);
    if (franja.cupoDisponible < 1) {
      return problema(req, res, 409, 'La franja ya no tiene cupo', 'FRANJA_SIN_CUPO');
    }
    const yaReservada = db
      .get('citas')
      .value()
      .some((c) => c.estado === 'CONFIRMADA' && c.fecha === fecha && c.vehiculoId === vehiculo.id);
    if (yaReservada) {
      return problema(req, res, 409, 'Ya tienes una cita para ese vehiculo ese dia', 'CITA_DUPLICADA');
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
      motivo: 'campana',
    };
    db.get('citas').push(cita).write();
    db.get('franjas').find({ id: franja.id }).assign({ cupoDisponible: franja.cupoDisponible - 1 }).write();
    db.get('campanasVehiculo')
      .find({ campanaId: actual.campana.id, vehiculoId: vehiculo.id })
      .assign({ estado: 'AGENDADA', citaId: cita.id })
      .write();
    const { clienteId, ...cuerpo } = cita;
    res.status(201).jsonp(cuerpo);
  });

  // ── emisor de prueba (fuera del contrato, sin token) ──

  // V2-M10.04 · publica una campana para los vehiculos indicados y avisa a sus
  // duenos con `campana.nueva`.
  servidor.post('/__mock/campanas', (req, res) => {
    const { codigo, titulo, descripcion, queHacer, gravedad = 'ALTA', vehiculoIds = [] } = req.body || {};
    if (!codigo || !titulo || !GRAVEDADES.includes(gravedad) || !Array.isArray(vehiculoIds)) {
      return problema(req, res, 400, 'Faltan codigo, titulo, gravedad o vehiculoIds', 'DATOS_INVALIDOS');
    }
    const ids = db.get('campanasSeguridad').value().map((c) => c.id);
    const campana = {
      id: ids.length ? Math.max(...ids) + 1 : 1,
      codigo: String(codigo).toUpperCase(),
      titulo,
      descripcion: descripcion || titulo,
      queHacer: queHacer || 'Agenda una revisión en la agencia.',
      gravedad,
      vehiculoIds: vehiculoIds.map(Number),
      publicadaEn: new Date().toISOString(),
    };
    db.get('campanasSeguridad').push(campana).write();
    let avisados = 0;
    for (const vehiculoId of campana.vehiculoIds) {
      const vehiculo = db.get('vehiculos').find({ id: vehiculoId }).value();
      if (!vehiculo) continue;
      avisados++;
      emitirEvento(vehiculo.clienteId, 'campana.nueva', {
        vehiculoId,
        campanaId: campana.id,
        codigo: campana.codigo,
        titulo: campana.titulo,
        gravedad: campana.gravedad,
        critica: campana.gravedad === 'CRITICA',
      });
    }
    res.status(201).jsonp({ id: campana.id, codigo: campana.codigo, vehiculosAfectados: avisados });
  });

  // V2-M10.03 · el taller marca atendida la campana de un vehiculo.
  servidor.post('/__mock/campanas/:campanaId/vehiculos/:vehiculoId/atendida', (req, res) => {
    const filtro = { campanaId: Number(req.params.campanaId), vehiculoId: Number(req.params.vehiculoId) };
    if (!db.get('campanasVehiculo').find(filtro).value()) return noEncontrado(req, res);
    db.get('campanasVehiculo').find(filtro).assign({ estado: 'ATENDIDA' }).write();
    res.status(204).end();
  });

  // V2-M10.05 · manda ya el aviso `garantia.por_vencer` de una cobertura, con
  // el motivo pedido (`dias_60`, `dias_15` o `km_1000`) o el que toque.
  servidor.post('/__mock/garantias/:garantiaId/aviso', (req, res) => {
    const garantia = db.get('garantias').find({ id: Number(req.params.garantiaId) }).value();
    if (!garantia) return noEncontrado(req, res);
    const vehiculo = db.get('vehiculos').find({ id: garantia.vehiculoId }).value();
    const cobertura = evaluar(garantia, kmActual(vehiculo), hoy());
    const motivo =
      (req.body && req.body.motivo) ||
      (cobertura.diasRestantes <= 15
        ? 'dias_15'
        : cobertura.kmRestantes != null && cobertura.kmRestantes <= KM_POR_VENCER
          ? 'km_1000'
          : 'dias_60');
    const datos = {
      vehiculoId: vehiculo.id,
      garantiaId: garantia.id,
      componente: garantia.componente,
      venceEn: garantia.venceEn,
      diasRestantes: cobertura.diasRestantes,
      ...(cobertura.kmRestantes != null ? { kmRestantes: cobertura.kmRestantes } : {}),
      motivo,
    };
    emitirEvento(vehiculo.clienteId, 'garantia.por_vencer', datos);
    res.jsonp(datos);
  });
};
