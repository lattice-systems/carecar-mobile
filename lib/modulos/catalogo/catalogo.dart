/// Contrato publico del modulo `catalogo` (V2-M03).
///
/// Otros modulos y la app solo importan este archivo.
library;

export 'dominio/modelo_vigente.dart' show ModeloVigente;
export 'presentacion/pantalla_catalogo.dart' show PantallaCatalogo;
export 'presentacion/proveedores_catalogo.dart'
    show catalogoProvider, repositorioCatalogoProvider;
export 'presentacion/rutas_catalogo.dart' show rutaCatalogo, rutasCatalogo;
