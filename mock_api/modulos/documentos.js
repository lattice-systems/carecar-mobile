const { BASE, noEncontrado, problema } = require('../comun/http');

const construirPdf = require('../comun/ticket_pdf');

const MAXIMO = 5 * 1024 * 1024;
const TIPOS = new Set(['POLIZA', 'TARJETA_CIRCULACION', 'VERIFICACION', 'TENENCIA', 'LICENCIA', 'GARANTIA', 'FACTURA', 'OTRO']);

async function leerFormulario(req) {
  const partes = [];
  let total = 0;
  for await (const parte of req.iterator({ destroyOnReturn: false })) {
    total += parte.length;
    if (total > MAXIMO + 8192) {
      req.resume();
      return null;
    }
    partes.push(parte);
  }
  return new Response(Buffer.concat(partes), {
    headers: { 'content-type': req.get('content-type') || '' },
  }).formData();
}

function fechaValida(fecha) {
  if (typeof fecha !== 'string' || !/^\d{4}-\d{2}-\d{2}$/.test(fecha)) return false;
  const dia = new Date(fecha);
  return Number.isFinite(dia.getTime()) && dia.toISOString().slice(0, 10) === fecha;
}

module.exports = function registrarDocumentos(servidor, db, vehiculoDelCliente) {
  // ── documentos ──
  // V2-M09.01 · como el contrato: el estado lo calcula el servidor con la fecha
  // de la agencia (America/Mexico_City, sin horario de verano: UTC-6), nunca con
  // la del telefono. POR_VENCER es de 0 a 30 dias. Orden: el que vence primero
  // arriba y los que no tienen fecha al final. Un vehiculo ajeno es 404.
  //
  // En la semilla un documento puede traer `venceEnDias` (relativo a hoy) en vez
  // de `venceEn`, para que el ejemplo siga mostrando los cuatro estados sin
  // tener que mover fechas a mano.
  db.defaults({ documentos: [] }).write();

  const DESFASE_AGENCIA_MS = 6 * 60 * 60 * 1000;
  const MS_POR_DIA = 24 * 60 * 60 * 1000;
  const DIAS_POR_VENCER = 30;

  const hoyEnLaAgencia = () => new Date(Date.now() - DESFASE_AGENCIA_MS).toISOString().slice(0, 10);
  const sumarDias = (fecha, n) => new Date(Date.parse(fecha) + n * MS_POR_DIA).toISOString().slice(0, 10);
  const diasEntre = (desde, hasta) => Math.round((Date.parse(hasta) - Date.parse(desde)) / MS_POR_DIA);

  function comoDocumento(d, hoy) {
    const venceEn = d.venceEn ?? (d.venceEnDias == null ? null : sumarDias(hoy, d.venceEnDias));
    const diasRestantes = venceEn == null ? null : diasEntre(hoy, venceEn);
    let estado = 'SIN_FECHA';
    if (diasRestantes != null) {
      if (diasRestantes < 0) estado = 'VENCIDO';
      else if (diasRestantes <= DIAS_POR_VENCER) estado = 'POR_VENCER';
      else estado = 'VIGENTE';
    }
    return {
      id: d.id,
      vehiculoId: d.vehiculoId,
      tipo: d.tipo,
      titulo: d.titulo ?? null,
      numero: d.numero ?? null,
      emitidoEn: d.emitidoEn ?? null,
      venceEn,
      estado,
      diasRestantes,
      origen: d.origen,
      tieneArchivo: Boolean(d.tieneArchivo),
      aseguradora: d.tipo === 'POLIZA' ? d.aseguradora ?? null : null,
      telefonoAseguradora: d.tipo === 'POLIZA' ? d.telefonoAseguradora ?? null : null,
    };
  }

  servidor.get(`${BASE}/vehiculos/:vehiculoId/documentos`, (req, res) => {
    const vehiculo = vehiculoDelCliente(req, req.params.vehiculoId);
    if (!vehiculo) return noEncontrado(req, res);

    const hoy = hoyEnLaAgencia();
    const lista = db
      .get('documentos')
      .filter({ vehiculoId: vehiculo.id })
      .value()
      .map((d) => comoDocumento(d, hoy))
      .sort((a, b) => {
        if (a.venceEn == null || b.venceEn == null) return (a.venceEn == null) - (b.venceEn == null) || a.id - b.id;
        return a.venceEn.localeCompare(b.venceEn) || a.id - b.id;
      });
    res.jsonp(lista);
  });

  servidor.get(`${BASE}/documentos/:documentoId/archivo`, (req, res) => {
    const id = Number(req.params.documentoId);
    const documentos = db.get('documentos').value() ?? [];
    const documento = documentos.find((doc) => doc.id === id);
    if (!documento?.tieneArchivo || !vehiculoDelCliente(req, documento.vehiculoId)) return noEncontrado(req, res);

    if (documento.origen === 'CLIENTE') {
      if (!documento.jpeg) return noEncontrado(req, res);
      res.set('Cache-Control', 'no-store').type('image/jpeg');
      return res.send(Buffer.from(documento.jpeg, 'base64'));
    }

    const titulo = documento.tipo === 'FACTURA' ? 'Factura de compra' : 'Póliza de garantía';
    res.set('Cache-Control', 'no-store').type('application/pdf');
    return res.send(construirPdf([titulo, 'Documento de ejemplo de CareCar']));
  });

  servidor.post(`${BASE}/vehiculos/:vehiculoId/documentos`, async (req, res) => {
    const vehiculo = vehiculoDelCliente(req, req.params.vehiculoId);
    if (!vehiculo) return noEncontrado(req, res);

    const invalido = () => problema(req, res, 400, 'Indica un tipo y una imagen JPEG de hasta 5 MB');
    let formulario;
    try {
      formulario = await leerFormulario(req);
    } catch {
      return invalido();
    }
    if (!formulario) return invalido();
    const tipo = formulario.get('tipo');
    const venceEn = formulario.get('venceEn');
    const titulo = formulario.get('titulo');
    const archivo = formulario.get('archivo');
    if ((tipo === 'OTRO' && (typeof titulo !== 'string' || !titulo.trim()))
        || (titulo !== null && (typeof titulo !== 'string' || titulo.trim().length > 80))
        || !TIPOS.has(tipo) || (venceEn !== null && !fechaValida(venceEn))
        || archivo?.type !== 'image/jpeg' || archivo.size < 5 || archivo.size > MAXIMO) {
      return invalido();
    }
    const firma = new Uint8Array(await archivo.slice(0, 3).arrayBuffer());
    const fin = new Uint8Array(await archivo.slice(-2).arrayBuffer());
    if (firma[0] !== 255 || firma[1] !== 216 || firma[2] !== 255 || fin[0] !== 255 || fin[1] !== 217) {
      return invalido();
    }

    const documentos = db.get('documentos').value() ?? [];
    const id = documentos.reduce((maximo, documento) => Math.max(maximo, documento.id), 0) + 1;
    const documento = { id, vehiculoId: vehiculo.id, tipo, titulo: titulo?.trim() ?? null, venceEn, origen: 'CLIENTE', tieneArchivo: true };
    const jpeg = Buffer.from(await archivo.arrayBuffer()).toString('base64');
    db.set('documentos', [...documentos, { ...documento, jpeg }]).write();
    return res.status(201).jsonp(comoDocumento(documento, hoyEnLaAgencia()));
  });
};
