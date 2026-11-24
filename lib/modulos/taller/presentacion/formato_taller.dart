import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import '../../../l10n/app_localizations.dart';
import '../../../nucleo/diseno/componentes/semaforo.dart';
import '../dominio/etapa_taller.dart';
import '../dominio/orden_taller.dart';

String _idioma(BuildContext context) =>
    Localizations.localeOf(context).toString();

/// Pesos con centavos: `$1,650.50`.
String monedaTaller(BuildContext context, double valor) =>
    NumberFormat.currency(
      locale: _idioma(context).startsWith('es') ? 'es_MX' : 'en_US',
      symbol: r'$',
      decimalDigits: 2,
    ).format(valor);

/// Dia y hora de la agencia: `24 nov 18:00`.
String horaTaller(BuildContext context, DateTime momento) =>
    DateFormat.MMMd(_idioma(context)).add_Hm().format(momento);

/// Solo la hora: `09:30`. Para la linea de tiempo, donde el espacio es corto.
String horaCortaTaller(BuildContext context, DateTime momento) =>
    DateFormat.Hm(_idioma(context)).format(momento);

String textoEtapa(AppLocalizations textos, EtapaTaller etapa) =>
    switch (etapa) {
      EtapaTaller.recibido => textos.tallerEtapaRecibido,
      EtapaTaller.diagnostico => textos.tallerEtapaDiagnostico,
      EtapaTaller.esperandoAprobacion => textos.tallerEtapaEsperandoAprobacion,
      EtapaTaller.enReparacion => textos.tallerEtapaEnReparacion,
      EtapaTaller.controlDeCalidad => textos.tallerEtapaControlDeCalidad,
      EtapaTaller.lavado => textos.tallerEtapaLavado,
      EtapaTaller.listoParaEntrega => textos.tallerEtapaListoParaEntrega,
      EtapaTaller.entregado => textos.tallerEtapaEntregado,
    };

EstadoSemaforo semaforoDe(ResultadoInspeccion resultado) => switch (resultado) {
  ResultadoInspeccion.verde => EstadoSemaforo.bien,
  ResultadoInspeccion.amarillo => EstadoSemaforo.atencion,
  ResultadoInspeccion.rojo => EstadoSemaforo.urgente,
};
