import 'package:carecar_mobile/api/excepciones.dart';
import 'package:carecar_mobile/modulos/pagos/datos/repositorio_datos_fiscales_fake.dart';
import 'package:carecar_mobile/modulos/pagos/presentacion/pantalla_datos_fiscales.dart';
import 'package:carecar_mobile/modulos/pagos/presentacion/pantalla_perfil_fiscal.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/esqueleto.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/estado_error.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/estado_vacio.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/grupo_lista.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/insignia.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../ayudas/tema_pista.dart';
import 'ayudas_pagos.dart';

const _pantalla = PantallaDatosFiscales();

void main() {
  pruebaPagos('mientras carga muestra esqueleto', (tester) async {
    await tester.pumpWidget(appPagos(_pantalla, repoDeEjemplo()));
    expect(find.byType(Esqueleto), findsWidgets);
    await tester.pumpAndSettle();
    expect(find.byType(Esqueleto), findsNothing);
  });

  pruebaPagos('lista cada perfil con RFC, persona y regimen; el '
      'predeterminado primero (V2-M08.05)', (tester) async {
    await tester.pumpWidget(appPagos(_pantalla, repoDeEjemplo()));
    await tester.pumpAndSettle();

    final grupo = tester.widget<GrupoLista>(find.byType(GrupoLista));
    expect(grupo.filas.map((f) => f.titulo), [
      'DOLORES GÓMEZ',
      'ESCUELA KEMPER URGATE',
    ]);
    expect(
      find.text('GODE561231GR8 · Persona física · Régimen 612'),
      findsOneWidget,
    );
    expect(
      find.text('EKU9003173C9 · Persona moral · Régimen 601'),
      findsOneWidget,
    );
    expect(find.widgetWithText(Insignia, 'Predeterminado'), findsOneWidget);
    expect(grupo.filas.first.etiquetaFin, 'Predeterminado');
    expect(grupo.filas.last.etiquetaFin, isNull);
    expect(find.textContaining('simuladas'), findsOneWidget);
  });

  pruebaPagos('el lector oye cual es el predeterminado', (tester) async {
    await tester.pumpWidget(appPagos(_pantalla, repoDeEjemplo()));
    await tester.pumpAndSettle();
    expect(
      find.bySemanticsLabel(RegExp(r'^DOLORES GÓMEZ\..*\. Predeterminado$')),
      findsOneWidget,
    );
  });

  pruebaPagos('tocar un perfil abre su edicion', (tester) async {
    await tester.pumpWidget(appPagosEnrutada(repoDeEjemplo()));
    await tester.pumpAndSettle();
    await tester.tap(find.text('ESCUELA KEMPER URGATE'));
    await tester.pumpAndSettle();

    final pantalla = tester.widget<PantallaPerfilFiscal>(
      find.byType(PantallaPerfilFiscal),
    );
    expect(pantalla.perfilId, 11);
    expect(find.text('Editar datos fiscales'), findsWidgets);
  });

  pruebaPagos('sin perfiles invita a agregar uno y abre el alta', (
    tester,
  ) async {
    await tester.pumpWidget(
      appPagosEnrutada(
        RepositorioDatosFiscalesFake(catalogo: catalogoDeEjemplo),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(EstadoVacio), findsOneWidget);
    expect(find.text('Aún no tienes datos fiscales'), findsOneWidget);

    await tester.tap(find.text('Agregar datos fiscales'));
    await tester.pumpAndSettle();
    expect(find.text('Nuevos datos fiscales'), findsWidgets);
  });

  pruebaPagos('si falla lo dice y reintenta', (tester) async {
    final repo = repoDeEjemplo()..falla = Exception('500');
    await tester.pumpWidget(appPagos(_pantalla, repo));
    await tester.pumpAndSettle();
    expect(find.byType(EstadoError), findsOneWidget);

    repo.falla = null;
    await tester.tap(find.text('Reintentar'));
    await tester.pumpAndSettle();
    expect(find.text('DOLORES GÓMEZ'), findsOneWidget);
  });

  pruebaPagos('sin conexion lo dice', (tester) async {
    await tester.pumpWidget(
      appPagos(_pantalla, repoDeEjemplo()..falla = const SinConexion()),
    );
    await tester.pumpAndSettle();
    final error = tester.widget<EstadoError>(find.byType(EstadoError));
    expect(error.causa, CausaError.sinConexion);
  });

  for (final escenario in Escenario.values) {
    pruebaPagos('se ve sin desbordes en ${escenario.name}', (tester) async {
      await tester.pumpWidget(
        appPagos(_pantalla, repoDeEjemplo(), escenario: escenario),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}
