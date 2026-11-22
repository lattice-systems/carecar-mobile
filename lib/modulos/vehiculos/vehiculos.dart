/// Contrato publico del modulo `vehiculos` (V2-M02).
///
/// Otros modulos y la app solo importan este archivo.
library;

export 'dominio/vehiculo_garaje.dart' show VehiculoGaraje;
export 'presentacion/pantalla_detalle_vehiculo.dart'
    show PantallaDetalleVehiculo;
export 'presentacion/pantalla_garaje.dart' show PantallaGaraje;
export 'presentacion/proveedores_vehiculos.dart'
    show garajeProvider, repositorioGarajeProvider, vehiculoProvider;
export 'presentacion/rutas_vehiculos.dart'
    show rutaDetalleVehiculo, rutaGaraje, rutasVehiculos;
