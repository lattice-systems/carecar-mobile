import 'comun.dart';

/// Un gasto de un vehículo (`Gasto` del contrato de la bitácora, V2-M18).
///
/// `tipo` viaja como texto (`gasolina`, `estacionamiento`, `casetas`,
/// `lavado`, `otro`): quien lo usa lo convierte a su enumeración.
class GastoVehiculo {
  const GastoVehiculo({
    required this.id,
    required this.vehiculoId,
    required this.tipo,
    required this.monto,
    required this.fecha,
    this.litros,
    this.km,
    this.descripcion,
  });

  factory GastoVehiculo.fromJson(Map<String, Object?> json) => GastoVehiculo(
    id: leerEntero(json['id'], 'id'),
    vehiculoId: leerEntero(json['vehiculoId'], 'vehiculoId'),
    tipo: leerTexto(json['tipo'], 'tipo'),
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

  final int id;
  final int vehiculoId;
  final String tipo;
  final double monto;
  final double? litros;
  final int? km;
  final DateTime fecha;
  final String? descripcion;
}

/// Cuerpo de `POST /vehiculos/{id}/gastos` y `PUT /gastos/{id}`
/// (`NuevoGasto`). Los campos nulos no se escriben.
class NuevoGasto {
  const NuevoGasto({
    required this.tipo,
    required this.monto,
    required this.fecha,
    this.litros,
    this.km,
    this.descripcion,
  });

  final String tipo;
  final double monto;
  final DateTime fecha;
  final double? litros;
  final int? km;
  final String? descripcion;

  Map<String, Object?> toJson() => {
    'tipo': tipo,
    'monto': monto,
    'litros': ?litros,
    'km': ?km,
    'fecha': escribirFecha(fecha),
    'descripcion': ?descripcion,
  };
}
