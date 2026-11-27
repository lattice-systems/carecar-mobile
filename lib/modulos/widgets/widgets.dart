/// Contrato publico del modulo `widgets` (V2-M25).
///
/// Otros modulos y la app solo importan este archivo. Trae los accesos rapidos
/// del icono (V2-M25.04) y los widgets de pantalla de inicio, que se agregan
/// por separado: proxima cita (V2-M25.01), taller en vivo (V2-M25.02),
/// mantenimiento, bitacora y accesos rapidos; Wallet llega con V2-M25.03. La
/// Live Activity del taller en iPhone (V2-M25.05) no se exporta: la lleva
/// [SincronizadorDeWidgets] con las mismas ordenes en curso.
library;

export 'dominio/acceso_rapido.dart'
    show AccesoRapido, AtajoDeIcono, PuertoAccesosRapidos;
export 'dominio/contenido_widgets.dart'
    show ContenidoWidget, PuertoWidgets, TipoWidget, enlaceDeRuta;
export 'dominio/proxima_cita_widget.dart'
    show enlaceAgendarWidget, enlaceDeCitaWidget, proximaCita;
export 'presentacion/destinos_accesos.dart' show rutaDeAcceso;
export 'presentacion/instalador_de_accesos_rapidos.dart'
    show InstaladorDeAccesosRapidos;
export 'presentacion/proveedores_widgets.dart'
    show puertoAccesosRapidosProvider, puertoWidgetsProvider;
export 'presentacion/sincronizador_de_widgets.dart' show SincronizadorDeWidgets;
