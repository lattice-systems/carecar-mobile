import 'package:carecar_mobile/api/excepciones.dart';
import 'package:carecar_mobile/modulos/pagos/datos/repositorio_datos_fiscales_fake.dart';
import 'package:carecar_mobile/modulos/pagos/dominio/datos_fiscales.dart';
import 'package:carecar_mobile/modulos/pagos/presentacion/pantalla_datos_fiscales.dart';
import 'package:carecar_mobile/modulos/pagos/presentacion/pantalla_perfil_fiscal.dart';
import 'package:carecar_mobile/modulos/pagos/presentacion/rutas_pagos.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/aviso.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/campo_texto.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/control_binario.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/dialogo.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/estado_error.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../ayudas/tema_pista.dart';
import 'ayudas_pagos.dart';

Finder _campo(String etiqueta) => find.descendant(
  of: find.widgetWithText(CampoTexto, etiqueta),
  matching: find.byType(EditableText),
);

String _texto(WidgetTester tester, String etiqueta) =>
    tester.widget<EditableText>(_campo(etiqueta)).controller.text;

Selector<String> _selector(WidgetTester tester, String etiqueta) =>
    tester.widget<Selector<String>>(
      find.byWidgetPredicate(
        (w) => w is Selector<String> && w.etiqueta == etiqueta,
      ),
    );

List<String> _opciones(WidgetTester tester, String etiqueta) => [
  for (final o in _selector(tester, etiqueta).opciones) o.valor,
];

Future<void> _elegir(WidgetTester tester, String etiqueta, String clave) async {
  _selector(tester, etiqueta).alCambiar!(clave);
  await tester.pumpAndSettle();
}

Future<void> _guardar(WidgetTester tester) async {
  await tester.tap(find.text('Guardar'));
  await tester.pumpAndSettle();
}

/// Llena un alta valida de persona fisica.
Future<void> _llenarFisica(WidgetTester tester) async {
  await tester.enterText(_campo('RFC'), 'gode561231gr8');
  await tester.enterText(_campo('Nombre o razón social'), 'Dolores Gómez');
  await tester.enterText(_campo('Código postal fiscal'), '76000');
  await tester.pumpAndSettle();
  await _elegir(tester, 'Régimen fiscal', '612');
  await _elegir(tester, 'Uso del CFDI', 'G03');
}

