// API simulada de Agencia360 para la app CareCar · TEC-5
//
// json-server se encarga del almacenamiento y de las colecciones planas
// (/vehiculos, /citas, /catalogo). Todo lo que no es CRUD lo resuelve este
// archivo: el bloque /auth/*, la cancelacion de citas, el ticket en PDF, la
// disponibilidad por rango de fechas y los manuales por modelo y anio.
//
// El contrato que simula es api/agencia360-api-app-v1.yaml.

const fs = require('fs');
const path = require('path');
const crypto = require('crypto');
const zlib = require('zlib');
const jsonServer = require('json-server');

const PUERTO = Number(process.env.PORT) || 3000;
const BASE = '/api/v1/app';
const RUTA_DB = path.join(__dirname, 'db.json');
const RUTA_SEED = path.join(__dirname, 'db.seed.json');

// Secreto solo para firmar tokens de desarrollo. No es un secreto real.
const SECRETO_DEV = 'carecar-mock-api-dev';
const VIDA_TOKEN_SEGUNDOS = 60 * 60;

// db.json es el estado vivo y esta ignorado por git: se crea desde la semilla.
if (!fs.existsSync(RUTA_DB)) {
  fs.copyFileSync(RUTA_SEED, RUTA_DB);
  console.log('db.json creado desde db.seed.json');
}

const servidor = jsonServer.create();
const router = jsonServer.router(RUTA_DB);
const db = router.db;

// ---------------------------------------------------------------------------
// Errores con el formato `Problema` del contrato (el ApiError del backend)
// ---------------------------------------------------------------------------

const TEXTO_ESTADO = {
  400: 'Bad Request',
  401: 'Unauthorized',
  403: 'Forbidden',
  404: 'Not Found',
  409: 'Conflict',
  422: 'Unprocessable Entity',
  429: 'Too Many Requests',
};

// Reglas de contrasena del contrato (RIC-9): de 8 a 72, con letra y numero.
const TEXTO_CONTRASENA =
  'La contrasena debe tener de 8 a 72 caracteres, con al menos una letra y un numero';

function contrasenaValida(valor) {
  const v = String(valor || '');
  return v.length >= 8 && v.length <= 72 && /[A-Za-z]/.test(v) && /[0-9]/.test(v);
}

function problema(req, res, status, mensaje, codigo) {
  const cuerpo = {
    timestamp: new Date().toISOString(),
    status,
    error: TEXTO_ESTADO[status] || 'Error',
    message: mensaje,
    path: req.originalUrl.split('?')[0],
  };
  // `codigo` es opcional en el contrato v1.1 (RIC-15). Se manda cuando se
  // conoce, para que la app decida sin leer el texto.
  if (codigo) cuerpo.codigo = codigo;
  res.status(status).jsonp(cuerpo);
}

// El contrato dice que un recurso ajeno responde 404, no 403: la app no debe
// poder distinguir "no existe" de "no es tuyo".
const noEncontrado = (req, res) =>
  problema(req, res, 404, 'No existe o no pertenece al cliente');

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

// ---------------------------------------------------------------------------
// Middleware comun
// ---------------------------------------------------------------------------

servidor.use(jsonServer.defaults({ logger: true }));
servidor.use(jsonServer.bodyParser);

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

// ---------------------------------------------------------------------------
// Vehiculos · APP-3.1 y ADM-1
// ---------------------------------------------------------------------------

// Perfil v1.1: siempre el de la cuenta autenticada, nunca un id del cliente.
servidor.get(`${BASE}/perfil`, (req, res) => {
  const cuenta = req.sesion.cuenta;
  res.jsonp({ id: cuenta.clienteId, nombre: cuenta.nombre, correo: cuenta.correo });
});

const comoVehiculo = (v) => ({
  id: v.id,
  vin: v.vin,
  modelo: v.modelo,
  anio: v.anio,
  // Extension local opcional. OpenAPI v1.1 permite propiedades adicionales;
  // estos datos no se presuponen disponibles en el backend real.
  marca: v.marca ?? null,
  tipo: v.tipo ?? null,
  version: v.version ?? null,
  color: v.color ?? null,
  placas: v.placas ?? null,
  kilometraje: v.kilometraje ?? null,
  // Simulada hasta V2-T05.06: fecha de cierre de la orden que dejo el km.
  kilometrajeActualizadoEn: v.kilometrajeActualizadoEn ?? null,
});

// Devuelve el vehiculo solo si es del cliente de la sesion.
function vehiculoDelCliente(req, id) {
  const vehiculo = db.get('vehiculos').find({ id: Number(id) }).value();
  if (!vehiculo || vehiculo.clienteId !== req.sesion.clienteId) return null;
  return vehiculo;
}

servidor.get(`${BASE}/vehiculos`, (req, res) => {
  const propios = db.get('vehiculos').filter({ clienteId: req.sesion.clienteId }).value();
  res.jsonp(propios.map(comoVehiculo));
});

servidor.get(`${BASE}/vehiculos/:vehiculoId/manuales`, (req, res) => {
  const vehiculo = vehiculoDelCliente(req, req.params.vehiculoId);
  if (!vehiculo) return noEncontrado(req, res);

  // Los manuales van por modelo y anio, no por vehiculo (ADM-1).
  const manuales = db
    .get('manuales')
    .filter({ modelo: vehiculo.modelo, anio: vehiculo.anio })
    .value();

  res.jsonp(manuales.map((m) => ({ id: m.id, modelo: m.modelo, anio: m.anio, url: m.url })));
});

