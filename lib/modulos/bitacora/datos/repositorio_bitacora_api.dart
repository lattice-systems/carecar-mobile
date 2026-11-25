import '../../../api/excepciones.dart';
import '../../../api/modelos/gasto.dart';
import '../../../api/modelos/problema.dart';
import '../../../nucleo/api/api_cliente.dart';
import '../dominio/fallos_bitacora.dart';
import '../dominio/gasto.dart';
import '../dominio/repositorio_bitacora.dart';

/// Bitácora con el cliente HTTP del núcleo (`/vehiculos/{id}/gastos`,
/// `/gastos/{id}`).
///
/// Los errores de la API pasan tal cual. Solo se traduce el 422 con código
/// `KM_INVALIDO`; uno con otro código pasa como `SolicitudRechazada`.
class RepositorioBitacoraApi implements RepositorioBitacora {
  const RepositorioBitacoraApi(this._cliente);

  final ApiCliente _cliente;

  static const int _tamanoPagina = 100;

  @override
  Future<List<Gasto>> gastos(int vehiculoId) async {
    final todos = <Gasto>[];
    var pagina = 0;
    while (true) {
      final actual = await _cliente.obtenerPagina(
        '/vehiculos/$vehiculoId/gastos',
        _leer,
        pagina: pagina,
        tamano: _tamanoPagina,
      );
      todos.addAll(actual.contenido);
      if (!actual.hayMas) return todos;
      pagina++;
    }
  }

  @override
  Future<Gasto> registrar(int vehiculoId, BorradorGasto borrador) async {
    try {
      return await _cliente.enviar(
        '/vehiculos/$vehiculoId/gastos',
        cuerpo: _cuerpo(borrador),
        leer: _leer,
      );
    } on SolicitudRechazada catch (e) {
      if (e.codigo == CodigoProblema.kmInvalido) throw const KmInvalido();
      rethrow;
    }
  }

  @override
  Future<Gasto> editar(int id, BorradorGasto borrador) async {
    try {
      return await _cliente.actualizar(
        '/gastos/$id',
        cuerpo: _cuerpo(borrador),
        leer: _leer,
      );
    } on SolicitudRechazada catch (e) {
      if (e.codigo == CodigoProblema.kmInvalido) throw const KmInvalido();
      rethrow;
    }
  }

  @override
  Future<void> borrar(int id) => _cliente.eliminar('/gastos/$id');

  /// `NuevoGasto`: litros y km solo viajan en las cargas de gasolina.
  static Map<String, Object?> _cuerpo(BorradorGasto b) {
    final descripcion = b.descripcion?.trim() ?? '';
    final esCarga = b.tipo == TipoGasto.gasolina;
    return NuevoGasto(
      tipo: b.tipo.enContrato,
      monto: b.monto!,
      litros: esCarga ? b.litros : null,
      km: esCarga ? b.km : null,
      fecha: b.fecha!,
      descripcion: descripcion.isEmpty ? null : descripcion,
    ).toJson();
  }

  static Gasto _leer(Map<String, Object?> json) {
    final g = GastoVehiculo.fromJson(json);
    return Gasto(
      id: g.id,
      vehiculoId: g.vehiculoId,
      tipo: TipoGasto.desde(g.tipo),
      monto: g.monto,
      litros: g.litros,
      km: g.km,
      fecha: g.fecha,
      descripcion: g.descripcion,
    );
  }
}
