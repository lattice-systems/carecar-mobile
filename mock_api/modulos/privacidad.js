const { BASE, problema, noEncontrado } = require('../comun/http');

module.exports = function registrarPrivacidad(servidor, db, emitirEvento) {
  // --- Aviso de privacidad (V2-M22.01) ---
  // La versión 1 es el texto que la app traía incluido. `POST /api/v1/avisos-privacidad`
  // (del personal, sin sesión en el simulador) publica la versión siguiente para
  // probar «una versión nueva vuelve a pedir la aceptación».
  const TEXTO_AVISO_V1 = [
    'Agencia360, con domicilio en el indicado en esta app, es responsable del tratamiento de tus datos personales.',
    'Datos que usamos: nombre, correo electrónico, teléfono y los datos de tus vehículos (marca, modelo, placas, número de serie y kilometraje), así como el historial de servicios y citas.',
    'Finalidades: identificarte al iniciar sesión, mostrarte tus vehículos, manuales, servicios y tickets, agendar y recordarte tus citas en el taller y atender tus solicitudes. No usamos tus datos con fines publicitarios ni los vendemos a terceros.',
    'Transferencias: solo compartimos tus datos con autoridades cuando la ley lo exige.',
    'Derechos ARCO: puedes acceder, rectificar, cancelar u oponerte al uso de tus datos, o revocar tu consentimiento, escribiendo al correo de contacto de la agencia. Te responderemos en un plazo máximo de 20 días hábiles.',
    'Seguridad: tu sesión se guarda cifrada en tu dispositivo y la comunicación con la agencia requiere autenticación.',
    'Cambios: cualquier modificación a este aviso se publicará en esta misma sección de la app.',
    'Última actualización: noviembre de 2026.',
  ].join('\n\n');
  const avisosPrivacidad = [
    { id: 1, version: 1, texto: TEXTO_AVISO_V1, vigenteDesde: '2026-11-01T00:00:00.000Z' },
  ];
  const aceptacionesAviso = [];

  function avisoVigente() {
    return avisosPrivacidad[avisosPrivacidad.length - 1];
  }

  function aceptacionDe(req, avisoId) {
    return aceptacionesAviso.find((a) => a.clienteId === req.sesion.clienteId && a.avisoId === avisoId);
  }

  servidor.get(`${BASE}/privacidad/aviso`, (req, res) => {
    const aviso = avisoVigente();
    const aceptacion = aceptacionDe(req, aviso.id);
    res.json({ ...aviso, aceptado: Boolean(aceptacion), aceptadoEn: aceptacion ? aceptacion.aceptadoEn : null });
  });

  servidor.post(`${BASE}/privacidad/aceptaciones`, (req, res) => {
    const { avisoId } = req.body || {};
    if (!Number.isInteger(avisoId)) {
      return problema(req, res, 400, 'Falta el aviso que se acepta', 'DATOS_INVALIDOS');
    }
    const aviso = avisosPrivacidad.find((a) => a.id === avisoId);
    if (!aviso) return noEncontrado(req, res);
    if (aviso.id !== avisoVigente().id) {
      return problema(req, res, 409, 'Hay un aviso de privacidad más reciente: léelo y acéptalo.', 'AVISO_NO_VIGENTE');
    }
    let aceptacion = aceptacionDe(req, aviso.id);
    if (!aceptacion) {
      aceptacion = { clienteId: req.sesion.clienteId, avisoId: aviso.id, aceptadoEn: new Date().toISOString() };
      aceptacionesAviso.push(aceptacion);
    }
    return res.json({ avisoId: aviso.id, version: aviso.version, aceptadoEn: aceptacion.aceptadoEn });
  });

  servidor.post('/api/v1/avisos-privacidad', (req, res) => {
    const { texto } = req.body || {};
    if (typeof texto !== 'string' || !texto.trim() || texto.length > 20000) {
      return res.status(400).json({ status: 400, error: 'Bad Request', message: 'El texto del aviso no es válido',
        codigo: 'DATOS_INVALIDOS', path: req.path, timestamp: new Date().toISOString() });
    }
    const nuevo = {
      id: avisosPrivacidad.length + 1,
      version: avisosPrivacidad.length + 1,
      texto: texto.trim(),
      vigenteDesde: new Date().toISOString(),
    };
    avisosPrivacidad.push(nuevo);
    return res.status(201).json({ ...nuevo, aceptado: false, aceptadoEn: null });
  });

  // --- Derechos ARCO: acceso a mis datos (V2-M22.02) ---
  // Como el backend: la solicitud nace PENDIENTE (202), el archivo se prepara
  // aparte y al estar listo llega el evento `arco.estado`. Dura 7 dias. El
  // retraso (2 s) se cambia con RETRASO_ARCO_MS; con 0 queda lista al instante.
  const VIGENCIA_ARCO_MS = 7 * 24 * 60 * 60 * 1000;
  const RETRASO_ARCO_MS = Number(process.env.RETRASO_ARCO_MS ?? 2000);
  const solicitudesArco = [];

  function comoSolicitudArco(s) {
    // Solo el acceso deja un archivo que vence; la cancelación no.
    const vence = s.tipo === 'ACCESO' && s.resueltaEn
      ? new Date(new Date(s.resueltaEn).getTime() + VIGENCIA_ARCO_MS)
      : null;
    const vencida = s.estado === 'RESUELTA' && vence && vence <= new Date();
    return {
      id: s.id,
      tipo: s.tipo,
      estado: vencida ? 'VENCIDA' : s.estado,
      creadaEn: s.creadaEn,
      resueltaEn: s.resueltaEn ?? null,
      venceEn: s.estado === 'RESUELTA' && vence ? vence.toISOString() : null,
    };
  }

  function archivoDeDatos(clienteId) {
    const cuenta = db.get('cuentas').find({ clienteId }).value() || {};
    return {
      generadoEn: new Date().toISOString(),
      descripcion: 'Copia de los datos personales que CareCar guarda de tu cuenta (derecho de acceso). '
        + 'Contiene información personal: guárdala en un lugar seguro y no la compartas.',
      alcance: {
        incluye: ['Tus datos de contacto', 'Tu cuenta de la app (sin contraseña)'],
        noIncluye: [
          'Los datos fiscales y comerciales que la agencia conserva por obligación legal '
            + '(ventas, pagos y facturas): pídelos en la agencia',
        ],
      },
      cliente: { id: clienteId, nombre: cuenta.nombre ?? null, correo: cuenta.correo ?? null },
      cuentaApp: { usuario: cuenta.usuario ?? null, activa: cuenta.activa ?? true },
    };
  }

  function resolverArco(solicitud) {
    solicitud.estado = 'RESUELTA';
    solicitud.resueltaEn = new Date().toISOString();
    emitirEvento(solicitud.clienteId, 'arco.estado', {
      solicitudId: solicitud.id,
      tipo: solicitud.tipo,
      estado: 'RESUELTA',
    });
  }

  servidor.get(`${BASE}/privacidad/arco`, (req, res) => {
    const propias = solicitudesArco
      .filter((s) => s.clienteId === req.sesion.clienteId)
      .sort((a, b) => b.id - a.id)
      .slice(0, 20)
      .map(comoSolicitudArco);
    res.json(propias);
  });

  servidor.post(`${BASE}/privacidad/arco/acceso`, (req, res) => {
    const clienteId = req.sesion.clienteId;
    const pendiente = solicitudesArco.find((s) => s.clienteId === clienteId && s.tipo === 'ACCESO'
      && s.estado === 'PENDIENTE');
    if (pendiente) return res.status(200).json(comoSolicitudArco(pendiente));
    const solicitud = {
      id: solicitudesArco.length + 1,
      clienteId,
      tipo: 'ACCESO',
      estado: 'PENDIENTE',
      creadaEn: new Date().toISOString(),
      resueltaEn: null,
    };
    solicitudesArco.push(solicitud);
    if (RETRASO_ARCO_MS > 0) setTimeout(() => resolverArco(solicitud), RETRASO_ARCO_MS);
    else resolverArco(solicitud);
    return res.status(202).json(comoSolicitudArco(solicitud));
  });

  servidor.get(`${BASE}/privacidad/arco/:id/archivo`, (req, res) => {
    const solicitud = solicitudesArco.find((s) => s.id === Number(req.params.id)
      && s.clienteId === req.sesion.clienteId);
    if (!solicitud || solicitud.tipo !== 'ACCESO' || comoSolicitudArco(solicitud).estado !== 'RESUELTA') {
      return noEncontrado(req, res);
    }
    res.set({
      'Content-Type': 'application/json',
      'Content-Disposition': 'attachment; filename="mis-datos-carecar.json"',
      'Cache-Control': 'no-store',
    });
    return res.status(200).send(JSON.stringify(archivoDeDatos(solicitud.clienteId), null, 2));
  });

  // --- Derechos ARCO: borrar mi cuenta (V2-M22.03) ---
  // Como el backend: pide la contraseña. Una equivocada responde 400 y no 401
  // (la app lee un 401 como sesión vencida y cerraría la sesión sin decir nada);
  // a los 5 fallos seguidos, 429 con Retry-After durante 15 minutos. Al terminar,
  // la cuenta queda desactivada y con otros datos: el middleware de `acceso`
  // contesta 403 a cualquier token suyo y el login con la contraseña vieja da 401.
  //
  // Diferencias con el backend: aquí el contador de fallos es solo de la
  // cancelación (allá es el mismo del login), y los datos del cliente en las
  // demás colecciones no se borran: nadie puede llegar a ellos sin sesión. Se
  // guarda en db.json como cualquier cambio; `npm run reset` devuelve la cuenta.
  const MAX_FALLOS_CANCELACION = 5;
  const BLOQUEO_CANCELACION_MS = 15 * 60 * 1000;
  const fallosDeCancelacion = new Map();

  function segundosBloqueadoParaCancelar(clienteId) {
    const registro = fallosDeCancelacion.get(clienteId);
    if (!registro || registro.fallos < MAX_FALLOS_CANCELACION) return 0;
    const restante = registro.hasta - Date.now();
    if (restante <= 0) {
      fallosDeCancelacion.delete(clienteId);
      return 0;
    }
    return Math.ceil(restante / 1000);
  }

  servidor.post(`${BASE}/privacidad/arco/cancelacion`, (req, res) => {
    const { contrasena } = req.body || {};
    if (typeof contrasena !== 'string' || !contrasena.trim()) {
      return problema(req, res, 400, 'Escribe tu contraseña para confirmar', 'DATOS_INVALIDOS');
    }
    const { clienteId, cuenta } = req.sesion;

    const espera = segundosBloqueadoParaCancelar(clienteId);
    if (espera > 0) {
      res.set('Retry-After', String(espera));
      return problema(req, res, 429, 'Demasiados intentos. Intenta de nuevo más tarde.', 'DEMASIADOS_INTENTOS');
    }
    if (cuenta.contrasena !== contrasena) {
      const registro = fallosDeCancelacion.get(clienteId) || { fallos: 0, hasta: 0 };
      registro.fallos += 1;
      if (registro.fallos >= MAX_FALLOS_CANCELACION) registro.hasta = Date.now() + BLOQUEO_CANCELACION_MS;
      fallosDeCancelacion.set(clienteId, registro);
      return problema(req, res, 400, 'La contraseña no es correcta', 'DATOS_INVALIDOS');
    }
    fallosDeCancelacion.delete(clienteId);

    const ahora = new Date().toISOString();
    const solicitud = {
      id: solicitudesArco.length + 1,
      clienteId,
      tipo: 'CANCELACION',
      estado: 'RESUELTA',
      creadaEn: ahora,
      resueltaEn: ahora,
    };
    solicitudesArco.push(solicitud);
    db.get('cuentas')
      .find({ id: cuenta.id })
      .assign({
        activa: false,
        usuario: `eliminada-${cuenta.id}`,
        nombre: 'Cliente eliminado',
        correo: `eliminada-${cuenta.id}`,
        // Una contraseña que nadie conoce: no vuelve a entrar con la de antes.
        contrasena: `${Date.now()}-${Math.random().toString(36).slice(2)}`,
      })
      .write();
    return res.status(200).json(comoSolicitudArco(solicitud));
  });
};
