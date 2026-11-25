import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

/// El código de formato de números del idioma de [context].
///
/// En español se usa el de México (`es_MX`: coma de miles y punto decimal) y no
/// el de España, porque la agencia y sus clientes son de México: el mismo
/// kilometraje no puede verse «18,450» en una pantalla y «18.450» en otra. En
/// los demás idiomas manda el suyo.
String formatoDeNumeros(BuildContext context) {
  final idioma = Localizations.localeOf(context);
  return idioma.languageCode == 'es' ? 'es_MX' : idioma.toString();
}

/// [valor] con separador de miles según el idioma: «18,450».
String formatearMiles(BuildContext context, num valor) =>
    NumberFormat.decimalPattern(formatoDeNumeros(context)).format(valor);
