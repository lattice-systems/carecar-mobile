import 'dart:convert';

import 'package:carecar_mobile/api/api_config.dart';
import 'package:carecar_mobile/api/cliente_api.dart';
import 'package:carecar_mobile/api/excepciones.dart';
import 'package:carecar_mobile/modulos/garantia/datos/repositorio_garantia_api.dart';
import 'package:carecar_mobile/modulos/garantia/datos/repositorio_garantia_fake.dart';
import 'package:carecar_mobile/modulos/garantia/dominio/campana_seguridad.dart';
import 'package:carecar_mobile/modulos/garantia/dominio/garantia_vehiculo.dart';
import 'package:carecar_mobile/modulos/garantia/dominio/repositorio_garantia.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'ayudas_garantia.dart';

const _garantia = {
  'vehiculoId': 5,
  'kmActual': 59200,
  'coberturas': [
    {
      'id': 2,
      'componente': 'Motor y transmisión',
      'descripcion': null,
      'iniciaEn': '2024-01-15',
      'venceEn': '2027-01-15',
      'kmLimite': 60000,
      'diasRestantes': 53,
      'kmRestantes': 800,
      'consumo': 98,
      'estado': 'POR_VENCER',
      'limite': 'km',
    },
    {
      'id': 3,
      'componente': 'Corrosión',
      'iniciaEn': '2024-01-15',
      'venceEn': '2030-01-15',
      'kmLimite': null,
      'diasRestantes': 1149,
      'kmRestantes': null,
      'consumo': 32,
      'estado': 'VIGENTE',
      'limite': 'fecha',
    },
  ],
};

const _campana = {
  'id': 7,
  'codigo': 'RC-24-017',
  'titulo': 'Bolsa de aire del conductor',
  'descripcion': 'El inflador puede activarse con fuerza de más.',
  'queHacer': 'Agenda una revisión; el cambio no tiene costo.',
  'gravedad': 'CRITICA',
  'estado': 'ABIERTA',
  'citaId': null,
  'publicadaEn': '2026-11-20T15:00:00Z',
};

const _cita = {
  'id': 31,
  'vehiculoId': 5,
  'franjaId': 3,
  'fecha': '2026-11-26',
  'horaInicio': '15:00',
  'horaFin': '16:00',
  'estado': 'PROGRAMADA',
  'motivo': 'campana',
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
  'path': '/vehiculos/5/campanas/7/cita',
});

RepositorioGarantiaApi _repo(http.Response Function(http.Request) f) =>
    RepositorioGarantiaApi(
      ClienteApi(
        config: ApiConfig.para('http://local/api/v1/app'),
        http: MockClient((req) async => f(req)),
      ),
    );

Future<CitaDeCampana> _agendar(RepositorioGarantia repo) => repo.agendarCampana(
  vehiculoId: 5,
  campanaId: 7,
  franjaId: 3,
  fecha: DateTime(2026, 11, 26),
);

