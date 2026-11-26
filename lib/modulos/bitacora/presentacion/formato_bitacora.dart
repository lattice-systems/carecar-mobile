import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:lucide_icons_flutter/lucide_icons_300.dart';

import '../../../l10n/app_localizations.dart';
import '../../../nucleo/diseno/tokens/tokens_pista.dart';
import '../dominio/gasto.dart';

String _locale(BuildContext context) {
  final idioma = Localizations.localeOf(context);
  return idioma.languageCode == 'es' ? 'es_MX' : idioma.toString();
}

/// Un monto en pesos mexicanos con dos decimales, p. ej. «$849.50».
String pesos(BuildContext context, double monto) => NumberFormat.currency(
  locale: _locale(context),
  symbol: r'$',
  decimalDigits: 2,
).format(monto);

/// Un número con hasta [decimales] decimales y el separador del idioma.
String numero(BuildContext context, num valor, {int decimales = 0}) =>
    NumberFormat.decimalPatternDigits(
      locale: _locale(context),
      decimalDigits: decimales,
    ).format(valor);

/// «noviembre de 2026» con el idioma de la persona.
String mesLegible(BuildContext context, DateTime mes) =>
    MaterialLocalizations.of(context).formatMonthYear(mes);

/// Fecha corta de un gasto, p. ej. «20/11/2026».
String fechaCorta(BuildContext context, DateTime fecha) =>
    MaterialLocalizations.of(context).formatCompactDate(fecha);

/// El nombre del tipo de gasto en el idioma de la persona.
String nombreTipo(AppLocalizations textos, TipoGasto tipo) => switch (tipo) {
  TipoGasto.gasolina => textos.bitacoraTipoGasolina,
  TipoGasto.estacionamiento => textos.bitacoraTipoEstacionamiento,
  TipoGasto.casetas => textos.bitacoraTipoCasetas,
  TipoGasto.lavado => textos.bitacoraTipoLavado,
  TipoGasto.otro => textos.bitacoraTipoOtro,
};

IconData iconoTipo(TipoGasto tipo) => switch (tipo) {
  TipoGasto.gasolina => LucideIcons300.fuel,
  TipoGasto.estacionamiento => LucideIcons300.squareParking,
  TipoGasto.casetas => LucideIcons300.coins,
  TipoGasto.lavado => LucideIcons300.droplets,
  TipoGasto.otro => LucideIcons300.receiptText,
};

/// Color del ícono de cada tipo, solo con colores de los tokens.
Color colorTipo(TokensPista tokens, TipoGasto tipo) {
  final c = tokens.colores;
  return switch (tipo) {
    TipoGasto.gasolina => c.acento,
    TipoGasto.estacionamiento => c.marca,
    TipoGasto.casetas => c.advertencia,
    TipoGasto.lavado => c.exito,
    TipoGasto.otro => c.textoSecundario,
  };
}
