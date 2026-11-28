const { BASE, problema } = require('../comun/http');
const semilla = require('../semillas/ayuda.json');

module.exports = function registrarAyuda(servidor, db) {
  db.defaults(semilla).write();
  servidor.get(`${BASE}/ayuda/preguntas-frecuentes`, (_req, res) => {
    res.jsonp(db.get('preguntasFrecuentes').filter({ activa: true })
      .sortBy(['tema', 'orden', 'id']).map(({ activa, ...pregunta }) => pregunta).value());
  });

  servidor.post(`${BASE}/ayuda/reportes`, (req, res) => {
    const { descripcion, versionApp, sistema, dispositivo } = req.body || {};
    if (typeof descripcion !== 'string' || descripcion.trim().length < 10 || descripcion.length > 2000
      || typeof versionApp !== 'string' || !versionApp.trim() || versionApp.length > 40
      || typeof sistema !== 'string' || !sistema.trim() || sistema.length > 60
      || typeof dispositivo !== 'string' || !dispositivo.trim() || dispositivo.length > 120) {
      return problema(req, res, 400, 'Los datos del reporte no son validos', 'DATOS_INVALIDOS');
    }
    const cuentaId = req.sesion.clienteId;
    db.get('reportesApp').push({ id: Date.now(), cuentaAppId: cuentaId, descripcion: descripcion.trim(), versionApp: versionApp.trim(), sistema: sistema.trim(), dispositivo: dispositivo.trim(), creadoEn: new Date().toISOString() }).write();
    res.status(204).end();
  });
};
