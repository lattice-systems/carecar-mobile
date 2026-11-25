/// Contrato publico del modulo `widgets` (V2-M25).
///
/// Otros modulos y la app solo importan este archivo. Por ahora trae los
/// accesos rapidos del icono (V2-M25.04) y el widget de pantalla de inicio con
/// la proxima cita (V2-M25.01) o el auto en el taller (V2-M25.02); Wallet llega con V2-M25.03.
library;

export 'dominio/acceso_rapido.dart'
    show AccesoRapido, AtajoDeIcono, PuertoAccesosRapidos;
export 'dominio/proxima_cita_widget.dart'
    show
        ContenidoWidgetCita,
        PuertoWidgetCita,
        enlaceAgendarWidget,
        enlaceDeCitaWidget,
        enlaceDeOrdenWidget,
        proximaCita;
export 'presentacion/destinos_accesos.dart' show rutaDeAcceso;
export 'presentacion/instalador_de_accesos_rapidos.dart'
    show InstaladorDeAccesosRapidos;
export 'presentacion/proveedores_widgets.dart'
    show puertoAccesosRapidosProvider, puertoWidgetCitaProvider;
export 'presentacion/sincronizador_del_widget_de_cita.dart'
    show SincronizadorDelWidgetDeCita;
