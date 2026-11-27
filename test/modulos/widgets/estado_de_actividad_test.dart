import 'package:carecar_mobile/modulos/taller/taller.dart';
import 'package:carecar_mobile/modulos/widgets/dominio/actividad_en_vivo.dart';
import 'package:flutter_test/flutter_test.dart';

OrdenEnCurso _orden({
  EtapaTaller etapa = EtapaTaller.enReparacion,
  int avance = 43,
  int adicionalesPendientes = 1,
  DateTime? entregaEstimada,
}) => OrdenEnCurso(
  id: 41,
  vehiculoId: 1,
  vehiculo: 'Nissan March 2026',
  etapa: etapa,
  avance: avance,
  adicionalesPendientes: adicionalesPendientes,
  entregaEstimada: entregaEstimada,
  asesor: 'Laura Méndez',
);

void main() {
  group('EstadoDeActividad desde la orden en curso', () {
    test('lleva las llaves del content-state que manda el backend', () {
      final estado = EstadoDeActividad.deOrden(
        _orden(entregaEstimada: DateTime(2026, 11, 22, 18)),
      );

      expect(estado.comoContentState(), {
        'etapa': 'EN_REPARACION',
        'estatus': 'EN_PROCESO',
        'avance': 43,
        'adicionalesPendientes': 1,
        // 18:00 en la agencia (America/Mexico_City, UTC-6) son las 00:00 UTC
        // del dia siguiente: el mismo Instant que el backend pasa a segundos.
        'entregaEstimada':
            DateTime.utc(2026, 11, 23).millisecondsSinceEpoch ~/ 1000,
      });
    });

    test('sin hora estimada omite la llave, como el backend', () {
      final estado = EstadoDeActividad.deOrden(_orden());

      expect(estado.entregaEstimada, isNull);
      expect(estado.comoContentState().containsKey('entregaEstimada'), isFalse);
    });

    test('el estatus sale de la etapa con la regla del backend', () {
      const esperado = {
        EtapaTaller.recibido: 'RECIBIDO',
        EtapaTaller.diagnostico: 'EN_PROCESO',
        EtapaTaller.esperandoAprobacion: 'EN_PROCESO',
        EtapaTaller.enReparacion: 'EN_PROCESO',
        EtapaTaller.controlDeCalidad: 'EN_PROCESO',
        EtapaTaller.lavado: 'EN_PROCESO',
        EtapaTaller.listoParaEntrega: 'TERMINADO',
        EtapaTaller.entregado: 'ENTREGADO',
      };
      for (final etapa in EtapaTaller.values) {
        final estado = EstadoDeActividad.deOrden(_orden(etapa: etapa));
        expect(estado.etapa, etapa.enElContrato, reason: '$etapa');
        expect(estado.estatus, esperado[etapa], reason: '$etapa');
      }
    });

    test('no lleva auto, asesor ni datos del cliente', () {
      final valores = EstadoDeActividad.deOrden(
        _orden(entregaEstimada: DateTime(2026, 11, 22, 18)),
      ).comoContentState().values.join('|');

      expect(valores, isNot(contains('Nissan')));
      expect(valores, isNot(contains('Laura')));
    });
  });

  group('EstadoDeActividad', () {
    test('al entregar queda en la ultima etapa, al 100 y sin pendientes', () {
      final entregada = EstadoDeActividad.deOrden(
        _orden(entregaEstimada: DateTime(2026, 11, 22, 18)),
      ).entregada();

      expect(entregada.etapa, 'ENTREGADO');
      expect(entregada.estatus, 'ENTREGADO');
      expect(entregada.avance, 100);
      expect(entregada.adicionalesPendientes, 0);
      expect(entregada.entregaEstimada, isNotNull);
    });

    test('dos estados con los mismos valores son iguales', () {
      final a = EstadoDeActividad.deOrden(_orden());
      final b = EstadoDeActividad.deOrden(_orden());
      final otro = EstadoDeActividad.deOrden(_orden(avance: 57));

      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(otro));
    });
  });

  group('esPushTokenValido', () {
    test('acepta hexadecimal de hasta 300 caracteres, como el contrato', () {
      expect(esPushTokenValido('aabbccDDEE0011'), isTrue);
      expect(esPushTokenValido('a' * 300), isTrue);
      expect(esPushTokenValido(''), isFalse);
      expect(esPushTokenValido('a' * 301), isFalse);
      expect(esPushTokenValido('token-con-guiones'), isFalse);
    });
  });
}
