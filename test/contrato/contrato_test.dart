// Tarea 4 de TEC-5 · Validar que las respuestas respetan el contrato.
// Recalibrada a la v1.1 en la tarea 1 de TEC-6.
//
// Lee api/agencia360-api-app-v1.yaml y lo compara contra lo que esta prueba
// declara. Si Ricardo cambia el contrato (agrega un campo, cambia uno a
// obligatorio, agrega un endpoint o toca el enum de estados), estas pruebas se
// ponen rojas y el CI avisa. Es la alarma que pedia RIC-22, y ya sirvio: al
// traer la v1.1 se pusieron rojas 6 de 7, nombrando cada cambio.
//
// Importante: estas pruebas comparan el YAML contra las constantes de abajo,
// no contra el codigo de la app. Que esten verdes significa «el contrato es el
// que creemos», no «la app ya implementa todo el contrato». Lo que falta por
// implementar esta en _pendientesDeImplementar, con su prueba.
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

/// La version exacta del contrato que esta copia debe tener.
///
/// El contrato vive en `docs/api/` del repositorio del backend y cambia por PR.
/// Esta copia se fija a una version a proposito (decision D-C): bajarla de la
/// rama principal del backend seria perseguir un blanco movil.
const _versionEsperada = '1.1.0';

/// Los 17 esquemas de la v1.1.
const _esquemasDelContrato = <String>{
  'LoginRequest',
  'LoginResponse',
  'RefreshTokenRequest',
  'CambiarContrasenaRequest',
  'RestablecerContrasenaRequest',
  'Perfil',
  'Vehiculo',
  'Manual',
  'Servicio',
  'PaginaServicios',
  'Disponibilidad',
  'NuevaCita',
  'EstadoCita',
  'Cita',
  'PaginaCitas',
  'ModeloCatalogo',
  'Problema',
};

/// Propiedades de cada esquema de objeto.
///
/// `EstadoCita` no aparece porque es un enum de cadena y no tiene
/// `properties`; se valida aparte, junto con el enum de la app.
const _propiedadesDelContrato = <String, Set<String>>{
  'LoginRequest': {'correo', 'contrasena'},
  'LoginResponse': {
    'accessToken',
    'expiresIn',
    'refreshToken',
    'debeCambiarContrasena',
  },
  'RefreshTokenRequest': {'refreshToken'},
  'CambiarContrasenaRequest': {'contrasenaActual', 'contrasenaNueva'},
  'RestablecerContrasenaRequest': {'correo', 'codigo', 'contrasenaNueva'},
  'Perfil': {'id', 'nombre', 'correo'},
  'Vehiculo': {'id', 'vin', 'modelo', 'anio', 'placas', 'kilometraje'},
  'Manual': {'id', 'modelo', 'anio', 'url'},
  'Servicio': {'id', 'fecha', 'estatus', 'total'},
  'PaginaServicios': {
    'contenido',
    'pagina',
    'tamano',
    'totalElementos',
    'totalPaginas',
  },
  'Disponibilidad': {
    'fecha',
    'franjaId',
    'horaInicio',
    'horaFin',
    'cupoDisponible',
  },
  'NuevaCita': {'vehiculoId', 'franjaId', 'fecha'},
  'Cita': {
    'id',
    'vehiculoId',
    'franjaId',
    'fecha',
    'horaInicio',
    'horaFin',
    'estado',
  },
  'PaginaCitas': {
    'contenido',
    'pagina',
    'tamano',
    'totalElementos',
    'totalPaginas',
  },
  'ModeloCatalogo': {'id', 'modelo'},
  'Problema': {'timestamp', 'status', 'error', 'message', 'codigo', 'path'},
};

