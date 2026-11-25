import 'dart:math' as math;

import '../../../api/excepciones.dart';
import '../../../api/modelos/traslado.dart';
import '../../../nucleo/mapas/mapas.dart';
import '../dominio/cotizacion_recoleccion.dart';
import '../dominio/direccion_guardada.dart';
import '../dominio/fallos_recoleccion.dart';
import '../dominio/repositorio_recoleccion.dart';

/// Repositorio con datos en memoria para pruebas y desarrollo.
///
/// La zona de cobertura es la del backend: 15 km alrededor de León, Guanajuato
/// (21.1250, -101.6860); fuera de ella `guardar`, `editar` y `cotizar` lanzan
/// `FueraDeCobertura`. `idsEnUso` son direcciones con traslados: no se pueden
/// borrar. Con `error` todo falla a pedido, como lo haría la red.
class RepositorioRecoleccionFake implements RepositorioRecoleccion {
  RepositorioRecoleccionFake({
    List<DireccionGuardada> direcciones = const [],
    this.error,
    this.idsEnUso = const {},
    this.costoPorTraslado = 150,
    List<TrasladoDetalle> traslados = const [],
    Map<int, ChecklistTraslado> checklists = const {},
    this.espera,
  }) : _direcciones = [...direcciones],
       traslados = {for (final t in traslados) t.id: t},
       checklists = {...checklists},
       _siguienteId =
           direcciones.fold<int>(0, (m, d) => d.id > m ? d.id : m) + 1;

  /// Centro de la zona de cobertura del fake: el mismo del backend (León).
  static const centro = Coordenada(21.1250, -101.6860);

  /// Radio de cobertura en kilómetros, igual al del backend.
  static const radioKm = 15.0;

  /// Si no es nulo, todas las operaciones lo lanzan.
  final Object? error;

  /// Ids de dirección que ya tienen traslados.
  final Set<int> idsEnUso;
  final double costoPorTraslado;

  /// Traslados por id; las pruebas los cambian para simular avances.
  final Map<int, TrasladoDetalle> traslados;

  /// Checklists por id de traslado; sin entrada no hay checklist (404).
  final Map<int, ChecklistTraslado> checklists;

  /// Si no es nulo, `traslado` y `checklist` no contestan hasta completarlo.
  final Future<void>? espera;

  /// Cuantas veces se consultaron traslado y checklist.
  int consultasTraslado = 0;
  int consultasChecklist = 0;

  final List<DireccionGuardada> _direcciones;
  int _siguienteId;

  static bool _dentro(Coordenada c) {
    double rad(double g) => g * math.pi / 180;
    final dLat = rad(c.latitud - centro.latitud);
    final dLng = rad(c.longitud - centro.longitud);
    final a =
        math.pow(math.sin(dLat / 2), 2) +
        math.cos(rad(centro.latitud)) *
            math.cos(rad(c.latitud)) *
            math.pow(math.sin(dLng / 2), 2);
    return 6371 * 2 * math.asin(math.sqrt(a)) <= radioKm;
  }

  void _fallaSiHayError() {
    final e = error;
    if (e != null) throw e;
  }

  @override
  Future<List<DireccionGuardada>> direcciones() async {
    _fallaSiHayError();
    return List.unmodifiable(_direcciones);
  }

  @override
  Future<DireccionGuardada> guardar(BorradorDireccion borrador) async {
    _fallaSiHayError();
    if (!_dentro(borrador.ubicacion!)) throw const FueraDeCobertura();
    final d = _de(_siguienteId++, borrador);
    _direcciones.add(d);
    return d;
  }

  @override
  Future<DireccionGuardada> editar(int id, BorradorDireccion borrador) async {
    _fallaSiHayError();
    final i = _direcciones.indexWhere((d) => d.id == id);
    if (i < 0) throw StateError('La dirección $id no existe');
    if (!_dentro(borrador.ubicacion!)) throw const FueraDeCobertura();
    return _direcciones[i] = _de(id, borrador);
  }

  @override
  Future<void> borrar(int id) async {
    _fallaSiHayError();
    if (idsEnUso.contains(id)) throw const DireccionEnUso();
    _direcciones.removeWhere((d) => d.id == id);
  }

  @override
  Future<CotizacionRecoleccion> cotizar({
    required int direccionId,
    required DateTime fecha,
  }) async {
    _fallaSiHayError();
    final d = _direcciones.firstWhere((d) => d.id == direccionId);
    if (!_dentro(d.ubicacion)) throw const FueraDeCobertura();
    return CotizacionRecoleccion(
      direccionId: direccionId,
      fecha: fecha,
      costoPorTraslado: costoPorTraslado,
      costoTotal: costoPorTraslado * 2,
      recoleccion: const VentanaHoraria(inicio: '07:00', fin: '09:00'),
      entrega: const VentanaHoraria(inicio: '17:00', fin: '19:00'),
    );
  }

  @override
  Future<TrasladoDetalle> traslado(int id) async {
    consultasTraslado++;
    await espera;
    _fallaSiHayError();
    final t = traslados[id];
    if (t == null) throw const NoEncontrado('No existe el traslado');
    return t;
  }

  @override
  Future<ChecklistTraslado?> checklist(int trasladoId) async {
    consultasChecklist++;
    await espera;
    _fallaSiHayError();
    return checklists[trasladoId];
  }

  static DireccionGuardada _de(int id, BorradorDireccion b) =>
      DireccionGuardada(
        id: id,
        alias: b.alias.trim(),
        calle: b.calle.trim(),
        colonia: b.colonia.trim(),
        cp: b.cp.trim(),
        ciudad: b.ciudad.trim(),
        ubicacion: b.ubicacion!,
      );
}