// ── vehiculos ──
// Ficha tecnica por modelo y ano (V2-M02.04). Simula la tabla
// `ficha_tecnica_modelo`; el backend real la reemplaza sin cambiar el contrato.
const FICHAS_TECNICAS = {
  'Versa:2024': [
    { nombre: 'Motor', especificaciones: [
      { nombre: 'Cilindrada', valor: '1.6 L, 4 cilindros' },
      { nombre: 'Potencia', valor: '118 hp a 6,300 rpm' },
      { nombre: 'Combustible', valor: 'Gasolina' },
    ] },
    { nombre: 'Transmisión', especificaciones: [
      { nombre: 'Caja', valor: 'CVT Xtronic' },
      { nombre: 'Tracción', valor: 'Delantera' },
    ] },
    { nombre: 'Dimensiones', especificaciones: [
      { nombre: 'Carrocería', valor: 'Sedán' },
      { nombre: 'Pasajeros', valor: '5' },
    ] },
  ],
  'Kicks:2023': [
    { nombre: 'Motor', especificaciones: [
      { nombre: 'Cilindrada', valor: '1.6 L, 4 cilindros' },
      { nombre: 'Potencia', valor: '118 hp a 6,300 rpm' },
    ] },
    { nombre: 'Transmisión', especificaciones: [
      { nombre: 'Caja', valor: 'CVT Xtronic' },
      { nombre: 'Tracción', valor: 'Delantera' },
    ] },
  ],
};

servidor.get(`${BASE}/vehiculos/:vehiculoId/ficha-tecnica`, (req, res) => {
  const vehiculo = vehiculoDelCliente(req, req.params.vehiculoId);
  if (!vehiculo) return noEncontrado(req, res);

  // Igual que el backend: sin ficha para ese modelo y ano responde 200 con
  // secciones vacias y la app usa su respaldo local.
  const secciones = FICHAS_TECNICAS[`${vehiculo.modelo}:${vehiculo.anio}`] || [];

  res.jsonp({ vehiculoId: vehiculo.id, modelo: vehiculo.modelo, anio: vehiculo.anio, secciones });
});

// ---------------------------------------------------------------------------
// Servicios y tickets · APP-3.2
// ---------------------------------------------------------------------------

// Arma la respuesta paginada del contrato (PaginaServicios, PaginaCitas).
function paginar(req, res, todo) {
  const pagina = req.query.pagina === undefined ? 0 : Number(req.query.pagina);
  const tamano = req.query.tamano === undefined ? 20 : Number(req.query.tamano);
  if (!Number.isInteger(pagina) || pagina < 0 || !Number.isInteger(tamano) || tamano < 1 || tamano > 100) {
    return problema(req, res, 400, 'pagina o tamano no son validos', 'DATOS_INVALIDOS');
  }
  res.jsonp({
    contenido: todo.slice(pagina * tamano, (pagina + 1) * tamano),
    pagina,
    tamano,
    totalElementos: todo.length,
    totalPaginas: Math.ceil(todo.length / tamano),
  });
}

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

// ---------------------------------------------------------------------------
// Agenda · APP-3.3
// ---------------------------------------------------------------------------

const ES_FECHA = /^\d{4}-\d{2}-\d{2}$/;

servidor.get(`${BASE}/agenda/disponibilidad`, (req, res) => {
  const { desde, hasta } = req.query;
  if (!ES_FECHA.test(desde || '') || !ES_FECHA.test(hasta || '')) {
    return problema(req, res, 400, 'Los parametros desde y hasta son obligatorios (AAAA-MM-DD)');
  }
  if (desde > hasta) {
    return problema(req, res, 400, 'El parametro desde no puede ser posterior a hasta');
  }

  // El contrato dice que solo se devuelven franjas con cupo mayor a cero.
  const franjas = db
    .get('franjas')
    .value()
    .filter((f) => f.fecha >= desde && f.fecha <= hasta && f.cupoDisponible > 0)
    .map((f) => ({
      fecha: f.fecha,
      franjaId: f.id,
      horaInicio: f.horaInicio,
      horaFin: f.horaFin,
      cupoDisponible: f.cupoDisponible,
    }));

  res.jsonp(franjas);
});

const comoCita = (c) => ({
  id: c.id,
  vehiculoId: c.vehiculoId,
  franjaId: c.franjaId,
  fecha: c.fecha,
  horaInicio: c.horaInicio,
  horaFin: c.horaFin,
  estado: c.estado,
  ...(c.motivo ? { motivo: c.motivo } : {}),
});

servidor.get(`${BASE}/citas`, (req, res) => {
  const propias = db.get('citas').filter({ clienteId: req.sesion.clienteId }).value();
  paginar(req, res, propias.map(comoCita));
});

servidor.post(`${BASE}/citas`, (req, res) => {
  const { vehiculoId, franjaId, fecha, motivo, recoleccion } = req.body || {};
  if (!vehiculoId || !franjaId || !ES_FECHA.test(fecha || '')) {
    return problema(req, res, 400, 'Faltan vehiculoId, franjaId o fecha (AAAA-MM-DD)');
  }

  // V2-M17.02 · `recoleccion: { direccionId }` es opcional. Una direccion ajena
  // o inexistente responde 404 y una fuera de cobertura, 422; en los dos casos
  // no se crea ni la cita ni los traslados.
  let direccionRecoleccion = null;
  if (recoleccion != null) {
    if (!Number.isInteger(Number(recoleccion.direccionId))) {
      return problema(req, res, 400, 'recoleccion.direccionId es obligatorio', 'DATOS_INVALIDOS');
    }
    direccionRecoleccion = direccionDelCliente(req, recoleccion.direccionId);
    if (!direccionRecoleccion) return noEncontrado(req, res);
    if (!enCobertura(direccionRecoleccion)) return fueraDeCobertura(req, res);
  }

  const vehiculo = vehiculoDelCliente(req, vehiculoId);
  if (!vehiculo) return noEncontrado(req, res);

  const franja = db.get('franjas').find({ id: Number(franjaId) }).value();
  if (!franja || franja.fecha !== fecha) return noEncontrado(req, res);

  if (franja.cupoDisponible < 1) {
    return problema(req, res, 409, 'La franja ya no tiene cupo', 'FRANJA_SIN_CUPO');
  }

  // "No se puede reservar dos veces" (APP-3.3): mismo vehiculo, mismo dia,
  // como el backend de V2-M02.08, que le pone el codigo CITA_DUPLICADA.
  const yaReservada = db
    .get('citas')
    .value()
    .some(
      (c) =>
        c.clienteId === req.sesion.clienteId &&
        c.estado === 'CONFIRMADA' &&
        c.fecha === fecha &&
        c.vehiculoId === vehiculo.id
    );
  if (yaReservada) {
    return problema(req, res, 409, 'Ya tienes una cita para ese vehiculo ese dia', 'CITA_DUPLICADA');
  }

  const ids = db.get('citas').value().map((c) => c.id);
  const cita = {
    id: ids.length ? Math.max(...ids) + 1 : 1,
    clienteId: req.sesion.clienteId,
    vehiculoId: vehiculo.id,
    franjaId: franja.id,
    fecha,
    horaInicio: franja.horaInicio,
    horaFin: franja.horaFin,
    estado: 'CONFIRMADA',
    // V2-M02.08: para que viene el cliente. Opcional.
    ...(typeof motivo === 'string' && motivo.trim() ? { motivo: motivo.trim() } : {}),
  };

  // La cita descuenta capacidad de la franja (APP-3.3).
  db.get('citas').push(cita).write();
  db.get('franjas')
    .find({ id: franja.id })
    .assign({ cupoDisponible: franja.cupoDisponible - 1 })
    .write();

  const cuerpo = comoCita(cita);
  if (direccionRecoleccion) {
    cuerpo.recoleccion = crearTraslados(cita, direccionRecoleccion);
  }
  res.status(201).jsonp(cuerpo);
});

