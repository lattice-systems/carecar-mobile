/// Contrato publico del modulo `citas` (V2-M02: agenda y citas).
///
/// Otros modulos y la app solo importan este archivo.
library;

export 'dominio/disponibilidad_taller.dart'
    show DisponibilidadTaller, FranjaDisponible;
export 'presentacion/pantalla_disponibilidad.dart' show PantallaDisponibilidad;
export 'presentacion/proveedores_citas.dart'
    show
        disponibilidadProvider,
        rangoAgendableProvider,
        relojCitasProvider,
        repositorioCitasProvider;
export 'presentacion/rutas_citas.dart' show rutaDisponibilidad, rutasCitas;
