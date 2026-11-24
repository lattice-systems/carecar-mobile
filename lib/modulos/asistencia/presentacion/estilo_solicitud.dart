import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../dominio/solicitud_asistencia.dart';
import 'ubicacion_para_ayuda.dart';

/// Icono de cada tipo de problema, compartido por el formulario y por la
/// solicitud enviada.
extension EstiloDeTipoAsistencia on TipoAsistencia {
  IconData get icono => switch (this) {
    TipoAsistencia.llanta => Icons.tire_repair_outlined,
    TipoAsistencia.bateria => Icons.battery_charging_full_outlined,
    TipoAsistencia.choque => Icons.car_crash_outlined,
    TipoAsistencia.sinGasolina => Icons.local_gas_station_outlined,
    TipoAsistencia.otro => Icons.help_outline,
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

  String mensajeSinUbicacion(MotivoSinUbicacion motivo) => switch (motivo) {
    MotivoSinUbicacion.permisoDenegado => asistenciaUbicacionPermisoDenegado,
    MotivoSinUbicacion.permisoBloqueado => asistenciaUbicacionPermisoBloqueado,
    MotivoSinUbicacion.servicioApagado => asistenciaUbicacionServicioApagado,
    MotivoSinUbicacion.tiempoAgotado => asistenciaUbicacionTiempoAgotado,
  };
}
