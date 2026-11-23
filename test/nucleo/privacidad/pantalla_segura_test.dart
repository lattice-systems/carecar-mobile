import 'package:carecar_mobile/nucleo/privacidad/pantalla_segura.dart';
import 'package:carecar_mobile/nucleo/privacidad/proteccion_de_captura.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app(ProteccionDeCapturaFake fake, {Widget? hijo}) => ProviderScope(
  overrides: [proteccionDeCapturaProvider.overrideWithValue(fake)],
  child: MaterialApp(home: hijo ?? const SizedBox()),
);

void main() {
  testWidgets('bloquea capturas mientras la pantalla esta visible', (
    tester,
  ) async {
    final fake = ProteccionDeCapturaFake();
    await tester.pumpWidget(
      _app(fake, hijo: const PantallaSegura(child: Text('Pago'))),
    );
    expect(fake.bloqueada, isTrue);

    await tester.pumpWidget(_app(fake));
    expect(fake.bloqueada, isFalse);
  });

  testWidgets('sin PantallaSegura las capturas estan permitidas', (
    tester,
  ) async {
    final fake = ProteccionDeCapturaFake();
    await tester.pumpWidget(_app(fake, hijo: const Text('Inicio')));
    expect(fake.bloqueada, isFalse);
    expect(fake.llamadas, isEmpty);
  });

  testWidgets('dos pantallas seguras apiladas: se libera al cerrar la ultima', (
    tester,
  ) async {
    final fake = ProteccionDeCapturaFake();
    late BuildContext contexto;
    await tester.pumpWidget(
      _app(
        fake,
        hijo: Builder(
          builder: (c) {
            contexto = c;
            return const PantallaSegura(child: Text('Documentos'));
          },
        ),
      ),
    );
    Navigator.of(contexto).push(
      MaterialPageRoute<void>(
        builder: (_) => const PantallaSegura(child: Text('Pago')),
      ),
    );
    await tester.pumpAndSettle();
    expect(fake.bloqueada, isTrue);

    Navigator.of(contexto).pop();
    await tester.pumpAndSettle();
    expect(fake.bloqueada, isTrue, reason: 'queda la pantalla de documentos');

    await tester.pumpWidget(_app(fake));
    expect(fake.bloqueada, isFalse);
  });
}
