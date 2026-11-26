const { BASE } = require('../comun/http');
const { leerSemillas } = require('../datos');
const { crearServidor } = require('../server');

const datos = leerSemillas();
const hoy = new Date();
datos.citas = [];
// Incluye mañana para el emulador y los husos horarios a ambos lados de UTC.
datos.franjas = [-1, 0, 1, 2, 3].map((desfase, indice) => ({
  id: indice + 1,
  fecha: new Date(Date.UTC(hoy.getUTCFullYear(), hoy.getUTCMonth(), hoy.getUTCDate() + desfase))
    .toISOString().slice(0, 10),
  horaInicio: '09:00',
  horaFin: '10:00',
  cupoDisponible: 2,
}));

const puerto = Number(process.env.PORT ?? 3000);
const escucha = crearServidor(datos, { logger: false }).listen(puerto, '127.0.0.1', () => {
  console.log(`http://127.0.0.1:${escucha.address().port}${BASE}`);
});
