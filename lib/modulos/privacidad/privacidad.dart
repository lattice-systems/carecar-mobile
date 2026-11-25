/// Contrato publico del modulo `privacidad` (M22.01: aviso de privacidad).
///
/// Otros modulos y la app solo importan este archivo.
library;

export 'dominio/privacidad.dart'
    show
        AvisoDePrivacidad,
        AvisoNoVigente,
        FalloPrivacidad,
        PrivacidadNoDisponible,
        PrivacidadSinConexion,
        RepositorioPrivacidad;
export 'presentacion/proveedores_privacidad.dart'
    show avisoVigenteProvider, repositorioPrivacidadProvider;
export 'presentacion/rutas_privacidad.dart'
    show rutaAvisoPrivacidad, rutasPrivacidad;
export 'presentacion/verificador_aviso.dart' show VerificadorDeAviso;
