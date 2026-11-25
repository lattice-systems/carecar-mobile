/// Contrato publico del modulo `bitacora` (V2-M18: bitacora del conductor).
///
/// Otros modulos y la app solo importan este archivo.
library;

export 'dominio/estadisticas.dart'
    show Rendimiento, calcularRendimiento, gastoDelMes;
export 'dominio/gasto.dart' show BorradorGasto, Gasto, TipoGasto;
export 'presentacion/caminos_bitacora.dart'
    show
        rutaBitacora,
        rutaBitacoraVehiculo,
        rutaEstadisticasBitacora,
        rutaExportarBitacora;
export 'presentacion/pantalla_bitacora.dart' show PantallaBitacora;
export 'presentacion/pantalla_estadisticas.dart' show PantallaEstadisticas;
export 'presentacion/pantalla_exportar.dart' show PantallaExportar;
export 'presentacion/pantalla_gasto.dart' show PantallaGasto;
export 'presentacion/proveedores_bitacora.dart'
    show
        CompartirArchivo,
        compartirBitacoraProvider,
        gastosProvider,
        lectorTicketProvider,
        relojBitacoraProvider,
        repositorioBitacoraProvider;
export 'presentacion/rutas_bitacora.dart' show rutasBitacora;
