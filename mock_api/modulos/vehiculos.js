const { BASE, noEncontrado } = require('../comun/http');

module.exports = function registrarVehiculos(servidor, db) {
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
    // La fecha del km NO viaja aqui: el contrato 2.11.0 la trae en el plan de
    // mantenimiento (`kmActualizadoEn` y `kmFuente`), no en el vehiculo. El seed
    // la guarda como `kilometrajeActualizadoEn` solo para armar ese plan.
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

  return vehiculoDelCliente;
};
