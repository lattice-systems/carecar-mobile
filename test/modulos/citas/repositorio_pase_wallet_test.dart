import 'dart:convert';
import 'dart:typed_data';

import 'package:carecar_mobile/api/api_config.dart';
import 'package:carecar_mobile/api/cliente_api.dart';
import 'package:carecar_mobile/api/excepciones.dart';
import 'package:carecar_mobile/api/modelos/problema.dart';
import 'package:carecar_mobile/modulos/citas/datos/repositorio_pase_wallet_api.dart';
import 'package:carecar_mobile/modulos/citas/dominio/pase_de_wallet.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

RepositorioPaseWalletApi _repo(MockClient cliente) => RepositorioPaseWalletApi(
  ClienteApi(
    config: ApiConfig.para('http://localhost:3000/api/v1/app'),
    http: cliente,
  ),
);

http.Response _problema(int status, String codigo) => http.Response(
  jsonEncode({
    'timestamp': '2026-11-22T10:00:00Z',
    'status': status,
    'error': 'Error',
    'message': 'x',
    'codigo': codigo,
    'path': '/citas/7/pase',
  }),
  status,
  headers: {'content-type': 'application/json'},
);

void main() {
  test('Apple: pide plataforma=apple y entrega los bytes del pkpass', () async {
    late Uri pedido;
    final repo = _repo(
      MockClient((r) async {
        pedido = r.url;
        return http.Response.bytes(
          [1, 2, 3],
          200,
          headers: {'content-type': 'application/vnd.apple.pkpass'},
        );
      }),
    );

    final pase = await repo.obtener(7, PlataformaWallet.apple);

    expect(pedido.path, endsWith('/citas/7/pase'));
    expect(pedido.queryParameters['plataforma'], 'apple');
    expect(pase, isA<PaseApple>());
    expect((pase as PaseApple).bytes, Uint8List.fromList([1, 2, 3]));
  });

  test('Google: pide plataforma=google y entrega el enlace', () async {
    late Uri pedido;
    final repo = _repo(
      MockClient((r) async {
        pedido = r.url;
        return http.Response(
          jsonEncode({'url': 'https://pay.google.com/gp/v/save/abc'}),
          200,
          headers: {'content-type': 'application/json'},
        );
      }),
    );

    final pase = await repo.obtener(7, PlataformaWallet.google);

    expect(pedido.queryParameters['plataforma'], 'google');
    expect(
      (pase as PaseGoogle).enlace,
      Uri.parse('https://pay.google.com/gp/v/save/abc'),
    );
  });

  test('Google: un enlace que no es de Google Pay se rechaza', () async {
    final repo = _repo(
      MockClient(
        (_) async => http.Response(
          jsonEncode({'url': 'https://sitio-falso.example/save/abc'}),
          200,
          headers: {'content-type': 'application/json'},
        ),
      ),
    );

    expect(
      repo.obtener(7, PlataformaWallet.google),
      throwsA(isA<RespuestaInvalida>()),
    );
  });

  test('cita cancelada: 409 CITA_CANCELADA llega como Conflicto', () async {
    final repo = _repo(
      MockClient((_) async => _problema(409, 'CITA_CANCELADA')),
    );

    await expectLater(
      repo.obtener(7, PlataformaWallet.apple),
      throwsA(
        isA<Conflicto>().having(
          (e) => e.problema?.codigo,
          'codigo',
          CodigoProblema.citaCancelada,
        ),
      ),
    );
  });

  test('sin certificados: 503 WALLET_NO_CONFIGURADO se reconoce', () async {
    final repo = _repo(
      MockClient((_) async => _problema(503, 'WALLET_NO_CONFIGURADO')),
    );

    await expectLater(
      repo.obtener(7, PlataformaWallet.google),
      throwsA(
        isA<ErrorDelServidor>().having(
          (e) => e.problema?.codigo,
          'codigo',
          CodigoProblema.walletNoConfigurado,
        ),
      ),
    );
  });

  test('sin red sale como SinConexion', () async {
    final repo = _repo(
      MockClient((_) async => throw http.ClientException('sin red')),
    );

    expect(
      repo.obtener(7, PlataformaWallet.apple),
      throwsA(isA<SinConexion>()),
    );
  });
}
