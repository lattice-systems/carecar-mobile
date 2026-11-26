import 'package:carecar_mobile/api/modelos/modelos.dart';
import 'package:carecar_mobile/modulos/historial/datos/repositorio_historial_api.dart';
import 'package:carecar_mobile/modulos/historial/dominio/orden_historial.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../ayudas/api_falsa.dart';

void main() {
  test('traduce las ordenes con su fecha de cierre y filtra por año', () async {
    final api = ApiFalsa()
      ..alPedirServicios = (_) async => [
        Servicio(
          id: 2,
          fecha: DateTime(2026, 10, 20),
          estatus: 'TERMINADO',
          total: 1282,
          fechaCierre: DateTime(2026, 10, 20, 13, 45),
        ),
        Servicio(
          id: 1,
          fecha: DateTime(2025, 3, 1),
          estatus: 'EN_PROCESO',
          total: 300,
        ),
      ];
    final repo = RepositorioHistorialApi(api);

    final todas = await repo.ordenes(7);
    final de2025 = await repo.ordenes(7, anio: 2025);

    expect(todas.ordenes.map((o) => o.id), [2, 1]);
    expect(todas.ordenes.first.estatus, EstatusOrden.terminado);
    expect(todas.ordenes.first.fechaCierre, DateTime(2026, 10, 20, 13, 45));
    expect(todas.ordenes.last.fechaCierre, isNull);
    expect(de2025.ordenes.single.estatus, EstatusOrden.enProceso);
    expect(await repo.anios(7), [2026, 2025]);
  });

  test('traduce el ticket con su mano de obra y sus refacciones', () async {
    final api = ApiFalsa()
      ..alPedirDetalleDeServicio = (id) async => ServicioDetalle.fromJson({
        'id': id,
        'vehiculoId': 7,
        'fecha': '2026-10-20',
        'kilometraje': 15000,
        'estatus': 'TERMINADO',
        'fechaCierre': '2026-10-20T13:45:00',
        'manoDeObra': [
          {
            'concepto': 'Cambio de aceite',
            'cantidad': 1,
            'precio': 450.0,
            'importe': 450.0,
          },
        ],
        'refacciones': [
          {
            'concepto': 'Filtro de aceite',
            'cantidad': 2,
            'precio': 175.5,
            'importe': 351.0,
          },
        ],
        'totalManoDeObra': 450.0,
        'totalRefacciones': 351.0,
        'subtotal': 690.52,
        'iva': 110.48,
        'total': 801.0,
        'puntosGanados': 80,
      });

    final ticket = await RepositorioHistorialApi(api).ticket(21);

    expect(ticket.id, 21);
    expect(ticket.fechaCierre, DateTime(2026, 10, 20, 13, 45));
    expect(ticket.manoDeObra.single.concepto, 'Cambio de aceite');
    expect(ticket.refacciones.single.importe, 351);
    expect(ticket.cuadra, isTrue);
    expect(ticket.puntosGanados, 80);
  });
}
