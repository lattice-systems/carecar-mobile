import '../../../api/carecar_api.dart';
import '../../../api/excepciones.dart';
import '../../../api/modelos/problema.dart';
import '../dominio/repositorio_asistente.dart';

/// Pregunta con `POST /asistente/preguntas` y traduce cada error del contrato
/// a un [FalloAsistente] por su codigo, nunca por el texto.
class RepositorioAsistenteApi implements RepositorioAsistente {
  const RepositorioAsistenteApi(this._api);

  final CarecarApi _api;

  @override
  Future<RespuestaDelAsistente> preguntar({
    required int vehiculoId,
    required String pregunta,
  }) async {
    try {
      final r = await _api.preguntarAlAsistente(
        vehiculoId: vehiculoId,
        pregunta: pregunta,
      );
      return RespuestaDelAsistente(
        consultaId: r.consultaId,
        texto: r.respuesta,
        encontrado: r.encontrado,
        fuentes: [
          for (final f in r.fuentes)
            CitaDelManual(manualId: f.manualId, pagina: f.pagina),
        ],
      );
    } on SinConexion {
      throw const AsistenteSinConexion();
    } on ExcepcionApi catch (e) {
      throw switch (e.problema?.codigo) {
        CodigoProblema.asistenteSinManual => const AsistenteSinManual(),
        CodigoProblema.asistenteLimite => const AsistenteLimiteDiario(),
        _ when e is DemasiadosIntentos => const AsistenteLimiteDiario(),
        _ => const AsistenteNoDisponible(),
      };
    }
  }

  @override
  Future<void> calificar({required int consultaId, required bool util}) async {
    try {
      await _api.calificarRespuestaDelAsistente(
        consultaId: consultaId,
        util: util,
      );
    } on SinConexion {
      throw const AsistenteSinConexion();
    } on ExcepcionApi {
      throw const AsistenteNoDisponible();
    }
  }
}
