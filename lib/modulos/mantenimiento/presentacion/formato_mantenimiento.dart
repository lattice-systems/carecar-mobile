import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../l10n/app_localizations.dart';
import '../../../nucleo/diseno/componentes/tono.dart';
import '../dominio/plan_mantenimiento.dart';

/// Un número de km con separador de miles según el idioma: «12,300».
///
/// En español se usa el formato de México (coma de miles) y no el de España.
String formatearKm(BuildContext context, num km) {
  final idioma = Localizations.localeOf(context);
  final locale = idioma.languageCode == 'es' ? 'es_MX' : idioma.toString();
  return NumberFormat.decimalPattern(locale).format(km);
}

/// Fecha corta y localizada: «15 nov 2026».
String formatearFecha(BuildContext context, DateTime fecha) =>
    MaterialLocalizations.of(context).formatMediumDate(fecha);

/// El tono de la insignia de un estado: el icono acompaña al color, así el
/// estado no depende solo de él.
Tono tonoEstado(EstadoServicio estado) => switch (estado) {
  EstadoServicio.hecho => Tono.exito,
  EstadoServicio.pendiente => Tono.neutro,
  EstadoServicio.proximo => Tono.informacion,
  EstadoServicio.vencido => Tono.peligro,
};

/// Cómo se llama un estado de servicio en pantalla.
String textoEstado(AppLocalizations textos, EstadoServicio estado) =>
    switch (estado) {
      EstadoServicio.hecho => textos.mantenimientoEstadoHecho,
      EstadoServicio.pendiente => textos.mantenimientoEstadoPendiente,
      EstadoServicio.proximo => textos.mantenimientoEstadoProximo,
      EstadoServicio.vencido => textos.mantenimientoEstadoVencido,
    };
