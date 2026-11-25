import 'dart:convert';
import 'dart:io';

import 'package:carecar_mobile/api/modelos/modelos.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('March y Jetta tienen VIN de 17 caracteres y pertenecen a cliente1', () {
    final cuentas = jsonDecode(
      File('mock_api/semillas/acceso.json').readAsStringSync(),
    ) as Map<String, dynamic>;
    final vehiculos = jsonDecode(
      File('mock_api/semillas/vehiculos.json').readAsStringSync(),
    ) as Map<String, dynamic>;
    final cliente = (cuentas['cuentas'] as List)
        .cast<Map<String, dynamic>>()
        .singleWhere((c) => c['usuario'] == 'cliente1');
    final autos = (vehiculos['vehiculos'] as List).cast<Map<String, dynamic>>();
    final esperados = {
      'Nissan March Sense': (2020, 'Blanco'),
      'Volkswagen Jetta Comfortline': (2018, 'Gris'),
    };
    expect(autos.map((v) => v['id']).toSet(), hasLength(autos.length));
    expect(autos.map((v) => v['vin']).toSet(), hasLength(autos.length));
    for (final esperado in esperados.entries) {
      final datos = autos.singleWhere((v) => v['modelo'] == esperado.key);
      final vehiculo = Vehiculo.fromJson(datos);
      expect(datos['clienteId'], cliente['clienteId']);
      expect(vehiculo.anio, esperado.value.$1);
      // Color es metadata interna de la semilla: la v1.1 no lo expone.
      expect(datos['color'], esperado.value.$2);
      expect(vehiculo.vin, matches(RegExp(r'^[A-HJ-NPR-Z0-9]{17}$')));
    }
  });

  test('todo vehiculo con km trae la fecha de cierre que lo dejo', () {
    final semilla = jsonDecode(
      File('mock_api/semillas/vehiculos.json').readAsStringSync(),
    ) as Map<String, dynamic>;
    final autos = (semilla['vehiculos'] as List).cast<Map<String, dynamic>>();
    final conKm = autos.where((v) => v['kilometraje'] != null);
    expect(conKm, isNotEmpty);
    for (final v in conKm) {
      expect(Vehiculo.fromJson(v).kilometrajeActualizadoEn, isNotNull);
    }
  });
}
