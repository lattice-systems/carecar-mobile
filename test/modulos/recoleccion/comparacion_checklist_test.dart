import 'dart:convert';

import 'package:carecar_mobile/api/excepciones.dart';
import 'package:carecar_mobile/api/modelos/traslado.dart';
import 'package:carecar_mobile/l10n/idiomas.dart';
import 'package:carecar_mobile/modulos/recoleccion/datos/repositorio_recoleccion_fake.dart';
import 'package:carecar_mobile/modulos/recoleccion/dominio/recoleccion_agendada.dart';
import 'package:carecar_mobile/modulos/recoleccion/presentacion/pantalla_checklist_traslado.dart';
import 'package:carecar_mobile/modulos/recoleccion/presentacion/proveedores_recoleccion.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/comparacion_antes_despues.dart';
import 'package:carecar_mobile/nucleo/diseno/tema_pista.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

// PNG de 1x1 para no tocar la red.
final _png = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==',
);

ChecklistTraslado _checklist(
  int id, {
  int km = 45200,
  NivelGasolina gasolina = NivelGasolina.medio,
  int fotos = 2,
}) => ChecklistTraslado(
  trasladoId: id,
  km: km,
  gasolina: gasolina,
  fotos: [for (var i = 0; i < fotos; i++) 'https://x/$id-$i.jpg'],
  registradoEn: DateTime.utc(2026, 12, 1, 13, 10),
);

RepositorioRecoleccionFake _repo({
  bool recoger = true,
  bool entregar = true,
  int fotosRecoger = 2,
  int fotosEntregar = 2,
  Object? error,
}) => RepositorioRecoleccionFake(
  error: error,
  checklists: {
    if (recoger) 5: _checklist(5, fotos: fotosRecoger),
    if (entregar)
      6: _checklist(
        6,
        km: 45230,
        gasolina: NivelGasolina.lleno,
        fotos: fotosEntregar,
      ),
  },
);

