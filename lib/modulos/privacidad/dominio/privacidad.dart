/// El aviso de privacidad vigente y si esta cuenta ya lo aceptó (V2-M22.01).
///
/// Una versión publicada no cambia: una versión nueva es otro aviso con otro
/// [id], y vuelve a pedir la aceptación.
class AvisoDePrivacidad {
  const AvisoDePrivacidad({
    required this.id,
    required this.version,
    required this.texto,
    required this.vigenteDesde,
    required this.aceptado,
    this.aceptadoEn,
  });

  final int id;
  final int version;

  /// Texto completo; los párrafos van separados por una línea en blanco.
  final String texto;
  final DateTime vigenteDesde;

  /// Si esta cuenta ya aceptó esta versión.
  final bool aceptado;
  final DateTime? aceptadoEn;

  /// El texto por párrafos, sin líneas en blanco de más: así se pintan con su
  /// espacio y los lee el lector de pantalla uno a uno.
  List<String> get parrafos => texto
      .split(RegExp(r'\n\s*\n'))
      .map((p) => p.trim())
      .where((p) => p.isNotEmpty)
      .toList();
}

/// Por qué no se pudo leer o aceptar el aviso. La pantalla decide el texto.
sealed class FalloPrivacidad implements Exception {
  const FalloPrivacidad();
}

/// No hay conexión con el servidor.
class PrivacidadSinConexion extends FalloPrivacidad {
  const PrivacidadSinConexion();
}

/// Se quiso aceptar una versión que ya no es la vigente (409
/// `AVISO_NO_VIGENTE`): la agencia publicó otra mientras se leía. Hay que
/// leer la nueva.
class AvisoNoVigente extends FalloPrivacidad {
  const AvisoNoVigente();
}

/// Cualquier otro error del servidor.
class PrivacidadNoDisponible extends FalloPrivacidad {
  const PrivacidadNoDisponible();
}

/// Lo que el módulo necesita del backend (V2-M22.01).
abstract interface class RepositorioPrivacidad {
  /// El aviso vigente con el estado de esta cuenta. Falla con un
  /// [FalloPrivacidad].
  Future<AvisoDePrivacidad> avisoVigente();

  /// Registra que se leyó el aviso [avisoId]. Es idempotente. Falla con un
  /// [FalloPrivacidad], y con [AvisoNoVigente] si ya hay una versión nueva.
  Future<void> aceptar(int avisoId);
}
