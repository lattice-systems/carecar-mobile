import 'package:carecar_mobile/modulos/taller/datos/lectura_taller.dart';
import 'package:carecar_mobile/modulos/taller/datos/repositorio_taller_fake.dart';
import 'package:carecar_mobile/modulos/taller/dominio/etapa_taller.dart';
import 'package:carecar_mobile/modulos/taller/dominio/orden_taller.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, Object?> _ordenJson({List<Object?>? etapas}) => {
  'id': 41,
  'vehiculoId': 5,
  'vehiculo': 'Nissan March 2026',
  'estatus': 'EN_PROCESO',
  'etapa': 'EN_REPARACION',
  'entregaEstimada': '2026-11-24T18:00:00',
  'asesor': 'Laura Méndez',
  'avance': 43,
  'etapas':
      etapas ??
      [
        {
          'etapa': 'RECIBIDO',
          'inicio': '2026-11-24T09:30:00',
          'fin': '2026-11-24T10:05:00',
          'nota': null,
        },
        {
          'etapa': 'EN_REPARACION',
          'inicio': '2026-11-24T10:05:00',
          'fin': null,
          'nota': 'Cambio de balatas',
        },
      ],
  'inspeccion': [
    {
      'id': 1,
      'punto': 'Frenos',
      'resultado': 'ROJO',
      'comentario': 'Balatas al 10 %',
      'evidencias': [
        {
          'id': 7,
          'tipo': 'FOTO',
          'url': '/api/v1/archivos/evidencias/abc?expira=1&firma=x',
        },
        {'id': 8, 'tipo': 'HOLOGRAMA', 'url': '/x'},
      ],
    },
    {
      'id': 2,
      'punto': 'Luces',
      'resultado': 'MORADO',
      'comentario': null,
      'evidencias': [],
    },
  ],
  'evidencias': [
    {'id': 9, 'tipo': 'VIDEO', 'url': 'https://cdn.test/v.mp4'},
  ],
  'adicionales': [
    {
      'id': 11,
      'concepto': 'Cambio de balatas',
      'manoDeObra': 450,
      'refacciones': 1200.5,
      'total': 1650.5,
      'estado': 'PENDIENTE',
      'respondidoEn': null,
    },
  ],
  'totalOrden': 1282,
  'totalAdicionalesAprobados': 0,
  'totalAdicionalesPendientes': 1650.5,
  'totalEstimado': 1282,
};

void main() {
  final lectura = LecturaTaller(Uri.parse('https://agencia.test/api/v1/app'));

  test('lee las etapas del contrato y tolera una desconocida', () {
    expect(
      EtapaTaller.desde('LISTO_PARA_ENTREGA'),
      EtapaTaller.listoParaEntrega,
    );
    expect(EtapaTaller.desde('OTRA'), isNull);
    expect(ResultadoInspeccion.desde('AMARILLO'), ResultadoInspeccion.amarillo);
    expect(EstadoAdicional.desde('RECHAZADO'), EstadoAdicional.rechazado);
  });

  test('lee la orden, resuelve las URL relativas y omite lo desconocido', () {
    final orden = lectura.orden(_ordenJson());

    expect(orden.etapa, EtapaTaller.enReparacion);
    expect(orden.entregaEstimada, DateTime(2026, 11, 24, 18));
    expect(orden.etapas.last.nota, 'Cambio de balatas');
    expect(orden.etapas.last.fin, isNull);
    expect(orden.inspeccion, hasLength(1));
    expect(orden.inspeccion.single.evidencias, hasLength(1));
    expect(
      orden.inspeccion.single.evidencias.single.url.toString(),
      'https://agencia.test/api/v1/archivos/evidencias/abc?expira=1&firma=x',
    );
    expect(orden.evidencias.single.tipo, TipoEvidencia.video);
    expect(orden.evidencias.single.url.toString(), 'https://cdn.test/v.mp4');
    expect(orden.adicionales.single.total, 1650.5);
    expect(orden.pendientes, hasLength(1));
  });

  test('una etapa sin inicio no respeta el contrato', () {
    expect(
      () => lectura.orden(
        _ordenJson(
          etapas: [
            {'etapa': 'RECIBIDO', 'inicio': null},
          ],
        ),
      ),
      throwsFormatException,
    );
  });

  test('la linea de tiempo trae lo recorrido y despues lo que falta', () {
    final linea = lectura.orden(_ordenJson()).lineaDeTiempo();

    expect(linea.map((p) => p.etapa), [
      EtapaTaller.recibido,
      EtapaTaller.enReparacion,
      EtapaTaller.controlDeCalidad,
      EtapaTaller.lavado,
      EtapaTaller.listoParaEntrega,
      EtapaTaller.entregado,
    ]);
    expect(linea.map((p) => p.estado), [
      EstadoEtapa.hecha,
      EstadoEtapa.actual,
      EstadoEtapa.pendiente,
      EstadoEtapa.pendiente,
      EstadoEtapa.pendiente,
      EstadoEtapa.pendiente,
    ]);
    expect(linea.first.inicio, DateTime(2026, 11, 24, 9, 30));
    expect(linea[2].inicio, isNull);
  });

  test('una orden entregada tiene todas sus etapas hechas', () {
    final linea = ordenDeEjemplo(etapa: EtapaTaller.entregado).lineaDeTiempo();

    expect(linea.every((p) => p.estado == EstadoEtapa.hecha), isTrue);
    expect(linea.last.etapa, EtapaTaller.entregado);
  });

  test('lee la orden en curso de la tarjeta de Inicio', () {
    final enCurso = lectura.enCurso({
      'id': 41,
      'vehiculoId': 5,
      'vehiculo': 'Nissan March 2026',
      'etapa': 'DIAGNOSTICO',
      'estatus': 'EN_PROCESO',
      'entregaEstimada': null,
      'asesor': null,
      'avance': 14,
      'adicionalesPendientes': 2,
    });

    expect(enCurso.etapa, EtapaTaller.diagnostico);
    expect(enCurso.entregaEstimada, isNull);
    expect(enCurso.asesor, isNull);
    expect(enCurso.adicionalesPendientes, 2);
  });
}
