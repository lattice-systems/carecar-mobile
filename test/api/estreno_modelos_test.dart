import 'package:carecar_mobile/api/modelos/modelos.dart';
import 'package:flutter_test/flutter_test.dart';

const _cotizacionJson = <String, Object?>{
  'precio': 300000,
  'enganche': 60000.5,
  'montoFinanciado': 239999.5,
  'tasaAnual': 0.1499,
  'plazoMeses': 48,
  'mensualidad': 6678.16,
  'leyenda': 'Estimación no vinculante.',
};

Map<String, Object?> _solicitudJson([
  Map<String, Object?> cambios = const {},
]) => {
  'id': 5,
  'tipo': 'PRUEBA_MANEJO',
  'modeloCatalogoId': 7,
  'modelo': 'Nissan Kicks 2026 Advance',
  'estado': 'RECIBIDA',
  'creadaEn': '2026-11-24T18:30:00Z',
  ...cambios,
};

void main() {
  group('CotizacionEstreno (V2-M16.02)', () {
    test('lee enteros y decimales del JSON como pesos', () {
      final c = CotizacionEstreno.fromJson(_cotizacionJson);
      expect(c.precio, 300000.0);
      expect(c.enganche, 60000.5);
      expect(c.montoFinanciado, 239999.5);
      expect(c.tasaAnual, 0.1499);
      expect(c.plazoMeses, 48);
      expect(c.mensualidad, 6678.16);
      expect(c.leyenda, 'Estimación no vinculante.');
    });

    test('sin leyenda no respeta el contrato', () {
      final sinLeyenda = {..._cotizacionJson}..remove('leyenda');
      expect(
        () => CotizacionEstreno.fromJson(sinLeyenda),
        throwsFormatException,
      );
    });
  });

  group('SolicitudEstreno (V2-M16.04)', () {
    test('la mínima viene sin vendedor, día, franja ni cotización', () {
      final s = SolicitudEstreno.fromJson(_solicitudJson());
      expect(s.id, 5);
      expect(s.tipo, 'PRUEBA_MANEJO');
      expect(s.modeloCatalogoId, 7);
      expect(s.modelo, 'Nissan Kicks 2026 Advance');
      expect(s.estado, 'RECIBIDA');
      expect(s.creadaEn, DateTime.utc(2026, 11, 24, 18, 30));
      expect(s.vendedor, isNull);
      expect(s.preferenciaFecha, isNull);
      expect(s.preferenciaFranja, isNull);
      expect(s.cotizacion, isNull);
      expect(s.estimacionTomaCuentaId, isNull);
    });

    test('la completa trae vendedor, preferencia, cotización y estimación', () {
      final s = SolicitudEstreno.fromJson(
        _solicitudJson({
          'estado': 'EN_ATENCION',
          'vendedor': 'Vera Vendedora',
          'preferenciaFecha': '2026-11-26',
          'preferenciaFranja': 'TARDE',
          'cotizacion': _cotizacionJson,
          'estimacionTomaCuentaId': 3,
        }),
      );
      expect(s.estado, 'EN_ATENCION');
      expect(s.vendedor, 'Vera Vendedora');
      expect(s.preferenciaFecha, DateTime(2026, 11, 26));
      expect(s.preferenciaFranja, 'TARDE');
      expect(s.cotizacion!.plazoMeses, 48);
      expect(s.estimacionTomaCuentaId, 3);
    });

    test('sin modelo no respeta el contrato', () {
      final sinModelo = _solicitudJson()..remove('modelo');
      expect(() => SolicitudEstreno.fromJson(sinModelo), throwsFormatException);
    });

    test('una fecha de creación rota falla en vez de inventar 1970', () {
      expect(
        () => SolicitudEstreno.fromJson(_solicitudJson({'creadaEn': 'ayer'})),
        throwsFormatException,
      );
    });
  });

  group('NuevaSolicitudEstreno (V2-M16.01 y V2-M16.02)', () {
    test('la prueba manda día y franja, con el día en AAAA-MM-DD', () {
      final nueva = NuevaSolicitudEstreno(
        tipo: 'PRUEBA_MANEJO',
        modeloCatalogoId: 7,
        preferenciaFecha: DateTime(2026, 1, 5),
        preferenciaFranja: 'MANANA',
      );
      expect(nueva.toJson(), {
        'tipo': 'PRUEBA_MANEJO',
        'modeloCatalogoId': 7,
        'preferenciaFecha': '2026-01-05',
        'preferenciaFranja': 'MANANA',
      });
    });

    test('la cotización manda enganche y plazo, y la estimación si hay', () {
      const nueva = NuevaSolicitudEstreno(
        tipo: 'COTIZACION',
        modeloCatalogoId: 7,
        enganche: 60000,
        plazoMeses: 48,
        estimacionTomaCuentaId: 3,
      );
      expect(nueva.toJson(), {
        'tipo': 'COTIZACION',
        'modeloCatalogoId': 7,
        'enganche': 60000,
        'plazoMeses': 48,
        'estimacionTomaCuentaId': 3,
      });
    });
  });
}
