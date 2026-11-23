/// La dirección queda fuera de la zona de cobertura (422
/// `FUERA_DE_COBERTURA`). No se guarda ni se puede pedir recolección en ella.
class FueraDeCobertura implements Exception {
  const FueraDeCobertura();

  @override
  String toString() => 'FueraDeCobertura';
}

/// La dirección ya tiene traslados y no se puede borrar (409
/// `DIRECCION_EN_USO`).
class DireccionEnUso implements Exception {
  const DireccionEnUso();

  @override
  String toString() => 'DireccionEnUso';
}
