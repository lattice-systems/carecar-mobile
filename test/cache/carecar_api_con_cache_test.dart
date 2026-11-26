import 'package:carecar_mobile/api/excepciones.dart';
import 'package:carecar_mobile/api/modelos/modelos.dart';
import 'package:carecar_mobile/cache/carecar_api_con_cache.dart';
import 'package:carecar_mobile/cache/cifrador_de_cache.dart';
import 'package:carecar_mobile/nucleo/seguridad/detector_integridad.dart';
import 'package:carecar_mobile/nucleo/seguridad/politica_datos_locales.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../ayudas/almacenamiento_en_memoria.dart';
import '../ayudas/api_falsa.dart';

const _auto = Vehiculo(
  id: 7,
  vin: 'VIN123',
  modelo: 'Aveo',
  anio: 2024,
  placas: 'ABC-1',
);

final _perfil = Perfil(
  id: 1,
  nombre: 'Ana Lopez',
  correo: 'ana@correo.com',
  telefono: '477 123 4567',
  clienteDesde: DateTime(2024, 3),
);

void main() {
  late ApiFalsa base;
  late AlmacenamientoEnMemoria llaves;
  late SharedPreferences prefs;
  late CarecarApiConCache api;

  CarecarApiConCache nueva({PoliticaDatosLocales? politica}) =>
      CarecarApiConCache(
        base,
        prefs,
        CifradorAesGcm(llaves),
        politica: politica,
      );

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    llaves = AlmacenamientoEnMemoria();
    base = ApiFalsa();
    base.alPedirVehiculos = () async => [_auto];
    base.alPedirPerfil = () async => _perfil;
    api = nueva();
  });

  test('ante SinConexion devuelve la ultima copia buena', () async {
    expect(await api.misVehiculos(), hasLength(1));
    expect(api.sinConexion.value, isFalse);

    base.alPedirVehiculos = () async => throw const SinConexion();
    final copia = await api.misVehiculos();

    expect(copia.single.modelo, 'Aveo');
    expect(copia.single.placas, 'ABC-1');
    expect(api.sinConexion.value, isTrue);
  });

  test('sin copia guardada, SinConexion se propaga', () async {
    base.alPedirVehiculos = () async => throw const SinConexion();
    expect(api.misVehiculos(), throwsA(isA<SinConexion>()));
  });

  test('al cerrar sesion se limpia la cache', () async {
    await api.misVehiculos();
    await api.cerrarSesion('refresco');

    base.alPedirVehiculos = () async => throw const SinConexion();
    expect(api.misVehiculos(), throwsA(isA<SinConexion>()));
  });

  group('copias cifradas (V2-M22.13)', () {
    test('ninguna copia deja ver correo, nombre, VIN ni placas', () async {
      await api.miPerfil();
      await api.misVehiculos();

      expect(prefs.getKeys(), hasLength(2));
      final guardado = prefs.getKeys().map(prefs.getString).join('|');
      for (final dato in ['ana@correo.com', 'Ana Lopez', 'VIN123', 'ABC-1']) {
        expect(guardado, isNot(contains(dato)), reason: 'se ve $dato');
      }
    });

    test(
      'lo cifrado se lee de vuelta sin conexión, también tras reiniciar',
      () async {
        await api.miPerfil();
        await api.misVehiculos();

        // Otra instancia: como al abrir la app de nuevo con la misma llave.
        final reiniciada = nueva();
        base.alPedirPerfil = () async => throw const SinConexion();
        base.alPedirVehiculos = () async => throw const SinConexion();

        expect((await reiniciada.miPerfil()).correo, 'ana@correo.com');
        expect((await reiniciada.misVehiculos()).single.vin, 'VIN123');
      },
    );

    test('una copia ilegible se descarta y SinConexion se propaga', () async {
      await api.misVehiculos();
      final clave = prefs.getKeys().single;
      await prefs.setString(clave, '[{"vin":"VIN123"}]');
      base.alPedirVehiculos = () async => throw const SinConexion();

      await expectLater(api.misVehiculos(), throwsA(isA<SinConexion>()));
      await Future<void>.delayed(Duration.zero);

      expect(prefs.getKeys(), isEmpty, reason: 'la copia inservible se borra');
      expect(api.sinConexion.value, isFalse);
    });

    test('una copia con otra forma que la de ahora se descarta', () async {
      await api.misVehiculos();
      final clave = prefs.getKeys().single;
      final ajena = await CifradorAesGcm(llaves)
          .cifrar('{"no":"es una lista"}', contexto: 'vehiculos');
      await prefs.setString(clave, ajena);
      base.alPedirVehiculos = () async => throw const SinConexion();

      await expectLater(api.misVehiculos(), throwsA(isA<SinConexion>()));

      expect(prefs.getKeys(), isEmpty);
    });

    test('una copia movida a otra clave de la caché no se usa', () async {
      await api.miPerfil();
      await api.misVehiculos();
      final claves = prefs.getKeys();
      final perfil = claves.firstWhere((k) => k.endsWith('perfil'));
      final vehiculos = claves.firstWhere((k) => k.endsWith('vehiculos'));
      await prefs.setString(vehiculos, prefs.getString(perfil)!);
      base.alPedirVehiculos = () async => throw const SinConexion();

      await expectLater(api.misVehiculos(), throwsA(isA<SinConexion>()));
    });

    test(
      'al arrancar borra las copias en texto plano de versiones anteriores',
      () async {
        await prefs.setString('cache_carecar_vehiculos', '[{"vin":"VIN123"}]');
        await prefs.setString(
          'cache_carecar_perfil',
          '{"correo":"ana@correo.com"}',
        );
        await prefs.setString('otra_cosa', 'se queda');

        nueva();
        await Future<void>.delayed(Duration.zero);

        expect(prefs.getKeys(), {'otra_cosa'});
      },
    );

    test('al cerrar sesión también se olvida la llave', () async {
      await api.misVehiculos();
      expect(llaves.valores, isNotEmpty);
      // Limpiar borra las copias de cualquier versión, no solo las de ahora.
      await prefs.setString(
        'cache_carecar_perfil',
        'copia de una versión vieja',
      );

      await api.cerrarSesion('refresco');

      expect(llaves.valores, isEmpty);
      expect(prefs.getKeys(), isEmpty);
    });

    test('cerrar sesión no falla aunque el almacén seguro falle', () async {
      await api.misVehiculos();
      llaves.falla = StateError('Keystore no responde');

      await api.cerrarSesion('refresco');

      expect(prefs.getKeys(), isEmpty);
    });

    test(
      'si el almacén seguro falla, la lectura se entrega y no se guarda copia',
      () async {
        llaves.falla = StateError('Keystore no responde');

        expect(await api.misVehiculos(), hasLength(1));

        expect(prefs.getKeys(), isEmpty);
      },
    );

    test(
      'si el almacén seguro falla, sin conexión no hay copia que dar',
      () async {
        await api.misVehiculos();
        llaves.falla = StateError('Keystore no responde');
        base.alPedirVehiculos = () async => throw const SinConexion();

        await expectLater(nueva().misVehiculos(), throwsA(isA<SinConexion>()));
      },
    );
  });

  group('equipo comprometido (V2-M22.05)', () {
    test('no guarda copias de las lecturas', () async {
      final politica = PoliticaDatosLocales(EstadoIntegridad.comprometido);
      final sinCopias = nueva(politica: politica);

      expect(await sinCopias.misVehiculos(), hasLength(1));

      expect(prefs.getKeys(), isEmpty);
      base.alPedirVehiculos = () async => throw const SinConexion();
      expect(sinCopias.misVehiculos(), throwsA(isA<SinConexion>()));
    });

    test('borra las copias que ya existian al arrancar', () async {
      await api.misVehiculos();
      expect(prefs.getKeys(), isNotEmpty);

      nueva(politica: PoliticaDatosLocales(EstadoIntegridad.comprometido));
      await Future<void>.delayed(Duration.zero);

      expect(prefs.getKeys(), isEmpty);
    });

    test('borra las copias si la deteccion llega despues', () async {
      final politica = PoliticaDatosLocales();
      final conPolitica = nueva(politica: politica);
      await conPolitica.misVehiculos();
      expect(prefs.getKeys(), isNotEmpty);

      politica.actualizar(EstadoIntegridad.comprometido);
      await Future<void>.delayed(Duration.zero);

      expect(prefs.getKeys(), isEmpty);
    });

    test('equipo integro o desconocido sigue guardando', () async {
      final conPolitica = nueva(
        politica: PoliticaDatosLocales(EstadoIntegridad.integro),
      );
      await conPolitica.misVehiculos();
      expect(prefs.getKeys(), isNotEmpty);
    });
  });
}
