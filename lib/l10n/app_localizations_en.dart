// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get catalogoTitulo => 'Catalog';

  @override
  String get catalogoCargando => 'Loading catalog';

  @override
  String get catalogoVacioTitulo => 'No models yet';

  @override
  String get catalogoVacioMensaje =>
      'When the dealership publishes models, you\'ll see them here.';

  @override
  String precioDesde(String precio) {
    return 'From $precio';
  }

  @override
  String fotoDeModelo(String modelo) {
    return 'Photo of the $modelo';
  }

  @override
  String get vehiculosCargando => 'Loading your garage';

  @override
  String vehiculosKilometros(String km) {
    return '$km km';
  }

  @override
  String vehiculosPlacas(String placas) {
    return 'Plates $placas';
  }

  @override
  String get vehiculosSinPlacas => 'No plates';

  @override
  String get vehiculosTitulo => 'My garage';

  @override
  String get vehiculosVacioMensaje =>
      'The dealership registers your cars when it hands them over. Once it does, they will show up here.';

  @override
  String get vehiculosVacioTitulo => 'You have no vehicles yet';
}
