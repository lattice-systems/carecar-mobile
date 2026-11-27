import 'comun.dart';

/// Una sucursal de la agencia (`Sucursal` del contrato 2.28.0, V2-M27.02).
///
/// `abiertaAhora` y el `abiertoAhora` de cada horario los calcula el servidor
/// con la hora de la agencia, no el teléfono.
class SucursalApi {
  const SucursalApi({
    required this.id,
    required this.nombre,
    required this.direccion,
    required this.latitud,
    required this.longitud,
    required this.abiertaAhora,
    this.telefono,
    this.correo,
    this.horarios = const [],
  });

  factory SucursalApi.fromJson(Map<String, Object?> json) => SucursalApi(
    id: leerEntero(json['id'], 'id'),
    nombre: leerTexto(json['nombre'], 'nombre'),
    direccion: leerTexto(json['direccion'], 'direccion'),
    latitud: leerDecimal(json['latitud'], 'latitud'),
    longitud: leerDecimal(json['longitud'], 'longitud'),
    telefono: _texto(json['telefono']),
    correo: _texto(json['correo']),
    abiertaAhora: leerBool(json['abiertaAhora'], 'abiertaAhora'),
    horarios: _horarios(json['horarios']),
  );

  final int id;
  final String nombre;
  final String direccion;
  final double latitud;
  final double longitud;
  final String? telefono;
  final String? correo;
  final bool abiertaAhora;
  final List<HorarioSucursalApi> horarios;
}

/// Un tramo de horario de un departamento (`HorarioSucursal` del contrato).
class HorarioSucursalApi {
  const HorarioSucursalApi({
    required this.departamento,
    required this.dias,
    required this.abre,
    required this.cierra,
    required this.abiertoAhora,
  });

  factory HorarioSucursalApi.fromJson(Map<String, Object?> json) {
    final dias = json['dias'];
    if (dias is! List) {
      throw FormatException('El campo «dias» no es una lista: $dias');
    }
    return HorarioSucursalApi(
      departamento: leerTexto(json['departamento'], 'departamento'),
      dias: List.unmodifiable([for (final d in dias) leerEntero(d, 'dias')]),
      abre: leerTexto(json['abre'], 'abre'),
      cierra: leerTexto(json['cierra'], 'cierra'),
      abiertoAhora: leerBool(json['abiertoAhora'], 'abiertoAhora'),
    );
  }

  /// `VENTAS`, `SERVICIO` o `REFACCIONES`; un valor nuevo no rompe la lectura.
  final String departamento;

  /// Días ISO: 1 lunes a 7 domingo.
  final List<int> dias;

  /// `HH:mm` en la hora de la agencia.
  final String abre;
  final String cierra;
  final bool abiertoAhora;
}

List<HorarioSucursalApi> _horarios(Object? json) {
  if (json is! List) return const [];
  return List.unmodifiable([
    for (final h in json)
      if (h is Map) HorarioSucursalApi.fromJson(h.cast<String, Object?>()),
  ]);
}

String? _texto(Object? v) {
  if (v is! String) return null;
  final t = v.trim();
  return t.isEmpty ? null : t;
}
