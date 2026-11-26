import 'package:carecar_mobile/api/excepciones.dart';
import 'package:carecar_mobile/modulos/lealtad/datos/repositorio_lealtad_fake.dart';
import 'package:carecar_mobile/modulos/lealtad/dominio/repositorio_lealtad.dart';
import 'package:carecar_mobile/modulos/lealtad/presentacion/pantalla_canje.dart';
import 'package:carecar_mobile/modulos/lealtad/presentacion/pantalla_recompensas.dart';
import 'package:carecar_mobile/modulos/lealtad/presentacion/rutas_lealtad.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/dialogo.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/esqueleto.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/estado_error.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/estado_vacio.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/tarjeta_resumen.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../ayudas/tema_pista.dart';
import 'ayudas_lealtad.dart';

const _pantalla = PantallaRecompensas();

/// Si la tarjeta de la recompensa se puede tocar.
bool _tocable(WidgetTester tester, String nombre) {
  final tarjeta = tester.widget<TarjetaResumen>(
    find.ancestor(of: find.text(nombre), matching: find.byType(TarjetaResumen)),
  );
  return tarjeta.alToque != null;
}

Future<void> _abrirConfirmacion(WidgetTester tester) async {
  await tester.tap(find.text('Lavado exprés'));
  await tester.pumpAndSettle();
}

void main() {
  pruebaLealtad('mientras carga muestra esqueleto', (tester) async {
    await tester.pumpWidget(appLealtad(_pantalla, repoDeEjemplo()));
    expect(find.byType(Esqueleto), findsWidgets);
    await tester.pumpAndSettle();
    expect(find.byType(Esqueleto), findsNothing);
  });

  pruebaLealtad('muestra el saldo y cada recompensa con su costo '
      '(V2-M12.03)', (tester) async {
    await tester.pumpWidget(appLealtad(_pantalla, repoDeEjemplo()));
    await tester.pumpAndSettle();

    expect(find.text('Tienes 1,330 puntos'), findsOneWidget);
    expect(find.byType(TarjetaRecompensa), findsNWidgets(3));
    expect(find.text('300 puntos'), findsOneWidget);
    expect(find.text('400 puntos'), findsOneWidget);
    expect(find.text('1,500 puntos'), findsOneWidget);
    expect(
      find.text('Lavado exterior a mano mientras esperas.'),
      findsOneWidget,
    );
  });

  pruebaLealtad('las que no alcanzan o se agotaron no se tocan y dicen por '
      'que', (tester) async {
    await tester.pumpWidget(appLealtad(_pantalla, repoDeEjemplo()));
    await tester.pumpAndSettle();

    expect(find.text('Disponible'), findsOneWidget);
    expect(find.text('Agotada'), findsOneWidget);
    expect(find.text('Te faltan 170'), findsOneWidget);
    expect(_tocable(tester, 'Lavado exprés'), isTrue);
    expect(_tocable(tester, 'Termo CareCar'), isFalse);
    expect(_tocable(tester, 'Kit de tapetes'), isFalse);
    await tester.tap(find.text('Termo CareCar'));
    await tester.tap(find.text('Kit de tapetes'));
    await tester.pumpAndSettle();
    expect(find.byType(Dialogo), findsNothing);
  });

  pruebaLealtad('confirma con el costo y el saldo que queda', (tester) async {
    final repo = repoDeEjemplo();
    await tester.pumpWidget(appLealtad(_pantalla, repo));
    await tester.pumpAndSettle();
    await _abrirConfirmacion(tester);

    expect(find.text('¿Canjear Lavado exprés?'), findsOneWidget);
    expect(find.text('Cuesta 300 puntos. Te quedarán 1,030.'), findsOneWidget);

    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(find.byType(Dialogo), findsNothing);
    expect(repo.canjeadas, isEmpty);
  });

  pruebaLealtad('al canjear abre el codigo con QR y baja el saldo', (
    tester,
  ) async {
    final repo = repoDeEjemplo();
    await tester.pumpWidget(appLealtadEnrutada(repo, inicial: rutaRecompensas));
    await tester.pumpAndSettle();
    await _abrirConfirmacion(tester);
    await tester.tap(find.text('Canjear'));
    await tester.pumpAndSettle();

    expect(repo.canjeadas, [1]);
    expect(find.byType(PantallaCanje), findsOneWidget);
    expect(find.text('K7XQ2MP1'), findsOneWidget);
    expect(repo.resumenActual.saldo, 1030);
  });

  pruebaLealtad('si ya no alcanza lo explica y vuelve a pedir el saldo', (
    tester,
  ) async {
    final repo = repoDeEjemplo()
      ..rechazoCanje = MotivoRechazoCanje.saldoInsuficiente;
    await tester.pumpWidget(appLealtad(_pantalla, repo));
    await tester.pumpAndSettle();
    final pedidos = repo.resumenesPedidos;
    await _abrirConfirmacion(tester);
    await tester.tap(find.text('Canjear'));
    await tester.pumpAndSettle();

    expect(find.text('No se pudo canjear'), findsOneWidget);
    expect(
      find.text('Ya no te alcanzan los puntos para esta recompensa.'),
      findsOneWidget,
    );
    expect(repo.resumenesPedidos, greaterThan(pedidos));
    await tester.tap(find.text('Entendido'));
    await tester.pumpAndSettle();
    expect(find.byType(Dialogo), findsNothing);
  });

  pruebaLealtad('si se agoto lo explica', (tester) async {
    final repo = repoDeEjemplo()..rechazoCanje = MotivoRechazoCanje.agotada;
    await tester.pumpWidget(appLealtad(_pantalla, repo));
    await tester.pumpAndSettle();
    await _abrirConfirmacion(tester);
    await tester.tap(find.text('Canjear'));
    await tester.pumpAndSettle();

    expect(find.text('Esta recompensa se acaba de agotar.'), findsOneWidget);
  });

  pruebaLealtad('sin recompensas muestra el estado vacio', (tester) async {
    await tester.pumpWidget(
      appLealtad(_pantalla, RepositorioLealtadFake(resumen: resumenPlata)),
    );
    await tester.pumpAndSettle();
    expect(find.byType(EstadoVacio), findsOneWidget);
    expect(find.text('Aún no hay recompensas'), findsOneWidget);
  });

  pruebaLealtad('sin conexion lo dice', (tester) async {
    await tester.pumpWidget(
      appLealtad(_pantalla, repoDeEjemplo()..falla = const SinConexion()),
    );
    await tester.pumpAndSettle();
    final error = tester.widget<EstadoError>(find.byType(EstadoError));
    expect(error.causa, CausaError.sinConexion);
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
}
