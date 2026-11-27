import 'package:carecar_mobile/modulos/lealtad/datos/repositorio_lealtad_fake.dart';
import 'package:carecar_mobile/modulos/lealtad/dominio/repositorio_lealtad.dart';
import 'package:carecar_mobile/modulos/lealtad/presentacion/pantalla_referir.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/aviso.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/boton_pildora.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/campo_texto.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/control_binario.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../ayudas/auditoria_accesibilidad.dart';
import '../../ayudas/tema_pista.dart';
import 'ayudas_lealtad.dart';

const _pantalla = PantallaReferir();

Finder _campo(String etiqueta) => find.descendant(
  of: find.widgetWithText(CampoTexto, etiqueta),
  matching: find.byType(EditableText),
);

BotonPildora _enviar(WidgetTester tester) =>
    tester.widget<BotonPildora>(find.widgetWithText(BotonPildora, 'Enviar'));

Future<void> _llenar(
  WidgetTester tester, {
  String nombre = 'Ana Torres',
  String telefono = '',
  String correo = '',
  bool consentimiento = true,
}) async {
  await tester.enterText(_campo('Nombre de tu amigo'), nombre);
  if (telefono.isNotEmpty) {
    await tester.enterText(_campo('Teléfono'), telefono);
  }
  if (correo.isNotEmpty) await tester.enterText(_campo('Correo'), correo);
  if (consentimiento) {
    await tester.ensureVisible(find.byType(Casilla));
    await tester.tap(find.byType(Casilla));
  }
  await tester.pumpAndSettle();
}

Future<void> _tocarEnviar(WidgetTester tester) async {
  await tester.ensureVisible(find.widgetWithText(BotonPildora, 'Enviar'));
  await tester.tap(find.widgetWithText(BotonPildora, 'Enviar'));
  await tester.pumpAndSettle();
}

