/// Live Activity del taller en la pantalla bloqueada del iPhone (V2-M25.05).
///
/// Dart puro. La app inicia la actividad de cada orden abierta, la actualiza
/// con lo que llega por el canal en vivo y manda su push token al backend, que
/// la sigue actualizando por APNs aunque la app este cerrada y la termina al
/// entregar el auto. Las dos fuentes pintan lo mismo porque comparten las
/// llaves de [EstadoDeActividad] (el `content-state` de ActivityKit).
///
/// A la pantalla bloqueada solo viajan la etapa, el estatus, el avance, los
/// trabajos por aprobar (cuantos) y la hora estimada. Nunca placas, VIN, auto,
/// asesor, montos ni datos del cliente: la ve cualquiera con el telefono en la
/// mano.
library;

import '../../taller/taller.dart';

/// Desfase de la agencia (America/Mexico_City). Mexico no tiene horario de
/// verano desde 2022, asi que es fijo; el backend usa la misma zona.
const _desfaseDeLaAgencia = Duration(hours: -6);

/// Lo que pinta la Live Activity. Sus llaves y tipos son los del
/// `content-state` que manda el backend (`ActualizadorDeActividadesEnVivo`) y
/// los que decodifica el `ContentState` de Swift
/// (`ios/CareCarWidgets/ActividadTallerAtributos.swift`).
class EstadoDeActividad {
  const EstadoDeActividad({
    required this.etapa,
    required this.estatus,
    required this.avance,
    required this.adicionalesPendientes,
    this.entregaEstimada,
  });

  /// La orden en curso tal como la da `GET /ordenes/activas`.
  factory EstadoDeActividad.deOrden(OrdenEnCurso orden) => EstadoDeActividad(
    etapa: orden.etapa.enElContrato,
    estatus: _estatusDe(orden.etapa),
    avance: orden.avance,
    adicionalesPendientes: orden.adicionalesPendientes,
    entregaEstimada: switch (orden.entregaEstimada) {
      final hora? => segundosDesde1970(hora),
      null => null,
    },
  );

  /// Nombre del enum `EtapaTaller` del backend (`EN_REPARACION`).
  final String etapa;

  /// Nombre del enum `EstatusOrden` del backend (`EN_PROCESO`).
  final String estatus;

  /// De 0 a 100.
  final int avance;

  /// Trabajos adicionales que esperan la respuesta del cliente.
  final int adicionalesPendientes;

  /// Segundos desde 1970 (UTC); nulo si el taller aun no la estima. Va como
  /// numero y no como fecha porque ActivityKit decodifica con el
  /// `JSONDecoder` por omision.
  final int? entregaEstimada;

  /// El estado con que termina al entregar el auto: lo mismo que manda el
  /// backend con `event: end`.
  EstadoDeActividad entregada() => EstadoDeActividad(
    etapa: EtapaTaller.entregado.enElContrato,
    estatus: 'ENTREGADO',
    avance: 100,
    adicionalesPendientes: 0,
    entregaEstimada: entregaEstimada,
  );

  /// El `content-state` para el canal de plataforma. Sin hora estimada se
  /// omite la llave, igual que en el backend.
  Map<String, Object> comoContentState() => {
    'etapa': etapa,
    'estatus': estatus,
    'avance': avance,
    'adicionalesPendientes': adicionalesPendientes,
    'entregaEstimada': ?entregaEstimada,
  };

  @override
  bool operator ==(Object other) =>
      other is EstadoDeActividad &&
      other.etapa == etapa &&
      other.estatus == estatus &&
      other.avance == avance &&
      other.adicionalesPendientes == adicionalesPendientes &&
      other.entregaEstimada == entregaEstimada;

  @override
  int get hashCode => Object.hash(
    etapa,
    estatus,
    avance,
    adicionalesPendientes,
    entregaEstimada,
  );

