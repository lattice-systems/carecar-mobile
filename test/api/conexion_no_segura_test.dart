import 'dart:io';

import 'package:carecar_mobile/api/api_config.dart';
import 'package:carecar_mobile/api/cliente_api.dart';
import 'package:carecar_mobile/api/excepciones.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

final _config = ApiConfig.para('https://servidor.ejemplo/api/v1/app');

/// Lo que Dart lanza cuando el certificado del servidor no valida contra lo
/// fijado (lo comprueba `cliente_http_fijado_test.dart` con un servidor real).
const _certificadoRechazado = HandshakeException(
  'Handshake error in client',
  OSError(
    'CERTIFICATE_VERIFY_FAILED: unable to get local issuer certificate'
    '(handshake.cc:393)',
    1,
  ),
);

const _otroFalloDeTls = HandshakeException(
  'Handshake error in client',
  OSError('WRONG_VERSION_NUMBER(tls_record.cc:242)', 267),
);

ClienteApi _cliente(
  Future<http.Response> Function(http.Request) responder,
  List<bool> verificaciones,
) => ClienteApi(
  config: _config,
  http: MockClient(responder),
  alVerificarCertificado: verificaciones.add,
);

Future<Object?> _pedir(ClienteApi cliente) =>
    cliente.obtener<Object?>('/perfil', (json) => json);

void main() {
  group('un certificado que no se puede verificar (V2-M22.15)', () {
    test(
      'sale como ConexionNoSegura, que sigue siendo una SinConexion',
      () async {
        final cliente = _cliente((_) async => throw _certificadoRechazado, []);

        await expectLater(
          _pedir(cliente),
          throwsA(
            isA<ConexionNoSegura>().having(
              (e) => e.causa,
              'causa',
              _certificadoRechazado,
            ),
          ),
        );
        await expectLater(_pedir(cliente), throwsA(isA<SinConexion>()));
      },
    );

    test('el mensaje dice qué pasó y qué hacer', () {
      const e = ConexionNoSegura();

      expect(e.mensaje, contains('No pudimos verificar'));
      expect(e.mensaje, contains('red'));
      expect(e.mensaje, isNot(SinConexion.mensajePorOmision));
    });

    test('avisa que el certificado no se verificó', () async {
      final verificaciones = <bool>[];
      final cliente = _cliente(
        (_) async => throw _certificadoRechazado,
        verificaciones,
      );

      await expectLater(_pedir(cliente), throwsA(isA<ConexionNoSegura>()));

      expect(verificaciones, [false]);
    });

    test('otro fallo de TLS sigue siendo una sin conexión corriente', () async {
      final verificaciones = <bool>[];
      final cliente = _cliente(
        (_) async => throw _otroFalloDeTls,
        verificaciones,
      );

      await expectLater(
        _pedir(cliente),
        throwsA(predicate((e) => e is SinConexion && e is! ConexionNoSegura)),
      );

      expect(verificaciones, isEmpty);
    });

    test('sin red tampoco es una conexión no segura', () async {
      final verificaciones = <bool>[];
      final cliente = _cliente(
        (_) async => throw const SocketException('Failed host lookup'),
        verificaciones,
      );

      await expectLater(
        _pedir(cliente),
        throwsA(predicate((e) => e is SinConexion && e is! ConexionNoSegura)),
      );

      expect(verificaciones, isEmpty);
    });

    test(
      'una respuesta, aun de error, avisa que el certificado sí valió',
      () async {
        final verificaciones = <bool>[];

        await _pedir(
          _cliente((_) async => http.Response('{}', 200), verificaciones),
        );
        await expectLater(
          _pedir(
            _cliente((_) async => http.Response('{}', 500), verificaciones),
          ),
          throwsA(isA<ExcepcionApi>()),
        );

        expect(verificaciones, [true, true]);
      },
    );

    test('también en el flujo de eventos (SSE)', () async {
      final verificaciones = <bool>[];
      final cliente = ClienteApi(
        config: _config,
        http: MockClient.streaming((_, _) async => throw _certificadoRechazado),
        alVerificarCertificado: verificaciones.add,
      );

      await expectLater(
        cliente.enviarFlujo('/asistente/preguntas', cuerpo: const {}).toList(),
        throwsA(isA<ConexionNoSegura>()),
      );

      expect(verificaciones, [false]);
    });
  });
}
