/// El km capturado es menor a la última lectura (422 `KM_INVALIDO`).
///
/// La pantalla lo explica en el campo de km: no es un fallo de red ni se
/// reintenta igual.
class KmInvalido implements Exception {
  const KmInvalido();

  @override
  String toString() => 'KmInvalido';
}
