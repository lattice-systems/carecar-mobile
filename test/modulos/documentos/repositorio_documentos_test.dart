import 'dart:convert';

import 'package:carecar_mobile/api/api_config.dart';
import 'package:carecar_mobile/api/cliente_api.dart';
import 'package:carecar_mobile/api/excepciones.dart';
import 'package:carecar_mobile/modulos/documentos/datos/repositorio_documentos_api.dart';
import 'package:carecar_mobile/modulos/documentos/datos/repositorio_documentos_fake.dart';
import 'package:carecar_mobile/modulos/documentos/dominio/documento_vehiculo.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'ayudas_documentos.dart';

const _poliza = {
  'id': 1,
  'vehiculoId': 5,
  'tipo': 'POLIZA',
  'titulo': null,
  'numero': 'POL-501-2026',
  'emitidoEn': '2025-12-28',
  'venceEn': '2026-12-27',
  'estado': 'POR_VENCER',
  'diasRestantes': 30,
  'origen': 'CLIENTE',
  'tieneArchivo': true,
  'aseguradora': 'Seguros Ejemplo',
  'telefonoAseguradora': '+52 800 000 1234',
};

const _factura = {
  'id': 4,
  'vehiculoId': 5,
  'tipo': 'FACTURA',
  'estado': 'SIN_FECHA',
  'origen': 'AGENCIA',
  'tieneArchivo': false,
};

http.Response _json(int status, Object cuerpo) => http.Response(
  jsonEncode(cuerpo),
  status,
  headers: {'content-type': 'application/json; charset=utf-8'},
);

RepositorioDocumentosApi _repo(http.Response Function(http.Request) f) =>
    RepositorioDocumentosApi(
      ClienteApi(
        config: ApiConfig.para('http://local/api/v1/app'),
        http: MockClient((req) async => f(req)),
      ),
    );

void main() {
  group('RepositorioDocumentosApi', () {
    test('pide los documentos del vehiculo y lee cada campo', () async {
      http.Request? pedida;
      final lista = await _repo((req) {
        pedida = req;
        return _json(200, [_poliza, _factura]);
      }).documentos(5);

      expect(pedida!.method, 'GET');
      expect(pedida!.url.path, '/api/v1/app/vehiculos/5/documentos');
      expect(lista, hasLength(2));
      final poliza = lista.first;
      expect(poliza.tipo, TipoDocumento.poliza);
      expect(poliza.numero, 'POL-501-2026');
      expect(poliza.emitidoEn, DateTime(2025, 12, 28));
      expect(poliza.venceEn, DateTime(2026, 12, 27));
      expect(poliza.estado, EstadoDocumento.porVencer);
      expect(poliza.diasRestantes, 30);
      expect(poliza.tieneArchivo, isTrue);
      expect(poliza.aseguradora, 'Seguros Ejemplo');
      expect(poliza.telefonoAseguradora, '+52 800 000 1234');
    });

    test('los campos opcionales pueden faltar o ir nulos', () async {
      final factura = (await _repo((_) => _json(200, [_factura])).documentos(5))
          .single;

      expect(factura.tipo, TipoDocumento.factura);
      expect(factura.origen, OrigenDocumento.agencia);
      expect(factura.venceEn, isNull);
      expect(factura.diasRestantes, isNull);
      expect(factura.aseguradora, isNull);
      expect(factura.estado, EstadoDocumento.sinFecha);
    });

    test('un vehiculo sin documentos devuelve una lista vacia', () async {
      expect(await _repo((_) => _json(200, [])).documentos(5), isEmpty);
    });

    test('un tipo o estado desconocidos no rompen la lectura', () async {
      final lista = await _repo(
        (_) => _json(200, [
          {..._poliza, 'tipo': 'NUEVO', 'estado': 'RARO'},
        ]),
      ).documentos(5);

      expect(lista.single.tipo, TipoDocumento.otro);
      expect(lista.single.estado, EstadoDocumento.sinFecha);
    });

    test('un documento sin id rompe el contrato', () async {
      final repo = _repo(
        (_) => _json(200, [
          {'tipo': 'POLIZA', 'vehiculoId': 5},
        ]),
      );
      await expectLater(repo.documentos(5), throwsA(isA<RespuestaInvalida>()));
    });

    test(
      'un vehiculo ajeno responde 404 y la excepcion pasa tal cual',
      () async {
        final repo = _repo(
          (_) => _json(404, {
            'timestamp': 't',
            'status': 404,
            'error': 'Not Found',
            'message': 'No existe',
            'path': '/vehiculos/9/documentos',
          }),
        );
        await expectLater(repo.documentos(9), throwsA(isA<NoEncontrado>()));
      },
    );

    test('sin red lanza SinConexion', () async {
      final repo = RepositorioDocumentosApi(
        ClienteApi(
          config: ApiConfig.para('http://local/api/v1/app'),
          http: MockClient((_) async => throw http.ClientException('sin red')),
        ),
      );
      await expectLater(repo.documentos(5), throwsA(isA<SinConexion>()));
    });
  });

  group('RepositorioDocumentosFake', () {
    test('devuelve solo los documentos del vehiculo pedido', () async {
      final repo = RepositorioDocumentosFake(
        documentos: [...documentosDeEjemplo(), documento(id: 9, vehiculoId: 6)],
      );
      expect(await repo.documentos(5), hasLength(4));
      expect(await repo.documentos(6), hasLength(1));
      expect(await repo.documentos(7), isEmpty);
    });

    test('con falla la lanza en cada lectura y cuenta las lecturas', () async {
      final repo = RepositorioDocumentosFake(falla: const SinConexion());
      await expectLater(repo.documentos(5), throwsA(isA<SinConexion>()));
      expect(repo.lecturas, 1);
    });
  });
}
