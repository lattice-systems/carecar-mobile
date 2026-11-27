const crypto = require('crypto');
const { BASE, problema, noEncontrado, paginar } = require('../comun/http');
const construirTicketPdf = require('../comun/ticket_pdf');

module.exports = function registrarPagos(servidor, db, vehiculoDelCliente, emitirEvento) {
  // ── pagos y facturas: datos fiscales ──
  // V2-M08.05 · Mismas reglas que el backend (DatosFiscales.validar): RFC con
  // forma, fecha real y dígito verificador del SAT, régimen y uso del catálogo
  // de CFDI 4.0 para el tipo de persona, el uso aceptado por el régimen y
  // errores por campo en `campos`. El catálogo es copia del de
  // CatalogoFiscal.java (semillas/catalogos_fiscales.json). Los pagos y las
  // facturas de M08 son simulados (ADR 0009); los pagos van abajo.
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

  // ── pagos y tarjetas guardadas ──
  // V2-M08.02, V2-M08.04 y V2-M08.07 · El procesador simulado del backend
  // (ProcesadorSimulado, ADR 0009): decide por el token de la tarjeta de
  // prueba, la misma Idempotency-Key devuelve el mismo intento, un 3-D Secure
  // sin responder vence a los 15 minutos y la tarjeta se guarda al quedar
  // pagado si se pidio. Una orden se paga si viene del taller (`delTaller`),
  // esta TERMINADO o ENTREGADO, tiene total y nadie la ha pagado.
  // V2-M14.04: Un pedido de la tienda se paga con las mismas tarjetas si es
  // del cliente, esta apartado o listo, no ha vencido, tiene total y nadie lo
  // ha pagado. Pagado no suma puntos (son por servicio) y ya no vence.
  // V2-M08.03: Apple Pay y Google Pay simulados (`billetera`) se aprueban
  // siempre, sin 3-D Secure, y no se guardan.
  db.defaults({ pagosApp: [], metodosPago: [], facturasApp: [] }).write();

  const TARJETAS = {
    tok_sim_visa: { marca: 'VISA', ultimos4: '4242', tipo: 'CREDITO', escenario: 'APROBADA' },
    tok_sim_mastercard: { marca: 'MASTERCARD', ultimos4: '4444', tipo: 'CREDITO', escenario: 'APROBADA' },
    tok_sim_visa_debito: { marca: 'VISA', ultimos4: '5556', tipo: 'DEBITO', escenario: 'APROBADA' },
    tok_sim_fondos_insuficientes: { marca: 'VISA', ultimos4: '9995', tipo: 'CREDITO', escenario: 'FONDOS' },
    tok_sim_3ds: { marca: 'VISA', ultimos4: '3220', tipo: 'CREDITO', escenario: 'CONFIRMAR' },
    tok_sim_3ds_falla: { marca: 'VISA', ultimos4: '1629', tipo: 'CREDITO', escenario: 'FALLA' },
  };
  const VIGENCIA_MS = 15 * 60 * 1000;
  const TARJETAS_MAXIMAS = 10;
  const ahora = () => new Date().toISOString();
  const siguiente = (coleccion) => {
    const ids = db.get(coleccion).map('id').value();
    return ids.length ? Math.max(...ids) + 1 : 1;
  };
  const folio = () => 'sim_pi_' + [...Array(24)].map(() => Math.floor(Math.random() * 16).toString(16)).join('');

  const publicoPago = (p) => ({
    id: p.id,
    ordenId: p.ordenId ?? null,
    pedidoId: p.pedidoId ?? null,
    vehiculoId: p.vehiculoId ?? null,
    monto: p.monto,
    moneda: p.moneda,
    medio: p.medio,
    marca: p.marca ?? null,
    ultimos4: p.ultimos4 ?? null,
    tipoTarjeta: p.tipoTarjeta ?? null,
    estado: p.estado,
    motivoFallo: p.motivoFallo ?? null,
    requiereAutenticacion: p.estado === 'PENDIENTE' && p.autenticacion === 'REQUERIDA',
    referencia: p.referencia,
    simulado: p.simulado,
    metodoPagoId: p.metodoPagoId ?? null,
    perfilFiscalId: p.perfilFiscalId ?? null,
    pagadoEn: p.pagadoEn ?? null,
    creadoEn: p.creadoEn,
    factura: publicaFactura(facturaDelPago(p.id)),
    facturable: p.estado === 'PAGADO' && p.medio !== 'CAJA' && !facturaDelPago(p.id),
  });
  const publicoMetodo = (m) => {
    const hoy = new Date();
    const vencida = m.anioVence < hoy.getFullYear() || (m.anioVence === hoy.getFullYear() && m.mesVence < hoy.getMonth() + 1);
    return {
      id: m.id,
      marca: m.marca,
      ultimos4: m.ultimos4,
      tipo: m.tipo,
      mesVence: m.mesVence,
      anioVence: m.anioVence,
      vencida,
      predeterminado: m.predeterminado,
      creadoEn: m.creadoEn,
    };
  };
  const metodosDe = (clienteId) =>
    db
      .get('metodosPago')
      .filter({ clienteId })
      .orderBy([(m) => (m.predeterminado ? 0 : 1), 'id'])
      .value();
  // ── facturas ──
  // V2-M08.06 · El timbrado simulado del backend (TimbradorSimulado, ADR
  // 0009): serie A, folio fiscal al azar, rechaza una razón social de
  // persona moral con el régimen societario («S.A. de C.V.») o un código
  // postal menor a 01000 con 422 TIMBRADO_RECHAZADO y `campos`. Se timbra
  // sola al quedar pagado con datos fiscales, o con POST /pagos/{id}/factura.
  const EMISOR = { rfc: 'EKU9003173C9', nombre: 'ESCUELA KEMPER URGATE', regimenFiscal: '601', codigoPostal: '42501' };
  const REGIMENES = new Set([
    'SA', 'SADECV', 'SAB', 'SABDECV', 'SAPI', 'SAPIDECV', 'SAS', 'SASDECV', 'SDERL', 'SDERLDECV', 'SDERLMI',
    'SC', 'SCDERL', 'AC', 'SCP', 'SPR', 'SPRDERL',
  ]);
  const facturaDelPago = (pagoId) => db.get('facturasApp').find({ pagoId }).value();
  const publicaFactura = (f) =>
    f
      ? {
          id: f.id,
          pagoId: f.pagoId,
          folio: f.folio,
          uuid: f.uuid,
          rfcReceptor: f.receptor.rfc,
          razonSocialReceptor: f.receptor.razonSocial,
          usoCfdi: f.receptor.usoCfdi,
          total: f.total,
          simulada: true,
          timbradaEn: f.timbradaEn,
        }
      : null;

  function rechazosDelTimbrado(perfil) {
    const campos = {};
    if (perfil.rfc.length === 12) {
      const palabras = perfil.razonSocial.toUpperCase().replace(/[.,]/g, ' ').split(/\s+/).filter(Boolean);
      for (let n = 1; n <= Math.min(8, palabras.length - 1); n++) {
        if (REGIMENES.has(palabras.slice(-n).join(''))) {
          campos.razonSocial = 'Escribe la razón social sin el régimen societario, como en la constancia';
          break;
        }
      }
    }
    if (Number(perfil.codigoPostal) < 1000) campos.codigoPostal = 'El código postal no existe en el catálogo del SAT';
    return campos;
  }

  function timbrar(pago, perfil) {
    const id = siguiente('facturasApp');
    const factura = {
      id,
      clienteId: pago.clienteId,
      pagoId: pago.id,
      folio: `A-${String(123 + id).padStart(6, '0')}`,
      uuid: crypto.randomUUID().toUpperCase(),
      receptor: {
        rfc: perfil.rfc,
        razonSocial: perfil.razonSocial,
        regimenFiscal: perfil.regimenFiscal,
        codigoPostal: perfil.codigoPostal,
        usoCfdi: perfil.usoCfdi,
      },
      formaPago: pago.tipoTarjeta === 'DEBITO' ? '28' : '04',
      total: pago.monto,
      timbradaEn: ahora(),
    };
    db.get('facturasApp').push(factura).write();
    pago.perfilFiscalId = perfil.id;
    db.get('pagosApp').find({ id: pago.id }).assign({ perfilFiscalId: perfil.id }).write();
    emitirEvento(pago.clienteId, 'factura.timbrada', { facturaId: id, pagoId: pago.id });
    return factura;
  }

  function xmlDe(f) {
    const base = (f.total / 1.16).toFixed(2);
    const iva = (f.total - Number(base)).toFixed(2);
    const fecha = f.timbradaEn.slice(0, 19);
    const r = f.receptor;
    const attr = (t) => String(t).replace(/&/g, '&amp;').replace(/"/g, '&quot;').replace(/</g, '&lt;');
    return (
      '<?xml version="1.0" encoding="UTF-8"?>\n' +
      '<cfdi:Comprobante xmlns:cfdi="http://www.sat.gob.mx/cfd/4" Version="4.0" Serie="A" ' +
      `Folio="${f.folio.slice(2)}" Fecha="${fecha}" FormaPago="${f.formaPago}" SubTotal="${base}" Moneda="MXN" ` +
      `Total="${f.total.toFixed(2)}" TipoDeComprobante="I" Exportacion="01" MetodoPago="PUE" ` +
      `LugarExpedicion="${EMISOR.codigoPostal}" Sello="SIMULADO" NoCertificado="00000000000000000000" Certificado="SIMULADO">\n` +
      `  <cfdi:Emisor Rfc="${EMISOR.rfc}" Nombre="${EMISOR.nombre}" RegimenFiscal="${EMISOR.regimenFiscal}"/>\n` +
      `  <cfdi:Receptor Rfc="${attr(r.rfc)}" Nombre="${attr(r.razonSocial)}" DomicilioFiscalReceptor="${attr(r.codigoPostal)}" ` +
      `RegimenFiscalReceptor="${attr(r.regimenFiscal)}" UsoCFDI="${attr(r.usoCfdi)}"/>\n` +
      '  <cfdi:Conceptos>\n' +
      `    <cfdi:Concepto ClaveProdServ="78181500" Cantidad="1" ClaveUnidad="E48" Descripcion="Pago ${f.pagoId} (API simulada)" ` +
      `ValorUnitario="${base}" Importe="${base}" ObjetoImp="02"/>\n` +
      '  </cfdi:Conceptos>\n' +
      `  <cfdi:Impuestos TotalImpuestosTrasladados="${iva}"/>\n` +
      '  <cfdi:Complemento>\n' +
      '    <tfd:TimbreFiscalDigital xmlns:tfd="http://www.sat.gob.mx/TimbreFiscalDigital" Version="1.1" ' +
      `UUID="${f.uuid}" FechaTimbrado="${fecha}" RfcProvCertif="SIM010101AA1" ` +
      'Leyenda="Factura simulada, sin validez fiscal" SelloCFD="SIMULADO" NoCertificadoSAT="00000000000000000000" SelloSAT="SIMULADO"/>\n' +
      '  </cfdi:Complemento>\n' +
      '</cfdi:Comprobante>\n'
    );
  }

  const pagadoDe = (ordenId) => db.get('pagosApp').find({ ordenId, estado: 'PAGADO' }).value();
  const pagadoDelPedido = (pedidoId) => db.get('pagosApp').find({ pedidoId, estado: 'PAGADO' }).value();

  function vencerPendientes(filtro) {
    const limite = Date.now() - VIGENCIA_MS;
    db.get('pagosApp')
      .filter((p) => p.estado === 'PENDIENTE' && Date.parse(p.creadoEn) <= limite)
      .filter(filtro)
      .each((p) => Object.assign(p, { estado: 'FALLIDO', motivoFallo: 'AUTENTICACION_VENCIDA', autenticacion: 'RECHAZADA' }))
      .value();
    db.write();
  }

  function puntosPorServicio(pago) {
    if (pago.ordenId == null) return;
    const yaSumo = db
      .get('movimientosPuntos')
      .find({ motivo: 'SERVICIO', referenciaTipo: 'ORDEN', referenciaId: pago.ordenId })
      .value();
    const puntos = Math.floor(pago.monto / 10);
    if (yaSumo || puntos <= 0) return;
    const ids = db.get('movimientosPuntos').map('id').value();
    db.get('movimientosPuntos')
      .push({
        id: ids.length ? Math.max(...ids) + 1 : 1,
        clienteId: pago.clienteId,
        puntos,
        motivo: 'SERVICIO',
        referenciaTipo: 'ORDEN',
        referenciaId: pago.ordenId,
        creadoEn: ahora(),
      })
      .write();
    const saldo = db.get('movimientosPuntos').filter({ clienteId: pago.clienteId }).map('puntos').sum().value();
    emitirEvento(pago.clienteId, 'puntos.movidos', { puntos, motivo: 'SERVICIO', saldo });
  }

  function confirmar(pago) {
    if (pago.guardar) {
      const existente = db.get('metodosPago').find({ clienteId: pago.clienteId, token: pago.token });
      if (existente.value()) {
        existente.assign({ mesVence: pago.mesVence, anioVence: pago.anioVence }).write();
        pago.metodoPagoId = existente.value().id;
      } else if (metodosDe(pago.clienteId).length < TARJETAS_MAXIMAS) {
        const id = siguiente('metodosPago');
        db.get('metodosPago')
          .push({
            id,
            clienteId: pago.clienteId,
            procesador: 'SIMULADO',
            clienteProcesadorId: `sim_cus_${pago.clienteId}`,
            token: pago.token,
            marca: pago.marca,
            ultimos4: pago.ultimos4,
            tipo: pago.tipoTarjeta,
            mesVence: pago.mesVence,
            anioVence: pago.anioVence,
            predeterminado: metodosDe(pago.clienteId).length === 0,
            creadoEn: ahora(),
          })
          .write();
        pago.metodoPagoId = id;
      }
    }
    puntosPorServicio(pago);
    if (pago.pedidoId != null) {
      db.get('pedidosTienda').find({ id: pago.pedidoId }).assign({ pagadoEn: pago.pagadoEn }).write();
    }
    emitirEvento(pago.clienteId, 'pago.confirmado', {
      pagoId: pago.id,
      ordenId: pago.ordenId ?? null,
      pedidoId: pago.pedidoId ?? null,
      estado: 'PAGADO',
    });
    const perfil = pago.perfilFiscalId == null ? null : db.get('perfilesFiscales').find({ id: pago.perfilFiscalId }).value();
    if (perfil && pago.medio !== 'CAJA' && Object.keys(rechazosDelTimbrado(perfil)).length === 0) {
      timbrar(pago, perfil);
    }
  }

  function aplicar(pago, respuesta) {
    if (respuesta === 'APROBADO') {
      Object.assign(pago, { estado: 'PAGADO', pagadoEn: ahora() });
      if (pago.autenticacion === 'REQUERIDA') pago.autenticacion = 'APROBADA';
      confirmar(pago);
    } else if (respuesta === 'RECHAZADO_FONDOS' || respuesta === 'RECHAZADO_AUTENTICACION') {
      Object.assign(pago, {
        estado: 'FALLIDO',
        motivoFallo: respuesta === 'RECHAZADO_FONDOS' ? 'FONDOS_INSUFICIENTES' : 'AUTENTICACION_FALLIDA',
      });
      if (pago.autenticacion === 'REQUERIDA') pago.autenticacion = 'RECHAZADA';
    } else {
      pago.autenticacion = 'REQUERIDA';
    }
  }

  // Lo comun de pagar una orden o un pedido. `objetivo` dice cual es y
  // `revisar` responde el 404 o 409 propio, o devuelve el monto y el vehiculo.
  function cobrar(req, res, objetivo, revisar) {
    const clienteId = req.sesion.clienteId;
    const { ordenId = null, pedidoId = null } = objetivo;
    const llave = String(req.get('Idempotency-Key') || '').trim();
    if (llave.length < 8 || llave.length > 64) {
      return problema(req, res, 400, 'La llave Idempotency-Key debe tener entre 8 y 64 caracteres', 'DATOS_INVALIDOS');
    }
    const cuerpo = req.body || {};
    const conToken = Boolean(cuerpo.tarjeta && cuerpo.tarjeta.token);
    const conBilletera = cuerpo.billetera != null;
    if ([conToken, cuerpo.metodoPagoId != null, conBilletera].filter(Boolean).length !== 1) {
      return problema(req, res, 400, 'Paga con una tarjeta nueva, una guardada o una billetera, solo una', 'DATOS_INVALIDOS');
    }
    if (conBilletera && !['APPLE_PAY', 'GOOGLE_PAY'].includes(cuerpo.billetera)) {
      return problema(req, res, 400, 'La billetera es APPLE_PAY o GOOGLE_PAY', 'DATOS_INVALIDOS');
    }
    const repetido = db.get('pagosApp').find({ clienteId, llave }).value();
    if (repetido) {
      if ((repetido.ordenId ?? null) !== ordenId || (repetido.pedidoId ?? null) !== pedidoId) {
        return problema(req, res, 400, 'Esa llave Idempotency-Key ya se usó para pagar otra orden o pedido', 'DATOS_INVALIDOS');
      }
      return res.status(200).jsonp(publicoPago(repetido));
    }
    const cobro = revisar();
    if (!cobro) return;
    const delMismo = (p) => (ordenId != null ? p.ordenId === ordenId : p.pedidoId === pedidoId);
    vencerPendientes(delMismo);
    if (db.get('pagosApp').find((p) => delMismo(p) && p.estado === 'PENDIENTE').value()) {
      const de = ordenId != null ? 'esta orden' : 'este pedido';
      return problema(req, res, 409, `Ya hay un pago de ${de} esperando la confirmación de tu banco`, 'PAGO_EN_CURSO');
    }
    let token;
    let mesVence;
    let anioVence;
    let metodoPagoId = null;
    if (conBilletera) {
      token = cuerpo.billetera === 'APPLE_PAY' ? 'tok_sim_apple_pay' : 'tok_sim_google_pay';
    } else if (conToken) {
      token = String(cuerpo.tarjeta.token).trim();
      mesVence = Number(cuerpo.tarjeta.mesVence);
      anioVence = Number(cuerpo.tarjeta.anioVence);
      if (!TARJETAS[token]) return problema(req, res, 400, 'Esa tarjeta no es una de las tarjetas de prueba', 'DATOS_INVALIDOS');
      const hoy = new Date();
      const valido = Number.isInteger(mesVence) && mesVence >= 1 && mesVence <= 12 && Number.isInteger(anioVence);
      const vencida = !valido || anioVence < hoy.getFullYear() || (anioVence === hoy.getFullYear() && mesVence < hoy.getMonth() + 1);
      if (vencida || anioVence > hoy.getFullYear() + 20) return problema(req, res, 400, 'La tarjeta ya venció', 'DATOS_INVALIDOS');
    } else {
      const metodo = db.get('metodosPago').find({ id: Number(cuerpo.metodoPagoId), clienteId }).value();
      if (!metodo) return noEncontrado(req, res);
      if (publicoMetodo(metodo).vencida) return problema(req, res, 400, 'La tarjeta guardada ya venció', 'DATOS_INVALIDOS');
      ({ token, mesVence, anioVence } = metodo);
      metodoPagoId = metodo.id;
    }
    const perfilFiscalId = cuerpo.perfilFiscalId == null ? null : Number(cuerpo.perfilFiscalId);
    if (perfilFiscalId != null && !db.get('perfilesFiscales').find({ id: perfilFiscalId, clienteId }).value()) {
      return noEncontrado(req, res);
    }
    const tarjeta = conBilletera
      ? { marca: null, ultimos4: null, tipo: 'CREDITO', escenario: 'APROBADA' }
      : TARJETAS[token];
    const pago = {
      id: siguiente('pagosApp'),
      clienteId,
      ordenId,
      pedidoId,
      vehiculoId: cobro.vehiculoId,
      monto: cobro.monto,
      moneda: 'MXN',
      medio: conBilletera ? cuerpo.billetera : 'TARJETA',
      marca: tarjeta.marca,
      ultimos4: tarjeta.ultimos4,
      tipoTarjeta: tarjeta.tipo,
      estado: 'PENDIENTE',
      motivoFallo: null,
      autenticacion: null,
      referencia: folio(),
      simulado: true,
      metodoPagoId,
      perfilFiscalId,
      pagadoEn: null,
      creadoEn: ahora(),
      token,
      llave,
      guardar: conToken && cuerpo.guardarTarjeta === true,
      mesVence,
      anioVence,
    };
    const respuesta = {
      APROBADA: 'APROBADO',
      FONDOS: 'RECHAZADO_FONDOS',
      CONFIRMAR: 'PIDE_AUTENTICACION',
      FALLA: 'PIDE_AUTENTICACION',
    }[tarjeta.escenario];
    aplicar(pago, respuesta);
    db.get('pagosApp').push(pago).write();
    res.status(201).jsonp(publicoPago(pago));
  }

  servidor.post(`${BASE}/ordenes/:ordenId/pagos`, (req, res) => {
    const ordenId = Number(req.params.ordenId);
    cobrar(req, res, { ordenId }, () => {
      const servicio = db.get('servicios').find({ id: ordenId }).value();
      if (!servicio || !vehiculoDelCliente(req, servicio.vehiculoId)) {
        noEncontrado(req, res);
        return null;
      }
      if (pagadoDe(ordenId)) {
        problema(req, res, 409, 'La orden ya está pagada', 'ORDEN_NO_PAGABLE');
        return null;
      }
      if (!['TERMINADO', 'ENTREGADO'].includes(servicio.estatus) || !(servicio.total > 0) || servicio.delTaller !== true) {
        problema(req, res, 409, 'La orden no se puede pagar en la app', 'ORDEN_NO_PAGABLE');
        return null;
      }
      return { monto: servicio.total, vehiculoId: servicio.vehiculoId };
    });
  });

  // V2-M14.04: mismo cuerpo, mismas respuestas y mismo Pago que una orden.
  servidor.post(`${BASE}/pedidos/:pedidoId/pagos`, (req, res) => {
    const pedidoId = Number(req.params.pedidoId);
    cobrar(req, res, { pedidoId }, () => {
      const pedido = db.get('pedidosTienda').find({ id: pedidoId }).value();
      if (!pedido || pedido.clienteId !== req.sesion.clienteId) {
        noEncontrado(req, res);
        return null;
      }
      const vencido = pedido.venceEn && Date.parse(pedido.venceEn) <= Date.now();
      if (pagadoDelPedido(pedidoId) || !['apartado', 'listo'].includes(pedido.estado) || vencido || !(pedido.total > 0)) {
        problema(req, res, 409, 'El pedido no se puede pagar en la app', 'PEDIDO_NO_PAGABLE');
        return null;
      }
      return { monto: pedido.total, vehiculoId: null };
    });
  });

  servidor.post(`${BASE}/pagos/:pagoId/autenticacion`, (req, res) => {
    const clienteId = req.sesion.clienteId;
    const registro = db.get('pagosApp').find({ id: Number(req.params.pagoId), clienteId });
    const pago = registro.value();
    if (!pago) return noEncontrado(req, res);
    if (typeof (req.body || {}).confirmada !== 'boolean') {
      return problema(req, res, 400, 'Falta confirmada', 'DATOS_INVALIDOS');
    }
    vencerPendientes((p) => p.id === pago.id);
    if (pago.estado !== 'PENDIENTE' || pago.autenticacion !== 'REQUERIDA') {
      if (pago.motivoFallo === 'AUTENTICACION_VENCIDA') return res.jsonp(publicoPago(pago));
      return problema(req, res, 409, 'El pago ya no espera la confirmación de tu banco', 'PAGO_NO_PENDIENTE');
    }
    const confirmada = req.body.confirmada;
    const falla = TARJETAS[pago.token] && TARJETAS[pago.token].escenario === 'FALLA';
    aplicar(pago, confirmada && !falla ? 'APROBADO' : 'RECHAZADO_AUTENTICACION');
    registro.assign(pago).write();
    res.jsonp(publicoPago(pago));
  });

  servidor.get(`${BASE}/pagos`, (req, res) => {
    const clienteId = req.sesion.clienteId;
    vencerPendientes((p) => p.clienteId === clienteId);
    const pagos = db
      .get('pagosApp')
      .filter({ clienteId })
      .orderBy(['creadoEn', 'id'], ['desc', 'desc'])
      .value()
      .map(publicoPago);
    paginar(req, res, pagos);
  });

  servidor.get(`${BASE}/pagos/:pagoId`, (req, res) => {
    const clienteId = req.sesion.clienteId;
    vencerPendientes((p) => p.clienteId === clienteId);
    const pago = db.get('pagosApp').find({ id: Number(req.params.pagoId), clienteId }).value();
    if (!pago) return noEncontrado(req, res);
    res.jsonp(publicoPago(pago));
  });

  servidor.post(`${BASE}/pagos/:pagoId/factura`, (req, res) => {
    const clienteId = req.sesion.clienteId;
    const pago = db.get('pagosApp').find({ id: Number(req.params.pagoId), clienteId }).value();
    if (!pago) return noEncontrado(req, res);
    const perfilFiscalId = (req.body || {}).perfilFiscalId;
    if (perfilFiscalId == null) return problema(req, res, 400, 'Falta perfilFiscalId', 'DATOS_INVALIDOS');
    const perfil = db.get('perfilesFiscales').find({ id: Number(perfilFiscalId), clienteId }).value();
    if (!perfil) return noEncontrado(req, res);
    if (facturaDelPago(pago.id)) return problema(req, res, 409, 'El pago ya tiene factura', 'YA_FACTURADO');
    if (pago.estado !== 'PAGADO' || pago.medio === 'CAJA') {
      return problema(req, res, 409, 'El pago no se puede facturar desde la app', 'PAGO_NO_FACTURABLE');
    }
    const campos = rechazosDelTimbrado(perfil);
    if (Object.keys(campos).length > 0) {
      return res.status(422).jsonp({
        timestamp: new Date().toISOString(),
        status: 422,
        error: 'Unprocessable Entity',
        message: 'El timbrado rechazó los datos fiscales',
        codigo: 'TIMBRADO_RECHAZADO',
        campos,
        path: req.originalUrl.split('?')[0],
      });
    }
    res.status(201).jsonp(publicaFactura(timbrar(pago, perfil)));
  });

  servidor.get(`${BASE}/facturas/:facturaId/:formato(pdf|xml)`, (req, res) => {
    const factura = db.get('facturasApp').find({ id: Number(req.params.facturaId), clienteId: req.sesion.clienteId }).value();
    if (!factura) return noEncontrado(req, res);
    const nombre = `factura-${factura.folio}.${req.params.formato}`;
    res.set('Content-Disposition', `attachment; filename="${nombre}"`);
    res.set('Cache-Control', 'no-store');
    if (req.params.formato === 'xml') return res.type('application/xml').send(xmlDe(factura));
    const r = factura.receptor;
    res.type('application/pdf').send(
      construirTicketPdf([
        'FACTURA SIMULADA, SIN VALIDEZ FISCAL (API simulada)',
        '',
        `Folio ${factura.folio}`,
        `Folio fiscal: ${factura.uuid}`,
        `Emisor: ${EMISOR.nombre} (${EMISOR.rfc})`,
        `Receptor: ${r.razonSocial} (${r.rfc}) - Uso del CFDI ${r.usoCfdi}`,
        `Total: $${factura.total.toFixed(2)} MXN - Forma de pago ${factura.formaPago} - PUE`,
        '',
        'Este documento no es un CFDI: el timbre y los sellos son simulados.',
      ]),
    );
  });

  servidor.get(`${BASE}/metodos-pago`, (req, res) => {
    res.jsonp(metodosDe(req.sesion.clienteId).map(publicoMetodo));
  });

  servidor.put(`${BASE}/metodos-pago/:metodoPagoId/predeterminado`, (req, res) => {
    const clienteId = req.sesion.clienteId;
    const metodo = db.get('metodosPago').find({ id: Number(req.params.metodoPagoId), clienteId }).value();
    if (!metodo) return noEncontrado(req, res);
    db.get('metodosPago').filter({ clienteId }).each((m) => { m.predeterminado = m.id === metodo.id; }).value();
    db.write();
    res.jsonp(publicoMetodo(db.get('metodosPago').find({ id: metodo.id }).value()));
  });

  // Si era la predeterminada, lo es la mas vieja de las que quedan. Los pagos
  // hechos con ella se conservan sin la referencia.
  servidor.delete(`${BASE}/metodos-pago/:metodoPagoId`, (req, res) => {
    const clienteId = req.sesion.clienteId;
    const metodo = db.get('metodosPago').find({ id: Number(req.params.metodoPagoId), clienteId }).value();
    if (!metodo) return noEncontrado(req, res);
    db.get('metodosPago').remove({ id: metodo.id }).write();
    db.get('pagosApp').filter({ metodoPagoId: metodo.id }).each((p) => { p.metodoPagoId = null; }).value();
    db.write();
    if (metodo.predeterminado) {
      const otra = metodosDe(clienteId)[0];
      if (otra) db.get('metodosPago').find({ id: otra.id }).assign({ predeterminado: true }).write();
    }
    res.status(204).end();
  });

  // Solo del simulador (en el backend es de la caja): la orden se cobro en el
  // mostrador. Un intento que esperaba el 3-D Secure queda fallido.
  servidor.post('/__mock/ordenes/:ordenId/pagada-en-caja', (req, res) => {
    const ordenId = Number(req.params.ordenId);
    const servicio = db.get('servicios').find({ id: ordenId }).value();
    if (!servicio) return noEncontrado(req, res);
    if (pagadoDe(ordenId)) return problema(req, res, 409, 'La orden ya está pagada', 'ORDEN_NO_PAGABLE');
    if (!['TERMINADO', 'ENTREGADO'].includes(servicio.estatus) || !(servicio.total > 0)) {
      return problema(req, res, 409, 'La orden aún no está lista para cobrarse', 'ORDEN_NO_PAGABLE');
    }
    const vehiculo = db.get('vehiculos').find({ id: servicio.vehiculoId }).value();
    db.get('pagosApp')
      .filter({ ordenId, estado: 'PENDIENTE' })
      .each((p) => Object.assign(p, { estado: 'FALLIDO', motivoFallo: 'PAGADA_EN_CAJA', autenticacion: 'RECHAZADA' }))
      .value();
    const pago = {
      id: siguiente('pagosApp'),
      clienteId: vehiculo ? vehiculo.clienteId : null,
      ordenId,
      vehiculoId: servicio.vehiculoId,
      monto: servicio.total,
      moneda: 'MXN',
      medio: 'CAJA',
      estado: 'PAGADO',
      referencia: String((req.body || {}).referencia || `caja_${folio()}`),
      simulado: false,
      metodoPagoId: null,
      perfilFiscalId: null,
      pagadoEn: ahora(),
      creadoEn: ahora(),
    };
    db.get('pagosApp').push(pago).write();
    if (pago.clienteId != null) confirmar(pago);
    res.status(201).jsonp(publicoPago(pago));
  });
};
