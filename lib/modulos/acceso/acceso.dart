/// Contrato publico del modulo `acceso` (M01).
///
/// Otros modulos y la app solo importan este archivo (regla R1).
library;

export 'datos/repositorio_acceso_fake.dart' show RepositorioAccesoFake;
export 'dominio/bloqueo_por_intentos.dart' show BloqueoPorIntentos;
export 'dominio/correo.dart' show pareceCorreo;
export 'dominio/fallos_acceso.dart'
    show CodigoNoValido, ContrasenaNoCoincide, CorreoEnUso, EnlaceNoValido;
export 'dominio/perfil_del_cliente.dart' show PerfilDelCliente;
export 'dominio/reglas_contrasena.dart'
    show ReglasContrasena, RevisionContrasena;
export 'dominio/repositorio_acceso.dart' show RepositorioAcceso;
export 'dominio/sesion_de_la_cuenta.dart' show SesionDeLaCuenta;
export 'presentacion/pantalla_acceso.dart' show PantallaAcceso;
export 'presentacion/pantalla_cambiar_contrasena.dart'
    show ListaDeReglas, PantallaCambiarContrasena;
export 'presentacion/pantalla_cambiar_correo.dart' show PantallaCambiarCorreo;
export 'presentacion/pantalla_cuenta_desactivada.dart'
    show PantallaCuentaDesactivada;
export 'presentacion/pantalla_mi_contrasena.dart' show PantallaMiContrasena;
export 'presentacion/pantalla_mi_perfil.dart' show PantallaMiPerfil;
export 'presentacion/pantalla_nueva_contrasena.dart'
    show PantallaNuevaContrasena;
export 'presentacion/pantalla_recuperar.dart' show PantallaRecuperar;
export 'presentacion/pantalla_sesiones.dart' show PantallaSesiones;
export 'presentacion/proveedores_acceso.dart'
    show
        abrirEnlaceProvider,
        perfilProvider,
        relojAccesoProvider,
        repositorioAccesoProvider;
export 'presentacion/rutas_acceso.dart'
    show
        rutaCambiarCorreo,
        rutaMiContrasena,
        rutaMiPerfil,
        rutaSesiones,
        rutasAcceso,
        rutasSesiones;
