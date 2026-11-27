import 'package:carecar_mobile/l10n/idiomas.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/barra_flotante.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/boton_accion_flotante.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/cuadro_fecha.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/tono.dart';
import 'package:carecar_mobile/nucleo/inicio/inicio_nuevo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _march = AutoInicio(
  id: 5,
  modelo: 'March',
  anio: 2020,
  marca: 'Nissan',
  placas: 'XYZ-123',
  kilometraje: 24300,
);

const _versa = AutoInicio(id: 6, modelo: 'Versa', anio: 2022);

Future<List<String>> _montar(
  WidgetTester tester, {
  Brightness brillo = Brightness.light,
  double letra = 1,
  String? nombre = 'Maria Elena Robles',
  List<AutoInicio>? autos = const [_march],
  CitaInicio? cita,
  bool conServicio = false,
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
        alAbrirVehiculos: () => toques.add('vehiculos'),
        alAbrirCitas: () => toques.add('citas'),
        alAbrirCatalogo: () => toques.add('catalogo'),
        alAbrirAjustes: () => toques.add('ajustes'),
        alAgendar: () => toques.add('agendar'),
        ordenEnCurso: const SizedBox(key: Key('orden'), height: 80),
        servicioDelAuto: conServicio
            ? (id) => SizedBox(
                key: Key('servicio-$id'),
                height: 80,
                child: Text('Servicio del auto $id'),
              )
            : null,
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
    testWidgets('saluda por el primer nombre y muestra lo del taller', (
      tester,
    ) async {
      await _montar(tester);

      expect(find.text('Hola, Maria'), findsOneWidget);
      expect(find.byKey(const Key('orden')), findsOneWidget);
    });

    testWidgets('sin nombre aún no muestra saludo ni falla', (tester) async {
      await _montar(tester, nombre: null);

      expect(find.textContaining('Hola'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'los destinos viven solo en la barra: el cuerpo no los repite',
      (tester) async {
        await _montar(tester);
        await _subir(tester);

        // Antes el cuerpo traía tres accesos redondos con los mismos destinos
        // que la barra. Cada nombre debe aparecer una sola vez, en la barra.
        for (final destino in ['Vehículos', 'Citas', 'Catálogo']) {
          expect(find.text(destino), findsOneWidget, reason: destino);
          expect(
            find.descendant(
              of: find.byType(BarraFlotante),
              matching: find.text(destino),
            ),
            findsOneWidget,
            reason: destino,
          );
        }
        expect(find.text('Mis vehículos'), findsNothing);
        expect(find.text('Conoce los modelos Nissan'), findsNothing);
      },
    );

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

    testWidgets('el auto del cliente es el protagonista y abre sus vehículos', (
      tester,
    ) async {
      final toques = await _montar(tester);

      expect(find.text('March 2020'), findsOneWidget);
      expect(find.text('Nissan'), findsOneWidget);
      expect(find.text('XYZ-123'), findsOneWidget);
      expect(find.text('24,300 km'), findsOneWidget);

      await tester.tap(find.text('March 2020'));
      expect(toques, ['vehiculos']);
    });

    testWidgets('la marca no se repite cuando el modelo ya la trae', (
      tester,
    ) async {
      await _montar(
        tester,
        autos: const [
          AutoInicio(
            id: 5,
            modelo: 'Nissan March Sense',
            anio: 2020,
            marca: 'Nissan',
          ),
        ],
      );

      expect(find.text('Nissan March Sense 2020'), findsOneWidget);
      expect(find.text('Nissan'), findsNothing);
    });

    testWidgets('con varios autos se desliza y avisa la posición', (
      tester,
    ) async {
      await _montar(tester, autos: const [_march, _versa]);

      expect(find.bySemanticsLabel(RegExp('Auto 1 de 2')), findsOneWidget);
      await tester.drag(find.text('March 2020'), const Offset(-300, 0));
      await tester.pumpAndSettle();
      expect(find.text('Versa 2022'), findsOneWidget);
    });

    testWidgets('el próximo servicio sigue al auto que se está viendo', (
      tester,
    ) async {
      await _montar(tester, autos: const [_march, _versa], conServicio: true);

      expect(find.text('Servicio del auto 5'), findsOneWidget);
      expect(find.text('Servicio del auto 6'), findsNothing);

      await tester.drag(find.text('March 2020'), const Offset(-300, 0));
      await tester.pumpAndSettle();

      expect(find.text('Servicio del auto 6'), findsOneWidget);
      expect(find.text('Servicio del auto 5'), findsNothing);
    });

    testWidgets('sin autos, o mientras cargan, no hay próximo servicio', (
      tester,
    ) async {
      await _montar(tester, autos: const [], conServicio: true);
      expect(find.textContaining('Servicio del auto'), findsNothing);

      await _montar(tester, autos: null, conServicio: true, esperar: false);
      expect(find.textContaining('Servicio del auto'), findsNothing);
    });

    testWidgets(
      'la cita va antes que el servicio; sin cita, la invitación al final',
      (tester) async {
        await _montar(
          tester,
          conServicio: true,
          cita: CitaInicio(fecha: DateTime(2026, 11, 28), hora: '10:00'),
        );
        final citaY = tester.getTopLeft(find.text('Próxima cita')).dy;
        final servicioY = tester
            .getTopLeft(find.text('Servicio del auto 5'))
            .dy;
        expect(citaY, lessThan(servicioY));

        // Lo vacío nunca se pone por encima de lo que sí hay.
        await _montar(tester, conServicio: true);
        final servicio = tester.getTopLeft(find.text('Servicio del auto 5')).dy;
        final invitacion = tester
            .getTopLeft(find.text('No tienes citas por venir'))
            .dy;
        expect(servicio, lessThan(invitacion));
      },
    );

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

    testWidgets(
      'el cuadro de la fecha va en el tono de una cita confirmada, como en Mis citas',
      (tester) async {
        await _montar(
          tester,
          cita: CitaInicio(
            fecha: DateTime(2026, 11, 28),
            hora: '10:00',
            vehiculo: 'March 2020',
          ),
        );

        expect(
          tester.widget<CuadroFecha>(find.byType(CuadroFecha)).tono,
          Tono.exito,
        );
      },
    );

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
      await _montar(
        tester,
        brillo: Brightness.dark,
        letra: 2,
        conServicio: true,
      );

      expect(find.text('Hola, Maria'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
