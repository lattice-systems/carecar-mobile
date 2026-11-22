import 'package:carecar_mobile/nucleo/diseno/tokens/tipografia.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  void verifica(
    TextStyle estilo, {
    required double tamano,
    required double interlineado,
    required FontWeight peso,
    required double tracking,
  }) {
    expect(estilo.fontSize, tamano);
    expect(estilo.height! * estilo.fontSize!, closeTo(interlineado, 0.001));
    expect(estilo.fontWeight, peso);
    expect(estilo.letterSpacing, closeTo(tamano * tracking, 0.0001));
  }

  final t = Tipografia.crear();

  test('la escala coincide con el documento', () {
    verifica(
      t.display,
      tamano: 40,
      interlineado: 44,
      peso: FontWeight.w600,
      tracking: -0.01,
    );
    verifica(
      t.titulo1,
      tamano: 28,
      interlineado: 34,
      peso: FontWeight.w600,
      tracking: -0.005,
    );
    verifica(
      t.titulo2,
      tamano: 22,
      interlineado: 28,
      peso: FontWeight.w600,
      tracking: 0,
    );
    verifica(
      t.titulo3,
      tamano: 18,
      interlineado: 24,
      peso: FontWeight.w600,
      tracking: 0,
    );
    verifica(
      t.cuerpo,
      tamano: 16,
      interlineado: 24,
      peso: FontWeight.w400,
      tracking: 0,
    );
    verifica(
      t.cuerpoFuerte,
      tamano: 16,
      interlineado: 24,
      peso: FontWeight.w500,
      tracking: 0,
    );
    verifica(
      t.cuerpoChico,
      tamano: 14,
      interlineado: 20,
      peso: FontWeight.w400,
      tracking: 0,
    );
    verifica(
      t.etiqueta,
      tamano: 13,
      interlineado: 16,
      peso: FontWeight.w500,
      tracking: 0.002,
    );
    verifica(
      t.micro,
      tamano: 11,
      interlineado: 14,
      peso: FontWeight.w600,
      tracking: 0.06,
    );
    verifica(
      t.cifra,
      tamano: 32,
      interlineado: 36,
      peso: FontWeight.w500,
      tracking: -0.02,
    );
  });

  test('ningun estilo baja de 11', () {
    for (final estilo in t.todos) {
      expect(estilo.fontSize, greaterThanOrEqualTo(11));
    }
  });

  test('el texto usa Geist con Inter de respaldo', () {
    expect(t.cuerpo.fontFamily, 'Geist');
    expect(t.cuerpo.fontFamilyFallback, contains('Inter'));
  });

  test('la cifra usa la mono con cifras tabulares', () {
    expect(t.cifra.fontFamily, 'GeistMono');
    expect(t.cifra.fontFeatures, contains(const FontFeature.tabularFigures()));
  });

  test('crear con color aplica el color a todos los estilos', () {
    const rojo = Color(0xFFFF0000);
    final coloreada = Tipografia.crear(color: rojo);
    for (final estilo in coloreada.todos) {
      expect(estilo.color, rojo);
    }
  });
}
