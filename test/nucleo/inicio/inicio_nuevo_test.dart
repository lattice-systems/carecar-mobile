import 'package:carecar_mobile/l10n/idiomas.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/barra_flotante.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/boton_accion_flotante.dart';
import 'package:carecar_mobile/nucleo/inicio/inicio_nuevo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<List<String>> _montar(
  WidgetTester tester, {
  Brightness brillo = Brightness.light,
  double letra = 1,
  String? nombre = 'Maria Elena Robles',
}) async {
  final toques = <String>[];
  tester.platformDispatcher.platformBrightnessTestValue = brillo;
  tester.platformDispatcher.textScaleFactorTestValue = letra;
  addTearDown(tester.platformDispatcher.clearAllTestValues);
  tester.view.physicalSize = const Size(360, 740);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: delegadasDeIdioma,
      supportedLocales: idiomasSoportados,
      locale: const Locale('es'),
      home: InicioNuevo(
        nombre: nombre,
        alAbrirAjustes: () => toques.add('ajustes'),
        alAgendar: () => toques.add('agendar'),
        accesos: [
          AccesoInicio(
            titulo: 'Mis vehículos',
            subtitulo: 'Tus autos, fichas y manuales',
            icono: Icons.directions_car_outlined,
            alPulsar: () => toques.add('vehiculos'),
          ),
          AccesoInicio(
            titulo: 'Citas',
            subtitulo: 'Agenda y revisa tus citas',
            icono: Icons.calendar_month_outlined,
            alPulsar: () => toques.add('citas'),
          ),
          AccesoInicio(
            titulo: 'Catálogo',
            subtitulo: 'Conoce los modelos Nissan',
            icono: Icons.grid_view_outlined,
            alPulsar: () => toques.add('catalogo'),
          ),
        ],
        ordenEnCurso: const SizedBox(key: Key('orden'), height: 80),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return toques;
}

void main() {
  group('InicioNuevo (rediseño de navegación)', () {
    testWidgets('saluda por el primer nombre y muestra los accesos', (
      tester,
    ) async {
      await _montar(tester);

      expect(find.text('Hola, Maria'), findsOneWidget);
      expect(find.text('Tus autos, fichas y manuales'), findsOneWidget);
      expect(find.text('Agenda y revisa tus citas'), findsOneWidget);
      expect(find.byKey(const Key('orden')), findsOneWidget);
    });

    testWidgets('sin nombre aún no muestra saludo ni falla', (tester) async {
      await _montar(tester, nombre: null);

      expect(find.textContaining('Hola'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'la barra flotante tiene Inicio activo y lleva a cada destino',
      (tester) async {
        final toques = await _montar(tester);

        expect(find.byType(BarraFlotante), findsOneWidget);
        await tester.tap(
          find.descendant(
            of: find.byType(BarraFlotante),
            matching: find.text('Vehículos'),
          ),
        );
        await tester.tap(
          find.descendant(
            of: find.byType(BarraFlotante),
            matching: find.text('Citas'),
          ),
        );
        await tester.tap(
          find.descendant(
            of: find.byType(BarraFlotante),
            matching: find.text('Catálogo'),
          ),
        );

        expect(toques, ['vehiculos', 'citas', 'catalogo']);
      },
    );

    testWidgets('tocar Inicio en la barra no navega', (tester) async {
      final toques = await _montar(tester);

      await tester.tap(
        find.descendant(
          of: find.byType(BarraFlotante),
          matching: find.text('Inicio'),
        ),
      );

      expect(toques, isEmpty);
    });

    testWidgets('los accesos de la lista abren su destino', (tester) async {
      final toques = await _montar(tester);

      await tester.tap(find.text('Tus autos, fichas y manuales'));
      await tester.tap(find.text('Conoce los modelos Nissan'));

      expect(toques, ['vehiculos', 'catalogo']);
    });

    testWidgets('el botón flotante agenda y el avatar abre ajustes', (
      tester,
    ) async {
      final toques = await _montar(tester);

      await tester.tap(find.byType(BotonAccionFlotante));
      await tester.tap(find.byTooltip('Perfil y ajustes'));

      expect(toques, ['agendar', 'ajustes']);
    });

    testWidgets('se ve en oscuro y con letra grande sin desbordar', (
      tester,
    ) async {
      await _montar(tester, brillo: Brightness.dark, letra: 2);

      expect(find.text('Hola, Maria'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
