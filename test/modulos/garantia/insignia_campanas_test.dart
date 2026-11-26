import 'package:carecar_mobile/api/excepciones.dart';
import 'package:carecar_mobile/modulos/garantia/datos/repositorio_garantia_fake.dart';
import 'package:carecar_mobile/modulos/garantia/dominio/campana_seguridad.dart';
import 'package:carecar_mobile/modulos/garantia/garantia.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/insignia.dart';
import 'package:flutter_test/flutter_test.dart';

import 'ayudas_garantia.dart';

const _insignia = InsigniaCampanas(vehiculoId: 5);

void main() {
  pruebaGarantia('con una campana pendiente aparece en el garaje (V2-M10.02)', (
    tester,
  ) async {
    await tester.pumpWidget(
      appGarantia(
        _insignia,
        RepositorioGarantiaFake(campanas: campanasDeEjemplo()),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      find.widgetWithText(Insignia, 'Campaña de seguridad'),
      findsOneWidget,
    );
  });

  pruebaGarantia('sin pendientes no ocupa lugar', (tester) async {
    await tester.pumpWidget(
      appGarantia(
        _insignia,
        RepositorioGarantiaFake(
          campanas: [
            campana(estado: EstadoCampana.agendada, citaId: 3),
            campana(id: 10, estado: EstadoCampana.atendida),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(Insignia), findsNothing);
  });

  pruebaGarantia('si falla no muestra nada', (tester) async {
    await tester.pumpWidget(
      appGarantia(
        _insignia,
        RepositorioGarantiaFake(
          campanas: campanasDeEjemplo(),
          falla: const SinConexion('sin red'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(Insignia), findsNothing);
  });
}
