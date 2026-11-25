/// Etapas de la orden en el taller (V2-M04.02), en el orden en que pasan.
enum EtapaTaller {
  recibido('RECIBIDO'),
  diagnostico('DIAGNOSTICO'),
  esperandoAprobacion('ESPERANDO_APROBACION'),
  enReparacion('EN_REPARACION'),
  controlDeCalidad('CONTROL_DE_CALIDAD'),
  lavado('LAVADO'),
  listoParaEntrega('LISTO_PARA_ENTREGA'),
  entregado('ENTREGADO');

  const EtapaTaller(this.enElContrato);

  final String enElContrato;

  /// La etapa del contrato, o nula si el backend manda una que esta version de
  /// la app aun no conoce.
  static EtapaTaller? desde(String? valor) {
    for (final etapa in values) {
      if (etapa.enElContrato == valor) return etapa;
    }
    return null;
  }
}

/// Como se ve una etapa en la linea de tiempo.
enum EstadoEtapa { hecha, actual, pendiente }
