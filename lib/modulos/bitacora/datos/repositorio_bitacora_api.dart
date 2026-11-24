import '../../../api/excepciones.dart';
import '../../../api/modelos/comun.dart';
import '../../../nucleo/api/api_cliente.dart';
import '../dominio/fallos_bitacora.dart';
import '../dominio/gasto.dart';
import '../dominio/repositorio_bitacora.dart';

/// Bitácora con el cliente HTTP del núcleo (`/vehiculos/{id}/gastos`,
/// `/gastos/{id}`).
///
/// Los errores de la API pasan tal cual. Solo se traduce el 422: el cliente
/// HTTP convierte todo 422 en `SinParametrosDeValuacion`, y en estos caminos
/// solo puede significar `KM_INVALIDO`.
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
    } on SinParametrosDeValuacion {
      throw const KmInvalido();
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
    } on SinParametrosDeValuacion {
      throw const KmInvalido();
    }
  }

  @override
  Future<void> borrar(int id) => _cliente.eliminar('/gastos/$id');

  /// `NuevoGasto`: litros y km solo viajan en las cargas de gasolina.
  static Map<String, Object?> _cuerpo(BorradorGasto b) {
    final descripcion = b.descripcion?.trim() ?? '';
    final esCarga = b.tipo == TipoGasto.gasolina;
    return {
      'tipo': b.tipo.enContrato,
      'monto': b.monto,
      if (esCarga) 'litros': b.litros,
      if (esCarga) 'km': b.km,
      'fecha': escribirFecha(b.fecha!),
      if (descripcion.isNotEmpty) 'descripcion': descripcion,
    };
  }

  static Gasto _leer(Map<String, Object?> json) => Gasto(
    id: leerEntero(json['id'], 'id'),
    vehiculoId: leerEntero(json['vehiculoId'], 'vehiculoId'),
    tipo: TipoGasto.desde(leerTexto(json['tipo'], 'tipo')),
    monto: leerDecimal(json['monto'], 'monto'),
    litros: json['litros'] == null
        ? null
        : leerDecimal(json['litros'], 'litros'),
    km: json['km'] == null ? null : leerEntero(json['km'], 'km'),
    fecha: leerFecha(json['fecha'], 'fecha'),
    descripcion: json['descripcion'] == null
        ? null
        : leerTexto(json['descripcion'], 'descripcion'),
  );
}
