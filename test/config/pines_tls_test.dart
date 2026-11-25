import 'dart:convert';

import 'package:carecar_mobile/config/flavor.dart';
import 'package:carecar_mobile/config/pines_tls.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';

/// Los bytes del certificado: lo que va entre las lineas BEGIN y END.
List<int> _der(String pem) => base64.decode(
  pem.split('\n').where((l) => l.isNotEmpty && !l.startsWith('-----')).join(),
);

void main() {
  group('anclas de Azure (V2-M22.04)', () {
    test('cada una es un solo certificado PEM bien formado', () {
      for (final a in anclasAzure) {
        expect(
          RegExp('-----BEGIN CERTIFICATE-----').allMatches(a.pem).length,
          1,
          reason: a.nombre,
        );
        expect(
          RegExp('-----END CERTIFICATE-----').allMatches(a.pem).length,
          1,
          reason: a.nombre,
        );
        expect(a.pem.trimLeft(), startsWith('-----BEGIN CERTIFICATE-----'));
        expect(a.pem.trimRight(), endsWith('-----END CERTIFICATE-----'));
        expect(_der(a.pem), isNotEmpty, reason: a.nombre);
      }
    });

    test('la huella SHA-256 declarada es la del certificado incluido', () {
      // Si alguien edita el PEM a mano o lo pega mal, esto falla: la huella es
      // la que se verifica contra lo que publican Microsoft y DigiCert.
      for (final a in anclasAzure) {
        expect(
          sha256.convert(_der(a.pem)).toString(),
          a.sha256,
          reason: a.nombre,
        );
        expect(a.sha256, matches(RegExp(r'^[0-9a-f]{64}$')), reason: a.nombre);
      }
    });

    test('hay mas de una (copia de respaldo) y ninguna se repite', () {
      expect(anclasAzure.length, greaterThanOrEqualTo(2));
      expect(
        anclasAzure.map((a) => a.nombre).toSet().length,
        anclasAzure.length,
      );
      expect(
        anclasAzure.map((a) => a.sha256).toSet().length,
        anclasAzure.length,
      );
    });

    test('dicen cuando vencen, con fecha', () {
      for (final a in anclasAzure) {
        expect(
          a.venceEn,
          matches(RegExp(r'^\d{4}-\d{2}-\d{2}$')),
          reason: a.nombre,
        );
      }
    });

    test('incluyen la raiz con la que hoy responde el backend', () {
      // La cadena actual termina en Microsoft TLS RSA Root G2, con firma cruzada
      // de DigiCert Global Root G2. Sin alguna de las dos la app no conecta.
      final nombres = anclasAzure.map((a) => a.nombre);
      expect(nombres, contains('Microsoft TLS RSA Root G2'));
      expect(nombres, contains('DigiCert Global Root G2'));
    });
  });

  group('anclasPara (V2-M22.04)', () {
    test('el backend de produccion y de pruebas tiene anclas', () {
      for (final flavor in [Flavor.pruebas, Flavor.produccion]) {
        final host = Uri.parse(flavor.urlPorOmision(esAndroid: false)).host;
        expect(anclasPara(host), same(anclasAzure), reason: flavor.name);
      }
    });

    test('acepta el dominio y sus subdominios, sin importar mayusculas', () {
      expect(anclasPara('azurecontainerapps.io'), same(anclasAzure));
      expect(anclasPara('x.eastus2.azurecontainerapps.io'), same(anclasAzure));
      expect(anclasPara('X.EASTUS2.AzureContainerApps.IO'), same(anclasAzure));
    });

    test('no acepta parecidos ni otros servidores', () {
      for (final host in [
        '',
        'localhost',
        '10.0.2.2',
        'example.com',
        // Un dominio que solo termina parecido no es subdominio.
        'evilazurecontainerapps.io',
        'azurecontainerapps.io.evil.com',
        'azurecontainerapps.io.',
        'x.azurecontainerapps.io.evil.com',
      ]) {
        expect(anclasPara(host), isNull, reason: host);
      }
    });
  });
}
