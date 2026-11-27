import 'package:carecar_mobile/modulos/notificaciones/datos/repositorio_avisos_fake.dart';
import 'package:carecar_mobile/modulos/notificaciones/dominio/aviso_cliente.dart';
import 'package:carecar_mobile/modulos/notificaciones/presentacion/pantalla_bandeja.dart';
import 'package:carecar_mobile/modulos/notificaciones/presentacion/proveedores_bandeja.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/boton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../ayudas/tema_pista.dart';

/// V2-M06.04 · la pantalla de la bandeja.
///
/// Lo que se comprueba es lo que la persona ve: que los cinco estados existan,
/// que el no leído se distinga **sin depender del color**, y que «marcar todos»
/// apague el contador.
void main() {
  AvisoCliente aviso(int id, {bool leida = false}) => AvisoCliente(
    id: id,
    categoria: CategoriaDeAviso.taller,
    titulo: 'Aviso $id',
    cuerpo: 'Cuerpo $id',
    creadaEn: DateTime.utc(2026, 11, 20),
    destino: '/taller',
    leida: leida,
  );

  Future<void> montar(
    WidgetTester tester,
    RepositorioAvisosFake repo, {
    int tamano = 20,
    Escenario escenario = Escenario.claro,
  }) async {
    tester.view.physicalSize = const Size(400, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          repositorioAvisosProvider.overrideWithValue(repo),
          tamanoPaginaAvisosProvider.overrideWithValue(tamano),
        ],
        child: conTemaPista(const PantallaBandeja(), escenario: escenario),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('con avisos, los lista y ofrece marcar todos', (tester) async {
    await montar(
      tester,
      RepositorioAvisosFake(avisos: [aviso(1), aviso(2, leida: true)]),
    );

    expect(find.text('Aviso 1'), findsOneWidget);
    expect(find.text('Aviso 2'), findsOneWidget);
    expect(find.byKey(PantallaBandeja.marcarTodos), findsOneWidget);
  });

  testWidgets('sin avisos muestra el vacío, no un error', (tester) async {
    await montar(tester, RepositorioAvisosFake());

    expect(find.text('Todavía no tienes avisos'), findsOneWidget);
    expect(find.byKey(PantallaBandeja.marcarTodos), findsNothing);
  });

  testWidgets('si falla la carga ofrece reintentar', (tester) async {
    await montar(tester, RepositorioAvisosFake(falla: true));

    expect(find.text('Reintentar'), findsOneWidget);
  });

  testWidgets('el no leído se anuncia al lector de pantalla', (tester) async {
    await montar(tester, RepositorioAvisosFake(avisos: [aviso(1)]));

    // No basta el punto de color: quien no distingue tonos lo necesita dicho.
    expect(
      find.bySemanticsLabel('Sin leer. Aviso 1. Cuerpo 1'),
      findsOneWidget,
    );
  });

  testWidgets('marcar todos apaga el contador y el botón', (tester) async {
    final repo = RepositorioAvisosFake(avisos: [aviso(1), aviso(2)]);
    await montar(tester, repo);
    expect(find.text('2 sin leer'), findsOneWidget);

    await tester.tap(find.byKey(PantallaBandeja.marcarTodos));
    await tester.pumpAndSettle();

    expect(find.text('2 sin leer'), findsNothing);
    expect(find.byKey(PantallaBandeja.marcarTodos), findsNothing);
    expect(repo.lotes, 1);
  });

  testWidgets('tocar un aviso lo marca leído', (tester) async {
    final repo = RepositorioAvisosFake(avisos: [aviso(1), aviso(2)]);
    await montar(tester, repo);

    await tester.tap(find.byKey(PantallaBandeja.aviso(1)));
    await tester.pumpAndSettle();

    expect(repo.marcados, [1]);
    expect(find.text('1 sin leer'), findsOneWidget);
  });

  testWidgets('con letra al 200 % no desborda', (tester) async {
    await montar(
      tester,
      RepositorioAvisosFake(avisos: [aviso(1), aviso(2)]),
      escenario: Escenario.letraGrande,
    );

    expect(tester.takeException(), isNull);
    expect(find.byType(Boton), findsOneWidget);
  });

  testWidgets('en oscuro se ve', (tester) async {
    await montar(
      tester,
      RepositorioAvisosFake(avisos: [aviso(1)]),
      escenario: Escenario.oscuro,
    );

    expect(tester.takeException(), isNull);
    expect(find.text('Aviso 1'), findsOneWidget);
  });
}
