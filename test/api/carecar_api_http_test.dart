import 'dart:convert';

import 'package:carecar_mobile/api/api_config.dart';
import 'package:carecar_mobile/api/carecar_api.dart';
import 'package:carecar_mobile/api/carecar_api_http.dart';
import 'package:carecar_mobile/api/cliente_api.dart';
import 'package:carecar_mobile/api/modelos/modelos.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// Guarda lo que se pidio, para comprobar metodo y ruta sin un servidor real.
class _Espia {
  String? metodo;
  Uri? url;
  String? cuerpo;
}

CarecarApi _api(
  _Espia espia,
  http.Response Function() responder, {
  Future<String?> Function()? token,
}) {
  return CarecarApiHttp(
    ClienteApi(
      config: ApiConfig.para('http://localhost:3000/api/v1/app'),
      http: MockClient((req) async {
        espia
          ..metodo = req.method
          ..url = req.url
          ..cuerpo = req.body;
        return responder();
      }),
      obtenerToken: token,
    ),
  );
}

http.Response _json(Object datos, [int status = 200]) => http.Response(
  jsonEncode(datos),
  status,
  headers: {'content-type': 'application/json'},
);

void main() {
  late _Espia espia;
  setUp(() => espia = _Espia());

  test('iniciarSesion llama POST /auth/login y lee la respuesta', () async {
    final api = _api(
      espia,
      () => _json({
        'accessToken': 'abc.def.ghi',
        'expiresIn': 3600,
        'refreshToken': 'refresco.abc',
        'debeCambiarContrasena': true,
      }),
    );

    final sesion = await api.iniciarSesion(
      const PeticionLogin(
        correo: 'cliente1@example.com',
        contrasena: 'CareCar2026',
      ),
    );

    expect(espia.metodo, 'POST');
    expect(espia.url!.path, '/api/v1/app/auth/login');
    expect(jsonDecode(espia.cuerpo!), {
      'correo': 'cliente1@example.com',
      'contrasena': 'CareCar2026',
    });
    expect(sesion.accessToken, 'abc.def.ghi');
    expect(sesion.expiresIn, 3600);
    expect(sesion.refreshToken, 'refresco.abc');
    expect(sesion.debeCambiarContrasena, isTrue);
  });

  test(
    'cambiarContrasena llama POST /auth/cambiar-contrasena y no espera cuerpo',
    () async {
      final api = _api(espia, () => http.Response('', 204));

      await api.cambiarContrasena(actual: 'CareCar2026', nueva: 'NuevaClave1');

      expect(espia.metodo, 'POST');
      expect(espia.url!.path, '/api/v1/app/auth/cambiar-contrasena');
      expect(jsonDecode(espia.cuerpo!), {
        'contrasenaActual': 'CareCar2026',
        'contrasenaNueva': 'NuevaClave1',
      });
    },
  );

  test('recuperarContrasena llama POST /auth/recuperar-contrasena', () async {
    final api = _api(espia, () => http.Response('', 202));
    await api.recuperarContrasena('cliente1@example.com');
    expect(espia.url!.path, '/api/v1/app/auth/recuperar-contrasena');
    expect(jsonDecode(espia.cuerpo!), {'correo': 'cliente1@example.com'});
  });

  test(
    'restablecerContrasena llama POST /auth/restablecer-contrasena',
    () async {
      final api = _api(espia, () => http.Response('', 204));
      await api.restablecerContrasena(
        const PeticionRestablecer(
          correo: '  Cliente1@Example.com ',
          codigo: ' 123456 ',
          contrasenaNueva: 'NuevaClave1',
        ),
      );
      expect(espia.url!.path, '/api/v1/app/auth/restablecer-contrasena');
      expect(jsonDecode(espia.cuerpo!), {
        // Se recortan los espacios: el usuario suele pegar el codigo del
        // correo con espacios alrededor.
        'correo': 'Cliente1@Example.com',
        'codigo': '123456',
        'contrasenaNueva': 'NuevaClave1',
      });
    },
  );

  test('misVehiculos llama GET /vehiculos y devuelve la lista', () async {
    final api = _api(
      espia,
      () => _json([
        {'id': 1, 'vin': 'A', 'modelo': 'Versa', 'anio': 2024},
        {'id': 2, 'vin': 'B', 'modelo': 'Kicks', 'anio': 2023, 'placas': null},
      ]),
    );

    final vehiculos = await api.misVehiculos();

    expect(espia.metodo, 'GET');
    expect(espia.url!.path, '/api/v1/app/vehiculos');
    expect(vehiculos, hasLength(2));
    expect(vehiculos.first, isA<Vehiculo>());
    expect(vehiculos[1].placas, isNull);
  });

  test('manualesDe llama GET /vehiculos/{id}/manuales', () async {
    final api = _api(espia, () => _json(const []));
    await api.manualesDe(7);
    expect(espia.url!.path, '/api/v1/app/vehiculos/7/manuales');
  });

  test('serviciosDe llama GET /vehiculos/{id}/servicios', () async {
    final api = _api(
      espia,
      () => _json([
        {
          'id': 1,
          'fecha': '2026-09-18',
          'estatus': 'Terminado',
          'total': 4850.5,
        },
      ]),
    );

    final servicios = await api.serviciosDe(1);

    expect(espia.url!.path, '/api/v1/app/vehiculos/1/servicios');
    expect(servicios.single.total, 4850.5);
  });

  test('ticketDe llama GET /servicios/{id}/ticket y devuelve bytes', () async {
    final api = _api(
      espia,
      () => http.Response.bytes(
        [0x25, 0x50, 0x44, 0x46],
        200,
        headers: {'content-type': 'application/pdf'},
      ),
    );

    final bytes = await api.ticketDe(3);

    expect(espia.url!.path, '/api/v1/app/servicios/3/ticket');
    expect(bytes, isNotEmpty);
  });

  test(
    'disponibilidad manda desde y hasta como parametros de consulta',
    () async {
      final api = _api(espia, () => _json(const []));

      await api.disponibilidad(
        desde: DateTime(2026, 10, 20),
        hasta: DateTime(2026, 10, 22),
      );

      expect(espia.url!.path, '/api/v1/app/agenda/disponibilidad');
      expect(espia.url!.queryParameters, {
        'desde': '2026-10-20',
        'hasta': '2026-10-22',
      });
    },
  );

  test('misCitas llama GET /citas', () async {
    final api = _api(
      espia,
      () => _json([
        {
          'id': 1,
          'vehiculoId': 1,
          'fecha': '2026-10-21',
          'horaInicio': '09:00',
          'horaFin': '10:00',
          'estado': 'CONFIRMADA',
        },
      ]),
    );

    final citas = await api.misCitas();

    expect(espia.url!.path, '/api/v1/app/citas');
    expect(citas.single.estado, EstadoCita.confirmada);
  });

  test('agendarCita llama POST /citas con el cuerpo del contrato', () async {
    final api = _api(
      espia,
      () => _json({
        'id': 3,
        'vehiculoId': 1,
        'fecha': '2026-10-22',
        'horaInicio': '09:00',
        'horaFin': '10:00',
        'estado': 'CONFIRMADA',
      }, 201),
    );

    final cita = await api.agendarCita(
      NuevaCita(vehiculoId: 1, franjaId: 6, fecha: DateTime(2026, 10, 22)),
    );

    expect(espia.metodo, 'POST');
    expect(espia.url!.path, '/api/v1/app/citas');
    expect(jsonDecode(espia.cuerpo!), {
      'vehiculoId': 1,
      'franjaId': 6,
      'fecha': '2026-10-22',
    });
    expect(cita.id, 3);
  });

  test('cancelarCita llama POST /citas/{id}/cancelar', () async {
    final api = _api(
      espia,
      () => _json({
        'id': 3,
        'vehiculoId': 1,
        'fecha': '2026-10-22',
        'horaInicio': '09:00',
        'horaFin': '10:00',
        'estado': 'CANCELADA',
      }),
    );

    final cita = await api.cancelarCita(3);

    expect(espia.metodo, 'POST');
    expect(espia.url!.path, '/api/v1/app/citas/3/cancelar');
    expect(cita.estado, EstadoCita.cancelada);
  });

  test('catalogo llama GET /catalogo', () async {
    final api = _api(
      espia,
      () => _json([
        {'id': 1, 'modelo': 'Versa'},
      ]),
    );

    final modelos = await api.catalogo();

    expect(espia.url!.path, '/api/v1/app/catalogo');
    expect(modelos.single.modelo, 'Versa');
  });
}