servidor.post(`${BASE}/citas/:citaId/cancelar`, (req, res) => {
  const cita = db.get('citas').find({ id: Number(req.params.citaId) }).value();
  if (!cita || cita.clienteId !== req.sesion.clienteId) return noEncontrado(req, res);

  if (cita.estado !== 'CONFIRMADA') {
    return problema(req, res, 409, 'La cita ya no esta confirmada', 'CITA_NO_CANCELABLE');
  }

  // PO-4 sigue abierta: no sabemos con cuantas horas de anticipacion se puede
  // cancelar. El mock solo valida que la cita no haya pasado. Cuando el PO de
  // el numero, se agrega la ventana aqui.
  const hoy = new Date().toISOString().slice(0, 10);
  if (cita.fecha < hoy) {
    return problema(req, res, 409, 'Fuera del plazo de cancelacion', 'FUERA_DE_PLAZO');
  }

  db.get('citas').find({ id: cita.id }).assign({ estado: 'CANCELADA' }).write();
  const franja = db.get('franjas').find({ id: cita.franjaId }).value();
  if (franja) {
    db.get('franjas')
      .find({ id: franja.id })
      .assign({ cupoDisponible: franja.cupoDisponible + 1 })
      .write();
  }

  res.jsonp({ ...comoCita(cita), estado: 'CANCELADA' });
});

// V2-M02.13 (propuesto, no esta en el contrato v1): cambia una cita confirmada
// a otra franja sin cancelarla. La franja anterior se libera y la nueva se
// ocupa en la misma operacion. 409 FRANJA_SIN_CUPO si la nueva se lleno;
// 409 CITA_NO_REPROGRAMABLE si la cita ya no esta confirmada; 409
// FUERA_DE_PLAZO si ya paso (misma regla provisional que cancelar, PO-4).
servidor.post(`${BASE}/citas/:citaId/reprogramar`, (req, res) => {
  const cita = db.get('citas').find({ id: Number(req.params.citaId) }).value();
  if (!cita || cita.clienteId !== req.sesion.clienteId) return noEncontrado(req, res);

  const { franjaId, fecha } = req.body || {};
  if (!franjaId || !ES_FECHA.test(fecha || '')) {
    return problema(req, res, 400, 'Faltan franjaId o fecha (AAAA-MM-DD)');
  }

  if (cita.estado !== 'CONFIRMADA') {
    return problema(req, res, 409, 'La cita ya no esta confirmada', 'CITA_NO_REPROGRAMABLE');
  }
  const hoy = new Date().toISOString().slice(0, 10);
  if (cita.fecha < hoy) {
    return problema(req, res, 409, 'Fuera del plazo para reprogramar', 'FUERA_DE_PLAZO');
  }

  const nueva = db.get('franjas').find({ id: Number(franjaId) }).value();
  if (!nueva || nueva.fecha !== fecha) return noEncontrado(req, res);

  const anterior = db.get('franjas').find({ id: cita.franjaId }).value();
  if (anterior && anterior.id === nueva.id) return res.jsonp(comoCita(cita));

  if (nueva.cupoDisponible < 1) {
    return problema(req, res, 409, 'La franja ya no tiene cupo', 'FRANJA_SIN_CUPO');
  }

  db.get('franjas').find({ id: nueva.id }).assign({ cupoDisponible: nueva.cupoDisponible - 1 }).write();
  if (anterior) {
    db.get('franjas')
      .find({ id: anterior.id })
      .assign({ cupoDisponible: anterior.cupoDisponible + 1 })
      .write();
  }
  db.get('citas')
    .find({ id: cita.id })
    .assign({ franjaId: nueva.id, fecha: nueva.fecha, horaInicio: nueva.horaInicio, horaFin: nueva.horaFin })
    .write();

  res.jsonp(comoCita(db.get('citas').find({ id: cita.id }).value()));
});

// V2-M02.11 · comprobante con QR. El backend real firma el id de la cita y
// lo pone en el PDF del ticket; aqui el mock simula ambas cosas. El codigo
// tiene la misma forma que el del backend, `CARECAR-CITA:<citaId>.<firma>`;
// aqui la firma es HMAC-SHA256 con la llave de desarrollo del mock, asi que
// no la valida el backend real.
function codigoDeCita(citaId) {
  const firma = crypto
    .createHmac('sha256', SECRETO_DEV)
    .update(`cita:${citaId}`)
    .digest('hex')
    .slice(0, 16);
  return `CARECAR-CITA:${citaId}.${firma}`;
}

function citaDelCliente(req) {
  const cita = db.get('citas').find({ id: Number(req.params.citaId) }).value();
  if (!cita || cita.clienteId !== req.sesion.clienteId) return null;
  return cita;
}

