import 'dart:async';

import 'package:carecar_mobile/api/excepciones.dart';
import 'package:carecar_mobile/modulos/mantenimiento/datos/repositorio_mantenimiento_fake.dart';
import 'package:carecar_mobile/modulos/mantenimiento/dominio/fallos_mantenimiento.dart';
import 'package:carecar_mobile/modulos/mantenimiento/dominio/plan_mantenimiento.dart';
import 'package:carecar_mobile/modulos/mantenimiento/dominio/repositorio_mantenimiento.dart';
import 'package:carecar_mobile/modulos/mantenimiento/presentacion/pantalla_registrar_km.dart';
import 'package:carecar_mobile/modulos/mantenimiento/presentacion/proveedores_mantenimiento.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../ayudas/auditoria_accesibilidad.dart';
import '../../ayudas/tema_pista.dart';

/// Un repositorio que decide qué contesta a `registrarKm`.
class _RepoQueFalla extends RepositorioMantenimientoFake {
  _RepoQueFalla(this.alRegistrar);

  final Future<LecturaKm> Function() alRegistrar;

  @override
  Future<LecturaKm> registrarKm(int vehiculoId, int km) => alRegistrar();
}

/// Abre la pantalla encima de otra, como lo hace el plan, y guarda con qué
/// resultado se cerró.
Widget _app(
  RepositorioMantenimiento repo, {
  Escenario escenario = Escenario.claro,
  void Function(bool?)? alCerrar,
}) => ProviderScope(
  overrides: [repositorioMantenimientoProvider.overrideWithValue(repo)],
  child: conTemaPista(
    Builder(
      builder: (context) => Center(
        child: TextButton(
          onPressed: () async {
            final r = await Navigator.of(context).push<bool>(
              MaterialPageRoute(
                builder: (_) => const PantallaRegistrarKm(vehiculoId: 5),
              ),
            );
            alCerrar?.call(r);
          },
          child: const Text('abrir'),
        ),
      ),
    ),
    escenario: escenario,
  ),
);

Future<void> _abrir(WidgetTester tester) async {
  await tester.tap(find.text('abrir'));
  await tester.pumpAndSettle();
}

Future<void> _escribir(WidgetTester tester, String km) async {
  await tester.enterText(find.byType(TextField), km);
  await tester.pump();
}

Future<void> _guardar(WidgetTester tester) async {
  final boton = find.text('Guardar kilometraje');
  await tester.ensureVisible(boton);
  await tester.pumpAndSettle();
  await tester.tap(boton);
  await tester.pumpAndSettle();
}

void _prueba(String descripcion, Future<void> Function(WidgetTester) cuerpo) =>
    testWidgets(descripcion, (tester) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await cuerpo(tester);
    });