/// Campos que el contrato marca como obligatorios en cada esquema.
const _obligatoriosDelContrato = <String, Set<String>>{
  'LoginRequest': {'correo', 'contrasena'},
  'LoginResponse': {
    'accessToken',
    'expiresIn',
    'refreshToken',
    'debeCambiarContrasena',
  },
  'RefreshTokenRequest': {'refreshToken'},
  'CambiarContrasenaRequest': {'contrasenaActual', 'contrasenaNueva'},
  'RestablecerContrasenaRequest': {'correo', 'codigo', 'contrasenaNueva'},
  'Perfil': {'id', 'nombre', 'correo'},
  'Vehiculo': {'id', 'vin', 'modelo', 'anio'},
  'Manual': {'id', 'modelo', 'anio', 'url'},
  'Servicio': {'id', 'fecha', 'estatus', 'total'},
  'PaginaServicios': {
    'contenido',
    'pagina',
    'tamano',
    'totalElementos',
    'totalPaginas',
  },
  'Disponibilidad': {
    'fecha',
    'franjaId',
    'horaInicio',
    'horaFin',
    'cupoDisponible',
  },
  'NuevaCita': {'vehiculoId', 'franjaId', 'fecha'},
  'Cita': {
    'id',
    'vehiculoId',
    'franjaId',
    'fecha',
    'horaInicio',
    'horaFin',
    'estado',
  },
  'PaginaCitas': {
    'contenido',
    'pagina',
    'tamano',
    'totalElementos',
    'totalPaginas',
  },
  'ModeloCatalogo': {'id', 'modelo'},
  // `codigo` es opcional: la app decide por el, pero no puede exigirlo.
  'Problema': {'timestamp', 'status', 'error', 'message', 'path'},
};

