import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../nucleo/api/proveedores_api.dart';
import '../datos/repositorio_asistencia_api.dart';
import '../dominio/repositorio_asistencia.dart';
import '../dominio/solicitud_asistencia.dart';

/// Repositorio de asistencia. En pruebas:
/// `repositorioAsistenciaProvider.overrideWithValue(RepositorioAsistenciaFake())`.
final repositorioAsistenciaProvider = Provider<RepositorioAsistencia>(
  (ref) => RepositorioAsistenciaApi(ref.watch(apiClienteProvider)),
  name: 'repositorioAsistenciaProvider',
);

/// La solicitud abierta del cliente, o `null`. Se consulta cada vez que se
/// abre la pantalla: la ubicacion y la solicitud no se guardan en el telefono.
final solicitudActivaProvider =
    FutureProvider.autoDispose<SolicitudAsistencia?>(
      (ref) => ref.watch(repositorioAsistenciaProvider).activa(),
      // El reintento es del usuario (boton de EstadoError), no automatico.
      retry: (_, _) => null,
      name: 'solicitudActivaProvider',
    );
