import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../nucleo/api/proveedores_api.dart';
import '../datos/repositorio_taller_api.dart';
import '../dominio/orden_taller.dart';
import '../dominio/repositorio_taller.dart';
import 'provisional/lienzo_firma_provisional.dart';

/// Repositorio del modulo. En pruebas:
/// `repositorioTallerProvider.overrideWithValue(RepositorioTallerFake())`.
final repositorioTallerProvider = Provider<RepositorioTaller>(
  (ref) => RepositorioTallerApi(ref.watch(apiClienteProvider)),
  retry: (_, _) => null,
  name: 'repositorioTallerProvider',
);

/// Ordenes sin entregar, para la tarjeta de Inicio (V2-M04.01). Si falla, la
/// tarjeta no aparece: Inicio no se llena de errores por algo secundario.
final ordenesEnCursoProvider = FutureProvider.autoDispose<List<OrdenEnCurso>>(
  (ref) => ref.watch(repositorioTallerProvider).enCurso(),
  retry: (_, _) => null,
  name: 'ordenesEnCursoProvider',
);

/// La orden `ordenId` con su linea de tiempo, su inspeccion y sus trabajos
/// adicionales. Responder un adicional reemplaza la orden por la que devuelve
/// el backend, con los totales recalculados.
class OrdenTallerNotifier extends AsyncNotifier<OrdenEnVivo> {
  OrdenTallerNotifier(this.ordenId);

  final int ordenId;

  @override
  Future<OrdenEnVivo> build() =>
      ref.watch(repositorioTallerProvider).orden(ordenId);

  /// Aprueba o rechaza con la firma. Si falla, la orden que se ve no cambia y
  /// el error sube a quien llamo.
  Future<void> responder({
    required int adicionalId,
    required bool aprobado,
    required Uint8List firmaPng,
  }) async {
    final respondida = await ref
        .read(repositorioTallerProvider)
        .responder(
          ordenId: ordenId,
          adicionalId: adicionalId,
          aprobado: aprobado,
          firmaPng: firmaPng,
        );
    if (!ref.mounted) return;
    state = AsyncData(respondida);
    ref.invalidate(ordenesEnCursoProvider);
  }
}

final ordenTallerProvider = AsyncNotifierProvider.autoDispose
    .family<OrdenTallerNotifier, OrdenEnVivo, int>(
      OrdenTallerNotifier.new,
      retry: (_, _) => null,
      name: 'ordenTallerProvider',
    );

/// Abre un video de la inspeccion en el reproductor del telefono. Devuelve
/// `false` si no se pudo. En pruebas se sustituye para no salir de la app.
final abrirVideoProvider = Provider<Future<bool> Function(Uri)>(
  (ref) =>
      (url) => launchUrl(url, mode: LaunchMode.externalApplication),
  name: 'abrirVideoProvider',
);

/// Convierte los trazos de la firma en un PNG. En pruebas se sustituye porque
/// pintar una imagen real necesita el motor de la app.
final exportarFirmaProvider =
    Provider<Future<Uint8List> Function(List<List<Offset>>, Size)>(
      (ref) => exportarFirmaPng,
      name: 'exportarFirmaProvider',
    );

/// Imagen de una foto de la inspeccion. En pruebas se sustituye por una en
/// memoria para no salir a la red.
final imagenEvidenciaProvider = Provider<ImageProvider Function(Uri)>(
  (ref) =>
      (url) => NetworkImage(url.toString()),
  name: 'imagenEvidenciaProvider',
);
