import 'package:carecar_mobile/api/excepciones.dart';
import 'package:carecar_mobile/modulos/garantia/datos/repositorio_garantia_fake.dart';
import 'package:carecar_mobile/modulos/garantia/dominio/campana_seguridad.dart';
import 'package:carecar_mobile/modulos/garantia/presentacion/pantalla_campana.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/aviso.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/estado_error.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/estado_vacio.dart';
import 'package:carecar_mobile/nucleo/eventos/eventos_en_vivo_fake.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../ayudas/tema_pista.dart';
import 'ayudas_garantia.dart';

const _critica = PantallaCampana(vehiculoId: 5, campanaId: 7);

void main() {
  pruebaGarantia('muestra que pasa y que hacer (V2-M10.02)', (tester) async {
    await tester.pumpWidget(
      appGarantia(
        _critica,
        RepositorioGarantiaFake(campanas: campanasDeEjemplo()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Bolsa de aire del conductor'), findsWidgets);
    expect(find.text('Campaña RC-24-017'), findsWidgets);
    expect(find.text('Qué pasa'), findsOneWidget);
    expect(
      find.text('El inflador puede activarse con fuerza de más.'),
      findsOneWidget,
    );
    expect(find.text('Qué hacer'), findsOneWidget);
    expect(
      find.text('Agenda una revisión; el cambio no tiene costo.'),
      findsOneWidget,
    );
  });

  pruebaGarantia('una critica pendiente se avisa y se puede agendar '
      '(V2-M10.03)', (tester) async {
    await tester.pumpWidget(
      appGarantia(
        _critica,
        RepositorioGarantiaFake(campanas: campanasDeEjemplo()),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      find.widgetWithText(Aviso, 'Atiende esta campaña cuanto antes'),
      findsOneWidget,
    );
    expect(find.text('Agendar atención'), findsOneWidget);
    expect(find.text('Ver mis citas'), findsNothing);
  });

  pruebaGarantia('la agendada lleva a las citas', (tester) async {
    await tester.pumpWidget(
      appGarantia(
        const PantallaCampana(vehiculoId: 5, campanaId: 9),
        RepositorioGarantiaFake(
          campanas: [campana(estado: EstadoCampana.agendada, citaId: 31)],
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Agendada'), findsOneWidget);
    expect(find.text('Ver mis citas'), findsOneWidget);
    expect(find.text('Agendar atención'), findsNothing);
  });

  pruebaGarantia('la atendida no tiene accion', (tester) async {
    await tester.pumpWidget(
      appGarantia(
        const PantallaCampana(vehiculoId: 5, campanaId: 4),
        RepositorioGarantiaFake(campanas: campanasDeEjemplo()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Atendida'), findsOneWidget);
    expect(find.text('Agendar atención'), findsNothing);
    expect(find.text('Ver mis citas'), findsNothing);
    expect(find.byType(Aviso), findsNothing);
  });

  pruebaGarantia('si la campana ya no esta lo dice', (tester) async {
    await tester.pumpWidget(
      appGarantia(
        const PantallaCampana(vehiculoId: 5, campanaId: 99),
        RepositorioGarantiaFake(campanas: campanasDeEjemplo()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(EstadoVacio), findsOneWidget);
    expect(find.text('Ya no encontramos esta campaña'), findsOneWidget);
  });

  pruebaGarantia('si falla deja reintentar', (tester) async {
    final repo = RepositorioGarantiaFake(
      campanas: campanasDeEjemplo(),
      falla: const SinConexion('sin red'),
    );
    await tester.pumpWidget(appGarantia(_critica, repo));
    await tester.pumpAndSettle();
    expect(find.byType(EstadoError), findsOneWidget);

    repo.falla = null;
    await tester.tap(find.text('Reintentar'));
    await tester.pumpAndSettle();
    expect(find.text('Qué pasa'), findsOneWidget);
  });

  pruebaGarantia('al agendarse en otro lado cambia sola', (tester) async {
    final eventos = EventosEnVivoFake();
    final repo = RepositorioGarantiaFake(campanas: campanasDeEjemplo());
    await tester.pumpWidget(appGarantia(_critica, repo, eventos: eventos));
    await tester.pumpAndSettle();
    expect(find.text('Agendar atención'), findsOneWidget);

    repo.campanasActuales = [
      campana(id: 7, estado: EstadoCampana.agendada, citaId: 31),
    ];
    eventos.emitir('campana.nueva', {'vehiculoId': 5, 'campanaId': 8});
    await tester.pumpAndSettle();
    expect(find.text('Ver mis citas'), findsOneWidget);
  });

  for (final escenario in Escenario.values) {
    pruebaGarantia('se ve sin desbordes en $escenario', (tester) async {
      await tester.pumpWidget(
        appGarantia(
          _critica,
          RepositorioGarantiaFake(campanas: campanasDeEjemplo()),
          escenario: escenario,
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}
