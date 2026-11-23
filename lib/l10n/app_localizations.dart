import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// Título de la pantalla del catálogo de modelos.
  ///
  /// In es, this message translates to:
  /// **'Catálogo'**
  String get catalogoTitulo;

  /// Lo que anuncia el lector de pantalla mientras carga el catálogo.
  ///
  /// In es, this message translates to:
  /// **'Cargando catálogo'**
  String get catalogoCargando;

  /// No description provided for @catalogoVacioTitulo.
  ///
  /// In es, this message translates to:
  /// **'Aún no hay modelos'**
  String get catalogoVacioTitulo;

  /// No description provided for @catalogoVacioMensaje.
  ///
  /// In es, this message translates to:
  /// **'Cuando la agencia publique modelos, los verás aquí.'**
  String get catalogoVacioMensaje;

  /// Lo que anuncia el lector de pantalla mientras carga la disponibilidad.
  ///
  /// In es, this message translates to:
  /// **'Cargando disponibilidad del taller'**
  String get citasCargando;

  /// Encabezado de las franjas del día elegido en el calendario.
  ///
  /// In es, this message translates to:
  /// **'Horarios del {dia}'**
  String citasHorariosDelDia(DateTime dia);

  /// No description provided for @citasHorariosVacio.
  ///
  /// In es, this message translates to:
  /// **'Este día ya no tiene lugares.'**
  String get citasHorariosVacio;

  /// No description provided for @citasNotaDiasSinCupo.
  ///
  /// In es, this message translates to:
  /// **'Los días tachados no tienen lugares disponibles.'**
  String get citasNotaDiasSinCupo;

  /// No description provided for @citasSinDiaElegido.
  ///
  /// In es, this message translates to:
  /// **'Elige un día para ver sus horarios.'**
  String get citasSinDiaElegido;

  /// Título de la pantalla con el calendario de disponibilidad.
  ///
  /// In es, this message translates to:
  /// **'Disponibilidad del taller'**
  String get citasTitulo;

  /// No description provided for @citasVacioMensaje.
  ///
  /// In es, this message translates to:
  /// **'Por ahora el taller no tiene lugares en los próximos días. Vuelve a revisar pronto.'**
  String get citasVacioMensaje;

  /// No description provided for @citasVacioTitulo.
  ///
  /// In es, this message translates to:
  /// **'Sin lugares disponibles'**
  String get citasVacioTitulo;

  /// Precio de entrada de un modelo.
  ///
  /// In es, this message translates to:
  /// **'Desde {precio}'**
  String precioDesde(String precio);

  /// Descripción de la foto de un modelo para el lector de pantalla.
  ///
  /// In es, this message translates to:
  /// **'Foto del {modelo}'**
  String fotoDeModelo(String modelo);

  /// Acceso del detalle a la ficha técnica del vehículo.
  ///
  /// In es, this message translates to:
  /// **'Ficha técnica'**
  String get vehiculosAccesoFicha;

  /// Acceso del detalle al historial de servicios del vehículo.
  ///
  /// In es, this message translates to:
  /// **'Historial de servicios'**
  String get vehiculosAccesoHistorial;

  /// Acceso del detalle a los manuales del vehículo.
  ///
  /// In es, this message translates to:
  /// **'Manuales'**
  String get vehiculosAccesoManuales;

  /// Se dice en un acceso del detalle cuya pantalla aún no existe.
  ///
  /// In es, this message translates to:
  /// **'Disponible pronto'**
  String get vehiculosAccesoPronto;

  /// Etiqueta del año del vehículo.
  ///
  /// In es, this message translates to:
  /// **'Año'**
  String get vehiculosAnio;

  /// Lo que anuncia el lector de pantalla mientras carga el garaje.
  ///
  /// In es, this message translates to:
  /// **'Cargando tu garaje'**
  String get vehiculosCargando;

  /// Etiqueta del color del vehículo.
  ///
  /// In es, this message translates to:
  /// **'Color'**
  String get vehiculosColor;

  /// Lo que lee el lector de pantalla en el botón que copia el VIN.
  ///
  /// In es, this message translates to:
  /// **'Copiar VIN'**
  String get vehiculosCopiarVin;

  /// Título de la pantalla de detalle de un vehículo.
  ///
  /// In es, this message translates to:
  /// **'Detalle del vehículo'**
  String get vehiculosDetalleTitulo;

  /// Etiqueta del kilometraje del vehículo.
  ///
  /// In es, this message translates to:
  /// **'Kilometraje'**
  String get vehiculosKilometraje;

  /// Kilometraje de un vehículo.
  ///
  /// In es, this message translates to:
  /// **'{km} km'**
  String vehiculosKilometros(String km);

  /// Fecha de cierre del servicio que dejó el kilometraje.
  ///
  /// In es, this message translates to:
  /// **'Actualizado por el taller el {fecha}'**
  String vehiculosKmActualizado(String fecha);

  /// Se muestra si el kilometraje no trae fecha de cierre.
  ///
  /// In es, this message translates to:
  /// **'Aún sin actualización del taller'**
  String get vehiculosKmSinActualizar;

  /// Se muestra si el vehículo no tiene kilometraje.
  ///
  /// In es, this message translates to:
  /// **'Sin kilometraje registrado'**
  String get vehiculosKmSinDato;

  /// Mensaje cuando el vehículo pedido no existe en el garaje.
  ///
  /// In es, this message translates to:
  /// **'Ese vehículo ya no está en tu garaje. Vuelve al garaje para elegir otro.'**
  String get vehiculosNoEncontradoMensaje;

  /// Título cuando el vehículo pedido no existe en el garaje.
  ///
  /// In es, this message translates to:
  /// **'No encontramos el vehículo'**
  String get vehiculosNoEncontradoTitulo;

  /// Placas de un vehículo.
  ///
  /// In es, this message translates to:
  /// **'Placas {placas}'**
  String vehiculosPlacas(String placas);

  /// Etiqueta de las placas del vehículo.
  ///
  /// In es, this message translates to:
  /// **'Placas'**
  String get vehiculosPlacasEtiqueta;

  /// Se muestra cuando el vehículo aún no tiene placas registradas.
  ///
  /// In es, this message translates to:
  /// **'Sin placas'**
  String get vehiculosSinPlacas;

  /// Título de la pantalla con los vehículos del cliente.
  ///
  /// In es, this message translates to:
  /// **'Mi garaje'**
  String get vehiculosTitulo;

  /// No description provided for @vehiculosVacioMensaje.
  ///
  /// In es, this message translates to:
  /// **'La agencia registra tus autos al entregártelos. Cuando lo haga, aparecerán aquí.'**
  String get vehiculosVacioMensaje;

  /// No description provided for @vehiculosVacioTitulo.
  ///
  /// In es, this message translates to:
  /// **'Aún no tienes vehículos'**
  String get vehiculosVacioTitulo;

  /// Etiqueta de la versión del vehículo.
  ///
  /// In es, this message translates to:
  /// **'Versión'**
  String get vehiculosVersion;

  /// Etiqueta del número de serie del vehículo.
  ///
  /// In es, this message translates to:
  /// **'VIN'**
  String get vehiculosVin;

  /// Confirmación al copiar el VIN.
  ///
  /// In es, this message translates to:
  /// **'VIN copiado'**
  String get vehiculosVinCopiado;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
