const { BASE } = require('../comun/http');

module.exports = function registrarEventos(servidor) {
  // V2-M11.04 · Eventos en vivo (SSE). `GET /eventos` deja la conexion abierta y
  // manda `event: <nombre>` + `data: <json>`; el servidor real hace lo mismo con
  // el token de la app. Solo llegan los eventos del cliente que escucha.
  const clientesEventos = new Set(); // { res, clienteId }
  const LATIDO_MS = 25 * 1000;
  const VIDA_CANAL_MS = 30 * 60 * 1000;

  function emitirEvento(clienteId, nombre, datos) {
    for (const c of clientesEventos) {
      if (c.clienteId !== clienteId) continue;
      c.res.write(`event: ${nombre}\ndata: ${JSON.stringify(datos)}\n\n`);
      if (typeof c.res.flush === 'function') c.res.flush();
    }
  }

  servidor.get(`${BASE}/eventos`, (req, res) => {
    res.status(200).set({
      'Content-Type': 'text/event-stream',
      'Cache-Control': 'no-cache',
      Connection: 'keep-alive',
    });
    res.flushHeaders();
    res.write(': conectado\n\n');
    const cliente = { res, clienteId: req.sesion.clienteId };
    clientesEventos.add(cliente);
    const latido = setInterval(() => {
      res.write(': latido\n\n');
      if (typeof res.flush === 'function') res.flush();
    }, LATIDO_MS);
    // Como el servidor real: a los 30 min se cierra para que la app reconecte
    // con un token vigente.
    const vida = setTimeout(() => res.end(), VIDA_CANAL_MS);
    req.on('close', () => {
      clearInterval(latido);
      clearTimeout(vida);
      clientesEventos.delete(cliente);
    });
  });

  return emitirEvento;
};
