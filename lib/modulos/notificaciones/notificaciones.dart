/// Contrato publico del modulo `notificaciones` (M06).
///
/// Otros modulos y la app solo importan este archivo.
library;

export 'datos/avisos_del_sistema_real.dart' show AvisosDelSistemaReal;
export 'dominio/avisos_del_sistema.dart' show AvisosDelSistema;
export 'dominio/aviso_cliente.dart'
    show AvisoCliente, CategoriaDeAviso, PaginaDeAvisos, RepositorioAvisos;
export 'dominio/preferencias_de_avisos.dart'
    show
        HoraDelDia,
        HorarioSilencioso,
        PreferenciasDeAvisos,
        RepositorioPreferenciasAvisos;
export 'dominio/recordatorios_de_cita.dart' show RecordatoriosDeCita;
export 'presentacion/estado_avisos.dart'
    show
        EstadoAvisos,
        PermisoDeAvisos,
        avisosDelSistemaProvider,
        permisoDeAvisosProvider;
export 'presentacion/proveedores_bandeja.dart'
    show avisosSinLeerProvider, bandejaProvider, repositorioAvisosProvider;
export 'presentacion/proveedores_preferencias.dart'
    show preferenciasDeAvisosProvider, repositorioPreferenciasProvider;
export 'presentacion/proveedores_recordatorios.dart'
    show recordatoriosDeCitaProvider;
export 'presentacion/rutas_notificaciones.dart'
    show
        rutaBandeja,
        rutaPermisoAvisos,
        rutaPreferenciasAvisos,
        rutasNotificaciones;