  /// Cada etapa fija el estatus de la orden, como `EtapaTaller.estatus()` del
  /// backend.
  static String _estatusDe(EtapaTaller etapa) => switch (etapa) {
    EtapaTaller.recibido => 'RECIBIDO',
    EtapaTaller.listoParaEntrega => 'TERMINADO',
    EtapaTaller.entregado => 'ENTREGADO',
    _ => 'EN_PROCESO',
  };
}

/// Una hora de la agencia como la manda el contrato (sin zona) en segundos
/// desde 1970, el mismo instante que el backend pone en el `content-state`.
int segundosDesde1970(DateTime horaDeLaAgencia) {
  final comoUtc = DateTime.utc(
    horaDeLaAgencia.year,
    horaDeLaAgencia.month,
    horaDeLaAgencia.day,
    horaDeLaAgencia.hour,
    horaDeLaAgencia.minute,
    horaDeLaAgencia.second,
  );
  return comoUtc.subtract(_desfaseDeLaAgencia).millisecondsSinceEpoch ~/ 1000;
}

final _hexadecimal = RegExp(r'^[0-9a-fA-F]+$');

/// Si [token] cumple `ActividadEnVivoToken` del contrato: hexadecimal y de
/// 300 caracteres o menos. Uno que no cumple no se manda (seria un 400).
bool esPushTokenValido(String token) =>
    token.length <= 300 && _hexadecimal.hasMatch(token);

/// El puente con ActivityKit. Solo hay uno real en iPhone
/// (`ServicioActividadEnVivoCanal`); en Android, en pruebas y donde no hay
/// soporte se usa el nulo, que no hace nada. Ningun metodo lanza: un fallo de
/// la plataforma se trata como «no disponible».
abstract interface class ServicioActividadEnVivo {
  /// Si el telefono puede mostrar Live Activities ahora (iPhone con iOS 16.1
  /// o superior, el puente enlazado y la persona no las apago en Ajustes).
  Future<bool> disponible();

  /// Inicia la actividad de [ordenId] con [estado]; si ya habia una de esa
  /// orden (de antes de cerrar la app) la reutiliza y la actualiza. Devuelve
  /// si quedo una actividad viva.
  Future<bool> iniciar(int ordenId, EstadoDeActividad estado);

  /// Los push tokens de la actividad de [ordenId], en hexadecimal. ActivityKit
  /// puede rotarlo: cada uno nuevo llega aqui.
  Stream<String> tokensDe(int ordenId);

  /// Repinta la actividad de [ordenId] con [estado].
  Future<void> actualizar(int ordenId, EstadoDeActividad estado);

  /// Termina la actividad de [ordenId]. Con [estadoFinal] se queda un rato en
  /// la pantalla bloqueada con ese estado (como el `dismissal-date` del
  /// backend); sin el, se quita de inmediato.
  Future<void> terminar(int ordenId, {EstadoDeActividad? estadoFinal});

  /// Termina todas las actividades de la app de inmediato (cerrar sesion).
  Future<void> terminarTodas();

  /// Las ordenes con actividad viva en el telefono, aunque las haya iniciado
  /// una ejecucion anterior de la app.
  Future<List<int>> activas();
}

/// La orden ya se entrego: el backend no acepta su actividad (409
/// `ORDEN_CERRADA`). No se reintenta.
class OrdenYaEntregada implements Exception {
  const OrdenYaEntregada();
}

/// Registro del push token de la Live Activity en el backend.
abstract interface class RepositorioActividadEnVivo {
  /// `PUT /ordenes/{ordenId}/actividad-en-vivo`. Lanza [OrdenYaEntregada] si
  /// la orden ya se entrego; cualquier otro fallo sube tal cual.
  Future<void> registrar({required int ordenId, required String pushToken});

  /// `DELETE /ordenes/{ordenId}/actividad-en-vivo`: con [pushToken] solo esa
  /// actividad; sin el, todas las del cliente en la orden. Es idempotente.
  Future<void> darDeBaja({required int ordenId, String? pushToken});
}
