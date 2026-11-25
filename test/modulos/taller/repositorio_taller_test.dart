import 'dart:convert';
import 'dart:typed_data';

import 'package:carecar_mobile/api/api_config.dart';
import 'package:carecar_mobile/api/cliente_api.dart';
import 'package:carecar_mobile/api/excepciones.dart';
import 'package:carecar_mobile/modulos/taller/datos/repositorio_taller_api.dart';
import 'package:carecar_mobile/modulos/taller/datos/repositorio_taller_fake.dart';
import 'package:carecar_mobile/modulos/taller/dominio/etapa_taller.dart';
import 'package:carecar_mobile/modulos/taller/dominio/orden_taller.dart';
import 'package:carecar_mobile/modulos/taller/dominio/repositorio_taller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

final _firma = Uint8List.fromList([0x89, 0x50, 0x4E, 0x47, 1, 2]);

const _orden = {
  'id': 41,
  'vehiculoId': 5,
  'vehiculo': 'Nissan March 2026',
  'estatus': 'EN_PROCESO',
  'etapa': 'ESPERANDO_APROBACION',
  'entregaEstimada': null,
  'asesor': 'Laura Méndez',
  'avance': 29,
  'etapas': [
    {
      'etapa': 'RECIBIDO',
      'inicio': '2026-11-24T09:30:00',
      'fin': null,
      'nota': null,
    },
  ],
  'inspeccion': [],
  'evidencias': [],
  'adicionales': [
    {
      'id': 11,
      'concepto': 'Balatas',
      'manoDeObra': 450,
      'refacciones': 1200.5,
      'total': 1650.5,
      'estado': 'APROBADO',
      'respondidoEn': '2026-11-24T11:05:00',
    },
  ],
  'totalOrden': 0,
  'totalAdicionalesAprobados': 1650.5,
  'totalAdicionalesPendientes': 0,
  'totalEstimado': 1650.5,
};

http.Response _json(int status, Object cuerpo) => http.Response(
  jsonEncode(cuerpo),
  status,
  headers: {'content-type': 'application/json; charset=utf-8'},
);

http.Response _problema(String codigo) => _json(409, {
  'timestamp': 't',
  'status': 409,
  'error': 'Conflict',
  'message': 'x',
  'codigo': codigo,
  'path': '/ordenes/41/adicionales/11/respuesta',
});

RepositorioTallerApi _repo(http.Response Function(http.Request) f) =>
    RepositorioTallerApi(
      ClienteApi(
        config: ApiConfig.para('http://local/api/v1/app'),
        http: MockClient((req) async => f(req)),
      ),
    );

