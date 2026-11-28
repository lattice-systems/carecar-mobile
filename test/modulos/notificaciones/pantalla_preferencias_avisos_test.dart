import 'package:carecar_mobile/modulos/notificaciones/dominio/aviso_cliente.dart';
import 'package:carecar_mobile/modulos/notificaciones/dominio/preferencias_de_avisos.dart';
import 'package:carecar_mobile/modulos/notificaciones/presentacion/pantalla_preferencias_avisos.dart';
import 'package:carecar_mobile/modulos/notificaciones/presentacion/proveedores_preferencias.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/control_binario.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../ayudas/tema_pista.dart';

/// V2-M06.05 · la pantalla de preferencias.
///
/// Se guarda al tocar, así que lo que importa comprobar es que el interruptor
/// **no se quede mintiendo** si el servidor falla.
void main() {
  late _RepoFalso repo;

  Future<void> montar(
    WidgetTester tester, {
    HorarioSilencioso? silencio,
    Escenario escenario = Escenario.claro,
  }) async {
    tester.view.physicalSize = const Size(400, 2000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    repo = _RepoFalso(silencio: silencio);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [repositorioPreferenciasProvider.overrideWithValue(repo)],
        child: conTemaPista(
          const PantallaPreferenciasAvisos(),
          escenario: escenario,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Interruptor interruptor(WidgetTester tester, Key llave) =>
      tester.widget<Interruptor>(find.byKey(llave));

  testWidgets('muestra las seis categorías, promociones apagada', (
    tester,
  ) async {
    await montar(tester);

    for (final c in [
      CategoriaDeAviso.taller,
      CategoriaDeAviso.citas,
      CategoriaDeAviso.mantenimiento,
      CategoriaDeAviso.documentos,
      CategoriaDeAviso.mensajes,
      CategoriaDeAviso.promociones,
    ]) {
      expect(
        find.byKey(PantallaPreferenciasAvisos.categoria(c)),
        findsOneWidget,
        reason: 'falta $c',
      );
    }
    expect(
      interruptor(
        tester,
        PantallaPreferenciasAvisos.categoria(CategoriaDeAviso.promociones),
      ).valor,
      isFalse,
    );
  });

  testWidgets('prender promociones se guarda', (tester) async {
    await montar(tester);
    final llave = PantallaPreferenciasAvisos.categoria(
      CategoriaDeAviso.promociones,
    );

    interruptor(tester, llave).alCambiar!(true);
    await tester.pumpAndSettle();

    expect(interruptor(tester, llave).valor, isTrue);
    expect(repo.guardados, 1);
  });

  testWidgets('si el guardado falla, el interruptor vuelve y se dice', (
    tester,
  ) async {
    await montar(tester);
    repo.falla = true;
    final llave = PantallaPreferenciasAvisos.categoria(CategoriaDeAviso.taller);

    interruptor(tester, llave).alCambiar!(false);
    await tester.pumpAndSettle();

    // Un interruptor que se queda mintiendo es peor que uno lento.
    expect(interruptor(tester, llave).valor, isTrue);
    expect(find.byKey(PantallaPreferenciasAvisos.avisoFallo), findsOneWidget);
  });

  testWidgets('sin horario no se ven las horas', (tester) async {
    await montar(tester);

    expect(
      interruptor(tester, PantallaPreferenciasAvisos.interruptorSilencio).valor,
      isFalse,
    );
    expect(find.byKey(PantallaPreferenciasAvisos.botonDesde), findsNothing);
  });

  testWidgets('prender el silencio pone 22:00 a 07:00 y lo explica', (
    tester,
  ) async {
    await montar(tester);

    interruptor(
      tester,
      PantallaPreferenciasAvisos.interruptorSilencio,
    ).alCambiar!(true);
    await tester.pumpAndSettle();

    expect(find.text('Desde 22:00'), findsOneWidget);
    expect(find.text('Hasta 07:00'), findsOneWidget);
    // Que cruce la medianoche es lo normal: se dice para que nadie crea que
    // lo configuró mal.
    expect(find.textContaining('cruza la medianoche'), findsOneWidget);
  });

  testWidgets('un rango dentro del mismo día se explica distinto', (
    tester,
  ) async {
    await montar(
      tester,
      silencio: const HorarioSilencioso(
        desde: HoraDelDia(13, 0),
        hasta: HoraDelDia(15, 30),
      ),
    );

    expect(find.text('Desde 13:00'), findsOneWidget);
    expect(find.text('Hasta 15:30'), findsOneWidget);
    expect(find.textContaining('mismo día'), findsOneWidget);
  });

  testWidgets('apagar el silencio quita las horas', (tester) async {
    await montar(
      tester,
      silencio: const HorarioSilencioso(
        desde: HoraDelDia(22, 0),
        hasta: HoraDelDia(7, 0),
      ),
    );

    interruptor(
      tester,
      PantallaPreferenciasAvisos.interruptorSilencio,
    ).alCambiar!(false);
    await tester.pumpAndSettle();

    expect(find.byKey(PantallaPreferenciasAvisos.botonDesde), findsNothing);
  });

  testWidgets('con letra al 200 % no desborda', (tester) async {
    await montar(tester, escenario: Escenario.letraGrande);

    expect(tester.takeException(), isNull);
  });

  testWidgets('en oscuro se ve', (tester) async {
    await montar(tester, escenario: Escenario.oscuro);

    expect(tester.takeException(), isNull);
    expect(
      find.byKey(PantallaPreferenciasAvisos.categoria(CategoriaDeAviso.taller)),
      findsOneWidget,
    );
  });
}

class _RepoFalso implements RepositorioPreferenciasAvisos {
  _RepoFalso({HorarioSilencioso? silencio})
    : _actual = PreferenciasDeAvisos(
        porCategoria: const {
          CategoriaDeAviso.taller: true,
          CategoriaDeAviso.citas: true,
          CategoriaDeAviso.mantenimiento: true,
          CategoriaDeAviso.documentos: true,
          CategoriaDeAviso.promociones: false,
          CategoriaDeAviso.mensajes: true,
        },
        silencio: silencio,
      );

  bool falla = false;
  int guardados = 0;
  PreferenciasDeAvisos _actual;

  @override
  Future<PreferenciasDeAvisos> preferencias() async => _actual;

  @override
  Future<PreferenciasDeAvisos> guardar(PreferenciasDeAvisos nuevas) async {
    if (falla) throw Exception('no se pudo guardar');
    guardados++;
    _actual = nuevas;
    return nuevas;
  }
}
