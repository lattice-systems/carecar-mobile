/// Contrato publico del modulo `ejemplo`.
///
/// Otros modulos y la app solo importan este archivo. Todo lo demas
/// (`datos/`, `dominio/`, `presentacion/`) es interno. Modulo de ejemplo: se
/// elimina en V2-T01.07.
library;

export 'dominio/aviso.dart' show Aviso;
export 'presentacion/pantalla_avisos.dart' show PantallaAvisos;
export 'presentacion/proveedores_ejemplo.dart' show repositorioAvisosProvider;
