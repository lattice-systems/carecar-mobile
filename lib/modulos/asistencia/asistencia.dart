/// Contrato publico del modulo `asistencia` (V2-M11).
///
/// Otros modulos y la app solo importan este archivo.
library;

export 'dominio/guia_emergencia.dart'
    show GuiaEmergencia, TipoGuia, guiasDeEmergencia;
export 'presentacion/pantalla_guia.dart' show PantallaGuia;
export 'presentacion/pantalla_guias.dart' show PantallaGuias;
export 'presentacion/pantalla_pedir_ayuda.dart' show PantallaPedirAyuda;
export 'presentacion/proveedores_asistencia.dart'
    show repositorioAsistenciaProvider, solicitudActivaProvider;
export 'presentacion/rutas_asistencia.dart'
    show
        rutaAsistenciaGuias,
        rutaGuiaDeEmergencia,
        rutaPedirAyuda,
        rutaSos,
        rutasAsistencia;
