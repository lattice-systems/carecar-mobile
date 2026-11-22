import 'package:carecar_mobile/nucleo/diseno/tema_pista.dart';
import 'package:carecar_mobile/nucleo/diseno/tokens/colores.dart';
import 'package:carecar_mobile/nucleo/diseno/tokens/tokens_pista.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('el tema claro usa Material 3 y trae los tokens claros', () {
    final tema = TemaPista.claro();
    expect(tema.useMaterial3, isTrue);
    expect(tema.brightness, Brightness.light);
    expect(tema.extension<TokensPista>(), TokensPista.claro);
  });

  test('el tema oscuro trae los tokens oscuros', () {
    final tema = TemaPista.oscuro();
    expect(tema.brightness, Brightness.dark);
    expect(tema.extension<TokensPista>(), TokensPista.oscuro);
  });

  test('el esquema de color sale de la paleta', () {
    final p = PaletaColores.claro;
    final esquema = TemaPista.claro().colorScheme;
    expect(esquema.primary, p.acento);
    expect(esquema.onPrimary, p.sobreAcento);
    expect(esquema.surface, p.superficie);
    expect(esquema.onSurface, p.texto);
    expect(esquema.error, p.peligro);
    expect(esquema.outline, p.borde);
  });

  test('el lienzo es el fondo de la paleta', () {
    expect(TemaPista.claro().scaffoldBackgroundColor, PaletaColores.claro.fondo);
    expect(TemaPista.oscuro().scaffoldBackgroundColor, PaletaColores.oscuro.fondo);
  });

  test('el texto del tema usa la tipografia v2', () {
    final tema = TemaPista.claro();
    expect(tema.textTheme.bodyLarge!.fontSize, 16);
    expect(tema.textTheme.headlineLarge!.fontSize, 28);
    expect(tema.textTheme.displayLarge!.fontSize, 40);
    expect(tema.textTheme.labelSmall!.fontSize, 11);
  });

  test('los objetivos tactiles minimos son de 48', () {
    final tema = TemaPista.claro();
    expect(tema.materialTapTargetSize, MaterialTapTargetSize.padded);
  });

  testWidgets('un widget de Material hereda el tema', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: TemaPista.claro(),
        darkTheme: TemaPista.oscuro(),
        themeMode: ThemeMode.dark,
        home: const Scaffold(body: Text('hola')),
      ),
    );
    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    expect(scaffold.backgroundColor, isNull);
    final contexto = tester.element(find.byType(Scaffold));
    expect(
      Theme.of(contexto).scaffoldBackgroundColor,
      PaletaColores.oscuro.fondo,
    );
  });
}
