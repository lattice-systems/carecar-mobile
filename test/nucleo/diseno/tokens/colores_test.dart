import 'package:carecar_mobile/nucleo/diseno/tokens/colores.dart';
import 'package:carecar_mobile/nucleo/diseno/tokens/contraste.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('valores del documento', () {
    test('claro', () {
      final p = PaletaColores.claro;
      expect(p.fondo, const Color(0xFFF6F7F9));
      expect(p.superficie, const Color(0xFFFFFFFF));
      expect(p.superficieHundida, const Color(0xFFEEF0F3));
      expect(p.borde, const Color(0xFFE3E6EB));
      expect(p.texto, const Color(0xFF0B0D12));
      expect(p.acento, const Color(0xFF2457F5));
      expect(p.marca, const Color(0xFF1D3557));
    });

    test('oscuro', () {
      final p = PaletaColores.oscuro;
      expect(p.fondo, const Color(0xFF0A0B0E));
      expect(p.superficie, const Color(0xFF14161B));
      expect(p.superficieElevada, const Color(0xFF1C1F26));
      expect(p.texto, const Color(0xFFF3F4F6));
      expect(p.acento, const Color(0xFF5B8CFF));
      expect(p.sobreAcento, const Color(0xFF0A0B0E));
    });

    test('el velo cambia de opacidad entre claro y oscuro', () {
      expect(PaletaColores.claro.velo.a, closeTo(0.48, 0.01));
      expect(PaletaColores.oscuro.velo.a, closeTo(0.64, 0.01));
    });
  });

  group('contraste AA', () {
    for (final entrada in {
      'claro': PaletaColores.claro,
      'oscuro': PaletaColores.oscuro,
    }.entries) {
      final p = entrada.value;
      final modo = entrada.key;

      final pares = <String, (Color, Color)>{
        'texto sobre fondo': (p.texto, p.fondo),
        'texto sobre superficie': (p.texto, p.superficie),
        'texto sobre superficie elevada': (p.texto, p.superficieElevada),
        'texto sobre superficie hundida': (p.texto, p.superficieHundida),
        'texto secundario sobre fondo': (p.textoSecundario, p.fondo),
        'texto secundario sobre superficie': (p.textoSecundario, p.superficie),
        'sobre acento sobre acento': (p.sobreAcento, p.acento),
        'acento sobre superficie': (p.acento, p.superficie),
        'acento sobre fondo': (p.acento, p.fondo),
        'marca sobre superficie': (p.marca, p.superficie),
        'exito sobre superficie': (p.exito, p.superficie),
        'advertencia sobre superficie': (p.advertencia, p.superficie),
        'peligro sobre superficie': (p.peligro, p.superficie),
        'exito sobre su fondo suave': (p.exito, p.exitoSuave),
        'advertencia sobre su fondo suave': (p.advertencia, p.advertenciaSuave),
        'peligro sobre su fondo suave': (p.peligro, p.peligroSuave),
        'acento sobre su fondo suave': (p.acento, p.acentoSuave),
        'texto secundario sobre superficie elevada': (
          p.textoSecundario,
          p.superficieElevada,
        ),
        'texto secundario sobre superficie hundida': (
          p.textoSecundario,
          p.superficieHundida,
        ),
        'sobre acento sobre peligro': (p.sobreAcento, p.peligro),
        'texto sobre fondo suave de exito': (p.texto, p.exitoSuave),
        'texto sobre fondo suave de advertencia': (p.texto, p.advertenciaSuave),
        'texto sobre fondo suave de peligro': (p.texto, p.peligroSuave),
        'texto sobre fondo suave de acento': (p.texto, p.acentoSuave),
        'acento sobre superficie elevada': (p.acento, p.superficieElevada),
        'peligro sobre superficie elevada': (p.peligro, p.superficieElevada),
        'advertencia sobre superficie elevada': (
          p.advertencia,
          p.superficieElevada,
        ),
        'exito sobre superficie elevada': (p.exito, p.superficieElevada),
      };

      for (final par in pares.entries) {
        test('$modo: ${par.key}', () {
          final (primer, segundo) = par.value;
          expect(
            Contraste.razon(primer, segundo),
            greaterThanOrEqualTo(Contraste.minimoTexto),
          );
        });
      }
    }
  });

  group('contraste de componentes (3 a 1, WCAG 1.4.11)', () {
    for (final entrada in {
      'claro': PaletaColores.claro,
      'oscuro': PaletaColores.oscuro,
    }.entries) {
      final p = entrada.value;
      final modo = entrada.key;

      final pares = <String, (Color, Color)>{
        'contorno de control sobre superficie': (
          p.contornoControl,
          p.superficie,
        ),
        'contorno de control sobre fondo': (p.contornoControl, p.fondo),
        'contorno de control sobre superficie elevada': (
          p.contornoControl,
          p.superficieElevada,
        ),
        'acento sobre superficie hundida': (p.acento, p.superficieHundida),
      };

      for (final par in pares.entries) {
        test('$modo: ${par.key}', () {
          final (primer, segundo) = par.value;
          expect(
            Contraste.razon(primer, segundo),
            greaterThanOrEqualTo(Contraste.minimoTextoGrande),
          );
        });
      }
    }

    test('el borde decorativo no se usa como contorno de control', () {
      // `borde` queda bajo 3 a 1 a proposito: solo divide, no delimita.
      expect(
        Contraste.razon(
          PaletaColores.claro.borde,
          PaletaColores.claro.superficie,
        ),
        lessThan(Contraste.minimoTextoGrande),
      );
    });
  });

  test('las variantes suaves se mezclan sobre la superficie', () {
    final p = PaletaColores.claro;
    expect(p.exitoSuave, isNot(p.superficie));
    expect(p.exitoSuave.a, 1);
  });

  test('copyWith y lerp conservan el resto de los valores', () {
    final cambiada = PaletaColores.claro.copyWith(
      acento: const Color(0xFFFF0000),
    );
    expect(cambiada.acento, const Color(0xFFFF0000));
    expect(cambiada.fondo, PaletaColores.claro.fondo);

    final mitad = PaletaColores.claro.lerp(PaletaColores.oscuro, 0);
    expect(mitad.fondo, PaletaColores.claro.fondo);
    final fin = PaletaColores.claro.lerp(PaletaColores.oscuro, 1);
    expect(fin.fondo, PaletaColores.oscuro.fondo);
  });
}
