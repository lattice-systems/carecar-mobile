import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import '../../../l10n/app_localizations.dart';
import '../../../nucleo/diseno/componentes/tono.dart';
import '../dominio/orden_historial.dart';

String _idioma(BuildContext context) =>
    Localizations.localeOf(context).toString();

/// Pesos con centavos: `$1,282.00`.
String monedaDe(BuildContext context, double valor) => NumberFormat.currency(
  locale: _idioma(context).startsWith('es') ? 'es_MX' : 'en_US',
  symbol: r'$',
  decimalDigits: 2,
).format(valor);

String fechaDe(BuildContext context, DateTime fecha) =>
    DateFormat.yMMMd(_idioma(context)).format(fecha);

String fechaHoraDe(BuildContext context, DateTime fecha) =>
    DateFormat.yMMMd(_idioma(context)).add_Hm().format(fecha);

String textoEstatus(AppLocalizations textos, EstatusOrden estatus) =>
    switch (estatus) {
      EstatusOrden.recibido => textos.historialEstatusRecibido,
      EstatusOrden.enProceso => textos.historialEstatusEnProceso,
      EstatusOrden.terminado => textos.historialEstatusTerminado,
      EstatusOrden.entregado => textos.historialEstatusEntregado,
      EstatusOrden.desconocido => textos.historialEstatusOtro,
    };

Tono tonoEstatus(EstatusOrden estatus) => switch (estatus) {
  EstatusOrden.recibido => Tono.informacion,
  EstatusOrden.enProceso => Tono.advertencia,
  EstatusOrden.terminado => Tono.exito,
  EstatusOrden.entregado => Tono.neutro,
  EstatusOrden.desconocido => Tono.neutro,
};
