import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../nucleo/api/proveedores_api.dart';
import '../datos/repositorio_documentos_api.dart';
import '../dominio/documento_vehiculo.dart';
import '../dominio/repositorio_documentos.dart';

/// Repositorio del modulo. En pruebas:
/// `repositorioDocumentosProvider.overrideWithValue(RepositorioDocumentosFake())`.
final repositorioDocumentosProvider = Provider<RepositorioDocumentos>(
  (ref) => RepositorioDocumentosApi(ref.watch(apiClienteProvider)),
  retry: (_, _) => null,
  name: 'repositorioDocumentosProvider',
);

/// Los documentos del vehiculo con su estado (V2-M09.01). El estado lo calcula
/// el servidor con la fecha de la agencia, asi que se pide de nuevo cada vez
/// que se abre la pantalla.
final documentosProvider = FutureProvider.autoDispose
    .family<List<DocumentoVehiculo>, int>(
      (ref, vehiculoId) =>
          ref.watch(repositorioDocumentosProvider).documentos(vehiculoId),
      // El reintento es del usuario (boton de EstadoError), no automatico.
      retry: (_, _) => null,
      name: 'documentosProvider',
    );
