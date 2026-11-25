import 'package:carecar_mobile/api/modelos/traslado.dart';
import 'package:flutter_test/flutter_test.dart';

const _traslado = {
  'id': 5,
  'citaId': 9,
  'tipo': 'recoger',
  'estado': 'en_camino',
  'costo': 150,
  'fecha': '2026-12-01',
  'ventanaInicio': '07:00',
  'ventanaFin': '09:00',
  'ubicacionChofer': {
    'lat': 19.43,
    'lng': -99.13,
    'actualizadaEn': '2026-12-01T13:00:00Z',
  },
};

void main() {
  group('TrasladoDetalle', () {
    test('lee un traslado en camino con la ubicacion del chofer', () {
      final t = TrasladoDetalle.fromJson(_traslado);

      expect(t.id, 5);
      expect(t.citaId, 9);
      expect(t.esRecoger, isTrue);
      expect(t.estado, EstadoTraslado.enCamino);
      expect(t.costo, 150.0);
      expect(t.fecha, DateTime(2026, 12));
      expect(t.ventanaInicio, '07:00');
      expect(t.ubicacionChofer?.lat, 19.43);
      expect(t.ubicacionChofer?.actualizadaEn.isUtc, isTrue);
    });

    test('sin ubicacionChofer queda nula', () {
      final t = TrasladoDetalle.fromJson(
        {..._traslado, 'estado': 'programado'}..remove('ubicacionChofer'),
      );

      expect(t.estado, EstadoTraslado.programado);
      expect(t.ubicacionChofer, isNull);
    });

    test('lee todos los estados del contrato y uno desconocido', () {
      const pares = {
        'programado': EstadoTraslado.programado,
        'en_camino': EstadoTraslado.enCamino,
        'recogido': EstadoTraslado.recogido,
        'en_taller': EstadoTraslado.enTaller,
        'de_regreso': EstadoTraslado.deRegreso,
        'entregado': EstadoTraslado.entregado,
        'cancelado': EstadoTraslado.cancelado,
      };
      pares.forEach((texto, estado) {
        expect(EstadoTraslado.desde(texto), estado);
      });
      expect(EstadoTraslado.desde('inventado'), EstadoTraslado.programado);
    });

    test('solo en camino y de regreso muestran al chofer', () {
      final visibles = EstadoTraslado.values.where((e) => e.muestraChofer);

      expect(visibles, [EstadoTraslado.enCamino, EstadoTraslado.deRegreso]);
    });

    test(
      'un estado que no es en camino ni de regreso descarta la ubicacion',
      () {
        final t = TrasladoDetalle.fromJson(_traslado);

        expect(t.conEstado(EstadoTraslado.recogido).ubicacionChofer, isNull);
        expect(
          t.conEstado(EstadoTraslado.deRegreso).ubicacionChofer?.lat,
          19.43,
        );
      },
    );

    test('conUbicacion reemplaza la ubicacion', () {
      final t = TrasladoDetalle.fromJson(_traslado).conUbicacion(
        UbicacionChofer(
          lat: 20,
          lng: -100,
          actualizadaEn: DateTime.utc(2026, 12, 1, 13, 5),
        ),
      );

      expect(t.ubicacionChofer?.lat, 20);
    });

    test('un traslado sin id lanza FormatException', () {
      expect(
        () => TrasladoDetalle.fromJson({..._traslado}..remove('id')),
        throwsFormatException,
      );
    });
  });

  group('ChecklistTraslado', () {
    const json = {
      'trasladoId': 5,
      'km': 45200,
      'gasolina': 'tres_cuartos',
      'notas': 'Rayón en la salpicadera',
      'fotos': ['https://x/f1.jpg?firma=a', 'https://x/f2.jpg?firma=b'],
      'firmaUrl': 'https://x/firma.png?firma=c',
      'registradoEn': '2026-12-01T13:10:00Z',
    };

    test('lee km, gasolina, notas, fotos y firma', () {
      final c = ChecklistTraslado.fromJson(json);

      expect(c.trasladoId, 5);
      expect(c.km, 45200);
      expect(c.gasolina, NivelGasolina.tresCuartos);
      expect(c.gasolina.cuartos, 3);
      expect(c.notas, 'Rayón en la salpicadera');
      expect(c.fotos, hasLength(2));
      expect(c.firmaUrl, contains('firma.png'));
    });

    test('notas, fotos y firma pueden faltar', () {
      final c = ChecklistTraslado.fromJson({
        'trasladoId': 5,
        'km': 10,
        'gasolina': 'vacio',
        'registradoEn': '2026-12-01T13:10:00Z',
      });

      expect(c.notas, isNull);
      expect(c.fotos, isEmpty);
      expect(c.firmaUrl, isNull);
      expect(c.gasolina.cuartos, 0);
    });

    test('cubre los cinco niveles de gasolina', () {
      expect(NivelGasolina.values.map((n) => n.cuartos), [0, 1, 2, 3, 4]);
      expect(NivelGasolina.desde('un_cuarto'), NivelGasolina.unCuarto);
      expect(NivelGasolina.desde('medio'), NivelGasolina.medio);
      expect(NivelGasolina.desde('lleno'), NivelGasolina.lleno);
    });
  });
}
