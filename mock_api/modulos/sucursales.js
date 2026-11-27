const { BASE } = require('../comun/http');

module.exports = function registrarSucursales(servidor, db) {
  // ── sucursales ──
  // V2-M27.02 · como el contrato: solo las activas, la principal primero, y
  // «abierto ahora» calculado con la hora de la agencia (America/Mexico_City,
  // sin horario de verano: UTC-6), nunca con la del telefono.
  db.defaults({ sucursales: [] }).write();

  const DESFASE_AGENCIA_MS = 6 * 60 * 60 * 1000;

  // Dia ISO (1 lunes a 7 domingo) y minutos desde la medianoche, en la agencia.
  function enLaAgencia(momento) {
    const local = new Date(momento - DESFASE_AGENCIA_MS);
    const dia = local.getUTCDay();
    return { dia: dia === 0 ? 7 : dia, minutos: local.getUTCHours() * 60 + local.getUTCMinutes() };
  }
  const aMinutos = (hhmm) => Number(hhmm.slice(0, 2)) * 60 + Number(hhmm.slice(3, 5));

  function abierto(horario, { dia, minutos }) {
    return horario.dias.includes(dia) && minutos >= aMinutos(horario.abre) && minutos < aMinutos(horario.cierra);
  }

  servidor.get(`${BASE}/sucursales`, (req, res) => {
    const ahora = enLaAgencia(Date.now());
    const lista = db
      .get('sucursales')
      .filter({ activa: true })
      .value()
      .slice()
      .sort((a, b) => a.orden - b.orden || a.id - b.id)
      .map((s) => {
        const horarios = s.horarios.map((h) => ({ ...h, abiertoAhora: abierto(h, ahora) }));
        return {
          id: s.id,
          nombre: s.nombre,
          direccion: s.direccion,
          latitud: s.lat,
          longitud: s.lng,
          telefono: s.telefono ?? null,
          correo: s.correo ?? null,
          abiertaAhora: horarios.some((h) => h.abiertoAhora),
          horarios,
        };
      });
    res.jsonp(lista);
  });
};
