import 'dart:async';

import 'package:carecar_mobile/modulos/privacidad/dominio/privacidad.dart';

/// Repositorio falso del aviso de privacidad: responde lo que se le asigna,
/// guarda lo que se acepta y espera a las pruebas cuando se le pide.
class RepositorioPrivacidadFalso implements RepositorioPrivacidad {
  /// Respuestas de `avisoVigente`, una por llamada y en orden; la última se
  /// repite. Un [FalloPrivacidad] se lanza en vez de devolverse.
  final avisos = <Object>[];
  int lecturas = 0;
  final aceptados = <int>[];

  /// Fallos al aceptar, uno por intento y en orden.
  final fallosAlAceptar = <FalloPrivacidad>[];

  /// Si se asigna, leer espera a que se complete.
  Completer<void>? esperaAlLeer;

  /// Si se asigna, aceptar espera a que se complete.
  Completer<void>? esperaAlAceptar;

  @override
  Future<AvisoDePrivacidad> avisoVigente() async {
    final i = lecturas < avisos.length ? lecturas : avisos.length - 1;
    lecturas++;
    await esperaAlLeer?.future;
    final respuesta = avisos[i];
    if (respuesta is FalloPrivacidad) throw respuesta;
    return respuesta as AvisoDePrivacidad;
  }

  @override
  Future<void> aceptar(int avisoId) async {
    aceptados.add(avisoId);
    await esperaAlAceptar?.future;
    if (fallosAlAceptar.isNotEmpty) throw fallosAlAceptar.removeAt(0);
  }
}
