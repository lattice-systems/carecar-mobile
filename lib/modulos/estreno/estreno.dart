/// Contrato publico del modulo `estreno` (M16: prueba de manejo y cotizacion).
///
/// Otros modulos y la app solo importan este archivo.
library;

export 'dominio/estreno.dart'
    show
        EstadoSolicitud,
        FranjaPreferida,
        MensualidadEstimada,
        PaginaDeSolicitudes,
        RepositorioEstreno,
        SolicitudDeEstreno,
        TipoSolicitud;
export 'presentacion/proveedores_estreno.dart'
    show
        misSolicitudesProvider,
        relojEstrenoProvider,
        repositorioEstrenoProvider;
export 'presentacion/rutas_estreno.dart'
    show
        rutaCotizarEstreno,
        rutaMisSolicitudesEstreno,
        rutaPruebaManejo,
        rutasEstreno;
