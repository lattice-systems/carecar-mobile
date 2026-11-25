/// El enlace de recuperacion ya no sirve · V2-M01.04.
///
/// Llega como **400 con `codigo: CODIGO_INVALIDO`**, el mismo codigo HTTP que
/// una contrasena que no cumple las reglas (`DATOS_INVALIDOS`): solo los
/// separa `Problema.codigo`. Si se confundieran, la pantalla ofreceria «pide
/// otro enlace» cuando lo unico malo era la contrasena.
///
/// El contrato no distingue vencido de usado a proposito, asi que la app
/// tampoco: en los dos casos la salida es la misma, pedir otro.
class EnlaceNoValido implements Exception {
  const EnlaceNoValido();

  @override
  String toString() => 'EnlaceNoValido';
}
