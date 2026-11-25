const BASE = '/api/v1/app';

const TEXTO_ESTADO = {
  400: 'Bad Request',
  401: 'Unauthorized',
  403: 'Forbidden',
  404: 'Not Found',
  409: 'Conflict',
  422: 'Unprocessable Entity',
  429: 'Too Many Requests',
};

function problema(req, res, status, mensaje, codigo) {
  const cuerpo = {
    timestamp: new Date().toISOString(),
    status,
    error: TEXTO_ESTADO[status] || 'Error',
    message: mensaje,
    path: req.originalUrl.split('?')[0],
  };
  // `codigo` es opcional en el contrato v1.1 (RIC-15). Se manda cuando se
  // conoce, para que la app decida sin leer el texto.
  if (codigo) cuerpo.codigo = codigo;
  res.status(status).jsonp(cuerpo);
}

// El contrato dice que un recurso ajeno responde 404, no 403: la app no debe
// poder distinguir "no existe" de "no es tuyo".
const noEncontrado = (req, res) =>
  problema(req, res, 404, 'No existe o no pertenece al cliente');

// Arma la respuesta paginada del contrato (PaginaServicios, PaginaCitas).
function paginar(req, res, todo) {
  const pagina = req.query.pagina === undefined ? 0 : Number(req.query.pagina);
  const tamano = req.query.tamano === undefined ? 20 : Number(req.query.tamano);
  if (!Number.isInteger(pagina) || pagina < 0 || !Number.isInteger(tamano) || tamano < 1 || tamano > 100) {
    return problema(req, res, 400, 'pagina o tamano no son validos', 'DATOS_INVALIDOS');
  }
  res.jsonp({
    contenido: todo.slice(pagina * tamano, (pagina + 1) * tamano),
    pagina,
    tamano,
    totalElementos: todo.length,
    totalPaginas: Math.ceil(todo.length / tamano),
  });
}

const ES_FECHA = /^\d{4}-\d{2}-\d{2}$/;

const sinContrato = (res, status, mensaje) => res.status(status).json({ error: mensaje });

module.exports = { BASE, problema, noEncontrado, paginar, ES_FECHA, sinContrato };
