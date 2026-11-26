import 'dart:io';

import 'package:carecar_mobile/api/modelos/modelos.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yaml/yaml.dart';

/// V2-M01.06 · el perfil trae lo que la pantalla necesita mostrar.
///
/// El criterio pide nombre, correo, **teléfono** y **«cliente desde»**. Los dos
/// últimos llegaron al contrato con esta historia, y cada uno tiene su regla:
/// el teléfono **puede faltar** y la fecha **siempre viene**.
void main() {
  group('el modelo', () {
    test('lee los cinco campos', () {
      final perfil = Perfil.fromJson({
        'id': 7,
        'nombre': 'Ana López',
        'correo': 'ana.lopez@correo.com',
        'telefono': '477 123 4567',
        'clienteDesde': '2024-03-01',
      });

      expect(perfil.id, 7);
      expect(perfil.nombre, 'Ana López');
      expect(perfil.correo, 'ana.lopez@correo.com');
      expect(perfil.telefono, '477 123 4567');
      expect(perfil.clienteDesde, DateTime(2024, 3));
    });

    test('sin teléfono se lee igual: la agencia no siempre lo captura', () {
      // Exigirlo dejaría sin perfil justo a quien no lo tiene.
      final perfil = Perfil.fromJson({
        'id': 7,
        'nombre': 'Ana López',
        'correo': 'ana.lopez@correo.com',
        'telefono': null,
        'clienteDesde': '2024-03-01',
      });

      expect(perfil.telefono, isNull);
    });

    test('tampoco pasa nada si la llave del teléfono no viene', () {
      final perfil = Perfil.fromJson({
        'id': 7,
        'nombre': 'Ana López',
        'correo': 'ana.lopez@correo.com',
        'clienteDesde': '2024-03-01',
      });

      expect(perfil.telefono, isNull);
    });

    test('sin «cliente desde» falla: el contrato dice que siempre viene', () {
      // `cliente.created_at` es `not null`, así que si falta es que algo se
      // rompió en el servidor y es mejor saberlo que pintar una fecha vacía.
      expect(
        () => Perfil.fromJson({
          'id': 7,
          'nombre': 'Ana López',
          'correo': 'ana.lopez@correo.com',
        }),
        throwsFormatException,
      );
    });

    test('la fecha se lee sin hora y sin correrse de día', () {
      // Es `date`, no `date-time`: el servidor ya la resolvió en la zona de la
      // agencia. Tratarla como instante la correría un día en México.
      final perfil = Perfil.fromJson({
        'id': 7,
        'nombre': 'Ana López',
        'correo': 'ana.lopez@correo.com',
        'clienteDesde': '2024-03-01',
      });

      expect(perfil.clienteDesde, DateTime(2024, 3));
      expect(perfil.clienteDesde.hour, 0);
      expect(perfil.clienteDesde.isUtc, isFalse);
    });
  });

  group('el contrato', () {
    test('declara el perfil como lo lee la app', () {
      final contrato = loadYaml(
        File('api/agencia360-api-app-v2.yaml').readAsStringSync(),
      ) as YamlMap;
      final perfil = contrato['components']['schemas']['Perfil'] as YamlMap;
      final propiedades = (perfil['properties'] as YamlMap).keys.toSet();
      final obligatorios = (perfil['required'] as YamlList).cast<String>();

      expect(propiedades, {
        'id',
        'nombre',
        'correo',
        'telefono',
        'clienteDesde',
      });
      // El teléfono falta seguido; la fecha nunca.
      expect(obligatorios, isNot(contains('telefono')));
      expect(obligatorios, contains('clienteDesde'));
      expect(perfil['properties']['telefono']['nullable'], isTrue);
      expect(perfil['properties']['clienteDesde']['format'], 'date');
    });
  });
}