servidor.get(`${BASE}/citas/:citaId/comprobante`, (req, res) => {
  const cita = citaDelCliente(req);
  if (!cita) return noEncontrado(req, res);
  if (cita.estado === 'CANCELADA') {
    return problema(req, res, 409, 'La cita esta cancelada', 'CITA_CANCELADA');
  }
  const vehiculo = db.get('vehiculos').find({ id: cita.vehiculoId }).value();
  res.jsonp({
    citaId: cita.id,
    codigo: codigoDeCita(cita.id),
    fecha: cita.fecha,
    horaInicio: cita.horaInicio,
    horaFin: cita.horaFin,
    ...(vehiculo ? { vehiculoNombre: `${vehiculo.modelo} ${vehiculo.anio}` } : {}),
  });
});

servidor.get(`${BASE}/citas/:citaId/ticket`, (req, res) => {
  const cita = citaDelCliente(req);
  if (!cita) return noEncontrado(req, res);
  const vehiculo = db.get('vehiculos').find({ id: cita.vehiculoId }).value();

  // El PDF real lleva el QR dibujado; el mock imprime el codigo que el QR
  // contendria.
  const pdf = construirTicketPdf([
    'CareCar - Comprobante de cita (API simulada)',
    '',
    `Folio: ${cita.id}`,
    `Fecha: ${cita.fecha}`,
    `Horario: ${cita.horaInicio} a ${cita.horaFin}`,
    `Estado: ${cita.estado}`,
    ...(vehiculo ? [`Vehiculo: ${vehiculo.modelo} ${vehiculo.anio}`] : []),
    '',
    `Codigo QR: ${codigoDeCita(cita.id)}`,
  ]);

  res.set('Content-Type', 'application/pdf');
  res.set('Content-Disposition', `inline; filename="cita-${cita.id}.pdf"`);
  res.send(pdf);
});

// ── asistencia ──
// V2-M11.01 · pedir ayuda. La solicitud vive en memoria (no en db.json): asi la
// ubicacion del cliente no queda escrita en disco y reiniciar el mock la borra.
// Una sola abierta por cliente: otra responde 409 SOLICITUD_ABIERTA.
const TIPOS_ASISTENCIA = ['llanta', 'bateria', 'choque', 'sin_gasolina', 'otro'];
const solicitudesAsistencia = new Map(); // clienteId -> solicitud abierta
let ultimoIdAsistencia = 0;

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
  res.status(201).jsonp(solicitud);
});

servidor.get(`${BASE}/asistencia`, (req, res) => {
  const abierta = solicitudesAsistencia.get(req.sesion.clienteId);
  if (req.query.activa === 'true' && !abierta) return res.status(204).end();
  if (!abierta) return res.status(204).end();
  res.jsonp(abierta);
});

// ── citas ──
// V2-M25.03 · pase de Wallet. El backend real firma el .pkpass (Apple) o arma
// el JWT de "Guardar en Google Wallet"; aqui el mock devuelve un archivo y un
// enlace falsos que solo ejercitan el flujo de la app. Una cita cancelada
// responde 409 CITA_CANCELADA: el pase queda vencido.
servidor.get(`${BASE}/citas/:citaId/pase`, (req, res) => {
  const cita = citaDelCliente(req);
  if (!cita) return noEncontrado(req, res);
  if (cita.estado === 'CANCELADA') {
    return problema(req, res, 409, 'La cita esta cancelada', 'CITA_CANCELADA');
  }
  const plataforma = req.query.plataforma;
  if (plataforma !== 'apple' && plataforma !== 'google') {
    return problema(req, res, 400, 'Plataforma invalida', 'DATOS_INVALIDOS');
  }
  if (plataforma === 'google') {
    return res.jsonp({
      url: `https://pay.google.com/gp/v/save/mock.${cita.id}.firma-falsa`,
    });
  }
  res.set('Content-Type', 'application/vnd.apple.pkpass');
  res.set('Content-Disposition', `attachment; filename="cita-${cita.id}.pkpass"`);
  res.send(Buffer.from(`PKPASS-FALSO cita ${cita.id} ${codigoDeCita(cita.id)}`));
});

// ── recoleccion ──
// V2-M17.01 y V2-M17.02 · direcciones guardadas, cotizacion y traslados.
// El backend real decide la cobertura con la geometria de la agencia; aqui es
// un circulo de 40 km alrededor del centro de la Ciudad de Mexico, suficiente
// para probar el 422 desde la app (un pin en Monterrey queda fuera).
db.defaults({ direcciones: [], traslados: [] }).write();

const CENTRO_COBERTURA = { lat: 19.4326, lng: -99.1332 };
const RADIO_COBERTURA_KM = 40;
const TARIFA_BASE = 80;
const TARIFA_POR_KM = 12;
const VENTANA_RECOGER = { inicio: '07:00', fin: '09:00' };
const VENTANA_ENTREGAR = { inicio: '17:00', fin: '19:00' };

function distanciaKm(a, b) {
  const rad = (g) => (g * Math.PI) / 180;
  const dLat = rad(b.lat - a.lat);
  const dLng = rad(b.lng - a.lng);
  const h =
    Math.sin(dLat / 2) ** 2 +
    Math.cos(rad(a.lat)) * Math.cos(rad(b.lat)) * Math.sin(dLng / 2) ** 2;
  return 2 * 6371 * Math.asin(Math.sqrt(h));
}

function enCobertura(direccion) {
  return distanciaKm(CENTRO_COBERTURA, direccion) <= RADIO_COBERTURA_KM;
}

const costoPorTraslado = (direccion) =>
  Math.round((TARIFA_BASE + TARIFA_POR_KM * distanciaKm(CENTRO_COBERTURA, direccion)) * 100) / 100;

const fueraDeCobertura = (req, res) =>
  problema(
    req,
    res,
    422,
    'La direccion queda fuera de la zona de cobertura',
    'FUERA_DE_COBERTURA'
  );

function direccionDelCliente(req, id) {
  const d = db.get('direcciones').find({ id: Number(id) }).value();
  return d && d.clienteId === req.sesion.clienteId ? d : null;
}

