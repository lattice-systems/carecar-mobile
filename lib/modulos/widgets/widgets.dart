/// Contrato publico del modulo `widgets` (V2-M25).
///
/// Otros modulos y la app solo importan este archivo. Por ahora trae los
/// accesos rapidos del icono (V2-M25.04); los widgets de pantalla de inicio y
/// Wallet llegan con V2-M25.01 a V2-M25.03.
library;

export 'dominio/acceso_rapido.dart'
    show AccesoRapido, AtajoDeIcono, PuertoAccesosRapidos;
export 'presentacion/destinos_accesos.dart' show rutaDeAcceso;
export 'presentacion/instalador_de_accesos_rapidos.dart'
    show InstaladorDeAccesosRapidos;
export 'presentacion/proveedores_widgets.dart'
    show puertoAccesosRapidosProvider;