/// Las 16 operaciones de la v1.1, como `METODO ruta`.
const _operacionesDelContrato = <String>{
  'POST /auth/login',
  'POST /auth/refrescar',
  'POST /auth/cerrar-sesion',
  'POST /auth/cambiar-contrasena',
  'POST /auth/recuperar-contrasena',
  'POST /auth/restablecer-contrasena',
  'GET /perfil',
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

/// Rutas que el contrato declara sin token.
///
/// `cerrar-sesion` es publica a proposito: debe funcionar aunque el access
/// token ya haya expirado, porque solo necesita el refresh token.
const _rutasPublicas = <String>{
  '/auth/login',
  '/auth/refrescar',
  '/auth/cerrar-sesion',
  '/auth/recuperar-contrasena',
  '/auth/restablecer-contrasena',
};

/// Lo que la v1.1 trae y la app todavia NO implementa.
///
/// Esta lista existe para que la deuda sea visible y no se confunda con que la
/// app ya hable la v1.1 completa. Cada entrada dice en que tarea de TEC-6 o en
/// que sprint entra. Al implementar una, se borra de aqui.
const _pendientesDeImplementar = <String, String>{
  'LoginRequest.correo': 'TEC-6 T2 · hoy la app manda `usuario`',
  'LoginResponse.expiresIn': 'TEC-6 T4',
  'LoginResponse.refreshToken': 'TEC-6 T4',
  'POST /auth/refrescar': 'TEC-6 T4',
  'POST /auth/cerrar-sesion': 'TEC-6 T4',
  'RestablecerContrasenaRequest.codigo': 'APP-2.3 · hoy la firma pide un token',
  'Problema.codigo': 'TEC-6 T5',
  '429 DEMASIADOS_INTENTOS': 'TEC-6 T5',
  'GET /perfil': 'Sprint 3',
  'Cita.franjaId': 'Sprint 4, con APP-3.3',
  'PaginaServicios': 'Sprint 4, con APP-3.2',
  'PaginaCitas': 'Sprint 4, con APP-3.3',
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
    test('la version del contrato es la fijada', () {
      expect(
        contrato['info']['version'],
        _versionEsperada,
        reason:
            'Esta copia se fija a una version. Si cambio, revisa que trae de '
            'nuevo antes de actualizar estas pruebas.',
      );
    });

    test('la base de las rutas no cambio', () {
      final servidores = contrato['servers'] as YamlList;
      expect(
        servidores.first['url'],
        '/api/v1/app',
        reason: 'Si la base cambia, hay que actualizar API_BASE_URL en todas partes',
      );
    });

    test('los esquemas del contrato son los que la prueba declara', () {
      final enElContrato = (contrato['components']['schemas'] as YamlMap).keys
          .cast<String>();
      expect(
        enElContrato.toSet(),
        _esquemasDelContrato,
        reason: 'Aparecio o desaparecio un esquema en el contrato',
      );
    });

    test('cada esquema de objeto tiene exactamente sus propiedades', () {
      final esquemas = contrato['components']['schemas'] as YamlMap;

      for (final entrada in _propiedadesDelContrato.entries) {
        final propiedades = (esquemas[entrada.key]['properties'] as YamlMap)
            .keys
            .cast<String>();
        expect(
          propiedades.toSet(),
          entrada.value,
          reason: 'Cambiaron las propiedades de ${entrada.key}',
        );
      }
    });

    test('cada esquema marca como obligatorio lo que la prueba declara', () {
      final esquemas = contrato['components']['schemas'] as YamlMap;

      for (final entrada in _obligatoriosDelContrato.entries) {
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

    test('el enum EstadoCita coincide con el de la app', () {
      final esquemas = contrato['components']['schemas'] as YamlMap;
      // En la v1.1 `Cita.estado` es un $ref al esquema EstadoCita, ya no un
      // enum escrito en linea.
      expect(
        esquemas['Cita']['properties']['estado'][r'$ref'],
        '#/components/schemas/EstadoCita',
        reason: 'Cita.estado dejo de apuntar a EstadoCita',
      );

      final enElContrato = (esquemas['EstadoCita']['enum'] as YamlList)
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

    test('las operaciones del contrato son las 16 que la prueba declara', () {
      final rutas = contrato['paths'] as YamlMap;
      final enElContrato = <String>{};

      rutas.forEach((ruta, operaciones) {
        (operaciones as YamlMap).forEach((metodo, _) {
          enElContrato.add('${(metodo as String).toUpperCase()} $ruta');
        });
      });

      expect(
        enElContrato,
        _operacionesDelContrato,
        reason: 'Aparecio o desaparecio una operacion en el contrato',
      );
    });

    test('las rutas publicas son las cinco que no llevan token', () {
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

      expect(
        publicas,
        _rutasPublicas,
        reason: 'Cambio que rutas van sin token',
      );
    });

    test('el login puede responder 429 por demasiados intentos', () {
      // RIC-5. La app todavia no lo maneja (TEC-6 T5); esta prueba fija que el
      // contrato lo declara, para que no se pierda.
      final respuestas =
          contrato['paths']['/auth/login']['post']['responses'] as YamlMap;
      // El contrato escribe los codigos entre comillas, asi que son cadenas.
      expect(respuestas.keys, contains('429'));
    });
  });

  group('la deuda con la v1.1 esta declarada', () {
    // No es una prueba de comportamiento: es un recordatorio con dientes. Si
    // alguien implementa una de estas y no la borra de la lista, o borra una
    // sin implementarla, al menos queda escrito en un solo lugar.
    test('cada pendiente dice en que tarea o sprint entra', () {
      expect(_pendientesDeImplementar, isNotEmpty);
      for (final entrada in _pendientesDeImplementar.entries) {
        expect(
          entrada.value,
          isNotEmpty,
          reason: '${entrada.key} no dice cuando se implementa',
        );
      }
    });

    test('lo que ya se implemento se borro de la lista', () {
      // `usuario` todavia es lo que la app manda: cuando T2 lo cambie a
      // `correo`, esta prueba obliga a quitar la entrada de la lista.
      final mandaUsuario = const PeticionLogin(
        correo: 'a@example.com',
        contrasena: 'b',
      ).toJson().containsKey('correo');

      expect(
        _pendientesDeImplementar.containsKey('LoginRequest.correo'),
        mandaUsuario,
        reason: mandaUsuario
            ? 'La app sigue mandando `usuario`: la entrada debe quedarse'
            : 'La app ya manda `correo`: borra LoginRequest.correo de la lista',
      );
    });
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

    test('Cita parsea una respuesta de la v1.1, ignorando franjaId', () {
      // La v1.1 agrega `franjaId` como obligatorio (RIC-10). El modelo todavia
      // no lo lee, y no estorba porque `fromJson` ignora lo que no conoce. Se
      // agrega en el Sprint 4, con APP-3.3, que es quien lo necesita.
      final c = Cita.fromJson(const {
        'id': 1,
        'vehiculoId': 1,
        'franjaId': 7,
        'fecha': '2026-10-21',
        'horaInicio': '09:00',
        'horaFin': '10:00',
        'estado': 'CONFIRMADA',
      });
      expect(c.estado, EstadoCita.confirmada);
      expect(c.horaInicio, '09:00');
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
                'correo': 'cliente1@example.com',
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
        const PeticionLogin(
          correo: 'cliente1@example.com',
          contrasena: 'CareCar2026',
        ),
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
        const PeticionLogin(
          correo: 'cliente1@example.com',
          contrasena: 'CareCar2026',
        ),
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
