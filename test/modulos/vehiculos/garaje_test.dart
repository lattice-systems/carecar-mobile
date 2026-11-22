import 'package:carecar_mobile/api/excepciones.dart';
import 'package:carecar_mobile/api/modelos/vehiculo.dart';
import 'package:carecar_mobile/modulos/vehiculos/datos/repositorio_garaje_api.dart';
import 'package:carecar_mobile/modulos/vehiculos/datos/repositorio_garaje_fake.dart';
import 'package:carecar_mobile/modulos/vehiculos/dominio/vehiculo_garaje.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../ayudas/api_falsa.dart';

void main() {
  group('VehiculoGaraje', () {
    test('arma el titulo con marca, modelo y anio', () {
      const v = VehiculoGaraje(
        id: 1,
        modelo: 'CX-5',
        anio: 2024,
        marca: 'Mazda',
      );
      expect(v.titulo, 'Mazda CX-5 2024');
    });

    test('sin marca usa modelo y anio', () {
      const v = VehiculoGaraje(id: 1, modelo: 'Mazda 3', anio: 2022);
      expect(v.titulo, 'Mazda 3 2022');
    });

    test('no repite la marca si el modelo ya la trae', () {
      const v = VehiculoGaraje(
        id: 1,
        modelo: 'Nissan March Sense',
        anio: 2020,
        marca: 'Nissan',
      );
      expect(v.titulo, 'Nissan March Sense 2020');
    });
  });

  group('RepositorioGarajeApi detalle', () {
    test('traduce vin, color, version y fecha de cierre del km', () async {
      final api = ApiFalsa()
        ..alPedirVehiculos = () async => [
          Vehiculo(
            id: 3,
            vin: 'VIN123',
            modelo: 'CX-30',
            anio: 2025,
            color: 'Rojo',
            version: 'Sport',
            kilometraje: 900,
            kilometrajeActualizadoEn: DateTime(2026, 10, 20),
          ),
        ];
      final v = (await RepositorioGarajeApi(api).vehiculos()).single;
      expect(v.vin, 'VIN123');
      expect(v.color, 'Rojo');
      expect(v.version, 'Sport');
      expect(v.kilometrajeActualizadoEn, DateTime(2026, 10, 20));
    });
  });

  group('RepositorioGarajeApi', () {
    test('traduce los vehiculos de la API al dominio', () async {
      final api = ApiFalsa()
        ..alPedirVehiculos = () async => [
          const Vehiculo(
            id: 3,
            vin: 'VIN123',
            modelo: 'CX-30',
            anio: 2025,
            marca: 'Mazda',
            placas: 'ABC-123',
            kilometraje: 12500,
          ),
        ];
      final lista = await RepositorioGarajeApi(api).vehiculos();
      expect(lista.single.id, 3);
      expect(lista.single.titulo, 'Mazda CX-30 2025');
      expect(lista.single.placas, 'ABC-123');
      expect(lista.single.kilometraje, 12500);
    });

    test('sin vehiculos da una lista vacia', () async {
      expect(await RepositorioGarajeApi(ApiFalsa()).vehiculos(), isEmpty);
    });

    test('la falta de conexion pasa tal cual', () {
      final api = ApiFalsa()
        ..alPedirVehiculos = () async => throw const SinConexion();
      expect(
        RepositorioGarajeApi(api).vehiculos(),
        throwsA(isA<SinConexion>()),
      );
    });
  });

  group('RepositorioGarajeFake', () {
    test('entrega datos de ejemplo', () async {
      expect(await RepositorioGarajeFake().vehiculos(), isNotEmpty);
    });

    test('puede fallar a pedido', () {
      expect(
        RepositorioGarajeFake(fallar: true).vehiculos(),
        throwsA(isA<Exception>()),
      );
    });
  });
}
