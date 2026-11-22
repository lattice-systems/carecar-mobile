import 'aviso.dart';

/// Contrato que la presentacion usa para leer avisos.
///
/// Vive en `dominio/` para que la presentacion no dependa de como se obtienen
/// los datos (red, base local, fake).
abstract interface class RepositorioAvisos {
  Future<List<Aviso>> avisos();
}
