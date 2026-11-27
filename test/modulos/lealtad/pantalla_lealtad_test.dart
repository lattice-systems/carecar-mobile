import 'package:carecar_mobile/api/excepciones.dart';
import 'package:carecar_mobile/modulos/lealtad/datos/repositorio_lealtad_fake.dart';
import 'package:carecar_mobile/modulos/lealtad/dominio/lealtad.dart';
import 'package:carecar_mobile/modulos/lealtad/presentacion/pantalla_lealtad.dart';
import 'package:carecar_mobile/modulos/lealtad/presentacion/proveedores_lealtad.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/esqueleto.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/estado_error.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/grupo_lista.dart';
import 'package:carecar_mobile/nucleo/eventos/eventos_en_vivo.dart';
import 'package:carecar_mobile/nucleo/eventos/eventos_en_vivo_fake.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../ayudas/auditoria_accesibilidad.dart';
import '../../ayudas/tema_pista.dart';
import 'ayudas_lealtad.dart';

const _pantalla = PantallaLealtad();

void main() {
  pruebaLealtad('mientras carga muestra esqueleto', (tester) async {
    await tester.pumpWidget(appLealtad(_pantalla, repoDeEjemplo()));
    expect(find.byType(Esqueleto), findsWidgets);
    await tester.pumpAndSettle();
    expect(find.byType(Esqueleto), findsNothing);
  });

  pruebaLealtad('muestra saldo, nivel y lo que falta para subir '
      '(V2-M12.01)', (tester) async {
    await tester.pumpWidget(appLealtad(_pantalla, repoDeEjemplo()));
    await tester.pumpAndSettle();

    expect(find.text('Mis puntos'), findsWidgets);
    expect(find.text('1,330 puntos'), findsOneWidget);
    expect(find.text('Nivel Plata'), findsOneWidget);
    expect(find.text('Te faltan 2,370 puntos para Oro'), findsOneWidget);
    expect(find.text('1,630 ganados en 12 meses'), findsOneWidget);
  });

  pruebaLealtad('el lector oye saldo, nivel, lo que falta y el avance', (
    tester,
  ) async {
    await tester.pumpWidget(appLealtad(_pantalla, repoDeEjemplo()));
    await tester.pumpAndSettle();

    final tarjeta = find.bySemanticsLabel(RegExp(r'^1,330 puntos, '));
    expect(tarjeta, findsOneWidget);
    final nodo = tester.getSemantics(tarjeta);
    expect(nodo.label, contains('Nivel Plata'));
    expect(nodo.label, contains('Te faltan 2,370 puntos para Oro'));
    expect(nodo.value, '41 %');
  });

  pruebaLealtad('en Oro dice que ya esta en el maximo', (tester) async {
    await tester.pumpWidget(
      appLealtad(_pantalla, repoDeEjemplo(resumen: resumenOro)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Nivel Oro'), findsOneWidget);
    expect(find.text('Ya estás en el nivel más alto.'), findsOneWidget);
    expect(find.textContaining('Te faltan'), findsNothing);
    final nodo = tester.getSemantics(
      find.bySemanticsLabel(RegExp(r'^5,200 puntos, ')),
    );
    expect(nodo.value, '100 %');
  });

  pruebaLealtad('un cliente nuevo ve 0 puntos en Bronce sin error', (
    tester,
  ) async {
    await tester.pumpWidget(appLealtad(_pantalla, RepositorioLealtadFake()));
    await tester.pumpAndSettle();

    expect(find.text('0 puntos'), findsOneWidget);
    expect(find.text('Nivel Bronce'), findsOneWidget);
    expect(find.text('Te faltan 1,500 puntos para Plata'), findsOneWidget);
    expect(find.byType(EstadoError), findsNothing);
  });

  pruebaLealtad('ofrece recompensas, canjes, movimientos y referir', (
    tester,
  ) async {
    await tester.pumpWidget(appLealtad(_pantalla, repoDeEjemplo()));
    await tester.pumpAndSettle();

    final grupo = tester.widget<GrupoLista>(find.byType(GrupoLista));
    expect(grupo.filas.map((f) => f.titulo), [
      'Recompensas',
      'Mis canjes',
      'Movimientos',
      'Referir a un amigo',
    ]);
    expect(grupo.filas.every((f) => f.alToque != null), isTrue);
  });

  pruebaLealtad('si falla muestra el error y reintenta', (tester) async {
    final repo = repoDeEjemplo()..falla = Exception('500');
    await tester.pumpWidget(appLealtad(_pantalla, repo));
    await tester.pumpAndSettle();
    expect(find.byType(EstadoError), findsOneWidget);

    repo.falla = null;
    await tester.tap(find.text('Reintentar'));
    await tester.pumpAndSettle();
    expect(find.text('1,330 puntos'), findsOneWidget);
  });

  pruebaLealtad('sin conexion lo dice', (tester) async {
    await tester.pumpWidget(
      appLealtad(_pantalla, repoDeEjemplo()..falla = const SinConexion()),
    );
    await tester.pumpAndSettle();
    final error = tester.widget<EstadoError>(find.byType(EstadoError));
    expect(error.causa, CausaError.sinConexion);
  });

  pruebaLealtad('con puntos.movidos el saldo se actualiza solo '
      '(V2-M12.02)', (tester) async {
    final repo = repoDeEjemplo();
    final eventos = EventosEnVivoFake();
    await tester.pumpWidget(appLealtad(_pantalla, repo, eventos: eventos));
    await tester.pumpAndSettle();
    final pedidos = repo.resumenesPedidos;

    repo.resumenActual = const ResumenLealtad(
      saldo: 1495,
      nivel: NivelLealtad.plata,
      ganados: 1795,
      siguienteNivel: NivelLealtad.oro,
      puntosParaSiguiente: 2205,
      codigoReferido: 'CC00001',
    );
    eventos.emitir(eventoPuntosMovidos, {
      'puntos': 165,
      'motivo': 'SERVICIO',
      'saldo': 1495,
    });
    await tester.pumpAndSettle();

    expect(repo.resumenesPedidos, pedidos + 1);
    expect(find.text('1,495 puntos'), findsOneWidget);
    expect(find.byType(Esqueleto), findsNothing);
  });

  pruebaLealtad('al volver la conexion pide de nuevo el saldo', (tester) async {
    final repo = repoDeEjemplo();
    final eventos = EventosEnVivoFake();
    await tester.pumpWidget(appLealtad(_pantalla, repo, eventos: eventos));
    await tester.pumpAndSettle();
    final pedidos = repo.resumenesPedidos;

    eventos.emitir(eventoReconectado);
    await tester.pumpAndSettle();
    expect(repo.resumenesPedidos, pedidos + 1);
  });

  for (final escenario in Escenario.values) {
    pruebaLealtad('se ve sin desbordes en ${escenario.name}', (tester) async {
      await tester.pumpWidget(
        appLealtad(_pantalla, repoDeEjemplo(), escenario: escenario),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.byType(PantallaLealtad), findsOneWidget);
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
