import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../nucleo/api/proveedores_api.dart';
import '../../../nucleo/eventos/eventos_en_vivo.dart';
import '../../../nucleo/eventos/proveedores_eventos.dart';
import '../datos/compartir_datos.dart';
import '../datos/repositorio_arco_api.dart';
import '../dominio/arco.dart';

/// Repositorio de los derechos ARCO. En pruebas:
/// `repositorioArcoProvider.overrideWithValue(...)`.
final repositorioArcoProvider = Provider<RepositorioArco>(
  (ref) => RepositorioArcoApi(ref.watch(carecarApiProvider)),
  name: 'repositorioArcoProvider',
);

/// Cada cuánto se vuelve a preguntar mientras la copia se prepara. El aviso en
/// vivo (`arco.estado`) la adelanta; esto cubre un canal caído.
final intervaloArcoProvider = Provider<Duration>(
  (ref) => const Duration(seconds: 3),
  name: 'intervaloArcoProvider',
);

/// Cómo se entrega un archivo: bytes, nombre con extensión y tipo MIME. En
/// pruebas se sustituye para no abrir la hoja del sistema.
typedef CompartirDatos = Future<void> Function(
  Uint8List bytes,
  String nombre,
  String tipoMime,
);

final compartirDatosProvider = Provider<CompartirDatos>(
  (ref) => compartirDatosConHojaDelSistema,
  name: 'compartirDatosProvider',
);

/// La última solicitud de acceso de la cuenta (V2-M22.02); `null` si nunca ha
/// pedido una copia.
///
/// Mientras hay una pendiente se vuelve a preguntar solo: con el aviso en vivo
/// `arco.estado` y, por si el canal se cae, cada [intervaloArcoProvider]. Es
/// `autoDispose`: al salir de la pantalla deja de preguntar y cierra el canal.
final accesoArcoProvider =
    AsyncNotifierProvider.autoDispose<AccesoArcoNotifier, SolicitudDeArco?>(
      AccesoArcoNotifier.new,
      // El reintento es de la persona (botón de EstadoError), no automático.
      retry: (_, _) => null,
      name: 'accesoArcoProvider',
    );

class AccesoArcoNotifier extends AsyncNotifier<SolicitudDeArco?> {
  Timer? _espera;

  RepositorioArco get _repo => ref.read(repositorioArcoProvider);

  @override
  Future<SolicitudDeArco?> build() async {
    ref.onDispose(() => _espera?.cancel());
    ref.listen(
      eventosProvider,
      (_, evento) => evento.whenData((e) {
        if (e.nombre == eventoArcoEstado || e.nombre == eventoReconectado) {
          unawaited(refrescar());
        }
      }),
    );
    final ultima = await _ultimaDeAcceso();
    _vigilar(ultima);
    return ultima;
  }

  /// Pide una copia de los datos y empieza a seguirla. Relanza el
  /// [FalloArco]; el estado se queda como estaba.
  Future<void> pedir() async {
    final solicitud = await _repo.pedirAcceso();
    // La pantalla pudo cerrarse mientras el servidor contestaba.
    if (!ref.mounted) return;
    state = AsyncData(solicitud);
    _vigilar(solicitud);
  }

  /// Vuelve a preguntar. Si falla, conserva lo que ya se sabía.
  Future<void> refrescar() async {
    try {
      final ultima = await _ultimaDeAcceso();
      // Una lectura en vuelo puede llegar con la pantalla ya cerrada.
      if (!ref.mounted) return;
      state = AsyncData(ultima);
      _vigilar(ultima);
    } on FalloArco {
      if (ref.mounted) _vigilar(state.value);
    }
  }

  Future<SolicitudDeArco?> _ultimaDeAcceso() async {
    final lista =
        [
          for (final s in await _repo.solicitudes())
            if (s.tipo == TipoArco.acceso) s,
        ]..sort((a, b) {
          final porFecha = b.creadaEn.compareTo(a.creadaEn);
          return porFecha != 0 ? porFecha : b.id.compareTo(a.id);
        });
    return lista.firstOrNull;
  }

  void _vigilar(SolicitudDeArco? solicitud) {
    _espera?.cancel();
    if (solicitud?.estado == EstadoArco.pendiente) {
      _espera = Timer(ref.read(intervaloArcoProvider), refrescar);
    }
  }
}

/// Nombre del aviso en vivo con el que el servidor dice que una solicitud ARCO
/// cambió de estado.
const eventoArcoEstado = 'arco.estado';
