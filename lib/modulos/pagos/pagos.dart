/// Contrato publico del modulo `pagos` (V2-M08: pagos y facturas).
///
/// Otros modulos y la app solo importan este archivo. Los pagos y las facturas
/// son simulados (ADR 0009).
library;

export 'presentacion/pantalla_datos_fiscales.dart' show PantallaDatosFiscales;
export 'presentacion/pantalla_perfil_fiscal.dart' show PantallaPerfilFiscal;
export 'presentacion/proveedores_datos_fiscales.dart'
    show repositorioDatosFiscalesProvider;
export 'presentacion/rutas_pagos.dart'
    show rutaDatosFiscales, rutaPerfilFiscal, rutaPerfilFiscalNuevo, rutasPagos;