const comoDireccion = (d) => ({
  id: d.id,
  alias: d.alias,
  calle: d.calle,
  colonia: d.colonia,
  cp: d.cp,
  ciudad: d.ciudad,
  lat: d.lat,
  lng: d.lng,
});

// Valida el cuerpo de NuevaDireccion con las mismas reglas del contrato.
function validarDireccion(cuerpo) {
  const c = cuerpo || {};
  const texto = (v, max) => typeof v === 'string' && v.trim().length > 0 && v.trim().length <= max;
  const numero = (v, min, max) => typeof v === 'number' && v >= min && v <= max;
  if (
    !texto(c.alias, 40) ||
    !texto(c.calle, 120) ||
    !texto(c.colonia, 80) ||
    !/^[0-9]{5}$/.test(String(c.cp || '')) ||
    !texto(c.ciudad, 80) ||
    !numero(c.lat, -90, 90) ||
    !numero(c.lng, -180, 180)
  ) {
    return null;
  }
  return {
    alias: c.alias.trim(),
    calle: c.calle.trim(),
    colonia: c.colonia.trim(),
    cp: c.cp,
    ciudad: c.ciudad.trim(),
    lat: c.lat,
    lng: c.lng,
  };
}

servidor.get(`${BASE}/direcciones`, (req, res) => {
  const propias = db.get('direcciones').filter({ clienteId: req.sesion.clienteId }).value();
  res.jsonp(propias.map(comoDireccion));
});

servidor.post(`${BASE}/direcciones`, (req, res) => {
  const datos = validarDireccion(req.body);
  if (!datos) return problema(req, res, 400, 'Datos de direccion invalidos', 'DATOS_INVALIDOS');
  if (!enCobertura(datos)) return fueraDeCobertura(req, res);

  const ids = db.get('direcciones').value().map((d) => d.id);
  const direccion = {
    id: ids.length ? Math.max(...ids) + 1 : 1,
    clienteId: req.sesion.clienteId,
    ...datos,
  };
  db.get('direcciones').push(direccion).write();
  res.status(201).jsonp(comoDireccion(direccion));
});

servidor.put(`${BASE}/direcciones/:direccionId`, (req, res) => {
  const existente = direccionDelCliente(req, req.params.direccionId);
  if (!existente) return noEncontrado(req, res);
  const datos = validarDireccion(req.body);
  if (!datos) return problema(req, res, 400, 'Datos de direccion invalidos', 'DATOS_INVALIDOS');
  if (!enCobertura(datos)) return fueraDeCobertura(req, res);

  db.get('direcciones').find({ id: existente.id }).assign(datos).write();
  res.jsonp(comoDireccion(db.get('direcciones').find({ id: existente.id }).value()));
});

servidor.delete(`${BASE}/direcciones/:direccionId`, (req, res) => {
  const existente = direccionDelCliente(req, req.params.direccionId);
  if (!existente) return noEncontrado(req, res);
  const enUso = db.get('traslados').value().some((t) => t.direccionId === existente.id);
  if (enUso) {
    return problema(
      req,
      res,
      409,
      'La direccion ya tiene traslados y no se puede borrar',
      'DIRECCION_EN_USO'
    );
  }
  db.get('direcciones').remove({ id: existente.id }).write();
  res.status(204).end();
});

servidor.get(`${BASE}/recoleccion/cotizacion`, (req, res) => {
  const { direccionId, fecha } = req.query;
  if (!/^\d+$/.test(direccionId || '') || !ES_FECHA.test(fecha || '')) {
    return problema(
      req,
      res,
      400,
      'direccionId y fecha (AAAA-MM-DD) son obligatorios',
      'DATOS_INVALIDOS'
    );
  }
  const hoy = new Date().toISOString().slice(0, 10);
  if (fecha < hoy) {
    return problema(req, res, 400, 'La fecha no puede ser anterior a hoy', 'DATOS_INVALIDOS');
  }
  const direccion = direccionDelCliente(req, direccionId);
  if (!direccion) return noEncontrado(req, res);
  if (!enCobertura(direccion)) return fueraDeCobertura(req, res);

  const costo = costoPorTraslado(direccion);
  res.jsonp({
    direccionId: direccion.id,
    fecha,
    costoPorTraslado: costo,
    costoTotal: Math.round(costo * 2 * 100) / 100,
    recoleccion: VENTANA_RECOGER,
    entrega: VENTANA_ENTREGAR,
  });
});

// Crea los dos traslados de una cita (recoger y entregar) y arma la
// `RecoleccionCita` que devuelve POST /citas.
function crearTraslados(cita, direccion) {
  const costo = costoPorTraslado(direccion);
  const ids = db.get('traslados').value().map((t) => t.id);
  let siguiente = ids.length ? Math.max(...ids) + 1 : 1;
  const nuevos = [
    ['recoger', VENTANA_RECOGER],
    ['entregar', VENTANA_ENTREGAR],
  ].map(([tipo, ventana]) => ({
    id: siguiente++,
    citaId: cita.id,
    direccionId: direccion.id,
    tipo,
    estado: 'programado',
    costo,
    fecha: cita.fecha,
    ventanaInicio: ventana.inicio,
    ventanaFin: ventana.fin,
  }));
  nuevos.forEach((t) => db.get('traslados').push(t).write());
  return {
    direccionId: direccion.id,
    costoTotal: Math.round(costo * 2 * 100) / 100,
    traslados: nuevos.map((t) => ({
      id: t.id,
      tipo: t.tipo,
      estado: t.estado,
      costo: t.costo,
      fecha: t.fecha,
      ventanaInicio: t.ventanaInicio,
      ventanaFin: t.ventanaFin,
    })),
  };
}

// ---------------------------------------------------------------------------
// Catalogo · APP-4.1 (fuera del MVP, pero el contrato lo incluye)
// ---------------------------------------------------------------------------

function comoModelo(m) {
  return {
    id: m.id,
    marca: m.marca,
    modelo: m.modelo,
    anio: m.anio,
    version: m.version ?? null,
    precioDesde: m.precioDesde ?? null,
    imagenUrl: m.imagenUrl ?? null,
    descripcion: m.descripcion ?? null,
    activo: m.activo,
  };
}

