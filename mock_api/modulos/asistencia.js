const { BASE, problema, noEncontrado, sinContrato } = require('../comun/http');

module.exports = function registrarAsistencia(servidor, vehiculoDelCliente, emitirEvento) {
  // ── asistencia ──
  // V2-M11.01 · pedir ayuda. La solicitud vive en memoria (no en db.json): asi la
  // ubicacion del cliente no queda escrita en disco y reiniciar el mock la borra.
  // Una sola abierta por cliente: otra responde 409 SOLICITUD_ABIERTA.
  const TIPOS_ASISTENCIA = ['llanta', 'bateria', 'choque', 'sin_gasolina', 'otro'];
  const solicitudesAsistencia = new Map(); // clienteId -> solicitud abierta
  const historialAsistencia = new Map(); // id -> { clienteId, solicitud } (tambien las cerradas)
  let ultimoIdAsistencia = 0;

  // Mueve una solicitud a otro estado y avisa. Atendida o cancelada la cierran:
  // se descartan lat y lng (la ubicacion deja de compartirse).
  function cambiarEstadoSolicitud(registro, estado) {
    const { clienteId, solicitud } = registro;
    solicitud.estado = estado;
    if (estado === 'atendida' || estado === 'cancelada') {
      solicitud.lat = null;
      solicitud.lng = null;
      solicitudesAsistencia.delete(clienteId);
    }
    emitirEvento(clienteId, 'asistencia.estado', { solicitudId: solicitud.id, estado });
  }

  servidor.post(`${BASE}/asistencia`, (req, res) => {
    const { vehiculoId, tipo, lat, lng, comentario } = req.body || {};
    const sinLat = lat === undefined || lat === null;
    const sinLng = lng === undefined || lng === null;
    const coordenadasOk =
      sinLat === sinLng &&
      (sinLat ||
        (typeof lat === 'number' && typeof lng === 'number' &&
          Math.abs(lat) <= 90 && Math.abs(lng) <= 180));
    const comentarioOk = comentario == null ||
      (typeof comentario === 'string' && comentario.length <= 500);
    if (!Number.isInteger(vehiculoId) || !TIPOS_ASISTENCIA.includes(tipo) ||
        !coordenadasOk || !comentarioOk) {
      return problema(req, res, 400, 'Datos invalidos', 'DATOS_INVALIDOS');
    }
    if (!vehiculoDelCliente(req, vehiculoId)) return noEncontrado(req, res);
    if (solicitudesAsistencia.has(req.sesion.clienteId)) {
      return problema(req, res, 409, 'Ya tienes una solicitud de ayuda abierta', 'SOLICITUD_ABIERTA');
    }
    const solicitud = {
      id: ++ultimoIdAsistencia,
      vehiculoId,
      tipo,
      lat: sinLat ? null : lat,
      lng: sinLng ? null : lng,
      comentario: comentario ? comentario : null,
      estado: 'recibida',
      creadaEn: new Date().toISOString(),
    };
    solicitudesAsistencia.set(req.sesion.clienteId, solicitud);
    historialAsistencia.set(solicitud.id, { clienteId: req.sesion.clienteId, solicitud });
    res.status(201).jsonp(solicitud);
  });

  // V2-M11.04 · estado de una solicitud. Una ajena responde 404 como inexistente.
  servidor.get(`${BASE}/asistencia/:solicitudId`, (req, res) => {
    const registro = historialAsistencia.get(Number(req.params.solicitudId));
    if (!registro || registro.clienteId !== req.sesion.clienteId) return noEncontrado(req, res);
    res.jsonp(registro.solicitud);
  });

  servidor.get(`${BASE}/asistencia`, (req, res) => {
    const abierta = solicitudesAsistencia.get(req.sesion.clienteId);
    if (req.query.activa === 'true' && !abierta) return res.status(204).end();
    if (!abierta) return res.status(204).end();
    res.jsonp(abierta);
  });

  servidor.post('/__mock/asistencia/:id/estado', (req, res) => {
    const registro = historialAsistencia.get(Number(req.params.id));
    const { estado } = req.body || {};
    if (!registro) return sinContrato(res, 404, 'No existe la solicitud');
    if (!['recibida', 'en_camino', 'atendida', 'cancelada'].includes(estado)) {
      return sinContrato(res, 400, 'Estado invalido');
    }
    cambiarEstadoSolicitud(registro, estado);
    res.json(registro.solicitud);
  });
};
