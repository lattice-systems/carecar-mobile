import '../../../api/excepciones.dart';
import '../../../api/modelos/problema.dart';
import '../../../nucleo/api/api_cliente.dart';
import '../dominio/actividad_en_vivo.dart';

/// `PUT` y `DELETE /ordenes/{ordenId}/actividad-en-vivo` (V2-M25.05) con el
/// cliente del nucleo. Sin cache ni reintentos propios: quien llama decide.
/// El token no se registra en logs.
class RepositorioActividadEnVivoApi implements RepositorioActividadEnVivo {
  RepositorioActividadEnVivoApi(this._cliente);

  final ApiCliente _cliente;

  static String _ruta(int ordenId) => '/ordenes/$ordenId/actividad-en-vivo';

  @override
  Future<void> registrar({
    required int ordenId,
    required String pushToken,
  }) async {
    try {
      await _cliente.actualizarSinRespuesta(
        _ruta(ordenId),
        cuerpo: {'pushToken': pushToken},
      );
    } on Conflicto catch (conflicto) {
      if (conflicto.problema?.codigo == CodigoProblema.ordenCerrada) {
        throw const OrdenYaEntregada();
      }
      rethrow;
    }
  }

  @override
  Future<void> darDeBaja({required int ordenId, String? pushToken}) =>
      _cliente.eliminar(_ruta(ordenId), consulta: {'pushToken': pushToken});
}
