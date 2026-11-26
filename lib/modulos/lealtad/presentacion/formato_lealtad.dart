import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import '../../../l10n/app_localizations.dart';
import '../../../nucleo/diseno/componentes/tono.dart';
import '../dominio/lealtad.dart';

String _idioma(BuildContext context) =>
    Localizations.localeOf(context).toString();

/// Puntos con separador de miles: `1,330`. En espanol se usa el formato de
/// Mexico (coma de miles), no el de Espana.
String puntosLealtad(BuildContext context, int puntos) {
  final idioma = Localizations.localeOf(context);
  final locale = idioma.languageCode == 'es' ? 'es_MX' : idioma.toString();
  return NumberFormat.decimalPattern(locale).format(puntos);
}

/// Fecha corta en la hora del telefono: `25 dic 2026`.
String fechaLealtad(BuildContext context, DateTime momento) =>
    DateFormat.yMMMd(_idioma(context)).format(momento.toLocal());

String textoNivel(AppLocalizations textos, NivelLealtad nivel) =>
    switch (nivel) {
      NivelLealtad.bronce => textos.lealtadNivelBronce,
      NivelLealtad.plata => textos.lealtadNivelPlata,
      NivelLealtad.oro => textos.lealtadNivelOro,
    };

Tono tonoNivel(NivelLealtad nivel) => switch (nivel) {
  NivelLealtad.bronce => Tono.advertencia,
  NivelLealtad.plata => Tono.informacion,
  NivelLealtad.oro => Tono.exito,
};

String textoMotivo(AppLocalizations textos, MotivoPuntos motivo) =>
    switch (motivo) {
      MotivoPuntos.servicio => textos.movimientosMotivoServicio,
      MotivoPuntos.canje => textos.movimientosMotivoCanje,
      MotivoPuntos.devolucionCanje => textos.movimientosMotivoDevolucion,
      MotivoPuntos.referido => textos.movimientosMotivoReferido,
      MotivoPuntos.ajuste => textos.movimientosMotivoAjuste,
      MotivoPuntos.desconocido => textos.movimientosMotivoOtro,
    };

/// A que se refiere un movimiento: la orden, el canje o el amigo referido;
/// nulo si no tiene referencia.
String? textoReferencia(AppLocalizations textos, MovimientoPuntos m) {
  final id = m.referenciaId;
  return switch (m.referenciaTipo) {
    'ORDEN' when id != null => textos.movimientosOrden(id),
    'CANJE' when id != null => textos.movimientosCanje(id),
    'REFERIDO' => textos.movimientosMotivoReferido,
    _ => null,
  };
}

String textoEstadoCanje(AppLocalizations textos, EstadoCanje estado) =>
    switch (estado) {
      EstadoCanje.vigente => textos.canjesEstadoVigente,
      EstadoCanje.usado => textos.canjesEstadoUsado,
      EstadoCanje.vencido => textos.canjesEstadoVencido,
    };

Tono tonoEstadoCanje(EstadoCanje estado) => switch (estado) {
  EstadoCanje.vigente => Tono.exito,
  EstadoCanje.usado => Tono.neutro,
  EstadoCanje.vencido => Tono.advertencia,
};

/// La fecha que importa de un canje: hasta cuando vale, cuando se uso o
/// cuando vencio.
String textoFechaCanje(BuildContext context, Canje canje) {
  final textos = AppLocalizations.of(context);
  return switch (canje.estado) {
    EstadoCanje.vigente => textos.canjesVence(
      fechaLealtad(context, canje.venceEn),
    ),
    EstadoCanje.usado => textos.canjesUsado(
      fechaLealtad(context, canje.usadoEn ?? canje.venceEn),
    ),
    EstadoCanje.vencido => textos.canjesVencio(
      fechaLealtad(context, canje.venceEn),
    ),
  };
}

String textoEstadoReferido(AppLocalizations textos, EstadoReferido estado) =>
    switch (estado) {
      EstadoReferido.registrado => textos.referidoEstadoRegistrado,
      EstadoReferido.enSeguimiento => textos.referidoEstadoSeguimiento,
      EstadoReferido.compro => textos.referidoEstadoCompro,
      EstadoReferido.descartado => textos.referidoEstadoDescartado,
    };
