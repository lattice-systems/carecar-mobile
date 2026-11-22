import 'package:carecar_mobile/nucleo/diseno/componentes/boton.dart';
import 'package:carecar_mobile/nucleo/diseno/tokens/colores.dart';
import 'package:carecar_mobile/nucleo/diseno/tokens/contraste.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../ayudas/tema_pista.dart';

ButtonStyle estiloDe(WidgetTester tester) {
  final boton = find.bySubtype<ButtonStyleButton>();
  return tester.widget<ButtonStyleButton>(boton).style!;
}

void main() {
  testWidgets('muestra su texto y llama a alPresionar', (tester) async {
    var toques = 0;
    await tester.pumpWidget(
      conTemaPista(Boton(texto: 'Agendar cita', alPresionar: () => toques++)),
    );
    expect(find.text('Agendar cita'), findsOneWidget);
    await tester.tap(find.byType(Boton));
    expect(toques, 1);
  });

  testWidgets('sin alPresionar queda deshabilitado', (tester) async {
    await tester.pumpWidget(
      conTemaPista(const Boton(texto: 'Agendar cita', alPresionar: null)),
    );
    final boton = tester.widget<ButtonStyleButton>(
      find.bySubtype<ButtonStyleButton>(),
    );
    expect(boton.enabled, isFalse);
  });

  testWidgets('cargando no responde y muestra el indicador', (tester) async {
    var toques = 0;
    await tester.pumpWidget(
      conTemaPista(
        Boton(texto: 'Guardar', cargando: true, alPresionar: () => toques++),
      ),
    );
    await tester.tap(find.byType(Boton), warnIfMissed: false);
    expect(toques, 0);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Guardar'), findsOneWidget);
  });

  testWidgets('cargando avisa al lector de pantalla', (tester) async {
    final semantica = tester.ensureSemantics();
    await tester.pumpWidget(
      conTemaPista(Boton(texto: 'Guardar', cargando: true, alPresionar: () {})),
    );
    expect(find.bySemanticsLabel('Guardar, cargando'), findsOneWidget);
    semantica.dispose();
  });

  testWidgets('con icono lo muestra junto al texto', (tester) async {
    await tester.pumpWidget(
      conTemaPista(
        Boton(texto: 'Llamar', icono: Icons.phone, alPresionar: () {}),
      ),
    );
    expect(find.byIcon(Icons.phone), findsOneWidget);
  });

  group('tamanos', () {
    final altos = {
      TamanoBoton.chico: 40.0,
      TamanoBoton.normal: 48.0,
      TamanoBoton.grande: 56.0,
    };
    for (final entrada in altos.entries) {
      testWidgets('${entrada.key.name} mide al menos ${entrada.value}', (
        tester,
      ) async {
        await tester.pumpWidget(
          conTemaPista(
            Boton(texto: 'Seguir', tamano: entrada.key, alPresionar: () {}),
          ),
        );
        final alto = tester.getSize(find.bySubtype<ButtonStyleButton>()).height;
        expect(alto, greaterThanOrEqualTo(entrada.value));
      });
    }

    testWidgets('todos dejan una zona tactil de 48', (tester) async {
      for (final tamano in TamanoBoton.values) {
        await tester.pumpWidget(
          conTemaPista(
            Boton(texto: 'Seguir', tamano: tamano, alPresionar: () {}),
          ),
        );
        final zona = tester.getSize(find.byType(Boton)).height;
        expect(zona, greaterThanOrEqualTo(48));
      }
    });
  });

  group('variantes', () {
    testWidgets('principal usa acento con texto sobre acento', (tester) async {
      await tester.pumpWidget(
        conTemaPista(Boton(texto: 'Ok', alPresionar: () {})),
      );
      final estilo = estiloDe(tester);
      expect(estilo.backgroundColor!.resolve({}), PaletaColores.claro.acento);
      expect(
        estilo.foregroundColor!.resolve({}),
        PaletaColores.claro.sobreAcento,
      );
    });

    testWidgets('peligro usa el color de peligro', (tester) async {
      await tester.pumpWidget(
        conTemaPista(
          Boton(
            texto: 'Cancelar cita',
            variante: VarianteBoton.peligro,
            alPresionar: () {},
          ),
        ),
      );
      expect(
        estiloDe(tester).backgroundColor!.resolve({}),
        PaletaColores.claro.peligro,
      );
    });

    testWidgets('secundario lleva borde y fondo transparente', (tester) async {
      await tester.pumpWidget(
        conTemaPista(
          Boton(
            texto: 'Ver',
            variante: VarianteBoton.secundario,
            alPresionar: () {},
          ),
        ),
      );
      final estilo = estiloDe(tester);
      expect(estilo.backgroundColor!.resolve({}), Colors.transparent);
      expect(estilo.side!.resolve({})!.color, PaletaColores.claro.borde);
    });

    testWidgets('terciario no lleva borde ni fondo', (tester) async {
      await tester.pumpWidget(
        conTemaPista(
          Boton(
            texto: 'Omitir',
            variante: VarianteBoton.terciario,
            alPresionar: () {},
          ),
        ),
      );
      final estilo = estiloDe(tester);
      expect(estilo.backgroundColor!.resolve({}), Colors.transparent);
      expect(estilo.side!.resolve({}), BorderSide.none);
    });

    testWidgets('deshabilitado baja a texto terciario sobre hundida', (
      tester,
    ) async {
      await tester.pumpWidget(
        conTemaPista(const Boton(texto: 'Ok', alPresionar: null)),
      );
      final estilo = estiloDe(tester);
      final estados = {WidgetState.disabled};
      expect(
        estilo.backgroundColor!.resolve(estados),
        PaletaColores.claro.superficieHundida,
      );
      expect(
        estilo.foregroundColor!.resolve(estados),
        PaletaColores.claro.textoTerciario,
      );
    });
  });

  group('contraste AA en ambos modos', () {
    for (final entrada in {
      'claro': PaletaColores.claro,
      'oscuro': PaletaColores.oscuro,
    }.entries) {
      final p = entrada.value;
      test('${entrada.key}: principal', () {
        expect(Contraste.cumpleAA(p.sobreAcento, p.acento), isTrue);
      });
      test('${entrada.key}: peligro', () {
        expect(Contraste.cumpleAA(p.sobreAcento, p.peligro), isTrue);
      });
      test('${entrada.key}: secundario y terciario', () {
        expect(Contraste.cumpleAA(p.acento, p.superficie), isTrue);
        expect(Contraste.cumpleAA(p.acento, p.fondo), isTrue);
      });
    }
  });

  group('escenarios del sistema', () {
    for (final escenario in Escenario.values) {
      for (final variante in VarianteBoton.values) {
        testWidgets('${variante.name} en ${escenario.name} no se desborda', (
          tester,
        ) async {
          await tester.pumpWidget(
            conTemaPista(
              Boton(
                texto: 'Agendar mi cita de servicio',
                icono: Icons.event,
                variante: variante,
                alPresionar: () {},
              ),
              escenario: escenario,
              ancho: 280,
            ),
          );
          expect(tester.takeException(), isNull);
        });
      }
    }
  });

  testWidgets('anchoCompleto ocupa todo el ancho disponible', (tester) async {
    await tester.pumpWidget(
      conTemaPista(
        Boton(texto: 'Seguir', anchoCompleto: true, alPresionar: () {}),
      ),
    );
    expect(tester.getSize(find.bySubtype<ButtonStyleButton>()).width, 360);
  });

  testWidgets('con teclado muestra el foco con borde de al menos 2', (
    tester,
  ) async {
    await tester.pumpWidget(
      conTemaPista(Boton(texto: 'Ok', alPresionar: () {})),
    );
    final foco = estiloDe(tester).side!.resolve({WidgetState.focused});
    expect(foco, isNotNull);
    expect(foco!.width, greaterThanOrEqualTo(2));
  });
}
