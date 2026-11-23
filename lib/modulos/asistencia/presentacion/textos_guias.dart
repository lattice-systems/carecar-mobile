import '../../../l10n/app_localizations.dart';
import '../dominio/guia_emergencia.dart';

/// Traduce una guia a los textos del ARB. El dominio no arma textos.
extension TextosDeGuias on AppLocalizations {
  String tituloDeGuia(TipoGuia tipo) => switch (tipo) {
    TipoGuia.llanta => asistenciaGuiaLlantaTitulo,
    TipoGuia.corriente => asistenciaGuiaCorrienteTitulo,
    TipoGuia.choque => asistenciaGuiaChoqueTitulo,
  };

  String resumenDeGuia(TipoGuia tipo) => switch (tipo) {
    TipoGuia.llanta => asistenciaGuiaLlantaResumen,
    TipoGuia.corriente => asistenciaGuiaCorrienteResumen,
    TipoGuia.choque => asistenciaGuiaChoqueResumen,
  };

  /// Texto del paso [numero] (desde 1) de la guia [tipo].
  String pasoDeGuia(TipoGuia tipo, int numero) => switch (tipo) {
    TipoGuia.llanta => switch (numero) {
      1 => asistenciaGuiaLlantaPaso1,
      2 => asistenciaGuiaLlantaPaso2,
      3 => asistenciaGuiaLlantaPaso3,
      4 => asistenciaGuiaLlantaPaso4,
      _ => asistenciaGuiaLlantaPaso5,
    },
    TipoGuia.corriente => switch (numero) {
      1 => asistenciaGuiaCorrientePaso1,
      2 => asistenciaGuiaCorrientePaso2,
      3 => asistenciaGuiaCorrientePaso3,
      4 => asistenciaGuiaCorrientePaso4,
      5 => asistenciaGuiaCorrientePaso5,
      _ => asistenciaGuiaCorrientePaso6,
    },
    TipoGuia.choque => switch (numero) {
      1 => asistenciaGuiaChoquePaso1,
      2 => asistenciaGuiaChoquePaso2,
      3 => asistenciaGuiaChoquePaso3,
      4 => asistenciaGuiaChoquePaso4,
      5 => asistenciaGuiaChoquePaso5,
      _ => asistenciaGuiaChoquePaso6,
    },
  };
}
