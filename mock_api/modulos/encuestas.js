const { BASE, noEncontrado, problema } = require('../comun/http');
const semillas = require('../semillas/encuestas.json');

module.exports = function registrarEncuestas(servidor, db) {
  db.defaults(semillas).write();
  const ordenPropia = req => db.get('serviciosCerradosEncuestables')
    .find({ ordenId: Number(req.params.ordenId), clienteId: req.sesion.clienteId }).value();
  const encuesta = orden => db.get('encuestasServicio').find({ ordenId: orden.ordenId });
  const nota = (valor, min, max) => Number.isInteger(valor) && valor >= min && valor <= max;

  servidor.get(`${BASE}/encuestas/pendientes`, (req, res) => {
    res.jsonp(db.get('serviciosCerradosEncuestables').filter({ clienteId: req.sesion.clienteId }).value()
      .filter(orden => {
        const guardada = encuesta(orden).value();
        return !guardada?.respondidaEn && !(Date.parse(guardada?.pospuestaHasta) > Date.now());
      }).map(({ clienteId, ...orden }) => orden));
  });

  servidor.post(`${BASE}/encuestas/:ordenId/posponer`, (req, res) => {
    const orden = ordenPropia(req);
    if (!orden) return noEncontrado(req, res);
    const actual = encuesta(orden);
    if (actual.value()?.respondidaEn) return problema(req, res, 409, 'Encuesta ya respondida');
    const pospuestaHasta = new Date(Date.now() + 86400000).toISOString();
    if (actual.value()) actual.assign({ pospuestaHasta }).write();
    else db.get('encuestasServicio').push({ ordenId: orden.ordenId, pospuestaHasta }).write();
    return res.status(204).end();
  });

  servidor.post(`${BASE}/encuestas/:ordenId/responder`, (req, res) => {
    const orden = ordenPropia(req);
    if (!orden) return noEncontrado(req, res);
    const actual = encuesta(orden);
    if (actual.value()?.respondidaEn) return problema(req, res, 409, 'Encuesta ya respondida');
    const { nps, tiempo, trato, limpieza, asesor, comentario } = req.body || {};
    if (!nota(nps, 0, 10) || ![tiempo, trato, limpieza, asesor].every(valor => nota(valor, 1, 5))
        || (comentario != null && (typeof comentario !== 'string' || comentario.length > 1000))) {
      return problema(req, res, 400, 'Calificaciones o comentario inválidos', 'DATOS_INVALIDOS');
    }
    const respuesta = { nps, tiempo, trato, limpieza, asesor, comentario, respondidaEn: new Date().toISOString() };
    if (actual.value()) actual.assign(respuesta).write();
    else db.get('encuestasServicio').push({ ordenId: orden.ordenId, ...respuesta }).write();
    return res.status(204).end();
  });

  servidor.post(`${BASE}/encuestas/:ordenId/contacto`, (req, res) => {
    const orden = ordenPropia(req);
    if (!orden) return noEncontrado(req, res);
    const actual = encuesta(orden);
    if (!actual.value()?.respondidaEn) return noEncontrado(req, res);
    if (actual.value().nps > 6) return problema(req, res, 400, 'El contacto requiere un NPS de 0 a 6');
    const tareas = db.get('tareasContactoEncuesta');
    if (!tareas.find({ ordenId: orden.ordenId }).value()) {
      tareas.push({ ordenId: orden.ordenId, creadaEn: new Date().toISOString() }).write();
    }
    actual.assign({ pideContacto: true }).write();
    return res.status(204).end();
  });
};