void main() {
  group('RepositorioTallerApi', () {
    test('pide las ordenes en curso', () async {
      http.Request? pedida;
      final repo = _repo((req) {
        pedida = req;
        return _json(200, [
          {
            'id': 41,
            'vehiculoId': 5,
            'vehiculo': 'Nissan March 2026',
            'etapa': 'EN_REPARACION',
            'estatus': 'EN_PROCESO',
            'entregaEstimada': '2026-11-24T18:00:00',
            'asesor': 'Laura Méndez',
            'avance': 43,
            'adicionalesPendientes': 1,
          },
        ]);
      });

      final ordenes = await repo.enCurso();

      expect(pedida?.method, 'GET');
      expect(pedida?.url.path, '/api/v1/app/ordenes/activas');
      expect(ordenes.single.etapa, EtapaTaller.enReparacion);
      expect(ordenes.single.adicionalesPendientes, 1);
    });

    test('pide la orden por su id', () async {
      http.Request? pedida;
      final repo = _repo((req) {
        pedida = req;
        return _json(200, _orden);
      });

      final orden = await repo.orden(41);

      expect(pedida?.url.path, '/api/v1/app/ordenes/41');
      expect(orden.asesor, 'Laura Méndez');
    });

    test(
      'responde con la firma en Base64 y lee la orden recalculada',
      () async {
        http.Request? pedida;
        final repo = _repo((req) {
          pedida = req;
          return _json(200, _orden);
        });

        final orden = await repo.responder(
          ordenId: 41,
          adicionalId: 11,
          aprobado: true,
          firmaPng: _firma,
        );

        expect(pedida?.method, 'POST');
        expect(
          pedida?.url.path,
          '/api/v1/app/ordenes/41/adicionales/11/respuesta',
        );
        expect(jsonDecode(pedida!.body), {
          'aprobado': true,
          'firma': base64Encode(_firma),
        });
        expect(orden.adicionales.single.estado, EstadoAdicional.aprobado);
        expect(orden.totalEstimado, 1650.5);
      },
    );

    test('traduce los 409 del contrato', () async {
      Future<OrdenEnVivo> responder(String codigo) =>
          _repo((_) => _problema(codigo)).responder(
            ordenId: 41,
            adicionalId: 11,
            aprobado: false,
            firmaPng: _firma,
          );

      await expectLater(
        responder('ADICIONAL_YA_RESPONDIDO'),
        throwsA(isA<AdicionalYaRespondido>()),
      );
      await expectLater(
        responder('ORDEN_CERRADA'),
        throwsA(isA<OrdenCerrada>()),
      );
      await expectLater(responder('OTRO'), throwsA(isA<Conflicto>()));
    });

    test('lista para entrega trae el total y el horario (V2-M04.06)', () async {
      final repo = _repo(
        (_) => _json(200, [
          {
            'id': 41,
            'vehiculoId': 5,
            'vehiculo': 'Nissan March 2026',
            'etapa': 'LISTO_PARA_ENTREGA',
            'estatus': 'TERMINADO',
            'entregaEstimada': null,
            'asesor': null,
            'avance': 86,
            'adicionalesPendientes': 0,
            'totalEstimado': 2932.5,
            'horarioEntrega': {
              'fecha': '2026-11-25',
              'desde': '09:00',
              'hasta': '17:00',
            },
          },
        ]),
      );

      final orden = (await repo.enCurso()).single;

      expect(orden.lista, isTrue);
      expect(orden.totalEstimado, 2932.5);
      expect(orden.horarioEntrega?.fecha, DateTime(2026, 11, 25));
      expect(orden.horarioEntrega?.desde, '09:00');
      expect(orden.horarioEntrega?.hasta, '17:00');
    });

    test('sin total ni horario, la orden en curso los deja nulos', () async {
      final repo = _repo(
        (_) => _json(200, [
          {
            'id': 41,
            'vehiculoId': 5,
            'vehiculo': 'Nissan March 2026',
            'etapa': 'EN_REPARACION',
            'estatus': 'EN_PROCESO',
            'avance': 43,
            'adicionalesPendientes': 0,
          },
        ]),
      );

      final orden = (await repo.enCurso()).single;

      expect(orden.lista, isFalse);
      expect(orden.totalEstimado, isNull);
      expect(orden.horarioEntrega, isNull);
    });

    test('la orden lista trae su horario y la entregada no', () async {
      final lista = await _repo(
        (_) => _json(200, {
          ..._orden,
          'etapa': 'LISTO_PARA_ENTREGA',
          'horarioEntrega': {
            'fecha': '2026-11-25',
            'desde': '09:00',
            'hasta': '17:00',
          },
        }),
      ).orden(41);
      final entregada = await _repo(
        (_) => _json(200, {
          ..._orden,
          'etapa': 'ENTREGADO',
          'horarioEntrega': null,
        }),
      ).orden(41);

      expect(lista.lista, isTrue);
      expect(lista.horarioEntrega?.hasta, '17:00');
      expect(entregada.entregada, isTrue);
      expect(entregada.horarioEntrega, isNull);
    });

    test('una orden ajena es NoEncontrado', () async {
      final repo = _repo(
        (_) => _json(404, {
          'timestamp': 't',
          'status': 404,
          'error': 'Not Found',
          'message': 'No existe la orden 41',
          'path': '/ordenes/41',
        }),
      );

      await expectLater(repo.orden(41), throwsA(isA<NoEncontrado>()));
    });
  });

  group('RepositorioTallerFake', () {
    test(
      'aprobar suma el trabajo al total estimado y no se responde dos veces',
      () async {
        final repo = RepositorioTallerFake();

        final orden = await repo.responder(
          ordenId: 41,
          adicionalId: 11,
          aprobado: true,
          firmaPng: _firma,
        );

        expect(orden.totalAdicionalesAprobados, 1650.5);
        expect(orden.totalEstimado, 1282 + 1650.5);
        expect(orden.totalAdicionalesPendientes, 200);
        expect((await repo.enCurso()).single.adicionalesPendientes, 1);
        await expectLater(
          repo.responder(
            ordenId: 41,
            adicionalId: 11,
            aprobado: false,
            firmaPng: _firma,
          ),
          throwsA(isA<AdicionalYaRespondido>()),
        );
      },
    );

    test('la orden lista trae su total y su horario en curso', () async {
      final repo = RepositorioTallerFake();

      repo.actualizar(ordenDeEjemplo(etapa: EtapaTaller.listoParaEntrega));

      final enCurso = (await repo.enCurso()).single;
      expect(enCurso.lista, isTrue);
      expect(enCurso.totalEstimado, 1282);
      expect(enCurso.horarioEntrega?.desde, '09:00');
    });

    test('una orden entregada ya no esta en curso', () async {
      final repo = RepositorioTallerFake(
        ordenes: [ordenDeEjemplo(etapa: EtapaTaller.entregado)],
      );

      expect(await repo.enCurso(), isEmpty);
    });
  });
}
