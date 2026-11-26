/// Contrato publico del modulo `garantia` (V2-M10: garantia y campanas de
/// seguridad).
///
/// Otros modulos y la app solo importan este archivo.
library;

export 'presentacion/insignia_campanas.dart' show InsigniaCampanas;
export 'presentacion/pantalla_agendar_campana.dart' show PantallaAgendarCampana;
export 'presentacion/pantalla_campana.dart' show PantallaCampana;
export 'presentacion/pantalla_campanas.dart' show PantallaCampanas;
export 'presentacion/pantalla_garantia.dart' show PantallaGarantia;
export 'presentacion/proveedores_garantia.dart'
    show
        campanasProvider,
        eventoCampanaNueva,
        eventoGarantiaPorVencer,
        garantiaProvider,
        hayCampanaAbiertaProvider,
        repositorioGarantiaProvider;
export 'presentacion/rutas_garantia.dart'
    show
        rutaAgendarCampana,
        rutaCampanaVehiculo,
        rutaCampanasVehiculo,
        rutaGarantia,
        rutaGarantiaVehiculo,
        rutasGarantia;
