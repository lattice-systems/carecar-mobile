import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../nucleo/api/proveedores_api.dart';
import '../datos/repositorio_sucursales_api.dart';
import '../dominio/repositorio_sucursales.dart';
import '../dominio/sucursal.dart';

/// Repositorio de sucursales. En pruebas:
/// `repositorioSucursalesProvider.overrideWithValue(RepositorioSucursalesFake())`.
final repositorioSucursalesProvider = Provider<RepositorioSucursales>(
  (ref) => RepositorioSucursalesApi(ref.watch(carecarApiProvider)),
  name: 'repositorioSucursalesProvider',
);

/// Las sucursales activas, la principal primero (V2-M27.02).
///
/// Se pide de nuevo cada vez que se abre la pantalla (`autoDispose`): «abierto
/// ahora» cambia con la hora y lo calcula el servidor, así que no se guarda.
final sucursalesProvider = FutureProvider.autoDispose<List<Sucursal>>(
  (ref) => ref.watch(repositorioSucursalesProvider).sucursales(),
  // El reintento es del usuario (boton de EstadoError), no automatico.
  retry: (_, _) => null,
  name: 'sucursalesProvider',
);

/// La sucursal principal, o `null` si la agencia no ha publicado ninguna.
///
/// Es lo que otros módulos leen para no repetir el teléfono ni la dirección de
/// la agencia: la dirección del evento de calendario de una cita (V2-M02.12) y
/// el teléfono del botón de llamar de la asistencia (V2-M11.02). Si la lectura
/// falla, el error llega a quien lo observa; quien necesite un respaldo (el
/// valor de `Agencia`) lo usa en `when(error: ...)`.
final sucursalPrincipalProvider = FutureProvider.autoDispose<Sucursal?>(
  (ref) async {
    final sucursales = await ref.watch(sucursalesProvider.future);
    return sucursales.isEmpty ? null : sucursales.first;
  },
  retry: (_, _) => null,
  name: 'sucursalPrincipalProvider',
);

/// Abre un `tel:` o el enlace de mapas en la app del sistema; `false` si no
/// hay con qué abrirlo. En pruebas se sustituye para no salir de la app.
final abrirEnlaceDeSucursalProvider = Provider<Future<bool> Function(Uri)>(
  (ref) =>
      (enlace) => launchUrl(enlace, mode: LaunchMode.externalApplication),
  name: 'abrirEnlaceDeSucursalProvider',
);
