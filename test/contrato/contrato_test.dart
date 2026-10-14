// Tarea 4 de TEC-5 · Validar que las respuestas respetan el contrato.
//
// Lee api/agencia360-api-app-v1.yaml y lo compara contra lo que la app cree que
// dice. Si Ricardo cambia el contrato (agrega un campo, cambia uno a
// obligatorio, agrega un endpoint o toca el enum de estados), estas pruebas se
// ponen rojas y el CI avisa. Es la alarma que pedia RIC-22.
//
// El ultimo grupo, ademas, valida las respuestas reales de la API simulada
// cuando esta levantada. En CI no lo esta y esas pruebas se omiten solas.

import 'dart:convert';
import 'dart:io';

import 'package:carecar_mobile/api/api_config.dart';
import 'package:carecar_mobile/api/carecar_api_http.dart';
import 'package:carecar_mobile/api/cliente_api.dart';
import 'package:carecar_mobile/api/modelos/modelos.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:yaml/yaml.dart';

const _rutaContrato = 'api/agencia360-api-app-v1.yaml';

/// Lo que la app cree que dice el contrato. Si el YAML se mueve, esto deja de
/// coincidir y la prueba falla: ese es el punto.
const _propiedadesQueLaAppConoce = <String, Set<String>>{
  'LoginRequest': {'usuario', 'contrasena'},
  'LoginResponse': {'accessToken', 'debeCambiarContrasena'},
  'CambiarContrasenaRequest': {'contrasenaActual', 'contrasenaNueva'},
  'Vehiculo': {'id', 'vin', 'modelo', 'anio', 'placas', 'kilometraje'},
  'Manual': {'id', 'modelo', 'anio', 'url'},
  'Servicio': {'id', 'fecha', 'estatus', 'total'},
  'Disponibilidad': {
    'fecha',
    'franjaId',
    'horaInicio',
    'horaFin',
    'cupoDisponible',
  },
  'NuevaCita': {'vehiculoId', 'franjaId', 'fecha'},
  'Cita': {'id', 'vehiculoId', 'fecha', 'horaInicio', 'horaFin', 'estado'},
  'ModeloCatalogo': {'id', 'modelo'},
  'Problema': {'timestamp', 'status', 'error', 'message', 'path'},
};

/// Campos que la app trata como obligatorios (no nulos) en cada modelo.
const _obligatoriosQueLaAppConoce = <String, Set<String>>{
  'LoginRequest': {'usuario', 'contrasena'},
  'LoginResponse': {'accessToken', 'debeCambiarContrasena'},
  'CambiarContrasenaRequest': {'contrasenaActual', 'contrasenaNueva'},
  'Vehiculo': {'id', 'vin', 'modelo', 'anio'},
  'Manual': {'id', 'modelo', 'anio', 'url'},
  'Servicio': {'id', 'fecha', 'estatus', 'total'},
  'Disponibilidad': {
    'fecha',
    'franjaId',
    'horaInicio',
    'horaFin',
    'cupoDisponible',
  },
  'NuevaCita': {'vehiculoId', 'franjaId', 'fecha'},
  'Cita': {'id', 'vehiculoId', 'fecha', 'horaInicio', 'horaFin', 'estado'},
  'ModeloCatalogo': {'id', 'modelo'},
  'Problema': {'timestamp', 'status', 'error', 'message', 'path'},
};

/// Las 13 operaciones que la app implementa, como `METODO ruta`.
const _operacionesQueLaAppImplementa = <String>{
  'POST /auth/login',
  'POST /auth/cambiar-contrasena',
  'POST /auth/recuperar-contrasena',
  'POST /auth/restablecer-contrasena',
  'GET /vehiculos',
  'GET /vehiculos/{vehiculoId}/manuales',
  'GET /vehiculos/{vehiculoId}/servicios',
  'GET /servicios/{servicioId}/ticket',
  'GET /agenda/disponibilidad',
  'GET /citas',
  'POST /citas',
  'POST /citas/{citaId}/cancelar',
  'GET /catalogo',
};

