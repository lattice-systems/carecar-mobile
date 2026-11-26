const { BASE, problema, noEncontrado } = require('../comun/http');

const UUID = /^[\da-f]{8}-[\da-f]{4}-[\da-f]{4}-[\da-f]{4}-[\da-f]{12}$/;
const campos = {
  DISPONIBILIDAD: ['intento'],
  FRANJA: ['intento'],
  CONFIRMADA: ['intento', 'citaId'],
  ERROR_FLUTTER: [],
  ERROR_ASINCRONO: [],
  RENDIMIENTO: ['arranqueMs', 'primeraPantallaMs', 'cuadrosMedidos', 'cuadrosPerdidos'],
};
const entero = (valor, minimo, maximo) => Number.isSafeInteger(valor) && valor >= minimo && valor <= maximo;

module.exports = function registrarAnalitica(servidor, db) {
  servidor.post(`${BASE}/analitica/eventos`, (req, res) => {
    const evento = req.body || {};
    const requeridos = typeof evento.tipo === 'string' && Object.hasOwn(campos, evento.tipo)
      ? campos[evento.tipo] : null;
    const invalidos = () => problema(req, res, 400, 'Propiedades de evento inválidas', 'DATOS_INVALIDOS');
    if (!requeridos || Object.keys(evento).length !== requeridos.length + 1
        || !requeridos.every((campo) => Object.hasOwn(evento, campo))) return invalidos();
    if (requeridos.includes('intento') && (typeof evento.intento !== 'string' || !UUID.test(evento.intento))) {
      return invalidos();
    }
    if (evento.tipo === 'CONFIRMADA') {
      if (!entero(evento.citaId, 1, Number.MAX_SAFE_INTEGER)) return invalidos();
      if (!db.get('citas').find({ id: evento.citaId, clienteId: req.sesion.clienteId }).value()) {
        return noEncontrado(req, res);
      }
    }
    if (evento.tipo === 'RENDIMIENTO' && (!entero(evento.arranqueMs, 0, 600000)
        || !entero(evento.primeraPantallaMs, 0, 600000) || !entero(evento.cuadrosMedidos, 1, 120)
        || !entero(evento.cuadrosPerdidos, 0, 60000))) return invalidos();
    return res.status(204).end();
  });
};
