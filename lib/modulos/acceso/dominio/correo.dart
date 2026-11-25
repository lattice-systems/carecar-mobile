/// Si un texto **parece** un correo · M01.
///
/// Validacion minima a proposito: que tenga algo antes de una arroba y un
/// punto despues. No se usa una expresion regular estricta porque **rechazar
/// un correo valido es peor que dejar pasar uno raro**: el backend valida
/// igual, ignora mayusculas y recorta espacios (RIC-8), y un cliente que no
/// puede escribir su propio correo no tiene a donde ir.
///
/// Vive en `dominio/` y no en una pantalla porque lo usan dos: el acceso y la
/// recuperacion. Devuelve un booleano y no un texto: el mensaje lo elige la
/// presentacion desde el ARB.
bool pareceCorreo(String correo) {
  final arroba = correo.indexOf('@');
  return arroba > 0 && correo.contains('.', arroba);
}
