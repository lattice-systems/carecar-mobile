import 'documento_vehiculo.dart';

/// La poliza a la que se puede llamar en un siniestro (V2-M11.02), o `null`.
///
/// Cuenta una poliza con nombre de aseguradora y telefono que no este vencida:
/// una por vencer todavia protege. Entre varias gana la vigente a la que vence
/// pronto y, a igualdad, la que vence mas tarde. Sin ninguna, `null`: la
/// pantalla de llamadas explica como agregarla.
DocumentoVehiculo? polizaParaLlamar(List<DocumentoVehiculo> documentos) {
  final candidatas = documentos.where(_sirve).toList()
    ..sort((a, b) {
      final porEstado = _rango(a.estado).compareTo(_rango(b.estado));
      if (porEstado != 0) return porEstado;
      final fechaA = a.venceEn;
      final fechaB = b.venceEn;
      if (fechaA != null && fechaB != null) {
        final porFecha = fechaB.compareTo(fechaA);
        if (porFecha != 0) return porFecha;
      } else if (fechaA != fechaB) {
        return fechaA == null ? 1 : -1;
      }
      return b.id.compareTo(a.id);
    });
  return candidatas.isEmpty ? null : candidatas.first;
}

bool _sirve(DocumentoVehiculo documento) =>
    documento.tipo == TipoDocumento.poliza &&
    documento.estado != EstadoDocumento.vencido &&
    (documento.aseguradora ?? '').trim().isNotEmpty &&
    (documento.telefonoAseguradora ?? '').trim().isNotEmpty;

int _rango(EstadoDocumento estado) => switch (estado) {
  EstadoDocumento.vigente => 0,
  EstadoDocumento.porVencer => 1,
  _ => 2,
};
