import 'package:carecar_mobile/nucleo/mapas/configuracion_teselas.dart';
import 'package:carecar_mobile/nucleo/mapas/coordenada.dart';
import 'package:carecar_mobile/nucleo/mapas/falsos.dart';
import 'package:carecar_mobile/nucleo/mapas/proveedores_mapas.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('por defecto las teselas son las de desarrollo', () {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    expect(
      c.read(configuracionTeselasProvider),
      ConfiguracionTeselas.openStreetMapDesarrollo,
    );
  });

  test('las pruebas sustituyen ubicación y geocodificador con fakes', () async {
    final c = ProviderContainer(
      overrides: [
        proveedorUbicacionProvider.overrideWithValue(
          UbicacionFalsa(posicion: const Coordenada(3, 4)),
        ),
        geocodificadorProvider.overrideWithValue(GeocodificadorFalso()),
      ],
    );
    addTearDown(c.dispose);
    expect(
      await c.read(proveedorUbicacionProvider).posicionActual(),
      const Coordenada(3, 4),
    );
    expect(await c.read(geocodificadorProvider).coordenadasDe('x'), isNull);
  });
}
