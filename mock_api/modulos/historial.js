const { BASE, noEncontrado, paginar } = require('../comun/http');
const construirTicketPdf = require('../comun/ticket_pdf');

module.exports = function registrarHistorial(servidor, db, vehiculoDelCliente) {
  // Servicios del vehiculo, el mas reciente primero.
  function serviciosDelVehiculo(vehiculoId) {
    return db
      .get('servicios')
      .filter({ vehiculoId })
      .value()
      .slice()
      .sort((a, b) => b.fecha.localeCompare(a.fecha));
  }

  servidor.get(`${BASE}/vehiculos/:vehiculoId/servicios`, (req, res) => {
    const vehiculo = vehiculoDelCliente(req, req.params.vehiculoId);
    if (!vehiculo) return noEncontrado(req, res);

    // V2-M02.05: filtro opcional por el año del servicio.
    let anio = null;
    if (req.query.anio !== undefined) {
      anio = Number(req.query.anio);
      if (!Number.isInteger(anio) || anio < 1900 || anio > 2100) {
        return problema(req, res, 400, 'anio no es valido', 'DATOS_INVALIDOS');
      }
    }

    // El contrato pide orden cronologico, el mas reciente primero.
    const servicios = serviciosDelVehiculo(vehiculo.id)
      .filter((s) => anio === null || s.fecha.startsWith(`${anio}-`))
      .map((s) => ({
        id: s.id,
        fecha: s.fecha,
        estatus: s.estatus,
        fechaCierre: s.fechaCierre ?? null,
        total: s.total,
      }));

    paginar(req, res, servicios);
  });

  // V2-M02.05: años con servicios, para el filtro del historial.
  servidor.get(`${BASE}/vehiculos/:vehiculoId/servicios/anios`, (req, res) => {
    const vehiculo = vehiculoDelCliente(req, req.params.vehiculoId);
    if (!vehiculo) return noEncontrado(req, res);

    const anios = [...new Set(serviciosDelVehiculo(vehiculo.id).map((s) => Number(s.fecha.slice(0, 4))))];
    res.jsonp(anios.sort((a, b) => b - a));
  });

  // V2-M02.06: el ticket con mano de obra y refacciones. Los precios traen el IVA:
  // el subtotal y el IVA se desglosan del total, como en el backend.
  servidor.get(`${BASE}/servicios/:servicioId`, (req, res) => {
    const servicio = db.get('servicios').find({ id: Number(req.params.servicioId) }).value();
    if (!servicio) return noEncontrado(req, res);

    const vehiculo = vehiculoDelCliente(req, servicio.vehiculoId);
    if (!vehiculo) return noEncontrado(req, res);

    const suma = (renglones) => Math.round(renglones.reduce((t, r) => t + r.importe, 0) * 100) / 100;
    const manoDeObra = servicio.manoDeObra ?? [];
    const refacciones = servicio.refacciones ?? [];
    const subtotal = Math.round((servicio.total / 1.16) * 100) / 100;
    res.jsonp({
      id: servicio.id,
      vehiculoId: servicio.vehiculoId,
      fecha: servicio.fecha,
      kilometraje: servicio.kilometraje ?? 0,
      estatus: servicio.estatus,
      fechaCierre: servicio.fechaCierre ?? null,
      manoDeObra,
      refacciones,
      totalManoDeObra: suma(manoDeObra),
      totalRefacciones: suma(refacciones),
      subtotal,
      iva: Math.round((servicio.total - subtotal) * 100) / 100,
      total: servicio.total,
    });
  });

  servidor.get(`${BASE}/servicios/:servicioId/ticket`, (req, res) => {
    const servicio = db.get('servicios').find({ id: Number(req.params.servicioId) }).value();
    if (!servicio) return noEncontrado(req, res);

    const vehiculo = vehiculoDelCliente(req, servicio.vehiculoId);
    if (!vehiculo) return noEncontrado(req, res);

    const pdf = construirTicketPdf([
      'CareCar - Ticket de servicio (API simulada)',
      '',
      `Orden de servicio: ${servicio.id}`,
      `Fecha: ${servicio.fecha}`,
      `Estatus: ${servicio.estatus}`,
      '',
      `Vehiculo: ${vehiculo.modelo} ${vehiculo.anio}`,
      `VIN: ${vehiculo.vin}`,
      '',
      `Total: $ ${servicio.total.toFixed(2)} MXN`,
    ]);

    res.set('Content-Type', 'application/pdf');
    res.set('Content-Disposition', `inline; filename="ticket-${servicio.id}.pdf"`);
    res.send(pdf);
  });
};
