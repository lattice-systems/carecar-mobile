import '../../../api/excepciones.dart';
import '../../../api/modelos/problema.dart';
import '../../../nucleo/api/api_cliente.dart';
import '../dominio/campana_seguridad.dart';
import '../dominio/garantia_vehiculo.dart';
import '../dominio/repositorio_garantia.dart';
import 'lectura_garantia.dart';

/// `GET /vehiculos/{id}/garantia`, `GET /vehiculos/{id}/campanas` y
/// `POST /vehiculos/{id}/campanas/{campanaId}/cita` con el cliente del
/// nucleo. Las excepciones de la API pasan tal cual; solo se traducen los 409
/// que la pantalla de agendar explica.
class RepositorioGarantiaApi implements RepositorioGarantia {
  const RepositorioGarantiaApi(this._cliente);

  final ApiCliente _cliente;

  static const _lectura = LecturaGarantia();

  @override
  Future<GarantiaVehiculo> garantia(int vehiculoId) =>
      _cliente.obtener('/vehiculos/$vehiculoId/garantia', _lectura.garantia);

  @override
  Future<List<CampanaSeguridad>> campanas(int vehiculoId) => _cliente
      .obtenerLista('/vehiculos/$vehiculoId/campanas', _lectura.campana);

  @override
  Future<CitaDeCampana> agendarCampana({
    required int vehiculoId,
    required int campanaId,
    required int franjaId,
    required DateTime fecha,
  }) async {
    try {
      return await _cliente.enviar(
        '/vehiculos/$vehiculoId/campanas/$campanaId/cita',
        cuerpo: {'franjaId': franjaId, 'fecha': _dia(fecha)},
        leer: _lectura.cita,
      );
    } on Conflicto catch (conflicto) {
      final motivo = switch (conflicto.problema?.codigo) {
        CodigoProblema.campanaNoAgendable => MotivoRechazoCampana.yaAgendada,
        CodigoProblema.franjaSinCupo => MotivoRechazoCampana.sinCupo,
        CodigoProblema.citaDuplicada => MotivoRechazoCampana.citaDuplicada,
        _ => null,
      };
      if (motivo == null) rethrow;
      throw AgendaCampanaRechazada(motivo);
    }
  }

  static String _dia(DateTime fecha) =>
      '${fecha.year.toString().padLeft(4, '0')}-'
      '${fecha.month.toString().padLeft(2, '0')}-'
      '${fecha.day.toString().padLeft(2, '0')}';
}
