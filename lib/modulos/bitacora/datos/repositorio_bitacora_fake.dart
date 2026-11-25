import '../dominio/estadisticas.dart';
import '../dominio/fallos_bitacora.dart';
import '../dominio/gasto.dart';
import '../dominio/repositorio_bitacora.dart';

/// Bitácora en memoria para pruebas y desarrollo.
///
/// Imita al servidor: una carga con km menor a la última lectura del vehículo
/// lanza `KmInvalido`. Con `error` todo falla a pedido, como la red.
class RepositorioBitacoraFake implements RepositorioBitacora {
  RepositorioBitacoraFake({List<Gasto> gastos = const [], this.error})
    : _gastos = [...gastos],
      _siguienteId = gastos.fold<int>(0, (m, g) => g.id > m ? g.id : m) + 1;

  /// Si no es nulo, todas las operaciones lo lanzan.
  final Object? error;

  final List<Gasto> _gastos;
  int _siguienteId;

  void _fallaSiHayError() {
    final e = error;
    if (e != null) throw e;
  }

  void _validarKm(int vehiculoId, BorradorGasto b, {int? ignorando}) {
    if (b.tipo != TipoGasto.gasolina) return;
    final previos = [
      for (final g in _gastos)
        if (g.vehiculoId == vehiculoId && g.id != ignorando) g,
    ];
    final minimo = kmMasAlto(previos);
    if (minimo != null && b.km! < minimo) throw const KmInvalido();
  }

  Gasto _de(int id, int vehiculoId, BorradorGasto b) => Gasto(
    id: id,
    vehiculoId: vehiculoId,
    tipo: b.tipo,
    monto: b.monto!,
    litros: b.tipo == TipoGasto.gasolina ? b.litros : null,
    km: b.tipo == TipoGasto.gasolina ? b.km : null,
    fecha: b.fecha!,
    descripcion: (b.descripcion?.trim().isEmpty ?? true)
        ? null
        : b.descripcion!.trim(),
  );

  @override
  Future<List<Gasto>> gastos(int vehiculoId) async {
    _fallaSiHayError();
    return [
      for (final g in _gastos.reversed)
        if (g.vehiculoId == vehiculoId) g,
    ]..sort((a, b) {
      final porFecha = b.fecha.compareTo(a.fecha);
      return porFecha != 0 ? porFecha : b.id.compareTo(a.id);
    });
  }

  @override
  Future<Gasto> registrar(int vehiculoId, BorradorGasto borrador) async {
    _fallaSiHayError();
    _validarKm(vehiculoId, borrador);
    final g = _de(_siguienteId++, vehiculoId, borrador);
    _gastos.add(g);
    return g;
  }

  @override
  Future<Gasto> editar(int id, BorradorGasto borrador) async {
    _fallaSiHayError();
    final i = _gastos.indexWhere((g) => g.id == id);
    if (i < 0) throw StateError('El gasto $id no existe');
    _validarKm(_gastos[i].vehiculoId, borrador, ignorando: id);
    return _gastos[i] = _de(id, _gastos[i].vehiculoId, borrador);
  }

  @override
  Future<void> borrar(int id) async {
    _fallaSiHayError();
    _gastos.removeWhere((g) => g.id == id);
  }
}
