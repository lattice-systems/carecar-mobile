import 'dart:convert';

import 'package:carecar_mobile/api/api_config.dart';
import 'package:carecar_mobile/api/cliente_api.dart';
import 'package:carecar_mobile/api/excepciones.dart';
import 'package:carecar_mobile/modulos/lealtad/datos/repositorio_lealtad_api.dart';
import 'package:carecar_mobile/modulos/lealtad/datos/repositorio_lealtad_fake.dart';
import 'package:carecar_mobile/modulos/lealtad/dominio/lealtad.dart';
import 'package:carecar_mobile/modulos/lealtad/dominio/repositorio_lealtad.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'ayudas_lealtad.dart';

const _resumen = {
  'saldo': 1330,
  'nivel': 'PLATA',
  'ganados': 1630,
  'siguienteNivel': 'ORO',
  'puntosParaSiguiente': 2370,
  'codigoReferido': 'CC00001',
};

const _canje = {
  'id': 2,
  'codigo': '5A6H4J78',
  'recompensa': '10 % en mano de obra',
  'puntos': 800,
  'estado': 'VIGENTE',
  'venceEn': '2026-12-24T18:00:00Z',
  'usadoEn': null,
  'creadoEn': '2026-11-24T18:00:00Z',
};

const _referido = {
  'id': 3,
  'nombre': 'Ana Torres',
  'estado': 'REGISTRADO',
  'puntos': 0,
  'creadoEn': '2026-11-24T18:00:00Z',
  'recompensadoEn': null,
};

http.Response _json(int status, Object cuerpo) => http.Response(
  jsonEncode(cuerpo),
  status,
  headers: {'content-type': 'application/json; charset=utf-8'},
);

http.Response _conflicto(String codigo) => _json(409, {
  'timestamp': 't',
  'status': 409,
  'error': 'Conflict',
  'message': 'x',
  'codigo': codigo,
  'path': '/lealtad',
});

RepositorioLealtadApi _repo(http.Response Function(http.Request) f) =>
    RepositorioLealtadApi(
      ClienteApi(
        config: ApiConfig.para('http://local/api/v1/app'),
        http: MockClient((req) async => f(req)),
      ),
    );

