import 'package:carecar_mobile/modulos/taller/datos/repositorio_taller_fake.dart';
import 'package:carecar_mobile/modulos/taller/dominio/orden_taller.dart';
import 'package:carecar_mobile/modulos/taller/presentacion/pantalla_inspeccion.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/estado_vacio.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/galeria_fotos.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/semaforo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../ayudas/auditoria_accesibilidad.dart';
import '../../ayudas/tema_pista.dart';
import 'ayudas_taller.dart';

Widget _app(
  RepositorioTallerFake repo, {
  Escenario escenario = Escenario.claro,
  double ancho = 360,
  bool abreVideo = true,
}) => appTaller(
  const PantallaInspeccion(ordenId: 41),
  repo,
  escenario: escenario,
  ancho: ancho,
  abreVideo: abreVideo,
);

OrdenEnVivo _sinInspeccion() {
  final orden = ordenDeEjemplo();
  return OrdenEnVivo(
    id: orden.id,
    vehiculoId: orden.vehiculoId,
    vehiculo: orden.vehiculo,
    etapa: orden.etapa,
    avance: orden.avance,
    etapas: orden.etapas,
    inspeccion: const [],
    evidencias: const [],
    adicionales: orden.adicionales,
    totalOrden: orden.totalOrden,
    totalAdicionalesAprobados: orden.totalAdicionalesAprobados,
    totalAdicionalesPendientes: orden.totalAdicionalesPendientes,
    totalEstimado: orden.totalEstimado,
  );
}

void main() {
  pruebaTaller('cada punto lleva su semaforo con icono y texto', (
    tester,
  ) async {
    await tester.pumpWidget(_app(RepositorioTallerFake()));
    await tester.pumpAndSettle();

    final semaforos = tester
        .widgetList<Semaforo>(find.byType(Semaforo))
        .toList();
    expect(semaforos.map((s) => s.punto), ['Frenos', 'Llantas', 'Luces']);
    expect(semaforos.map((s) => s.estado), [
      EstadoSemaforo.urgente,
      EstadoSemaforo.atencion,
      EstadoSemaforo.bien,
    ]);
    expect(semaforos.first.detalle, 'Balatas al 10 %');
    expect(find.byIcon(EstadoSemaforo.urgente.icono), findsWidgets);
  });

  pruebaTaller('las fotos se amplian con zoom', (tester) async {
    await tester.pumpWidget(_app(RepositorioTallerFake()));
    await tester.pumpAndSettle();

    final galeria = tester.widget<GaleriaFotos>(find.byType(GaleriaFotos));
    expect(galeria.fotos.single.descripcion, 'Foto de Frenos');

    await tester.tap(
      find.descendant(
        of: find.byType(GaleriaFotos),
        matching: find.byType(Image),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(InteractiveViewer), findsOneWidget);
  });

  pruebaTaller('el video se abre en el reproductor del telefono', (
    tester,
  ) async {
    await tester.pumpWidget(_app(RepositorioTallerFake()));
    await tester.pumpAndSettle();

    expect(find.text('De la orden'), findsOneWidget);
    await tester.tap(find.text('Ver video 1'));
    await tester.pumpAndSettle();

    expect(videosAbiertos, [
      Uri.parse('https://agencia.test/api/v1/archivos/evidencias/2'),
    ]);
    expect(find.textContaining('No se pudo abrir el video'), findsNothing);
  });

  pruebaTaller('si el video no abre lo avisa', (tester) async {
    await tester.pumpWidget(_app(RepositorioTallerFake(), abreVideo: false));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Ver video 1'));
    await tester.pumpAndSettle();

    expect(find.textContaining('No se pudo abrir el video'), findsOneWidget);
  });

  pruebaTaller('sin inspeccion lo explica', (tester) async {
    await tester.pumpWidget(
      _app(RepositorioTallerFake(ordenes: [_sinInspeccion()])),
    );
    await tester.pumpAndSettle();

    expect(find.byType(EstadoVacio), findsOneWidget);
    expect(find.text('Aún sin inspección'), findsOneWidget);
  });

  for (final escenario in Escenario.values) {
    pruebaTaller('se ve sin desbordes en ${escenario.name}', (tester) async {
      await tester.pumpWidget(
        _app(RepositorioTallerFake(), escenario: escenario),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('pasa la auditoria de accesibilidad en 320 (V2-M20.02, '
      'V2-M20.03 y V2-M20.08)', (tester) async {
    telefonoChicoYAlto(tester);
    for (final escenario in Escenario.values) {
      await tester.pumpWidget(
        _app(
          RepositorioTallerFake(),
          escenario: escenario,
          ancho: anchoTelefonoChico,
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: escenario.name);
      if (escenario != Escenario.letraGrande) {
        await auditarAccesibilidad(tester);
      }
    }
  });
}
