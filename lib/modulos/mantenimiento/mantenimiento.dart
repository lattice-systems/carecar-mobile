/// Contrato publico del modulo `mantenimiento` (V2-M05: mantenimiento
/// inteligente).
///
/// Otros modulos y la app solo importan este archivo.
library;

export 'dominio/plan_mantenimiento.dart'
    show
        FuenteKm,
        PlanMantenimiento,
        ProximoServicio,
        ServicioMantenimiento;
export 'presentacion/pantalla_plan_mantenimiento.dart'
    show PantallaPlanMantenimiento;
export 'presentacion/pantalla_registrar_km.dart' show PantallaRegistrarKm;
export 'presentacion/pantalla_servicio_mantenimiento.dart'
    show PantallaServicioMantenimiento;
export 'presentacion/proveedores_mantenimiento.dart'
    show planMantenimientoProvider, repositorioMantenimientoProvider;
export 'presentacion/rutas_mantenimiento.dart'
    show
        rutaKilometraje,
        rutaMantenimiento,
        rutaMantenimientoVehiculo,
        rutaServicioMantenimiento,
        rutasMantenimiento;
