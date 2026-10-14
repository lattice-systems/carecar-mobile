/// Formato de error del backend (el `ApiError` de `shared/exception`).
///
/// La guia de estilos pide mostrar [message] tal cual al usuario. Queda abierto
/// si siempre viene en espanol y sin detalle tecnico: pregunta RIC-14.
class Problema {
  const Problema({
    required this.timestamp,
    required this.status,
    required this.error,
    required this.message,
    required this.path,
  });

  /// Tolerante a proposito: un cuerpo de error incompleto no debe provocar un
  /// segundo error mientras se intenta reportar el primero.
  factory Problema.fromJson(Map<String, Object?> json) => Problema(
    timestamp: json['timestamp'] as String? ?? '',
    status: (json['status'] as num?)?.toInt() ?? 0,
    error: json['error'] as String? ?? 'Error',
    message: (json['message'] as String?)?.trim().isNotEmpty == true
        ? json['message'] as String
        : 'Ocurrio un error inesperado. Intenta de nuevo.',
    path: json['path'] as String? ?? '',
  );

  final String timestamp;
  final int status;
  final String error;
  final String message;
  final String path;
}