void main() {
  late YamlMap contrato;

  setUpAll(() {
    final archivo = File(_rutaContrato);
    if (!archivo.existsSync()) {
      fail(
        'No se encontro $_rutaContrato. Las pruebas corren desde la raiz del paquete.',
      );
    }
    contrato = loadYaml(archivo.readAsStringSync()) as YamlMap;
  });

  group('el contrato sigue siendo el que la app espera', () {
    test('la base de las rutas no cambio', () {
      final servidores = contrato['servers'] as YamlList;
      expect(
        servidores.first['url'],
        '/api/v1/app',
        reason: 'Si la base cambia, hay que actualizar API_URL en todas partes',
      );
    });

    test('los esquemas del contrato son los que la app conoce', () {
      final enElContrato = (contrato['components']['schemas'] as YamlMap).keys
          .cast<String>();
      expect(
        enElContrato.toSet(),
        _propiedadesQueLaAppConoce.keys.toSet(),
        reason: 'Aparecio o desaparecio un esquema en el contrato',
      );
    });

    test(
      'cada esquema tiene exactamente las propiedades que la app conoce',
      () {
        final esquemas = contrato['components']['schemas'] as YamlMap;

        for (final entrada in _propiedadesQueLaAppConoce.entries) {
          final propiedades = (esquemas[entrada.key]['properties'] as YamlMap)
              .keys
              .cast<String>();
          expect(
            propiedades.toSet(),
            entrada.value,
            reason: 'Cambiaron las propiedades de ${entrada.key}',
          );
        }
      },
    );

    test('cada esquema marca como obligatorio lo mismo que la app', () {
      final esquemas = contrato['components']['schemas'] as YamlMap;

      for (final entrada in _obligatoriosQueLaAppConoce.entries) {
        final requeridos =
            (esquemas[entrada.key]['required'] as YamlList?)?.cast<String>() ??
            [];
        expect(
          requeridos.toSet(),
          entrada.value,
          reason: 'Cambiaron los campos obligatorios de ${entrada.key}',
        );
      }
    });

    test('el enum de Cita.estado coincide con EstadoCita', () {
      final esquemas = contrato['components']['schemas'] as YamlMap;
      final enElContrato =
          (esquemas['Cita']['properties']['estado']['enum'] as YamlList)
              .cast<String>()
              .toSet();

      final queLaAppMapea = EstadoCita.values
          .where((e) => e != EstadoCita.desconocido)
          .map((e) => e.enElContrato)
          .toSet();

      expect(
        enElContrato,
        queLaAppMapea,
        reason: 'Cambiaron los estados de cita; revisa EstadoCita',
      );
    });

    test('las operaciones del contrato son las que la app implementa', () {
      final rutas = contrato['paths'] as YamlMap;
      final enElContrato = <String>{};

      rutas.forEach((ruta, operaciones) {
        (operaciones as YamlMap).forEach((metodo, _) {
          enElContrato.add('${(metodo as String).toUpperCase()} $ruta');
        });
      });

      expect(
        enElContrato,
        _operacionesQueLaAppImplementa,
        reason: 'Aparecio o desaparecio una operacion en el contrato',
      );
    });

    test(
      'las rutas publicas del contrato son las tres que la app no autentica',
      () {
        final rutas = contrato['paths'] as YamlMap;
        final publicas = <String>{};

        rutas.forEach((ruta, operaciones) {
          (operaciones as YamlMap).forEach((metodo, op) {
            final seguridad = (op as YamlMap)['security'];
            if (seguridad is YamlList && seguridad.isEmpty) {
              publicas.add(ruta as String);
            }
          });
        });

        expect(publicas, {
          '/auth/login',
          '/auth/recuperar-contrasena',
          '/auth/restablecer-contrasena',
        }, reason: 'Cambio que rutas van sin token');
      },
    );
  });

  group('los modelos parsean ejemplos armados desde el contrato', () {
    test(
      'todos los campos obligatorios de Vehiculo bastan para construirlo',
      () {
        final v = Vehiculo.fromJson(const {
          'id': 1,
          'vin': 'X',
          'modelo': 'Versa',
          'anio': 2024,
        });
        expect(v.id, 1);
      },
    );

    test('Cita exige los seis campos del contrato', () {
      final c = Cita.fromJson(const {
        'id': 1,
        'vehiculoId': 1,
        'fecha': '2026-10-21',
        'horaInicio': '09:00',
        'horaFin': '10:00',
        'estado': 'CONFIRMADA',
      });
      expect(c.estado, EstadoCita.confirmada);
    });

    test(
      'Disponibilidad exige cupoDisponible, que el contrato pone en minimo 1',
      () {
        final esquemas = contrato['components']['schemas'] as YamlMap;
        expect(
          esquemas['Disponibilidad']['properties']['cupoDisponible']['minimum'],
          1,
        );

        final d = Disponibilidad.fromJson(const {
          'fecha': '2026-10-20',
          'franjaId': 1,
          'horaInicio': '09:00',
          'horaFin': '10:00',
          'cupoDisponible': 1,
        });
        expect(d.cupoDisponible, 1);
      },
    );
  });

  // Estas pruebas solo corren si la API simulada esta levantada:
  //   cd mock_api && npm start
  // En CI no lo esta, y se omiten sin poner el build en rojo.
  group('las respuestas de la API simulada respetan el contrato', () {
    const base = 'http://localhost:3000/api/v1/app';
    late bool levantada;

    setUpAll(() async {
      try {
        final r = await http
            .post(
              Uri.parse('$base/auth/login'),
              headers: const {'content-type': 'application/json'},
              body: jsonEncode(const {
                'usuario': 'cliente1',
                'contrasena': 'CareCar2026',
              }),
            )
            .timeout(const Duration(seconds: 2));
        levantada = r.statusCode == 200;
      } catch (_) {
        levantada = false;
      }
    });

    Future<CarecarApiHttp> conSesion() async {
      final sinSesion = CarecarApiHttp(
        ClienteApi(config: ApiConfig.para(base), http: http.Client()),
      );
      final sesion = await sinSesion.iniciarSesion(
        const PeticionLogin(usuario: 'cliente1', contrasena: 'CareCar2026'),
      );
      return CarecarApiHttp(
        ClienteApi(
          config: ApiConfig.para(base),
          http: http.Client(),
          obtenerToken: () async => sesion.accessToken,
        ),
      );
    }

    test('el login devuelve una RespuestaLogin valida', () async {
      if (!levantada) {
        return markTestSkipped('La API simulada no esta levantada');
      }
      final api = CarecarApiHttp(
        ClienteApi(config: ApiConfig.para(base), http: http.Client()),
      );
      final sesion = await api.iniciarSesion(
        const PeticionLogin(usuario: 'cliente1', contrasena: 'CareCar2026'),
      );
      expect(
        sesion.accessToken.split('.'),
        hasLength(3),
        reason: 'debe tener forma de JWT',
      );
      expect(sesion.debeCambiarContrasena, isFalse);
    });

    test('los vehiculos se deserializan sin perder campos', () async {
      if (!levantada) {
        return markTestSkipped('La API simulada no esta levantada');
      }
      final api = await conSesion();
      final vehiculos = await api.misVehiculos();
      expect(vehiculos, isNotEmpty);
      expect(vehiculos.every((v) => v.vin.isNotEmpty && v.anio > 1900), isTrue);
    });

    test('el historial viene del mas reciente al mas antiguo', () async {
      if (!levantada) {
        return markTestSkipped('La API simulada no esta levantada');
      }
      final api = await conSesion();
      final servicios = await api.serviciosDe(1);
      final fechas = servicios.map((s) => s.fecha).toList();
      expect(fechas, equals([...fechas]..sort((a, b) => b.compareTo(a))));
    });

    test('la disponibilidad solo trae franjas con cupo', () async {
      if (!levantada) {
        return markTestSkipped('La API simulada no esta levantada');
      }
      final api = await conSesion();
      final franjas = await api.disponibilidad(
        desde: DateTime(2026, 10, 20),
        hasta: DateTime(2026, 10, 22),
      );
      expect(franjas.every((f) => f.cupoDisponible > 0), isTrue);
    });

    test('las citas traen un estado del enum del contrato', () async {
      if (!levantada) {
        return markTestSkipped('La API simulada no esta levantada');
      }
      final api = await conSesion();
      final citas = await api.misCitas();
      expect(
        citas.every((c) => c.estado != EstadoCita.desconocido),
        isTrue,
        reason: 'la simulada devolvio un estado que el contrato no declara',
      );
    });

    test('el ticket es un PDF', () async {
      if (!levantada) {
        return markTestSkipped('La API simulada no esta levantada');
      }
      final api = await conSesion();
      final bytes = await api.ticketDe(1);
      expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
    });
  });
}
