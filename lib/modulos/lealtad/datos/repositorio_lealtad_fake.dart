import '../dominio/lealtad.dart';
import '../dominio/repositorio_lealtad.dart';

/// Lealtad en memoria para pruebas y la galeria. Canjear descuenta el saldo y
/// agrega el canje y su movimiento; referir agrega un referido registrado.
class RepositorioLealtadFake implements RepositorioLealtad {
  RepositorioLealtadFake({
    ResumenLealtad? resumen,
    List<Recompensa> recompensas = const [],
    List<Canje> canjes = const [],
    List<MovimientoPuntos> movimientos = const [],
    List<Referido> referidos = const [],
    this.falla,
    this.fallaAlCargarMas,
    this.rechazoCanje,
    this.rechazoReferido,
    DateTime Function()? reloj,
  }) : resumenActual =
           resumen ??
           const ResumenLealtad(
             saldo: 0,
             nivel: NivelLealtad.bronce,
             ganados: 0,
             siguienteNivel: NivelLealtad.plata,
             puntosParaSiguiente: 1500,
             codigoReferido: 'CC00001',
           ),
       recompensasActuales = [...recompensas],
       canjesActuales = [...canjes],
       movimientosActuales = [...movimientos],
       referidosActuales = [...referidos],
       _reloj = reloj ?? DateTime.now;

  ResumenLealtad resumenActual;
  List<Recompensa> recompensasActuales;
  List<Canje> canjesActuales;
  List<MovimientoPuntos> movimientosActuales;
  List<Referido> referidosActuales;
  Object? falla;

  /// Falla solo al pedir de la segunda pagina en adelante.
  Object? fallaAlCargarMas;
  MotivoRechazoCanje? rechazoCanje;
  MotivoRechazoReferido? rechazoReferido;
  final DateTime Function() _reloj;

  int resumenesPedidos = 0;
  final paginasPedidas = <int>[];
  final canjeadas = <int>[];
  final referidosEnviados =
      <({String nombre, String? telefono, String? correo})>[];

  Future<void> _quizaFalla() async {
    final error = falla;
    if (error != null) throw error;
  }

  @override
  Future<ResumenLealtad> resumen() async {
    resumenesPedidos++;
    await _quizaFalla();
    return resumenActual;
  }

  @override
  Future<PaginaMovimientos> movimientos({
    int pagina = 0,
    int tamano = 20,
  }) async {
    paginasPedidas.add(pagina);
    await _quizaFalla();
    final alCargarMas = fallaAlCargarMas;
    if (pagina > 0 && alCargarMas != null) throw alCargarMas;
    final inicio = pagina * tamano;
    final fin = (inicio + tamano).clamp(0, movimientosActuales.length);
    return PaginaMovimientos(
      movimientos: inicio >= movimientosActuales.length
          ? const []
          : movimientosActuales.sublist(inicio, fin),
      pagina: pagina,
      hayMas: fin < movimientosActuales.length,
    );
  }

  @override
  Future<List<Recompensa>> recompensas() async {
    await _quizaFalla();
    return recompensasActuales;
  }

  @override
  Future<Canje> canjear(int recompensaId) async {
    await _quizaFalla();
    final rechazo = rechazoCanje;
    if (rechazo != null) throw CanjeRechazado(rechazo);
    final recompensa = recompensasActuales.firstWhere(
      (r) => r.id == recompensaId,
    );
    canjeadas.add(recompensaId);
    final ahora = _reloj();
    final canje = Canje(
      id: 500 + canjeadas.length,
      codigo: 'K7XQ2MP${canjeadas.length}',
      recompensa: recompensa.nombre,
      puntos: recompensa.puntos,
      estado: EstadoCanje.vigente,
      venceEn: ahora.add(const Duration(days: 30)),
      creadoEn: ahora,
    );
    canjesActuales = [canje, ...canjesActuales];
    movimientosActuales = [
      MovimientoPuntos(
        id: 900 + canjeadas.length,
        puntos: -recompensa.puntos,
        motivo: MotivoPuntos.canje,
        referenciaTipo: 'CANJE',
        referenciaId: canje.id,
        creadoEn: ahora,
      ),
      ...movimientosActuales,
    ];
    final r = resumenActual;
    resumenActual = ResumenLealtad(
      saldo: r.saldo - recompensa.puntos,
      nivel: r.nivel,
      ganados: r.ganados,
      siguienteNivel: r.siguienteNivel,
      puntosParaSiguiente: r.puntosParaSiguiente,
      codigoReferido: r.codigoReferido,
    );
    return canje;
  }

  @override
  Future<List<Canje>> canjes() async {
    await _quizaFalla();
    return canjesActuales;
  }

  @override
  Future<Referido> referir({
    required String nombre,
    String? telefono,
    String? correo,
  }) async {
    await _quizaFalla();
    final rechazo = rechazoReferido;
    if (rechazo != null) throw ReferidoRechazado(rechazo);
    referidosEnviados.add((nombre: nombre, telefono: telefono, correo: correo));
    final referido = Referido(
      id: 700 + referidosEnviados.length,
      nombre: nombre,
      estado: EstadoReferido.registrado,
      puntos: 0,
      creadoEn: _reloj(),
    );
    referidosActuales = [referido, ...referidosActuales];
    return referido;
  }

  @override
  Future<List<Referido>> referidos() async {
    await _quizaFalla();
    return referidosActuales;
  }
}
