import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../nucleo/api/proveedores_api.dart';
import '../datos/repositorio_datos_fiscales_api.dart';
import '../dominio/datos_fiscales.dart';
import '../dominio/repositorio_datos_fiscales.dart';

/// Repositorio de datos fiscales. En pruebas:
/// `repositorioDatosFiscalesProvider.overrideWithValue(
/// RepositorioDatosFiscalesFake(catalogo: ...))`.
final repositorioDatosFiscalesProvider = Provider<RepositorioDatosFiscales>(
  (ref) => RepositorioDatosFiscalesApi(ref.watch(apiClienteProvider)),
  retry: (_, _) => null,
  name: 'repositorioDatosFiscalesProvider',
);

/// Catalogos del SAT para el formulario (V2-M08.05).
final catalogoFiscalProvider = FutureProvider.autoDispose<CatalogoFiscal>(
  (ref) => ref.watch(repositorioDatosFiscalesProvider).catalogo(),
  retry: (_, _) => null,
  name: 'catalogoFiscalProvider',
);

/// Mis datos fiscales, el predeterminado primero. Alta, edicion y borrado
/// vuelven a pedir la lista para quedar igual que el servidor (el
/// predeterminado puede cambiar en otros perfiles).
class PerfilesFiscalesNotifier extends AsyncNotifier<List<PerfilFiscal>> {
  @override
  Future<List<PerfilFiscal>> build() =>
      ref.watch(repositorioDatosFiscalesProvider).perfiles();

  /// Lanza [DatosFiscalesRechazados] si el servidor no acepta un dato.
  Future<PerfilFiscal> crear(BorradorPerfilFiscal borrador) async {
    final creado = await ref
        .read(repositorioDatosFiscalesProvider)
        .crear(borrador);
    await _recargar();
    return creado;
  }

  /// Lanza [DatosFiscalesRechazados] si el servidor no acepta un dato.
  Future<PerfilFiscal> editar(int id, BorradorPerfilFiscal borrador) async {
    final editado = await ref
        .read(repositorioDatosFiscalesProvider)
        .editar(id, borrador);
    await _recargar();
    return editado;
  }

  Future<void> borrar(int id) async {
    await ref.read(repositorioDatosFiscalesProvider).borrar(id);
    await _recargar();
  }

  /// Sin pasar por carga; si falla, se queda lo que se veia.
  Future<void> _recargar() async {
    if (!ref.mounted) return;
    try {
      final perfiles = await ref
          .read(repositorioDatosFiscalesProvider)
          .perfiles();
      if (ref.mounted) state = AsyncData(perfiles);
    } on Object {
      // El cambio ya quedo en el servidor; la lista se corrige al refrescar.
    }
  }
}

final perfilesFiscalesProvider =
    AsyncNotifierProvider.autoDispose<
      PerfilesFiscalesNotifier,
      List<PerfilFiscal>
    >(
      PerfilesFiscalesNotifier.new,
      retry: (_, _) => null,
      name: 'perfilesFiscalesProvider',
    );
