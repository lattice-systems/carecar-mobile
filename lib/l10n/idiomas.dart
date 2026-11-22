import 'dart:ui';

import 'app_localizations.dart';

/// Idioma que usa la app cuando el del sistema no es ninguno de los que
/// traduce. El generador pone `en` primero, y por defecto Flutter caeria ahi.
const idiomaBase = Locale('es');

/// Elige el idioma de la app: el del sistema si lo traducimos, y si no el
/// espanol. Se pasa a `MaterialApp.localeResolutionCallback`.
Locale resolverIdioma(Locale? delSistema, Iterable<Locale> soportados) {
  if (delSistema != null) {
    for (final idioma in soportados) {
      if (idioma.languageCode == delSistema.languageCode) return idioma;
    }
  }
  return idiomaBase;
}

/// Delegadas e idiomas para `MaterialApp`, en un solo lugar.
const delegadasDeIdioma = AppLocalizations.localizationsDelegates;
const idiomasSoportados = AppLocalizations.supportedLocales;
