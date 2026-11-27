import 'package:carecar_mobile/modulos/citas/citas.dart';
import 'package:carecar_mobile/modulos/citas/datos/repositorio_citas_fake.dart';
import 'package:carecar_mobile/modulos/mantenimiento/datos/repositorio_mantenimiento_fake.dart';
import 'package:carecar_mobile/modulos/mantenimiento/mantenimiento.dart';
import 'package:carecar_mobile/modulos/vehiculos/datos/repositorio_garaje_fake.dart';
import 'package:carecar_mobile/modulos/vehiculos/vehiculos.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../ayudas/auditoria_rutas.dart';

void main() {
  testWidgets('las pantallas de mantenimiento pasan la auditoría', (
    tester,
  ) async {
    await montarParaAuditar(
      tester,
      overrides: [
        repositorioMantenimientoProvider.overrideWithValue(
          RepositorioMantenimientoFake(),
        ),
        repositorioCitasProvider.overrideWithValue(RepositorioCitasFake()),
        repositorioGarajeProvider.overrideWithValue(RepositorioGarajeFake()),
        relojCitasProvider.overrideWithValue(() => DateTime(2026, 11, 23)),
      ],
    );
    await auditarRutas(tester, {
      rutaMantenimientoVehiculo(1): PantallaPlanMantenimiento,
      rutaKilometraje(1): PantallaRegistrarKm,
    });
  });
}