void main() {
  group('alta', () {
    pruebaPagos('el RFC dice la persona y filtra regimen y uso', (
      tester,
    ) async {
      await tester.pumpWidget(
        appPagos(const PantallaPerfilFiscal(), repoDeEjemplo()),
      );
      await tester.pumpAndSettle();
      expect(
        find.text(
          '13 caracteres si eres persona física; 12 si es una empresa.',
        ),
        findsOneWidget,
      );
      expect(_opciones(tester, 'Régimen fiscal'), hasLength(4));

      await tester.enterText(_campo('RFC'), 'gode561231gr8');
      await tester.pumpAndSettle();
      expect(_texto(tester, 'RFC'), 'GODE561231GR8');
      expect(find.text('Persona física'), findsOneWidget);
      expect(_opciones(tester, 'Régimen fiscal'), ['605', '612', '626']);

      await _elegir(tester, 'Régimen fiscal', '605');
      expect(_opciones(tester, 'Uso del CFDI'), ['D01', 'S01']);

      await tester.enterText(_campo('RFC'), 'EKU9003173C9');
      await tester.pumpAndSettle();
      expect(find.text('Persona moral'), findsOneWidget);
      expect(_opciones(tester, 'Régimen fiscal'), ['601', '626']);
      expect(_selector(tester, 'Régimen fiscal').valor, isNull);
    });

    pruebaPagos('al guardar marca los campos que fallan sin enviar', (
      tester,
    ) async {
      final repo = repoDeEjemplo();
      await tester.pumpWidget(appPagos(const PantallaPerfilFiscal(), repo));
      await tester.pumpAndSettle();
      await tester.enterText(_campo('RFC'), 'GODE561231GR9');
      await tester.enterText(_campo('Código postal fiscal'), '760');
      await _guardar(tester);

      expect(
        find.widgetWithText(Aviso, 'Revisa los campos marcados.'),
        findsOneWidget,
      );
      expect(
        find.text('El último carácter no coincide; revisa la homoclave.'),
        findsOneWidget,
      );
      expect(find.text('Escribe el nombre o la razón social.'), findsOneWidget);
      expect(find.text('Escribe los 5 dígitos.'), findsOneWidget);
      expect(find.text('Elige tu régimen fiscal.'), findsOneWidget);
      expect(find.text('Elige el uso del CFDI.'), findsOneWidget);
      expect(repo.enviados, isEmpty);
    });

    pruebaPagos('lo que rechaza el servidor aparece en su campo', (
      tester,
    ) async {
      final repo = repoDeEjemplo()
        ..rechazo = {CampoFiscal.usoCfdi: 'Ese uso de CFDI no aplica aquí'};
      await tester.pumpWidget(appPagos(const PantallaPerfilFiscal(), repo));
      await tester.pumpAndSettle();
      await _llenarFisica(tester);
      await _guardar(tester);

      expect(find.text('Ese uso de CFDI no aplica aquí'), findsOneWidget);
      expect(repo.enviados, hasLength(1));

      await _elegir(tester, 'Uso del CFDI', 'S01');
      expect(find.text('Ese uso de CFDI no aplica aquí'), findsNothing);
    });

    pruebaPagos('guarda los datos limpios y regresa a la lista', (
      tester,
    ) async {
      final repo = repoDeEjemplo();
      await tester.pumpWidget(
        appPagosEnrutada(repo, inicial: rutaPerfilFiscalNuevo),
      );
      await tester.pumpAndSettle();
      await _llenarFisica(tester);
      await tester.enterText(
        _campo('Correo para la factura (opcional)'),
        'Lola@Correo.mx',
      );
      await tester.tap(find.byType(Casilla));
      await tester.pumpAndSettle();
      await _guardar(tester);

      final enviado = repo.enviados.single;
      expect(enviado.rfcNormalizado, 'GODE561231GR8');
      expect(enviado.regimenFiscal, '612');
      expect(enviado.usoCfdi, 'G03');
      expect(enviado.predeterminado, isTrue);
      expect(find.byType(PantallaDatosFiscales), findsOneWidget);
      expect(find.byType(PantallaPerfilFiscal), findsNothing);
      expect(
        repo.perfilesActuales.where((p) => p.predeterminado),
        hasLength(1),
      );
    });

    pruebaPagos('sin conexion al guardar lo dice y no sale', (tester) async {
      final repo = repoDeEjemplo();
      await tester.pumpWidget(appPagos(const PantallaPerfilFiscal(), repo));
      await tester.pumpAndSettle();
      await _llenarFisica(tester);
      repo.falla = const SinConexion();
      await _guardar(tester);

      expect(
        find.text('Sin conexión. Revisa tu internet e intenta de nuevo.'),
        findsOneWidget,
      );
    });
  });

  group('edicion', () {
    pruebaPagos('trae los datos y el predeterminado no ofrece la casilla', (
      tester,
    ) async {
      await tester.pumpWidget(
        appPagos(const PantallaPerfilFiscal(perfilId: 10), repoDeEjemplo()),
      );
      await tester.pumpAndSettle();

      expect(_texto(tester, 'RFC'), 'GODE561231GR8');
      expect(_texto(tester, 'Nombre o razón social'), 'DOLORES GÓMEZ');
      expect(_selector(tester, 'Régimen fiscal').valor, '612');
      expect(_selector(tester, 'Uso del CFDI').valor, 'G03');
      expect(find.byType(Casilla), findsNothing);
      expect(find.text('Borrar'), findsOneWidget);
    });

    pruebaPagos('otro perfil puede volverse el predeterminado', (tester) async {
      final repo = repoDeEjemplo();
      await tester.pumpWidget(
        appPagosEnrutada(repo, inicial: rutaPerfilFiscal(11)),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byType(Casilla));
      await tester.pumpAndSettle();
      await _guardar(tester);

      final moral = repo.perfilesActuales.firstWhere((p) => p.id == 11);
      expect(moral.predeterminado, isTrue);
      expect(find.byType(PantallaDatosFiscales), findsOneWidget);
    });

    pruebaPagos('borrar pide confirmacion y regresa', (tester) async {
      final repo = repoDeEjemplo();
      await tester.pumpWidget(
        appPagosEnrutada(repo, inicial: rutaPerfilFiscal(10)),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Borrar'));
      await tester.pumpAndSettle();

      expect(find.text('¿Borrar estos datos fiscales?'), findsOneWidget);
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();
      expect(repo.borrados, isEmpty);

      await tester.tap(find.text('Borrar'));
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(
          of: find.byType(Dialogo),
          matching: find.text('Borrar'),
        ),
      );
      await tester.pumpAndSettle();

      expect(repo.borrados, [10]);
      expect(find.byType(PantallaDatosFiscales), findsOneWidget);
      expect(find.text('ESCUELA KEMPER URGATE'), findsOneWidget);
    });

    pruebaPagos('un perfil que ya no existe lo dice', (tester) async {
      await tester.pumpWidget(
        appPagos(const PantallaPerfilFiscal(perfilId: 99), repoDeEjemplo()),
      );
      await tester.pumpAndSettle();
      expect(
        find.text('Ya no encontramos estos datos fiscales'),
        findsOneWidget,
      );
    });
  });

  pruebaPagos('si no llegan los catalogos ofrece reintentar', (tester) async {
    final repo = RepositorioDatosFiscalesFake(
      catalogo: catalogoDeEjemplo,
      falla: Exception('500'),
    );
    await tester.pumpWidget(appPagos(const PantallaPerfilFiscal(), repo));
    await tester.pumpAndSettle();
    expect(find.byType(EstadoError), findsOneWidget);

    repo.falla = null;
    await tester.tap(find.text('Reintentar'));
    await tester.pumpAndSettle();
    expect(find.text('Nuevos datos fiscales'), findsWidgets);
    expect(repo.catalogosPedidos, 2);
  });

  for (final escenario in Escenario.values) {
    pruebaPagos('se ve sin desbordes en ${escenario.name}', (tester) async {
      await tester.pumpWidget(
        appPagos(
          const PantallaPerfilFiscal(perfilId: 10),
          repoDeEjemplo(),
          escenario: escenario,
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}
