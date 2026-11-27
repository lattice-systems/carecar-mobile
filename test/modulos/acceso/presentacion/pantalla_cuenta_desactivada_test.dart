import 'package:carecar_mobile/config/agencia.dart';
import 'package:carecar_mobile/modulos/acceso/acceso.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../ayudas/tema_pista.dart';

/// V2-M01.08 · «saber por qué no puedo entrar».
///
/// La pantalla es un callejón a propósito: lo único accionable es hablar con
/// la agencia. Lo que se prueba es que eso **funcione** y que marque el
/// teléfono de la agencia, no cualquier cosa.
void main() {
  testWidgets('explica el porque y ofrece contactar a la agencia', (
    tester,
  ) async {
    final abiertos = <Uri>[];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          abrirEnlaceProvider.overrideWithValue((enlace) async {
            abiertos.add(enlace);
            return true;
          }),
        ],
        child: conTemaPista(const PantallaCuentaDesactivada()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Tu cuenta está desactivada'), findsOneWidget);
    // No se ofrece reintentar: escribir otra vez la contraseña no arregla nada.
    expect(find.byType(TextField), findsNothing);

    await tester.tap(find.byKey(PantallaCuentaDesactivada.botonLlamar));
    await tester.pumpAndSettle();

    expect(abiertos.single.scheme, 'tel');
    expect(abiertos.single.path, Agencia.telefono.replaceAll(' ', ''));
  });
}