servidor.get(`${BASE}/catalogo`, (req, res) => {
  const activos = db.get('catalogo').filter({ activo: true }).value();
  res.jsonp(activos.map(comoModelo));
});

// V2-M03.02 · Detalle de un modelo. Un modelo retirado o inexistente responde
// 404, igual que el backend. Las versiones son los modelos activos de la misma
// marca, modelo y anio, de la mas barata a la mas cara (sin precio al final).
servidor.get(`${BASE}/catalogo/:modeloId`, (req, res) => {
  const id = Number(req.params.modeloId);
  const modelo = db.get('catalogo').find({ id, activo: true }).value();
  if (!Number.isInteger(id) || !modelo) {
    return problema(req, res, 404, 'No existe el modelo');
  }

  const ordenadoPor = (campo) => (a, b) => a[campo] - b[campo];
  const imagenes = db
    .get('catalogoImagenes')
    .filter({ modeloId: id })
    .value()
    .sort(ordenadoPor('orden'))
    .map(({ id: imagenId, url, color, descripcion, orden }) => ({
      id: imagenId,
      url,
      color: color ?? null,
      descripcion: descripcion ?? null,
      orden,
    }));
  const especificaciones = db
    .get('catalogoEspecificaciones')
    .filter({ modeloId: id })
    .value()
    .sort(ordenadoPor('orden'))
    .map(({ etiqueta, valor, orden }) => ({ etiqueta, valor, orden }));
  const versiones = db
    .get('catalogo')
    .filter({
      activo: true,
      marca: modelo.marca,
      modelo: modelo.modelo,
      anio: modelo.anio,
    })
    .value()
    .sort(
      (a, b) =>
        (a.precioDesde ?? Infinity) - (b.precioDesde ?? Infinity) || a.id - b.id,
    )
    .map((v) => ({
      id: v.id,
      nombre: v.version ?? v.modelo,
      precioDesde: v.precioDesde ?? null,
    }));

  res.jsonp({ ...comoModelo(modelo), imagenes, versiones, especificaciones });
});

// ---------------------------------------------------------------------------
// Toma a cuenta · V2-M03.04, V2-M03.06 y V2-M03.07
//
// La formula es la del diseno del backend (plan/historias-backend.md): vive
// aqui, no en la app. Los parametros de db.seed.json son de ejemplo, no valores
// de la agencia. Una estimacion nunca es una oferta.
// ---------------------------------------------------------------------------

const ESTADOS_VEHICULO = { EXCELENTE: -1, BUENO: 0, REGULAR: 1, MALO: 2 };
const KM_ANUALES = 15000;
const MARGEN = 0.08;

const redondearA100 = (n) => Math.max(0, Math.round(n / 100) * 100);
const limitar = (n, min, max) => Math.min(max, Math.max(min, n));
const mismo = (a, b) => String(a).trim().toLowerCase() === String(b).trim().toLowerCase();

// Calcula el rango y los supuestos con un parametro de la agencia.
function calcularTomaACuenta(parametro, anio, km, estado) {
  const edadAnios = Math.max(0, new Date().getFullYear() - anio);
  const base = parametro.valorBase * Math.pow(1 - parametro.depreciacionAnual, edadAnios);
  const kmEsperado = edadAnios * KM_ANUALES;
  const ajusteKm = limitar(1 - (parametro.factorKm * (km - kmEsperado)) / 10000, 0.5, 1.2);
  const ajusteEstado = 1 - parametro.factorEstado * ESTADOS_VEHICULO[estado];
  const estimado = base * ajusteKm * ajusteEstado;
  return {
    minimo: redondearA100(estimado * (1 - MARGEN)),
    maximo: redondearA100(estimado * (1 + MARGEN)),
    supuestos: {
      valorBase: parametro.valorBase,
      edadAnios,
      kmEsperado,
      ajusteKm: Number(ajusteKm.toFixed(4)),
      ajusteEstado: Number(ajusteEstado.toFixed(4)),
      margen: MARGEN,
    },
  };
}

const comoEstimacion = (e) => {
  const { clienteId, parametroId, ...contrato } = e;
  return contrato;
};

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

servidor.get(`${BASE}/toma-a-cuenta/estimaciones`, (req, res) => {
  const propias = db
    .get('estimacionesTomaCuenta')
    .filter({ clienteId: req.sesion.clienteId })
    .value()
    .slice()
    .sort((a, b) => b.id - a.id)
    .map(comoEstimacion);
  paginar(req, res, propias);
});

