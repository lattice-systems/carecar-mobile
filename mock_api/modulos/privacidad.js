const { BASE, problema, noEncontrado } = require('../comun/http');

module.exports = function registrarPrivacidad(servidor) {
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
};
