import 'package:carecar_mobile/api/excepciones.dart';
import 'package:carecar_mobile/modulos/garantia/datos/repositorio_garantia_fake.dart';
import 'package:carecar_mobile/modulos/garantia/dominio/campana_seguridad.dart';
import 'package:carecar_mobile/modulos/garantia/presentacion/pantalla_campanas.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/aviso.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/esqueleto.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/estado_error.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/estado_vacio.dart';
import 'package:carecar_mobile/nucleo/eventos/eventos_en_vivo_fake.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../ayudas/auditoria_accesibilidad.dart';
import '../../ayudas/tema_pista.dart';
import 'ayudas_garantia.dart';

const _pantalla = PantallaCampanas(vehiculoId: 5);

void main() {
  pruebaGarantia('mientras carga muestra esqueleto', (tester) async {
    await tester.pumpWidget(
      appGarantia(
        _pantalla,
        RepositorioGarantiaFake(campanas: campanasDeEjemplo()),
      ),
    );
    expect(find.byType(Esqueleto), findsWidgets);
    await tester.pumpAndSettle();
    expect(find.byType(Esqueleto), findsNothing);
  });

  pruebaGarantia('muestra cada campana con codigo, gravedad y estado '
      '(V2-M10.02)', (tester) async {
    await tester.pumpWidget(
      appGarantia(
        _pantalla,
        RepositorioGarantiaFake(campanas: campanasDeEjemplo()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(TarjetaCampana), findsNWidgets(2));
    expect(find.text('Bolsa de aire del conductor'), findsOneWidget);
    expect(find.text('Campaña RC-24-017'), findsOneWidget);
    expect(find.text('Crítica'), findsOneWidget);
    expect(find.text('Pendiente'), findsOneWidget);
    expect(find.text('Tornillo del soporte del motor'), findsOneWidget);
    expect(find.text('Campaña RC-23-002'), findsOneWidget);
    expect(find.text('Gravedad media'), findsOneWidget);
    expect(find.text('Atendida'), findsOneWidget);
  });

  pruebaGarantia('cada campana se puede tocar para ver su detalle', (
    tester,
  ) async {
    await tester.pumpWidget(
      appGarantia(
        _pantalla,
        RepositorioGarantiaFake(campanas: campanasDeEjemplo()),
      ),
    );
    await tester.pumpAndSettle();
    for (final tarjeta in tester.widgetList<TarjetaCampana>(
      find.byType(TarjetaCampana),
    )) {
      expect(tarjeta.alToque, isNotNull);
    }
  });

  pruebaGarantia('una campana critica pendiente se avisa arriba', (
    tester,
  ) async {
    await tester.pumpWidget(
      appGarantia(
        _pantalla,
        RepositorioGarantiaFake(campanas: campanasDeEjemplo()),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      find.widgetWithText(Aviso, 'Atiende esta campaña cuanto antes'),
      findsOneWidget,
    );
  });

  pruebaGarantia('una critica ya atendida no se avisa', (tester) async {
    await tester.pumpWidget(
      appGarantia(
        _pantalla,
        RepositorioGarantiaFake(
          campanas: [
            campana(
              estado: EstadoCampana.atendida,
              gravedad: GravedadCampana.critica,
            ),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(Aviso), findsNothing);
  });

  pruebaGarantia('sin campanas muestra el estado vacio', (tester) async {
    await tester.pumpWidget(appGarantia(_pantalla, RepositorioGarantiaFake()));
    await tester.pumpAndSettle();
    expect(find.byType(EstadoVacio), findsOneWidget);
    expect(find.text('Tu auto no tiene campañas'), findsOneWidget);
  });

  pruebaGarantia('si falla deja reintentar', (tester) async {
    final repo = RepositorioGarantiaFake(
      campanas: campanasDeEjemplo(),
      falla: const SinConexion('sin red'),
    );
    await tester.pumpWidget(appGarantia(_pantalla, repo));
    await tester.pumpAndSettle();
    expect(find.byType(EstadoError), findsOneWidget);

    repo.falla = null;
    await tester.tap(find.text('Reintentar'));
    await tester.pumpAndSettle();
    expect(find.byType(TarjetaCampana), findsNWidgets(2));
  });

  group('en vivo (V2-M10.04)', () {
    pruebaGarantia('una campana nueva de este vehiculo aparece sola', (
      tester,
    ) async {
      final eventos = EventosEnVivoFake();
      final repo = RepositorioGarantiaFake(campanas: [campanasDeEjemplo()[1]]);
      await tester.pumpWidget(appGarantia(_pantalla, repo, eventos: eventos));
      await tester.pumpAndSettle();
      expect(find.byType(Aviso), findsNothing);

      repo.campanasActuales = campanasDeEjemplo();
      eventos.emitir('campana.nueva', {
        'vehiculoId': 5,
        'campanaId': 7,
        'codigo': 'RC-24-017',
        'titulo': 'Bolsa de aire del conductor',
        'gravedad': 'CRITICA',
        'critica': true,
      });
      await tester.pumpAndSettle();

      expect(repo.campanasPedidas, 2);
      expect(find.byType(TarjetaCampana), findsNWidgets(2));
      expect(find.byType(Aviso), findsOneWidget);
    });

    pruebaGarantia('la de otro vehiculo no la toca', (tester) async {
      final eventos = EventosEnVivoFake();
      final repo = RepositorioGarantiaFake(campanas: campanasDeEjemplo());
      await tester.pumpWidget(appGarantia(_pantalla, repo, eventos: eventos));
      await tester.pumpAndSettle();

      eventos.emitir('campana.nueva', {'vehiculoId': 99, 'campanaId': 7});
      await tester.pumpAndSettle();
      expect(repo.campanasPedidas, 1);
    });
  });

  for (final escenario in Escenario.values) {
    pruebaGarantia('se ve sin desbordes en $escenario', (tester) async {
      await tester.pumpWidget(
        appGarantia(
          _pantalla,
          RepositorioGarantiaFake(campanas: campanasDeEjemplo()),
          escenario: escenario,
        ),
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
        appGarantia(
          _pantalla,
          RepositorioGarantiaFake(campanas: campanasDeEjemplo()),
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
