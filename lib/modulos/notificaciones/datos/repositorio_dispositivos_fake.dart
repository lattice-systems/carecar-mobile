import '../dominio/push.dart';

/// `RepositorioDispositivos` en memoria: anota cada llamada en [llamadas] y
/// falla con [fallarCon] si se le pide.
class RepositorioDispositivosFake implements RepositorioDispositivos {
  final llamadas = <String>[];

  /// Si no es nulo, cada llamada lo lanza y no se anota.
  Object? fallarCon;

  @override
  Future<void> registrar({
    required String instalacionId,
    required String tokenFcm,
    required PlataformaPush plataforma,
    String? idioma,
  }) async {
    final error = fallarCon;
    if (error != null) throw error;
    llamadas.add('PUT $instalacionId $tokenFcm ${plataforma.valor} $idioma');
  }

  @override
  Future<void> darDeBaja(String instalacionId) async {
    final error = fallarCon;
    if (error != null) throw error;
    llamadas.add('DELETE $instalacionId');
  }
}
