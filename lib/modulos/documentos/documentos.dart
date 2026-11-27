/// Contrato publico del modulo `documentos` (V2-M09: documentos y
/// vencimientos).
///
/// Otros modulos y la app solo importan este archivo.
///
/// Para llamar a la aseguradora (V2-M11.02): `documentosProvider(vehiculoId)`
/// entrega los documentos del auto y `polizaParaLlamar(documentos)` elige la
/// poliza no vencida con aseguradora y telefono, o `null`.
library;

export 'dominio/documento_vehiculo.dart'
    show
        DocumentoVehiculo,
        EstadoDocumento,
        OrigenDocumento,
        TipoDocumento;
export 'dominio/poliza_para_llamar.dart' show polizaParaLlamar;
export 'presentacion/pantalla_documentos.dart' show PantallaDocumentos;
export 'presentacion/proveedores_documentos.dart'
    show documentosProvider, repositorioDocumentosProvider;
export 'presentacion/rutas_documentos.dart'
    show rutaDocumentos, rutaDocumentosVehiculo, rutasDocumentos;
