import 'package:carecar_mobile/api/api_config.dart';
import 'package:carecar_mobile/nucleo/api/api_cliente.dart';
import 'package:carecar_mobile/nucleo/api/proveedores_api.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../ayudas/api_falsa.dart';

void main() {
  test('sin inyectar, la API falla diciendo como inyectarla', () {
    final c = ProviderContainer();
    addTearDown(c.dispose);

    expect(
      () => c.read(carecarApiProvider),
      throwsA(
        isA<Exception>().having(
          (e) => e.toString(),
          'mensaje',
          contains('carecarApiProvider.overrideWithValue'),
        ),
      ),
    );
  });

  test('un override con fake sustituye a CarecarApi', () {
    final fake = ApiFalsa();
    final c = ProviderContainer(
      overrides: [carecarApiProvider.overrideWithValue(fake)],
    );
    addTearDown(c.dispose);

    expect(c.read(carecarApiProvider), same(fake));
  });

  test('el cliente del nucleo es el ClienteApi v1', () {
    final cliente = ApiCliente(config: ApiConfig.para('http://localhost/api'));
    addTearDown(cliente.cerrar);
    final c = ProviderContainer(
      overrides: [apiClienteProvider.overrideWithValue(cliente)],
    );
    addTearDown(c.dispose);

    expect(c.read(apiClienteProvider), same(cliente));
  });
}
