/// Contrato publico del modulo `recoleccion` (V2-M17: recoleccion y entrega a
/// domicilio).
///
/// Otros modulos y la app solo importan este archivo.
library;

export 'dominio/cotizacion_recoleccion.dart'
    show CotizacionRecoleccion, VentanaHoraria;
export 'dominio/direccion_guardada.dart'
    show BorradorDireccion, CampoDireccion, DireccionGuardada;
export 'dominio/fallos_recoleccion.dart' show DireccionEnUso, FueraDeCobertura;
export 'dominio/recoleccion_agendada.dart'
    show RecoleccionAgendada, TipoTraslado, TrasladoAgendado;
export 'presentacion/formato_pesos.dart' show formatearPesos;
export 'presentacion/pantalla_direccion.dart' show PantallaDireccion;
export 'presentacion/pantalla_mis_direcciones.dart' show PantallaMisDirecciones;
export 'presentacion/proveedores_recoleccion.dart'
    show
        ClaveCotizacion,
        cotizacionRecoleccionProvider,
        direccionesProvider,
        repositorioRecoleccionProvider;
export 'presentacion/rutas_recoleccion.dart'
    show rutaMisDirecciones, rutasRecoleccion;
export 'presentacion/seleccion_recoleccion.dart' show SeleccionRecoleccion;
