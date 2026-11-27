import '../../../api/excepciones.dart';
import '../../../api/modelos/problema.dart';
import '../../../nucleo/api/api_cliente.dart';
import '../dominio/lealtad.dart';
import '../dominio/repositorio_lealtad.dart';
import 'lectura_lealtad.dart';

/// `/lealtad` y sus rutas con el cliente del nucleo. Las excepciones de la API
/// pasan tal cual; solo se traducen los 409 que las pantallas explican.
class RepositorioLealtadApi implements RepositorioLealtad {
  const RepositorioLealtadApi(this._cliente);

  final ApiCliente _cliente;

  static const _lectura = LecturaLealtad();

  @override
  Future<ResumenLealtad> resumen() =>
      _cliente.obtener('/lealtad', _lectura.resumen);

  @override
  Future<PaginaMovimientos> movimientos({int pagina = 0, int tamano = 20}) =>
      _cliente.obtener(
        '/lealtad/movimientos',
        _lectura.pagina,
        consulta: {'pagina': '$pagina', 'tamano': '$tamano'},
      );

  @override
  Future<List<Recompensa>> recompensas() =>
      _cliente.obtenerLista('/lealtad/recompensas', _lectura.recompensa);

  @override
  Future<Canje> canjear(int recompensaId) async {
    try {
      return await _cliente.enviar(
        '/lealtad/canjes',
        cuerpo: {'recompensaId': recompensaId},
        leer: _lectura.canje,
      );
    } on Conflicto catch (conflicto) {
      final motivo = switch (conflicto.problema?.codigo) {
        CodigoProblema.saldoInsuficiente =>
          MotivoRechazoCanje.saldoInsuficiente,
        CodigoProblema.recompensaAgotada => MotivoRechazoCanje.agotada,
        _ => null,
      };
      if (motivo == null) rethrow;
      throw CanjeRechazado(motivo);
    }
  }

  @override
  Future<List<Canje>> canjes() =>
      _cliente.obtenerLista('/lealtad/canjes', _lectura.canje);

  @override
  Future<Referido> referir({
    required String nombre,
    String? telefono,
    String? correo,
  }) async {
    try {
      return await _cliente.enviar(
        '/lealtad/referidos',
        cuerpo: {
          'nombre': nombre,
          'telefono': ?telefono,
          'correo': ?correo,
          'consentimiento': true,
        },
        leer: _lectura.referido,
      );
    } on Conflicto catch (conflicto) {
      final motivo = switch (conflicto.problema?.codigo) {
        CodigoProblema.referidoDuplicado => MotivoRechazoReferido.duplicado,
        CodigoProblema.limiteReferidos => MotivoRechazoReferido.limite,
        _ => null,
      };
      if (motivo == null) rethrow;
      throw ReferidoRechazado(motivo);
    }
  }

  @override
  Future<List<Referido>> referidos() =>
      _cliente.obtenerLista('/lealtad/referidos', _lectura.referido);
}
