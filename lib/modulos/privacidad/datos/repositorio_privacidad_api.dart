import '../../../api/carecar_api.dart';
import '../../../api/excepciones.dart';
import '../../../api/modelos/privacidad.dart';
import '../../../api/modelos/problema.dart';
import '../dominio/privacidad.dart';

/// [RepositorioPrivacidad] contra el contrato 2.13.0 (V2-M22.01). Decide los
/// fallos por el `codigo`, nunca por el texto.
class RepositorioPrivacidadApi implements RepositorioPrivacidad {
  const RepositorioPrivacidadApi(this._api);

  final CarecarApi _api;

  @override
  Future<AvisoDePrivacidad> avisoVigente() => _traducir(() async {
    final a = await _api.avisoDePrivacidad();
    return _aviso(a);
  });

  @override
  Future<void> aceptar(int avisoId) =>
      _traducir(() => _api.aceptarAvisoDePrivacidad(avisoId));

  static Future<T> _traducir<T>(Future<T> Function() llamada) async {
    try {
      return await llamada();
    } on SinConexion {
      throw const PrivacidadSinConexion();
    } on ExcepcionApi catch (e) {
      throw switch (e.problema?.codigo) {
        CodigoProblema.avisoNoVigente => const AvisoNoVigente(),
        _ => const PrivacidadNoDisponible(),
      };
    }
  }

  static AvisoDePrivacidad _aviso(AvisoPrivacidad a) => AvisoDePrivacidad(
    id: a.id,
    version: a.version,
    texto: a.texto,
    vigenteDesde: a.vigenteDesde,
    aceptado: a.aceptado,
    aceptadoEn: a.aceptadoEn,
  );
}
