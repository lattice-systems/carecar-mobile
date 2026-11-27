import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../nucleo/api/proveedores_api.dart';
import '../../documentos/documentos.dart';
import '../../vehiculos/vehiculos.dart' show garajeProvider;
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

/// La poliza a la que se puede llamar entre los documentos de todos los autos
/// del cliente (V2-M11.02 con V2-M09.01), y si todavia se esta leyendo.
///
/// Espera al garaje y a los documentos de cada auto. Si algo falla o no hay
/// poliza no vencida con aseguradora y telefono, no hay poliza: el boton lo
/// explica en vez de romperse. Es `autoDispose`: se vuelve a leer cada vez que
/// se abre la pantalla de llamadas, porque la poliza pudo vencer o cambiar.
final _polizaDeMisAutosProvider =
    Provider.autoDispose<({DocumentoVehiculo? poliza, bool buscando})>((ref) {
      final garaje = ref.watch(garajeProvider);
      var buscando = garaje.isLoading;
      final documentos = <DocumentoVehiculo>[];
      for (final vehiculo in garaje.value ?? const []) {
        final delAuto = ref.watch(documentosProvider(vehiculo.id));
        buscando = buscando || delAuto.isLoading;
        documentos.addAll(delAuto.value ?? const []);
      }
      return (poliza: polizaParaLlamar(documentos), buscando: buscando);
    }, name: '_polizaDeMisAutosProvider');

/// Aseguradora del cliente para el boton de llamar (V2-M11.02): el nombre y el
/// telefono de la poliza no vencida de sus documentos (V2-M09.01), o `null` si
/// no hay, para que la pantalla explique como agregarla. En pruebas:
/// `aseguradoraProvider.overrideWithValue(const Aseguradora(...))`.
final aseguradoraProvider = Provider.autoDispose<Aseguradora?>((ref) {
  final poliza = ref.watch(_polizaDeMisAutosProvider).poliza;
  final nombre = poliza?.aseguradora;
  final telefono = poliza?.telefonoAseguradora;
  if (nombre == null || telefono == null) return null;
  return Aseguradora(nombre: nombre, telefono: telefono);
}, name: 'aseguradoraProvider');

/// Si todavia se esta leyendo la poliza: la pantalla no debe decir que falta
/// mientras se busca. En pruebas:
/// `aseguradoraCargandoProvider.overrideWithValue(false)`.
final aseguradoraCargandoProvider = Provider.autoDispose<bool>(
  (ref) => ref.watch(_polizaDeMisAutosProvider).buscando,
  name: 'aseguradoraCargandoProvider',
);

/// Abre el marcador con un `tel:`; `false` si no se pudo. En pruebas se
/// sustituye para no salir de la app.
final abrirLlamadaProvider = Provider<Future<bool> Function(Uri)>(
  (ref) =>
      (enlace) => launchUrl(enlace),
  name: 'abrirLlamadaProvider',
);
