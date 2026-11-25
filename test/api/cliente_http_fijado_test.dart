import 'dart:convert';
import 'dart:io';

import 'package:carecar_mobile/api/api_config.dart';
import 'package:carecar_mobile/api/cliente_api.dart';
import 'package:carecar_mobile/api/cliente_http_fijado.dart';
import 'package:carecar_mobile/config/flavor.dart';
import 'package:carecar_mobile/config/pines_tls.dart';
import 'package:flutter_test/flutter_test.dart';

final _azure = Uri.parse(Flavor.produccion.urlPorOmision(esAndroid: false));

/// Si hay `openssl` para armar certificados de prueba. Se detecta al cargar el
/// archivo para poder omitir las pruebas de conexion real donde no esta.
final bool _hayOpenssl = () {
  try {
    return Process.runSync('openssl', ['version']).exitCode == 0;
  } on ProcessException {
    return false;
  }
}();

/// En CI `openssl` es obligatorio: omitir ahi dejaria sin probar lo principal.
final bool _enCi = Platform.environment['CI'] == 'true';

void main() {
  group('decidirConfianza (V2-M22.04)', () {
    ConfianzaTls decidir(
      Flavor flavor,
      Uri servidor, {
      bool esRelease = true,
      bool pinesActivados = true,
    }) => decidirConfianza(
      flavor: flavor,
      servidor: servidor,
      esRelease: esRelease,
      pinesActivados: pinesActivados,
    );

    test(
      'desarrollo usa la tienda del sistema: es http contra el simulador',
      () {
        expect(
          decidir(
            Flavor.desarrollo,
            Uri.parse('http://localhost:3000/api/v1/app'),
          ),
          isA<ConfianzaDelSistema>(),
        );
        // Ni con https: desarrollo nunca fija.
        expect(decidir(Flavor.desarrollo, _azure), isA<ConfianzaDelSistema>());
      },
    );

    test(
      'pruebas y produccion fijan las anclas de Azure contra el backend',
      () {
        for (final flavor in [Flavor.pruebas, Flavor.produccion]) {
          final confianza = decidir(flavor, _azure);

          expect(confianza, isA<ConfianzaFijada>(), reason: flavor.name);
          expect(
            (confianza as ConfianzaFijada).pem,
            anclasAzure.map((a) => a.pem).toList(),
            reason: flavor.name,
          );
        }
      },
    );

    test('sin tls no hay nada que fijar', () {
      // Un flavor que fija no deberia llegar a http (ApiConfig lo rechaza); si
      // llega, no hay certificado que validar y no se inventa uno.
      expect(
        decidir(Flavor.produccion, Uri.parse('http://localhost:3000/api')),
        isA<ConfianzaDelSistema>(),
      );
    });

    test('un servidor sin anclas no arranca en vez de quedar sin fijar', () {
      for (final flavor in [Flavor.pruebas, Flavor.produccion]) {
        expect(
          () => decidir(flavor, Uri.parse('https://api.otro.com/api/v1/app')),
          throwsA(
            isA<ConfianzaTlsInvalida>().having(
              (e) => e.toString(),
              'texto',
              allOf(contains('api.otro.com'), contains('pines_tls.dart')),
            ),
          ),
          reason: flavor.name,
        );
      }
    });

    test('quitar los pines solo se puede fuera de release', () {
      // En release, la opcion se ignora: no hay forma de apagarlos.
      expect(
        decidir(Flavor.produccion, _azure, pinesActivados: false),
        isA<ConfianzaFijada>(),
      );
      // Depurando contra un proxy, si.
      expect(
        decidir(
          Flavor.produccion,
          _azure,
          esRelease: false,
          pinesActivados: false,
        ),
        isA<ConfianzaDelSistema>(),
      );
      // Y sin pedirlo, depurando tambien se fija.
      expect(
        decidir(Flavor.produccion, _azure, esRelease: false),
        isA<ConfianzaFijada>(),
      );
    });

    test(
      'por omision, esta fuera de release y con pines (lo que corre en CI)',
      () {
        // Las pruebas corren en modo debug: la omision es fijar.
        expect(
          decidirConfianza(flavor: Flavor.produccion, servidor: _azure),
          isA<ConfianzaFijada>(),
        );
      },
    );
  });

  group('el cliente de la API sin cliente propio (V2-M22.04)', () {
    late Flavor anterior;
    setUp(() {
      anterior = Flavor.actual;
      Flavor.actual = Flavor.produccion;
    });
    tearDown(() => Flavor.actual = anterior);

    test('pasa por la misma decision', () {
      expect(
        () => ClienteApi(
          config: ApiConfig.para(
            'https://api.otro.com/api/v1/app',
            permitirHttp: false,
          ),
        ),
        throwsA(isA<ConfianzaTlsInvalida>()),
      );
      expect(
        () => ClienteApi(
          config: ApiConfig.para(_azure.toString(), permitirHttp: false),
        ).cerrar(),
        returnsNormally,
      );
      expect(
        () => ClienteApi(
          config: ApiConfig.para('http://localhost:3000/api/v1/app'),
        ).cerrar(),
        returnsNormally,
      );
    });
  });

  group('conexion real contra un servidor de prueba (V2-M22.04)', () {
    test('en CI hay openssl', () {
      if (_enCi) {
        expect(
          _hayOpenssl,
          isTrue,
          reason: 'Sin openssl no se prueba la conexion',
        );
      }
    });

    final omitir = _hayOpenssl ? false : 'openssl no esta instalado';

    late Directory dir;
    late HttpServer servidor;
    late String caA;
    late String caB;

    Future<void> openssl(List<String> args) async {
      final r = await Process.run('openssl', args, workingDirectory: dir.path);
      if (r.exitCode != 0) {
        throw StateError('openssl ${args.join(' ')}\n${r.stderr}');
      }
    }

    /// Una autoridad de prueba y, solo con la primera, un certificado de
    /// servidor para `localhost` firmado por ella.
    Future<void> autoridad(String id, {bool conServidor = false}) async {
      File('${dir.path}/$id.cnf').writeAsStringSync('''
[req]
distinguished_name = dn
prompt = no
x509_extensions = v3_ca
[dn]
CN = Autoridad de prueba $id
[v3_ca]
basicConstraints = critical, CA:TRUE
keyUsage = critical, keyCertSign, cRLSign
subjectKeyIdentifier = hash
''');
      await openssl([
        'req',
        '-x509',
        '-newkey',
        'rsa:2048',
        '-nodes',
        '-sha256',
        '-keyout',
        '$id.key',
        '-out',
        '$id.pem',
        '-days',
        '2',
        '-config',
        '$id.cnf',
      ]);
      if (!conServidor) return;
      File('${dir.path}/servidor.ext').writeAsStringSync('''
basicConstraints = CA:FALSE
keyUsage = critical, digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth
subjectAltName = DNS:localhost
''');
      await openssl([
        'req',
        '-new',
        '-newkey',
        'rsa:2048',
        '-nodes',
        '-keyout',
        'servidor.key',
        '-out',
        'servidor.csr',
        '-subj',
        '/CN=localhost',
      ]);
      await openssl([
        'x509',
        '-req',
        '-in',
        'servidor.csr',
        '-CA',
        '$id.pem',
        '-CAkey',
        '$id.key',
        '-CAcreateserial',
        '-out',
        'servidor.pem',
        '-days',
        '2',
        '-sha256',
        '-extfile',
        'servidor.ext',
      ]);
    }

    setUpAll(() async {
      if (!_hayOpenssl) return;
      dir = Directory.systemTemp.createTempSync('pines-tls-');
      await autoridad('a', conServidor: true);
      await autoridad('b');
      caA = File('${dir.path}/a.pem').readAsStringSync();
      caB = File('${dir.path}/b.pem').readAsStringSync();
      final contexto = SecurityContext()
        ..useCertificateChain('${dir.path}/servidor.pem')
        ..usePrivateKey('${dir.path}/servidor.key');
      servidor = await HttpServer.bindSecure(
        InternetAddress.loopbackIPv4,
        0,
        contexto,
      );
      servidor.listen((peticion) {
        peticion.response
          ..statusCode = 200
          ..write('hola')
          ..close();
      });
    });

    tearDownAll(() async {
      if (!_hayOpenssl) return;
      await servidor.close(force: true);
      dir.deleteSync(recursive: true);
    });

    Future<String> pedir(ConfianzaTls confianza, String host) async {
      final cliente = crearClienteHttp(confianza);
      try {
        final r = await cliente
            .get(Uri.parse('https://$host:${servidor.port}/'))
            .timeout(const Duration(seconds: 10));
        return '${r.statusCode} ${r.body}';
      } finally {
        cliente.close();
      }
    }

    test('conecta si el servidor es de la autoridad fijada', () async {
      expect(await pedir(ConfianzaFijada([caA]), 'localhost'), '200 hola');
    }, skip: omitir);

    test('con varias anclas basta con que una valide', () async {
      expect(await pedir(ConfianzaFijada([caB, caA]), 'localhost'), '200 hola');
    }, skip: omitir);

    test('varias anclas sin salto de linea final tambien valen', () async {
      // Un PEM pegado a mano en pines_tls.dart puede no terminar en salto de
      // linea; juntarlos sin separador los pegaria en una sola linea.
      expect(
        await pedir(ConfianzaFijada([caB.trim(), caA.trim()]), 'localhost'),
        '200 hola',
      );
    }, skip: omitir);

    test('no conecta si el servidor es de otra autoridad', () async {
      // El mismo servidor, fijado a una autoridad que no lo firmo: es lo que
      // vería la app ante un certificado de un tercero.
      await expectLater(
        pedir(ConfianzaFijada([caB]), 'localhost'),
        throwsA(predicate((e) => '$e'.contains('CERTIFICATE_VERIFY_FAILED'))),
      );
    }, skip: omitir);

    test(
      'la tienda del sistema tampoco confia en la autoridad de prueba',
      () async {
        // Contraste: el exito de arriba se debe a que se fijo, no a que el
        // certificado de prueba valiera en general.
        await expectLater(
          pedir(const ConfianzaDelSistema(), 'localhost'),
          throwsA(predicate((e) => '$e'.contains('CERTIFICATE_VERIFY_FAILED'))),
        );
      },
      skip: omitir,
    );

    test(
      'sigue verificando que el certificado sea del servidor al que se conecta',
      () async {
        // Fijar la autoridad no es aceptar cualquier certificado suyo: el de
        // prueba es de «localhost» y no vale para 127.0.0.1.
        await expectLater(
          pedir(ConfianzaFijada([caA]), '127.0.0.1'),
          throwsA(predicate((e) => '$e'.contains('CERTIFICATE_VERIFY_FAILED'))),
        );
      },
      skip: omitir,
    );

    test('fijar deja fuera los certificados del telefono', () async {
      // Un servidor publico, con el certificado de una autoridad que el sistema
      // conoce. Con la tienda del sistema conecta; fijado a otra autoridad, no:
      // si conectara, los pines no estarian quitando nada.
      Future<bool> conecta(ConfianzaTls confianza) async {
        final cliente = crearClienteHttp(confianza);
        try {
          await cliente
              .get(Uri.parse('https://example.com/'))
              .timeout(const Duration(seconds: 10));
          return true;
        } on Object {
          return false;
        } finally {
          cliente.close();
        }
      }

      if (!await conecta(const ConfianzaDelSistema())) {
        markTestSkipped('Sin red: no hay servidor publico con el que comparar');
        return;
      }
      expect(await conecta(ConfianzaFijada([caA])), isFalse);
    }, skip: omitir);

    test('un PEM roto no se traga: la app no arranca sin pines validos', () {
      expect(
        () => crearClienteHttp(
          const ConfianzaFijada(['esto no es un certificado']),
        ),
        throwsA(isA<ConfianzaTlsInvalida>()),
      );
      // Sin ninguno, lo dice con su propio motivo: no es un PEM malo.
      expect(
        () => crearClienteHttp(const ConfianzaFijada([])),
        throwsA(
          isA<ConfianzaTlsInvalida>().having(
            (e) => e.motivo,
            'motivo',
            contains('ningún certificado'),
          ),
        ),
      );
      expect(
        () => crearClienteHttp(
          const ConfianzaFijada(['esto no es un certificado']),
        ),
        throwsA(
          isA<ConfianzaTlsInvalida>().having(
            (e) => e.motivo,
            'motivo',
            contains('no se pudieron leer'),
          ),
        ),
      );
    });
  });

  test('los certificados reales de Azure arman un cliente sin error', () {
    // No conecta: solo comprueba que BoringSSL acepta las cinco anclas juntas.
    final cliente = crearClienteHttp(
      ConfianzaFijada(anclasAzure.map((a) => a.pem).toList()),
    );
    cliente.close();
    expect(utf8.encode(anclasAzure.first.pem), isNotEmpty);
  });
}
