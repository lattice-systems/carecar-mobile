import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../nucleo/api/api_cliente.dart';
import '../../../nucleo/api/proveedores_api.dart';
import '../dominio/encuesta.dart';

class RepositorioEncuestas {
  const RepositorioEncuestas(this._api);

  final ApiCliente _api;

  Future<List<EncuestaPendiente>> pendientes() =>
      _api.obtenerLista('/encuestas/pendientes', EncuestaPendiente.desdeJson);

  Future<void> posponer(int id) =>
      _api.enviarSinRespuesta('/encuestas/$id/posponer');

  Future<void> responder(
    int id,
    Map<CalificacionEncuesta, int> notas,
    String comentario,
  ) => _api.enviarSinRespuesta(
    '/encuestas/$id/responder',
    cuerpo: {
      for (final nota in notas.entries) nota.key.name: nota.value,
      if (comentario.isNotEmpty) 'comentario': comentario,
    },
  );

  Future<void> contacto(int id) =>
      _api.enviarSinRespuesta('/encuestas/$id/contacto');
}

final repositorioEncuestasProvider = Provider<RepositorioEncuestas>(
  (ref) => RepositorioEncuestas(ref.watch(apiClienteProvider)),
);

final encuestasPendientesProvider =
    FutureProvider.autoDispose<List<EncuestaPendiente>>(
      (ref) => ref.watch(repositorioEncuestasProvider).pendientes(),
      retry: (_, _) => null,
    );
