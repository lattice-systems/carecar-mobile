import 'package:carecar_mobile/api/modelos/vehiculo.dart';
import 'package:carecar_mobile/modulos/bitacora/bitacora.dart';
import 'package:carecar_mobile/modulos/bitacora/datos/repositorio_bitacora_fake.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../ayudas/api_falsa.dart';
import '../../ayudas/auditoria_rutas.dart';
import '../../modulos/bitacora/arnes_bitacora.dart';

void main() {
  testWidgets('las pantallas de bitácora pasan la auditoría', (tester) async {
    await montarParaAuditar(
      tester,
      api: ApiFalsa()
        ..alPedirVehiculos = () async => const [
          Vehiculo(
            id: 1,
            vin: 'VIN1',
            modelo: 'CX-5',
            anio: 2024,
            marca: 'Mazda',
            placas: 'ABC-123',
            kilometraje: 12500,
          ),
        ],
      overrides: [
        repositorioBitacoraProvider.overrideWithValue(
          RepositorioBitacoraFake(
            gastos: [carga(1, DateTime(2026, 10), 10000, 40, 800)],
          ),
        ),
      ],
    );
    await auditarRutas(tester, {
      rutaBitacoraVehiculo(1): PantallaBitacora,
      rutaEstadisticasBitacora(1): PantallaEstadisticas,
      rutaExportarBitacora(1): PantallaExportar,
    });
  });
}
