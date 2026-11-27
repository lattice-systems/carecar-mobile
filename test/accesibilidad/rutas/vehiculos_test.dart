import 'package:carecar_mobile/api/modelos/vehiculo.dart';
import 'package:carecar_mobile/manuales/servicio_manuales.dart';
import 'package:carecar_mobile/modulos/vehiculos/dominio/ficha_tecnica_vehiculo.dart';
import 'package:carecar_mobile/modulos/vehiculos/dominio/repositorio_ficha_tecnica.dart';
import 'package:carecar_mobile/modulos/vehiculos/presentacion/proveedores_vehiculos.dart';
import 'package:carecar_mobile/modulos/vehiculos/vehiculos.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../ayudas/api_falsa.dart';
import '../../ayudas/auditoria_rutas.dart';

class _SinFicha implements RepositorioFichaTecnica {
  @override
  Future<FichaTecnicaVehiculo?> ficha(VehiculoGaraje vehiculo) async => null;
}

class _SinManual implements ServicioManuales {
  @override
  Future<DocumentoManual> cargar(Vehiculo vehiculo) async =>
      throw const FalloManual('sin manual');
}

void main() {
  testWidgets('las pantallas de vehículos pasan la auditoría', (tester) async {
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
        repositorioFichaTecnicaProvider.overrideWithValue(_SinFicha()),
        servicioManualesProvider.overrideWithValue(_SinManual()),
      ],
    );
    await auditarRutas(tester, {
      rutaGaraje: PantallaGaraje,
      rutaDetalleVehiculo(1): PantallaDetalleVehiculo,
      rutaFichaTecnicaVehiculo(1): PantallaFichaTecnica,
      rutaManualVehiculo(1): PantallaManual,
    });
  });
}
