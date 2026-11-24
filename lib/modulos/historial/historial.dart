/// Contrato publico del modulo `historial` (V2-M02.05 y V2-M02.06).
///
/// Otros modulos y la app solo importan este archivo.
library;

export 'presentacion/pantalla_historial.dart' show PantallaHistorial;
export 'presentacion/pantalla_ticket.dart' show PantallaTicket;
export 'presentacion/proveedores_historial.dart'
    show
        aniosHistorialProvider,
        compartirTicketProvider,
        historialProvider,
        repositorioHistorialProvider,
        ticketServicioProvider;
export 'presentacion/rutas_historial.dart'
    show
        rutaHistorial,
        rutaHistorialVehiculo,
        rutaTicketServicio,
        rutasHistorial;
