import 'dart:typed_data';

import '../dominio/etapa_taller.dart';
import '../dominio/orden_taller.dart';
import '../dominio/repositorio_taller.dart';

/// Repositorio en memoria para pruebas y para la galeria. Responde como la
/// API: aprobar suma el trabajo al total estimado y responder dos veces lanza
/// [AdicionalYaRespondido]. [actualizar] cambia una orden como lo haria el
/// taller; el aviso en vivo lo manda la prueba por el canal de eventos.
class RepositorioTallerFake implements RepositorioTaller {
  RepositorioTallerFake({List<OrdenEnVivo>? ordenes, this.falla})
    : _ordenes = {
        for (final orden in ordenes ?? [ordenDeEjemplo()]) orden.id: orden,
      };

  final Map<int, OrdenEnVivo> _ordenes;

  /// Si no es nula, toda consulta la lanza.
  Object? falla;

  /// Si no es nula, responder la lanza.
  Object? fallaAlResponder;

  /// Lo que se respondio, en orden: (ordenId, adicionalId, aprobado, firma).
  final respuestas = <(int, int, bool, Uint8List)>[];

  /// Cuantas veces se pidio la orden, para saber si la pantalla recargo.
  var ordenesPedidas = 0;

  /// Reemplaza la orden, como cuando el taller la pasa de etapa.
  void actualizar(OrdenEnVivo orden) => _ordenes[orden.id] = orden;

  @override
  Future<List<OrdenEnCurso>> enCurso() async {
    if (falla != null) throw falla!;
    return [
      for (final orden in _ordenes.values)
        if (orden.etapa != EtapaTaller.entregado)
          OrdenEnCurso(
            id: orden.id,
            vehiculoId: orden.vehiculoId,
            vehiculo: orden.vehiculo,
            etapa: orden.etapa,
            avance: orden.avance,
            adicionalesPendientes: orden.pendientes.length,
            entregaEstimada: orden.entregaEstimada,
            asesor: orden.asesor,
            totalEstimado: orden.totalEstimado,
            horarioEntrega: orden.horarioEntrega,
          ),
    ];
  }

  @override
  Future<OrdenEnVivo> orden(int ordenId) async {
    ordenesPedidas++;
    if (falla != null) throw falla!;
    final orden = _ordenes[ordenId];
    if (orden == null) throw StateError('No existe la orden $ordenId');
    return orden;
  }

  @override
  Future<OrdenEnVivo> responder({
    required int ordenId,
    required int adicionalId,
    required bool aprobado,
    required Uint8List firmaPng,
  }) async {
    if (fallaAlResponder != null) throw fallaAlResponder!;
    final orden = await this.orden(ordenId);
    final adicional = orden.adicionales.firstWhere((a) => a.id == adicionalId);
    if (!adicional.pendiente) throw const AdicionalYaRespondido();
    respuestas.add((ordenId, adicionalId, aprobado, firmaPng));
    final adicionales = [
      for (final a in orden.adicionales)
        a.id == adicionalId
            ? TrabajoAdicional(
                id: a.id,
                concepto: a.concepto,
                manoDeObra: a.manoDeObra,
                refacciones: a.refacciones,
                total: a.total,
                estado: aprobado
                    ? EstadoAdicional.aprobado
                    : EstadoAdicional.rechazado,
                respondidoEn: DateTime(2026, 11, 24, 11, 5),
              )
            : a,
    ];
    double suma(EstadoAdicional estado) => adicionales
        .where((a) => a.estado == estado)
        .fold<double>(0, (total, a) => total + a.total);
    final aprobados = suma(EstadoAdicional.aprobado);
    final respondida = OrdenEnVivo(
      id: orden.id,
      vehiculoId: orden.vehiculoId,
      vehiculo: orden.vehiculo,
      etapa: orden.etapa,
      avance: orden.avance,
      etapas: orden.etapas,
      inspeccion: orden.inspeccion,
      evidencias: orden.evidencias,
      adicionales: adicionales,
      totalOrden: orden.totalOrden,
      totalAdicionalesAprobados: aprobados,
      totalAdicionalesPendientes: suma(EstadoAdicional.pendiente),
      totalEstimado: orden.totalOrden + aprobados,
      entregaEstimada: orden.entregaEstimada,
      asesor: orden.asesor,
      horarioEntrega: orden.horarioEntrega,
    );
    _ordenes[ordenId] = respondida;
    return respondida;
  }
}

/// Una orden en reparacion con inspeccion, foto, video y dos trabajos
/// adicionales pendientes. Lista para entrega trae el horario para recogerla
/// el 25 de noviembre de 09:00 a 17:00.
OrdenEnVivo ordenDeEjemplo({
  int id = 41,
  EtapaTaller etapa = EtapaTaller.enReparacion,
}) {
  final fotoFrenos = Evidencia(
    id: 1,
    tipo: TipoEvidencia.foto,
    url: Uri.parse('https://agencia.test/api/v1/archivos/evidencias/1'),
  );
  final video = Evidencia(
    id: 2,
    tipo: TipoEvidencia.video,
    url: Uri.parse('https://agencia.test/api/v1/archivos/evidencias/2'),
  );
  final recorridas = [
    for (final e in EtapaTaller.values)
      if (e.index <= etapa.index && e != EtapaTaller.lavado) e,
  ];
  return OrdenEnVivo(
    id: id,
    vehiculoId: 1,
    vehiculo: 'Nissan March 2026',
    etapa: etapa,
    avance: (etapa.index * 100 / (EtapaTaller.values.length - 1)).round(),
    entregaEstimada: DateTime(2026, 11, 24, 18),
    asesor: 'Laura Méndez',
    etapas: [
      for (final (i, e) in recorridas.indexed)
        PasoEtapa(
          etapa: e,
          inicio: DateTime(2026, 11, 24, 9 + i, 30),
          fin: e == etapa ? null : DateTime(2026, 11, 24, 10 + i, 30),
          nota: e == EtapaTaller.enReparacion ? 'Cambio de balatas' : null,
        ),
    ],
    inspeccion: [
      PuntoRevisado(
        id: 1,
        punto: 'Frenos',
        resultado: ResultadoInspeccion.rojo,
        comentario: 'Balatas al 10 %',
        evidencias: [fotoFrenos],
      ),
      const PuntoRevisado(
        id: 2,
        punto: 'Llantas',
        resultado: ResultadoInspeccion.amarillo,
        comentario: 'Desgaste parejo',
        evidencias: [],
      ),
      const PuntoRevisado(
        id: 3,
        punto: 'Luces',
        resultado: ResultadoInspeccion.verde,
        evidencias: [],
      ),
    ],
    evidencias: [video],
    adicionales: const [
      TrabajoAdicional(
        id: 11,
        concepto: 'Cambio de balatas delanteras',
        manoDeObra: 450,
        refacciones: 1200.5,
        total: 1650.5,
        estado: EstadoAdicional.pendiente,
      ),
      TrabajoAdicional(
        id: 12,
        concepto: 'Lavado de motor',
        manoDeObra: 200,
        refacciones: 0,
        total: 200,
        estado: EstadoAdicional.pendiente,
      ),
    ],
    totalOrden: 1282,
    totalAdicionalesAprobados: 0,
    totalAdicionalesPendientes: 1850.5,
    totalEstimado: 1282,
    horarioEntrega: etapa == EtapaTaller.listoParaEntrega
        ? HorarioEntrega(
            fecha: DateTime(2026, 11, 25),
            desde: '09:00',
            hasta: '17:00',
          )
        : null,
  );
}
