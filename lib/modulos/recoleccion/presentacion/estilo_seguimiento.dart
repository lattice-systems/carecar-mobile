import '../../../api/modelos/traslado.dart';
import '../../../l10n/app_localizations.dart';

/// Los estados de un traslado, en el orden en que ocurren. «Cancelado» no
/// está: corta la línea en cualquier punto.
const pasosDeTraslado = <EstadoTraslado>[
  EstadoTraslado.programado,
  EstadoTraslado.enCamino,
  EstadoTraslado.recogido,
  EstadoTraslado.enTaller,
  EstadoTraslado.deRegreso,
  EstadoTraslado.entregado,
];

/// Traduce estados y niveles a los textos del ARB. El dominio no arma textos.
extension TextosDeSeguimiento on AppLocalizations {
  String nombreDeEstadoTraslado(EstadoTraslado estado) => switch (estado) {
    EstadoTraslado.programado => recoleccionEstadoProgramado,
    EstadoTraslado.enCamino => recoleccionEstadoEnCamino,
    EstadoTraslado.recogido => recoleccionEstadoRecogido,
    EstadoTraslado.enTaller => recoleccionEstadoEnTaller,
    EstadoTraslado.deRegreso => recoleccionEstadoDeRegreso,
    EstadoTraslado.entregado => recoleccionEstadoEntregado,
    EstadoTraslado.cancelado => recoleccionEstadoCancelado,
  };

  /// Detalle bajo el paso actual; solo los estados con chofer en el mapa lo
  /// llevan.
  String? notaDeEstadoTraslado(EstadoTraslado estado) => switch (estado) {
    EstadoTraslado.enCamino => recoleccionEstadoNotaEnCamino,
    EstadoTraslado.deRegreso => recoleccionEstadoNotaDeRegreso,
    _ => null,
  };

  String tituloDeTraslado(TrasladoDetalle traslado) => traslado.esRecoger
      ? recoleccionSeguimientoRecoger
      : recoleccionSeguimientoEntregar;

  String nombreDeGasolina(NivelGasolina nivel) => switch (nivel) {
    NivelGasolina.vacio => recoleccionGasolinaVacio,
    NivelGasolina.unCuarto => recoleccionGasolinaUnCuarto,
    NivelGasolina.medio => recoleccionGasolinaMedio,
    NivelGasolina.tresCuartos => recoleccionGasolinaTresCuartos,
    NivelGasolina.lleno => recoleccionGasolinaLleno,
  };
}
