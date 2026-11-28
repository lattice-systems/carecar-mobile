const { BASE, problema } = require('../comun/http');

module.exports = function registrarDispositivos(servidor) {
  // ── dispositivos de push ──
  // V2-M06.02 · como el contrato y el backend (backend#117): una instalacion
  // tiene un solo token; el mismo token en otra instalacion (reinstalacion)
  // descarta la vieja; una instalacion de otra cuenta pasa a quien llama. La
  // baja es idempotente y no toca instalaciones ajenas. Vive en memoria: el
  // mock no manda push, solo deja probar el registro.
  const dispositivos = new Map();

  const ES_INSTALACION = /^[A-Za-z0-9-]{8,64}$/;
  const PLATAFORMAS = ['android', 'ios'];

  function invalido({ tokenFcm, plataforma, idioma } = {}) {
    if (typeof tokenFcm !== 'string' || tokenFcm.length < 1 || tokenFcm.length > 4096) return 'tokenFcm';
    if (!PLATAFORMAS.includes(plataforma)) return 'plataforma';
    if (idioma != null && (typeof idioma !== 'string' || idioma.length > 10)) return 'idioma';
    return null;
  }

  servidor.put(`${BASE}/dispositivos/:instalacionId`, (req, res) => {
    const { instalacionId } = req.params;
    const campo = ES_INSTALACION.test(instalacionId) ? invalido(req.body) : 'instalacionId';
    if (campo) return problema(req, res, 400, `El campo ${campo} no es válido`, 'DATOS_INVALIDOS');

    const { tokenFcm, plataforma, idioma } = req.body;
    for (const [otra, dispositivo] of dispositivos) {
      if (otra !== instalacionId && dispositivo.tokenFcm === tokenFcm) dispositivos.delete(otra);
    }
    dispositivos.set(instalacionId, {
      clienteId: req.sesion.clienteId,
      tokenFcm,
      plataforma,
      idioma: idioma || 'es',
    });
    res.status(204).end();
  });

  servidor.delete(`${BASE}/dispositivos/:instalacionId`, (req, res) => {
    const dispositivo = dispositivos.get(req.params.instalacionId);
    if (dispositivo && dispositivo.clienteId === req.sesion.clienteId) {
      dispositivos.delete(req.params.instalacionId);
    }
    res.status(204).end();
  });
};
