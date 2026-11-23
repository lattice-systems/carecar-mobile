import 'package:quick_actions/quick_actions.dart';

import '../dominio/acceso_rapido.dart';

/// [PuertoAccesosRapidos] real, sobre el paquete `quick_actions`.
class AccesosRapidosQuickActions implements PuertoAccesosRapidos {
  AccesosRapidosQuickActions([QuickActions? quickActions])
    : _quickActions = quickActions ?? const QuickActions();

  final QuickActions _quickActions;

  /// Nombre del recurso del icono: `drawable/ic_acceso_<id>` en Android. iOS
  /// no trae icono propio y muestra el atajo solo con texto.
  static String _icono(AccesoRapido acceso) => 'ic_acceso_${acceso.id}';

  @override
  Future<void> instalar(List<AtajoDeIcono> atajos) =>
      _quickActions.setShortcutItems([
        for (final atajo in atajos)
          ShortcutItem(
            type: atajo.acceso.id,
            localizedTitle: atajo.titulo,
            icon: _icono(atajo.acceso),
          ),
      ]);

  @override
  void alElegir(void Function(AccesoRapido acceso) callback) {
    _quickActions.initialize((tipo) {
      final acceso = AccesoRapido.desdeId(tipo);
      // Un atajo viejo de otra version de la app no hace nada.
      if (acceso != null) callback(acceso);
    });
  }
}
