/// El kilometraje es menor a la última lectura del taller o a la última del
/// cliente (422 `KM_INVALIDO`). No se guarda: el odómetro no baja.
class KmInvalido implements Exception {
  const KmInvalido();

  @override
  String toString() => 'KmInvalido';
}
