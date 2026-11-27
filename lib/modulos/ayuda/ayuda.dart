/// Contrato publico del modulo `ayuda` (V2-M27: ayuda y sucursales).
///
/// Otros modulos y la app solo importan este archivo.
///
/// Para usar el contacto de la agencia desde otro modulo (V2-M02.12 la
/// direccion del evento de calendario, V2-M11.02 el telefono de la asistencia):
/// `ref.watch(contactoDeAgenciaProvider)`. Ya trae el respaldo de `Agencia`
/// (`lib/config/agencia.dart`) si aun carga, falla o no hay sucursales, asi que
/// no hace falta manejar el error. Quien necesite la sucursal completa lee
/// `sucursalPrincipalProvider`.
library;

export 'dominio/contacto_de_agencia.dart' show ContactoDeAgencia;
export 'dominio/sucursal.dart'
    show Departamento, HorarioDeDepartamento, HorariosDelDepartamento, Sucursal;
export 'presentacion/pantalla_contacto.dart' show PantallaContacto;
export 'presentacion/pantalla_sucursales.dart' show PantallaSucursales;
export 'presentacion/proveedores_ayuda.dart'
    show
        abrirEnlaceDeSucursalProvider,
        contactoDeAgenciaProvider,
        repositorioSucursalesProvider,
        sucursalPrincipalProvider,
        sucursalesProvider;
export 'presentacion/rutas_ayuda.dart'
    show rutaContacto, rutaSucursales, rutasAyuda;
