const { BASE, noEncontrado } = require('../comun/http');

module.exports = function registrarPagos(servidor, db) {
  // ── pagos y facturas: datos fiscales ──
  // V2-M08.05 · Mismas reglas que el backend (DatosFiscales.validar): RFC con
  // forma, fecha real y dígito verificador del SAT, régimen y uso del catálogo
  // de CFDI 4.0 para el tipo de persona, el uso aceptado por el régimen y
  // errores por campo en `campos`. El catálogo es copia del de
  // CatalogoFiscal.java (semillas/catalogos_fiscales.json). Los pagos y las
  // facturas de M08 son simulados (ADR 0009).
  db.defaults({ regimenesFiscales: [], usosCfdi: [], perfilesFiscales: [] }).write();

  const VALORES = '0123456789ABCDEFGHIJKLMN&OPQRSTUVWXYZ Ñ';
  const FORMA = /^([A-ZÑ&]{3,4})([0-9]{2})([0-9]{2})([0-9]{2})([A-Z0-9]{2})([0-9A])$/;
  const DIAS_DEL_MES = [31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];

  function digitoVerificador(rfc) {
    const completo = rfc.length === 12 ? ` ${rfc}` : rfc;
    let suma = 0;
    for (let i = 0; i < 12; i++) suma += VALORES.indexOf(completo[i]) * (13 - i);
    const residuo = suma % 11;
    if (residuo === 0) return '0';
    const digito = 11 - residuo;
    return digito === 10 ? 'A' : String(digito);
  }

  function problemaRfc(rfc) {
    if (!rfc) return 'Escribe el RFC';
    if (rfc.length !== 12 && rfc.length !== 13) {
      return 'El RFC tiene 12 caracteres (persona moral) o 13 (persona física)';
    }
    const partes = FORMA.exec(rfc);
    if (!partes || partes[1].length !== rfc.length - 9) return 'El RFC no tiene la forma del SAT';
    if (rfc === 'XAXX010101000' || rfc === 'XEXX010101000') return 'El RFC genérico no se usa en un perfil fiscal';
    const [anio, mes, dia] = [Number(partes[2]), Number(partes[3]), Number(partes[4])];
    const fechaValida = mes >= 1 && mes <= 12 && dia >= 1 && dia <= DIAS_DEL_MES[mes - 1] && (mes !== 2 || dia !== 29 || anio % 4 === 0);
    if (!fechaValida) return 'La fecha del RFC no existe';
    if (digitoVerificador(rfc) !== rfc[rfc.length - 1]) {
      return 'El dígito verificador del RFC no coincide; revisa la homoclave';
    }
    return null;
  }

  function validar(cuerpo) {
    const errores = {};
    const rfc = String(cuerpo.rfc || '').trim().toUpperCase();
    const delRfc = problemaRfc(rfc);
    if (delRfc) errores.rfc = delRfc;
    const tipo = delRfc ? null : rfc.length === 13 ? 'FISICA' : 'MORAL';
    const aplica = (entrada) => tipo === null || (tipo === 'FISICA' ? entrada.fisica : entrada.moral);
    const nombre = tipo === 'FISICA' ? 'física' : 'moral';

    const razon = String(cuerpo.razonSocial || '').trim().replace(/\s+/g, ' ').toUpperCase();
    if (!razon) errores.razonSocial = 'Escribe el nombre o la razón social como aparece en tu constancia';
    else if (razon.length > 254) errores.razonSocial = 'El nombre pasa de 254 caracteres';

    const cp = String(cuerpo.codigoPostal || '').trim();
    if (!/^[0-9]{5}$/.test(cp)) errores.codigoPostal = 'El código postal tiene 5 dígitos';

    const claveRegimen = String(cuerpo.regimenFiscal || '').trim().toUpperCase();
    const regimen = db.get('regimenesFiscales').find({ clave: claveRegimen }).value();
    if (!regimen) errores.regimenFiscal = 'Elige un régimen fiscal del catálogo del SAT';
    else if (!aplica(regimen)) errores.regimenFiscal = `Ese régimen no aplica a una persona ${nombre}`;

    const claveUso = String(cuerpo.usoCfdi || '').trim().toUpperCase();
    const uso = db.get('usosCfdi').find({ clave: claveUso }).value();
    if (!uso) errores.usoCfdi = 'Elige un uso de CFDI del catálogo del SAT';
    else if (!aplica(uso)) errores.usoCfdi = `Ese uso de CFDI no aplica a una persona ${nombre}`;
    else if (regimen && !uso.regimenes.includes(claveRegimen)) {
      errores.usoCfdi = `Ese uso de CFDI no se puede con el régimen ${claveRegimen}`;
    }

    const correo = cuerpo.correo && String(cuerpo.correo).trim() ? String(cuerpo.correo).trim().toLowerCase() : null;
    if (correo && (correo.length > 254 || !/^[^@\s]+@[^@\s.]+(\.[^@\s.]+)+$/.test(correo))) errores.correo = 'Revisa el correo';

    if (Object.keys(errores).length) return { errores };
    return {
      datos: { rfc, razonSocial: razon, regimenFiscal: claveRegimen, codigoPostal: cp, usoCfdi: claveUso, correo },
    };
  }

  function rechazar(req, res, errores) {
    res.status(400).jsonp({
      timestamp: new Date().toISOString(),
      status: 400,
      error: 'Bad Request',
      message: Object.values(errores).join('; '),
      codigo: 'DATOS_FISCALES_INVALIDOS',
      campos: errores,
      path: req.originalUrl.split('?')[0],
    });
  }

  const deCliente = (clienteId) =>
    db
      .get('perfilesFiscales')
      .filter({ clienteId })
      .orderBy([(p) => (p.predeterminado ? 0 : 1), 'id'])
      .value();
  const publico = ({ clienteId, ...p }) => ({ ...p, tipoPersona: p.rfc.length === 13 ? 'FISICA' : 'MORAL' });
  const siguienteId = () => {
    const ids = db.get('perfilesFiscales').map('id').value();
    return ids.length ? Math.max(...ids) + 1 : 1;
  };
  const quitarPredeterminado = (clienteId) =>
    db.get('perfilesFiscales').filter({ clienteId }).each((p) => { p.predeterminado = false; }).value();

  servidor.get(`${BASE}/catalogos-fiscales`, (req, res) => {
    res.jsonp({ regimenes: db.get('regimenesFiscales').value(), usosCfdi: db.get('usosCfdi').value() });
  });

  servidor.get(`${BASE}/perfiles-fiscales`, (req, res) => {
    res.jsonp(deCliente(req.sesion.clienteId).map(publico));
  });

  servidor.get(`${BASE}/perfiles-fiscales/:id`, (req, res) => {
    const perfil = db.get('perfilesFiscales').find({ id: Number(req.params.id), clienteId: req.sesion.clienteId }).value();
    if (!perfil) return noEncontrado(req, res);
    res.jsonp(publico(perfil));
  });

  // El primero queda predeterminado; otro lo toma con `predeterminado: true`.
  servidor.post(`${BASE}/perfiles-fiscales`, (req, res) => {
    const clienteId = req.sesion.clienteId;
    const { errores, datos } = validar(req.body || {});
    if (errores) return rechazar(req, res, errores);
    const primero = deCliente(clienteId).length === 0;
    const predeterminado = primero || (req.body || {}).predeterminado === true;
    if (predeterminado) quitarPredeterminado(clienteId);
    const perfil = { id: siguienteId(), clienteId, ...datos, predeterminado, creadoEn: new Date().toISOString() };
    db.get('perfilesFiscales').push(perfil).write();
    res.status(201).jsonp(publico(perfil));
  });

  // `predeterminado: true` lo vuelve el predeterminado; `false` no cambia cuál es.
  servidor.put(`${BASE}/perfiles-fiscales/:id`, (req, res) => {
    const clienteId = req.sesion.clienteId;
    const actual = db.get('perfilesFiscales').find({ id: Number(req.params.id), clienteId }).value();
    if (!actual) return noEncontrado(req, res);
    const { errores, datos } = validar(req.body || {});
    if (errores) return rechazar(req, res, errores);
    const predeterminado = actual.predeterminado || (req.body || {}).predeterminado === true;
    if (predeterminado && !actual.predeterminado) quitarPredeterminado(clienteId);
    db.get('perfilesFiscales').find({ id: actual.id }).assign({ ...datos, predeterminado }).write();
    res.jsonp(publico(db.get('perfilesFiscales').find({ id: actual.id }).value()));
  });

  // Si era el predeterminado, lo toma el más viejo de los que quedan.
  servidor.delete(`${BASE}/perfiles-fiscales/:id`, (req, res) => {
    const clienteId = req.sesion.clienteId;
    const actual = db.get('perfilesFiscales').find({ id: Number(req.params.id), clienteId }).value();
    if (!actual) return noEncontrado(req, res);
    db.get('perfilesFiscales').remove({ id: actual.id }).write();
    if (actual.predeterminado) {
      const siguiente = deCliente(clienteId)[0];
      if (siguiente) db.get('perfilesFiscales').find({ id: siguiente.id }).assign({ predeterminado: true }).write();
    }
    res.status(204).end();
  });
};
