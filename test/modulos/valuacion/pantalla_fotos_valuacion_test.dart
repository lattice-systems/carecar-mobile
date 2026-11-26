import 'dart:async';

import 'package:carecar_mobile/api/excepciones.dart';
import 'package:carecar_mobile/modulos/valuacion/datos/repositorio_valuacion_fake.dart';
import 'package:carecar_mobile/modulos/valuacion/presentacion/proveedores_valuacion.dart';
import 'package:carecar_mobile/modulos/valuacion/presentacion/silueta_toma.dart';
import 'package:carecar_mobile/modulos/valuacion/valuacion.dart';
import 'package:carecar_mobile/nucleo/camara/selector_foto.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/silueta_auto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../ayudas/auditoria_accesibilidad.dart';
import '../../ayudas/tema_pista.dart';
import 'ayudas_valuacion.dart';

const _pantalla = PantallaFotosValuacion(valuacionId: 1);

void _pantallaDeFotos(WidgetTester tester) {
  tester.view.physicalSize = const Size(800, 12000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

Future<void> _montar(
  WidgetTester tester,
  RepositorioValuacionFake repo, {
  SelectorFalso? selector,
  Escenario escenario = Escenario.claro,
}) async {
  _pantallaDeFotos(tester);
  await tester.pumpWidget(
    app(
      _pantalla,
      repositorio: repo,
      selector: selector ?? SelectorFalso(),
      escenario: escenario,
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('las 8 tomas en orden, con silueta, instruccion y avance', (
    tester,
  ) async {
    await _montar(
      tester,
      RepositorioValuacionFake(
        valuaciones: [
          valuacion(fotos: [foto(TomaValuacion.frente)]),
        ],
      ),
    );

    const nombres = [
      '1. Frente',
      '2. Trasera',
      '3. Lateral izquierdo',
      '4. Lateral derecho',
      '5. Interior delantero',
      '6. Interior trasero',
      '7. Tablero con el kilometraje',
      '8. Cajuela',
    ];
    var anterior = 0.0;
    for (final nombre in nombres) {
      final y = tester.getTopLeft(find.text(nombre)).dy;
      expect(y, greaterThan(anterior), reason: nombre);
      anterior = y;
    }
    expect(find.byType(SiluetaToma), findsNWidgets(8));
    // Los dos laterales reutilizan la silueta del sistema.
    expect(find.byType(SiluetaAuto), findsNWidgets(2));
    expect(find.textContaining('placas a la vista'), findsNWidgets(2));
    expect(find.text('1 de 8 fotos'), findsOneWidget);
    expect(find.text('Tomar foto'), findsNWidgets(8));
    expect(find.text('Elegir de la galería'), findsNWidgets(8));
    expect(find.byType(Image), findsOneWidget);
  });

  testWidgets('tomar una foto sube solo esa toma y se puede repetir', (
    tester,
  ) async {
    final repo = RepositorioValuacionFake(valuaciones: [valuacion()]);
    final selector = SelectorFalso();
    await _montar(tester, repo, selector: selector);

    await tester.tap(find.text('Tomar foto').at(1));
    await tester.pumpAndSettle();

    expect(selector.pedidos, [OrigenFoto.camara]);
    expect(repo.subidas, [TomaValuacion.trasera]);
    expect(find.text('1 de 8 fotos'), findsOneWidget);

    await tester.tap(find.text('Elegir de la galería').at(1));
    await tester.pumpAndSettle();

    expect(selector.pedidos, [OrigenFoto.camara, OrigenFoto.galeria]);
    expect(repo.subidas, [TomaValuacion.trasera, TomaValuacion.trasera]);
    expect(find.text('1 de 8 fotos'), findsOneWidget);
  });

  testWidgets('sube la foto ya enderezada, no la que dio la camara', (
    tester,
  ) async {
    _pantallaDeFotos(tester);
    final repo = _RepoQueAnota(valuaciones: [valuacion()]);
    final derecha = FotoElegida(bytes: pixel, tipo: 'image/png');
    await tester.pumpWidget(
      app(
        _pantalla,
        repositorio: repo,
        selector: SelectorFalso(),
        extra: [enderezarFotoProvider.overrideWithValue((_) async => derecha)],
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Tomar foto').first);
    await tester.pumpAndSettle();

    expect(repo.tipos, ['image/png']);
  });

  testWidgets('un 413 por tamano explica el limite y conserva la foto', (
    tester,
  ) async {
    final repo = RepositorioValuacionFake(valuaciones: [valuacion()]);
    await _montar(tester, repo);

    repo.falla = const ErrorDelServidor('x', status: 413);
    await tester.tap(find.text('Tomar foto').first);
    await tester.pumpAndSettle();

    expect(find.textContaining('de hasta 8 MB'), findsOneWidget);
    expect(find.text('Reintentar'), findsOneWidget);
  });

  testWidgets('cancelar la camara no sube nada', (tester) async {
    final repo = RepositorioValuacionFake(valuaciones: [valuacion()]);
    await _montar(tester, repo, selector: SelectorFalso(cancela: true));

    await tester.tap(find.text('Tomar foto').first);
    await tester.pumpAndSettle();

    expect(repo.subidas, isEmpty);
  });

  testWidgets('si falla se conserva con Reintentar y las demas no se pierden', (
    tester,
  ) async {
    final repo = RepositorioValuacionFake(
      valuaciones: [
        valuacion(fotos: [foto(TomaValuacion.frente)]),
      ],
    );
    await _montar(tester, repo);

    repo.falla = const SinConexion();
    await tester.tap(find.text('Tomar foto').at(1));
    await tester.pumpAndSettle();

    expect(find.text('Sin conexión. La foto sigue aquí.'), findsOneWidget);
    expect(find.byType(Image), findsNWidgets(2));
    expect(find.text('Reintentar'), findsOneWidget);
    expect(find.text('1 de 8 fotos'), findsOneWidget);

    repo.falla = null;
    await tester.tap(find.text('Reintentar'));
    await tester.pumpAndSettle();

    expect(repo.subidas, [TomaValuacion.trasera]);
    expect(find.text('2 de 8 fotos'), findsOneWidget);
    expect(find.text('Reintentar'), findsNothing);
  });

  testWidgets('mientras sube lo anuncia y no deja repetir esa toma', (
    tester,
  ) async {
    final repo = _RepoLento(valuaciones: [valuacion()]);
    await _montar(tester, repo);

    await tester.tap(find.text('Tomar foto').first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Subiendo la foto'), findsOneWidget);

    repo.llegar.complete();
    await tester.pumpAndSettle();
    expect(find.text('Subiendo la foto'), findsNothing);
    expect(find.text('1 de 8 fotos'), findsOneWidget);
  });

  testWidgets('sin permiso de camara explica y abre los ajustes', (
    tester,
  ) async {
    final selector = SelectorFalso(negado: true);
    await _montar(
      tester,
      RepositorioValuacionFake(valuaciones: [valuacion()]),
      selector: selector,
    );

    await tester.tap(find.text('Tomar foto').first);
    await tester.pumpAndSettle();
    expect(find.textContaining('Sin permiso para la cámara'), findsOneWidget);

    await tester.tap(find.text('Abrir ajustes'));
    expect(selector.ajustesAbiertos, 1);
  });

  testWidgets('una valuacion cerrada no tiene acciones para subir', (
    tester,
  ) async {
    await _montar(tester, RepositorioValuacionFake(valuaciones: [ofertada()]));

    expect(find.text('Esta valuación ya no admite fotos.'), findsOneWidget);
    expect(find.text('Tomar foto'), findsNothing);
    expect(find.text('Elegir de la galería'), findsNothing);
  });

  testWidgets('si se cierra con la pantalla abierta lo explica y recarga', (
    tester,
  ) async {
    final repo = RepositorioValuacionFake(valuaciones: [valuacion()]);
    await _montar(tester, repo);
    repo.valuaciones = [ofertada()];

    await tester.tap(find.text('Tomar foto').first);
    await tester.pumpAndSettle();

    expect(repo.subidas, isEmpty);
    expect(find.text('Esta valuación ya no admite fotos.'), findsOneWidget);
    expect(find.text('Tomar foto'), findsNothing);
  });

  testWidgets('sin conexion al abrir deja reintentar', (tester) async {
    final repo = RepositorioValuacionFake(
      valuaciones: [valuacion()],
      falla: const SinConexion(),
    );
    await _montar(tester, repo);
    expect(find.text('Sin conexión'), findsOneWidget);

    repo.falla = null;
    await tester.tap(find.text('Reintentar'));
    await tester.pumpAndSettle();
    expect(find.text('1. Frente'), findsOneWidget);
  });

  testWidgets('una ajena se explica como no encontrada', (tester) async {
    await _montar(tester, RepositorioValuacionFake());
    expect(find.text('No encontramos esa valuación'), findsOneWidget);
  });

  testWidgets('claro, oscuro y letra al 200 % con las guias', (tester) async {
    for (final escenario in Escenario.values) {
      await _montar(
        tester,
        RepositorioValuacionFake(
          valuaciones: [
            valuacion(fotos: [foto(TomaValuacion.frente)]),
          ],
        ),
        escenario: escenario,
      );
      expect(tester.takeException(), isNull, reason: escenario.name);
      expect(find.text('1. Frente'), findsOneWidget);
      await auditarAccesibilidad(tester);
    }
  });
}

class _RepoQueAnota extends RepositorioValuacionFake {
  _RepoQueAnota({super.valuaciones});

  final tipos = <String>[];

  @override
  Future<Valuacion> subirFoto({
    required int valuacionId,
    required TomaValuacion toma,
    required List<int> bytes,
    required String tipo,
  }) {
    tipos.add(tipo);
    return super.subirFoto(
      valuacionId: valuacionId,
      toma: toma,
      bytes: bytes,
      tipo: tipo,
    );
  }
}

class _RepoLento extends RepositorioValuacionFake {
  _RepoLento({super.valuaciones});

  final llegar = Completer<void>();

  @override
  Future<Valuacion> subirFoto({
    required int valuacionId,
    required TomaValuacion toma,
    required List<int> bytes,
    required String tipo,
  }) async {
    await llegar.future;
    return super.subirFoto(
      valuacionId: valuacionId,
      toma: toma,
      bytes: bytes,
      tipo: tipo,
    );
  }
}
