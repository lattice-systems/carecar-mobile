// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get catalogoTitulo => 'Catálogo';

  @override
  String get catalogoCargando => 'Cargando catálogo';

  @override
  String get catalogoVacioTitulo => 'Aún no hay modelos';

  @override
  String get catalogoVacioMensaje =>
      'Cuando la agencia publique modelos, los verás aquí.';

  @override
  String precioDesde(String precio) {
    return 'Desde $precio';
  }

  @override
  String fotoDeModelo(String modelo) {
    return 'Foto del $modelo';
  }

  @override
  String get vehiculosCargando => 'Cargando tu garaje';

  @override
  String vehiculosKilometros(String km) {
    return '$km km';
  }

  @override
  String vehiculosPlacas(String placas) {
    return 'Placas $placas';
  }

  @override
  String get vehiculosSinPlacas => 'Sin placas';

  @override
  String get vehiculosTitulo => 'Mi garaje';

  @override
  String get vehiculosVacioMensaje =>
      'La agencia registra tus autos al entregártelos. Cuando lo haga, aparecerán aquí.';

  @override
  String get vehiculosVacioTitulo => 'Aún no tienes vehículos';
}
