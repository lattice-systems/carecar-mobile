import 'comun.dart';

/// Estados de un traslado de recolección (`EstadoTraslado` del contrato).
enum EstadoTraslado {
  programado('programado'),
  enCamino('en_camino'),
  recogido('recogido'),
  enTaller('en_taller'),
  deRegreso('de_regreso'),
  entregado('entregado'),
  cancelado('cancelado');

  const EstadoTraslado(this.enElContrato);

  final String enElContrato;

  /// El contrato solo manda la ubicación del chofer en estos dos estados.
  bool get muestraChofer => this == enCamino || this == deRegreso;

  /// Un estado que la app aún no conoce se trata como `programado`: es lo más
  /// prudente, no promete que el chofer ya salió.
  static EstadoTraslado desde(String? valor) {
    for (final e in values) {
      if (e.enElContrato == valor) return e;
    }
    return programado;
  }
}

/// Dónde está el chofer (`ubicacionChofer` de `GET /traslados/{id}`).
class UbicacionChofer {
  const UbicacionChofer({
    required this.lat,
    required this.lng,
    required this.actualizadaEn,
  });

  factory UbicacionChofer.fromJson(Map<String, Object?> json) =>
      UbicacionChofer(
        lat: leerDecimal(json['lat'], 'lat'),
        lng: leerDecimal(json['lng'], 'lng'),
        actualizadaEn: _leerInstante(json['actualizadaEn'], 'actualizadaEn'),
      );

  final double lat;
  final double lng;

  /// Instante en UTC; se pasa a hora local solo para mostrarlo.
  final DateTime actualizadaEn;
}

/// Un traslado con su estado y, si va en camino, la ubicación del chofer
/// (`GET /traslados/{id}`).
class TrasladoDetalle {
  const TrasladoDetalle({
    required this.id,
    required this.citaId,
    required this.tipo,
    required this.estado,
    required this.costo,
    required this.fecha,
    required this.ventanaInicio,
    required this.ventanaFin,
    this.ubicacionChofer,
  });

  factory TrasladoDetalle.fromJson(Map<String, Object?> json) {
    final ubicacion = json['ubicacionChofer'];
    return TrasladoDetalle(
      id: leerEntero(json['id'], 'id'),
      citaId: leerEntero(json['citaId'], 'citaId'),
      tipo: leerTexto(json['tipo'], 'tipo'),
      estado: EstadoTraslado.desde(json['estado'] as String?),
      costo: leerDecimal(json['costo'], 'costo'),
      fecha: leerFecha(json['fecha'], 'fecha'),
      ventanaInicio: leerTexto(json['ventanaInicio'], 'ventanaInicio'),
      ventanaFin: leerTexto(json['ventanaFin'], 'ventanaFin'),
      ubicacionChofer: ubicacion is Map
          ? UbicacionChofer.fromJson(ubicacion.cast<String, Object?>())
          : null,
    );
  }

  final int id;
  final int citaId;

  /// `recoger` o `entregar`.
  final String tipo;
  final EstadoTraslado estado;
  final double costo;
  final DateTime fecha;
  final String ventanaInicio;
  final String ventanaFin;
  final UbicacionChofer? ubicacionChofer;

  bool get esRecoger => tipo == 'recoger';

  /// El mismo traslado en otro estado. Fuera de en camino y de regreso la
  /// ubicación del chofer se descarta: ya no se comparte.
  TrasladoDetalle conEstado(EstadoTraslado nuevo) => TrasladoDetalle(
    id: id,
    citaId: citaId,
    tipo: tipo,
    estado: nuevo,
    costo: costo,
    fecha: fecha,
    ventanaInicio: ventanaInicio,
    ventanaFin: ventanaFin,
    ubicacionChofer: nuevo.muestraChofer ? ubicacionChofer : null,
  );

  TrasladoDetalle conUbicacion(UbicacionChofer nueva) => TrasladoDetalle(
    id: id,
    citaId: citaId,
    tipo: tipo,
    estado: estado,
    costo: costo,
    fecha: fecha,
    ventanaInicio: ventanaInicio,
    ventanaFin: ventanaFin,
    ubicacionChofer: nueva,
  );
}

/// Nivel de gasolina del checklist.
enum NivelGasolina {
  vacio('vacio', 0),
  unCuarto('un_cuarto', 1),
  medio('medio', 2),
  tresCuartos('tres_cuartos', 3),
  lleno('lleno', 4);

  const NivelGasolina(this.enElContrato, this.cuartos);

  final String enElContrato;

  /// Cuartos de tanque, de 0 a 4: es lo que dibuja el indicador.
  final int cuartos;

  static NivelGasolina desde(String? valor) {
    for (final n in values) {
      if (n.enElContrato == valor) return n;
    }
    throw FormatException('La gasolina «$valor» no es del contrato.');
  }
}

/// Checklist del chofer al recoger o entregar (`GET /traslados/{id}/checklist`).
///
/// Las URLs de [fotos] y [firmaUrl] vienen firmadas y duran 15 minutos: no se
/// guardan ni se reutilizan, siempre se pide el checklist de nuevo.
class ChecklistTraslado {
  const ChecklistTraslado({
    required this.trasladoId,
    required this.km,
    required this.gasolina,
    required this.registradoEn,
    this.notas,
    this.fotos = const [],
    this.firmaUrl,
  });

  factory ChecklistTraslado.fromJson(Map<String, Object?> json) {
    final fotos = json['fotos'];
    final notas = (json['notas'] as String?)?.trim();
    return ChecklistTraslado(
      trasladoId: leerEntero(json['trasladoId'], 'trasladoId'),
      km: leerEntero(json['km'], 'km'),
      gasolina: NivelGasolina.desde(json['gasolina'] as String?),
      notas: notas == null || notas.isEmpty ? null : notas,
      fotos: [
        if (fotos is List)
          for (final f in fotos) leerTexto(f, 'fotos'),
      ],
      firmaUrl: json['firmaUrl'] as String?,
      registradoEn: _leerInstante(json['registradoEn'], 'registradoEn'),
    );
  }

  final int trasladoId;
  final int km;
  final NivelGasolina gasolina;
  final String? notas;
  final List<String> fotos;
  final String? firmaUrl;
  final DateTime registradoEn;
}

DateTime _leerInstante(Object? valor, String campo) {
  final texto = leerTexto(valor, campo);
  final instante = DateTime.tryParse(texto);
  if (instante == null) {
    throw FormatException('El campo «$campo» no es una fecha y hora: $texto');
  }
  return instante;
}
