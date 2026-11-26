import 'package:carecar_mobile/nucleo/mapas/cliente_teselas.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

final _direccion = Uri.parse('https://teselas.ejemplo/16/14574/28907.png');

Future<String> _fallo(http.Client interno) async {
  try {
    await ClienteTeselas(interno).get(_direccion);
  } on Object catch (e) {
    return '$e';
  }
  return fail('debía fallar');
}

void main() {
  test('una respuesta correcta pasa sin cambios', () async {
    final cliente = ClienteTeselas(
      MockClient((_) async => http.Response('ok', 200)),
    );

    expect((await cliente.get(_direccion)).body, 'ok');
  });

  test('un 304 pasa, porque lo usa la caché', () async {
    final cliente = ClienteTeselas(
      MockClient((_) async => http.Response('', 304)),
    );

    expect((await cliente.get(_direccion)).statusCode, 304);
  });

  test('un error del servidor no deja la tesela en el mensaje', () async {
    final mensaje = await _fallo(
      MockClient((_) async => http.Response('no', 429)),
    );

    expect(mensaje, contains('429'));
    expect(mensaje, isNot(contains('14574')));
    expect(mensaje, isNot(contains('teselas.ejemplo')));
  });

  test('sin conexión no deja la tesela en el mensaje', () async {
    final mensaje = await _fallo(
      MockClient(
        (_) async => throw http.ClientException('sin red', _direccion),
      ),
    );

    expect(mensaje, isNot(contains('14574')));
    expect(mensaje, isNot(contains('teselas.ejemplo')));
  });

  test('una descarga cancelada conserva su tipo', () async {
    final cliente = ClienteTeselas(
      MockClient((_) async => throw http.RequestAbortedException(_direccion)),
    );

    await expectLater(
      cliente.get(_direccion),
      throwsA(isA<http.RequestAbortedException>()),
    );
  });
}
