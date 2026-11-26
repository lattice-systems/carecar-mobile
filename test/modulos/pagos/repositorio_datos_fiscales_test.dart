import 'dart:convert';

import 'package:carecar_mobile/api/api_config.dart';
import 'package:carecar_mobile/api/cliente_api.dart';
import 'package:carecar_mobile/api/excepciones.dart';
import 'package:carecar_mobile/modulos/pagos/datos/repositorio_datos_fiscales_api.dart';
import 'package:carecar_mobile/modulos/pagos/datos/repositorio_datos_fiscales_fake.dart';
import 'package:carecar_mobile/modulos/pagos/dominio/datos_fiscales.dart';
import 'package:carecar_mobile/modulos/pagos/dominio/repositorio_datos_fiscales.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'ayudas_pagos.dart';

const _perfil = {
  'id': 10,
  'rfc': 'GODE561231GR8',
  'tipoPersona': 'FISICA',
  'razonSocial': 'DOLORES GÓMEZ',
  'regimenFiscal': '612',
  'codigoPostal': '76000',
  'usoCfdi': 'G03',
  'correo': null,
  'predeterminado': true,
  'creadoEn': '2026-11-26T18:00:00Z',
};

const _borrador = BorradorPerfilFiscal(
  rfc: ' gode561231gr8 ',
  razonSocial: ' Dolores Gómez ',
  codigoPostal: '76000',
  regimenFiscal: '612',
  usoCfdi: 'G03',
  correo: '  ',
  predeterminado: true,
);

http.Response _json(int status, Object cuerpo) => http.Response(
  jsonEncode(cuerpo),
  status,
  headers: {'content-type': 'application/json; charset=utf-8'},
);

RepositorioDatosFiscalesApi _repo(http.Response Function(http.Request) f) =>
    RepositorioDatosFiscalesApi(
      ClienteApi(
        config: ApiConfig.para('http://local/api/v1/app'),
        http: MockClient((req) async => f(req)),
      ),
    );

void main() {
  group('RepositorioDatosFiscalesApi', () {
    test('lee los catalogos con sus reglas', () async {
      http.Request? pedida;
      final catalogo = await _repo((req) {
        pedida = req;
        return _json(200, {
          'regimenes': [
            {
              'clave': '612',
              'descripcion': 'Personas Físicas',
              'fisica': true,
              'moral': false,
            },
          ],
          'usosCfdi': [
            {
              'clave': 'G03',
              'descripcion': 'Gastos en general',
              'fisica': true,
              'moral': true,
              'regimenes': ['601', '612'],
            },
          ],
        });
      }).catalogo();

      expect(pedida!.url.path, '/api/v1/app/catalogos-fiscales');
      expect(catalogo.regimen('612')!.aplicaA(TipoPersona.fisica), isTrue);
      expect(catalogo.uso('G03')!.aceptaRegimen('612'), isTrue);
      expect(catalogo.uso('G03')!.aceptaRegimen('605'), isFalse);
    });

    test('lee mis perfiles', () async {
      final perfiles = await _repo(
        (_) => _json(200, [
          _perfil,
          {
            ..._perfil,
            'id': 11,
            'tipoPersona': 'MORAL',
            'predeterminado': false,
          },
        ]),
      ).perfiles();

      expect(perfiles.first.tipoPersona, TipoPersona.fisica);
      expect(perfiles.first.correo, isNull);
      expect(perfiles.first.creadoEn, DateTime.utc(2026, 11, 26, 18));
      expect(perfiles.last.tipoPersona, TipoPersona.moral);
    });

    test('crear manda los datos limpios y el predeterminado', () async {
      http.Request? pedida;
      await _repo((req) {
        pedida = req;
        return _json(201, _perfil);
      }).crear(_borrador);

      expect(pedida!.method, 'POST');
      expect(pedida!.url.path, '/api/v1/app/perfiles-fiscales');
      expect(jsonDecode(pedida!.body), {
        'rfc': 'GODE561231GR8',
        'razonSocial': 'Dolores Gómez',
        'regimenFiscal': '612',
        'codigoPostal': '76000',
        'usoCfdi': 'G03',
        'correo': null,
        'predeterminado': true,
      });
    });

    test('editar usa PUT y borrar DELETE', () async {
      final pedidas = <http.Request>[];
      final repo = _repo((req) {
        pedidas.add(req);
        return req.method == 'DELETE'
            ? http.Response('', 204)
            : _json(200, _perfil);
      });

      await repo.editar(10, _borrador);
      await repo.borrar(10);

      expect(pedidas.map((p) => '${p.method} ${p.url.path}'), [
        'PUT /api/v1/app/perfiles-fiscales/10',
        'DELETE /api/v1/app/perfiles-fiscales/10',
      ]);
    });

    test('DATOS_FISCALES_INVALIDOS dice que corregir en cada campo', () async {
      await expectLater(
        _repo(
          (_) => _json(400, {
            'timestamp': 't',
            'status': 400,
            'error': 'Bad Request',
            'message': 'x',
            'codigo': 'DATOS_FISCALES_INVALIDOS',
            'campos': {
              'rfc': 'Revisa la homoclave',
              'usoCfdi': 'Ese uso no se puede',
              'campoNuevo': 'Se ignora',
            },
            'path': '/perfiles-fiscales',
          }),
        ).crear(_borrador),
        throwsA(
          isA<DatosFiscalesRechazados>().having((e) => e.campos, 'campos', {
            CampoFiscal.rfc: 'Revisa la homoclave',
            CampoFiscal.usoCfdi: 'Ese uso no se puede',
          }),
        ),
      );
    });

    test('otro 400 pasa tal cual', () async {
      await expectLater(
        _repo(
          (_) => _json(400, {
            'status': 400,
            'message': 'x',
            'codigo': 'DATOS_INVALIDOS',
          }),
        ).crear(_borrador),
        throwsA(isA<DatosInvalidos>()),
      );
    });
  });

  group('RepositorioDatosFiscalesFake', () {
    test('el primero es predeterminado y otro lo toma al pedirlo', () async {
      final repo = RepositorioDatosFiscalesFake(catalogo: catalogoDeEjemplo);
      final primero = await repo.crear(
        const BorradorPerfilFiscal(
          rfc: 'GODE561231GR8',
          razonSocial: 'Dolores',
          codigoPostal: '76000',
          regimenFiscal: '612',
          usoCfdi: 'G03',
        ),
      );
      expect(primero.predeterminado, isTrue);

      final segundo = await repo.crear(
        const BorradorPerfilFiscal(
          rfc: 'EKU9003173C9',
          razonSocial: 'Escuela',
          codigoPostal: '42501',
          regimenFiscal: '601',
          usoCfdi: 'G03',
          predeterminado: true,
        ),
      );
      final lista = await repo.perfiles();
      expect(lista.first.id, segundo.id);
      expect(lista.where((p) => p.predeterminado), hasLength(1));
    });

    test('al borrar el predeterminado lo toma el que sigue', () async {
      final repo = repoDeEjemplo();
      await repo.borrar(perfilFisica.id);
      final lista = await repo.perfiles();
      expect(lista.single.id, perfilMoral.id);
      expect(lista.single.predeterminado, isTrue);
    });
  });
}