void main() {
  pruebaLealtad('muestra mi codigo y lo comparte con la hoja del sistema '
      '(V2-M12.04)', (tester) async {
    final compartidos = <String>[];
    await tester.pumpWidget(
      appLealtad(_pantalla, repoDeEjemplo(), compartidos: compartidos),
    );
    await tester.pumpAndSettle();

    expect(find.text('CC00001'), findsOneWidget);
    await tester.tap(find.text('Compartir mi código'));
    await tester.pumpAndSettle();
    expect(compartidos, [
      'Te recomiendo la agencia. Menciona mi código CC00001 cuando vayas.',
    ]);
  });

  pruebaLealtad('sin la casilla de consentimiento no se envia', (tester) async {
    await tester.pumpWidget(appLealtad(_pantalla, repoDeEjemplo()));
    await tester.pumpAndSettle();
    expect(_enviar(tester).alPresionar, isNull);

    await _llenar(tester, telefono: '4421234567', consentimiento: false);
    expect(_enviar(tester).alPresionar, isNull);

    await tester.tap(find.byType(Casilla));
    await tester.pumpAndSettle();
    expect(_enviar(tester).alPresionar, isNotNull);
  });

  pruebaLealtad('pide telefono o correo y los valida', (tester) async {
    await tester.pumpWidget(appLealtad(_pantalla, repoDeEjemplo()));
    await tester.pumpAndSettle();

    await _llenar(tester);
    expect(_enviar(tester).alPresionar, isNull);

    await tester.enterText(_campo('Teléfono'), '44212');
    await tester.pumpAndSettle();
    expect(find.text('Escribe los 10 dígitos.'), findsOneWidget);
    expect(_enviar(tester).alPresionar, isNull);

    await tester.enterText(_campo('Teléfono'), '');
    await tester.enterText(_campo('Correo'), 'ana@');
    await tester.pumpAndSettle();
    expect(find.text('Revisa el correo.'), findsOneWidget);
    expect(_enviar(tester).alPresionar, isNull);

    await tester.enterText(_campo('Correo'), 'ana@correo.mx');
    await tester.pumpAndSettle();
    expect(find.text('Revisa el correo.'), findsNothing);
    expect(_enviar(tester).alPresionar, isNotNull);
  });

  pruebaLealtad('registra al amigo, limpia el formulario y lo agrega a la '
      'lista', (tester) async {
    final repo = repoDeEjemplo();
    await tester.pumpWidget(appLealtad(_pantalla, repo));
    await tester.pumpAndSettle();

    await _llenar(tester, telefono: '4421234567');
    await _tocarEnviar(tester);

    expect(repo.referidosEnviados.single, (
      nombre: 'Ana Torres',
      telefono: '4421234567',
      correo: null,
    ));
    expect(
      find.widgetWithText(Aviso, 'Listo, la agencia contactará a Ana Torres.'),
      findsOneWidget,
    );
    expect(find.text('Ana Torres'), findsOneWidget);
    expect(find.textContaining('Registrado · desde el'), findsOneWidget);
    expect(tester.widget<Casilla>(find.byType(Casilla)).valor, isFalse);
  });

  pruebaLealtad('si ya esta con la agencia no dice de quien', (tester) async {
    final repo = repoDeEjemplo()
      ..rechazoReferido = MotivoRechazoReferido.duplicado;
    await tester.pumpWidget(appLealtad(_pantalla, repo));
    await tester.pumpAndSettle();

    await _llenar(tester, correo: 'ana@correo.mx');
    await _tocarEnviar(tester);

    expect(find.text('Esa persona ya está con la agencia.'), findsOneWidget);
  });

  pruebaLealtad('con el maximo abierto pide esperar', (tester) async {
    final repo = repoDeEjemplo()
      ..rechazoReferido = MotivoRechazoReferido.limite;
    await tester.pumpWidget(appLealtad(_pantalla, repo));
    await tester.pumpAndSettle();

    await _llenar(tester, correo: 'ana@correo.mx');
    await _tocarEnviar(tester);

    expect(find.textContaining('Ya tienes el máximo'), findsOneWidget);
  });

  pruebaLealtad('lista mis referidos con su estado y lo que gane', (
    tester,
  ) async {
    await tester.pumpWidget(appLealtad(_pantalla, repoDeEjemplo()));
    await tester.pumpAndSettle();

    expect(find.text('Jorge Ruiz'), findsOneWidget);
    expect(find.textContaining('En seguimiento · desde el'), findsOneWidget);
    expect(find.text('Laura Méndez'), findsOneWidget);
    expect(find.textContaining('Compró · desde el'), findsOneWidget);
    expect(find.text('+500'), findsOneWidget);
    expect(
      find.bySemanticsLabel(RegExp(r'^Laura Méndez\..*Ganaste 500 puntos$')),
      findsOneWidget,
    );
  });

  pruebaLealtad('sin referidos lo dice', (tester) async {
    await tester.pumpWidget(appLealtad(_pantalla, RepositorioLealtadFake()));
    await tester.pumpAndSettle();
    expect(find.text('Aún no refieres a nadie.'), findsOneWidget);
  });

  pruebaLealtad('si fallan los referidos ofrece reintentar', (tester) async {
    final repo = repoDeEjemplo()..falla = Exception('500');
    await tester.pumpWidget(appLealtad(_pantalla, repo));
    await tester.pumpAndSettle();
    expect(find.text('No pudimos cargar tus referidos.'), findsOneWidget);

    repo.falla = null;
    await tester.ensureVisible(find.text('Reintentar'));
    await tester.tap(find.text('Reintentar'));
    await tester.pumpAndSettle();
    expect(find.text('Jorge Ruiz'), findsOneWidget);
  });

  for (final escenario in Escenario.values) {
    pruebaLealtad('se ve sin desbordes en ${escenario.name}', (tester) async {
      await tester.pumpWidget(
        appLealtad(_pantalla, repoDeEjemplo(), escenario: escenario),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('pasa la auditoria de accesibilidad en 320 (V2-M20.02, '
      'V2-M20.03 y V2-M20.08)', (tester) async {
    telefonoChicoYAlto(tester);
    for (final escenario in Escenario.values) {
      await tester.pumpWidget(
        appLealtad(
          _pantalla,
          repoDeEjemplo(),
          escenario: escenario,
          ancho: anchoTelefonoChico,
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: escenario.name);
      if (escenario != Escenario.letraGrande) {
        await auditarAccesibilidad(tester);
      }
    }
  });
}
