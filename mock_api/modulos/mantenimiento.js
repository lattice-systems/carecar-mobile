const { BASE, problema, noEncontrado } = require('../comun/http');

module.exports = function registrarMantenimiento(servidor, db, vehiculoDelCliente) {
  // ── mantenimiento ──
  // V2-M05 · plan de mantenimiento por modelo, estado de cada servicio y
  // lecturas de kilometraje del cliente. El backend real cruza el plan con el
  // historial (orden_servicio); aqui el estado sale solo del km vigente:
  //   hecho   = el km vigente ya paso 1,000 km del servicio
  //   vencido = el km vigente ya llego al servicio y aun no esta hecho
  //   proximo = el primero que falta; pendiente = los demas.
  // El km oficial es el del taller (`vehiculo.kilometraje`): una lectura del
  // cliente nunca lo sobrescribe, solo se suma, y no puede ser menor a ninguna.
  // Vehiculos de 2014 o anteriores no tienen plan (200 con servicios vacios).
  db.defaults({ lecturasKm: [] }).write();

  const PASO_SERVICIO_KM = 5000;
  const SERVICIOS_DEL_PLAN = 8;
  const MARGEN_HECHO_KM = 1000;
  const PROMEDIO_KM_DIARIO_POR_OMISION = 35;
  const ANIO_MINIMO_CON_PLAN = 2015;

  function conceptosDelServicio(n) {
    const conceptos = ['Cambio de aceite y filtro', 'Revisión de niveles'];
    if (n % 2 === 0) conceptos.push('Revisión de frenos', 'Rotación de llantas');
    if (n % 4 === 0) conceptos.push('Filtro de aire', 'Bujías');
    return conceptos;
  }

  function serviciosDelPlan() {
    return Array.from({ length: SERVICIOS_DEL_PLAN }, (_, i) => {
      const n = i + 1;
      const km = PASO_SERVICIO_KM * n;
      return {
        id: n,
        nombre: `Servicio de ${km.toLocaleString('en-US')} km`,
        km,
        meses: 6 * n,
        precioEstimado: 1200 + (n % 2 === 0 ? 650 : 0) + (n % 4 === 0 ? 900 : 0),
        conceptos: conceptosDelServicio(n),
      };
    });
  }

  function sumarDias(fecha, dias) {
    const d = new Date(fecha);
    d.setDate(d.getDate() + dias);
    return d.toISOString().slice(0, 10);
  }

  // Lecturas del cliente de un vehiculo, de la mas vieja a la mas nueva.
  function lecturasDelCliente(vehiculoId) {
    return db
      .get('lecturasKm')
      .filter({ vehiculoId })
      .sortBy('id')
      .value();
  }

  function planDeMantenimiento(vehiculo) {
    const hoy = new Date().toISOString().slice(0, 10);
    const lecturas = lecturasDelCliente(vehiculo.id);
    const ultimaDelCliente = lecturas.length ? lecturas[lecturas.length - 1] : null;
    const kmTaller = vehiculo.kilometraje ?? null;

    let kmActual = kmTaller;
    let kmFuente = kmTaller == null ? null : 'taller';
    let kmActualizadoEn = kmTaller == null ? null : (vehiculo.kilometrajeActualizadoEn ?? hoy);
    if (ultimaDelCliente && ultimaDelCliente.km >= (kmTaller ?? 0)) {
      kmActual = ultimaDelCliente.km;
      kmFuente = 'cliente';
      kmActualizadoEn = ultimaDelCliente.registradaEn.slice(0, 10);
    }

    const base = {
      vehiculoId: vehiculo.id,
      kmActual,
      kmActualizadoEn,
      kmFuente,
      promedioKmDiario: null,
      servicios: [],
      proximo: null,
    };
    if (vehiculo.anio < ANIO_MINIMO_CON_PLAN) return base;

    // Promedio diario con las lecturas del cliente; sin historial suficiente se
    // usa un valor por omision.
    let promedio = kmActual == null ? null : PROMEDIO_KM_DIARIO_POR_OMISION;
    if (lecturas.length >= 2) {
      const primera = lecturas[0];
      const ultima = lecturas[lecturas.length - 1];
      const dias = Math.max(
        1,
        Math.round((new Date(ultima.registradaEn) - new Date(primera.registradaEn)) / 86400000)
      );
      promedio = Math.max(1, Math.round((ultima.km - primera.km) / dias));
    }
    base.promedioKmDiario = promedio;

    let yaHayProximo = false;
    base.servicios = serviciosDelPlan().map((s) => {
      let estado = 'pendiente';
      let hechoEn = null;
      if (kmActual != null && s.km + MARGEN_HECHO_KM <= kmActual) {
        estado = 'hecho';
        hechoEn = sumarDias(hoy, -Math.round((kmActual - s.km) / (promedio || 1)));
      } else if (kmActual != null && !yaHayProximo) {
        estado = s.km <= kmActual ? 'vencido' : 'proximo';
        yaHayProximo = true;
      }
      return { ...s, estado, hechoEn };
    });

    const siguiente = base.servicios.find((s) => s.estado === 'vencido' || s.estado === 'proximo');
    if (siguiente && kmActual != null) {
      const faltanKm = siguiente.km - kmActual;
      const faltanDias = Math.max(0, Math.ceil(faltanKm / promedio));
      base.proximo = {
        servicioId: siguiente.id,
        nombre: siguiente.nombre,
        kmObjetivo: siguiente.km,
        fechaEstimada: sumarDias(hoy, faltanDias),
        faltanKm,
        faltanDias,
        motivo: 'km',
      };
    }
    return base;
  }

  servidor.get(`${BASE}/vehiculos/:vehiculoId/mantenimiento`, (req, res) => {
    const vehiculo = vehiculoDelCliente(req, req.params.vehiculoId);
    if (!vehiculo) return noEncontrado(req, res);
    res.jsonp(planDeMantenimiento(vehiculo));
  });

  servidor.post(`${BASE}/vehiculos/:vehiculoId/lecturas-km`, (req, res) => {
    const vehiculo = vehiculoDelCliente(req, req.params.vehiculoId);
    if (!vehiculo) return noEncontrado(req, res);

    const km = req.body ? req.body.km : undefined;
    if (!Number.isInteger(km) || km <= 0) {
      return problema(req, res, 400, 'km debe ser un entero mayor que cero', 'DATOS_INVALIDOS');
    }

    const lecturas = lecturasDelCliente(vehiculo.id);
    const ultimoDelCliente = lecturas.length ? lecturas[lecturas.length - 1].km : 0;
    const ultimoOficial = vehiculo.kilometraje ?? 0;
    if (km < ultimoOficial || km < ultimoDelCliente) {
      return problema(
        req,
        res,
        422,
        'El kilometraje es menor a la ultima lectura registrada',
        'KM_INVALIDO'
      );
    }

    const ids = db.get('lecturasKm').value().map((l) => l.id);
    const lectura = {
      id: ids.length ? Math.max(...ids) + 1 : 1,
      vehiculoId: vehiculo.id,
      km,
      fuente: 'cliente',
      registradaEn: new Date().toISOString(),
    };
    db.get('lecturasKm').push(lectura).write();
    res.status(201).jsonp({
      id: lectura.id,
      km: lectura.km,
      fuente: lectura.fuente,
      registradaEn: lectura.registradaEn,
    });
  });
};
