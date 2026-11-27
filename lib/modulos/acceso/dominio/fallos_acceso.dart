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

/// Esa sesion ya no esta donde la lista creia · V2-M01.09.
///
/// Llega como **404** al cerrar una sesion, y no significa necesariamente que
/// la sesion muriera: el backend **crea una fila nueva en cada refresco**, asi
/// que el `id` que la pantalla tiene en mano envejece. Si la otra sesion se
/// refresco entremedias, el `DELETE` del id viejo no encuentra nada y **la
/// sesion sigue viva con otro id**.
///
/// Por eso no se trata como exito: quitarla de la lista le diria al cliente
/// que echo al intruso cuando no lo hizo. Quien lo reciba vuelve a leer la
/// lista y ofrece intentar otra vez.
class SesionYaNoEsta implements Exception {
  const SesionYaNoEsta();

  @override
  String toString() => 'SesionYaNoEsta';
}

/// La contraseña actual no coincide · V2-M01.07.
///
/// Llega como **400 con `codigo: CREDENCIALES_INVALIDAS`**, el mismo código
/// HTTP que un correo mal escrito (`DATOS_INVALIDOS`): solo los separa
/// `Problema.codigo`. Si se confundieran, la pantalla culparía al correo
/// cuando lo que falló fue la contraseña, y la persona corregiría lo que
/// estaba bien.
///
/// El servidor responde 400 y no 401 a propósito: la app lee un 401 como
/// sesión vencida y cerraría la sesión sin explicar nada.
class ContrasenaNoCoincide implements Exception {
  const ContrasenaNoCoincide();

  @override
  String toString() => 'ContrasenaNoCoincide';
}

/// Ese correo ya es de otro cliente · V2-M01.07.
///
/// Puede llegar en los dos pasos: al pedir el cambio, o al confirmarlo si
/// alguien lo tomó mientras se verificaba.
class CorreoEnUso implements Exception {
  const CorreoEnUso();

  @override
  String toString() => 'CorreoEnUso';
}

/// El código de verificación no sirve · V2-M01.07.
///
/// Equivocado, ya usado o vencido llegan **igual**, y el contrato no los
/// distingue a propósito: responder distinto permitiría averiguar qué códigos
/// existen. En los tres casos la salida es la misma, pedir otro.
class CodigoNoValido implements Exception {
  const CodigoNoValido();

  @override
  String toString() => 'CodigoNoValido';
}
