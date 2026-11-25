/// Contrato publico del modulo `taller` (V2-M04.01 a V2-M04.07).
///
/// Otros modulos y la app solo importan este archivo.
library;

export 'dominio/etapa_taller.dart' show EtapaTaller;
export 'dominio/orden_taller.dart' show OrdenEnCurso;
export 'presentacion/formato_taller.dart' show horaTaller, textoEtapa;
export 'presentacion/proveedores_taller.dart'
    show ordenTallerProvider, ordenesEnCursoProvider, repositorioTallerProvider;
export 'presentacion/rutas_taller.dart'
    show
        rutaAdicionalesTaller,
        rutaInspeccionTaller,
        rutaOrdenTaller,
        rutaTaller,
        rutasTaller;
export 'presentacion/tarjeta_orden_en_curso.dart' show TarjetaOrdenEnCurso;
