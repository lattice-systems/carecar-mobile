import 'package:home_widget/home_widget.dart';

import '../dominio/proxima_cita_widget.dart';

/// [PuertoWidgetCita] real, sobre el paquete `home_widget`.
///
/// Guarda cada dato en el almacen que comparte con el widget nativo
/// (`SharedPreferences` en Android, App Group en iOS) y le pide repintarse. Las
/// claves son el contrato con el codigo nativo: si cambian aqui, cambian en
/// `ProximaCitaWidgetProvider.kt` y en el widget de iOS.
class WidgetCitaHomeWidget implements PuertoWidgetCita {
  /// Nombre completo del `AppWidgetProvider` de Android.
  static const proveedorAndroid =
      'com.carecar.carecar_mobile.ProximaCitaWidgetProvider';

  /// `kind` del widget de WidgetKit en iOS.
  static const tipoIos = 'ProximaCitaWidget';

  /// App Group compartido entre la app y la extension de iOS.
  static const grupoIos = 'group.com.carecar.carecarMobile';

  static const claveHayCita = 'proxima_cita_hay';
  static const claveTitulo = 'proxima_cita_titulo';
  static const claveFecha = 'proxima_cita_fecha';
  static const claveHorario = 'proxima_cita_horario';
  static const claveVehiculo = 'proxima_cita_vehiculo';
  static const claveMensaje = 'proxima_cita_mensaje';
  static const claveAccion = 'proxima_cita_accion';
  static const claveEnlace = 'proxima_cita_enlace';

  bool _grupoConfigurado = false;

  @override
  Future<void> publicar(ContenidoWidgetCita contenido) async {
    if (!_grupoConfigurado) {
      await HomeWidget.setAppGroupId(grupoIos);
      _grupoConfigurado = true;
    }
    final datos = <String, Object?>{
      claveHayCita: contenido.hayCita,
      claveTitulo: contenido.titulo,
      claveFecha: contenido.fecha,
      claveHorario: contenido.horario,
      claveVehiculo: contenido.vehiculo,
      claveMensaje: contenido.mensaje,
      claveAccion: contenido.accion,
      claveEnlace: contenido.enlace,
    };
    for (final entrada in datos.entries) {
      // Un dato nulo borra el anterior: el widget no debe quedarse con el
      // vehiculo de una cita que ya no es la proxima.
      await HomeWidget.saveWidgetData<Object>(entrada.key, entrada.value);
    }
    await HomeWidget.updateWidget(
      qualifiedAndroidName: proveedorAndroid,
      iOSName: tipoIos,
    );
  }
}
