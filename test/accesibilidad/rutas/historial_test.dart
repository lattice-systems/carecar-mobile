import 'package:carecar_mobile/modulos/historial/datos/repositorio_historial_fake.dart';
import 'package:carecar_mobile/modulos/historial/historial.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../ayudas/auditoria_rutas.dart';

void main() {
  testWidgets('las pantallas de historial pasan la auditoría', (tester) async {
    await montarParaAuditar(
      tester,
      overrides: [
        repositorioHistorialProvider.overrideWithValue(
          RepositorioHistorialFake(),
        ),
      ],
    );
    await auditarRutas(tester, {
      rutaHistorialVehiculo(1): PantallaHistorial,
      rutaTicketServicio(1, 21): PantallaTicket,
    });
  });
}
