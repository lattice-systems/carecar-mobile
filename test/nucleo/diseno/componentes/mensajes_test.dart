import 'package:carecar_mobile/nucleo/diseno/componentes/burbuja_mensaje.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/campo_mensaje.dart';
import 'package:carecar_mobile/nucleo/diseno/tokens/colores.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../ayudas/tema_pista.dart';

Color? _fondoBurbuja(WidgetTester tester) {
  final caja = tester.widget<DecoratedBox>(
    find.byKey(const ValueKey('burbuja-mensaje-fondo')),
  );
  return (caja.decoration as BoxDecoration).color;
}

void main() {
  group('BurbujaMensaje (V2-T02.15)', () {
    testWidgets('la propia va a la derecha con el acento', (tester) async {
      await tester.pumpWidget(
        conTemaPista(
          const BurbujaMensaje(
            texto: 'Hola',
            autor: AutorMensaje.propio,
            nombreAutor: 'Tú',
          ),
        ),
      );
      final burbuja = tester.getRect(
        find.byKey(const ValueKey('burbuja-mensaje-fondo')),
      );
      expect(burbuja.right, closeTo(360, 0.5));
      expect(burbuja.left, greaterThan(0));
      expect(_fondoBurbuja(tester), PaletaColores.claro.acento);
    });

    testWidgets('la ajena va a la izquierda en una superficie', (tester) async {
      await tester.pumpWidget(
        conTemaPista(
          const BurbujaMensaje(
            texto: 'Hola, ¿en qué te ayudo?',
            autor: AutorMensaje.ajeno,
            nombreAutor: 'CareCar',
          ),
        ),
      );
      final burbuja = tester.getRect(
        find.byKey(const ValueKey('burbuja-mensaje-fondo')),
      );
      expect(burbuja.left, closeTo(0, 0.5));
      expect(_fondoBurbuja(tester), PaletaColores.claro.superficieHundida);
    });

    testWidgets('no ocupa más del 80 % del ancho', (tester) async {
      await tester.pumpWidget(
        conTemaPista(
          BurbujaMensaje(
            texto: 'Un mensaje largo ' * 20,
            autor: AutorMensaje.ajeno,
            nombreAutor: 'CareCar',
          ),
        ),
      );
      final ancho = tester
          .getSize(find.byKey(const ValueKey('burbuja-mensaje-fondo')))
          .width;
      expect(ancho, lessThanOrEqualTo(360 * 0.8 + 0.5));
    });

    testWidgets('el lector de pantalla dice quién habla y la hora', (
      tester,
    ) async {
      final semantica = tester.ensureSemantics();
      await tester.pumpWidget(
        conTemaPista(
          const BurbujaMensaje(
            texto: '¿Cada cuánto cambio el aceite?',
            autor: AutorMensaje.propio,
            nombreAutor: 'Tú',
            hora: '10:42',
          ),
        ),
      );
      expect(
        find.bySemanticsLabel('Tú: ¿Cada cuánto cambio el aceite?, 10:42'),
        findsOneWidget,
      );
      semantica.dispose();
    });

    testWidgets('las fuentes se tocan con al menos 48 de alto', (tester) async {
      final semantica = tester.ensureSemantics();
      var abiertas = 0;
      await tester.pumpWidget(
        conTemaPista(
          BurbujaMensaje(
            texto: 'Cada 10 000 km o un año.',
            autor: AutorMensaje.ajeno,
            nombreAutor: 'CareCar',
            fuentes: [
              FuenteMensaje(
                texto: 'Manual, pág. 214',
                etiquetaLector: 'Manual, página 214, abrir',
                alTocar: () => abiertas++,
              ),
            ],
          ),
        ),
      );
      final fuente = find.text('Manual, pág. 214');
      expect(fuente, findsOneWidget);
      expect(
        tester.getSize(find.byKey(const ValueKey('fuente-mensaje-0'))).height,
        greaterThanOrEqualTo(48),
      );
      expect(
        find.bySemanticsLabel('Manual, página 214, abrir'),
        findsOneWidget,
      );
      await tester.tap(fuente);
      expect(abiertas, 1);
      semantica.dispose();
    });

    testWidgets('enviando lo dice debajo de la burbuja', (tester) async {
      await tester.pumpWidget(
        conTemaPista(
          const BurbujaMensaje(
            texto: 'Hola',
            autor: AutorMensaje.propio,
            nombreAutor: 'Tú',
            estado: EstadoEnvio.enviando,
          ),
        ),
      );
      expect(find.text('Enviando…'), findsOneWidget);
    });

    testWidgets('fallido avisa y deja reintentar', (tester) async {
      var reintentos = 0;
      await tester.pumpWidget(
        conTemaPista(
          BurbujaMensaje(
            texto: 'Hola',
            autor: AutorMensaje.propio,
            nombreAutor: 'Tú',
            estado: EstadoEnvio.fallido,
            alReintentar: () => reintentos++,
          ),
        ),
      );
      expect(find.text('No se envió'), findsOneWidget);
      final reintentar = find.text('Reintentar');
      expect(
        tester.getSize(find.byKey(const ValueKey('reintentar-mensaje'))).height,
        greaterThanOrEqualTo(48),
      );
      await tester.tap(reintentar);
      expect(reintentos, 1);
    });

    testWidgets('se ve en los tres escenarios sin desbordar', (tester) async {
      for (final escenario in Escenario.values) {
        await tester.pumpWidget(
          conTemaPista(
            Column(
              children: [
                const BurbujaMensaje(
                  texto: '¿Qué significa la luz naranja del motor?',
                  autor: AutorMensaje.propio,
                  nombreAutor: 'Tú',
                  hora: '10:42',
                  estado: EstadoEnvio.enviado,
                ),
                BurbujaMensaje(
                  texto:
                      'Es el testigo de revisión del motor. Agenda una cita.',
                  autor: AutorMensaje.ajeno,
                  nombreAutor: 'CareCar',
                  hora: '10:42',
                  fuentes: [
                    FuenteMensaje(texto: 'Manual, pág. 214', alTocar: () {}),
                  ],
                ),
              ],
            ),
            escenario: escenario,
          ),
        );
        expect(tester.takeException(), isNull);
      }
    });
  });

  group('CampoMensaje (V2-T02.15)', () {
    Finder enviar() => find.byKey(const ValueKey('campo-mensaje-enviar'));

    testWidgets('sin texto no deja enviar', (tester) async {
      await tester.pumpWidget(conTemaPista(CampoMensaje(alEnviar: (_) {})));
      expect(tester.widget<IconButton>(enviar()).onPressed, isNull);

      await tester.enterText(find.byType(TextField), '   ');
      await tester.pump();
      expect(tester.widget<IconButton>(enviar()).onPressed, isNull);
    });

    testWidgets('envía el texto sin espacios de más y se vacía', (
      tester,
    ) async {
      final enviados = <String>[];
      await tester.pumpWidget(
        conTemaPista(CampoMensaje(alEnviar: enviados.add)),
      );
      await tester.enterText(find.byType(TextField), '  Hola  ');
      await tester.pump();
      await tester.tap(enviar());
      await tester.pump();
      expect(enviados, ['Hola']);
      expect(find.text('Hola'), findsNothing);
    });

    testWidgets('crece hasta cinco líneas y ahí se detiene', (tester) async {
      await tester.pumpWidget(conTemaPista(CampoMensaje(alEnviar: (_) {})));
      final campo = find.byType(TextField);
      final alto1 = tester.getSize(campo).height;

      await tester.enterText(campo, List.filled(5, 'línea').join('\n'));
      await tester.pump();
      final alto5 = tester.getSize(campo).height;

      await tester.enterText(campo, List.filled(10, 'línea').join('\n'));
      await tester.pump();
      final alto10 = tester.getSize(campo).height;

      expect(alto5, greaterThan(alto1));
      expect(alto10, alto5);
    });

    testWidgets('adjuntar solo aparece si hay a quién avisar', (tester) async {
      await tester.pumpWidget(conTemaPista(CampoMensaje(alEnviar: (_) {})));
      expect(
        find.byKey(const ValueKey('campo-mensaje-adjuntar')),
        findsNothing,
      );

      var adjuntos = 0;
      await tester.pumpWidget(
        conTemaPista(
          CampoMensaje(alEnviar: (_) {}, alAdjuntar: () => adjuntos++),
        ),
      );
      await tester.tap(find.byKey(const ValueKey('campo-mensaje-adjuntar')));
      expect(adjuntos, 1);
    });

    testWidgets('los botones miden al menos 48 y tienen nombre', (
      tester,
    ) async {
      final semantica = tester.ensureSemantics();
      await tester.pumpWidget(
        conTemaPista(CampoMensaje(alEnviar: (_) {}, alAdjuntar: () {})),
      );
      for (final clave in ['campo-mensaje-enviar', 'campo-mensaje-adjuntar']) {
        final tam = tester.getSize(find.byKey(ValueKey(clave)));
        expect(tam.width, greaterThanOrEqualTo(48));
        expect(tam.height, greaterThanOrEqualTo(48));
      }
      expect(find.bySemanticsLabel('Enviar'), findsOneWidget);
      expect(find.bySemanticsLabel('Adjuntar'), findsOneWidget);
      semantica.dispose();
    });

    testWidgets('deshabilitado no deja escribir ni enviar', (tester) async {
      await tester.pumpWidget(
        conTemaPista(CampoMensaje(alEnviar: (_) {}, habilitado: false)),
      );
      expect(tester.widget<TextField>(find.byType(TextField)).enabled, isFalse);
      expect(tester.widget<IconButton>(enviar()).onPressed, isNull);
    });

    testWidgets('se ve en los tres escenarios sin desbordar', (tester) async {
      for (final escenario in Escenario.values) {
        await tester.pumpWidget(
          conTemaPista(
            CampoMensaje(alEnviar: (_) {}, alAdjuntar: () {}),
            escenario: escenario,
          ),
        );
        expect(tester.takeException(), isNull);
      }
    });
  });
}
