/// Contrato publico del modulo `vehiculos` (V2-M02).
///
/// Otros modulos y la app solo importan este archivo.
library;

export 'dominio/vehiculo_garaje.dart' show VehiculoGaraje;
export 'presentacion/pantalla_detalle_vehiculo.dart'
    show PantallaDetalleVehiculo;
export 'presentacion/pantalla_ficha_tecnica.dart' show PantallaFichaTecnica;
export 'presentacion/pantalla_garaje.dart' show PantallaGaraje;
export 'presentacion/pantalla_manual.dart' show PantallaManual;
export 'presentacion/proveedores_vehiculos.dart'
    show
        fichaTecnicaProvider,
        garajeProvider,
        manualProvider,
        repositorioFichaTecnicaProvider,
        repositorioGarajeProvider,
        vehiculoProvider;
export 'presentacion/rutas_vehiculos.dart'
    show
        rutaDetalleVehiculo,
        rutaFichaTecnicaVehiculo,
        rutaGaraje,
        rutaManualVehiculo,
        rutasVehiculos;
