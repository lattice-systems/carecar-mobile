import 'package:carecar_mobile/modulos/lealtad/lealtad.dart';
import 'package:carecar_mobile/nucleo/eventos/eventos_en_vivo_fake.dart';
import 'package:carecar_mobile/nucleo/eventos/proveedores_eventos.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../ayudas/auditoria_rutas.dart';
import '../../modulos/lealtad/ayudas_lealtad.dart';

void main() {
  testWidgets('las pantallas de lealtad pasan la auditoría', (tester) async {
    await montarParaAuditar(
      tester,
      overrides: [
        repositorioLealtadProvider.overrideWithValue(repoDeEjemplo()),
        eventosEnVivoProvider.overrideWithValue(EventosEnVivoFake()),
      ],
    );
    await auditarRutas(tester, {
      rutaLealtad: PantallaLealtad,
      rutaRecompensas: PantallaRecompensas,
      rutaCanjes: PantallaCanjes,
      rutaCanje(2): PantallaCanje,
      rutaMovimientos: PantallaMovimientos,
      rutaReferir: PantallaReferir,
    });
  });
}
