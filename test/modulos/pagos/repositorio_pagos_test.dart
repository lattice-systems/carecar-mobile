import 'dart:convert';

import 'package:carecar_mobile/api/api_config.dart';
import 'package:carecar_mobile/api/cliente_api.dart';
import 'package:carecar_mobile/api/excepciones.dart';
import 'package:carecar_mobile/modulos/pagos/datos/repositorio_pagos_api.dart';
import 'package:carecar_mobile/modulos/pagos/dominio/pagos.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

const _pago = {
  'id': 7,
  'ordenId': 41,
  'vehiculoId': 9,
  'monto': 1650.0,
  'moneda': 'MXN',
  'medio': 'TARJETA',
  'marca': 'VISA',
  'ultimos4': '4242',
  'tipoTarjeta': 'CREDITO',
  'estado': 'PAGADO',
  'motivoFallo': null,
  'requiereAutenticacion': false,
  'referencia': 'sim_pi_abc',
  'simulado': true,
  'metodoPagoId': null,
  'perfilFiscalId': 10,
  'pagadoEn': '2026-11-26T18:00:00Z',
  'creadoEn': '2026-11-26T18:00:00Z',
};

const _metodo = {
  'id': 1,
  'marca': 'VISA',
  'ultimos4': '4242',
  'tipo': 'CREDITO',
  'mesVence': 12,
  'anioVence': 2028,
  'vencida': false,
  'predeterminado': true,
  'creadoEn': '2026-11-26T18:00:00Z',
};

http.Response _json(int status, Object cuerpo) => http.Response(
  jsonEncode(cuerpo),
  status,
  headers: {'content-type': 'application/json; charset=utf-8'},
);

http.Response _conflicto(String codigo) => _json(409, {
  'timestamp': '2026-11-26T18:00:00Z',
  'status': 409,
  'error': 'Conflict',
  'message': 'No',
  'codigo': codigo,
  'path': '/api/v1/app/ordenes/41/pagos',
});

RepositorioPagosApi _repo(http.Response Function(http.Request) f) =>
    RepositorioPagosApi(
      ClienteApi(
        config: ApiConfig.para('http://local/api/v1/app'),
        http: MockClient((req) async => f(req)),
      ),
    );

