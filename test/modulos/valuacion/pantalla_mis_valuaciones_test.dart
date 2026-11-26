import 'package:carecar_mobile/api/excepciones.dart';
import 'package:carecar_mobile/modulos/valuacion/datos/repositorio_valuacion_fake.dart';
import 'package:carecar_mobile/modulos/valuacion/presentacion/proveedores_valuacion.dart';
import 'package:carecar_mobile/modulos/valuacion/valuacion.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/estado_error.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/estado_vacio.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/tarjeta_resumen.dart';
import 'package:carecar_mobile/nucleo/eventos/eventos_en_vivo_fake.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../ayudas/auditoria_accesibilidad.dart';
import '../../ayudas/tema_pista.dart';
import 'ayudas_valuacion.dart';

void main() {
  testWidgets('lista cada valuacion con auto, estado, oferta y vigencia', (
    tester,
  ) async {
    pantallaAlta(tester);
    final repo = RepositorioValuacionFake(
      valuaciones: [ofertada(id: 2), valuacion(id: 1)],
    );
    await tester.pumpWidget(
      app(const PantallaMisValuaciones(), repositorio: repo),
    );
    await tester.pumpAndSettle();

    expect(find.byType(TarjetaResumen), findsNWidgets(2));
    expect(find.text('Con oferta'), findsOneWidget);
    expect(find.text('Por agendar'), findsOneWidget);
    expect(
      find.textContaining(r'Oferta de $112,500, vigente hasta el 4 dic 2026'),
      findsOneWidget,
    );
  });

  testWidgets('mientras carga lo anuncia', (tester) async {
    await tester.pumpWidget(
      app(
        const PantallaMisValuaciones(),
        repositorio: RepositorioValuacionFake(),
      ),
    );
    expect(find.bySemanticsLabel('Cargando la valuación'), findsOneWidget);
    await tester.pumpAndSettle();
  });

  testWidgets('vacio explica y ofrece ir a Mis estimaciones', (tester) async {
    await tester.pumpWidget(
      app(
        const PantallaMisValuaciones(),
        repositorio: RepositorioValuacionFake(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(EstadoVacio), findsOneWidget);
    expect(find.text('Aún no tienes valuaciones'), findsOneWidget);
    expect(find.text('Ir a Mis estimaciones'), findsOneWidget);
  });

  testWidgets('sin conexion lo dice y reintentar recupera', (tester) async {
    final repo = RepositorioValuacionFake(
      valuaciones: [valuacion()],
      falla: const SinConexion(),
    );
    await tester.pumpWidget(
      app(const PantallaMisValuaciones(), repositorio: repo),
    );
    await tester.pumpAndSettle();
    expect(find.byType(EstadoError), findsOneWidget);
    expect(find.text('Sin conexión'), findsOneWidget);

    repo.falla = null;
    await tester.tap(find.text('Reintentar'));
    await tester.pumpAndSettle();
    expect(find.text('Nissan March 2020'), findsOneWidget);
  });

  testWidgets('otro error tambien deja reintentar', (tester) async {
    await tester.pumpWidget(
      app(
        const PantallaMisValuaciones(),
        repositorio: RepositorioValuacionFake(
          falla: const ErrorDelServidor('x'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('No pudimos cargar esto'), findsOneWidget);
  });

  testWidgets('pide las paginas de a una', (tester) async {
    pantallaAlta(tester);
    final repo = RepositorioValuacionFake(
      valuaciones: [for (var i = 3; i >= 1; i--) valuacion(id: i)],
    );
    await tester.pumpWidget(
      app(
        const PantallaMisValuaciones(),
        repositorio: repo,
        extra: [tamanoPaginaValuacionesProvider.overrideWithValue(2)],
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(TarjetaResumen), findsNWidgets(2));

    await tester.tap(find.text('Ver más'));
    await tester.pumpAndSettle();
    expect(find.byType(TarjetaResumen), findsNWidgets(3));
    expect(find.text('Ver más'), findsNothing);
  });

  testWidgets('una oferta nueva actualiza la lista sin pasar por carga', (
    tester,
  ) async {
    final eventos = EventosEnVivoFake();
    final repo = RepositorioValuacionFake(valuaciones: [valuacion()]);
    await tester.pumpWidget(
      app(const PantallaMisValuaciones(), repositorio: repo, eventos: eventos),
    );
    await tester.pumpAndSettle();

    repo.valuaciones = [ofertada()];
    eventos.emitir('valuacion.oferta', {'valuacionId': 1});
    await tester.pumpAndSettle();

    expect(find.text('Con oferta'), findsOneWidget);
  });

  testWidgets('si la recarga en vivo falla se queda lo que se ve', (
    tester,
  ) async {
    final eventos = EventosEnVivoFake();
    final repo = RepositorioValuacionFake(valuaciones: [valuacion()]);
    await tester.pumpWidget(
      app(const PantallaMisValuaciones(), repositorio: repo, eventos: eventos),
    );
    await tester.pumpAndSettle();

    repo.falla = const SinConexion();
    eventos.emitir('conexion.restablecida');
    await tester.pumpAndSettle();

    expect(find.text('Nissan March 2020'), findsOneWidget);
    expect(find.byType(EstadoError), findsNothing);
  });

  testWidgets('claro, oscuro y letra al 200 % sin desbordar', (tester) async {
    pantallaAlta(tester);
    for (final escenario in Escenario.values) {
      await tester.pumpWidget(
        app(
          const PantallaMisValuaciones(),
          repositorio: RepositorioValuacionFake(valuaciones: [ofertada()]),
          escenario: escenario,
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: escenario.name);
      expect(find.text('Con oferta'), findsOneWidget);
      await auditarAccesibilidad(tester);
    }
  });

  testWidgets('en 320 de ancho pasa las guias en los tres escenarios', (
    tester,
  ) async {
    telefonoChicoYAlto(tester);
    for (final escenario in Escenario.values) {
      await tester.pumpWidget(
        app(
          const PantallaMisValuaciones(),
          repositorio: RepositorioValuacionFake(valuaciones: [ofertada()]),
          escenario: escenario,
          ancho: anchoTelefonoChico,
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: escenario.name);
      await auditarAccesibilidad(tester);
    }
  });
}
