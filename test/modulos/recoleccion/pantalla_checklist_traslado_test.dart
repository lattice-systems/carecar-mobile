import 'dart:async';
import 'dart:convert';

import 'package:carecar_mobile/api/excepciones.dart';
import 'package:carecar_mobile/api/modelos/traslado.dart';
import 'package:carecar_mobile/l10n/idiomas.dart';
import 'package:carecar_mobile/modulos/recoleccion/datos/repositorio_recoleccion_fake.dart';
import 'package:carecar_mobile/modulos/recoleccion/presentacion/pantalla_checklist_traslado.dart';
import 'package:carecar_mobile/modulos/recoleccion/presentacion/proveedores_recoleccion.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/firma.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/galeria_fotos.dart';
import 'package:carecar_mobile/nucleo/diseno/tema_pista.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

// PNG de 1x1 para no tocar la red.
final _png = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==',
);

ChecklistTraslado _checklist({
  NivelGasolina gasolina = NivelGasolina.medio,
  String? notas = 'Rayón en la salpicadera',
  List<String> fotos = const ['https://x/f1.jpg?firma=a', 'https://x/f2.jpg'],
  String? firma = 'https://x/firma.png?firma=c',
}) => ChecklistTraslado(
  trasladoId: 5,
  km: 45200,
  gasolina: gasolina,
  notas: notas,
  fotos: fotos,
  firmaUrl: firma,
  registradoEn: DateTime.utc(2026, 12, 1, 13, 10),
);

Future<RepositorioRecoleccionFake> _montar(
  WidgetTester tester, {
  RepositorioRecoleccionFake? repo,
  Brightness brillo = Brightness.light,
  Size tamano = const Size(800, 1800),
  double escala = 1,
  bool esperar = true,
}) async {
  tester.view.physicalSize = tamano;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final fake =
      repo ?? RepositorioRecoleccionFake(checklists: {5: _checklist()});
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        repositorioRecoleccionProvider.overrideWithValue(fake),
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
        home: const PantallaChecklistTraslado(trasladoId: 5),
      ),
    ),
  );
  if (esperar) await tester.pumpAndSettle();
  return fake;
}

void main() {
  testWidgets('muestra km, gasolina, notas, fotos y firma', (tester) async {
    await _montar(tester);

    expect(find.text('45.200 km'), findsOneWidget);
    expect(find.text('Medio tanque'), findsOneWidget);
    expect(find.text('Rayón en la salpicadera'), findsOneWidget);
    expect(find.byType(GaleriaFotos), findsOneWidget);
    expect(find.text('1 de 2'), findsOneWidget);
    expect(find.byType(Firma), findsOneWidget);
  });

  testWidgets('el indicador de gasolina llena los cuartos que son', (
    tester,
  ) async {
    await _montar(
      tester,
      repo: RepositorioRecoleccionFake(
        checklists: {5: _checklist(gasolina: NivelGasolina.tresCuartos)},
      ),
    );

    Finder segmentos(String tipo) => find.byWidgetPredicate(
      (w) =>
          w.key is ValueKey<String> &&
          (w.key! as ValueKey<String>).value.startsWith(tipo),
    );
    expect(segmentos('gasolina_llena'), findsNWidgets(3));
    expect(segmentos('gasolina_vacia'), findsOneWidget);
  });

  testWidgets('la gasolina se anuncia con palabras, no con color', (
    tester,
  ) async {
    final manejador = tester.ensureSemantics();
    await _montar(tester);

    expect(
      find.bySemanticsLabel(RegExp('Gasolina.*Medio tanque')),
      findsOneWidget,
    );
    manejador.dispose();
  });

  testWidgets('cada foto trae su descripcion para el lector de pantalla', (
    tester,
  ) async {
    final manejador = tester.ensureSemantics();
    await _montar(tester);

    expect(
      find.bySemanticsLabel(RegExp('Foto 1 de 2 del estado del auto')),
      findsWidgets,
    );
    manejador.dispose();
  });

  testWidgets('sin notas, fotos ni firma no inventa secciones vacias', (
    tester,
  ) async {
    await _montar(
      tester,
      repo: RepositorioRecoleccionFake(
        checklists: {5: _checklist(notas: null, fotos: const [], firma: null)},
      ),
    );

    expect(find.text('Notas del chofer'), findsNothing);
    expect(find.byType(Firma), findsNothing);
    expect(find.text('Este checklist no trae fotos.'), findsOneWidget);
  });

  testWidgets('404 explica que aun no hay checklist', (tester) async {
    await _montar(tester, repo: RepositorioRecoleccionFake());

    expect(find.text('Aún no hay checklist'), findsOneWidget);
    expect(find.textContaining('El chofer lo registra'), findsOneWidget);
    expect(find.byType(GaleriaFotos), findsNothing);
  });

  testWidgets('cargando muestra un esqueleto anunciado', (tester) async {
    final espera = Completer<void>();
    final manejador = tester.ensureSemantics();
    await _montar(
      tester,
      repo: RepositorioRecoleccionFake(
        checklists: {5: _checklist()},
        espera: espera.future,
      ),
      esperar: false,
    );
    await tester.pump();

    expect(
      find.bySemanticsLabel('Cargando el checklist del auto'),
      findsOneWidget,
    );
    espera.complete();
    await tester.pumpAndSettle();
    manejador.dispose();
  });

  testWidgets('sin conexion ofrece reintentar', (tester) async {
    await _montar(
      tester,
      repo: RepositorioRecoleccionFake(error: const SinConexion()),
    );

    expect(find.text('Reintentar'), findsOneWidget);
  });

  testWidgets('cada apertura pide un checklist nuevo', (tester) async {
    final repo = await _montar(tester);
    expect(repo.consultasChecklist, 1);

    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
    await _montar(tester, repo: repo);

    expect(repo.consultasChecklist, 2);
  });

  testWidgets('aguanta letra al 200 % en pantalla chica y en oscuro', (
    tester,
  ) async {
    await _montar(
      tester,
      brillo: Brightness.dark,
      tamano: const Size(320, 568),
      escala: 2,
    );

    expect(tester.takeException(), isNull);
    expect(find.text('Checklist del auto'), findsWidgets);
  });
}
