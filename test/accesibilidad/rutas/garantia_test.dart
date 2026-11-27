import 'package:carecar_mobile/modulos/citas/citas.dart';
import 'package:carecar_mobile/modulos/citas/datos/repositorio_citas_fake.dart';
import 'package:carecar_mobile/modulos/garantia/datos/repositorio_garantia_fake.dart';
import 'package:carecar_mobile/modulos/garantia/garantia.dart';
import 'package:carecar_mobile/nucleo/eventos/eventos_en_vivo_fake.dart';
import 'package:carecar_mobile/nucleo/eventos/proveedores_eventos.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../ayudas/auditoria_rutas.dart';
import '../../modulos/garantia/ayudas_garantia.dart';

void main() {
  testWidgets('las pantallas de garantía pasan la auditoría', (tester) async {
    await montarParaAuditar(
      tester,
      overrides: [
        repositorioGarantiaProvider.overrideWithValue(
          RepositorioGarantiaFake(
            garantia: garantiaDeEjemplo(),
            campanas: campanasDeEjemplo(),
          ),
        ),
        repositorioCitasProvider.overrideWithValue(
          RepositorioCitasFake(reloj: () => hoyGarantia),
        ),
        relojCitasProvider.overrideWithValue(() => hoyGarantia),
        eventosEnVivoProvider.overrideWithValue(EventosEnVivoFake()),
      ],
    );
    await auditarRutas(tester, {
      rutaGarantiaVehiculo(5): PantallaGarantia,
      rutaCampanasVehiculo(5): PantallaCampanas,
      rutaCampanaVehiculo(5, 7): PantallaCampana,
    });
    await auditarRutas(tester, {
      rutaAgendarCampana(5, 7): PantallaAgendarCampana,
    }, conCalendario: true);
  });
}
