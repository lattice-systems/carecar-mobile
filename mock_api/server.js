// Ensambla los módulos sobre una sola base de desarrollo.
const fs = require('node:fs');
const jsonServer = require('json-server');
const { BASE, problema } = require('./comun/http');
const { RUTA_DB, restaurarSemillas } = require('./datos');

function crearServidor(datos, { logger = true } = {}) {
  const servidor = jsonServer.create();
  const router = jsonServer.router(datos);
  const db = router.db;

  servidor.use(jsonServer.defaults({ logger }));
  servidor.use(jsonServer.bodyParser);

  require('./modulos/acceso')(servidor, db);
  const vehiculoDelCliente = require('./modulos/vehiculos')(servidor, db);
  const emitirEvento = require('./modulos/eventos')(servidor);
  const recoleccion = require('./modulos/recoleccion')(servidor, db, emitirEvento);
  require('./modulos/historial')(servidor, db, vehiculoDelCliente);
  require('./modulos/citas')(servidor, db, vehiculoDelCliente, recoleccion);
  require('./modulos/asistencia')(servidor, vehiculoDelCliente, emitirEvento);
  require('./modulos/mantenimiento')(servidor, db, vehiculoDelCliente);
  require('./modulos/catalogo')(servidor, db, vehiculoDelCliente);
  require('./modulos/asistente')(servidor, vehiculoDelCliente);
  require('./modulos/estreno')(servidor, db);
  require('./modulos/taller')(servidor, db, vehiculoDelCliente);
  require('./modulos/bitacora')(servidor, db, vehiculoDelCliente);

  servidor.use(BASE, (req, res) => {
    problema(req, res, 404, 'Esa ruta no existe en el contrato');
  });

  // Las colecciones sin el prefijo de la app sirven para inspeccionar datos.
  servidor.use(router);
  return servidor;
}

if (require.main === module) {
  if (!fs.existsSync(RUTA_DB)) restaurarSemillas();
  const puerto = Number(process.env.PORT) || 3000;
  crearServidor(RUTA_DB).listen(puerto, () => {
    console.log('');
    console.log(`API simulada de CareCar escuchando en http://localhost:${puerto}${BASE}`);
    console.log(`Estado vivo: ${RUTA_DB}`);
    console.log('Restaurar los datos iniciales: npm run reset');
    console.log('');
  });
}

module.exports = { crearServidor };
