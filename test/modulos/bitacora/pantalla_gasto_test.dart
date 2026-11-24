import 'package:carecar_mobile/api/excepciones.dart';
import 'package:carecar_mobile/modulos/bitacora/datos/repositorio_bitacora_fake.dart';
import 'package:carecar_mobile/modulos/bitacora/dominio/fallos_bitacora.dart';
import 'package:carecar_mobile/modulos/bitacora/dominio/gasto.dart';
import 'package:carecar_mobile/modulos/bitacora/dominio/lector_ticket.dart';
import 'package:carecar_mobile/modulos/bitacora/dominio/parser_ticket.dart';
import 'package:carecar_mobile/modulos/bitacora/presentacion/pantalla_gasto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../ayudas/tema_pista.dart';
import 'arnes_bitacora.dart';

/// Falla al guardar como lo haría el servidor con un km menor a la lectura.
class _RepoKmRechazado extends RepositorioBitacoraFake {
  @override
  Future<Gasto> registrar(int vehiculoId, BorradorGasto borrador) =>
      throw const KmInvalido();
}

Widget _form(
  RepositorioBitacoraFake repo, {
  TipoGasto tipo = TipoGasto.gasolina,
  Gasto? editando,
  LectorTicketFake? lector,
  Escenario escenario = Escenario.claro,
}) => aplicacion(
  PantallaGasto(vehiculoId: 4, tipoInicial: tipo, editando: editando),
  repo: repo,
  lector: lector,
  escenario: escenario,
);

Future<void> _escribir(
  WidgetTester tester,
  String etiqueta,
  String texto,
) async {
  await tester.enterText(
    find.descendant(
      of: find
          .ancestor(of: find.text(etiqueta), matching: find.byType(Column))
          .first,
      matching: find.byType(TextField),
    ),
    texto,
  );
}

