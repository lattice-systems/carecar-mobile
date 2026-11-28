import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../api/excepciones.dart';
import '../../../nucleo/api/api_cliente.dart';
import '../dominio/centro_ayuda.dart';

class RepositorioCentroAyudaApi implements RepositorioCentroAyuda {
  const RepositorioCentroAyudaApi(this.api);
  final ApiCliente api;
  static const _cacheKey = 'centro_ayuda_preguntas_v1';

  @override
  Future<List<PreguntaFrecuente>> preguntas() async {
    final List<PreguntaFrecuente> resultado;
    try {
      resultado = await api.obtenerLista(
        '/ayuda/preguntas-frecuentes',
        PreguntaFrecuente.desdeJson,
      );
    } on SinConexion {
      final guardado = (await SharedPreferences.getInstance()).getString(
        _cacheKey,
      );
      if (guardado == null) rethrow;
      return [
        for (final item in jsonDecode(guardado) as List)
          PreguntaFrecuente.desdeJson(Map<String, Object?>.from(item as Map)),
      ];
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _cacheKey,
        jsonEncode([
          for (final item in resultado)
            {
              'id': item.id,
              'tema': item.tema,
              'pregunta': item.pregunta,
              'respuesta': item.respuesta,
              'orden': item.orden,
            },
        ]),
      );
    } on Exception {
      // Una falla de almacenamiento no impide mostrar la respuesta de la API.
    }
    return resultado;
  }

  @override
  Future<void> reportar({
    required String descripcion,
    required String version,
    required String sistema,
    required String dispositivo,
  }) => api.enviarSinRespuesta(
    '/ayuda/reportes',
    cuerpo: {
      'descripcion': descripcion,
      'versionApp': version,
      'sistema': sistema,
      'dispositivo': dispositivo,
    },
  );
}
