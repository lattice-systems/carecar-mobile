import 'package:carecar_mobile/modulos/asistencia/asistencia.dart';
import 'package:carecar_mobile/modulos/asistencia/datos/repositorio_asistencia_fake.dart';
import 'package:carecar_mobile/modulos/vehiculos/datos/repositorio_garaje_fake.dart';
import 'package:carecar_mobile/modulos/vehiculos/presentacion/proveedores_vehiculos.dart';
import 'package:carecar_mobile/nucleo/mapas/mapas.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../ayudas/auditoria_rutas.dart';

void main() {
  testWidgets('las pantallas de asistencia pasan la auditoría', (tester) async {
    await montarParaAuditar(
      tester,
      overrides: [
        repositorioAsistenciaProvider.overrideWithValue(
          RepositorioAsistenciaFake(),
        ),
        repositorioGarajeProvider.overrideWithValue(RepositorioGarajeFake()),
        proveedorUbicacionProvider.overrideWithValue(UbicacionFalsa()),
      ],
    );
    await auditarRutas(tester, {
      rutaAsistenciaGuias: PantallaGuias,
      rutaGuiaDeEmergencia(TipoGuia.llanta): PantallaGuia,
      rutaPedirAyuda: PantallaPedirAyuda,
      rutaLlamarRapido: PantallaLlamarRapido,
    });
  });
}
