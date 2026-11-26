import 'package:carecar_mobile/nucleo/diseno/componentes/campo_texto.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/control_binario.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lucide_icons_flutter/lucide_icons_300.dart';

import '../../../ayudas/tema_pista.dart';

void main() {
  group('CampoTexto', () {
    testWidgets('muestra etiqueta y avisa lo escrito', (tester) async {
      String? ultimo;
      await tester.pumpWidget(
        conTemaPista(
          CampoTexto(etiqueta: 'Correo', alCambiar: (v) => ultimo = v),
        ),
      );
      expect(find.text('Correo'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'ana@mail.com');
      expect(ultimo, 'ana@mail.com');
    });

    testWidgets('la ayuda se ve sin error', (tester) async {
      await tester.pumpWidget(
        conTemaPista(const CampoTexto(etiqueta: 'Correo', ayuda: 'Tu correo')),
      );
      expect(find.text('Tu correo'), findsOneWidget);
    });

    testWidgets('el error reemplaza a la ayuda y lleva icono', (tester) async {
      await tester.pumpWidget(
        conTemaPista(
          const CampoTexto(
            etiqueta: 'Correo',
            ayuda: 'Tu correo',
            error: 'Escribe un correo valido',
          ),
        ),
      );
      expect(find.text('Escribe un correo valido'), findsOneWidget);
      expect(find.text('Tu correo'), findsNothing);
      expect(find.byIcon(LucideIcons300.circleAlert), findsOneWidget);
    });

    testWidgets('deshabilitado no deja escribir', (tester) async {
      await tester.pumpWidget(
        conTemaPista(const CampoTexto(etiqueta: 'Correo', habilitado: false)),
      );
      expect(tester.widget<TextField>(find.byType(TextField)).enabled, isFalse);
    });

    testWidgets('mide al menos 48 de alto', (tester) async {
      await tester.pumpWidget(
        conTemaPista(const CampoTexto(etiqueta: 'Correo')),
      );
      expect(
        tester.getSize(find.byType(TextField)).height,
        greaterThanOrEqualTo(48),
      );
    });

    testWidgets('no desborda en los tres escenarios con error', (tester) async {
      for (final escenario in Escenario.values) {
        await tester.pumpWidget(
          conTemaPista(
            const CampoTexto(
              etiqueta: 'Correo electronico de contacto',
              error: 'Escribe un correo valido para poder avisarte',
            ),
            escenario: escenario,
          ),
        );
        expect(tester.takeException(), isNull);
      }
    });
  });

  group('CampoContrasena', () {
    testWidgets('empieza oculta y el boton la muestra', (tester) async {
      await tester.pumpWidget(
        conTemaPista(const CampoContrasena(etiqueta: 'Contraseña')),
      );
      TextField campo() => tester.widget<TextField>(find.byType(TextField));
      expect(campo().obscureText, isTrue);
      await tester.tap(find.byTooltip('Mostrar contraseña'));
      await tester.pump();
      expect(campo().obscureText, isFalse);
      expect(find.byTooltip('Ocultar contraseña'), findsOneWidget);
    });

    testWidgets('el boton de ver mide 48', (tester) async {
      await tester.pumpWidget(
        conTemaPista(const CampoContrasena(etiqueta: 'Contraseña')),
      );
      final tamano = tester.getSize(find.byType(IconButton));
      expect(tamano.width, greaterThanOrEqualTo(48));
      expect(tamano.height, greaterThanOrEqualTo(48));
    });
  });

  group('Casilla', () {
    testWidgets('tocar la etiqueta cambia el valor', (tester) async {
      bool? recibido;
      await tester.pumpWidget(
        conTemaPista(
          Casilla(
            etiqueta: 'Acepto',
            valor: false,
            alCambiar: (v) => recibido = v,
          ),
        ),
      );
      await tester.tap(find.text('Acepto'));
      expect(recibido, isTrue);
    });

    testWidgets('sin alCambiar no responde', (tester) async {
      await tester.pumpWidget(
        conTemaPista(
          const Casilla(etiqueta: 'Acepto', valor: false, alCambiar: null),
        ),
      );
      expect(tester.widget<InkWell>(find.byType(InkWell)).onTap, isNull);
    });

    testWidgets('la fila mide al menos 48', (tester) async {
      await tester.pumpWidget(
        conTemaPista(
          Casilla(etiqueta: 'Acepto', valor: true, alCambiar: (_) {}),
        ),
      );
      expect(
        tester.getSize(find.byType(Casilla)).height,
        greaterThanOrEqualTo(48),
      );
    });

    testWidgets('avisa su estado marcado en un solo nodo', (tester) async {
      final semantica = tester.ensureSemantics();
      await tester.pumpWidget(
        conTemaPista(
          Casilla(etiqueta: 'Acepto', valor: true, alCambiar: (_) {}),
        ),
      );
      expect(
        tester.getSemantics(find.byType(Casilla)),
        isSemantics(
          label: 'Acepto',
          hasCheckedState: true,
          isChecked: true,
          hasEnabledState: true,
          isEnabled: true,
          hasTapAction: true,
        ),
      );
      semantica.dispose();
    });
  });

  group('Interruptor', () {
    testWidgets('tocar la fila cambia el valor', (tester) async {
      bool? recibido;
      await tester.pumpWidget(
        conTemaPista(
          Interruptor(
            etiqueta: 'Avisos',
            descripcion: 'Citas y taller',
            valor: true,
            alCambiar: (v) => recibido = v,
          ),
        ),
      );
      await tester.tap(find.text('Avisos'));
      expect(recibido, isFalse);
      expect(find.text('Citas y taller'), findsOneWidget);
    });

    testWidgets('la etiqueta semantica incluye la descripcion', (tester) async {
      final semantica = tester.ensureSemantics();
      await tester.pumpWidget(
        conTemaPista(
          Interruptor(
            etiqueta: 'Avisos',
            descripcion: 'Citas y taller',
            valor: true,
            alCambiar: (_) {},
          ),
        ),
      );
      expect(find.bySemanticsLabel('Avisos. Citas y taller'), findsOneWidget);
      semantica.dispose();
    });

    testWidgets('no desborda en los tres escenarios', (tester) async {
      for (final escenario in Escenario.values) {
        await tester.pumpWidget(
          conTemaPista(
            Interruptor(
              etiqueta: 'Recibir avisos de mi cita y del taller',
              descripcion: 'Te avisamos cuando tu auto este listo',
              valor: true,
              alCambiar: (_) {},
            ),
            escenario: escenario,
          ),
        );
        expect(tester.takeException(), isNull);
      }
    });
  });

  group('Selector', () {
    const opciones = [
      OpcionSelector(valor: 1, texto: 'Servicio'),
      OpcionSelector(valor: 2, texto: 'Garantia'),
    ];

    testWidgets('elegir una opcion avisa su valor', (tester) async {
      int? elegido;
      await tester.pumpWidget(
        conTemaPista(
          Selector<int>(
            etiqueta: 'Motivo',
            opciones: opciones,
            valor: null,
            alCambiar: (v) => elegido = v,
          ),
        ),
      );
      await tester.tap(find.byType(DropdownButtonFormField<int>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Garantia').last);
      await tester.pumpAndSettle();
      expect(elegido, 2);
    });

    testWidgets('muestra la opcion actual', (tester) async {
      await tester.pumpWidget(
        conTemaPista(
          Selector<int>(
            etiqueta: 'Motivo',
            opciones: opciones,
            valor: 1,
            alCambiar: (_) {},
          ),
        ),
      );
      expect(find.text('Servicio'), findsOneWidget);
    });

    testWidgets('con error lo muestra con icono', (tester) async {
      await tester.pumpWidget(
        conTemaPista(
          Selector<int>(
            etiqueta: 'Motivo',
            opciones: opciones,
            valor: null,
            alCambiar: (_) {},
            error: 'Elige un motivo',
          ),
        ),
      );
      expect(find.text('Elige un motivo'), findsOneWidget);
      expect(find.byIcon(LucideIcons300.circleAlert), findsOneWidget);
    });

    testWidgets('no desborda en los tres escenarios', (tester) async {
      for (final escenario in Escenario.values) {
        await tester.pumpWidget(
          conTemaPista(
            Selector<int>(
              etiqueta: 'Motivo de tu visita',
              opciones: const [
                OpcionSelector(
                  valor: 1,
                  texto: 'Servicio de mantenimiento programado',
                ),
              ],
              valor: 1,
              alCambiar: (_) {},
            ),
            escenario: escenario,
          ),
        );
        expect(tester.takeException(), isNull);
      }
    });
  });
}
