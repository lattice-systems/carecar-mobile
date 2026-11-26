/// Contrato publico del modulo `lealtad` (V2-M12: lealtad y recompensas).
///
/// Otros modulos y la app solo importan este archivo.
library;

export 'presentacion/pantalla_canje.dart' show PantallaCanje;
export 'presentacion/pantalla_canjes.dart' show PantallaCanjes;
export 'presentacion/pantalla_lealtad.dart' show PantallaLealtad;
export 'presentacion/pantalla_movimientos.dart' show PantallaMovimientos;
export 'presentacion/pantalla_recompensas.dart' show PantallaRecompensas;
export 'presentacion/pantalla_referir.dart' show PantallaReferir;
export 'presentacion/proveedores_lealtad.dart'
    show
        eventoPuntosMovidos,
        repositorioLealtadProvider,
        resumenLealtadProvider;
export 'presentacion/rutas_lealtad.dart'
    show
        rutaCanje,
        rutaCanjes,
        rutaLealtad,
        rutaMovimientos,
        rutaRecompensas,
        rutaReferir,
        rutasLealtad;
