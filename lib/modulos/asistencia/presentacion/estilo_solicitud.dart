import 'package:flutter/material.dart';

import 'package:lucide_icons_flutter/lucide_icons_300.dart';

import '../../../l10n/app_localizations.dart';
import '../dominio/solicitud_asistencia.dart';
import 'ubicacion_para_ayuda.dart';

/// Icono de cada tipo de problema, compartido por el formulario y por la
/// solicitud enviada.
extension EstiloDeTipoAsistencia on TipoAsistencia {
  IconData get icono => switch (this) {
    TipoAsistencia.llanta => LucideIcons300.lifeBuoy,
    TipoAsistencia.bateria => LucideIcons300.batteryCharging,
    TipoAsistencia.choque => LucideIcons300.triangleAlert,
    TipoAsistencia.sinGasolina => LucideIcons300.fuel,
    TipoAsistencia.otro => LucideIcons300.circleQuestionMark,
  };
}

/// Traduce tipos y motivos a los textos del ARB. El dominio no arma textos.
extension TextosDeAsistencia on AppLocalizations {
  String nombreDeTipo(TipoAsistencia tipo) => switch (tipo) {
    TipoAsistencia.llanta => asistenciaTipoLlanta,
    TipoAsistencia.bateria => asistenciaTipoBateria,
    TipoAsistencia.choque => asistenciaTipoChoque,
    TipoAsistencia.sinGasolina => asistenciaTipoSinGasolina,
    TipoAsistencia.otro => asistenciaTipoOtro,
  };

  String nombreDeEstado(EstadoSolicitud estado) => switch (estado) {
    EstadoSolicitud.recibida => asistenciaEstadoRecibida,
    EstadoSolicitud.enCamino => asistenciaEstadoEnCamino,
    EstadoSolicitud.atendida => asistenciaEstadoAtendida,
    EstadoSolicitud.cancelada => asistenciaEstadoCancelada,
  };

  String notaDeEstado(EstadoSolicitud estado) => switch (estado) {
    EstadoSolicitud.recibida => asistenciaEstadoNotaRecibida,
    EstadoSolicitud.enCamino => asistenciaEstadoNotaEnCamino,
    EstadoSolicitud.atendida => asistenciaEstadoNotaAtendida,
    EstadoSolicitud.cancelada => asistenciaEstadoNotaCancelada,
  };

  String mensajeSinUbicacion(MotivoSinUbicacion motivo) => switch (motivo) {
    MotivoSinUbicacion.permisoDenegado => asistenciaUbicacionPermisoDenegado,
    MotivoSinUbicacion.permisoBloqueado => asistenciaUbicacionPermisoBloqueado,
    MotivoSinUbicacion.servicioApagado => asistenciaUbicacionServicioApagado,
    MotivoSinUbicacion.tiempoAgotado => asistenciaUbicacionTiempoAgotado,
  };
}