servidor.post(`${BASE}/toma-a-cuenta/estimaciones`, (req, res) => {
  const { vehiculoId, marca, modelo, anio, km, estado, modeloCatalogoId } = req.body || {};
  const conVehiculo = vehiculoId !== undefined && vehiculoId !== null;
  const capturado = [marca, modelo, anio].some((v) => v !== undefined && v !== null);

  if (conVehiculo === capturado) {
    return problema(req, res, 400, 'Indica vehiculoId o marca, modelo y anio, no las dos ni ninguna', 'DATOS_INVALIDOS');
  }
  if (!Number.isInteger(km) || km < 0 || km > 999999 || !(estado in ESTADOS_VEHICULO)) {
    return problema(req, res, 400, 'km o estado no son validos', 'DATOS_INVALIDOS');
  }

  let auto;
  let vehiculo = null;
  if (conVehiculo) {
    vehiculo = vehiculoDelCliente(req, vehiculoId);
    if (!vehiculo) return noEncontrado(req, res);
    auto = { marca: vehiculo.marca, modelo: vehiculo.tipo ?? vehiculo.modelo, anio: vehiculo.anio };
  } else {
    const anioValido = Number.isInteger(anio) && anio >= 1900 && anio <= new Date().getFullYear() + 1;
    if (typeof marca !== 'string' || !marca.trim() || typeof modelo !== 'string' || !modelo.trim() || !anioValido) {
      return problema(req, res, 400, 'marca, modelo o anio no son validos', 'DATOS_INVALIDOS');
    }
    auto = { marca: marca.trim(), modelo: modelo.trim(), anio };
  }

  let destino = null;
  if (modeloCatalogoId !== undefined && modeloCatalogoId !== null) {
    destino = db.get('catalogo').find({ id: Number(modeloCatalogoId), activo: true }).value();
    if (!destino) return noEncontrado(req, res);
  }

  const parametro = db
    .get('parametrosTomaCuenta')
    .value()
    .find((p) => p.activo && mismo(p.marca, auto.marca || '') && mismo(p.modelo, auto.modelo) && p.anio === auto.anio);
  if (!parametro) {
    return problema(
      req,
      res,
      422,
      'Todavia no podemos estimar ese auto. Pide una valuacion formal.',
      'SIN_PARAMETROS_DE_VALUACION'
    );
  }

  const calculo = calcularTomaACuenta(parametro, auto.anio, km, estado);
  const ids = db.get('estimacionesTomaCuenta').value().map((e) => e.id);
  const estimacion = {
    id: ids.length ? Math.max(...ids) + 1 : 1,
    clienteId: req.sesion.clienteId,
    parametroId: parametro.id,
    creadaEn: new Date().toISOString(),
    vehiculoId: vehiculo ? vehiculo.id : null,
    marca: auto.marca,
    modelo: auto.modelo,
    anio: auto.anio,
    km,
    estado,
    modeloCatalogoId: destino ? destino.id : null,
    modeloDestino: destino ? [destino.marca, destino.modelo, destino.anio].join(' ') : null,
    precioDestino: destino ? destino.precioDesde ?? null : null,
    ...calculo,
  };
  db.get('estimacionesTomaCuenta').push(estimacion).write();
  res.status(201).jsonp(comoEstimacion(estimacion));
});

const ETAPAS_TALLER = [
  'RECIBIDO',
  'DIAGNOSTICO',
  'ESPERANDO_APROBACION',
  'EN_REPARACION',
  'CONTROL_DE_CALIDAD',
  'LAVADO',
  'LISTO_PARA_ENTREGA',
  'ENTREGADO',
];

function etapaActual(orden) {
  return orden.etapas[orden.etapas.length - 1].etapa;
}

function avanceDe(etapa) {
  return Math.round((ETAPAS_TALLER.indexOf(etapa) * 100) / (ETAPAS_TALLER.length - 1));
}

function estatusDe(etapa) {
  if (etapa === 'RECIBIDO') return 'RECIBIDO';
  if (etapa === 'LISTO_PARA_ENTREGA') return 'TERMINADO';
  if (etapa === 'ENTREGADO') return 'ENTREGADO';
  return 'EN_PROCESO';
}

function descripcionVehiculo(vehiculo) {
  return [vehiculo.marca, vehiculo.tipo, vehiculo.anio].filter(Boolean).join(' ');
}

function sumaAdicionales(orden, estado) {
  const total = orden.adicionales
    .filter((a) => a.estado === estado)
    .reduce((t, a) => t + a.total, 0);
  return Math.round(total * 100) / 100;
}

function comoOrdenEnCurso(orden, vehiculo) {
  const etapa = etapaActual(orden);
  return {
    id: orden.id,
    vehiculoId: orden.vehiculoId,
    vehiculo: descripcionVehiculo(vehiculo),
    etapa,
    estatus: estatusDe(etapa),
    entregaEstimada: orden.entregaEstimada ?? null,
    asesor: orden.asesor ?? null,
    avance: avanceDe(etapa),
    adicionalesPendientes: orden.adicionales.filter((a) => a.estado === 'PENDIENTE').length,
  };
}

function comoOrdenEnVivo(orden, vehiculo) {
  const aprobados = sumaAdicionales(orden, 'APROBADO');
  return {
    ...comoOrdenEnCurso(orden, vehiculo),
    etapas: orden.etapas,
    inspeccion: orden.inspeccion,
    evidencias: orden.evidencias,
    adicionales: orden.adicionales.map((a) => ({
      id: a.id,
      concepto: a.concepto,
      manoDeObra: a.manoDeObra,
      refacciones: a.refacciones,
      total: a.total,
      estado: a.estado,
      respondidoEn: a.respondidoEn ?? null,
    })),
    totalOrden: orden.totalOrden,
    totalAdicionalesAprobados: aprobados,
    totalAdicionalesPendientes: sumaAdicionales(orden, 'PENDIENTE'),
    totalEstimado: Math.round((orden.totalOrden + aprobados) * 100) / 100,
  };
}

function ordenDelCliente(req, id) {
  const orden = db.get('ordenesTaller').find({ id: Number(id) }).value();
  if (!orden) return null;
  const vehiculo = vehiculoDelCliente(req, orden.vehiculoId);
  return vehiculo ? { orden, vehiculo } : null;
}

servidor.get(`${BASE}/ordenes/activas`, (req, res) => {
  const propias = db
    .get('ordenesTaller')
    .value()
    .map((orden) => ({ orden, vehiculo: vehiculoDelCliente(req, orden.vehiculoId) }))
    .filter(({ orden, vehiculo }) => vehiculo && etapaActual(orden) !== 'ENTREGADO')
    .sort((a, b) => b.orden.id - a.orden.id);
  res.jsonp(propias.map(({ orden, vehiculo }) => comoOrdenEnCurso(orden, vehiculo)));
});

servidor.get(`${BASE}/ordenes/:ordenId`, (req, res) => {
  const encontrada = ordenDelCliente(req, req.params.ordenId);
  if (!encontrada) return noEncontrado(req, res);
  res.jsonp(comoOrdenEnVivo(encontrada.orden, encontrada.vehiculo));
});

