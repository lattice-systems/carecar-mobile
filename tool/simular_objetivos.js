const muestra = require('./semilla_objetivos.json');

function porcentaje(numerador, denominador) {
  return denominador === 0 ? null : Math.round(1000 * numerador / denominador) / 10;
}

function calcularObjetivos({ citas, ordenes, llamadas, recomendaciones, periodo }) {
  const en = (fecha, desde, hasta) => fecha >= desde && fecha < hasta;
  const enPeriodo = fecha => en(fecha, periodo.desde, periodo.hasta);

  const citasPeriodo = Array.from(new Map(
    citas.filter(cita => enPeriodo(cita.creadaEn) && cita.estado !== 'CANCELADA')
      .map(cita => [cita.id, cita]),
  ).values());
  const citasCareCar = citasPeriodo.filter(cita => cita.canal === 'CARECAR').length;

  const ordenesAbiertas = ordenes.filter(orden => orden.abierta);
  const ordenesVisibles = ordenesAbiertas.filter(orden => orden.estadoVisible).length;
  const llamadasDeEstado = desdeHasta => new Set(llamadas
    .filter(llamada => llamada.motivo === 'ESTADO'
      && en(llamada.fecha, desdeHasta.desde, desdeHasta.hasta))
    .map(llamada => llamada.id)).size;
  const llamadasActuales = llamadasDeEstado(periodo);
  const llamadasAnteriores = llamadasDeEstado(periodo.anterior);

  // El periodo cuenta recomendaciones cuyo plazo terminó. Cada una solo
  // cuenta como completada si tiene una orden del mismo auto y en su plazo.
  const exigibles = recomendaciones.filter(rec => enPeriodo(rec.hasta));
  const atendidas = exigibles.filter(rec => ordenes.some(orden =>
    orden.recomendacionId === rec.id && orden.vehiculoId === rec.vehiculoId
    && orden.tipo === 'MANTENIMIENTO' && orden.cerradaEn
    && en(orden.cerradaEn, rec.desde, rec.hasta),
  )).length;

  return {
    origen: 'SIMULACION',
    periodo,
    O2: { citasCareCar, citasTotales: citasPeriodo.length,
      participacion: porcentaje(citasCareCar, citasPeriodo.length) },
    O3: { ordenesAbiertas: ordenesAbiertas.length, ordenesVisibles,
      cobertura: porcentaje(ordenesVisibles, ordenesAbiertas.length),
      llamadasActuales, llamadasAnteriores,
      reduccion: porcentaje(llamadasAnteriores - llamadasActuales, llamadasAnteriores) },
    O4: { recomendacionesExigibles: exigibles.length, atendidas,
      retorno: porcentaje(atendidas, exigibles.length) },
  };
}

if (require.main === module) {
  process.stdout.write(JSON.stringify(calcularObjetivos(muestra), null, 2) + '\n');
}

module.exports = { calcularObjetivos };
