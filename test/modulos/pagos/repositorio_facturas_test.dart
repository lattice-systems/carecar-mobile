import 'dart:convert';

import 'package:carecar_mobile/api/api_config.dart';
import 'package:carecar_mobile/api/cliente_api.dart';
import 'package:carecar_mobile/api/excepciones.dart';
import 'package:carecar_mobile/modulos/pagos/datos/repositorio_pagos_api.dart';
import 'package:carecar_mobile/modulos/pagos/dominio/pagos.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

const _factura = {
  'id': 3,
  'pagoId': 7,
  'folio': 'A-000124',
  'uuid': '6F1C2A3B-4D5E-4F60-8A7B-000000000007',
  'rfcReceptor': 'GODE561231GR8',
  'razonSocialReceptor': 'DOLORES GÓMEZ',
  'usoCfdi': 'G03',
  'total': 1650.0,
  'simulada': true,
  'timbradaEn': '2026-11-26T18:00:05Z',
};

const _pago = {
  'id': 7,
  'ordenId': 41,
  'pedidoId': null,
  'vehiculoId': 9,
  'monto': 1650.0,
  'moneda': 'MXN',
  'medio': 'APPLE_PAY',
  'marca': null,
  'ultimos4': null,
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
  'factura': _factura,
  'facturable': false,
};

http.Response _json(int status, Object cuerpo) => http.Response(
  jsonEncode(cuerpo),
  status,
  headers: {'content-type': 'application/json; charset=utf-8'},
);

http.Response _problema(int status, String codigo, {Object? campos}) =>
    _json(status, {
      'timestamp': '2026-11-26T18:00:00Z',
      'status': status,
      'error': 'No',
      'message': 'No',
      'codigo': codigo,
      if (campos != null) 'campos': campos,
      'path': '/api/v1/app/pagos/7/factura',
    });

RepositorioPagosApi _repo(http.Response Function(http.Request) f) =>
    RepositorioPagosApi(
      ClienteApi(
        config: ApiConfig.para('http://local/api/v1/app'),
        http: MockClient((req) async => f(req)),
      ),
    );

Factura _leida() => Factura(
  id: 3,
  pagoId: 7,
  folio: 'A-000124',
  uuid: '6F1C2A3B-4D5E-4F60-8A7B-000000000007',
  rfcReceptor: 'GODE561231GR8',
  razonSocialReceptor: 'DOLORES GÓMEZ',
  usoCfdi: 'G03',
  total: 1650,
  timbradaEn: DateTime.utc(2026, 11, 26, 18, 0, 5),
);

void main() {
  group('RepositorioPagosApi: billeteras y facturas (V2-M08.03 y '
      'V2-M08.06)', () {
    test('paga con la billetera simulada sin tarjeta ni token', () async {
      late http.Request pedida;
      final pago =
          await _repo((req) {
            pedida = req;
            return _json(201, _pago);
          }).pagar(
            41,
            llave: 'llave-123456',
            medio: const Billetera(MedioPago.applePay),
            perfilFiscalId: 10,
          );

      expect(jsonDecode(pedida.body), {
        'billetera': 'APPLE_PAY',
        'perfilFiscalId': 10,
      });
      expect(pago.medio, MedioPago.applePay);
      expect(pago.marca, isNull);
      expect(pago.factura?.folio, 'A-000124');
      expect(pago.facturable, isFalse);
    });

    test('lee un pago sin factura que se puede facturar', () async {
      final pago = await _repo(
        (_) => _json(200, {..._pago, 'factura': null, 'facturable': true}),
      ).pago(7);

      expect(pago.factura, isNull);
      expect(pago.facturable, isTrue);
    });

    test('factura con el perfil y lee la factura timbrada', () async {
      late http.Request pedida;
      final factura = await _repo((req) {
        pedida = req;
        return _json(201, _factura);
      }).facturar(7, perfilFiscalId: 10);

      expect(pedida.method, 'POST');
      expect(pedida.url.path, '/api/v1/app/pagos/7/factura');
      expect(jsonDecode(pedida.body), {'perfilFiscalId': 10});
      expect(factura.folio, 'A-000124');
      expect(factura.uuid, '6F1C2A3B-4D5E-4F60-8A7B-000000000007');
      expect(factura.usoCfdi, 'G03');
      expect(factura.total, 1650);
      expect(factura.timbradaEn, DateTime.utc(2026, 11, 26, 18, 0, 5));
    });

    test('los 409 de facturas llegan como FacturaRechazada', () async {
      for (final (codigo, motivo) in [
        ('YA_FACTURADO', MotivoRechazoFactura.yaFacturado),
        ('PAGO_NO_FACTURABLE', MotivoRechazoFactura.pagoNoFacturable),
      ]) {
        await expectLater(
          _repo((_) => _problema(409, codigo)).facturar(7, perfilFiscalId: 10),
          throwsA(
            isA<FacturaRechazada>().having((e) => e.motivo, codigo, motivo),
          ),
        );
      }
    });

    test('el 422 del timbrado dice que campos corregir', () async {
      await expectLater(
        _repo(
          (_) => _problema(
            422,
            'TIMBRADO_RECHAZADO',
            campos: {
              'razonSocial': 'Sin el régimen societario',
              'codigoPostal': 'No existe',
            },
          ),
        ).facturar(7, perfilFiscalId: 10),
        throwsA(
          isA<TimbradoRechazado>().having((e) => e.campos, 'campos', {
            'razonSocial',
            'codigoPostal',
          }),
        ),
      );
    });

    test('otro 409 o 422 no se disfraza de rechazo de factura', () async {
      await expectLater(
        _repo((_) => _problema(409, 'PAGO_EN_CURSO'))
            .facturar(7, perfilFiscalId: 10),
        throwsA(isA<Conflicto>()),
      );
      await expectLater(
        _repo((_) => _problema(422, 'DATOS_FISCALES_INVALIDOS'))
            .facturar(7, perfilFiscalId: 10),
        throwsA(isA<SolicitudRechazada>()),
      );
    });

    test('descarga el PDF y el XML con su nombre', () async {
      final pedidas = <String>[];
      final repo = _repo((req) {
        pedidas.add(req.url.path);
        return http.Response.bytes(
          utf8.encode(
            req.url.path.endsWith('pdf') ? '%PDF-1.4' : '<cfdi:Comprobante/>',
          ),
          200,
        );
      });

      final pdf = await repo.descargarFactura(_leida(), FormatoFactura.pdf);
      final xml = await repo.descargarFactura(_leida(), FormatoFactura.xml);

      expect(pedidas, [
        '/api/v1/app/facturas/3/pdf',
        '/api/v1/app/facturas/3/xml',
      ]);
      expect(pdf.nombre, 'factura-A-000124.pdf');
      expect(utf8.decode(pdf.bytes), '%PDF-1.4');
      expect(pdf.formato.tipoContenido, 'application/pdf');
      expect(xml.nombre, 'factura-A-000124.xml');
      expect(xml.formato.tipoContenido, 'application/xml');
    });

    test('una factura ajena llega como NoEncontrado', () async {
      await expectLater(
        _repo((_) => _problema(404, 'NO_ENCONTRADO'))
            .descargarFactura(_leida(), FormatoFactura.pdf),
        throwsA(isA<NoEncontrado>()),
      );
    });
  });
}
