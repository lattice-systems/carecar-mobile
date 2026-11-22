import 'package:carecar_mobile/nucleo/diseno/tokens/colores.dart';
import 'package:carecar_mobile/nucleo/diseno/tokens/tokens_pista.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('claro y oscuro traen su paleta', () {
    expect(TokensPista.claro.colores, PaletaColores.claro);
    expect(TokensPista.oscuro.colores, PaletaColores.oscuro);
    expect(TokensPista.claro.brillo, Brightness.light);
    expect(TokensPista.oscuro.brillo, Brightness.dark);
  });

  test('copyWith cambia solo lo pedido', () {
    final nuevo = TokensPista.claro.copyWith(colores: PaletaColores.oscuro);
    expect(nuevo.colores, PaletaColores.oscuro);
    expect(nuevo.brillo, Brightness.light);
  });

  test('lerp en los extremos devuelve cada lado', () {
    final inicio = TokensPista.claro.lerp(TokensPista.oscuro, 0);
    final fin = TokensPista.claro.lerp(TokensPista.oscuro, 1);
    expect(inicio.colores.fondo, PaletaColores.claro.fondo);
    expect(fin.colores.fondo, PaletaColores.oscuro.fondo);
  });

  test('lerp con otro tipo devuelve el mismo', () {
    expect(TokensPista.claro.lerp(null, 0.5), TokensPista.claro);
  });

  testWidgets('se obtiene desde el contexto', (tester) async {
    late TokensPista leidos;
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(extensions: [TokensPista.claro]),
        home: Builder(
          builder: (context) {
            leidos = TokensPista.de(context);
            return const SizedBox();
          },
        ),
      ),
    );
    expect(leidos.colores, PaletaColores.claro);
  });

  testWidgets('sin la extension falla con un mensaje claro', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            expect(() => TokensPista.de(context), throwsAssertionError);
            return const SizedBox();
          },
        ),
      ),
    );
  });

  test('la tipografia hereda el color del texto de la paleta', () {
    expect(
      TokensPista.claro.tipografia.cuerpo.color,
      PaletaColores.claro.texto,
    );
    expect(
      TokensPista.oscuro.tipografia.cuerpo.color,
      PaletaColores.oscuro.texto,
    );
  });
}
