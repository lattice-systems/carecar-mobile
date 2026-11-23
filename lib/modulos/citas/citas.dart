/// Contrato publico del modulo `citas` (V2-M02: agenda y citas).
///
/// Otros modulos y la app solo importan este archivo.
library;

export 'dominio/cita_agendada.dart' show CitaAgendada;
export 'dominio/disponibilidad_taller.dart'
    show DisponibilidadTaller, FranjaDisponible;
export 'dominio/motivo_cita.dart' show MotivoCita;
export 'presentacion/pantalla_agendar_cita.dart' show PantallaAgendarCita;
export 'presentacion/pantalla_disponibilidad.dart' show PantallaDisponibilidad;
export 'presentacion/pantalla_mis_citas.dart' show PantallaMisCitas;
export 'presentacion/proveedores_citas.dart'
    show
        disponibilidadProvider,
        misCitasProvider,
        rangoAgendableProvider,
        relojCitasProvider,
        repositorioCitasProvider,
        tamanoPaginaCitasProvider;
export 'presentacion/rutas_citas.dart'
    show rutaAgendarCita, rutaDisponibilidad, rutaMisCitas, rutasCitas;