void main() {
  group('carga de gasolina (V2-M18.01)', () {
    prueba('guardar vacío marca error en cada campo', (tester) async {
      await tester.pumpWidget(_form(RepositorioBitacoraFake()));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Guardar'));
      await tester.pumpAndSettle();
      expect(find.text('Escribe los litros, mayores a 0.'), findsOneWidget);
      expect(find.text('Escribe un monto mayor a 0.'), findsOneWidget);
      expect(
        find.text('Escribe el kilometraje como número entero.'),
        findsOneWidget,
      );
    });

    prueba('guarda la carga y vuelve a la pantalla anterior', (tester) async {
      final repo = RepositorioBitacoraFake();
      await tester.pumpWidget(_form(repo));
      await tester.pumpAndSettle();
      await _escribir(tester, 'Litros', '35.4');
      await _escribir(tester, 'Monto total', '849.50');
      await _escribir(tester, 'Kilometraje del tablero', '12500');
      await tester.tap(find.text('Guardar'));
      await tester.pumpAndSettle();
      final guardados = await repo.gastos(4);
      expect(guardados, hasLength(1));
      expect(guardados.single.litros, 35.4);
      expect(guardados.single.monto, 849.5);
      expect(guardados.single.km, 12500);
      expect(guardados.single.fecha, hoyDePrueba);
    });

    prueba('un km menor a la última lectura se explica en el campo', (
      tester,
    ) async {
      final repo = RepositorioBitacoraFake(gastos: gastosDePrueba());
      await tester.pumpWidget(_form(repo));
      await tester.pumpAndSettle();
      expect(find.text('Tu última lectura es de 10,400 km.'), findsOneWidget);
      await _escribir(tester, 'Litros', '30');
      await _escribir(tester, 'Monto total', '700');
      await _escribir(tester, 'Kilometraje del tablero', '10000');
      await tester.tap(find.text('Guardar'));
      await tester.pumpAndSettle();
      expect(
        find.text('No puede ser menor a tu última lectura (10,400 km).'),
        findsOneWidget,
      );
      expect(await repo.gastos(4), hasLength(3));
    });

    prueba('el 422 KM_INVALIDO del servidor sale en el campo de km', (
      tester,
    ) async {
      await tester.pumpWidget(_form(_RepoKmRechazado()));
      await tester.pumpAndSettle();
      await _escribir(tester, 'Litros', '30');
      await _escribir(tester, 'Monto total', '700');
      await _escribir(tester, 'Kilometraje del tablero', '10000');
      await tester.tap(find.text('Guardar'));
      await tester.pumpAndSettle();
      expect(
        find.textContaining('El servidor lo rechazó: es menor a tu última'),
        findsOneWidget,
      );
    });

    prueba('sin red avisa y conserva lo escrito', (tester) async {
      await tester.pumpWidget(
        _form(RepositorioBitacoraFake(error: const SinConexion())),
      );
      await tester.pumpAndSettle();
      await _escribir(tester, 'Litros', '30');
      await _escribir(tester, 'Monto total', '700');
      await _escribir(tester, 'Kilometraje del tablero', '10000');
      await tester.tap(find.text('Guardar'));
      await tester.pumpAndSettle();
      expect(
        find.text('Sin conexión. Revisa tu internet e intenta de nuevo.'),
        findsOneWidget,
      );
      expect(find.text('Guardar'), findsOneWidget);
    });
  });

  group('foto del ticket (V2-M18.02)', () {
    prueba('propone litros y monto leídos y deja corregir', (tester) async {
      final lector = LectorTicketFake(
        lectura: LecturaTicket(
          litros: 35.42,
          monto: 849.77,
          fecha: DateTime(2026, 11, 18),
        ),
      );
      await tester.pumpWidget(_form(RepositorioBitacoraFake(), lector: lector));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Tomar foto'));
      await tester.pumpAndSettle();
      expect(lector.ultimoOrigen, OrigenFoto.camara);
      expect(find.text('35.42'), findsOneWidget);
      expect(find.text('849.77'), findsOneWidget);
      expect(find.text('18/11/2026'), findsOneWidget);
      expect(
        find.text(
          'Esto fue lo que leímos. Revísalo y corrige lo que haga falta.',
        ),
        findsOneWidget,
      );
    });

    prueba('si no lee nada, el formulario queda vacío', (tester) async {
      final lector = LectorTicketFake(lectura: const LecturaTicket());
      await tester.pumpWidget(_form(RepositorioBitacoraFake(), lector: lector));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Elegir de fotos'));
      await tester.pumpAndSettle();
      expect(lector.ultimoOrigen, OrigenFoto.galeria);
      expect(
        find.text('No pudimos leer el ticket. Llena los datos a mano.'),
        findsOneWidget,
      );
      final campos = tester.widgetList<TextField>(find.byType(TextField));
      expect(campos.every((c) => c.controller!.text.isEmpty), isTrue);
    });

    prueba('si la persona cancela no pasa nada', (tester) async {
      await tester.pumpWidget(
        _form(RepositorioBitacoraFake(), lector: LectorTicketFake()),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Tomar foto'));
      await tester.pumpAndSettle();
      expect(find.textContaining('No pudimos leer'), findsNothing);
    });

    prueba('sin permiso lo explica y deja llenar a mano', (tester) async {
      final lector = LectorTicketFake(fallo: const FalloLecturaTicket(true));
      await tester.pumpWidget(_form(RepositorioBitacoraFake(), lector: lector));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Tomar foto'));
      await tester.pumpAndSettle();
      expect(find.textContaining('No tenemos permiso'), findsOneWidget);
    });

    prueba('aclara que la foto no se guarda ni se sube', (tester) async {
      await tester.pumpWidget(_form(RepositorioBitacoraFake()));
      await tester.pumpAndSettle();
      expect(
        find.text('La foto se lee en tu teléfono; no se guarda ni se sube.'),
        findsOneWidget,
      );
    });
  });

  group('otros gastos (V2-M18.04)', () {
    prueba('elige el tipo y pide monto', (tester) async {
      final repo = RepositorioBitacoraFake();
      await tester.pumpWidget(_form(repo, tipo: TipoGasto.estacionamiento));
      await tester.pumpAndSettle();
      expect(find.text('Litros'), findsNothing);
      expect(find.text('Kilometraje del tablero'), findsNothing);
      await tester.tap(find.text('Guardar'));
      await tester.pumpAndSettle();
      expect(find.text('Escribe un monto mayor a 0.'), findsOneWidget);
      await _escribir(tester, 'Monto total', '60');
      await tester.tap(find.text('Guardar'));
      await tester.pumpAndSettle();
      final g = (await repo.gastos(4)).single;
      expect(g.tipo, TipoGasto.estacionamiento);
      expect(g.monto, 60);
    });

    prueba('«Otro» exige descripción', (tester) async {
      final repo = RepositorioBitacoraFake();
      await tester.pumpWidget(_form(repo, tipo: TipoGasto.estacionamiento));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Estacionamiento'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Otro').last);
      await tester.pumpAndSettle();
      await _escribir(tester, 'Monto total', '90');
      await tester.tap(find.text('Guardar'));
      await tester.pumpAndSettle();
      expect(
        find.text('Describe el gasto, en máximo 200 caracteres.'),
        findsOneWidget,
      );
      await _escribir(tester, 'Descripción', 'Grúa');
      await tester.tap(find.text('Guardar'));
      await tester.pumpAndSettle();
      expect((await repo.gastos(4)).single.descripcion, 'Grúa');
    });
  });

  group('editar y borrar', () {
    prueba('edita un gasto y conserva sus datos', (tester) async {
      final lavado = otroGasto(3, DateTime(2026, 11, 5), 80);
      final repo = RepositorioBitacoraFake(gastos: [lavado]);
      await tester.pumpWidget(
        _form(repo, tipo: TipoGasto.lavado, editando: lavado),
      );
      await tester.pumpAndSettle();
      expect(find.text('Editar gasto'), findsOneWidget);
      expect(find.text('80'), findsOneWidget);
      await _escribir(tester, 'Monto total', '95');
      await tester.tap(find.text('Guardar'));
      await tester.pumpAndSettle();
      expect((await repo.gastos(4)).single.monto, 95);
    });

    prueba('borra con confirmación', (tester) async {
      final lavado = otroGasto(3, DateTime(2026, 11, 5), 80);
      final repo = RepositorioBitacoraFake(gastos: [lavado]);
      await tester.pumpWidget(
        _form(repo, tipo: TipoGasto.lavado, editando: lavado),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Borrar gasto'));
      await tester.pumpAndSettle();
      expect(find.text('¿Borrar este gasto?'), findsOneWidget);
      expect(await repo.gastos(4), hasLength(1));
      await tester.tap(find.text('Borrar'));
      await tester.pumpAndSettle();
      expect(await repo.gastos(4), isEmpty);
    });

    prueba('cancelar la confirmación no borra', (tester) async {
      final lavado = otroGasto(3, DateTime(2026, 11, 5), 80);
      final repo = RepositorioBitacoraFake(gastos: [lavado]);
      await tester.pumpWidget(
        _form(repo, tipo: TipoGasto.lavado, editando: lavado),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Borrar gasto'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();
      expect(await repo.gastos(4), hasLength(1));
    });
  });

  for (final escenario in [Escenario.oscuro, Escenario.letraGrande]) {
    prueba('el formulario se ve completo con ${escenario.name}', (
      tester,
    ) async {
      await tester.pumpWidget(
        _form(RepositorioBitacoraFake(), escenario: escenario),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Guardar'), findsOneWidget);
    });
  }
}