servidor.post(`${BASE}/ordenes/:ordenId/adicionales/:adicionalId/respuesta`, (req, res) => {
  const encontrada = ordenDelCliente(req, req.params.ordenId);
  if (!encontrada) return noEncontrado(req, res);
  const { orden, vehiculo } = encontrada;
  const adicional = orden.adicionales.find((a) => a.id === Number(req.params.adicionalId));
  if (!adicional) return noEncontrado(req, res);

  const { aprobado, firma } = req.body || {};
  if (typeof aprobado !== 'boolean' || typeof firma !== 'string' || !firma.startsWith('iVBORw0KGgo')) {
    return problema(req, res, 400, 'La firma debe ser una imagen PNG en Base64', 'DATOS_INVALIDOS');
  }
  if (adicional.estado !== 'PENDIENTE') {
    return problema(req, res, 409, 'Ya respondiste este trabajo adicional', 'ADICIONAL_YA_RESPONDIDO');
  }
  if (['LISTO_PARA_ENTREGA', 'ENTREGADO'].includes(etapaActual(orden))) {
    return problema(req, res, 409, 'La orden ya está terminada; habla con tu asesor', 'ORDEN_CERRADA');
  }

  adicional.estado = aprobado ? 'APROBADO' : 'RECHAZADO';
  adicional.respondidoEn = new Date().toISOString().slice(0, 19);
  db.get('ordenesTaller').find({ id: orden.id }).assign(orden).write();
  res.jsonp(comoOrdenEnVivo(orden, vehiculo));
});

const TABLA_CRC = Array.from({ length: 256 }, (_, n) => {
  let c = n;
  for (let k = 0; k < 8; k++) c = c & 1 ? 0xedb88320 ^ (c >>> 1) : c >>> 1;
  return c >>> 0;
});

function crc32(buffer) {
  let c = 0xffffffff;
  for (const byte of buffer) c = TABLA_CRC[(c ^ byte) & 0xff] ^ (c >>> 8);
  return (c ^ 0xffffffff) >>> 0;
}

function bloquePng(tipo, datos) {
  const largo = Buffer.alloc(4);
  largo.writeUInt32BE(datos.length);
  const cuerpo = Buffer.concat([Buffer.from(tipo, 'latin1'), datos]);
  const crc = Buffer.alloc(4);
  crc.writeUInt32BE(crc32(cuerpo));
  return Buffer.concat([largo, cuerpo, crc]);
}

function fotoDePrueba(semilla) {
  const ancho = 320;
  const alto = 200;
  const tonos = [
    [11, 92, 173],
    [190, 61, 52],
    [24, 128, 94],
  ];
  const [r, g, b] = tonos[semilla % tonos.length];
  const filas = [];
  for (let y = 0; y < alto; y++) {
    const fila = Buffer.alloc(1 + ancho * 3);
    for (let x = 0; x < ancho; x++) {
      const luz = ((x + y) >> 4) % 2 === 0 ? 1 : 0.8;
      fila[1 + x * 3] = Math.round(r * luz);
      fila[2 + x * 3] = Math.round(g * luz);
      fila[3 + x * 3] = Math.round(b * luz);
    }
    filas.push(fila);
  }
  const cabecera = Buffer.alloc(13);
  cabecera.writeUInt32BE(ancho, 0);
  cabecera.writeUInt32BE(alto, 4);
  cabecera[8] = 8;
  cabecera[9] = 2;
  return Buffer.concat([
    Buffer.from([0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a]),
    bloquePng('IHDR', cabecera),
    bloquePng('IDAT', zlib.deflateSync(Buffer.concat(filas))),
    bloquePng('IEND', Buffer.alloc(0)),
  ]);
}

servidor.get('/api/v1/archivos/evidencias/:id', (req, res) => {
  res.set('Content-Type', 'image/png');
  res.set('Cache-Control', 'no-store');
  res.send(fotoDePrueba(Number(req.params.id) || 0));
});

// ---------------------------------------------------------------------------
// Cualquier otra ruta bajo la base no existe en el contrato
// ---------------------------------------------------------------------------

servidor.use(BASE, (req, res) => {
  problema(req, res, 404, 'Esa ruta no existe en el contrato');
});

// json-server queda al final: sirve /cuentas, /vehiculos y las demas colecciones
// sin el prefijo del contrato, util para inspeccionar el estado durante el
// desarrollo. No forma parte del contrato.
servidor.use(router);

servidor.listen(PUERTO, () => {
  console.log('');
  console.log(`API simulada de CareCar escuchando en http://localhost:${PUERTO}${BASE}`);
  console.log(`Estado vivo: ${RUTA_DB}`);
  console.log('Restaurar los datos iniciales: npm run reset');
  console.log('');
});

// ---------------------------------------------------------------------------
// PDF minimo valido, sin dependencias
// ---------------------------------------------------------------------------

function construirTicketPdf(lineas) {
  const escapar = (t) => t.replace(/\\/g, '\\\\').replace(/\(/g, '\\(').replace(/\)/g, '\\)');

  let texto = 'BT /F1 12 Tf 72 780 Td 16 TL\n';
  for (const linea of lineas) texto += `(${escapar(linea)}) Tj T*\n`;
  texto += 'ET';

  const objetos = [
    null,
    '<< /Type /Catalog /Pages 2 0 R >>',
    '<< /Type /Pages /Kids [3 0 R] /Count 1 >>',
    '<< /Type /Page /Parent 2 0 R /MediaBox [0 0 595 842] ' +
      '/Resources << /Font << /F1 4 0 R >> >> /Contents 5 0 R >>',
    '<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica >>',
    `<< /Length ${Buffer.byteLength(texto, 'latin1')} >>\nstream\n${texto}\nendstream`,
  ];

  let pdf = '%PDF-1.4\n';
  const posiciones = [];
  for (let i = 1; i < objetos.length; i++) {
    posiciones[i] = Buffer.byteLength(pdf, 'latin1');
    pdf += `${i} 0 obj\n${objetos[i]}\nendobj\n`;
  }

  const inicioXref = Buffer.byteLength(pdf, 'latin1');
  const total = objetos.length;
  pdf += `xref\n0 ${total}\n0000000000 65535 f \n`;
  for (let i = 1; i < total; i++) {
    pdf += `${String(posiciones[i]).padStart(10, '0')} 00000 n \n`;
  }
  pdf += `trailer\n<< /Size ${total} /Root 1 0 R >>\nstartxref\n${inicioXref}\n%%EOF\n`;

  return Buffer.from(pdf, 'latin1');
}
