const { BASE } = require('../comun/http');
const { leerSemillas } = require('../datos');
const { crearServidor } = require('../server');

const servidor = crearServidor(leerSemillas(), { logger: false });

// json-server 0.17.4 usa Express 4. Su tabla de rutas incluye solo las
// operaciones registradas en el servidor, sin inferirlas del texto del módulo.
const operaciones = servidor._router.stack
  .map((capa) => capa.route)
  .filter((ruta) => ruta?.path.startsWith(`${BASE}/`))
  .flatMap((ruta) => {
    const plantilla = ruta.path.slice(BASE.length).replace(/:(\w+)/g, '{$1}');
    return Object.keys(ruta.methods).map((metodo) => `${metodo.toUpperCase()} ${plantilla}`);
  });

const escucha = servidor.listen(0, '127.0.0.1', () => {
  console.log(JSON.stringify({
    base: `http://127.0.0.1:${escucha.address().port}${BASE}`,
    operaciones,
  }));
});
