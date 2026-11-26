import 'dart:math' as math;

import '../../../api/modelos/comun.dart';
import '../dominio/campana_seguridad.dart';
import '../dominio/garantia_vehiculo.dart';

/// Lee la garantia y las campanas del contrato (`GarantiaVehiculo`,
/// `CampanaSeguridad` y `Cita`). Lanza [FormatException] si falta algo
/// obligatorio.
class LecturaGarantia {
  const LecturaGarantia();

  GarantiaVehiculo garantia(Map<String, Object?> json) => GarantiaVehiculo(
    vehiculoId: leerEntero(json['vehiculoId'], 'vehiculoId'),
    kmActual: _enteroOpcional(json['kmActual'], 'kmActual'),
    coberturas: [
      for (final cobertura in _lista(json['coberturas'], 'coberturas'))
        _cobertura(cobertura),
    ],
  );

  CampanaSeguridad campana(Map<String, Object?> json) => CampanaSeguridad(
    id: leerEntero(json['id'], 'id'),
    codigo: leerTexto(json['codigo'], 'codigo'),
    titulo: leerTexto(json['titulo'], 'titulo'),
    descripcion: leerTexto(json['descripcion'], 'descripcion'),
    queHacer: leerTexto(json['queHacer'], 'queHacer'),
    gravedad: GravedadCampana.desde(json['gravedad'] as String?),
    estado: EstadoCampana.desde(json['estado'] as String?),
    citaId: _enteroOpcional(json['citaId'], 'citaId'),
    publicadaEn: leerMomentoUtc(json['publicadaEn'], 'publicadaEn'),
  );

  CitaDeCampana cita(Map<String, Object?> json) => CitaDeCampana(
    id: leerEntero(json['id'], 'id'),
    fecha: leerFecha(json['fecha'], 'fecha'),
    horaInicio: leerTexto(json['horaInicio'], 'horaInicio'),
    horaFin: leerTexto(json['horaFin'], 'horaFin'),
  );

  static CoberturaGarantia _cobertura(Map<String, Object?> json) =>
      CoberturaGarantia(
        id: leerEntero(json['id'], 'id'),
        componente: leerTexto(json['componente'], 'componente'),
        descripcion: json['descripcion'] as String?,
        iniciaEn: leerFecha(json['iniciaEn'], 'iniciaEn'),
        venceEn: leerFecha(json['venceEn'], 'venceEn'),
        kmLimite: _enteroOpcional(json['kmLimite'], 'kmLimite'),
        diasRestantes: leerEntero(json['diasRestantes'], 'diasRestantes'),
        kmRestantes: _enteroOpcional(json['kmRestantes'], 'kmRestantes'),
        consumo: math.min(
          100,
          math.max(0, leerEntero(json['consumo'], 'consumo')),
        ),
        estado: EstadoCobertura.desde(json['estado'] as String?),
        limite: LimiteCobertura.desde(json['limite'] as String?),
      );

  static int? _enteroOpcional(Object? valor, String campo) =>
      valor == null ? null : leerEntero(valor, campo);

  static List<Map<String, Object?>> _lista(Object? valor, String campo) {
    if (valor is! List) {
      throw FormatException('El campo «$campo» no es una lista: $valor');
    }
    return [
      for (final elemento in valor)
        if (elemento is Map<String, Object?>)
          elemento
        else
          throw FormatException('Un elemento de «$campo» no es un objeto'),
    ];
  }
}
