/// Contrato publico del modulo `catalogo` (V2-M03).
///
/// Otros modulos y la app solo importan este archivo.
library;

export 'dominio/comparativa.dart'
    show
        FilaComparativa,
        filasDeFicha,
        idsDeComparativa,
        indiceMasBarato,
        maximoComparables,
        minimoComparables;
export 'dominio/detalle_modelo.dart'
    show DatoFicha, DetalleModelo, FotoModelo, VersionDeModelo;
export 'dominio/modelo_vigente.dart' show ModeloVigente;
export 'presentacion/pantalla_catalogo.dart' show PantallaCatalogo;
export 'presentacion/pantalla_comparador.dart' show PantallaComparador;
export 'presentacion/pantalla_detalle_modelo.dart' show PantallaDetalleModelo;
export 'presentacion/proveedores_catalogo.dart'
    show
        catalogoProvider,
        comparativaProvider,
        detalleModeloProvider,
        repositorioCatalogoProvider;
export 'presentacion/rutas_catalogo.dart'
    show
        rutaCatalogo,
        rutaComparador,
        rutaComparadorDe,
        rutaDetalleModelo,
        rutasCatalogo;
