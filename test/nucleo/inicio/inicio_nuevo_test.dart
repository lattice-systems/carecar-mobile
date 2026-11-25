import 'package:carecar_mobile/l10n/idiomas.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/barra_flotante.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/boton_accion_flotante.dart';
import 'package:carecar_mobile/nucleo/inicio/inicio_nuevo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _march = AutoInicio(
  modelo: 'March',
  anio: 2020,
  marca: 'Nissan',
  placas: 'XYZ-123',
  kilometraje: 24300,
);

Future<List<String>> _montar(
  WidgetTester tester, {
  Brightness brillo = Brightness.light,
  double letra = 1,
  String? nombre = 'Maria Elena Robles',
  List<AutoInicio>? autos = const [_march],
  CitaInicio? cita,
  bool esperar = true,
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
        autos: autos,
        proximaCita: cita,
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
  // Con el esqueleto de carga la animación no termina nunca.
  await (esperar ? tester.pumpAndSettle() : tester.pump());
  return toques;
}

/// Desliza la lista para sacar el contenido de detrás del botón y la barra
/// flotantes (en pruebas la letra es más ancha que la real).
Future<void> _subir(WidgetTester tester) async {
  await tester.drag(find.byType(ListView), const Offset(0, -260));
  await tester.pumpAndSettle();
}

void main() {
  group('InicioNuevo (rediseño de navegación)', () {
    testWidgets('saluda por el primer nombre y muestra los accesos', (
      tester,
    ) async {
      await _montar(tester);

      expect(find.text('Hola, Maria'), findsOneWidget);
      expect(find.text('Mis vehículos'), findsOneWidget);
      expect(find.text('Catálogo'), findsWidgets);
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

      await _subir(tester);
      await tester.tap(find.text('Mis vehículos'));
      await tester.tap(find.text('Catálogo').first);

      expect(toques, ['vehiculos', 'catalogo']);
    });

    testWidgets('el auto del cliente es el protagonista y abre sus vehículos', (
      tester,
    ) async {
      final toques = await _montar(tester);

      expect(find.text('March 2020'), findsOneWidget);
      expect(find.text('Nissan'), findsOneWidget);
      expect(find.text('XYZ-123'), findsOneWidget);
      expect(find.text('24.300 km'), findsOneWidget);

      await tester.tap(find.text('March 2020'));
      expect(toques, ['vehiculos']);
    });

    testWidgets('con varios autos se desliza y avisa la posición', (
      tester,
    ) async {
      await _montar(
        tester,
        autos: const [
          _march,
          AutoInicio(modelo: 'Versa', anio: 2022),
        ],
      );

      expect(find.bySemanticsLabel(RegExp('Auto 1 de 2')), findsOneWidget);
      await tester.drag(find.text('March 2020'), const Offset(-300, 0));
      await tester.pumpAndSettle();
      expect(find.text('Versa 2022'), findsOneWidget);
    });

    testWidgets('mientras cargan los autos no muestra vacío ni cita', (
      tester,
    ) async {
      await _montar(tester, autos: null, esperar: false);

      expect(find.text('Aún no tienes autos registrados'), findsNothing);
      expect(find.text('No tienes citas por venir'), findsNothing);
    });

    testWidgets(
      'sin autos invita a esperar el registro; sin citas, a agendar',
      (tester) async {
        final toques = await _montar(tester, autos: const []);

        expect(find.text('Aún no tienes autos registrados'), findsOneWidget);
        expect(find.text('No tienes citas por venir'), findsOneWidget);
        await _subir(tester);
        await tester.tap(find.text('Agenda la próxima revisión de tu auto'));
        expect(toques, ['agendar']);
      },
    );

    testWidgets('la próxima cita muestra día, hora y auto y abre Citas', (
      tester,
    ) async {
      final toques = await _montar(
        tester,
        cita: CitaInicio(
          fecha: DateTime(2026, 11, 28),
          hora: '10:00',
          vehiculo: 'March 2020',
        ),
      );

      expect(find.text('Próxima cita'), findsOneWidget);
      expect(find.text('Sábado, 10:00'), findsOneWidget);
      expect(find.text('28'), findsOneWidget);
      await _subir(tester);
      await tester.tap(find.text('Sábado, 10:00'));
      expect(toques, ['citas']);
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