void main() {
  group('RepositorioGarantiaApi', () {
    test('pide la garantia del vehiculo y lee sus coberturas', () async {
      http.Request? pedida;
      final garantia = await _repo((req) {
        pedida = req;
        return _json(200, _garantia);
      }).garantia(5);

      expect(pedida!.method, 'GET');
      expect(pedida!.url.path, '/api/v1/app/vehiculos/5/garantia');
      expect(garantia.vehiculoId, 5);
      expect(garantia.kmActual, 59200);
      expect(garantia.coberturas, hasLength(2));
      final motor = garantia.coberturas.first;
      expect(motor.componente, 'Motor y transmisión');
      expect(motor.descripcion, isNull);
      expect(motor.venceEn, DateTime(2027, 1, 15));
      expect(motor.kmLimite, 60000);
      expect(motor.kmRestantes, 800);
      expect(motor.consumo, 98);
      expect(motor.estado, EstadoCobertura.porVencer);
      expect(motor.limite, LimiteCobertura.km);
      final corrosion = garantia.coberturas.last;
      expect(corrosion.kmLimite, isNull);
      expect(corrosion.estado, EstadoCobertura.vigente);
      expect(corrosion.limite, LimiteCobertura.fecha);
    });

    test('sin km del auto y sin coberturas tambien se lee', () async {
      final garantia = await _repo(
        (_) =>
            _json(200, {'vehiculoId': 5, 'kmActual': null, 'coberturas': []}),
      ).garantia(5);
      expect(garantia.kmActual, isNull);
      expect(garantia.coberturas, isEmpty);
    });

    test('un estado o un limite desconocidos no rompen la lectura', () async {
      final garantia = await _repo(
        (_) => _json(200, {
          'vehiculoId': 5,
          'coberturas': [
            {
              ...(_garantia['coberturas']! as List).first as Map,
              'estado': 'SUSPENDIDA',
              'limite': 'horas',
              'consumo': 130,
            },
          ],
        }),
      ).garantia(5);
      final cobertura = garantia.coberturas.single;
      expect(cobertura.estado, EstadoCobertura.vigente);
      expect(cobertura.limite, LimiteCobertura.fecha);
      expect(cobertura.consumo, 100);
    });

    test('pide las campanas del vehiculo', () async {
      http.Request? pedida;
      final campanas = await _repo((req) {
        pedida = req;
        return _json(200, [
          _campana,
          {..._campana, 'id': 4, 'estado': 'ATENDIDA', 'citaId': 12},
        ]);
      }).campanas(5);

      expect(pedida!.url.path, '/api/v1/app/vehiculos/5/campanas');
      expect(campanas, hasLength(2));
      final critica = campanas.first;
      expect(critica.codigo, 'RC-24-017');
      expect(critica.gravedad, GravedadCampana.critica);
      expect(critica.estado, EstadoCampana.abierta);
      expect(critica.abierta, isTrue);
      expect(critica.citaId, isNull);
      expect(critica.publicadaEn, DateTime.utc(2026, 11, 20, 15));
      expect(campanas.last.estado, EstadoCampana.atendida);
      expect(campanas.last.citaId, 12);
    });

    test('una gravedad desconocida se trata como alta', () async {
      final campanas = await _repo(
        (_) => _json(200, [
          {..._campana, 'gravedad': 'EXTREMA'},
        ]),
      ).campanas(5);
      expect(campanas.single.gravedad, GravedadCampana.alta);
    });

    test('agendar manda la franja y el dia y lee la cita', () async {
      http.Request? pedida;
      final cita = await _agendar(
        _repo((req) {
          pedida = req;
          return _json(201, _cita);
        }),
      );

      expect(pedida!.method, 'POST');
      expect(pedida!.url.path, '/api/v1/app/vehiculos/5/campanas/7/cita');
      expect(jsonDecode(pedida!.body), {'franjaId': 3, 'fecha': '2026-11-26'});
      expect(cita.id, 31);
      expect(cita.fecha, DateTime(2026, 11, 26));
      expect(cita.horaInicio, '15:00');
      expect(cita.horaFin, '16:00');
    });

    for (final (codigo, motivo) in [
      ('CAMPANA_NO_AGENDABLE', MotivoRechazoCampana.yaAgendada),
      ('FRANJA_SIN_CUPO', MotivoRechazoCampana.sinCupo),
      ('CITA_DUPLICADA', MotivoRechazoCampana.citaDuplicada),
    ]) {
      test('un 409 $codigo se explica como $motivo', () async {
        await expectLater(
          _agendar(_repo((_) => _conflicto(codigo))),
          throwsA(
            isA<AgendaCampanaRechazada>().having(
              (e) => e.motivo,
              'motivo',
              motivo,
            ),
          ),
        );
      });
    }

    test('otro 409 pasa tal cual', () async {
      await expectLater(
        _agendar(_repo((_) => _conflicto('ORDEN_CERRADA'))),
        throwsA(isA<Conflicto>()),
      );
    });
  });

  group('RepositorioGarantiaFake', () {
    test('agendar deja la campana agendada con su cita', () async {
      final repo = RepositorioGarantiaFake(campanas: campanasDeEjemplo());
      final cita = await _agendar(repo);

      expect(repo.agendadas.single, (5, 7, 3, DateTime(2026, 11, 26)));
      final campana = (await repo.campanas(5)).firstWhere((c) => c.id == 7);
      expect(campana.estado, EstadoCampana.agendada);
      expect(campana.citaId, cita.id);
    });

    test('una campana ya agendada no se vuelve a agendar', () async {
      final repo = RepositorioGarantiaFake(campanas: campanasDeEjemplo());
      await _agendar(repo);
      await expectLater(
        _agendar(repo),
        throwsA(
          isA<AgendaCampanaRechazada>().having(
            (e) => e.motivo,
            'motivo',
            MotivoRechazoCampana.yaAgendada,
          ),
        ),
      );
    });
  });
}
