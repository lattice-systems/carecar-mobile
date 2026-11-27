import 'package:carecar_mobile/modulos/pagos/datos/pasarela_simulada.dart';
import 'package:carecar_mobile/modulos/pagos/dominio/pagos.dart';
import 'package:carecar_mobile/modulos/pagos/dominio/tarjetas.dart';
import 'package:flutter_test/flutter_test.dart';

final _hoy = DateTime(2026, 11, 26);

void main() {
  group('ReglasTarjeta (V2-M08.02)', () {
    test('Luhn acepta las tarjetas de prueba y rechaza un digito cambiado', () {
      for (final tarjeta in tarjetasDePrueba) {
        expect(
          ReglasTarjeta.luhn(tarjeta.numero),
          isTrue,
          reason: tarjeta.numero,
        );
      }
      expect(ReglasTarjeta.luhn('4242424242424241'), isFalse);
      expect(ReglasTarjeta.luhn(''), isFalse);
      expect(ReglasTarjeta.luhn('4242 4242'), isFalse);
    });

    test('las tarjetas de prueba son las mismas del backend', () {
      expect(tarjetasDePrueba.map((t) => t.token), [
        'tok_sim_visa',
        'tok_sim_mastercard',
        'tok_sim_visa_debito',
        'tok_sim_fondos_insuficientes',
        'tok_sim_3ds',
        'tok_sim_3ds_falla',
      ]);
      expect(tarjetasDePrueba.map((t) => t.ultimos4), [
        '4242',
        '4444',
        '5556',
        '9995',
        '3220',
        '1629',
      ]);
      expect(
        ReglasTarjeta.deNumero('4000 0566 5566 5556')?.tipo,
        TipoTarjeta.debito,
      );
      expect(ReglasTarjeta.deNumero('4111111111111111'), isNull);
    });

    test('el vencimiento se lee como MM/AA y vence al terminar su mes', () {
      expect(ReglasTarjeta.vencimiento('12/28'), (mes: 12, anio: 2028));
      expect(ReglasTarjeta.vencimiento(' 01 / 30 '), (mes: 1, anio: 2030));
      expect(ReglasTarjeta.vencimiento('13/28'), isNull);
      expect(ReglasTarjeta.vencimiento('1228'), isNull);
      expect(ReglasTarjeta.vencida(11, 2026, _hoy), isFalse);
      expect(ReglasTarjeta.vencida(10, 2026, _hoy), isTrue);
      expect(ReglasTarjeta.vencida(1, 2025, _hoy), isTrue);
      expect(ReglasTarjeta.agrupar('4242424242424242'), '4242 4242 4242 4242');
      expect(ReglasTarjeta.agrupar('42424'), '4242 4');
    });
  });

  group('BorradorTarjeta', () {
    test('sin errores con una tarjeta de prueba vigente', () {
      const borrador = BorradorTarjeta(
        numero: '4242 4242 4242 4242',
        vencimiento: '12/28',
        cvv: '123',
      );
      expect(borrador.errores(_hoy), isEmpty);
      expect(borrador.tarjeta?.token, 'tok_sim_visa');
    });

    test('marca cada campo que falla', () {
      expect(const BorradorTarjeta().errores(_hoy), {
        CampoTarjeta.numero: MotivoTarjeta.numeroVacio,
        CampoTarjeta.vencimiento: MotivoTarjeta.vencimientoVacio,
        CampoTarjeta.cvv: MotivoTarjeta.cvvInvalido,
      });
      expect(
        const BorradorTarjeta(
          numero: '4242 4242',
          vencimiento: '10/26',
          cvv: '12',
        ).errores(_hoy),
        {
          CampoTarjeta.numero: MotivoTarjeta.numeroIncompleto,
          CampoTarjeta.vencimiento: MotivoTarjeta.vencida,
          CampoTarjeta.cvv: MotivoTarjeta.cvvInvalido,
        },
      );
      expect(
        const BorradorTarjeta(
          numero: '4242424242424241',
          vencimiento: '99/99',
          cvv: '123',
        ).errores(_hoy),
        {
          CampoTarjeta.numero: MotivoTarjeta.numeroInvalido,
          CampoTarjeta.vencimiento: MotivoTarjeta.vencimientoInvalido,
        },
      );
      expect(
        const BorradorTarjeta(
          numero: '4111 1111 1111 1111',
          vencimiento: '12/60',
          cvv: '123',
        ).errores(_hoy),
        {
          CampoTarjeta.numero: MotivoTarjeta.noEsDePrueba,
          CampoTarjeta.vencimiento: MotivoTarjeta.vencimientoInvalido,
        },
      );
    });
  });

  group('PasarelaSimulada', () {
    test('cambia la tarjeta por su token sin el numero ni el CVV', () {
      final nueva = const PasarelaSimulada().tokenizar(
        const BorradorTarjeta(
          numero: '4000 0000 0000 3220',
          vencimiento: '12/28',
          cvv: '321',
          guardar: true,
        ),
        _hoy,
      );
      expect(nueva.token, 'tok_sim_3ds');
      expect(nueva.mesVence, 12);
      expect(nueva.anioVence, 2028);
      expect(nueva.guardar, isTrue);
    });

    test('una tarjeta que no pasa las reglas no sale del telefono', () {
      expect(
        () => const PasarelaSimulada().tokenizar(
          const BorradorTarjeta(
            numero: '4111111111111111',
            vencimiento: '12/28',
            cvv: '123',
          ),
          _hoy,
        ),
        throwsA(
          isA<TarjetaInvalida>().having((e) => e.errores, 'errores', {
            CampoTarjeta.numero: MotivoTarjeta.noEsDePrueba,
          }),
        ),
      );
    });
  });
}
