/// Contrato publico del modulo `acceso` (M01).
///
/// Otros modulos y la app solo importan este archivo (regla R1).
library;

export 'dominio/bloqueo_por_intentos.dart' show BloqueoPorIntentos;
export 'presentacion/pantalla_acceso.dart' show PantallaAcceso;
export 'presentacion/proveedores_acceso.dart' show relojAccesoProvider;
export 'presentacion/rutas_acceso.dart' show rutasAcceso;
