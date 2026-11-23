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
  String get citasCargando => 'Loading workshop availability';

  @override
  String citasHorariosDelDia(DateTime dia) {
    final intl.DateFormat diaDateFormat = intl.DateFormat.MMMMEEEEd(localeName);
    final String diaString = diaDateFormat.format(dia);

    return 'Times for $diaString';
  }

  @override
  String get citasHorariosVacio => 'This day has no spots left.';

  @override
  String get citasNotaDiasSinCupo =>
      'Crossed-out days have no spots available.';

  @override
  String get citasSinDiaElegido => 'Pick a day to see its times.';

  @override
  String get citasTitulo => 'Workshop availability';

  @override
  String get citasVacioMensaje =>
      'The workshop has no spots in the coming days. Check back soon.';

  @override
  String get citasVacioTitulo => 'No spots available';

  @override
  String precioDesde(String precio) {
    return 'From $precio';
  }

  @override
  String fotoDeModelo(String modelo) {
    return 'Photo of the $modelo';
  }

  @override
  String get vehiculosAccesoFicha => 'Technical specs';

  @override
  String get vehiculosAccesoHistorial => 'Service history';

  @override
  String get vehiculosAccesoManuales => 'Manuals';

  @override
  String get vehiculosAccesoPronto => 'Coming soon';

  @override
  String get vehiculosAnio => 'Year';

  @override
  String get vehiculosCargando => 'Loading your garage';

  @override
  String get vehiculosColor => 'Color';

  @override
  String get vehiculosCopiarVin => 'Copy VIN';

  @override
  String get vehiculosDetalleTitulo => 'Vehicle details';

  @override
  String get vehiculosKilometraje => 'Mileage';

  @override
  String vehiculosKilometros(String km) {
    return '$km km';
  }

  @override
  String vehiculosKmActualizado(String fecha) {
    return 'Updated by the workshop on $fecha';
  }

  @override
  String get vehiculosKmSinActualizar => 'Not updated by the workshop yet';

  @override
  String get vehiculosKmSinDato => 'No mileage recorded';

  @override
  String get vehiculosNoEncontradoMensaje =>
      'That vehicle is no longer in your garage. Go back to your garage to pick another.';

  @override
  String get vehiculosNoEncontradoTitulo => 'We could not find the vehicle';

  @override
  String vehiculosPlacas(String placas) {
    return 'Plates $placas';
  }

  @override
  String get vehiculosPlacasEtiqueta => 'Plates';

  @override
  String get vehiculosSinPlacas => 'No plates';

  @override
  String get vehiculosTitulo => 'My garage';

  @override
  String get vehiculosVacioMensaje =>
      'The dealership registers your cars when it hands them over. Once it does, they will show up here.';

  @override
  String get vehiculosVacioTitulo => 'You have no vehicles yet';

  @override
  String get vehiculosVersion => 'Trim';

  @override
  String get vehiculosVin => 'VIN';

  @override
  String get vehiculosVinCopiado => 'VIN copied';
}
