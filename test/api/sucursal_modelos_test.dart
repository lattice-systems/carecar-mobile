import 'package:carecar_mobile/api/modelos/modelos.dart';
import 'package:flutter_test/flutter_test.dart';

// V2-M27.02: la sucursal tal como la manda el contrato 2.28.0.
void main() {
  Map<String, Object?> json({Object? telefono = '+52 477 000 0000'}) => {
    'id': 1,
    'nombre': 'CareCar León',
    'direccion': 'Blvd. Ejemplo 100, León, Gto.',
    'latitud': 21.125,
    'longitud': -101.686,
    'telefono': telefono,
    'correo': null,
    'abiertaAhora': true,
    'horarios': [
      {
        'departamento': 'SERVICIO',
        'dias': [1, 2, 3, 4, 5],
        'abre': '08:00',
        'cierra': '18:00',
        'abiertoAhora': true,
      },
    ],
  };

  test('lee la sucursal con su ubicación y sus horarios', () {
    final s = SucursalApi.fromJson(json());

    expect(s.id, 1);
    expect(s.nombre, 'CareCar León');
    expect(s.latitud, 21.125);
    expect(s.longitud, -101.686);
    expect(s.abiertaAhora, isTrue);
    expect(s.horarios.single.departamento, 'SERVICIO');
    expect(s.horarios.single.dias, [1, 2, 3, 4, 5]);
    expect(s.horarios.single.abre, '08:00');
    expect(s.horarios.single.abiertoAhora, isTrue);
  });

  test('un teléfono o correo nulos o vacíos quedan como nulo', () {
    expect(SucursalApi.fromJson(json()).correo, isNull);
    expect(SucursalApi.fromJson(json(telefono: null)).telefono, isNull);
    expect(SucursalApi.fromJson(json(telefono: '  ')).telefono, isNull);
  });

  test('las coordenadas enteras se leen como decimales', () {
    final s = SucursalApi.fromJson({
      ...json(),
      'latitud': 21,
      'longitud': -101,
    });

    expect(s.latitud, 21.0);
    expect(s.longitud, -101.0);
  });

  test('sin horarios queda la lista vacía', () {
    final s = SucursalApi.fromJson({...json(), 'horarios': null});

    expect(s.horarios, isEmpty);
  });

  test('sin nombre falla con FormatException', () {
    expect(
      () => SucursalApi.fromJson({...json(), 'nombre': null}),
      throwsFormatException,
    );
  });
}
