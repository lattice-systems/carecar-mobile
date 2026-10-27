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

const comoVehiculo = (v) => ({
  id: v.id,
  vin: v.vin,
  modelo: v.modelo,
  anio: v.anio,
  placas: v.placas ?? null,
  kilometraje: v.kilometraje ?? null,
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

// ---------------------------------------------------------------------------
// Servicios y tickets · APP-3.2
// ---------------------------------------------------------------------------

servidor.get(`${BASE}/vehiculos/:vehiculoId/servicios`, (req, res) => {
  const vehiculo = vehiculoDelCliente(req, req.params.vehiculoId);
  if (!vehiculo) return noEncontrado(req, res);

  // El contrato pide orden cronologico, el mas reciente primero.
  const servicios = db
    .get('servicios')
    .filter({ vehiculoId: vehiculo.id })
    .value()
    .slice()
    .sort((a, b) => b.fecha.localeCompare(a.fecha))
    .map((s) => ({ id: s.id, fecha: s.fecha, estatus: s.estatus, total: s.total }));

  res.jsonp(servicios);
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
  fecha: c.fecha,
  horaInicio: c.horaInicio,
  horaFin: c.horaFin,
  estado: c.estado,
});

servidor.get(`${BASE}/citas`, (req, res) => {
  const propias = db.get('citas').filter({ clienteId: req.sesion.clienteId }).value();
  res.jsonp(propias.map(comoCita));
});

servidor.post(`${BASE}/citas`, (req, res) => {
  const { vehiculoId, franjaId, fecha } = req.body || {};
  if (!vehiculoId || !franjaId || !ES_FECHA.test(fecha || '')) {
    return problema(req, res, 400, 'Faltan vehiculoId, franjaId o fecha (AAAA-MM-DD)');
  }

  const vehiculo = vehiculoDelCliente(req, vehiculoId);
  if (!vehiculo) return noEncontrado(req, res);

  const franja = db.get('franjas').find({ id: Number(franjaId) }).value();
  if (!franja || franja.fecha !== fecha) return noEncontrado(req, res);

  if (franja.cupoDisponible < 1) {
    return problema(req, res, 409, 'La franja ya no tiene cupo', 'FRANJA_SIN_CUPO');
  }

  // "No se puede reservar dos veces" (APP-3.3).
  const yaReservada = db
    .get('citas')
    .value()
    .some(
      (c) =>
        c.clienteId === req.sesion.clienteId &&
        c.franjaId === franja.id &&
        c.fecha === fecha &&
        c.estado === 'CONFIRMADA'
    );
  if (yaReservada) {
    return problema(req, res, 409, 'Ya tienes una cita en esa franja');
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
  };

  // La cita descuenta capacidad de la franja (APP-3.3).
  db.get('citas').push(cita).write();
  db.get('franjas')
    .find({ id: franja.id })
    .assign({ cupoDisponible: franja.cupoDisponible - 1 })
    .write();

  res.status(201).jsonp(comoCita(cita));
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

// ---------------------------------------------------------------------------
// Catalogo · APP-4.1 (fuera del MVP, pero el contrato lo incluye)
// ---------------------------------------------------------------------------

servidor.get(`${BASE}/catalogo`, (req, res) => {
  const activos = db.get('catalogo').filter({ activo: true }).value();
  res.jsonp(activos.map((m) => ({ id: m.id, modelo: m.modelo })));
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
