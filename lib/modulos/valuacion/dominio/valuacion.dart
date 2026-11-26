/// La valuacion formal del auto del cliente (V2-M26). Dart puro: no sabe de
/// Flutter ni de la red.
library;

/// En que va la valuacion. Lo calcula el servidor y la app no lo deduce.
enum EstadoValuacion {
  solicitada,
  citaAgendada,
  ofertada,
  aceptada,
  rechazada,
  vencida,

  /// Un estado que el contrato aun no declara. No ofrece ninguna accion.
  desconocido;

  /// Si la valuacion admite subir o reemplazar fotos.
  bool get admiteFotos => this == solicitada || this == citaAgendada;
}

/// Las 8 tomas guiadas, en el orden en que la app las pide (V2-M26.02).
enum TomaValuacion {
  frente,
  trasera,
  lateralIzquierdo,
  lateralDerecho,
  interiorDelantero,
  interiorTrasero,
  tableroKm,
  cajuela,
}

/// El resumen de la estimacion de la que salio la valuacion. Es una clase
/// propia: `valuacion` no importa `catalogo`.
class EstimacionDeValuacion {
  const EstimacionDeValuacion({
    required this.id,
    required this.creadaEn,
    required this.marca,
    required this.modelo,
    required this.anio,
    required this.km,
    required this.minimo,
    required this.maximo,
  });

  final int id;
  final DateTime creadaEn;
  final String marca;
  final String modelo;
  final int anio;
  final int km;
  final double minimo;
  final double maximo;

  /// "Nissan March 2020".
  String get auto => [marca, modelo, anio].join(' ');
}

/// Una foto ya subida. [url] es temporal, firmada y relativa al servidor.
class FotoValuacion {
  const FotoValuacion({
    required this.toma,
    required this.url,
    required this.subidaEn,
  });

  final TomaValuacion toma;
  final String url;
  final DateTime subidaEn;
}

/// La cita de inspeccion fisica. Las horas son `HH:mm` sin zona.
class InspeccionValuacion {
  const InspeccionValuacion({
    required this.citaId,
    required this.fecha,
    required this.horaInicio,
    required this.horaFin,
  });

  final int citaId;
  final DateTime fecha;
  final String horaInicio;
  final String horaFin;
}

/// La oferta formal de la agencia (V2-M26.04), a diferencia de la estimacion.
class OfertaValuacion {
  const OfertaValuacion({
    required this.monto,
    required this.vigenciaHasta,
    required this.ofertadaEn,
    this.nota,
  });

  /// Pesos con IVA.
  final double monto;

  /// Ultimo dia en que se puede responder, inclusive.
  final DateTime vigenciaHasta;
  final DateTime ofertadaEn;
  final String? nota;
}

/// Una valuacion formal del cliente.
class Valuacion {
  const Valuacion({
    required this.id,
    required this.estado,
    required this.creadaEn,
    required this.vehiculoId,
    required this.estimacion,
    required this.fotos,
    required this.puedeAgendar,
    this.cita,
    this.oferta,
    this.respondidaEn,
    this.asesor,
  });

  final int id;
  final EstadoValuacion estado;
  final DateTime creadaEn;
  final int vehiculoId;
  final EstimacionDeValuacion estimacion;

  /// Solo las tomas ya subidas.
  final List<FotoValuacion> fotos;

  /// Lo decide el servidor: es lo unico que ofrece «Agendar inspeccion».
  final bool puedeAgendar;
  final InspeccionValuacion? cita;
  final OfertaValuacion? oferta;
  final DateTime? respondidaEn;

  /// Nombre del vendedor del prospecto ligado, cuando ya lo hay.
  final String? asesor;

  FotoValuacion? fotoDe(TomaValuacion toma) =>
      fotos.where((f) => f.toma == toma).firstOrNull;

  /// Si hay una oferta que el cliente puede responder.
  bool get ofertaPorResponder =>
      estado == EstadoValuacion.ofertada && oferta != null;

  /// La misma valuacion sumando las fotos de [otra]: de cada toma queda la
  /// subida mas reciente. Asi dos subidas a la vez no se borran entre si,
  /// llegue primero la respuesta que llegue (las fotos no se pueden borrar).
  Valuacion conFotosDe(Valuacion otra) {
    final porToma = {for (final f in fotos) f.toma: f};
    for (final f in otra.fotos) {
      final actual = porToma[f.toma];
      if (actual == null || f.subidaEn.isAfter(actual.subidaEn)) {
        porToma[f.toma] = f;
      }
    }
    return Valuacion(
      id: id,
      estado: estado,
      creadaEn: creadaEn,
      vehiculoId: vehiculoId,
      estimacion: estimacion,
      fotos: [for (final toma in TomaValuacion.values) ?porToma[toma]],
      puedeAgendar: puedeAgendar,
      cita: cita,
      oferta: oferta,
      respondidaEn: respondidaEn,
      asesor: asesor,
    );
  }
}

/// El valor estimado de un mes con estimacion guardada (V2-M26.05). Es un
/// historial no vinculante.
class PuntoValorEstimado {
  const PuntoValorEstimado({
    required this.mes,
    required this.estimacionId,
    required this.creadaEn,
    required this.minimo,
    required this.maximo,
    required this.medio,
    required this.km,
  });

  /// El dia primero del mes.
  final DateTime mes;
  final int estimacionId;
  final DateTime creadaEn;
  final double minimo;
  final double maximo;

  /// Lo que se grafica.
  final double medio;
  final int km;
}