void main() {
  group('RepositorioLealtadApi', () {
    test('lee saldo, nivel, lo que falta y mi codigo', () async {
      http.Request? pedida;
      final resumen = await _repo((req) {
        pedida = req;
        return _json(200, _resumen);
      }).resumen();

      expect(pedida!.method, 'GET');
      expect(pedida!.url.path, '/api/v1/app/lealtad');
      expect(resumen.saldo, 1330);
      expect(resumen.nivel, NivelLealtad.plata);
      expect(resumen.ganados, 1630);
      expect(resumen.siguienteNivel, NivelLealtad.oro);
      expect(resumen.puntosParaSiguiente, 2370);
      expect(resumen.codigoReferido, 'CC00001');
      expect(resumen.avance, closeTo(0.4075, 0.0001));
    });

    test('en Oro no hay siguiente nivel y el avance es completo', () async {
      final resumen = await _repo(
        (_) => _json(200, {
          ..._resumen,
          'nivel': 'ORO',
          'siguienteNivel': null,
          'puntosParaSiguiente': 0,
        }),
      ).resumen();
      expect(resumen.siguienteNivel, isNull);
      expect(resumen.avance, 1);
    });

    test('un nivel desconocido se lee como Bronce', () async {
      final resumen = await _repo(
        (_) => _json(200, {..._resumen, 'nivel': 'PLATINO'}),
      ).resumen();
      expect(resumen.nivel, NivelLealtad.bronce);
    });

    test('pide los movimientos paginados y sabe si hay mas', () async {
      http.Request? pedida;
      final pagina = await _repo((req) {
        pedida = req;
        return _json(200, {
          'contenido': [
            {
              'id': 2,
              'puntos': 230,
              'motivo': 'SERVICIO',
              'referenciaTipo': 'ORDEN',
              'referenciaId': 2,
              'creadoEn': '2026-08-30T18:00:00Z',
            },
            {
              'id': 1,
              'puntos': 900,
              'motivo': 'BONO_NUEVO',
              'referenciaTipo': null,
              'referenciaId': null,
              'creadoEn': '2026-07-01T18:00:00Z',
            },
          ],
          'pagina': 1,
          'tamano': 20,
          'totalElementos': 42,
          'totalPaginas': 3,
        });
      }).movimientos(pagina: 1);

      expect(pedida!.url.path, '/api/v1/app/lealtad/movimientos');
      expect(pedida!.url.queryParameters, {'pagina': '1', 'tamano': '20'});
      expect(pagina.pagina, 1);
      expect(pagina.hayMas, isTrue);
      final servicio = pagina.movimientos.first;
      expect(servicio.motivo, MotivoPuntos.servicio);
      expect(servicio.referenciaTipo, 'ORDEN');
      expect(servicio.referenciaId, 2);
      expect(servicio.creadoEn, DateTime.utc(2026, 8, 30, 18));
      expect(pagina.movimientos.last.motivo, MotivoPuntos.desconocido);
      expect(pagina.movimientos.last.referenciaId, isNull);
    });

    test('lee las recompensas con y sin existencia', () async {
      final recompensas = await _repo(
        (_) => _json(200, [
          {
            'id': 1,
            'nombre': 'Lavado exprés',
            'descripcion': null,
            'puntos': 300,
            'existencia': null,
          },
          {'id': 5, 'nombre': 'Termo', 'puntos': 400, 'existencia': 0},
        ]),
      ).recompensas();
      expect(recompensas.first.existencia, isNull);
      expect(recompensas.first.agotada, isFalse);
      expect(recompensas.last.agotada, isTrue);
    });

    test('canjear manda la recompensa y lee el codigo', () async {
      http.Request? pedida;
      final canje = await _repo((req) {
        pedida = req;
        return _json(201, _canje);
      }).canjear(2);

      expect(pedida!.method, 'POST');
      expect(pedida!.url.path, '/api/v1/app/lealtad/canjes');
      expect(jsonDecode(pedida!.body), {'recompensaId': 2});
      expect(canje.codigo, '5A6H4J78');
      expect(canje.estado, EstadoCanje.vigente);
      expect(canje.venceEn, DateTime.utc(2026, 12, 24, 18));
      expect(canje.usadoEn, isNull);
    });

    test('SALDO_INSUFICIENTE y RECOMPENSA_AGOTADA se explican', () async {
      await expectLater(
        _repo((_) => _conflicto('SALDO_INSUFICIENTE')).canjear(1),
        throwsA(
          isA<CanjeRechazado>().having(
            (e) => e.motivo,
            'motivo',
            MotivoRechazoCanje.saldoInsuficiente,
          ),
        ),
      );
      await expectLater(
        _repo((_) => _conflicto('RECOMPENSA_AGOTADA')).canjear(1),
        throwsA(
          isA<CanjeRechazado>().having(
            (e) => e.motivo,
            'motivo',
            MotivoRechazoCanje.agotada,
          ),
        ),
      );
    });

    test('otro 409 al canjear pasa tal cual', () async {
      await expectLater(
        _repo((_) => _conflicto('OTRO')).canjear(1),
        throwsA(isA<Conflicto>()),
      );
    });

    test('un estado de canje desconocido se lee como vencido', () async {
      final canjes = await _repo(
        (_) => _json(200, [
          {..._canje, 'estado': 'ANULADO'},
        ]),
      ).canjes();
      expect(canjes.single.estado, EstadoCanje.vencido);
    });

    test('referir manda el contacto que hay y el consentimiento', () async {
      http.Request? pedida;
      final referido = await _repo((req) {
        pedida = req;
        return _json(201, _referido);
      }).referir(nombre: 'Ana Torres', telefono: '4421234567');

      expect(pedida!.url.path, '/api/v1/app/lealtad/referidos');
      expect(jsonDecode(pedida!.body), {
        'nombre': 'Ana Torres',
        'telefono': '4421234567',
        'consentimiento': true,
      });
      expect(referido.estado, EstadoReferido.registrado);
    });

    test('REFERIDO_DUPLICADO y LIMITE_REFERIDOS se explican', () async {
      await expectLater(
        _repo((_) => _conflicto('REFERIDO_DUPLICADO'))
            .referir(nombre: 'Ana', correo: 'ana@correo.mx'),
        throwsA(
          isA<ReferidoRechazado>().having(
            (e) => e.motivo,
            'motivo',
            MotivoRechazoReferido.duplicado,
          ),
        ),
      );
      await expectLater(
        _repo((_) => _conflicto('LIMITE_REFERIDOS'))
            .referir(nombre: 'Ana', correo: 'ana@correo.mx'),
        throwsA(
          isA<ReferidoRechazado>().having(
            (e) => e.motivo,
            'motivo',
            MotivoRechazoReferido.limite,
          ),
        ),
      );
    });

    test('lee mis referidos', () async {
      final referidos = await _repo(
        (_) => _json(200, [
          {..._referido, 'estado': 'COMPRO', 'puntos': 500},
        ]),
      ).referidos();
      expect(referidos.single.estado, EstadoReferido.compro);
      expect(referidos.single.puntos, 500);
    });
  });

  group('RepositorioLealtadFake', () {
    test('canjear baja el saldo y agrega el canje y su movimiento', () async {
      final repo = repoDeEjemplo();
      final canje = await repo.canjear(1);

      expect(canje.estado, EstadoCanje.vigente);
      expect(canje.venceEn, hoyLealtad.add(const Duration(days: 30)));
      expect((await repo.resumen()).saldo, 1030);
      expect((await repo.canjes()).first.id, canje.id);
      final pagina = await repo.movimientos();
      expect(pagina.movimientos.first.puntos, -300);
      expect(pagina.movimientos.first.referenciaId, canje.id);
    });

    test('pagina los movimientos', () async {
      final repo = RepositorioLealtadFake(movimientos: muchosMovimientos(25));
      final primera = await repo.movimientos();
      final segunda = await repo.movimientos(pagina: 1);
      expect(primera.movimientos, hasLength(20));
      expect(primera.hayMas, isTrue);
      expect(segunda.movimientos, hasLength(5));
      expect(segunda.hayMas, isFalse);
    });
  });
}
