const crypto = require('node:crypto');
const { BASE, problema } = require('../comun/http');
const SECRETO_DEV = require('../comun/firma');

module.exports = function registrarAcceso(servidor, db) {
  const VIDA_TOKEN_SEGUNDOS = 60 * 60;

  // Reglas de contrasena del contrato (RIC-9): de 8 a 72, con letra y numero.
  const TEXTO_CONTRASENA =
    'La contrasena debe tener de 8 a 72 caracteres, con al menos una letra y un numero';

  function contrasenaValida(valor) {
    const v = String(valor || '');
    return v.length >= 8 && v.length <= 72 && /[A-Za-z]/.test(v) && /[0-9]/.test(v);
  }

  // ---------------------------------------------------------------------------
  // Tokens
  //
  // Se firma un JWT de verdad (HS256) aunque el mock no lo necesite, por dos
  // razones: la app puede leer el claim `exp` mientras RIC-1 siga abierta, y el
  // token tiene la misma forma que el que dara el backend real.
  // ---------------------------------------------------------------------------

  const b64url = (buf) =>
    Buffer.from(buf).toString('base64').replace(/\+/g, '-').replace(/\//g, '_').replace(/=+$/, '');

  function firmarToken(cuenta) {
    const encabezado = b64url(JSON.stringify({ alg: 'HS256', typ: 'JWT' }));
    const ahora = Math.floor(Date.now() / 1000);
    const cuerpo = b64url(
      JSON.stringify({
        sub: String(cuenta.clienteId),
        usuario: cuenta.usuario,
        iat: ahora,
        exp: ahora + VIDA_TOKEN_SEGUNDOS,
      })
    );
    const firma = b64url(
      crypto.createHmac('sha256', SECRETO_DEV).update(`${encabezado}.${cuerpo}`).digest()
    );
    return `${encabezado}.${cuerpo}.${firma}`;
  }

  function leerToken(valor) {
    if (!valor || !valor.startsWith('Bearer ')) return null;
    const partes = valor.slice(7).split('.');
    if (partes.length !== 3) return null;

    const [encabezado, cuerpo, firma] = partes;
    const esperada = b64url(
      crypto.createHmac('sha256', SECRETO_DEV).update(`${encabezado}.${cuerpo}`).digest()
    );
    if (firma !== esperada) return null;

    try {
      const datos = JSON.parse(Buffer.from(cuerpo.replace(/-/g, '+').replace(/_/g, '/'), 'base64'));
      if (datos.exp && datos.exp < Math.floor(Date.now() / 1000)) return null;
      return datos;
    } catch {
      return null;
    }
  }

  // Las cinco rutas publicas del contrato. `refrescar` y `cerrar-sesion` lo son
  // a proposito: deben funcionar aunque el access token ya haya expirado.
  const RUTAS_SIN_TOKEN = [
    `${BASE}/auth/login`,
    `${BASE}/auth/refrescar`,
    `${BASE}/auth/cerrar-sesion`,
    `${BASE}/auth/recuperar-contrasena`,
    `${BASE}/auth/restablecer-contrasena`,
  ];

  // Guardia de sesion. Deja pasar las rutas publicas del contrato y exige token
  // en todo lo demas bajo /api/v1/app.
  servidor.use((req, res, siguiente) => {
    const ruta = req.path;
    if (!ruta.startsWith(BASE)) return siguiente();
    if (RUTAS_SIN_TOKEN.includes(ruta)) return siguiente();

    const sesion = leerToken(req.get('Authorization'));
    if (!sesion) {
      return problema(req, res, 401, 'Sin token o token invalido', 'CREDENCIALES_INVALIDAS');
    }

    const cuenta = db.get('cuentas').find({ clienteId: Number(sesion.sub) }).value();

    // Hueco conocido del contrato (RIC-3): no define que responder cuando la
    // cuenta se desactiva y el cliente ya tenia un token valido. El mock contesta
    // 403 para que la app pueda implementar y probar ese caso desde ahora. Si
    // Ricardo decide otra cosa, se cambia aqui.
    if (!cuenta || !cuenta.activa) {
      return problema(req, res, 403, 'La cuenta esta desactivada', 'CUENTA_DESACTIVADA');
    }

    req.sesion = { clienteId: cuenta.clienteId, cuenta };
    siguiente();
  });

  // ---------------------------------------------------------------------------
  // Acceso · APP-2.1 y APP-2.3
  // ---------------------------------------------------------------------------

  // Intentos fallidos por correo, en memoria. RIC-5: 5 seguidos bloquean 15 min.
  const intentos = new Map();
  const BLOQUEO_MS = 15 * 60 * 1000;
  const MAX_INTENTOS = 5;

  function segundosBloqueado(correo) {
    const registro = intentos.get(correo);
    if (!registro || registro.fallos < MAX_INTENTOS) return 0;
    const restante = registro.hasta - Date.now();
    if (restante <= 0) {
      intentos.delete(correo);
      return 0;
    }
    return Math.ceil(restante / 1000);
  }

  function registrarFallo(correo) {
    const registro = intentos.get(correo) || { fallos: 0, hasta: 0 };
    registro.fallos += 1;
    if (registro.fallos >= MAX_INTENTOS) registro.hasta = Date.now() + BLOQUEO_MS;
    intentos.set(correo, registro);
  }

  // Refresh tokens vivos, en memoria: token -> id de cuenta. RIC-2: duran 30
  // dias y son de un solo uso, asi que refrescar borra el viejo y entrega otro.
  //
  // Vive en memoria y no en db.json a proposito: reiniciar el mock debe dejar
  // todas las sesiones cerradas, igual que reiniciar el backend en desarrollo.
  const refrescos = new Map();
  let contadorDeRefrescos = 0;

  function emitirRefresco(cuenta) {
    contadorDeRefrescos += 1;
    const token = `refresh-${cuenta.id}-${contadorDeRefrescos}`;
    refrescos.set(token, cuenta.id);
    return token;
  }

  /// La respuesta que comparten `/auth/login` y `/auth/refrescar`.
  function respuestaDeSesion(cuenta) {
    return {
      accessToken: firmarToken(cuenta),
      expiresIn: VIDA_TOKEN_SEGUNDOS,
      refreshToken: emitirRefresco(cuenta),
      debeCambiarContrasena: cuenta.debeCambiarContrasena,
    };
  }

  servidor.post(`${BASE}/auth/login`, (req, res) => {
    const { correo, contrasena } = req.body || {};
    if (!correo || !contrasena) {
      return problema(req, res, 400, 'Escribe tu correo y tu contrasena', 'DATOS_INVALIDOS');
    }

    // El backend ignora mayusculas y espacios al inicio y al final (RIC-8).
    const normalizado = String(correo).trim().toLowerCase();

    const espera = segundosBloqueado(normalizado);
    if (espera > 0) {
      res.set('Retry-After', String(espera));
      return problema(
        req,
        res,
        429,
        'Demasiados intentos. Intenta de nuevo mas tarde.',
        'DEMASIADOS_INTENTOS',
      );
    }

    const cuenta = db
      .get('cuentas')
      .find((c) => String(c.correo).toLowerCase() === normalizado)
      .value();

    if (!cuenta || cuenta.contrasena !== contrasena) {
      registrarFallo(normalizado);
      return problema(req, res, 401, 'Correo o contrasena incorrectos', 'CREDENCIALES_INVALIDAS');
    }
    if (!cuenta.activa) {
      return problema(req, res, 403, 'La cuenta esta desactivada', 'CUENTA_DESACTIVADA');
    }

    intentos.delete(normalizado);

    res.jsonp(respuestaDeSesion(cuenta));
  });

  // RIC-2 · Cambia el refresh token por un par nuevo.
  //
  // Es publica a proposito: no pide el access token, para que funcione aunque ya
  // haya expirado. Eso es justo lo que la app necesita para renovar sola.
  servidor.post(`${BASE}/auth/refrescar`, (req, res) => {
    const { refreshToken } = req.body || {};
    if (!refreshToken) {
      return problema(req, res, 400, 'Falta el refreshToken', 'DATOS_INVALIDOS');
    }

    const cuentaId = refrescos.get(refreshToken);
    if (cuentaId === undefined) {
      // Vencido, ya usado o revocado: el contrato no los distingue.
      return problema(req, res, 401, 'La sesion termino. Vuelve a entrar.', 'CREDENCIALES_INVALIDAS');
    }

    // De un solo uso: se gasta aunque la cuenta resulte estar desactivada.
    refrescos.delete(refreshToken);

    const cuenta = db.get('cuentas').find({ id: cuentaId }).value();
    if (!cuenta) {
      return problema(req, res, 401, 'La sesion termino. Vuelve a entrar.', 'CREDENCIALES_INVALIDAS');
    }
    // RIC-3: tambien aqui se revisa que la cuenta siga activa.
    if (!cuenta.activa) {
      return problema(req, res, 403, 'La cuenta esta desactivada', 'CUENTA_DESACTIVADA');
    }

    res.jsonp(respuestaDeSesion(cuenta));
  });

  // RIC-4 · Revoca el refresh token.
  //
  // Tambien publica, y responde 204 aunque el token ya no exista: cerrar sesion
  // dos veces no es un error. El access token sigue valido hasta que expire, que
  // es el riesgo que el contrato acepta a cambio de no consultar una lista negra
  // en cada peticion.
  servidor.post(`${BASE}/auth/cerrar-sesion`, (req, res) => {
    const { refreshToken } = req.body || {};
    if (!refreshToken) {
      return problema(req, res, 400, 'Falta el refreshToken', 'DATOS_INVALIDOS');
    }

    refrescos.delete(refreshToken);
    res.status(204).end();
  });

  servidor.post(`${BASE}/auth/cambiar-contrasena`, (req, res) => {
    const { contrasenaActual, contrasenaNueva } = req.body || {};
    if (!contrasenaActual || !contrasenaNueva) {
      return problema(req, res, 400, 'Faltan la contrasena actual y la nueva', 'DATOS_INVALIDOS');
    }
    if (!contrasenaValida(contrasenaNueva)) {
      return problema(req, res, 400, TEXTO_CONTRASENA, 'DATOS_INVALIDOS');
    }

    const { cuenta } = req.sesion;
    if (cuenta.contrasena !== contrasenaActual) {
      return problema(req, res, 400, 'La contrasena actual no coincide', 'DATOS_INVALIDOS');
    }

    db.get('cuentas')
      .find({ id: cuenta.id })
      .assign({ contrasena: contrasenaNueva, debeCambiarContrasena: false })
      .write();

    res.status(204).end();
  });

  // Responde 202 siempre, exista o no el correo, para no revelar que cuentas hay.
  servidor.post(`${BASE}/auth/recuperar-contrasena`, (req, res) => {
    const { correo } = req.body || {};
    if (!correo) {
      return problema(req, res, 400, 'Escribe tu correo', 'DATOS_INVALIDOS');
    }
    res.status(202).end();
  });

  servidor.post(`${BASE}/auth/restablecer-contrasena`, (req, res) => {
    const { correo, codigo, contrasenaNueva } = req.body || {};
    if (!correo || !codigo || !contrasenaNueva) {
      return problema(
        req,
        res,
        400,
        'Faltan el correo, el codigo y la contrasena nueva',
        'DATOS_INVALIDOS',
      );
    }
    if (!contrasenaValida(contrasenaNueva)) {
      return problema(req, res, 400, TEXTO_CONTRASENA, 'DATOS_INVALIDOS');
    }

    const normalizado = String(correo).trim().toLowerCase();
    const registro = db
      .get('tokensRecuperacion')
      .find(
        (t) =>
          t.token === String(codigo).trim() &&
          String(t.correo).toLowerCase() === normalizado,
      )
      .value();
    const expirado = registro && new Date(registro.expira) < new Date();
    // Invalido, usado o vencido responden igual a proposito (RIC-19): si
    // respondieran distinto se podria averiguar que codigos existen.
    if (!registro || registro.usado || expirado) {
      return problema(req, res, 400, 'El codigo no es valido, ya se uso o vencio', 'CODIGO_INVALIDO');
    }

    const cuenta = db.get('cuentas').find({ correo: registro.correo }).value();
    if (cuenta) {
      db.get('cuentas')
        .find({ id: cuenta.id })
        .assign({ contrasena: contrasenaNueva, debeCambiarContrasena: false })
        .write();
    }
    db.get('tokensRecuperacion').find({ id: registro.id }).assign({ usado: true }).write();

    res.status(204).end();
  });

  // Perfil v1.1: siempre el de la cuenta autenticada, nunca un id del cliente.
  servidor.get(`${BASE}/perfil`, (req, res) => {
    const cuenta = req.sesion.cuenta;
    res.jsonp({ id: cuenta.clienteId, nombre: cuenta.nombre, correo: cuenta.correo });
  });
};
