/// Contrato publico del modulo `valuacion` (V2-M26: valuacion formal y toma a
/// cuenta avanzada).
///
/// Otros modulos y la app solo importan este archivo. El modulo no importa
/// `catalogo`, que es quien lo usa para sus botones.
library;

export 'dominio/repositorio_valuacion.dart'
    show
        MotivoRechazoValuacion,
        PaginaDeValuaciones,
        RepositorioValuacion,
        ValuacionRechazada;
export 'dominio/valuacion.dart'
    show
        EstadoValuacion,
        EstimacionDeValuacion,
        FotoValuacion,
        InspeccionValuacion,
        OfertaValuacion,
        PuntoValorEstimado,
        TomaValuacion,
        Valuacion;
export 'presentacion/boton_pedir_valuacion.dart' show BotonPedirValuacion;
export 'presentacion/pantalla_agendar_inspeccion.dart'
    show PantallaAgendarInspeccion;
export 'presentacion/pantalla_fotos_valuacion.dart' show PantallaFotosValuacion;
export 'presentacion/pantalla_mis_valuaciones.dart' show PantallaMisValuaciones;
export 'presentacion/pantalla_valor_vehiculo.dart' show PantallaValorVehiculo;
export 'presentacion/pantalla_valuacion.dart' show PantallaValuacion;
export 'presentacion/proveedores_valuacion.dart'
    show repositorioValuacionProvider;
export 'presentacion/rutas_valuacion.dart'
    show
        rutaCitaValuacion,
        rutaFotosValuacion,
        rutaValorVehiculo,
        rutaValuacion,
        rutaValuaciones,
        rutasValuacion;
