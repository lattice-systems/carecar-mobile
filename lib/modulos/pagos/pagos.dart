/// Contrato publico del modulo `pagos` (V2-M08: pagos y facturas).
///
/// Otros modulos y la app solo importan este archivo. Los pagos y las facturas
/// son simulados (ADR 0009). La tienda cobra sus pedidos con la misma pantalla
/// (V2-M14.04).
library;

export 'presentacion/pantalla_datos_fiscales.dart' show PantallaDatosFiscales;
export 'presentacion/pantalla_metodos_pago.dart' show PantallaMetodosPago;
export 'presentacion/pantalla_mis_pagos.dart' show PantallaMisPagos;
export 'presentacion/pantalla_pagar_orden.dart'
    show PantallaPagarOrden, PantallaPagarPedido;
export 'presentacion/pantalla_pago.dart' show PantallaPago;
export 'presentacion/pantalla_perfil_fiscal.dart' show PantallaPerfilFiscal;
export 'presentacion/proveedores_datos_fiscales.dart'
    show repositorioDatosFiscalesProvider;
export 'presentacion/proveedores_pagos.dart'
    show eventoPagoConfirmado, repositorioPagosProvider;
export 'presentacion/rutas_pagos.dart'
    show
        rutaDatosFiscales,
        rutaMetodosPago,
        rutaMisPagos,
        rutaPagarOrden,
        rutaPagarPedido,
        rutaPago,
        rutaPerfilFiscal,
        rutaPerfilFiscalNuevo,
        rutasPagos;
