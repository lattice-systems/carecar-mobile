const { BASE, problema, noEncontrado } = require('../comun/http');

module.exports = function registrarNotificaciones(servidor, db) {
  // ── bandeja y preferencias de avisos ──
  // V2-M06.04 y V2-M06.05 · contrato 1.6.0. El backend todavia no las tiene
  // (`agencia-360-backend` no declara el modulo `notificaciones`), asi que esto
  // es lo que permite construir la app contra el contrato sin esperarlo.
  db.defaults({ notificaciones: [], preferenciasNotificacion: [] }).write();

  const CATEGORIAS = ['TALLER', 'CITAS', 'MANTENIMIENTO', 'DOCUMENTOS', 'PROMOCIONES', 'MENSAJES'];

  // Lo comercial se pide, no se asume: PROMOCIONES nace apagada.
  const PUSH_POR_OMISION = (categoria) => categoria !== 'PROMOCIONES';

  const ES_HORA = /^([01][0-9]|2[0-3]):[0-5][0-9]$/;

  const deCliente = (clienteId) =>
    db
      .get('notificaciones')
      .filter({ clienteId })
      .orderBy(['creadaEn'], ['desc'])
      .value();

  const sinLeer = (clienteId) => deCliente(clienteId).filter((n) => !n.leidaEn).length;

  const paraLaApp = (n) => ({
    id: n.id,
    categoria: CATEGORIAS.includes(n.categoria) ? n.categoria : 'DESCONOCIDA',
    titulo: n.titulo,
    cuerpo: n.cuerpo,
    destino: n.destino ?? null,
    leidaEn: n.leidaEn ?? null,
    creadaEn: n.creadaEn,
  });

  // GET /notificaciones — la bandeja. No se usa `paginar` de `comun/http`
  // porque esta pagina trae `noLeidas`, que es de la cuenta y no de la pagina:
  // es lo que la app pinta en el contador del icono.
  servidor.get(`${BASE}/notificaciones`, (req, res) => {
    const pagina = req.query.pagina === undefined ? 0 : Number(req.query.pagina);
    const tamano = req.query.tamano === undefined ? 20 : Number(req.query.tamano);
    if (!Number.isInteger(pagina) || pagina < 0 || !Number.isInteger(tamano) || tamano < 1 || tamano > 50) {
      return problema(req, res, 400, 'pagina o tamano no son validos', 'DATOS_INVALIDOS');
    }
    const clienteId = req.sesion.clienteId;
    const todo = deCliente(clienteId);
    res.jsonp({
      contenido: todo.slice(pagina * tamano, (pagina + 1) * tamano).map(paraLaApp),
      pagina,
      tamano,
      totalElementos: todo.length,
      totalPaginas: Math.ceil(todo.length / tamano),
      noLeidas: sinLeer(clienteId),
    });
  });

  // POST /notificaciones/leidas — todas de un golpe. Va ANTES de la ruta con
  // parametro: si no, Express tomaria «leidas» como un id.
  servidor.post(`${BASE}/notificaciones/leidas`, (req, res) => {
    const ahora = new Date().toISOString();
    db.get('notificaciones')
      .filter((n) => n.clienteId === req.sesion.clienteId && !n.leidaEn)
      .each((n) => {
        n.leidaEn = ahora;
      })
      .write();
    res.status(204).end();
  });

  // POST /notificaciones/{id}/leida — idempotente: dos veces no mueve `leidaEn`.
  servidor.post(`${BASE}/notificaciones/:notificacionId/leida`, (req, res) => {
    const id = Number(req.params.notificacionId);
    const aviso = db.get('notificaciones').find({ id, clienteId: req.sesion.clienteId }).value();
    // Un aviso ajeno responde 404 y no 403: no se confirma que exista.
    if (!aviso) return noEncontrado(req, res, 'No encontramos ese aviso.');
    if (!aviso.leidaEn) {
      db.get('notificaciones')
        .find({ id })
        .assign({ leidaEn: new Date().toISOString() })
        .write();
    }
    res.status(204).end();
  });

  const preferenciasDe = (clienteId) => {
    const guardado = db.get('preferenciasNotificacion').find({ clienteId }).value();
    // Se guarda lo que la persona ELIGIO, no solo lo que apago. Guardar solo
    // las apagadas hacia imposible prender PROMOCIONES: al no estar en la
    // lista caia otra vez en su valor por omision, que es apagada.
    const elegidas = guardado?.elegidas ?? {};
    return {
      categorias: CATEGORIAS.map((categoria) => ({
        categoria,
        push: categoria in elegidas ? elegidas[categoria] : PUSH_POR_OMISION(categoria),
      })),
      silencioDesde: guardado?.silencioDesde ?? null,
      silencioHasta: guardado?.silencioHasta ?? null,
    };
  };

  // GET /notificaciones/preferencias — siempre TODAS las categorias, tambien
  // las que nadie ha tocado: asi la app no tiene que saber cuales existen ni
  // que se asume cuando falta una.
  servidor.get(`${BASE}/notificaciones/preferencias`, (req, res) => {
    res.jsonp(preferenciasDe(req.sesion.clienteId));
  });

  servidor.put(`${BASE}/notificaciones/preferencias`, (req, res) => {
    const cuerpo = req.body ?? {};
    if (!Array.isArray(cuerpo.categorias)) {
      return problema(req, res, 400, 'categorias es obligatorio', 'DATOS_INVALIDOS');
    }
    for (const c of cuerpo.categorias) {
      if (!CATEGORIAS.includes(c?.categoria) || typeof c?.push !== 'boolean') {
        return problema(req, res, 400, 'Una categoria no es valida', 'DATOS_INVALIDOS');
      }
    }
    const desde = cuerpo.silencioDesde ?? null;
    const hasta = cuerpo.silencioHasta ?? null;
    // Van juntos: uno sin el otro no describe ningun horario.
    if ((desde === null) !== (hasta === null)) {
      return problema(req, res, 400, 'silencioDesde y silencioHasta van juntos', 'DATOS_INVALIDOS');
    }
    if (desde !== null && (!ES_HORA.test(desde) || !ES_HORA.test(hasta))) {
      return problema(req, res, 400, 'El horario silencioso no es una hora valida', 'DATOS_INVALIDOS');
    }

    const clienteId = req.sesion.clienteId;
    const elegidas = Object.fromEntries(cuerpo.categorias.map((c) => [c.categoria, c.push]));
    const fila = { clienteId, elegidas, silencioDesde: desde, silencioHasta: hasta };
    if (db.get('preferenciasNotificacion').find({ clienteId }).value()) {
      db.get('preferenciasNotificacion').find({ clienteId }).assign(fila).write();
    } else {
      db.get('preferenciasNotificacion').push(fila).write();
    }
    res.jsonp(preferenciasDe(clienteId));
  });

  // Lo que hara el servicio de envio del backend (V2-M06.07): respeta la
  // preferencia de la categoria y el horario silencioso. Vive aqui para que la
  // app pueda comprobar que una categoria apagada no llega.
  function enviar(clienteId, categoria, titulo, cuerpo, destino = null) {
    const prefs = preferenciasDe(clienteId);
    const quiere = prefs.categorias.find((c) => c.categoria === categoria)?.push ?? true;
    if (!quiere) return null;
    return guardar(clienteId, categoria, titulo, cuerpo, destino);
  }

  // La bandeja conserva respuestas de servicio aunque el cliente apague push.
  function guardar(clienteId, categoria, titulo, cuerpo, destino, clave) {
    const avisos = db.get('notificaciones');
    if (clave != null) {
      const existente = avisos.find({ clienteId, clave }).value();
      if (existente) return existente;
    }
    const ids = avisos.map('id').value();
    const aviso = {
      id: ids.length ? Math.max(...ids) + 1 : 1,
      clienteId,
      categoria,
      titulo,
      cuerpo,
      destino,
      leidaEn: null,
      creadaEn: new Date().toISOString(),
      ...(clave == null ? {} : { clave }),
    };
    avisos.push(aviso).write();
    return aviso;
  }

  return { enviar, guardar };
};
