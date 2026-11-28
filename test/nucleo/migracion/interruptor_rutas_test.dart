import 'package:flutter/material.dart' show Locale;
import 'package:carecar_mobile/nucleo/inicio/inicio_nuevo.dart';
import 'package:carecar_mobile/modulos/acceso/acceso.dart';
import 'package:carecar_mobile/modulos/asistencia/asistencia.dart';
import 'package:carecar_mobile/modulos/catalogo/catalogo.dart';
import 'package:carecar_mobile/modulos/citas/citas.dart';
import 'package:carecar_mobile/modulos/vehiculos/vehiculos.dart';
import 'package:carecar_mobile/nucleo/migracion/interruptor_modulos.dart';
import 'package:carecar_mobile/nucleo/migracion/proveedores_migracion.dart';
import 'package:carecar_mobile/nucleo/navegacion/rutas.dart';
import 'package:carecar_mobile/pantallas/catalogo/pantalla_catalogo.dart' as v1;
import 'package:carecar_mobile/pantallas/citas/pantalla_mis_citas.dart' as v1;
import 'package:carecar_mobile/pantallas/pantalla_vehiculos.dart' as v1;
import 'package:carecar_mobile/sesion/almacen_sesion.dart';
import 'package:carecar_mobile/sesion/controlador_sesion.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../ayudas/api_falsa.dart';
import '../../ayudas/app_enrutada.dart';

