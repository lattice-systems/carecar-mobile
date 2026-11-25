const zlib = require('node:zlib');
const { BASE, problema, noEncontrado } = require('../comun/http');

module.exports = function registrarTaller(servidor, db, vehiculoDelCliente) {
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
};
