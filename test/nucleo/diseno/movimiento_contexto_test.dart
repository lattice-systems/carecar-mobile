import 'package:carecar_mobile/nucleo/diseno/movimiento_contexto.dart';
import 'package:carecar_mobile/nucleo/diseno/tokens/movimiento.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<TokenMovimiento> resolver(
  WidgetTester tester, {
  required bool reducir,
  required TokenMovimiento token,
}) async {
  late TokenMovimiento resultado;
  await tester.pumpWidget(
    MediaQuery(
      data: MediaQueryData(disableAnimations: reducir),
      child: Builder(
        builder: (context) {
          resultado = context.movimiento(token);
          return const SizedBox();
        },
      ),
    ),
  );
  return resultado;
}

void main() {
  testWidgets('sin preferencia devuelve el token tal cual', (tester) async {
    final r = await resolver(
      tester,
      reducir: false,
      token: Movimiento.enfatico,
    );
    expect(r, Movimiento.enfatico);
  });

  testWidgets('con reducir movimiento devuelve el fundido de 120 ms', (
    tester,
  ) async {
    final r = await resolver(tester, reducir: true, token: Movimiento.enfatico);
    expect(r.duracion, const Duration(milliseconds: 120));
    expect(r.curva, Curves.linear);
  });

  testWidgets('cada token base se reduce igual', (tester) async {
    for (final token in [
      Movimiento.rapido,
      Movimiento.base,
      Movimiento.enfatico,
    ]) {
      final r = await resolver(tester, reducir: true, token: token);
      expect(r.duracion, const Duration(milliseconds: 120));
    }
  });

  testWidgets('una animacion real respeta la preferencia', (tester) async {
    Widget construir({required bool reducir}) {
      return MediaQuery(
        data: MediaQueryData(disableAnimations: reducir),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Builder(
            builder: (context) {
              final m = context.movimiento(Movimiento.enfatico);
              return AnimatedOpacity(
                opacity: 0,
                duration: m.duracion,
                curve: m.curva,
                child: const SizedBox(),
              );
            },
          ),
        ),
      );
    }

    await tester.pumpWidget(construir(reducir: true));
    final animado = tester.widget<AnimatedOpacity>(
      find.byType(AnimatedOpacity),
    );
    expect(animado.duration, const Duration(milliseconds: 120));
  });
}
