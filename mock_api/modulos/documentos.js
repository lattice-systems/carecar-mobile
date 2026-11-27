const { BASE, noEncontrado } = require('../comun/http');

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
};
