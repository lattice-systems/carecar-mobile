/// Contrato publico del modulo `acceso` (M01).
///
/// Otros modulos y la app solo importan este archivo (regla R1).
library;

export 'datos/repositorio_acceso_fake.dart' show RepositorioAccesoFake;
export 'dominio/bloqueo_por_intentos.dart' show BloqueoPorIntentos;
export 'dominio/correo.dart' show pareceCorreo;
export 'dominio/fallos_acceso.dart' show EnlaceNoValido;
export 'dominio/reglas_contrasena.dart'
    show ReglasContrasena, RevisionContrasena;
export 'dominio/repositorio_acceso.dart' show RepositorioAcceso;
export 'presentacion/pantalla_acceso.dart' show PantallaAcceso;
export 'presentacion/pantalla_cambiar_contrasena.dart'
    show ListaDeReglas, PantallaCambiarContrasena;
export 'presentacion/pantalla_nueva_contrasena.dart'
    show PantallaNuevaContrasena;
export 'presentacion/pantalla_recuperar.dart' show PantallaRecuperar;
export 'presentacion/proveedores_acceso.dart'
    show relojAccesoProvider, repositorioAccesoProvider;
export 'presentacion/rutas_acceso.dart' show rutasAcceso;
