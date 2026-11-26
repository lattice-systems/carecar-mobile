import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import '../../../l10n/app_localizations.dart';
import '../../../nucleo/diseno/componentes/tono.dart';
import '../dominio/campana_seguridad.dart';
import '../dominio/garantia_vehiculo.dart';

String _idioma(BuildContext context) =>
    Localizations.localeOf(context).toString();

/// Fecha corta: `25 dic 2026`.
String fechaGarantia(BuildContext context, DateTime fecha) =>
    DateFormat.yMMMd(_idioma(context)).format(fecha);

/// Dia con su nombre, para la cita: `lun, 30 nov`.
String diaGarantia(BuildContext context, DateTime fecha) =>
    DateFormat.MMMEd(_idioma(context)).format(fecha);

/// Kilometros con separador de miles: `60,000`. En espanol se usa el formato
/// de Mexico (coma de miles), no el de Espana.
String kmGarantia(BuildContext context, int km) {
  final idioma = Localizations.localeOf(context);
  final locale = idioma.languageCode == 'es' ? 'es_MX' : idioma.toString();
  return NumberFormat.decimalPattern(locale).format(km);
}

String textoEstadoCobertura(AppLocalizations textos, EstadoCobertura estado) =>
    switch (estado) {
      EstadoCobertura.vigente => textos.garantiaEstadoVigente,
      EstadoCobertura.porVencer => textos.garantiaEstadoPorVencer,
      EstadoCobertura.vencida => textos.garantiaEstadoVencida,
    };

Tono tonoCobertura(EstadoCobertura estado) => switch (estado) {
  EstadoCobertura.vigente => Tono.exito,
  EstadoCobertura.porVencer => Tono.advertencia,
  EstadoCobertura.vencida => Tono.peligro,
};

/// Hasta cuando cubre: la fecha y, si tiene, el km limite.
String textoLimiteCobertura(BuildContext context, CoberturaGarantia c) {
  final textos = AppLocalizations.of(context);
  final fecha = fechaGarantia(context, c.venceEn);
  final km = c.kmLimite;
  return km == null
      ? textos.garantiaVence(fecha)
      : textos.garantiaVenceOKm(fecha, kmGarantia(context, km));
}

/// Lo que le queda, por el limite que llega primero; o por que vencio.
String textoRestante(BuildContext context, CoberturaGarantia c) {
  final textos = AppLocalizations.of(context);
  final km = c.kmRestantes;
  if (c.estado == EstadoCobertura.vencida) {
    return c.limite == LimiteCobertura.km
        ? textos.garantiaVencidaPorKm
        : textos.garantiaVencidaPorFecha;
  }
  if (c.limite == LimiteCobertura.km && km != null) {
    return textos.garantiaQuedanKm(kmGarantia(context, km));
  }
  return textos.garantiaQuedanDias(c.diasRestantes);
}

String textoGravedad(AppLocalizations textos, GravedadCampana gravedad) =>
    switch (gravedad) {
      GravedadCampana.baja => textos.campanasGravedadBaja,
      GravedadCampana.media => textos.campanasGravedadMedia,
      GravedadCampana.alta => textos.campanasGravedadAlta,
      GravedadCampana.critica => textos.campanasGravedadCritica,
    };

Tono tonoGravedad(GravedadCampana gravedad) => switch (gravedad) {
  GravedadCampana.baja => Tono.informacion,
  GravedadCampana.media => Tono.advertencia,
  GravedadCampana.alta => Tono.peligro,
  GravedadCampana.critica => Tono.peligro,
};

String textoEstadoCampana(AppLocalizations textos, EstadoCampana estado) =>
    switch (estado) {
      EstadoCampana.abierta => textos.campanasEstadoAbierta,
      EstadoCampana.agendada => textos.campanasEstadoAgendada,
      EstadoCampana.atendida => textos.campanasEstadoAtendida,
    };

Tono tonoEstadoCampana(EstadoCampana estado) => switch (estado) {
  EstadoCampana.abierta => Tono.advertencia,
  EstadoCampana.agendada => Tono.informacion,
  EstadoCampana.atendida => Tono.exito,
};
