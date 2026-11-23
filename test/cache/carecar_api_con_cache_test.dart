import 'package:carecar_mobile/api/excepciones.dart';
import 'package:carecar_mobile/api/modelos/modelos.dart';
import 'package:carecar_mobile/cache/carecar_api_con_cache.dart';
import 'package:carecar_mobile/nucleo/seguridad/detector_integridad.dart';
import 'package:carecar_mobile/nucleo/seguridad/politica_datos_locales.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../ayudas/api_falsa.dart';

const _auto = Vehiculo(
  id: 7,
  vin: 'VIN123',
  modelo: 'Aveo',
  anio: 2024,
  placas: 'ABC-1',
);

void main() {
  late ApiFalsa base;
  late CarecarApiConCache api;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    base = ApiFalsa()..alPedirVehiculos = () async => [_auto];
    api = CarecarApiConCache(base, await SharedPreferences.getInstance());
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

  group('equipo comprometido (V2-M22.05)', () {
    late SharedPreferences prefs;

    setUp(() async {
      prefs = await SharedPreferences.getInstance();
    });

    test('no guarda copias de las lecturas', () async {
      final politica = PoliticaDatosLocales(EstadoIntegridad.comprometido);
      final sinCopias = CarecarApiConCache(base, prefs, politica: politica);

      expect(await sinCopias.misVehiculos(), hasLength(1));

      expect(prefs.getKeys(), isEmpty);
      base.alPedirVehiculos = () async => throw const SinConexion();
      expect(sinCopias.misVehiculos(), throwsA(isA<SinConexion>()));
    });

    test('borra las copias que ya existian al arrancar', () async {
      await api.misVehiculos();
      expect(prefs.getKeys(), isNotEmpty);

      CarecarApiConCache(
        base,
        prefs,
        politica: PoliticaDatosLocales(EstadoIntegridad.comprometido),
      );
      await Future<void>.delayed(Duration.zero);

      expect(prefs.getKeys(), isEmpty);
    });

    test('borra las copias si la deteccion llega despues', () async {
      final politica = PoliticaDatosLocales();
      final conPolitica = CarecarApiConCache(base, prefs, politica: politica);
      await conPolitica.misVehiculos();
      expect(prefs.getKeys(), isNotEmpty);

      politica.actualizar(EstadoIntegridad.comprometido);
      await Future<void>.delayed(Duration.zero);

      expect(prefs.getKeys(), isEmpty);
    });

    test('equipo integro o desconocido sigue guardando', () async {
      final conPolitica = CarecarApiConCache(
        base,
        prefs,
        politica: PoliticaDatosLocales(EstadoIntegridad.integro),
      );
      await conPolitica.misVehiculos();
      expect(prefs.getKeys(), isNotEmpty);
    });
  });
}
