import 'package:carecar_mobile/nucleo/mapas/errores_mapas.dart';
import 'package:flutter_test/flutter_test.dart';

String describir(ErrorUbicacion error) => switch (error) {
  UbicacionPermisoDenegado() => 'denegado',
  UbicacionPermisoDenegadoParaSiempre() => 'siempre',
  UbicacionServicioApagado() => 'apagado',
  UbicacionTiempoAgotado() => 'tiempo',
};

void main() {
  test('los cuatro errores de ubicación son una jerarquía cerrada', () {
    expect(describir(const UbicacionPermisoDenegado()), 'denegado');
    expect(describir(const UbicacionPermisoDenegadoParaSiempre()), 'siempre');
    expect(describir(const UbicacionServicioApagado()), 'apagado');
    expect(describir(const UbicacionTiempoAgotado()), 'tiempo');
  });

  test('todos son Exception y traen un mensaje en español', () {
    const errores = <ErrorUbicacion>[
      UbicacionPermisoDenegado(),
      UbicacionPermisoDenegadoParaSiempre(),
      UbicacionServicioApagado(),
      UbicacionTiempoAgotado(),
    ];
    for (final e in errores) {
      expect(e, isA<Exception>());
      expect(e.mensaje, isNotEmpty);
    }
  });

  test('ErrorGeocodificacion conserva su mensaje', () {
    expect(const ErrorGeocodificacion('sin red').mensaje, 'sin red');
    expect(const ErrorGeocodificacion('x'), isA<Exception>());
  });
}
