import 'package:carecar_mobile/api/excepciones.dart';
import 'package:carecar_mobile/modulos/bitacora/datos/repositorio_bitacora_fake.dart';
import 'package:carecar_mobile/modulos/bitacora/presentacion/pantalla_bitacora.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/esqueleto.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/estado_error.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../ayudas/tema_pista.dart';
import 'arnes_bitacora.dart';

Widget _pantalla(
  RepositorioBitacoraFake repo, {
  Escenario escenario = Escenario.claro,
}) => aplicacion(
  const PantallaBitacora(vehiculoId: 4, nombre: 'Aveo 2022'),
  repo: repo,
  escenario: escenario,
);

void main() {
  prueba('mientras carga muestra esqueleto y lo anuncia', (tester) async {
    await tester.pumpWidget(_pantalla(RepositorioBitacoraFake()));
    expect(find.byType(Esqueleto), findsWidgets);
    expect(find.bySemanticsLabel('Cargando tu bitácora'), findsOneWidget);
    await tester.pumpAndSettle();
  });

  prueba('sin gastos explica qué hacer y deja las dos altas a la mano', (
    tester,
  ) async {
    await tester.pumpWidget(_pantalla(RepositorioBitacoraFake()));
    await tester.pumpAndSettle();
    expect(find.text('Aún no hay gastos'), findsOneWidget);
    expect(find.text('Nueva carga'), findsOneWidget);
    expect(find.text('Otro gasto'), findsOneWidget);
    expect(find.text('Aveo 2022'), findsOneWidget);
  });

  prueba('con gastos muestra km/l, \$/km y el gasto del mes (V2-M18.03)', (
    tester,
  ) async {
    await tester.pumpWidget(
      _pantalla(RepositorioBitacoraFake(gastos: gastosDePrueba())),
    );
    await tester.pumpAndSettle();
    expect(find.text('10.0 km/l'), findsOneWidget);
    expect(find.text(r'$2.10/km'), findsOneWidget);
    // La tercera cifra queda fuera de la vista del estante: se desliza.
    await tester.drag(find.text('Rendimiento'), const Offset(-400, 0));
    await tester.pumpAndSettle();
    // El gasto del mes es el lavado de noviembre.
    expect(find.text(r'$80.00'), findsWidgets);
    expect(find.text('Gasto de este mes'), findsOneWidget);
  });

  prueba('con una sola carga dice que necesita 2 y no inventa cifras', (
    tester,
  ) async {
    await tester.pumpWidget(
      _pantalla(
        RepositorioBitacoraFake(
          gastos: [carga(1, DateTime(2026, 10, 1), 10000, 40, 800)],
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('—'), findsNWidgets(2));
    expect(find.text('Necesitas 2 cargas'), findsNWidgets(2));
  });

  prueba('agrupa los gastos por mes y marca cada tipo', (tester) async {
    await tester.pumpWidget(
      _pantalla(
        RepositorioBitacoraFake(
          gastos: [
            ...gastosDePrueba(),
            otroGasto(
              9,
              DateTime(2026, 11, 7),
              50,
              descripcion: 'Lavado express',
            ),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('noviembre de 2026'), findsWidgets);
    expect(find.text('octubre de 2026'), findsOneWidget);
    expect(find.text('Gasolina'), findsNWidgets(2));
    expect(find.text('Lavado'), findsNWidgets(2));
    expect(find.textContaining('40.00 l · 10,400 km'), findsOneWidget);
  });

  prueba('un error con red ofrece reintentar y uno sin red lo dice', (
    tester,
  ) async {
    await tester.pumpWidget(
      _pantalla(RepositorioBitacoraFake(error: const SinConexion())),
    );
    await tester.pumpAndSettle();
    final error = tester.widget<EstadoError>(find.byType(EstadoError));
    expect(error.causa, CausaError.sinConexion);
    expect(find.text('Reintentar'), findsOneWidget);
  });

  prueba('«Nueva carga» abre el formulario de carga', (tester) async {
    await tester.pumpWidget(_pantalla(RepositorioBitacoraFake()));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Nueva carga'));
    await tester.pumpAndSettle();
    expect(find.text('Llenar desde el ticket'), findsOneWidget);
    expect(find.text('Litros'), findsOneWidget);
  });

  prueba('«Otro gasto» abre el formulario de otros gastos', (tester) async {
    await tester.pumpWidget(_pantalla(RepositorioBitacoraFake()));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Otro gasto'));
    await tester.pumpAndSettle();
    expect(find.text('Nuevo gasto'), findsOneWidget);
    expect(find.text('Llenar desde el ticket'), findsNothing);
    expect(find.text('Descripción'), findsOneWidget);
  });

  prueba('tocar un gasto lo abre para editarlo', (tester) async {
    await tester.pumpWidget(
      _pantalla(RepositorioBitacoraFake(gastos: gastosDePrueba())),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lavado'));
    await tester.pumpAndSettle();
    expect(find.text('Editar gasto'), findsOneWidget);
    expect(find.text('Borrar gasto'), findsOneWidget);
  });

  for (final escenario in [Escenario.oscuro, Escenario.letraGrande]) {
    prueba('se ve completa con ${escenario.name} sin desbordar', (
      tester,
    ) async {
      await tester.pumpWidget(
        _pantalla(
          RepositorioBitacoraFake(gastos: gastosDePrueba()),
          escenario: escenario,
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Nueva carga'), findsOneWidget);
    });
  }
}
