import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:carecar_mobile/api/modelos/vehiculo.dart';
import 'package:carecar_mobile/manuales/servicio_manuales.dart';

Vehiculo auto({
  String? marca = 'Nissan',
  String? tipo = 'March',
  int anio = 2020,
  String? version = 'Sense',
}) => Vehiculo(
  id: 1,
  vin: '3N1CK3CD0LL123456',
  modelo: 'Nombre no utilizado',
  anio: anio,
  marca: marca,
  tipo: tipo,
  version: version,
);
void main() {
  final rutas = Directory('assets/Manuales')
      .listSync(recursive: true)
      .whereType<File>()
      .map((f) => f.path.replaceAll('\\', '/'))
      .toList();
  test('mapea los atributos opcionales sin perder los originales', () {
    final v = Vehiculo.fromJson({
      'id': 1,
      'vin': '3N1CK3CD0LL123456',
      'modelo': 'March',
      'anio': 2020,
      'marca': 'Nissan',
      'tipo': 'March',
      'version': 'Sense',
      'color': 'Blanco',
    });
    expect(
      [v.marca, v.tipo, v.version, v.color, v.anio, v.vin],
      ['Nissan', 'March', 'Sense', 'Blanco', 2020, '3N1CK3CD0LL123456'],
    );
    expect(
      Vehiculo.fromJson({'id': 1, 'vin': 'A', 'modelo': 'March', 'anio': 2020})
          .marca,
      isNull,
    );
  });
  for (final caso in [('March', 2020), ('Kicks', 2023), ('Versa', 2024)]) {
    test('resuelve exclusivamente ${caso.$1} ${caso.$2} y existe el PDF original', () {
      final ruta = ResolverManual.ruta(
        auto(tipo: caso.$1, anio: caso.$2),
        rutas,
      );
      expect(
        ruta,
        'assets/Manuales/Nissan/${caso.$1}/${caso.$2}/Nissan${caso.$1}${caso.$2}Manual.pdf',
      );
      expect(File(ruta).readAsBytesSync().take(5), '%PDF-'.codeUnits);
    });
  }
  test('normaliza espacios y capitalizacion sin usar version ni VIN', () {
    expect(
      ResolverManual.ruta(
        auto(marca: ' nIsSaN ', tipo: ' Mar ch ', version: 'Otra'),
        rutas,
      ),
      contains('NissanMarch2020Manual.pdf'),
    );
  });
  test('nunca sustituye un manual por otro anio o marca', () {
    expect(
      () => ResolverManual.ruta(auto(anio: 2021), rutas),
      throwsA(isA<FalloManual>()),
    );
    expect(
      () => ResolverManual.ruta(auto(marca: 'Honda'), rutas),
      throwsA(isA<FalloManual>()),
    );
  });
  test('rechaza datos incompletos y rutas manipuladas', () {
    for (final v in [
      auto(marca: null),
      auto(tipo: ''),
      auto(anio: 0),
      auto(tipo: '../March'),
    ]) {
      expect(() => ResolverManual.ruta(v, rutas), throwsA(isA<FalloManual>()));
    }
  });
  test('rechaza coincidencias ambiguas', () {
    expect(
      () => ResolverManual.ruta(auto(), [
        ...rutas,
        'assets/Manuales/nissan/march/2020/nissanmarch2020manual.pdf',
      ]),
      throwsA(isA<FalloManual>()),
    );
  });
}
