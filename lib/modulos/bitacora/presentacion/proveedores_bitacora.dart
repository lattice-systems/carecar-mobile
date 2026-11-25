import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../nucleo/api/proveedores_api.dart';
import '../datos/compartir_bitacora.dart';
import '../datos/lector_ticket_mlkit.dart';
import '../datos/repositorio_bitacora_api.dart';
import '../dominio/gasto.dart';
import '../dominio/lector_ticket.dart';
import '../dominio/repositorio_bitacora.dart';

/// Repositorio del módulo. En pruebas:
/// `repositorioBitacoraProvider.overrideWithValue(RepositorioBitacoraFake())`.
final repositorioBitacoraProvider = Provider<RepositorioBitacora>(
  (ref) => RepositorioBitacoraApi(ref.watch(apiClienteProvider)),
  name: 'repositorioBitacoraProvider',
);

/// Los gastos de un vehículo, del más reciente al más viejo. Registrar, editar
/// y borrar actualizan la lista sin volver a pedirla.
class GastosNotifier extends AsyncNotifier<List<Gasto>> {
  GastosNotifier(this.vehiculoId);

  final int vehiculoId;

  @override
  Future<List<Gasto>> build() =>
      ref.watch(repositorioBitacoraProvider).gastos(vehiculoId);

  RepositorioBitacora get _repo => ref.read(repositorioBitacoraProvider);

  static List<Gasto> _ordenar(Iterable<Gasto> gastos) =>
      gastos.toList()..sort((a, b) {
        final porFecha = b.fecha.compareTo(a.fecha);
        return porFecha != 0 ? porFecha : b.id.compareTo(a.id);
      });

  /// Guarda y suma a la lista. Relanza `KmInvalido` y los errores de red.
  Future<Gasto> registrar(BorradorGasto borrador) async {
    final creado = await _repo.registrar(vehiculoId, borrador);
    state = AsyncData(_ordenar([...?state.value, creado]));
    return creado;
  }

  /// Edita y sustituye en la lista.
  Future<Gasto> editar(int id, BorradorGasto borrador) async {
    final editado = await _repo.editar(id, borrador);
    state = AsyncData(
      _ordenar([
        for (final g in state.value ?? const <Gasto>[])
          g.id == id ? editado : g,
      ]),
    );
    return editado;
  }

  /// Borra y quita de la lista.
  Future<void> borrar(int id) async {
    await _repo.borrar(id);
    state = AsyncData([
      for (final g in state.value ?? const <Gasto>[])
        if (g.id != id) g,
    ]);
  }
}

final gastosProvider =
    AsyncNotifierProvider.family<GastosNotifier, List<Gasto>, int>(
      GastosNotifier.new,
      // El reintento es del usuario (botón de EstadoError), no automático.
      retry: (_, _) => null,
      name: 'gastosProvider',
    );

/// Lector del ticket (cámara + ML Kit). En pruebas:
/// `lectorTicketProvider.overrideWithValue(LectorTicketFake(...))`.
final lectorTicketProvider = Provider<LectorTicket>(
  (ref) => LectorTicketMlKit(),
  name: 'lectorTicketProvider',
);

/// Cómo se comparte un archivo exportado: bytes, nombre con extensión y tipo
/// MIME. En pruebas se sustituye para no abrir la hoja del sistema.
typedef CompartirArchivo = Future<void> Function(
  Uint8List bytes,
  String nombre,
  String tipoMime,
);

final compartirBitacoraProvider = Provider<CompartirArchivo>(
  (ref) => compartirBitacoraConHojaDelSistema,
  name: 'compartirBitacoraProvider',
);

/// El reloj de la bitácora: «hoy» para validar fechas y el gasto del mes.
final relojBitacoraProvider = Provider<DateTime Function()>(
  (ref) => DateTime.now,
  name: 'relojBitacoraProvider',
);
