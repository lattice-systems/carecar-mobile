import '../../../api/modelos/comun.dart';
import '../dominio/tienda.dart';

/// Lee la tienda del contrato (`Producto`, `Pedido` y sus páginas). Lanza
/// [FormatException] si falta algo obligatorio.
class LecturaTienda {
  const LecturaTienda();

  Producto producto(Map<String, Object?> json) => Producto(
    id: leerEntero(json['id'], 'id'),
    codigo: leerTexto(json['codigo'], 'codigo'),
    nombre: leerTexto(json['nombre'], 'nombre'),
    descripcion: json['descripcion'] as String?,
    categoria: CategoriaProducto.values.asNameMap()[json['categoria']],
    precio: leerDecimal(json['precio'], 'precio'),
    fotoUrl: json['fotoUrl'] as String?,
    existencia: leerEntero(json['existencia'], 'existencia'),
    universal: leerBool(json['universal'], 'universal'),
    compatibilidad: _lista(
      json['compatibilidad'],
      'compatibilidad',
      (e) => CompatibilidadProducto(
        modelo: leerTexto(e['modelo'], 'modelo'),
        anioDesde: leerEntero(e['anioDesde'], 'anioDesde'),
        anioHasta: leerEntero(e['anioHasta'], 'anioHasta'),
      ),
    ),
    compatible: json['compatible'] as bool?,
  );

  Pedido pedido(Map<String, Object?> json) {
    final cita = json['cita'];
    final pago = json['pago'];
    return Pedido(
      id: leerEntero(json['id'], 'id'),
      estado: _valor(EstadoPedido.values, json['estado'], 'estado'),
      entrega: _valor(EntregaPedido.values, json['entrega'], 'entrega'),
      total: leerDecimal(json['total'], 'total'),
      creadoEn: leerMomentoUtc(json['creadoEn'], 'creadoEn'),
      venceEn: _momento(json['venceEn'], 'venceEn'),
      listoEn: _momento(json['listoEn'], 'listoEn'),
      entregadoEn: _momento(json['entregadoEn'], 'entregadoEn'),
      canceladoEn: _momento(json['canceladoEn'], 'canceladoEn'),
      motivoCancelacion: MotivoCancelacion.values
          .asNameMap()[json['motivoCancelacion']],
      cita: cita is Map<String, Object?>
          ? CitaDePedido(
              id: leerEntero(cita['id'], 'cita.id'),
              fecha: leerFecha(cita['fecha'], 'cita.fecha'),
              hora: leerTexto(cita['hora'], 'cita.hora'),
              vehiculoId: leerEntero(cita['vehiculoId'], 'cita.vehiculoId'),
            )
          : null,
      pagable: json['pagable'] == true,
      pagadoEn: _momento(json['pagadoEn'], 'pagadoEn'),
      pago: pago is Map<String, Object?>
          ? PagoDePedido(
              id: leerEntero(pago['id'], 'pago.id'),
              marca: pago['marca'] as String?,
              ultimos4: pago['ultimos4'] as String?,
              pagadoEn: _momento(pago['pagadoEn'], 'pago.pagadoEn'),
            )
          : null,
      renglones: _lista(
        json['renglones'],
        'renglones',
        (e) => RenglonPedido(
          productoId: leerEntero(e['productoId'], 'productoId'),
          nombre: leerTexto(e['nombre'], 'nombre'),
          cantidad: leerEntero(e['cantidad'], 'cantidad'),
          precio: leerDecimal(e['precio'], 'precio'),
          importe: leerDecimal(e['importe'], 'importe'),
        ),
      ),
    );
  }

  static DateTime? _momento(Object? valor, String campo) =>
      valor == null ? null : leerMomentoUtc(valor, campo);

  // Un estado desconocido no se adivina: ofrecería acciones que no valen.
  static T _valor<T extends Enum>(
    List<T> valores,
    Object? texto,
    String campo,
  ) {
    final valor = valores.asNameMap()[texto];
    if (valor == null) {
      throw FormatException('El campo «$campo» no se conoce: $texto');
    }
    return valor;
  }

  static List<T> _lista<T>(
    Object? valor,
    String campo,
    T Function(Map<String, Object?>) leer,
  ) {
    if (valor is! List) {
      throw FormatException('El campo «$campo» no es una lista');
    }
    return [
      for (final elemento in valor)
        if (elemento is Map<String, Object?>)
          leer(elemento)
        else
          throw FormatException('Un elemento de «$campo» no es un objeto'),
    ];
  }
}
