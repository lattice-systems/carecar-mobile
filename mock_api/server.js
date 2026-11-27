// Ensambla los módulos sobre una sola base de desarrollo.
const fs = require('node:fs');
const jsonServer = require('json-server');
const { BASE, problema } = require('./comun/http');
const { RUTA_DB, restaurarSemillas } = require('./datos');

if (!fs.existsSync(RUTA_DB)) restaurarSemillas();

const PUERTO = Number(process.env.PORT) || 3000;
const servidor = jsonServer.create();
const router = jsonServer.router(RUTA_DB);
const db = router.db;

servidor.use(jsonServer.defaults({ logger: true }));
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
require('./modulos/privacidad')(servidor, db, emitirEvento);
require('./modulos/taller')(servidor, db, vehiculoDelCliente, emitirEvento);
require('./modulos/bitacora')(servidor, db, vehiculoDelCliente);
require('./modulos/garantia')(servidor, db, vehiculoDelCliente, emitirEvento);
require('./modulos/valuacion')(servidor, db, vehiculoDelCliente, emitirEvento);
require('./modulos/lealtad')(servidor, db, emitirEvento);
require('./modulos/pagos')(servidor, db, vehiculoDelCliente, emitirEvento);
require('./modulos/tienda')(servidor, db, vehiculoDelCliente, emitirEvento);
require('./modulos/sucursales')(servidor, db);

// Devuelve Problema para cualquier otra ruta de la app.
servidor.use(BASE, (req, res) => {
  problema(req, res, 404, 'Esa ruta no existe en el contrato');
});

// json-server queda al final: sirve /cuentas, /vehiculos y las demas colecciones
// sin el prefijo del contrato, util para inspeccionar el estado durante el
// desarrollo. No forma parte del contrato.
servidor.use(router);

servidor.listen(PUERTO, () => {
  console.log('');
  console.log(`API simulada de CareCar escuchando en http://localhost:${PUERTO}${BASE}`);
  console.log(`Estado vivo: ${RUTA_DB}`);
  console.log('Restaurar los datos iniciales: npm run reset');
  console.log('');
});
