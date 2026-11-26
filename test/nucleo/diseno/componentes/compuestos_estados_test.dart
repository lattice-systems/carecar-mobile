import 'package:carecar_mobile/nucleo/diseno/componentes/estado_error.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/estado_vacio.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/esqueleto.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/fila_lista.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/tarjeta_metrica.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/tono.dart';
import 'package:carecar_mobile/nucleo/diseno/tokens/colores.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../ayudas/tema_pista.dart';

void main() {
  group('EstadoVacio', () {
    testWidgets('se ve en los tres escenarios sin desbordar', (tester) async {
      for (final escenario in Escenario.values) {
        await tester.pumpWidget(
          conTemaPista(
            EstadoVacio(
              titulo: 'Aun no tienes citas',
              mensaje: 'Agenda tu primera cita de servicio.',
              textoAccion: 'Agendar cita',
              alAccion: () {},
            ),
            escenario: escenario,
          ),
        );
        expect(find.text('Aun no tienes citas'), findsOneWidget);
        expect(find.text('Agendar cita'), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('sin accion no muestra boton', (tester) async {
      await tester.pumpWidget(
        conTemaPista(const EstadoVacio(titulo: 'Nada por aqui')),
      );
      expect(find.byType(OutlinedButton), findsNothing);
    });

    testWidgets('la accion responde al toque', (tester) async {
      var veces = 0;
      await tester.pumpWidget(
        conTemaPista(
          EstadoVacio(
            titulo: 'Nada por aqui',
            textoAccion: 'Crear',
            alAccion: () => veces++,
          ),
        ),
      );
      await tester.tap(find.text('Crear'));
      expect(veces, 1);
    });
  });

  group('EstadoError', () {
    testWidgets('se ve en los tres escenarios sin desbordar', (tester) async {
      for (final escenario in Escenario.values) {
        await tester.pumpWidget(
          conTemaPista(EstadoError(alReintentar: () {}), escenario: escenario),
        );
        expect(find.text('No pudimos cargar esto'), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('sin conexion cambia texto e icono', (tester) async {
      await tester.pumpWidget(
        conTemaPista(
          EstadoError(causa: CausaError.sinConexion, alReintentar: () {}),
        ),
      );
      expect(find.text('Sin conexión'), findsOneWidget);
      expect(find.byIcon(Icons.wifi_off), findsOneWidget);
    });

    testWidgets('los textos por omisión siguen el idioma de la app', (
      tester,
    ) async {
      await tester.pumpWidget(
        conTemaPista(
          EstadoError(causa: CausaError.sinConexion, alReintentar: () {}),
          idioma: const Locale('en'),
        ),
      );
      expect(find.text('No connection'), findsOneWidget);
      expect(find.text('Check your internet and try again.'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
      expect(find.text('Sin conexión'), findsNothing);
    });

    testWidgets('reintentar llama al callback', (tester) async {
      var veces = 0;
      await tester.pumpWidget(
        conTemaPista(EstadoError(alReintentar: () => veces++)),
      );
      await tester.tap(find.text('Reintentar'));
      expect(veces, 1);
    });

    testWidgets('acepta titulo y mensaje propios', (tester) async {
      await tester.pumpWidget(
        conTemaPista(
          EstadoError(
            titulo: 'Citas no disponibles',
            mensaje: 'Vuelve mas tarde.',
            alReintentar: () {},
          ),
        ),
      );
      expect(find.text('Citas no disponibles'), findsOneWidget);
      expect(find.text('Vuelve mas tarde.'), findsOneWidget);
    });
  });

  group('Esqueleto', () {
    testWidgets('se ve en los tres escenarios', (tester) async {
      for (final escenario in Escenario.values) {
        await tester.pumpWidget(
          conTemaPista(
            const Column(
              children: [
                Esqueleto(alto: 120),
                Esqueleto.linea(),
                Esqueleto.circulo(diametro: 40),
              ],
            ),
            escenario: escenario,
          ),
        );
        await tester.pump(const Duration(milliseconds: 300));
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('late y con reducir movimiento se queda quieto', (
      tester,
    ) async {
      await tester.pumpWidget(conTemaPista(const Esqueleto()));
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.hasRunningAnimations, isTrue);

      await tester.pumpWidget(
        conTemaPista(
          const MediaQuery(
            data: MediaQueryData(disableAnimations: true),
            child: Esqueleto(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.hasRunningAnimations, isFalse);
    });

    testWidgets('no aparece en la semantica', (tester) async {
      final semantica = tester.ensureSemantics();
      await tester.pumpWidget(conTemaPista(const Esqueleto()));
      await tester.pump();
      expect(find.semantics.byLabel(RegExp('.')), findsNothing);
      semantica.dispose();
    });
  });

  group('TarjetaMetrica', () {
    testWidgets('muestra cifra y etiqueta en los tres escenarios', (
      tester,
    ) async {
      for (final escenario in Escenario.values) {
        await tester.pumpWidget(
          conTemaPista(
            const TarjetaMetrica(
              cifra: '12 400 km',
              etiqueta: 'Recorrido del mes',
              detalle: 'vs. mes anterior',
            ),
            escenario: escenario,
          ),
        );
        expect(find.text('12 400 km'), findsOneWidget);
        expect(find.text('Recorrido del mes'), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('con tono suma el icono del tono', (tester) async {
      await tester.pumpWidget(
        conTemaPista(
          const TarjetaMetrica(
            cifra: '3',
            etiqueta: 'Alertas',
            tono: Tono.advertencia,
          ),
        ),
      );
      expect(
        find.byIcon(
          ColoresTono.de(Tono.advertencia, PaletaColores.claro).icono,
        ),
        findsOneWidget,
      );
    });

    testWidgets('se anuncia como un solo texto', (tester) async {
      await tester.pumpWidget(
        conTemaPista(const TarjetaMetrica(cifra: '3', etiqueta: 'Alertas')),
      );
      expect(find.bySemanticsLabel('Alertas: 3'), findsOneWidget);
    });

    testWidgets('una cifra larga se reduce y no desborda', (tester) async {
      await tester.pumpWidget(
        conTemaPista(
          const TarjetaMetrica(
            cifra: r'$1 234 567 890.00',
            etiqueta: 'Gasto total',
          ),
          ancho: 160,
          escenario: Escenario.letraGrande,
        ),
      );
      expect(tester.takeException(), isNull);
    });
  });

  group('FilaLista', () {
    testWidgets('se ve en los tres escenarios sin desbordar', (tester) async {
      for (final escenario in Escenario.values) {
        await tester.pumpWidget(
          conTemaPista(
            FilaLista(
              titulo: 'Mazda CX-5 2024',
              subtitulo: 'Proximo servicio en 1 200 km',
              inicio: const Icon(Icons.directions_car),
              fin: const Text('Ok'),
              alToque: () {},
            ),
            escenario: escenario,
          ),
        );
        expect(find.text('Mazda CX-5 2024'), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('mide al menos 48 de alto y responde al toque', (tester) async {
      var veces = 0;
      await tester.pumpWidget(
        conTemaPista(FilaLista(titulo: 'Citas', alToque: () => veces++)),
      );
      expect(
        tester.getSize(find.byType(FilaLista)).height,
        greaterThanOrEqualTo(48),
      );
      await tester.tap(find.text('Citas'));
      expect(veces, 1);
    });

    testWidgets('sin toque no muestra chevron', (tester) async {
      await tester.pumpWidget(conTemaPista(const FilaLista(titulo: 'Citas')));
      expect(find.byIcon(Icons.chevron_right_rounded), findsNothing);
    });

    testWidgets('se anuncia como boton con titulo y subtitulo', (tester) async {
      await tester.pumpWidget(
        conTemaPista(
          FilaLista(titulo: 'Citas', subtitulo: '2 proximas', alToque: () {}),
        ),
      );
      expect(find.bySemanticsLabel('Citas. 2 proximas'), findsOneWidget);
    });
  });
}
