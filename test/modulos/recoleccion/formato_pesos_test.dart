import 'package:carecar_mobile/l10n/idiomas.dart';
import 'package:carecar_mobile/modulos/recoleccion/recoleccion.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<String> _formatear(
  WidgetTester tester,
  Locale idioma,
  double monto,
) async {
  late String texto;
  await tester.pumpWidget(
    MaterialApp(
      locale: idioma,
      localizationsDelegates: delegadasDeIdioma,
      supportedLocales: idiomasSoportados,
      home: Builder(
        builder: (context) {
          texto = formatearPesos(context, monto);
          return const SizedBox();
        },
      ),
    ),
  );
  return texto;
}

void main() {
  testWidgets('en español usa el formato de México', (tester) async {
    expect(await _formatear(tester, const Locale('es'), 1234.5), r'$1,234.50');
  });

  testWidgets('siempre dos decimales', (tester) async {
    expect(await _formatear(tester, const Locale('es'), 150), r'$150.00');
  });

  testWidgets('en inglés también muestra pesos con dos decimales', (
    tester,
  ) async {
    expect(await _formatear(tester, const Locale('en'), 300), r'$300.00');
  });
}
