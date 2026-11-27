import 'package:carecar_mobile/modulos/pagos/pagos.dart';
import 'package:carecar_mobile/modulos/pagos/presentacion/proveedores_pagos.dart';
import 'package:carecar_mobile/nucleo/eventos/eventos_en_vivo_fake.dart';
import 'package:carecar_mobile/nucleo/eventos/proveedores_eventos.dart';
import 'package:carecar_mobile/nucleo/privacidad/proteccion_de_captura.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../ayudas/auditoria_rutas.dart';
import '../../modulos/pagos/ayudas_cobro.dart';
import '../../modulos/pagos/ayudas_pagos.dart';

void main() {
  testWidgets('las pantallas de pagos pasan la auditoría', (tester) async {
    await montarParaAuditar(
      tester,
      overrides: [
        repositorioDatosFiscalesProvider.overrideWithValue(repoDeEjemplo()),
        repositorioPagosProvider.overrideWithValue(
          repoCobro(
            pagos: [pagoDeEjemplo(ordenId: 40)],
            metodos: [visaGuardada],
          ),
        ),
        hoyPagosProvider.overrideWithValue(() => hoyDePrueba),
        eventosEnVivoProvider.overrideWithValue(EventosEnVivoFake()),
        proteccionDeCapturaProvider.overrideWithValue(
          ProteccionDeCapturaFake(),
        ),
      ],
    );
    await auditarRutas(tester, {
      rutaDatosFiscales: PantallaDatosFiscales,
      rutaPerfilFiscalNuevo: PantallaPerfilFiscal,
      rutaPerfilFiscal(11): PantallaPerfilFiscal,
      rutaMisPagos: PantallaMisPagos,
      rutaPago(7): PantallaPago,
      rutaMetodosPago: PantallaMetodosPago,
      rutaPagarOrden(41): PantallaPagarOrden,
    });
  });
}
