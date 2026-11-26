import 'package:carecar_mobile/l10n/idiomas.dart';
import 'package:carecar_mobile/nucleo/idioma/formato_numeros.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Lo que da [formatearMiles] en un idioma, leído desde un contexto real.
Future<String> _enIdioma(WidgetTester tester, Locale idioma, num valor) async {
  late String texto;
  await tester.pumpWidget(
    MaterialApp(
      locale: idioma,
      localizationsDelegates: delegadasDeIdioma,
      supportedLocales: idiomasSoportados,
      home: Builder(
        builder: (context) {
          texto = formatearMiles(context, valor);
          return const SizedBox.shrink();
        },
      ),
    ),
  );
  return texto;
}

void main() {
  group('formatearMiles', () {
    testWidgets('en español usa el formato de México: coma de miles', (
      tester,
    ) async {
      // El de España daría «18.450»: el mismo número se vería distinto según
      // la pantalla, y la agencia es de México.
      expect(await _enIdioma(tester, const Locale('es'), 18450), '18,450');
      expect(await _enIdioma(tester, const Locale('es'), 1234567), '1,234,567');
      expect(await _enIdioma(tester, const Locale('es'), 950), '950');
    });

    testWidgets('en español el punto es el decimal', (tester) async {
      expect(await _enIdioma(tester, const Locale('es'), 1234.5), '1,234.5');
    });

    testWidgets('en inglés usa su propio formato', (tester) async {
      expect(await _enIdioma(tester, const Locale('en'), 18450), '18,450');
    });
  });
}
