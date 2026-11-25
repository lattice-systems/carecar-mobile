const { BASE, problema, noEncontrado } = require('../comun/http');

module.exports = function registrarAsistente(servidor, vehiculoDelCliente) {
  // V2-M24.03 · Asistente (ADR 0007). Sin IA: responde con una cita de ejemplo
  // si la pregunta toca un tema del manual, para que la app avance sin backend.
  const TEMAS_DEL_MANUAL = /aceite|llanta|presi[oó]n|testigo|luz|mantenimiento|servicio|frenos?|bater[ií]a/;
  servidor.post(`${BASE}/asistente/preguntas`, (req, res) => {
    const { vehiculoId, pregunta } = req.body || {};
    if (typeof pregunta !== 'string' || !pregunta.trim() || pregunta.length > 500) {
      return problema(req, res, 400, 'Escribe una pregunta de hasta 500 caracteres', 'DATOS_INVALIDOS');
    }
    const vehiculo = vehiculoDelCliente(req, vehiculoId);
    if (!vehiculo) return noEncontrado(req, res);
    const encontrado = TEMAS_DEL_MANUAL.test(pregunta.toLowerCase());
    res.json({
      consultaId: Date.now(),
      encontrado,
      respuesta: encontrado
        ? 'Respuesta de ejemplo de la API simulada: en el manual de tu auto viene en la página 12.'
        : 'No encontré eso en el manual de tu auto. Puedes preguntarle a tu asesor en la agencia.',
      fuentes: encontrado ? [{ manualId: 1, pagina: 12, titulo: 'Manual, pág. 12' }] : [],
    });
  });

  // V2-M24.05: sin IA ni multer; lee el multipart a mano solo para sacar
  // vehiculoId y responde siempre el mismo testigo rojo con cita a la pag. 12.
  servidor.post(`${BASE}/asistente/testigos`, (req, res) => {
    const partes = [];
    req.on('data', (parte) => partes.push(parte));
    req.on('end', () => {
      const cuerpo = Buffer.concat(partes).toString('latin1');
      const id = /name="vehiculoId"\r\n\r\n(\d+)/.exec(cuerpo);
      const conImagen = /name="imagen"/.test(cuerpo) && cuerpo.length > 200;
      if (!id || !conImagen) {
        return problema(req, res, 400, 'La foto debe ser una imagen JPEG o PNG de hasta 5 MB', 'DATOS_INVALIDOS');
      }
      if (!vehiculoDelCliente(req, Number(id[1]))) return noEncontrado(req, res);
      res.json({
        consultaId: Date.now(),
        reconocido: true,
        testigo: 'Presión de aceite',
        gravedad: 'roja',
        queHacer: 'Detente en un lugar seguro, apaga el motor y revisa el nivel de aceite. No sigas manejando si sigue encendida.',
        fuentes: [{ manualId: 1, pagina: 12, titulo: 'Manual, pág. 12' }],
      });
    });
  });

  // V2-M24.07: la calificacion solo se acepta; el simulador no guarda consultas.
  servidor.post(`${BASE}/asistente/consultas/:consultaId/calificacion`, (req, res) => {
    const { util } = req.body || {};
    if (typeof util !== 'boolean') {
      return problema(req, res, 400, 'Indica si la respuesta te sirvió', 'DATOS_INVALIDOS');
    }
    res.status(204).end();
  });

  // V2-M24.09: misma respuesta que /asistente/preguntas, palabra por palabra.
  servidor.post(`${BASE}/asistente/preguntas/flujo`, (req, res) => {
    const { vehiculoId, pregunta } = req.body || {};
    if (typeof pregunta !== 'string' || !pregunta.trim() || pregunta.length > 500) {
      return problema(req, res, 400, 'Escribe una pregunta de hasta 500 caracteres', 'DATOS_INVALIDOS');
    }
    if (!vehiculoDelCliente(req, vehiculoId)) return noEncontrado(req, res);
    const encontrado = TEMAS_DEL_MANUAL.test(pregunta.toLowerCase());
    const respuesta = encontrado
      ? 'Respuesta de ejemplo de la API simulada: en el manual de tu auto viene en la página 12.'
      : 'No encontré eso en el manual de tu auto. Puedes preguntarle a tu asesor en la agencia.';
    res.writeHead(200, { 'content-type': 'text/event-stream', 'cache-control': 'no-cache' });
    const palabras = respuesta.split(/(?<= )/);
    let i = 0;
    const enviar = () => {
      if (i < palabras.length) {
        res.write(`event:texto\ndata:${JSON.stringify({ texto: palabras[i++] })}\n\n`);
        return setTimeout(enviar, 70);
      }
      res.write(`event:fin\ndata:${JSON.stringify({
        consultaId: Date.now(),
        respuesta,
        encontrado,
        fuentes: encontrado ? [{ manualId: 1, pagina: 12, titulo: 'Manual, pág. 12' }] : [],
      })}\n\n`);
      res.end();
    };
    enviar();
  });
};
