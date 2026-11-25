import 'dart:convert';

import 'package:carecar_mobile/cache/cifrador_de_cache.dart';
import 'package:flutter_test/flutter_test.dart';

import '../ayudas/almacenamiento_en_memoria.dart';

const _json = '[{"vin":"VIN123","placas":"ABC-1"}]';

void main() {
  late AlmacenamientoEnMemoria almacen;
  late CifradorAesGcm cifrador;

  setUp(() {
    almacen = AlmacenamientoEnMemoria();
    cifrador = CifradorAesGcm(almacen);
  });

  group('CifradorAesGcm (V2-M22.13)', () {
    test('lo que se cifra se descifra igual', () async {
      final guardado = await cifrador.cifrar(_json, contexto: 'vehiculos');

      expect(await cifrador.descifrar(guardado, contexto: 'vehiculos'), _json);
    });

    test(
      'lo guardado no deja ver el texto, ni en claro ni en base64',
      () async {
        final guardado = await cifrador.cifrar(_json, contexto: 'vehiculos');

        expect(guardado, isNot(contains('VIN123')));
        expect(guardado, isNot(contains('ABC-1')));
        expect(guardado, isNot(contains(base64Encode(utf8.encode('VIN123')))));
      },
    );

    test('cifrar dos veces el mismo texto da resultados distintos', () async {
      final a = await cifrador.cifrar(_json, contexto: 'vehiculos');
      final b = await cifrador.cifrar(_json, contexto: 'vehiculos');

      expect(a, isNot(b));
    });

    test(
      'otra instancia con el mismo almacén lee lo que cifró la primera',
      () async {
        final guardado = await cifrador.cifrar(_json, contexto: 'vehiculos');

        final otra = CifradorAesGcm(almacen);

        expect(await otra.descifrar(guardado, contexto: 'vehiculos'), _json);
        expect(almacen.escrituras, 1, reason: 'la clave se reutiliza');
      },
    );

    test('con peticiones a la vez la clave se crea una sola vez', () async {
      final guardados = await Future.wait([
        for (var i = 0; i < 8; i++)
          cifrador.cifrar('texto $i', contexto: 'perfil'),
      ]);

      expect(almacen.escrituras, 1);
      for (var i = 0; i < 8; i++) {
        expect(
          await cifrador.descifrar(guardados[i], contexto: 'perfil'),
          'texto $i',
        );
      }
    });

    test('una copia alterada no se descifra', () async {
      final guardado = await cifrador.cifrar(_json, contexto: 'vehiculos');
      final medio = guardado.length ~/ 2;
      final letra = guardado[medio] == 'A' ? 'B' : 'A';
      final alterado = guardado.replaceRange(medio, medio + 1, letra);

      expect(await cifrador.descifrar(alterado, contexto: 'vehiculos'), isNull);
    });

    test('una copia movida a otra clave de la caché no se descifra', () async {
      final guardado = await cifrador.cifrar(_json, contexto: 'vehiculos');

      expect(await cifrador.descifrar(guardado, contexto: 'perfil'), isNull);
    });

    test(
      'el texto sin cifrar de una versión anterior no se descifra',
      () async {
        expect(await cifrador.descifrar(_json, contexto: 'vehiculos'), isNull);
        expect(await cifrador.descifrar('', contexto: 'vehiculos'), isNull);
      },
    );

    test('lo que no es base64 después de la marca no se descifra', () async {
      final guardado = await cifrador.cifrar(_json, contexto: 'vehiculos');
      final marca = guardado.substring(0, guardado.indexOf('.') + 1);

      expect(
        await cifrador.descifrar('$marca¡¡¡', contexto: 'vehiculos'),
        isNull,
      );
      expect(await cifrador.descifrar(marca, contexto: 'vehiculos'), isNull);
    });

    test('olvidar borra la clave y lo cifrado antes ya no se lee', () async {
      final guardado = await cifrador.cifrar(_json, contexto: 'vehiculos');

      await cifrador.olvidar();

      expect(almacen.valores, isEmpty);
      expect(almacen.borrados, 1);
      expect(await cifrador.descifrar(guardado, contexto: 'vehiculos'), isNull);
      // La siguiente copia usa una clave nueva.
      final nueva = await cifrador.cifrar(_json, contexto: 'vehiculos');
      expect(await cifrador.descifrar(nueva, contexto: 'vehiculos'), _json);
      expect(almacen.escrituras, 2);
    });

    test('una clave guardada con el tamaño equivocado se reemplaza', () async {
      almacen.valores[CifradorAesGcm.claveEnAlmacen] = base64Encode([1, 2, 3]);

      final guardado = await cifrador.cifrar(_json, contexto: 'vehiculos');

      expect(await cifrador.descifrar(guardado, contexto: 'vehiculos'), _json);
      expect(
        base64Decode(almacen.valores[CifradorAesGcm.claveEnAlmacen]!),
        hasLength(32),
      );
    });

    test('si el almacén falla no se descifra nada y no se cifra', () async {
      final guardado = await cifrador.cifrar(_json, contexto: 'vehiculos');
      final sinClave = CifradorAesGcm(almacen);
      almacen.falla = StateError('Keystore no responde');

      expect(await sinClave.descifrar(guardado, contexto: 'vehiculos'), isNull);
      await expectLater(
        sinClave.cifrar(_json, contexto: 'vehiculos'),
        throwsA(isA<StateError>()),
      );

      // Cuando el almacén vuelve, se recupera sin quedarse con el error.
      almacen.falla = null;
      expect(await sinClave.descifrar(guardado, contexto: 'vehiculos'), _json);
    });
  });
}
