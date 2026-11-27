/// Contrato publico del modulo `ayuda` (V2-M27: ayuda y sucursales).
///
/// Otros modulos y la app solo importan este archivo.
///
/// Para usar la sucursal principal desde otro modulo (V2-M02.12 la direccion
/// del evento de calendario, V2-M11.02 el telefono de la asistencia):
/// `ref.watch(sucursalPrincipalProvider)`; si falla o es nula, se queda el
/// valor de `Agencia` (`lib/config/agencia.dart`).
library;

export 'dominio/sucursal.dart'
    show Departamento, HorarioDeDepartamento, HorariosDelDepartamento, Sucursal;
export 'presentacion/pantalla_sucursales.dart' show PantallaSucursales;
export 'presentacion/proveedores_ayuda.dart'
    show
        repositorioSucursalesProvider,
        sucursalPrincipalProvider,
        sucursalesProvider;
export 'presentacion/rutas_ayuda.dart' show rutaSucursales, rutasAyuda;