void main() {
  _prueba('muestra el último km, que el del taller manda y el campo', (
    tester,
  ) async {
    await tester.pumpWidget(_app(RepositorioMantenimientoFake()));
    await _abrir(tester);

    expect(find.text('Registrar kilometraje'), findsOneWidget);
    expect(find.text('Kilometraje actual'), findsOneWidget);
    expect(find.text('Tu último registro: 9,000 km'), findsOneWidget);
    expect(
      find.textContaining(
        'El kilometraje que registra el taller es el oficial',
      ),
      findsOneWidget,
    );
  });

  _prueba('sin lectura previa pide el número del tablero', (tester) async {
    final base = RepositorioMantenimientoFake.planDeEjemplo();
    await tester.pumpWidget(
      _app(
        RepositorioMantenimientoFake(
          plan: PlanMantenimiento(
            vehiculoId: base.vehiculoId,
            servicios: base.servicios,
          ),
        ),
      ),
    );
    await _abrir(tester);
    expect(
      find.text('Escribe el número que marca el tablero de tu auto.'),
      findsOneWidget,
    );
  });

  _prueba('vacío no se guarda y dice qué falta', (tester) async {
    final repo = RepositorioMantenimientoFake();
    await tester.pumpWidget(_app(repo));
    await _abrir(tester);
    await _guardar(tester);

    expect(find.text('Escribe tu kilometraje.'), findsOneWidget);
    expect(repo.lecturas, isEmpty);
  });

  _prueba('cero no es un kilometraje válido', (tester) async {
    final repo = RepositorioMantenimientoFake();
    await tester.pumpWidget(_app(repo));
    await _abrir(tester);
    await _escribir(tester, '0');
    await _guardar(tester);

    expect(
      find.text('Usa solo números enteros mayores que cero.'),
      findsOneWidget,
    );
    expect(repo.lecturas, isEmpty);
  });

  _prueba('un km menor al último se rechaza antes de pedirlo al servidor', (
    tester,
  ) async {
    final repo = RepositorioMantenimientoFake();
    await tester.pumpWidget(_app(repo));
    await _abrir(tester);
    await _escribir(tester, '8999');
    await _guardar(tester);

    expect(
      find.text('No puede ser menor a 9,000 km, el último que tenemos.'),
      findsOneWidget,
    );
    expect(repo.lecturas, isEmpty);
  });

  _prueba('un km válido se guarda y la pantalla se cierra con éxito', (
    tester,
  ) async {
    final repo = RepositorioMantenimientoFake();
    bool? resultado;
    await tester.pumpWidget(_app(repo, alCerrar: (r) => resultado = r));
    await _abrir(tester);
    await _escribir(tester, '9500');
    await _guardar(tester);

    expect(repo.lecturas, [9500]);
    expect(resultado, isTrue);
    expect(find.text('Registrar kilometraje'), findsNothing);
  });

  _prueba('el mismo km que el último también es válido', (tester) async {
    final repo = RepositorioMantenimientoFake();
    await tester.pumpWidget(_app(repo));
    await _abrir(tester);
    await _escribir(tester, '9000');
    await _guardar(tester);
    expect(repo.lecturas, [9000]);
  });

  _prueba('el servidor dice KM_INVALIDO: lo explica y deja corregir', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(_RepoQueFalla(() async => throw const KmInvalido())),
    );
    await _abrir(tester);
    await _escribir(tester, '9500');
    await _guardar(tester);

    expect(
      find.text(
        'Ese kilometraje es menor al último registrado. Revísalo en tu tablero.',
      ),
      findsOneWidget,
    );
    expect(find.text('Registrar kilometraje'), findsOneWidget);
    expect(find.text('9500'), findsOneWidget);
  });

  _prueba('sin conexión conserva lo escrito y permite reintentar', (
    tester,
  ) async {
    var intentos = 0;
    await tester.pumpWidget(
      _app(
        _RepoQueFalla(() async {
          intentos++;
          if (intentos == 1) throw const SinConexion();
          return LecturaKm(
            id: 1,
            km: 9500,
            registradaEn: DateTime(2026, 11, 23),
          );
        }),
      ),
    );
    await _abrir(tester);
    await _escribir(tester, '9500');
    await _guardar(tester);

    expect(
      find.text(
        'No pudimos guardar tu kilometraje. Revisa tu internet y vuelve a '
        'intentarlo.',
      ),
      findsOneWidget,
    );
    expect(find.text('9500'), findsOneWidget);

    await _guardar(tester);
    expect(intentos, 2);
    expect(find.text('Registrar kilometraje'), findsNothing);
  });

  _prueba('mientras guarda se anuncia y no se puede guardar dos veces', (
    tester,
  ) async {
    final espera = Completer<LecturaKm>();
    var intentos = 0;
    await tester.pumpWidget(
      _app(
        _RepoQueFalla(() {
          intentos++;
          return espera.future;
        }),
      ),
    );
    await _abrir(tester);
    await _escribir(tester, '9500');
    final boton = find.text('Guardar kilometraje');
    await tester.ensureVisible(boton);
    await tester.pumpAndSettle();
    await tester.tap(boton);
    await tester.pump();

    expect(find.bySemanticsLabel('Guardando kilometraje'), findsOneWidget);
    await tester.tap(boton, warnIfMissed: false);
    await tester.pump();
    expect(intentos, 1);

    espera.complete(
      LecturaKm(id: 1, km: 9500, registradaEn: DateTime(2026, 11, 23)),
    );
    await tester.pumpAndSettle();
  });

  for (final escenario in Escenario.values) {
    _prueba('se ve sin desbordes ($escenario)', (tester) async {
      await tester.pumpWidget(
        _app(RepositorioMantenimientoFake(), escenario: escenario),
      );
      await _abrir(tester);
      await _escribir(tester, '8000');
      await _guardar(tester);
      expect(tester.takeException(), isNull);
      expect(find.textContaining('No puede ser menor a'), findsOneWidget);
    });
  }

  _prueba('pasa la auditoría de accesibilidad', (tester) async {
    await tester.pumpWidget(_app(RepositorioMantenimientoFake()));
    await _abrir(tester);
    await auditarAccesibilidad(tester);
  });
}
