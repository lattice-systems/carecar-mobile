const fs = require('node:fs');
const path = require('node:path');

const origen = process.argv[2] ?? 'coverage/lcov.info';
const registrados = new Map();
let actual;

for (const linea of fs.readFileSync(origen, 'utf8').split(/\r?\n/)) {
  if (linea.startsWith('SF:')) {
    const archivo = path.relative(process.cwd(), path.resolve(linea.slice(3)))
      .split(path.sep).join('/');
    actual = undefined;
    if (archivo.startsWith('lib/')) {
      if (!registrados.has(archivo)) registrados.set(archivo, new Map());
      actual = registrados.get(archivo);
    }
  } else if (linea.startsWith('DA:') && actual) {
    const [numero, veces] = linea.slice(3).split(',').map(Number);
    actual.set(numero, (actual.get(numero) ?? false) || veces > 0);
  } else if (linea === 'end_of_record') {
    actual = undefined;
  }
}

const fuentes = fs.readdirSync('lib', { recursive: true, withFileTypes: true })
  .filter((entrada) => entrada.isFile() && entrada.name.endsWith('.dart'))
  .map((entrada) => path.join(entrada.parentPath, entrada.name).split(path.sep).join('/'));

function fila(nombre, incluye, meta = '—') {
  let lineas = 0;
  let cubiertas = 0;
  let conDatos = 0;
  const archivos = fuentes.filter(incluye);
  for (const archivo of archivos) {
    const datos = registrados.get(archivo);
    if (!datos?.size) continue;
    conDatos++;
    lineas += datos.size;
    cubiertas += Array.from(datos.values()).filter(Boolean).length;
  }
  const porcentaje = lineas === 0 ? 'Sin datos' : `${(100 * cubiertas / lineas).toFixed(1)} %`;
  return `| ${nombre} | ${porcentaje} | ${cubiertas}/${lineas} | ${conDatos}/${archivos.length} | ${meta} |`;
}

if (![...registrados.values()].some((lineas) => lineas.size > 0)) {
  throw new Error('LCOV no contiene líneas de lib/. Ejecuta flutter test --coverage desde la raíz.');
}

console.log([
  '## Cobertura de CareCar',
  '',
  '| Área | Cobertura | Líneas ejecutadas/instrumentadas | Archivos con datos/total | Meta |',
  '| --- | ---: | ---: | ---: | ---: |',
  fila('`lib/`', () => true),
  fila('`dominio/`', (archivo) => archivo.includes('/dominio/'), '85 %'),
  fila('`datos/`', (archivo) => archivo.includes('/datos/'), '85 %'),
  '',
  'Los archivos ausentes del LCOV aparecen en el total de archivos. El porcentaje usa las líneas instrumentadas.',
].join('\n'));
