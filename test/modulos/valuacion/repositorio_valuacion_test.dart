import 'dart:convert';

import 'package:carecar_mobile/api/api_config.dart';
import 'package:carecar_mobile/api/cliente_api.dart';
import 'package:carecar_mobile/api/excepciones.dart';
import 'package:carecar_mobile/modulos/valuacion/datos/repositorio_valuacion_api.dart';
import 'package:carecar_mobile/modulos/valuacion/datos/repositorio_valuacion_fake.dart';
import 'package:carecar_mobile/modulos/valuacion/valuacion.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'ayudas_valuacion.dart';

const _valuacion = {
  'id': 4,
  'estado': 'OFERTADA',
  'creadaEn': '2026-11-20T15:00:00Z',
  'vehiculoId': 5,
  'estimacion': {
    'id': 9,
    'creadaEn': '2026-11-19T15:00:00Z',
    'marca': 'Nissan',
    'modelo': 'March',
    'anio': 2020,
    'km': 48000,
    'minimo': 100000,
    'maximo': 120000,
  },
  'fotos': [
    {
      'toma': 'TABLERO_KM',
      'url': '/api/v1/archivos/valuacion-fotos/2?firma=b',
      'subidaEn': '2026-11-21T15:00:00Z',
    },
    {
      'toma': 'FRENTE',
      'url': '/api/v1/archivos/valuacion-fotos/1?firma=a',
      'subidaEn': '2026-11-21T14:00:00Z',
    },
    {'toma': 'TOMA_NUEVA', 'url': '/x', 'subidaEn': '2026-11-21T14:00:00Z'},
  ],
  'puedeAgendar': false,
  'cita': {
    'citaId': 31,
    'fecha': '2026-11-27',
    'horaInicio': '09:00',
    'horaFin': '10:00',
  },
  'oferta': {
    'monto': 112500,
    'vigenciaHasta': '2026-12-04',
    'nota': null,
    'ofertadaEn': '2026-11-27T18:00:00Z',
  },
  'respondidaEn': null,
  'asesor': 'Vera Vendedora',
};

http.Response _json(int status, Object cuerpo) => http.Response(
  jsonEncode(cuerpo),
  status,
  headers: {'content-type': 'application/json; charset=utf-8'},
);

http.Response _problema(int status, String codigo) => _json(status, {
  'timestamp': 't',
  'status': status,
  'error': 'x',
  'message': 'x',
  'codigo': codigo,
  'path': '/valuaciones',
});

final _pedidas = <http.Request>[];

RepositorioValuacionApi _repo(http.Response Function(http.Request) f) {
  _pedidas.clear();
  return RepositorioValuacionApi(
    ClienteApi(
      config: ApiConfig.para('http://local/api/v1/app'),
      http: MockClient((req) async {
        _pedidas.add(req);
        return f(req);
      }),
    ),
  );
}

Matcher _rechazo(MotivoRechazoValuacion motivo) => throwsA(
  isA<ValuacionRechazada>().having((e) => e.motivo, 'motivo', motivo),
);

