import 'lealtad.dart';

/// Por que no se pudo canjear (409 del contrato).
enum MotivoRechazoCanje { saldoInsuficiente, agotada }

class CanjeRechazado implements Exception {
  const CanjeRechazado(this.motivo);

  final MotivoRechazoCanje motivo;

  @override
  String toString() => 'CanjeRechazado($motivo)';
}

/// Por que no se pudo referir (409 del contrato).
enum MotivoRechazoReferido { duplicado, limite }

class ReferidoRechazado implements Exception {
  const ReferidoRechazado(this.motivo);

  final MotivoRechazoReferido motivo;

  @override
  String toString() => 'ReferidoRechazado($motivo)';
}

/// Lealtad y recompensas del cliente (V2-M12).
abstract interface class RepositorioLealtad {
  Future<ResumenLealtad> resumen();

  Future<PaginaMovimientos> movimientos({int pagina = 0, int tamano = 20});

  Future<List<Recompensa>> recompensas();

  /// Lanza [CanjeRechazado] si no alcanzan los puntos o se agoto.
  Future<Canje> canjear(int recompensaId);

  Future<List<Canje>> canjes();

  /// Lanza [ReferidoRechazado] si ya es cliente o ya lo refirieron, o si
  /// tiene el maximo abierto.
  Future<Referido> referir({
    required String nombre,
    String? telefono,
    String? correo,
  });

  Future<List<Referido>> referidos();
}
