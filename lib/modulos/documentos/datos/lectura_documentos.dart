import '../../../api/modelos/comun.dart';
import '../dominio/documento_vehiculo.dart';

/// Lee un `Documento` del contrato. Lanza [FormatException] si falta algo
/// obligatorio; un tipo, estado u origen que la app no conoce no rompe la
/// lectura (ver los `desde` del dominio).
class LecturaDocumentos {
  const LecturaDocumentos();

  DocumentoVehiculo documento(Map<String, Object?> json) => DocumentoVehiculo(
    id: leerEntero(json['id'], 'id'),
    vehiculoId: leerEntero(json['vehiculoId'], 'vehiculoId'),
    tipo: TipoDocumento.desde(json['tipo'] as String?),
    titulo: json['titulo'] as String?,
    numero: json['numero'] as String?,
    emitidoEn: _fechaOpcional(json['emitidoEn'], 'emitidoEn'),
    venceEn: _fechaOpcional(json['venceEn'], 'venceEn'),
    estado: EstadoDocumento.desde(json['estado'] as String?),
    diasRestantes: leerEnteroOpcional(json['diasRestantes'], 'diasRestantes'),
    origen: OrigenDocumento.desde(json['origen'] as String?),
    tieneArchivo: json['tieneArchivo'] == true,
    aseguradora: json['aseguradora'] as String?,
    telefonoAseguradora: json['telefonoAseguradora'] as String?,
  );

  static DateTime? _fechaOpcional(Object? valor, String campo) =>
      valor == null ? null : leerFecha(valor, campo);
}
