const test = require('node:test');
const assert = require('node:assert/strict');
const { calcularObjetivos } = require('./simular_objetivos');
const muestra = require('./semilla_objetivos.json');

test('calcula O2, O3 y O4 con la muestra ficticia', () => {
  const { origen, O2, O3, O4 } = calcularObjetivos(muestra);
  assert.equal(origen, 'SIMULACION');
  assert.deepEqual(O2, { citasCareCar: 2, citasTotales: 4, participacion: 50 });
  assert.deepEqual(O3, { ordenesAbiertas: 2, ordenesVisibles: 1, cobertura: 50,
    llamadasActuales: 2, llamadasAnteriores: 4, reduccion: 50 });
  assert.deepEqual(O4, { recomendacionesExigibles: 3, atendidas: 1, retorno: 33.3 });
});

test('las citas y llamadas repetidas cuentan una vez y el cero queda sin dato', () => {
  const duplicada = { ...muestra, citas: [...muestra.citas, muestra.citas[0]],
    llamadas: [...muestra.llamadas, muestra.llamadas[4]], ordenes: [],
    recomendaciones: [] };
  const { O2, O3, O4 } = calcularObjetivos(duplicada);
  assert.equal(O2.citasTotales, 4);
  assert.equal(O3.llamadasActuales, 2);
  assert.equal(O3.cobertura, null);
  assert.equal(O4.retorno, null);
});
