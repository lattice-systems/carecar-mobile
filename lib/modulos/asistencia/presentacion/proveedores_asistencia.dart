import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../nucleo/api/proveedores_api.dart';
import '../datos/repositorio_asistencia_api.dart';
import '../dominio/contacto_de_llamada.dart';
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

/// Aseguradora del cliente para el boton de llamar (V2-M11.02).
///
/// SUPUESTO (V2-M09.01 es de Haziel y aun no se integra): hoy no hay de donde
/// leerla y devuelve `null`, asi que el boton explica como agregarla. Cuando
/// existan los documentos del auto, `ref.watch` aqui la poliza vigente del
/// vehiculo y arma [Aseguradora] con su nombre y telefono de siniestros. En
/// pruebas: `aseguradoraProvider.overrideWithValue(const Aseguradora(...))`.
final aseguradoraProvider = Provider<Aseguradora?>(
  (ref) => null,
  name: 'aseguradoraProvider',
);

/// Abre el marcador con un `tel:`; `false` si no se pudo. En pruebas se
/// sustituye para no salir de la app.
final abrirLlamadaProvider = Provider<Future<bool> Function(Uri)>(
  (ref) =>
      (enlace) => launchUrl(enlace),
  name: 'abrirLlamadaProvider',
);
