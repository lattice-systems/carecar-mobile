import 'package:home_widget/home_widget.dart';

import '../dominio/contenido_widgets.dart';

/// [PuertoWidgets] real, sobre el paquete `home_widget`.
///
/// Guarda cada dato en el almacén que comparte con los widgets nativos
/// (`SharedPreferences` en Android, App Group en iOS) y les pide repintarse.
/// Las claves (`TipoWidget.clave`) son el contrato con el código nativo: si
/// cambian aquí, cambian en los proveedores Kotlin y en los widgets de iOS.
class WidgetsHomeWidget implements PuertoWidgets {
  /// Paquete de la app: los `AppWidgetProvider` viven en él.
  static const paqueteAndroid = 'com.carecar.carecar_mobile';

  /// App Group compartido entre la app y la extensión de iOS.
  static const grupoIos = 'group.com.carecar.carecarMobile';

  bool _grupoConfigurado = false;

  Future<void> _configurar() async {
    if (_grupoConfigurado) return;
    await HomeWidget.setAppGroupId(grupoIos);
    _grupoConfigurado = true;
  }

  Future<void> _repintar(TipoWidget tipo) => HomeWidget.updateWidget(
    qualifiedAndroidName: '$paqueteAndroid.${tipo.proveedorAndroid}',
    iOSName: tipo.tipoIos,
  );

  @override
  Future<void> publicar(ContenidoWidget contenido) async {
    await _configurar();
    final tipo = contenido.tipo;
    final almacen = contenido.almacen;
    for (final campo in tipo.campos) {
      final clave = tipo.clave(campo);
      // Un dato ausente borra el anterior: el widget no debe quedarse con el
      // vehículo de una cita que ya no es la próxima.
      await HomeWidget.saveWidgetData<Object>(clave, almacen[clave]);
    }
    await _repintar(tipo);
  }

  @override
  Future<void> borrarTodo() async {
    await _configurar();
    for (final tipo in TipoWidget.values) {
      for (final campo in tipo.campos) {
        await HomeWidget.saveWidgetData<Object>(tipo.clave(campo), null);
      }
      await _repintar(tipo);
    }
  }
}
