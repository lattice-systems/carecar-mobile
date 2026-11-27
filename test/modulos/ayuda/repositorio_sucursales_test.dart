import 'package:carecar_mobile/api/carecar_api.dart';
import 'package:carecar_mobile/api/excepciones.dart';
import 'package:carecar_mobile/api/modelos/sucursal.dart';
import 'package:carecar_mobile/modulos/ayuda/datos/repositorio_sucursales_api.dart';
import 'package:carecar_mobile/modulos/ayuda/datos/repositorio_sucursales_fake.dart';
import 'package:carecar_mobile/modulos/ayuda/dominio/sucursal.dart';
import 'package:flutter_test/flutter_test.dart';

class _Api implements CarecarApi {
  _Api(this.respuesta);
  final Future<List<SucursalApi>> Function() respuesta;

  @override
  Future<List<SucursalApi>> sucursales() => respuesta();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

SucursalApi _dto({List<HorarioSucursalApi> horarios = const []}) => SucursalApi(
  id: 1,
  nombre: 'CareCar León',
  direccion: 'Blvd. Ejemplo 100',
  latitud: 21.125,
  longitud: -101.686,
  telefono: '+52 477 000 0000',
  abiertaAhora: true,
  horarios: horarios,
);

void main() {
  group('RepositorioSucursalesApi', () {
    test('traduce la sucursal y sus horarios a dominio', () async {
      final repo = RepositorioSucursalesApi(
        _Api(
          () async => [
            _dto(
              horarios: const [
                HorarioSucursalApi(
                  departamento: 'SERVICIO',
                  dias: [1, 2],
                  abre: '08:00',
                  cierra: '18:00',
                  abiertoAhora: true,
                ),
              ],
            ),
          ],
        ),
      );

      final sucursal = (await repo.sucursales()).single;

      expect(sucursal.nombre, 'CareCar León');
      expect(sucursal.abiertaAhora, isTrue);
      expect(sucursal.horarios.single.departamento, Departamento.servicio);
      expect(sucursal.horarios.single.dias, [1, 2]);
    });

    test('un departamento que la app no conoce se omite sin fallar', () async {
      final repo = RepositorioSucursalesApi(
        _Api(
          () async => [
            _dto(
              horarios: const [
                HorarioSucursalApi(
                  departamento: 'LAVADO',
                  dias: [1],
                  abre: '08:00',
                  cierra: '18:00',
                  abiertoAhora: true,
                ),
              ],
            ),
          ],
        ),
      );

      expect((await repo.sucursales()).single.horarios, isEmpty);
    });

    test('sin sucursales devuelve una lista vacía', () async {
      final repo = RepositorioSucursalesApi(_Api(() async => const []));

      expect(await repo.sucursales(), isEmpty);
    });

    test('los errores de la API pasan tal cual', () async {
      final repo = RepositorioSucursalesApi(
        _Api(() async => throw const SinConexion()),
      );

      expect(repo.sucursales(), throwsA(isA<SinConexion>()));
    });
  });

  group('RepositorioSucursalesFake', () {
    test('trae sucursales de ejemplo', () async {
      expect(await RepositorioSucursalesFake().sucursales(), isNotEmpty);
    });

    test('puede fallar a pedido', () async {
      final fake = RepositorioSucursalesFake(error: const SinConexion());

      expect(fake.sucursales(), throwsA(isA<SinConexion>()));
    });
  });
}
