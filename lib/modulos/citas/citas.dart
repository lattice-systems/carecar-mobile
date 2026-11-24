/// Contrato publico del modulo `citas` (V2-M02: agenda y citas).
///
/// Otros modulos y la app solo importan este archivo.
library;

export 'dominio/cita_agendada.dart' show CitaAgendada;
export 'dominio/cita_cliente.dart' show CitaCliente, EstadoDeCita;
export 'dominio/disponibilidad_taller.dart'
    show DisponibilidadTaller, FranjaDisponible;
export 'dominio/motivo_cita.dart' show MotivoCita;
export 'presentacion/pantalla_agendar_cita.dart' show PantallaAgendarCita;
export 'presentacion/pantalla_comprobante_cita.dart'
    show PantallaComprobanteCita;
export 'presentacion/pantalla_disponibilidad.dart' show PantallaDisponibilidad;
export 'presentacion/pantalla_mis_citas.dart' show PantallaMisCitas;
export 'presentacion/pantalla_reprogramar_cita.dart'
    show PantallaReprogramarCita;
export 'presentacion/proveedores_citas.dart'
    show
        comprobanteCitaProvider,
        disponibilidadProvider,
        misCitasProvider,
        rangoAgendableProvider,
        relojCitasProvider,
        repositorioCitasProvider,
        tamanoPaginaCitasProvider;
export 'presentacion/rutas_citas.dart'
    show
        rutaAgendarCita,
        rutaAgendarCitaCon,
        rutaComprobanteCita,
        rutaDisponibilidad,
        rutaMisCitas,
        localizacionAgendarCita,
        rutaReprogramarCita,
        rutasCitas;