Future<void> _montar(
  WidgetTester tester, {
  required RepositorioRecoleccionFake repo,
  TipoTraslado tipo = TipoTraslado.recoger,
  bool verComparacion = false,
  Size tamano = const Size(800, 2400),
  double escala = 1,
  Brightness brillo = Brightness.light,
}) async {
  tester.view.physicalSize = tamano;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        repositorioRecoleccionProvider.overrideWithValue(repo),
        imagenDeChecklistProvider.overrideWithValue((_) => MemoryImage(_png)),
      ],
      child: MaterialApp(
        theme: brillo == Brightness.dark
            ? TemaPista.oscuro()
            : TemaPista.claro(),
        locale: const Locale('es'),
        localizationsDelegates: delegadasDeIdioma,
        supportedLocales: idiomasSoportados,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(escala),
            disableAnimations: true,
          ),
          child: child!,
        ),
        home: PantallaChecklistTraslado(
          trasladoId: tipo == TipoTraslado.recoger ? 5 : 6,
          trasladoContrarioId: tipo == TipoTraslado.recoger ? 6 : 5,
          tipo: tipo,
          verComparacion: verComparacion,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('abre en el checklist del traslado tocado, con tres pestanas', (
    tester,
  ) async {
    await _montar(tester, repo: _repo());

    expect(find.text('Al recoger'), findsOneWidget);
    expect(find.text('Al entregar'), findsOneWidget);
    expect(find.text('Comparar'), findsOneWidget);
    expect(find.text('45.200 km'), findsOneWidget);
    expect(find.text('45.230 km'), findsNothing);
  });

  testWidgets('abre en Al entregar cuando se toco el traslado de entregar', (
    tester,
  ) async {
    await _montar(tester, repo: _repo(), tipo: TipoTraslado.entregar);

    expect(find.text('45.230 km'), findsOneWidget);
    expect(find.text('45.200 km'), findsNothing);
  });

  testWidgets('alternar a Al entregar muestra el otro checklist', (
    tester,
  ) async {
    await _montar(tester, repo: _repo());

    await tester.tap(find.text('Al entregar'));
    await tester.pumpAndSettle();

    expect(find.text('45.230 km'), findsOneWidget);
    expect(find.text('Tanque lleno'), findsOneWidget);
  });

  testWidgets('Comparar pone km, gasolina y fotos lado a lado', (tester) async {
    await _montar(tester, repo: _repo());

    await tester.tap(find.text('Comparar'));
    await tester.pumpAndSettle();

    expect(
      find.text('45.200 km al recoger, 45.230 km al entregar'),
      findsOneWidget,
    );
    expect(find.text('30 km'), findsOneWidget);
    expect(
      find.text('Medio tanque al recoger, Tanque lleno al entregar'),
      findsOneWidget,
    );
    expect(find.byType(ComparacionAntesDespues), findsNWidgets(2));
  });

  testWidgets('con distinto numero de fotos compara las primeras y avisa', (
    tester,
  ) async {
    await _montar(
      tester,
      repo: _repo(fotosRecoger: 4, fotosEntregar: 3),
      verComparacion: true,
    );

    expect(find.byType(ComparacionAntesDespues), findsNWidgets(3));
    expect(
      find.text(
        'Hay 4 fotos al recoger y 3 al entregar; se comparan las primeras 3.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('sin fotos en uno de los dos lo dice y no dibuja comparaciones', (
    tester,
  ) async {
    await _montar(tester, repo: _repo(fotosEntregar: 0), verComparacion: true);

    expect(find.byType(ComparacionAntesDespues), findsNothing);
    expect(
      find.text('Alguno de los dos checklists no trae fotos para comparar.'),
      findsOneWidget,
    );
  });

  testWidgets('un 404 del checklist de entregar se explica', (tester) async {
    await _montar(tester, repo: _repo(entregar: false), verComparacion: true);

    expect(find.text('Aún no se puede comparar'), findsOneWidget);
    expect(
      find.textContaining('todavía no registra el checklist de entregar'),
      findsOneWidget,
    );
    expect(find.byType(ComparacionAntesDespues), findsNothing);
  });

  testWidgets('un 404 del checklist de recoger se explica', (tester) async {
    await _montar(tester, repo: _repo(recoger: false), verComparacion: true);

    expect(
      find.textContaining('todavía no registra el checklist de recoger'),
      findsOneWidget,
    );
  });

  testWidgets('sin ninguno de los dos checklists tambien se explica', (
    tester,
  ) async {
    await _montar(
      tester,
      repo: _repo(recoger: false, entregar: false),
      verComparacion: true,
    );

    expect(
      find.textContaining('ningún checklist de esta recolección'),
      findsOneWidget,
    );
  });

  testWidgets('la pestana de un lado sin checklist usa el vacio de siempre', (
    tester,
  ) async {
    await _montar(tester, repo: _repo(entregar: false));

    await tester.tap(find.text('Al entregar'));
    await tester.pumpAndSettle();

    expect(find.text('Aún no hay checklist'), findsOneWidget);
  });

  testWidgets('sin conexion en Comparar ofrece reintentar', (tester) async {
    await _montar(
      tester,
      repo: _repo(error: const SinConexion()),
      verComparacion: true,
    );

    expect(find.text('Reintentar'), findsOneWidget);
  });

  testWidgets('las pestanas se anuncian y la comparacion es un deslizador', (
    tester,
  ) async {
    final manejador = tester.ensureSemantics();
    await _montar(tester, repo: _repo(), verComparacion: true);

    expect(find.bySemanticsLabel(RegExp('Comparar.*3 de 3')), findsWidgets);
    expect(
      find.bySemanticsLabel(RegExp('Foto 1 de 2 al recoger')),
      findsWidgets,
    );
    manejador.dispose();
  });

  testWidgets('sin comparacion pedida la pantalla se comporta como siempre', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          repositorioRecoleccionProvider.overrideWithValue(_repo()),
          imagenDeChecklistProvider.overrideWithValue((_) => MemoryImage(_png)),
        ],
        child: MaterialApp(
          theme: TemaPista.claro(),
          locale: const Locale('es'),
          localizationsDelegates: delegadasDeIdioma,
          supportedLocales: idiomasSoportados,
          home: const PantallaChecklistTraslado(trasladoId: 5),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Comparar'), findsNothing);
    expect(find.text('45.200 km'), findsOneWidget);
  });

  testWidgets('aguanta letra al 200 % en pantalla chica y en oscuro', (
    tester,
  ) async {
    await _montar(
      tester,
      repo: _repo(),
      verComparacion: true,
      tamano: const Size(320, 568),
      escala: 2,
      brillo: Brightness.dark,
    );

    expect(tester.takeException(), isNull);
    expect(find.text('Comparar'), findsWidgets);
  });
}
