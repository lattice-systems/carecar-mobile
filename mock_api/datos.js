const fs = require('node:fs');
const path = require('node:path');

const RUTA_DB = path.join(__dirname, 'db.json');
const RUTA_SEMILLAS = path.join(__dirname, 'semillas');

function leerSemillas() {
  const colecciones = new Map();
  const archivos = fs.readdirSync(RUTA_SEMILLAS).filter((nombre) => nombre.endsWith('.json')).sort();

  for (const archivo of archivos) {
    const semilla = JSON.parse(fs.readFileSync(path.join(RUTA_SEMILLAS, archivo), 'utf8'));
    for (const [nombre, registros] of Object.entries(semilla)) {
      if (colecciones.has(nombre)) {
        throw new Error(`La colección ${nombre} está repetida en ${archivo}`);
      }
      if (!Array.isArray(registros)) {
        throw new Error(`La colección ${nombre} de ${archivo} debe ser una lista`);
      }
      colecciones.set(nombre, registros);
    }
  }

  return Object.fromEntries(colecciones);
}

function restaurarSemillas() {
  fs.writeFileSync(RUTA_DB, JSON.stringify(leerSemillas(), null, 2) + '\n');
  console.log('db.json restaurado desde semillas/');
}

if (require.main === module) restaurarSemillas();

module.exports = { RUTA_DB, leerSemillas, restaurarSemillas };
