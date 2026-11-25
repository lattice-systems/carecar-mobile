const { BASE, problema, noEncontrado, paginar } = require('../comun/http');

module.exports = function registrarCatalogo(servidor, db, vehiculoDelCliente) {
  function comoModelo(m) {
    return {
      id: m.id,
      marca: m.marca,
      modelo: m.modelo,
      anio: m.anio,
      version: m.version ?? null,
      precioDesde: m.precioDesde ?? null,
      imagenUrl: m.imagenUrl ?? null,
      descripcion: m.descripcion ?? null,
      activo: m.activo,
    };
  }

  servidor.get(`${BASE}/catalogo`, (req, res) => {
    const activos = db.get('catalogo').filter({ activo: true }).value();
    res.jsonp(activos.map(comoModelo));
  });

  // V2-M03.02 · Detalle de un modelo. Un modelo retirado o inexistente responde
  // 404, igual que el backend. Las versiones son los modelos activos de la misma
  // marca, modelo y anio, de la mas barata a la mas cara (sin precio al final).
  servidor.get(`${BASE}/catalogo/:modeloId`, (req, res) => {
    const id = Number(req.params.modeloId);
    const modelo = db.get('catalogo').find({ id, activo: true }).value();
    if (!Number.isInteger(id) || !modelo) {
      return problema(req, res, 404, 'No existe el modelo');
    }

    const ordenadoPor = (campo) => (a, b) => a[campo] - b[campo];
    const imagenes = db
      .get('catalogoImagenes')
      .filter({ modeloId: id })
      .value()
      .sort(ordenadoPor('orden'))
      .map(({ id: imagenId, url, color, descripcion, orden }) => ({
        id: imagenId,
        url,
        color: color ?? null,
        descripcion: descripcion ?? null,
        orden,
      }));
    const especificaciones = db
      .get('catalogoEspecificaciones')
      .filter({ modeloId: id })
      .value()
      .sort(ordenadoPor('orden'))
      .map(({ etiqueta, valor, orden }) => ({ etiqueta, valor, orden }));
    const versiones = db
      .get('catalogo')
      .filter({
        activo: true,
        marca: modelo.marca,
        modelo: modelo.modelo,
        anio: modelo.anio,
      })
      .value()
      .sort(
        (a, b) =>
          (a.precioDesde ?? Infinity) - (b.precioDesde ?? Infinity) || a.id - b.id,
      )
      .map((v) => ({
        id: v.id,
        nombre: v.version ?? v.modelo,
        precioDesde: v.precioDesde ?? null,
      }));

    res.jsonp({ ...comoModelo(modelo), imagenes, versiones, especificaciones });
  });

  // ---------------------------------------------------------------------------
  // Toma a cuenta · V2-M03.04, V2-M03.06 y V2-M03.07
  //
  // La formula es la del diseno del backend (plan/historias-backend.md): vive
  // aqui, no en la app. Los parametros de semillas/catalogo.json son de ejemplo, no valores
  // de la agencia. Una estimacion nunca es una oferta.
  // ---------------------------------------------------------------------------

  const ESTADOS_VEHICULO = { EXCELENTE: -1, BUENO: 0, REGULAR: 1, MALO: 2 };
  const KM_ANUALES = 15000;
  const MARGEN = 0.08;

  const redondearA100 = (n) => Math.max(0, Math.round(n / 100) * 100);
  const limitar = (n, min, max) => Math.min(max, Math.max(min, n));
  const mismo = (a, b) => String(a).trim().toLowerCase() === String(b).trim().toLowerCase();

  // Calcula el rango y los supuestos con un parametro de la agencia.
  function calcularTomaACuenta(parametro, anio, km, estado) {
    const edadAnios = Math.max(0, new Date().getFullYear() - anio);
    const base = parametro.valorBase * Math.pow(1 - parametro.depreciacionAnual, edadAnios);
    const kmEsperado = edadAnios * KM_ANUALES;
    const ajusteKm = limitar(1 - (parametro.factorKm * (km - kmEsperado)) / 10000, 0.5, 1.2);
    const ajusteEstado = 1 - parametro.factorEstado * ESTADOS_VEHICULO[estado];
    const estimado = base * ajusteKm * ajusteEstado;
    return {
      minimo: redondearA100(estimado * (1 - MARGEN)),
      maximo: redondearA100(estimado * (1 + MARGEN)),
      supuestos: {
        valorBase: parametro.valorBase,
        edadAnios,
        kmEsperado,
        ajusteKm: Number(ajusteKm.toFixed(4)),
        ajusteEstado: Number(ajusteEstado.toFixed(4)),
        margen: MARGEN,
      },
    };
  }

  const comoEstimacion = (e) => {
    const { clienteId, parametroId, ...contrato } = e;
    return contrato;
  };

  servidor.get(`${BASE}/toma-a-cuenta/estimaciones`, (req, res) => {
    const propias = db
      .get('estimacionesTomaCuenta')
      .filter({ clienteId: req.sesion.clienteId })
      .value()
      .slice()
      .sort((a, b) => b.id - a.id)
      .map(comoEstimacion);
    paginar(req, res, propias);
  });

  servidor.post(`${BASE}/toma-a-cuenta/estimaciones`, (req, res) => {
    const { vehiculoId, marca, modelo, anio, km, estado, modeloCatalogoId } = req.body || {};
    const conVehiculo = vehiculoId !== undefined && vehiculoId !== null;
    const capturado = [marca, modelo, anio].some((v) => v !== undefined && v !== null);

    if (conVehiculo === capturado) {
      return problema(req, res, 400, 'Indica vehiculoId o marca, modelo y anio, no las dos ni ninguna', 'DATOS_INVALIDOS');
    }
    if (!Number.isInteger(km) || km < 0 || km > 999999 || !(estado in ESTADOS_VEHICULO)) {
      return problema(req, res, 400, 'km o estado no son validos', 'DATOS_INVALIDOS');
    }

    let auto;
    let vehiculo = null;
    if (conVehiculo) {
      vehiculo = vehiculoDelCliente(req, vehiculoId);
      if (!vehiculo) return noEncontrado(req, res);
      auto = { marca: vehiculo.marca, modelo: vehiculo.tipo ?? vehiculo.modelo, anio: vehiculo.anio };
    } else {
      const anioValido = Number.isInteger(anio) && anio >= 1900 && anio <= new Date().getFullYear() + 1;
      if (typeof marca !== 'string' || !marca.trim() || typeof modelo !== 'string' || !modelo.trim() || !anioValido) {
        return problema(req, res, 400, 'marca, modelo o anio no son validos', 'DATOS_INVALIDOS');
      }
      auto = { marca: marca.trim(), modelo: modelo.trim(), anio };
    }

    let destino = null;
    if (modeloCatalogoId !== undefined && modeloCatalogoId !== null) {
      destino = db.get('catalogo').find({ id: Number(modeloCatalogoId), activo: true }).value();
      if (!destino) return noEncontrado(req, res);
    }

    const parametro = db
      .get('parametrosTomaCuenta')
      .value()
      .find((p) => p.activo && mismo(p.marca, auto.marca || '') && mismo(p.modelo, auto.modelo) && p.anio === auto.anio);
    if (!parametro) {
      return problema(
        req,
        res,
        422,
        'Todavia no podemos estimar ese auto. Pide una valuacion formal.',
        'SIN_PARAMETROS_DE_VALUACION'
      );
    }

    const calculo = calcularTomaACuenta(parametro, auto.anio, km, estado);
    const ids = db.get('estimacionesTomaCuenta').value().map((e) => e.id);
    const estimacion = {
      id: ids.length ? Math.max(...ids) + 1 : 1,
      clienteId: req.sesion.clienteId,
      parametroId: parametro.id,
      creadaEn: new Date().toISOString(),
      vehiculoId: vehiculo ? vehiculo.id : null,
      marca: auto.marca,
      modelo: auto.modelo,
      anio: auto.anio,
      km,
      estado,
      modeloCatalogoId: destino ? destino.id : null,
      modeloDestino: destino ? [destino.marca, destino.modelo, destino.anio].join(' ') : null,
      precioDestino: destino ? destino.precioDesde ?? null : null,
      ...calculo,
    };
    db.get('estimacionesTomaCuenta').push(estimacion).write();
    res.status(201).jsonp(comoEstimacion(estimacion));
  });
};
