import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../l10n/app_localizations.dart';
import '../../../nucleo/diseno/componentes/tono.dart';
import '../dominio/valuacion.dart';

// Los precios son en pesos mexicanos y se escriben igual en cualquier idioma.
final _pesos = NumberFormat.currency(
  locale: 'es_MX',
  symbol: r'$',
  decimalDigits: 0,
);

final _miles = NumberFormat.decimalPattern('es_MX');

String pesosValuacion(double monto) => _pesos.format(monto);

String milesValuacion(int numero) => _miles.format(numero);

/// "$100,000 a $120,000".
String rangoValuacion(AppLocalizations t, double minimo, double maximo) =>
    t.calculadoraRango(pesosValuacion(minimo), pesosValuacion(maximo));

String _idioma(BuildContext context) =>
    Localizations.localeOf(context).toLanguageTag();

/// "vie 27 nov".
String diaValuacion(BuildContext context, DateTime fecha) =>
    DateFormat.MMMEd(_idioma(context)).format(fecha);

/// "4 dic 2026".
String fechaValuacion(BuildContext context, DateTime fecha) =>
    DateFormat.yMMMd(_idioma(context)).format(fecha);

/// "noviembre de 2026".
String mesValuacion(BuildContext context, DateTime mes) =>
    DateFormat.yMMMM(_idioma(context)).format(mes);

/// "nov 26", para el eje de la grafica.
String mesCortoValuacion(BuildContext context, DateTime mes) =>
    DateFormat('MMM yy', _idioma(context)).format(mes);

String textoEstadoValuacion(AppLocalizations t, EstadoValuacion estado) =>
    switch (estado) {
      EstadoValuacion.solicitada => t.valuacionEstadoSolicitada,
      EstadoValuacion.citaAgendada => t.valuacionEstadoCitaAgendada,
      EstadoValuacion.ofertada => t.valuacionEstadoOfertada,
      EstadoValuacion.aceptada => t.valuacionEstadoAceptada,
      EstadoValuacion.rechazada => t.valuacionEstadoRechazada,
      EstadoValuacion.vencida => t.valuacionEstadoVencida,
      EstadoValuacion.desconocido => t.valuacionEstadoDesconocido,
    };

Tono tonoEstadoValuacion(EstadoValuacion estado) => switch (estado) {
  EstadoValuacion.solicitada => Tono.informacion,
  EstadoValuacion.citaAgendada => Tono.informacion,
  EstadoValuacion.ofertada => Tono.exito,
  EstadoValuacion.aceptada => Tono.exito,
  EstadoValuacion.rechazada => Tono.neutro,
  EstadoValuacion.vencida => Tono.advertencia,
  EstadoValuacion.desconocido => Tono.neutro,
};

String nombreToma(AppLocalizations t, TomaValuacion toma) => switch (toma) {
  TomaValuacion.frente => t.valuacionTomaFrente,
  TomaValuacion.trasera => t.valuacionTomaTrasera,
  TomaValuacion.lateralIzquierdo => t.valuacionTomaLateralIzquierdo,
  TomaValuacion.lateralDerecho => t.valuacionTomaLateralDerecho,
  TomaValuacion.interiorDelantero => t.valuacionTomaInteriorDelantero,
  TomaValuacion.interiorTrasero => t.valuacionTomaInteriorTrasero,
  TomaValuacion.tableroKm => t.valuacionTomaTableroKm,
  TomaValuacion.cajuela => t.valuacionTomaCajuela,
};

String instruccionToma(AppLocalizations t, TomaValuacion toma) =>
    switch (toma) {
      TomaValuacion.frente => t.valuacionInstruccionFrente,
      TomaValuacion.trasera => t.valuacionInstruccionTrasera,
      TomaValuacion.lateralIzquierdo => t.valuacionInstruccionLateralIzquierdo,
      TomaValuacion.lateralDerecho => t.valuacionInstruccionLateralDerecho,
      TomaValuacion.interiorDelantero =>
        t.valuacionInstruccionInteriorDelantero,
      TomaValuacion.interiorTrasero => t.valuacionInstruccionInteriorTrasero,
      TomaValuacion.tableroKm => t.valuacionInstruccionTableroKm,
      TomaValuacion.cajuela => t.valuacionInstruccionCajuela,
    };
