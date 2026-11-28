const { BASE, noEncontrado } = require('../comun/http');
const semillas = require('../semillas/promociones.json');

module.exports = function registrarPromociones(servidor, db) {
  db.defaults(semillas).write();

  function vigentes() {
    const ahora = Date.now();
    return db.get('promociones').value()
      .filter(p => Date.parse(p.iniciaEn) <= ahora && Date.parse(p.terminaEn) > ahora)
      .sort((a, b) => Date.parse(a.terminaEn) - Date.parse(b.terminaEn) || a.id - b.id);
  }

  function aplica(promocion, vehiculo) {
    const { modelo, anio, kmMin, kmMax, mantenimientoPendiente } = promocion.segmento;
    const km = vehiculo.kilometraje;
    return (modelo == null || modelo.toLowerCase() === vehiculo.modelo?.toLowerCase())
      && (anio == null || anio === vehiculo.anio)
      && (kmMin == null || (Number.isFinite(km) && km >= kmMin))
      && (kmMax == null || (Number.isFinite(km) && km <= kmMax))
      && (mantenimientoPendiente == null || mantenimientoPendiente === (vehiculo.anio >= 2015));
  }

  function paraCliente(clienteId) {
    const autos = db.get('vehiculos').filter({ clienteId }).value();
    return vigentes().map(({ segmento, ...oferta }) => ({
      ...oferta,
      vehiculosIds: autos.filter(auto => aplica({ segmento }, auto)).map(auto => auto.id),
    })).filter(oferta => oferta.vehiculosIds.length > 0);
  }

  servidor.get(`${BASE}/novedades`, (_req, res) => {
    const lista = db.get('novedades').value()
      .filter(n => n.activa && Date.parse(n.publicadaEn) <= Date.now())
      .sort((a, b) => Date.parse(b.publicadaEn) - Date.parse(a.publicadaEn) || b.id - a.id)
      .map(({ activa, ...novedad }) => novedad);
    res.jsonp(lista);
  });

  servidor.get(`${BASE}/promociones`, (req, res) => res.jsonp(paraCliente(req.sesion.clienteId)));

  servidor.post(`${BASE}/promociones/:promocionId/vista`, (req, res) => {
    const promocionId = Number(req.params.promocionId);
    const { clienteId } = req.sesion;
    if (!paraCliente(clienteId).some(p => p.id === promocionId)) return noEncontrado(req, res);
    const vistas = db.get('promocionesVistas');
    if (!vistas.find({ promocionId, clienteId }).value()) {
      vistas.push({ promocionId, clienteId, vistaEn: new Date().toISOString(), usadaEn: null }).write();
    }
    return res.status(204).end();
  });

  return {
    cupon(id, vehiculo) {
      return vigentes().find(p => p.id === id && p.cta === 'agendar' && p.cupon && aplica(p, vehiculo))?.cupon;
    },
    uso(promocionId, clienteId, confirmadaEn) {
      const vista = db.get('promocionesVistas').find({ promocionId, clienteId });
      if (vista.value() && !vista.value().usadaEn) vista.assign({ usadaEn: confirmadaEn }).write();
    },
  };
};
