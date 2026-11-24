import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

/// Un monto en pesos mexicanos con dos decimales, p. ej. «$150.00».
///
/// Los montos de la agencia son siempre pesos de México, así que en español se
/// usa el formato de México (punto decimal y símbolo antes del número) y no el
/// de España; en otros idiomas, el del idioma de la persona.
String formatearPesos(BuildContext context, double monto) {
  final idioma = Localizations.localeOf(context);
  final locale = idioma.languageCode == 'es' ? 'es_MX' : idioma.toString();
  return NumberFormat.currency(
    locale: locale,
    symbol: r'$',
    decimalDigits: 2,
  ).format(monto);
}
