import '../../../api/excepciones.dart';
import '../dominio/repositorio_valuacion.dart';
import '../dominio/valuacion.dart';

/// Repositorio en memoria para pruebas, con fallo a pedido. Sigue las reglas
/// que las pantallas ven: una abierta por vehiculo, fotos solo mientras se
/// admiten y la respuesta con el monto vigente. Los datos de ejemplo viven en
/// las pruebas.
class RepositorioValuacionFake implements RepositorioValuacion {
  RepositorioValuacionFake({
    List<Valuacion> valuaciones = const [],
    this.puntos = const [],
    this.falla,
    this.rechazo,
  }) : valuaciones = [...valuaciones];

  /// De la mas reciente a la mas antigua.
  List<Valuacion> valuaciones;
  List<PuntoValorEstimado> puntos;

  /// Si no es nulo, todo lo lanza.
  Object? falla;

  /// Si no es nulo, las acciones lo lanzan como [ValuacionRechazada].
  MotivoRechazoValuacion? rechazo;

  /// Cuantas veces se pidio una lista, un detalle o el historial.
  var lecturas = 0;

  /// Los ids de estimacion con que se pidio una valuacion.
  final pedidas = <int>[];

  /// Las tomas subidas, en orden.
  final subidas = <TomaValuacion>[];

  /// Lo que se agendo: (valuacionId, franjaId, fecha).
  final agendadas = <(int, int, DateTime)>[];

  /// Lo que se respondio: (valuacionId, aceptada, monto).
  final respuestas = <(int, bool, double)>[];

  void _fallarSiToca() {
    if (falla != null) throw falla!;
  }

  void _rechazarSiToca() {
    _fallarSiToca();
    if (rechazo != null) throw ValuacionRechazada(rechazo!);
  }

  Valuacion _buscar(int id) =>
      valuaciones.where((v) => v.id == id).firstOrNull ??
      (throw const NoEncontrado('No existe la valuacion'));

  void _guardar(Valuacion nueva) {
    valuaciones = [for (final v in valuaciones) v.id == nueva.id ? nueva : v];
  }

  @override
  Future<Valuacion> pedir(int estimacionId) async {
    _rechazarSiToca();
    pedidas.add(estimacionId);
    final abierta = valuaciones
        .where((v) => v.estimacion.id == estimacionId)
        .firstOrNull;
    if (abierta != null) return abierta;
    final nueva = Valuacion(
      id: 100 + pedidas.length,
      estado: EstadoValuacion.solicitada,
      creadaEn: DateTime.utc(2026, 11, 25),
      vehiculoId: 5,
      estimacion: EstimacionDeValuacion(
        id: estimacionId,
        creadaEn: DateTime.utc(2026, 11, 24),
        marca: 'Nissan',
        modelo: 'March',
        anio: 2020,
        km: 48000,
        minimo: 100000,
        maximo: 120000,
      ),
      fotos: const [],
      puedeAgendar: true,
    );
    valuaciones = [nueva, ...valuaciones];
    return nueva;
  }

  @override
  Future<PaginaDeValuaciones> listar({int pagina = 0, int tamano = 20}) async {
    lecturas++;
    _fallarSiToca();
    return PaginaDeValuaciones(
      valuaciones: valuaciones.skip(pagina * tamano).take(tamano).toList(),
      pagina: pagina,
      hayMas: (pagina + 1) * tamano < valuaciones.length,
    );
  }

  @override
  Future<Valuacion> una(int valuacionId) async {
    lecturas++;
    _fallarSiToca();
    return _buscar(valuacionId);
  }

  @override
  Future<Valuacion> subirFoto({
    required int valuacionId,
    required TomaValuacion toma,
    required List<int> bytes,
    required String tipo,
  }) async {
    _rechazarSiToca();
    final actual = _buscar(valuacionId);
    if (!actual.estado.admiteFotos) {
      throw const ValuacionRechazada(MotivoRechazoValuacion.cerrada);
    }
    subidas.add(toma);
    final foto = FotoValuacion(
      toma: toma,
      url: '/api/v1/archivos/valuacion-fotos/${subidas.length}',
      subidaEn: DateTime.utc(2026, 11, 25, 12, 0, subidas.length),
    );
    final nueva = _con(
      actual,
      fotos: [...actual.fotos.where((f) => f.toma != toma), foto]
        ..sort((a, b) => a.toma.index.compareTo(b.toma.index)),
    );
    _guardar(nueva);
    return nueva;
  }

  @override
  Future<InspeccionValuacion> agendar({
    required int valuacionId,
    required int franjaId,
    required DateTime fecha,
  }) async {
    _rechazarSiToca();
    final actual = _buscar(valuacionId);
    if (!actual.puedeAgendar) {
      throw const ValuacionRechazada(MotivoRechazoValuacion.noAgendable);
    }
    agendadas.add((valuacionId, franjaId, fecha));
    final cita = InspeccionValuacion(
      citaId: 900 + agendadas.length,
      fecha: fecha,
      horaInicio: '09:00',
      horaFin: '10:00',
    );
    _guardar(
      _con(
        actual,
        estado: EstadoValuacion.citaAgendada,
        puedeAgendar: false,
        cita: cita,
      ),
    );
    return cita;
  }

  @override
  Future<Valuacion> responder({
    required int valuacionId,
    required bool aceptada,
    required double monto,
  }) async {
    _rechazarSiToca();
    final actual = _buscar(valuacionId);
    if (!actual.ofertaPorResponder || actual.oferta!.monto != monto) {
      throw const ValuacionRechazada(MotivoRechazoValuacion.ofertaNoDisponible);
    }
    respuestas.add((valuacionId, aceptada, monto));
    final nueva = _con(
      actual,
      estado: aceptada ? EstadoValuacion.aceptada : EstadoValuacion.rechazada,
      respondidaEn: DateTime.utc(2026, 11, 25),
    );
    _guardar(nueva);
    return nueva;
  }

  @override
  Future<List<PuntoValorEstimado>> valorEstimado(
    int vehiculoId, {
    int meses = 12,
  }) async {
    lecturas++;
    _fallarSiToca();
    return List.unmodifiable(puntos);
  }

  static Valuacion _con(
    Valuacion v, {
    EstadoValuacion? estado,
    List<FotoValuacion>? fotos,
    bool? puedeAgendar,
    InspeccionValuacion? cita,
    DateTime? respondidaEn,
  }) => Valuacion(
    id: v.id,
    estado: estado ?? v.estado,
    creadaEn: v.creadaEn,
    vehiculoId: v.vehiculoId,
    estimacion: v.estimacion,
    fotos: fotos ?? v.fotos,
    puedeAgendar: puedeAgendar ?? v.puedeAgendar,
    cita: cita ?? v.cita,
    oferta: v.oferta,
    respondidaEn: respondidaEn ?? v.respondidaEn,
    asesor: v.asesor,
  );
}