void main() {
  group('RepositorioPagosApi (V2-M08.02, V2-M08.04 y V2-M08.07)', () {
    test(
      'paga con el token, la llave y los datos fiscales; nunca el numero',
      () async {
        late http.Request pedida;
        final pago =
            await _repo((req) {
              pedida = req;
              return _json(201, _pago);
            }).pagar(
              41,
              llave: 'llave-123456',
              medio: const TarjetaNueva(
                token: 'tok_sim_visa',
                mesVence: 12,
                anioVence: 2028,
                guardar: true,
              ),
              perfilFiscalId: 10,
            );

        expect(pedida.method, 'POST');
        expect(pedida.url.path, '/api/v1/app/ordenes/41/pagos');
        expect(pedida.headers['Idempotency-Key'], 'llave-123456');
        expect(jsonDecode(pedida.body), {
          'tarjeta': {
            'token': 'tok_sim_visa',
            'mesVence': 12,
            'anioVence': 2028,
          },
          'guardarTarjeta': true,
          'perfilFiscalId': 10,
        });
        expect(pedida.body, isNot(contains('4242')));
        expect(pago.estado, EstadoPago.pagado);
        expect(pago.monto, 1650);
        expect(pago.medio, MedioPago.tarjeta);
        expect(pago.tipoTarjeta, TipoTarjeta.credito);
        expect(pago.pagadoEn, DateTime.utc(2026, 11, 26, 18));
      },
    );

    test('con una tarjeta guardada manda solo su id', () async {
      late http.Request pedida;
      await _repo((req) {
        pedida = req;
        return _json(201, _pago);
      }).pagar(41, llave: 'llave-123456', medio: const TarjetaGuardada(1));

      expect(jsonDecode(pedida.body), {
        'metodoPagoId': 1,
        'perfilFiscalId': null,
      });
    });

    test('los 409 de pagos llegan como PagoRechazado', () async {
      for (final (codigo, motivo) in [
        ('ORDEN_NO_PAGABLE', MotivoRechazoPago.ordenNoPagable),
        ('PAGO_EN_CURSO', MotivoRechazoPago.pagoEnCurso),
      ]) {
        await expectLater(
          _repo(
            (_) => _conflicto(codigo),
          ).pagar(41, llave: 'llave-123456', medio: const TarjetaGuardada(1)),
          throwsA(
            isA<PagoRechazado>().having((e) => e.motivo, 'motivo', motivo),
          ),
        );
      }
      await expectLater(
        _repo((_) => _conflicto('PAGO_NO_PENDIENTE'))
            .autenticar(7, confirmada: true),
        throwsA(
          isA<PagoRechazado>().having(
            (e) => e.motivo,
            'motivo',
            MotivoRechazoPago.pagoNoPendiente,
          ),
        ),
      );
      await expectLater(
        _repo((_) => _conflicto('ORDEN_CERRADA'))
            .pagar(41, llave: 'llave-123456', medio: const TarjetaGuardada(1)),
        throwsA(isA<Conflicto>()),
      );
    });

    test('responde el 3-D Secure', () async {
      late http.Request pedida;
      final pago = await _repo((req) {
        pedida = req;
        return _json(200, {
          ..._pago,
          'estado': 'FALLIDO',
          'motivoFallo': 'AUTENTICACION_FALLIDA',
          'pagadoEn': null,
        });
      }).autenticar(7, confirmada: false);

      expect(pedida.url.path, '/api/v1/app/pagos/7/autenticacion');
      expect(jsonDecode(pedida.body), {'confirmada': false});
      expect(pago.estado, EstadoPago.fallido);
      expect(pago.motivoFallo, MotivoFalloPago.autenticacionFallida);
      expect(pago.pagadoEn, isNull);
    });

    test('lee la orden de su ticket con su cobro', () async {
      final orden = await _repo(
        (_) => _json(200, {
          'id': 41,
          'vehiculoId': 9,
          'fecha': '2026-11-26',
          'kilometraje': 15200,
          'estatus': 'TERMINADO',
          'manoDeObra': const [],
          'refacciones': const [],
          'totalManoDeObra': 1200.0,
          'totalRefacciones': 450.0,
          'subtotal': 1422.41,
          'iva': 227.59,
          'total': 1650.0,
          'pago': _pago,
          'pagable': false,
        }),
      ).orden(41);

      expect(orden.total, 1650);
      expect(orden.pagable, isFalse);
      expect(orden.pago?.referencia, 'sim_pi_abc');
    });

    test('mis pagos paginados y un motivo que aun no se conoce', () async {
      late http.Request pedida;
      final pagina = await _repo((req) {
        pedida = req;
        return _json(200, {
          'contenido': [
            {..._pago, 'estado': 'FALLIDO', 'motivoFallo': 'OTRO_NUEVO'},
          ],
          'pagina': 1,
          'tamano': 20,
          'totalElementos': 41,
          'totalPaginas': 3,
        });
      }).pagos(pagina: 1);

      expect(pedida.url.queryParameters, {'pagina': '1', 'tamano': '20'});
      expect(pagina.hayMas, isTrue);
      expect(pagina.pagos.single.motivoFallo, MotivoFalloPago.otro);
    });

    test('tarjetas guardadas: listar, predeterminar y borrar', () async {
      final pedidas = <String>[];
      final repo = _repo((req) {
        pedidas.add('${req.method} ${req.url.path}');
        return switch (req.method) {
          'GET' => _json(200, [_metodo]),
          'PUT' => _json(200, _metodo),
          _ => http.Response('', 204),
        };
      });

      final metodos = await repo.metodos();
      await repo.predeterminar(1);
      await repo.borrarMetodo(1);

      expect(metodos.single.ultimos4, '4242');
      expect(metodos.single.predeterminado, isTrue);
      expect(pedidas, [
        'GET /api/v1/app/metodos-pago',
        'PUT /api/v1/app/metodos-pago/1/predeterminado',
        'DELETE /api/v1/app/metodos-pago/1',
      ]);
    });
  });
}