Future<void> _montar(
  WidgetTester tester,
  InterruptorModulos interruptor, {
  bool conSesion = true,
}) async {
  final api = ApiFalsa();
  final sesion = ControladorSesion(api, AlmacenEnMemoria());
  addTearDown(sesion.dispose);
  if (conSesion) {
    await sesion.iniciarSesion(correo: 'a@b.mx', contrasena: 'CareCar2026');
  }
  await tester.pumpWidget(
    AppEnrutadaDePrueba(
      api: api,
      controlador: sesion,
      interruptor: interruptor,

      idioma: const Locale('es'),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _ir(WidgetTester tester, String ruta) async {
  enrutadorDe(tester).go(ruta);
  await tester.pumpAndSettle();
}

void main() {
  test('la app lee el interruptor de los --dart-define (v2 sin ellos)', () {
    final contenedor = ProviderContainer();
    addTearDown(contenedor.dispose);
    final i = contenedor.read(interruptorModulosProvider);
    for (final m in ModuloMigrable.values) {
      expect(i.esV2(m), isTrue, reason: m.name);
    }
  });

  group('rutas v2 segun el interruptor', () {
    const rutas = {
      ModuloMigrable.vehiculos: rutaGaraje,
      ModuloMigrable.citas: rutaMisCitas,
      ModuloMigrable.catalogo: rutaCatalogo,
      ModuloMigrable.asistencia: rutaSos,
    };

    for (final e in rutas.entries) {
      testWidgets('${e.key.name} en v2: ${e.value} abre la pantalla v2', (
        tester,
      ) async {
        await _montar(tester, InterruptorModulos.todoV2);
        await _ir(tester, e.value);
        expect(find.byType(InicioNuevo), findsNothing);
      });

      testWidgets('${e.key.name} en v1: ${e.value} cae en el inicio', (
        tester,
      ) async {
        await _montar(tester, InterruptorModulos.todoV1);
        await _ir(tester, e.value);
        expect(find.byType(InicioNuevo), findsOneWidget);
      });
    }

    testWidgets('apagar un modulo no apaga a los demas', (tester) async {
      await _montar(
        tester,
        InterruptorModulos.desdeValores(v2: 'todos', v1: 'citas'),
      );
      await _ir(tester, rutaMisCitas);
      expect(find.byType(InicioNuevo), findsOneWidget);
      await _ir(tester, rutaGaraje);
      expect(find.byType(InicioNuevo), findsNothing);
    });
  });

  // Los destinos del inicio viven en la barra flotante (V2-T02.22).
  // El acceso y la recuperacion ya no tienen v1 (V2-T02.27): el interruptor
  // no los toca, ni siquiera con todo en v1.
  group('el acceso y la recuperacion siempre son v2', () {
    for (final (nombre, interruptor) in [
      ('por defecto', InterruptorModulos.porDefecto),
      ('todo en v1', InterruptorModulos.todoV1),
    ]) {
      testWidgets('$nombre: sin sesion se ve el acceso v2', (tester) async {
        await _montar(tester, interruptor, conSesion: false);
        expect(find.byType(PantallaAcceso), findsOneWidget);
      });

      testWidgets('$nombre: /recuperar es la recuperacion v2', (tester) async {
        await _montar(tester, interruptor, conSesion: false);
        await _ir(tester, Rutas.recuperar);
        expect(find.byType(PantallaRecuperar), findsOneWidget);
      });
    }

    testWidgets('el enlace del correo abre el paso de la contrasena nueva', (
      tester,
    ) async {
      await _montar(tester, InterruptorModulos.porDefecto, conSesion: false);
      await _ir(tester, Rutas.localizacionRestablecer(token: '123456'));
      expect(find.byType(PantallaNuevaContrasena), findsOneWidget);
    });

    testWidgets(
      '«Olvide mi contrasena» del acceso v2 llega a la recuperacion',
      (tester) async {
        await _montar(tester, InterruptorModulos.porDefecto, conSesion: false);
        await tester.tap(find.byKey(PantallaAcceso.botonOlvide));
        await tester.pumpAndSettle();
        expect(find.byType(PantallaRecuperar), findsOneWidget);
      },
    );
  });

  group('el menu v1 abre la version que dice el interruptor', () {
    testWidgets('por defecto: la barra abre las pantallas v2', (tester) async {
      await _montar(tester, InterruptorModulos.porDefecto);
      await tester.tap(find.text('Garaje'));
      await tester.pumpAndSettle();
      expect(find.byType(v1.PantallaVehiculos), findsNothing);
      expect(find.byType(PantallaGaraje), findsOneWidget);
    });

    testWidgets('MODULOS_V1=todos: la barra vuelve a las pantallas v1', (
      tester,
    ) async {
      await _montar(tester, InterruptorModulos.desdeValores(v1: 'todos'));
      await tester.tap(find.text('Garaje'));
      await tester.pumpAndSettle();
      expect(find.byType(v1.PantallaVehiculos), findsOneWidget);
    });

    testWidgets('todo en v1: la barra abre las pantallas v1', (tester) async {
      await _montar(tester, InterruptorModulos.todoV1);
      await tester.tap(find.text('Garaje'));
      await tester.pumpAndSettle();
      expect(find.byType(v1.PantallaVehiculos), findsOneWidget);
    });

    testWidgets('vehiculos en v2: la barra lleva al garaje v2', (tester) async {
      await _montar(
        tester,
        const InterruptorModulos({ModuloMigrable.vehiculos: VersionModulo.v2}),
      );
      await tester.tap(find.text('Garaje'));
      await tester.pumpAndSettle();
      expect(find.byType(v1.PantallaVehiculos), findsNothing);
      expect(find.byType(PantallaGaraje), findsOneWidget);
    });

    testWidgets('citas en v2: la barra lleva a mis citas v2', (tester) async {
      await _montar(
        tester,
        const InterruptorModulos({ModuloMigrable.citas: VersionModulo.v2}),
      );
      await tester.tap(find.text('Citas').last);
      await tester.pumpAndSettle();
      expect(find.byType(v1.PantallaMisCitas), findsNothing);
      expect(find.byType(PantallaMisCitas), findsOneWidget);
    });

    testWidgets('catalogo en v2: la barra lleva al catalogo v2', (
      tester,
    ) async {
      await _montar(
        tester,
        const InterruptorModulos({ModuloMigrable.catalogo: VersionModulo.v2}),
      );
      await tester.tap(find.text('Catálogo').last);
      await tester.pumpAndSettle();
      expect(find.byType(v1.PantallaCatalogo), findsNothing);
      expect(find.byType(PantallaCatalogo), findsOneWidget);
    });

    testWidgets('un modulo en v2 no cambia los que siguen en v1', (
      tester,
    ) async {
      await _montar(
        tester,
        const InterruptorModulos({ModuloMigrable.vehiculos: VersionModulo.v2}),
      );
      await tester.tap(find.text('Citas').last);
      await tester.pumpAndSettle();
      expect(find.byType(v1.PantallaMisCitas), findsOneWidget);
    });
  });
}
