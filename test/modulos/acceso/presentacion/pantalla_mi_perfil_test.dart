import 'package:carecar_mobile/modulos/acceso/acceso.dart';
import 'package:carecar_mobile/modulos/vehiculos/datos/repositorio_garaje_fake.dart';
import 'package:carecar_mobile/modulos/vehiculos/vehiculos.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/esqueleto.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/estado_error.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../ayudas/fallos_de_prueba.dart';
import '../../../ayudas/tema_pista.dart';

/// V2-M01.06 · «ver mi perfil para confirmar mis datos».
///
/// El criterio pide nombre, correo, teléfono, «cliente desde» y vehículos, con
/// los estados de carga, error y sin conexión. Lo que más se prueba aquí es el
/// **teléfono que falta** -la agencia no siempre lo captura- y que un fallo al
/// traer los vehículos **no se lleve el perfil entero**: son dos lecturas
/// distintas y el cliente vino a confirmar sus datos.
void main() {
  PerfilDelCliente perfil({String? telefono = '477 123 4567'}) =>
      PerfilDelCliente(
        nombre: 'María Elena Robles',
        correo: 'cliente1@example.com',
        telefono: telefono,
        clienteDesde: DateTime(2022, 5, 18),
      );

  const versa = VehiculoGaraje(id: 1, modelo: 'Versa', anio: 2024);
  const cx5 = VehiculoGaraje(id: 2, modelo: 'CX-5', anio: 2021, marca: 'Mazda');

  Widget app(
    RepositorioAccesoFake repo, {
    List<VehiculoGaraje> vehiculos = const [versa, cx5],
    bool fallanLosVehiculos = false,
    Escenario escenario = Escenario.claro,
  }) => ProviderScope(
    overrides: [
      repositorioAccesoProvider.overrideWithValue(repo),
      repositorioGarajeProvider.overrideWithValue(
        RepositorioGarajeFake(fallar: fallanLosVehiculos, datos: vehiculos),
      ),
    ],
    child: conTemaPista(const PantallaMiPerfil(), escenario: escenario),
  );

  void prueba(String descripcion, Future<void> Function(WidgetTester) cuerpo) =>
      testWidgets(descripcion, (tester) async {
        tester.view.physicalSize = const Size(800, 4000);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        await cuerpo(tester);
      });

  group('los datos del cliente', () {
    prueba('muestra nombre, correo, telefono y desde cuando es cliente', (
      tester,
    ) async {
      await tester.pumpWidget(app(RepositorioAccesoFake()..perfilDelCliente = perfil()));
      await tester.pumpAndSettle();

      expect(find.text('María Elena Robles'), findsOneWidget);
      expect(find.text('cliente1@example.com'), findsOneWidget);
      expect(find.text('477 123 4567'), findsOneWidget);
      // La fecha se escribe en palabras, no como «2022-05-18».
      expect(find.textContaining('2022'), findsOneWidget);
    });

    prueba('sin telefono lo dice, en vez de dejar el renglon vacio', (
      tester,
    ) async {
      await tester.pumpWidget(
        app(RepositorioAccesoFake()..perfilDelCliente = perfil(telefono: null)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Sin teléfono registrado'), findsOneWidget);
      expect(find.text('María Elena Robles'), findsOneWidget);
    });
  });

  group('los vehiculos', () {
    prueba('salen en la lista', (tester) async {
      await tester.pumpWidget(app(RepositorioAccesoFake()..perfilDelCliente = perfil()));
      await tester.pumpAndSettle();

      expect(find.text('Versa 2024'), findsOneWidget);
      expect(find.text('Mazda CX-5 2021'), findsOneWidget);
    });

    prueba('si no hay, lo dice', (tester) async {
      await tester.pumpWidget(
        app(
          RepositorioAccesoFake()..perfilDelCliente = perfil(),
          vehiculos: const [],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('No tienes vehículos registrados'), findsOneWidget);
    });

    prueba('si fallan, el perfil se sigue viendo', (tester) async {
      // Son dos lecturas distintas y el cliente vino a confirmar sus datos:
      // perder el perfil entero porque el garaje no respondio seria peor.
      await tester.pumpWidget(
        app(
          RepositorioAccesoFake()..perfilDelCliente = perfil(),
          fallanLosVehiculos: true,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('María Elena Robles'), findsOneWidget);
      expect(find.text('No pudimos traer tus vehículos'), findsOneWidget);
    });
  });

  group('los estados del perfil', () {
    prueba('mientras carga muestra esqueleto', (tester) async {
      final repo = RepositorioAccesoFake()
        ..perfilDelCliente = perfil()
        ..esperar = Future<void>.delayed(const Duration(milliseconds: 50));

      await tester.pumpWidget(app(repo));
      await tester.pump();

      expect(find.byType(Esqueleto), findsWidgets);
      await tester.pumpAndSettle();
    });

    prueba('sin conexion ofrece reintentar', (tester) async {
      final repo = RepositorioAccesoFake()
        ..fallaAlLeerPerfil = Fallos.sinConexion();

      await tester.pumpWidget(app(repo));
      await tester.pumpAndSettle();

      expect(find.byType(EstadoError), findsOneWidget);
    });
  });

  prueba('ofrece ver las sesiones abiertas', (tester) async {
    // Es lo que vuelve alcanzable la pantalla de V2-M01.09: su ruta existe y
    // hasta ahora nada llevaba a ella.
    await tester.pumpWidget(app(RepositorioAccesoFake()..perfilDelCliente = perfil()));
    await tester.pumpAndSettle();

    expect(find.text('Mis sesiones'), findsOneWidget);
  });

  for (final escenario in [Escenario.oscuro, Escenario.letraGrande]) {
    prueba('se ve completa en ${escenario.name} sin desbordar', (tester) async {
      await tester.pumpWidget(
        app(
          RepositorioAccesoFake()..perfilDelCliente = perfil(telefono: null),
          escenario: escenario,
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('María Elena Robles'), findsOneWidget);
      expect(find.text('Sin teléfono registrado'), findsOneWidget);
    });
  }
}
