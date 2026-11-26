import '../../../api/modelos/comun.dart';
import '../dominio/valuacion.dart';

/// Los textos del contrato para cada estado (`EstadoValuacion`).
const estadosEnElContrato = <EstadoValuacion, String>{
  EstadoValuacion.solicitada: 'SOLICITADA',
  EstadoValuacion.citaAgendada: 'CITA_AGENDADA',
  EstadoValuacion.ofertada: 'OFERTADA',
  EstadoValuacion.aceptada: 'ACEPTADA',
  EstadoValuacion.rechazada: 'RECHAZADA',
  EstadoValuacion.vencida: 'VENCIDA',
};

/// Los textos del contrato para cada toma (`TomaValuacion`).
const tomasEnElContrato = <TomaValuacion, String>{
  TomaValuacion.frente: 'FRENTE',
  TomaValuacion.trasera: 'TRASERA',
  TomaValuacion.lateralIzquierdo: 'LATERAL_IZQUIERDO',
  TomaValuacion.lateralDerecho: 'LATERAL_DERECHO',
  TomaValuacion.interiorDelantero: 'INTERIOR_DELANTERO',
  TomaValuacion.interiorTrasero: 'INTERIOR_TRASERO',
  TomaValuacion.tableroKm: 'TABLERO_KM',
  TomaValuacion.cajuela: 'CAJUELA',
};

/// Lee la valuacion y el historial de valor del contrato (`Valuacion`,
/// `Cita` y `ValorEstimado`). Lanza [FormatException] si falta algo
/// obligatorio.
class LecturaValuacion {
  const LecturaValuacion();

  Valuacion valuacion(Map<String, Object?> json) => Valuacion(
    id: leerEntero(json['id'], 'id'),
    estado: estado(json['estado']),
    creadaEn: leerMomentoUtc(json['creadaEn'], 'creadaEn'),
    vehiculoId: leerEntero(json['vehiculoId'], 'vehiculoId'),
    estimacion: _estimacion(_objeto(json['estimacion'], 'estimacion')),
    fotos: _fotos(json['fotos']),
    puedeAgendar: leerBool(json['puedeAgendar'], 'puedeAgendar'),
    cita: json['cita'] == null
        ? null
        : _inspeccion(_objeto(json['cita'], 'cita'), 'citaId'),
    oferta: json['oferta'] == null
        ? null
        : _oferta(_objeto(json['oferta'], 'oferta')),
    respondidaEn: json['respondidaEn'] == null
        ? null
        : leerMomentoUtc(json['respondidaEn'], 'respondidaEn'),
    asesor: json['asesor'] as String?,
  );

  /// La respuesta de agendar es una `Cita`: su `id` es el de la inspeccion.
  InspeccionValuacion cita(Map<String, Object?> json) =>
      _inspeccion(json, 'id');

  List<PuntoValorEstimado> valorEstimado(Map<String, Object?> json) => [
    for (final punto in _lista(json['puntos'], 'puntos')) _punto(punto),
  ];

  EstadoValuacion estado(Object? valor) =>
      estadosEnElContrato.entries
          .where((e) => e.value == valor)
          .firstOrNull
          ?.key ??
      EstadoValuacion.desconocido;

  EstimacionDeValuacion _estimacion(Map<String, Object?> json) =>
      EstimacionDeValuacion(
        id: leerEntero(json['id'], 'id'),
        creadaEn: leerMomentoUtc(json['creadaEn'], 'creadaEn'),
        marca: leerTexto(json['marca'], 'marca'),
        modelo: leerTexto(json['modelo'], 'modelo'),
        anio: leerEntero(json['anio'], 'anio'),
        km: leerEntero(json['km'], 'km'),
        minimo: leerDecimal(json['minimo'], 'minimo'),
        maximo: leerDecimal(json['maximo'], 'maximo'),
      );

  // Una toma que la app no conoce se ignora: no tiene donde mostrarse.
  List<FotoValuacion> _fotos(Object? valor) {
    final fotos = <FotoValuacion>[];
    for (final json in _lista(valor, 'fotos')) {
      final toma = tomasEnElContrato.entries
          .where((e) => e.value == json['toma'])
          .firstOrNull
          ?.key;
      if (toma == null) continue;
      fotos.add(
        FotoValuacion(
          toma: toma,
          url: leerTexto(json['url'], 'url'),
          subidaEn: leerMomentoUtc(json['subidaEn'], 'subidaEn'),
        ),
      );
    }
    return fotos..sort((a, b) => a.toma.index.compareTo(b.toma.index));
  }

  InspeccionValuacion _inspeccion(Map<String, Object?> json, String campoId) =>
      InspeccionValuacion(
        citaId: leerEntero(json[campoId], campoId),
        fecha: leerFecha(json['fecha'], 'fecha'),
        horaInicio: leerTexto(json['horaInicio'], 'horaInicio'),
        horaFin: leerTexto(json['horaFin'], 'horaFin'),
      );

  OfertaValuacion _oferta(Map<String, Object?> json) => OfertaValuacion(
    monto: leerDecimal(json['monto'], 'monto'),
    vigenciaHasta: leerFecha(json['vigenciaHasta'], 'vigenciaHasta'),
    ofertadaEn: leerMomentoUtc(json['ofertadaEn'], 'ofertadaEn'),
    nota: json['nota'] as String?,
  );

  PuntoValorEstimado _punto(Map<String, Object?> json) {
    final mes = leerTexto(json['mes'], 'mes');
    return PuntoValorEstimado(
      mes: leerFecha('$mes-01', 'mes'),
      estimacionId: leerEntero(
        json['estimacionTomaCuentaId'],
        'estimacionTomaCuentaId',
      ),
      creadaEn: leerMomentoUtc(json['creadaEn'], 'creadaEn'),
      minimo: leerDecimal(json['minimo'], 'minimo'),
      maximo: leerDecimal(json['maximo'], 'maximo'),
      medio: leerDecimal(json['medio'], 'medio'),
      km: leerEntero(json['km'], 'km'),
    );
  }

  static Map<String, Object?> _objeto(Object? valor, String campo) {
    if (valor is Map<String, Object?>) return valor;
    throw FormatException('El campo «$campo» no es un objeto');
  }

  static List<Map<String, Object?>> _lista(Object? valor, String campo) {
    if (valor is! List) {
      throw FormatException('El campo «$campo» no es una lista: $valor');
    }
    return [for (final elemento in valor) _objeto(elemento, campo)];
  }
}
