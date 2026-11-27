import 'package:carecar_mobile/api/excepciones.dart';
import 'package:carecar_mobile/modulos/lealtad/datos/repositorio_lealtad_fake.dart';
import 'package:carecar_mobile/modulos/lealtad/dominio/lealtad.dart';
import 'package:carecar_mobile/modulos/lealtad/presentacion/pantalla_movimientos.dart';
import 'package:carecar_mobile/modulos/lealtad/presentacion/proveedores_lealtad.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/estado_error.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/estado_vacio.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/grupo_lista.dart';
import 'package:carecar_mobile/nucleo/eventos/eventos_en_vivo_fake.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

import '../../ayudas/auditoria_accesibilidad.dart';
import '../../ayudas/tema_pista.dart';
import 'ayudas_lealtad.dart';

const _pantalla = PantallaMovimientos();

String _fecha(DateTime momento) =>
    DateFormat.yMMMd('es').format(momento.toLocal());

int _filas(WidgetTester tester) =>
    tester.widget<GrupoLista>(find.byType(GrupoLista)).filas.length;

void main() {
  pruebaLealtad('muestra puntos con signo, motivo, fecha y referencia '
      '(V2-M12.05)', (tester) async {
    await tester.pumpWidget(appLealtad(_pantalla, repoDeEjemplo()));
    await tester.pumpAndSettle();

    expect(find.text('−300'), findsOneWidget);
    expect(find.text('+500'), findsOneWidget);
    expect(find.text('+230'), findsOneWidget);
    expect(find.text('+900'), findsOneWidget);
    expect(find.text('Canje de recompensa'), findsOneWidget);
    expect(find.text('Amigo referido'), findsOneWidget);
    expect(find.text('Servicio en el taller'), findsOneWidget);
    expect(find.text('Ajuste de la agencia'), findsOneWidget);
    expect(
      find.text('${_fecha(DateTime.utc(2026, 8, 30, 18))} · Orden 2'),
      findsOneWidget,
    );
    expect(
      find.text('${_fecha(DateTime.utc(2026, 10, 10, 18))} · Canje 1'),
      findsOneWidget,
    );
    expect(find.text(_fecha(DateTime.utc(2026, 7, 1, 18))), findsOneWidget);
  });

  pruebaLealtad('lo ganado va en verde y lo gastado en el color del texto', (
    tester,
  ) async {
    await tester.pumpWidget(appLealtad(_pantalla, repoDeEjemplo()));
    await tester.pumpAndSettle();
    final ganado = tester.widget<Text>(find.text('+230'));
    final gastado = tester.widget<Text>(find.text('−300'));
    expect(ganado.style!.color, isNot(gastado.style!.color));
  });

  pruebaLealtad('el lector oye cuanto gano o uso en palabras', (tester) async {
    await tester.pumpWidget(appLealtad(_pantalla, repoDeEjemplo()));
    await tester.pumpAndSettle();
    expect(
      find.bySemanticsLabel(RegExp(r'Orden 2\. Ganaste 230 puntos$')),
      findsOneWidget,
    );
    expect(
      find.bySemanticsLabel(RegExp(r'Canje 1\. Usaste 300 puntos$')),
      findsOneWidget,
    );
  });

  test('la suma de los movimientos de ejemplo es su saldo', () {
    final suma = movimientosDeEjemplo().fold<int>(0, (t, m) => t + m.puntos);
    expect(suma, resumenPlata.saldo);
  });

  pruebaLealtad('al llegar al final pide la pagina siguiente y la suma', (
    tester,
  ) async {
    final repo = RepositorioLealtadFake(movimientos: muchosMovimientos(25));
    await tester.pumpWidget(appLealtad(_pantalla, repo));
    await tester.pumpAndSettle();

    expect(repo.paginasPedidas, [0, 1]);
    expect(_filas(tester), 25);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  pruebaLealtad('si falla la pagina siguiente conserva lo cargado y '
      'reintenta', (tester) async {
    final repo = RepositorioLealtadFake(
      movimientos: muchosMovimientos(25),
      fallaAlCargarMas: Exception('500'),
    );
    await tester.pumpWidget(appLealtad(_pantalla, repo));
    await tester.pumpAndSettle();

    // El aviso queda al final de la lista, ya construido pero fuera de la
    // vista; se busca tambien fuera de escena y se desplaza hasta el.
    final aviso = find.text(
      'No pudimos cargar más movimientos.',
      skipOffstage: false,
    );
    expect(aviso, findsOneWidget);
    expect(_filas(tester), tamanoPaginaMovimientos);

    repo.fallaAlCargarMas = null;
    final reintentar = find.text('Reintentar', skipOffstage: false);
    await tester.ensureVisible(reintentar);
    await tester.pumpAndSettle();
    await tester.tap(reintentar);
    await tester.pumpAndSettle();
    expect(_filas(tester), 25);
    expect(aviso, findsNothing);
  });

  pruebaLealtad('con puntos.movidos vuelve a pedir la primera pagina', (
    tester,
  ) async {
    final repo = repoDeEjemplo();
    final eventos = EventosEnVivoFake();
    await tester.pumpWidget(appLealtad(_pantalla, repo, eventos: eventos));
    await tester.pumpAndSettle();

    repo.movimientosActuales = [
      MovimientoPuntos(
        id: 5,
        puntos: 165,
        motivo: MotivoPuntos.servicio,
        referenciaTipo: 'ORDEN',
        referenciaId: 41,
        creadoEn: hoyLealtad.toUtc(),
      ),
      ...repo.movimientosActuales,
    ];
    eventos.emitir(eventoPuntosMovidos, {
      'puntos': 165,
      'motivo': 'SERVICIO',
      'saldo': 1495,
    });
    await tester.pumpAndSettle();

    expect(repo.paginasPedidas, [0, 0]);
    expect(find.text('+165'), findsOneWidget);
  });

  pruebaLealtad('sin movimientos muestra el estado vacio', (tester) async {
    await tester.pumpWidget(appLealtad(_pantalla, RepositorioLealtadFake()));
    await tester.pumpAndSettle();
    expect(find.byType(EstadoVacio), findsOneWidget);
    expect(find.text('Aún no tienes movimientos'), findsOneWidget);
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