void main() {
  test('pedir manda la estimacion y lee la valuacion completa', () async {
    final v = await _repo((_) => _json(201, _valuacion)).pedir(9);

    expect(_pedidas.single.url.path, '/api/v1/app/valuaciones');
    expect(jsonDecode(_pedidas.single.body), {'estimacionTomaCuentaId': 9});
    expect(v.id, 4);
    expect(v.estado, EstadoValuacion.ofertada);
    expect(v.vehiculoId, 5);
    expect(v.estimacion.auto, 'Nissan March 2020');
    expect(v.puedeAgendar, isFalse);
    expect(v.cita!.citaId, 31);
    expect(v.cita!.fecha, DateTime(2026, 11, 27));
    expect(v.oferta!.monto, 112500);
    expect(v.oferta!.vigenciaHasta, DateTime(2026, 12, 4));
    expect(v.oferta!.nota, isNull);
    expect(v.asesor, 'Vera Vendedora');
    // En el orden de las tomas y sin la que la app no conoce.
    expect(v.fotos.map((f) => f.toma), [
      TomaValuacion.frente,
      TomaValuacion.tableroKm,
    ]);
  });

  test('un estado que no conoce no ofrece fotos ni respuesta', () async {
    final v = await _repo(
      (_) => _json(200, {..._valuacion, 'estado': 'EN_REVISION'}),
    ).una(4);

    expect(v.estado, EstadoValuacion.desconocido);
    expect(v.estado.admiteFotos, isFalse);
    expect(v.ofertaPorResponder, isFalse);
  });

  test('listar pide la pagina y dice si hay mas', () async {
    final pagina = await _repo(
      (_) => _json(200, {
        'contenido': [_valuacion],
        'pagina': 0,
        'tamano': 1,
        'totalElementos': 2,
        'totalPaginas': 2,
      }),
    ).listar(tamano: 1);

    expect(_pedidas.single.url.queryParameters, {'pagina': '0', 'tamano': '1'});
    expect(pagina.valuaciones.single.id, 4);
    expect(pagina.hayMas, isTrue);
  });

  test('subir una foto va en multipart con el campo imagen', () async {
    await _repo((_) => _json(200, _valuacion)).subirFoto(
      valuacionId: 4,
      toma: TomaValuacion.lateralIzquierdo,
      bytes: pixel,
      tipo: 'image/jpeg',
    );

    final peticion = _pedidas.single;
    expect(
      peticion.url.path,
      '/api/v1/app/valuaciones/4/fotos/LATERAL_IZQUIERDO',
    );
    final cuerpo = latin1.decode(peticion.bodyBytes);
    expect(cuerpo, contains('name="imagen"'));
    expect(cuerpo.toLowerCase(), contains('content-type: image/jpeg'));
    // Un solo campo: el archivo, sin campos de texto.
    expect(RegExp('; name="').allMatches(cuerpo), hasLength(1));
  });

  test('agendar manda franja y dia y lee la cita', () async {
    final cita = await _repo(
      (_) => _json(201, {
        'id': 31,
        'vehiculoId': 5,
        'franjaId': 3,
        'fecha': '2026-11-27',
        'horaInicio': '09:00',
        'horaFin': '10:00',
        'estado': 'CONFIRMADA',
        'motivo': 'valuacion',
      }),
    ).agendar(valuacionId: 4, franjaId: 3, fecha: DateTime(2026, 11, 27));

    expect(_pedidas.single.url.path, '/api/v1/app/valuaciones/4/cita');
    expect(jsonDecode(_pedidas.single.body), {
      'franjaId': 3,
      'fecha': '2026-11-27',
    });
    expect(cita.citaId, 31);
    expect(cita.horaInicio, '09:00');
  });

  test('responder manda la decision y el monto que se vio', () async {
    await _repo((_) => _json(200, {..._valuacion, 'estado': 'ACEPTADA'}))
        .responder(valuacionId: 4, aceptada: true, monto: 112500);

    expect(_pedidas.single.url.path, '/api/v1/app/valuaciones/4/respuesta');
    expect(jsonDecode(_pedidas.single.body), {
      'aceptada': true,
      'monto': 112500,
    });
  });

  test('el valor estimado lee un punto por mes', () async {
    final puntos = await _repo(
      (_) => _json(200, {
        'vehiculoId': 5,
        'puntos': [
          {
            'mes': '2026-09',
            'estimacionTomaCuentaId': 2,
            'creadaEn': '2026-09-10T15:00:00Z',
            'minimo': 100000,
            'maximo': 120000,
            'medio': 110000.5,
            'km': 45000,
            'estado': 'BUENO',
          },
        ],
      }),
    ).valorEstimado(5);

    expect(_pedidas.single.url.path, '/api/v1/app/vehiculos/5/valor-estimado');
    expect(_pedidas.single.url.queryParameters, {'meses': '12'});
    expect(puntos.single.mes, DateTime(2026, 9));
    expect(puntos.single.medio, 110000.5);
  });

  test('cada codigo del contrato se vuelve su rechazo', () async {
    const casos = {
      (422, 'VALUACION_SIN_VEHICULO'): MotivoRechazoValuacion.sinVehiculo,
      (409, 'VALUACION_CERRADA'): MotivoRechazoValuacion.cerrada,
      (409, 'VALUACION_NO_AGENDABLE'): MotivoRechazoValuacion.noAgendable,
      (409, 'FRANJA_SIN_CUPO'): MotivoRechazoValuacion.sinCupo,
      (409, 'CITA_DUPLICADA'): MotivoRechazoValuacion.citaDuplicada,
      (409, 'OFERTA_VENCIDA'): MotivoRechazoValuacion.ofertaVencida,
      (409, 'OFERTA_NO_DISPONIBLE'): MotivoRechazoValuacion.ofertaNoDisponible,
    };
    for (final MapEntry(key: (status, codigo), value: motivo)
        in casos.entries) {
      final repo = _repo((_) => _problema(status, codigo));
      await expectLater(repo.pedir(9), _rechazo(motivo), reason: codigo);
    }
  });

  test('un conflicto sin codigo conocido pasa tal cual', () async {
    final repo = _repo((_) => _problema(409, 'OTRO'));
    await expectLater(repo.pedir(9), throwsA(isA<Conflicto>()));
  });

  test('una estimacion ajena es un no encontrado', () async {
    final repo = _repo((_) => _problema(404, 'OTRO'));
    await expectLater(repo.pedir(9), throwsA(isA<NoEncontrado>()));
  });

  test('un cuerpo sin puedeAgendar es una respuesta invalida', () async {
    final repo = _repo(
      (_) => _json(200, {..._valuacion}..remove('puedeAgendar')),
    );
    await expectLater(repo.una(4), throwsA(isA<RespuestaInvalida>()));
  });

  group('el falso', () {
    test('pedir otra vez devuelve la abierta sin crear otra', () async {
      final repo = RepositorioValuacionFake();
      final primera = await repo.pedir(7);
      final segunda = await repo.pedir(7);
      expect(segunda.id, primera.id);
      expect(repo.valuaciones, hasLength(1));
    });

    test('falla a pedido', () async {
      final repo = RepositorioValuacionFake(falla: const SinConexion());
      await expectLater(repo.listar(), throwsA(isA<SinConexion>()));
    });

    test('responder con otro monto no registra nada', () async {
      final repo = RepositorioValuacionFake(valuaciones: [ofertada()]);
      await expectLater(
        repo.responder(valuacionId: 1, aceptada: true, monto: 1),
        _rechazo(MotivoRechazoValuacion.ofertaNoDisponible),
      );
      expect(repo.respuestas, isEmpty);
    });

    test('subir una foto a una cerrada se rechaza', () async {
      final repo = RepositorioValuacionFake(valuaciones: [ofertada()]);
      await expectLater(
        repo.subirFoto(
          valuacionId: 1,
          toma: TomaValuacion.frente,
          bytes: pixel,
          tipo: 'image/jpeg',
        ),
        _rechazo(MotivoRechazoValuacion.cerrada),
      );
    });
  });

  test('sumar fotos de dos respuestas no pierde ninguna', () {
    final a = valuacion(fotos: [foto(TomaValuacion.trasera)]);
    final b = valuacion(fotos: [foto(TomaValuacion.frente)]);
    expect(a.conFotosDe(b).fotos.map((f) => f.toma), [
      TomaValuacion.frente,
      TomaValuacion.trasera,
    ]);
  });
}
