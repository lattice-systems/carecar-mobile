import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../nucleo/api/proveedores_api.dart';
import '../../../nucleo/eventos/eventos_en_vivo.dart';
import '../../../nucleo/eventos/proveedores_eventos.dart';
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

/// Nombre del aviso de `GET /eventos` cuando cambia una orden del cliente.
const eventoOrden = 'orden';

/// Si [evento] pide volver a consultar las ordenes (V2-M04.03): cambio una
/// orden (la [ordenId], si se da) o el canal volvio tras una caida y pudo
/// perderse algun aviso.
bool cambioLaOrden(EventoEnVivo evento, {int? ordenId}) =>
    evento.nombre == eventoReconectado ||
    (evento.nombre == eventoOrden &&
        (ordenId == null || evento.datos['ordenId'] == ordenId));

/// Ordenes sin entregar, para la tarjeta de Inicio (V2-M04.01). Si falla, la
/// tarjeta no aparece: Inicio no se llena de errores por algo secundario.
/// Con cada aviso en vivo de una orden se vuelve a pedir sin pasar por carga
/// (V2-M04.03 y V2-M04.06): la tarjeta cambia a «Listo» sola.
class OrdenesEnCursoNotifier extends AsyncNotifier<List<OrdenEnCurso>> {
  var _turno = 0;

  @override
  Future<List<OrdenEnCurso>> build() {
    ref.listen(eventosProvider, (_, evento) {
      if (evento case AsyncData(:final value) when cambioLaOrden(value)) {
        _recargar();
      }
    });
    return ref.watch(repositorioTallerProvider).enCurso();
  }

  Future<void> _recargar() async {
    final turno = ++_turno;
    try {
      final ordenes = await ref.read(repositorioTallerProvider).enCurso();
      if (ref.mounted && turno == _turno) state = AsyncData(ordenes);
    } on Object {
      return;
    }
  }
}

final ordenesEnCursoProvider =
    AsyncNotifierProvider.autoDispose<
      OrdenesEnCursoNotifier,
      List<OrdenEnCurso>
    >(
      OrdenesEnCursoNotifier.new,
      retry: (_, _) => null,
      name: 'ordenesEnCursoProvider',
    );

/// La orden `ordenId` con su linea de tiempo, su inspeccion y sus trabajos
/// adicionales. Responder un adicional reemplaza la orden por la que devuelve
/// el backend, con los totales recalculados. Un aviso en vivo de esta orden, o
/// la vuelta del canal tras una caida, la vuelve a pedir sin pasar por carga
/// (V2-M04.03); si esa recarga falla, se queda la que se ve.
class OrdenTallerNotifier extends AsyncNotifier<OrdenEnVivo> {
  OrdenTallerNotifier(this.ordenId);

  final int ordenId;
  var _turno = 0;

  @override
  Future<OrdenEnVivo> build() {
    ref.listen(eventosProvider, (_, evento) {
      if (evento case AsyncData(:final value)
          when cambioLaOrden(value, ordenId: ordenId)) {
        _recargar();
      }
    });
    return ref.watch(repositorioTallerProvider).orden(ordenId);
  }

  Future<void> _recargar() async {
    final turno = ++_turno;
    try {
      final orden = await ref.read(repositorioTallerProvider).orden(ordenId);
      if (ref.mounted && turno == _turno) state = AsyncData(orden);
    } on Object {
      return;
    }
  }

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
    _turno++;
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
