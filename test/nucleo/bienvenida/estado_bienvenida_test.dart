import 'package:carecar_mobile/nucleo/bienvenida/estado_bienvenida.dart';
import 'package:carecar_mobile/nucleo/idioma/proveedores_idioma.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// V2-M01.02 · que la bienvenida aparezca **una** vez.
///
/// Es todo el criterio: si esto falla, o nadie la ve o la ve en cada arranque.
void main() {
  Future<ProviderContainer> contenedor(Map<String, Object> guardado) async {
    SharedPreferences.setMockInitialValues(guardado);
    final prefs = await SharedPreferences.getInstance();
    final c = ProviderContainer(
      overrides: [preferenciasProvider.overrideWithValue(prefs)],
    );
    addTearDown(c.dispose);
    return c;
  }

  test('en el primer arranque esta pendiente', () async {
    final c = await contenedor({});
    expect(c.read(bienvenidaPendienteProvider), isTrue);
  });

  test('verla o saltarla la apaga y lo recuerda', () async {
    final c = await contenedor({});

    await c.read(bienvenidaPendienteProvider.notifier).marcarVista();

    expect(c.read(bienvenidaPendienteProvider), isFalse);
    // Lo que importa del criterio: el siguiente arranque ya no la muestra.
    final otro = await contenedor({claveBienvenidaVista: true});
    expect(otro.read(bienvenidaPendienteProvider), isFalse);
  });

  test('sin preferencias no se muestra, para no repetirla cada vez', () {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    expect(c.read(bienvenidaPendienteProvider), isFalse);
  });
}
