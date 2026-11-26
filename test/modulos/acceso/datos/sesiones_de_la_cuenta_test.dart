import 'package:carecar_mobile/api/modelos/modelos.dart';
import 'package:carecar_mobile/modulos/acceso/datos/repositorio_acceso_api.dart';
import 'package:carecar_mobile/nucleo/datos/fallo.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../ayudas/api_falsa.dart';
import '../../../ayudas/fallos_de_prueba.dart';

/// V2-M01.09 · el repositorio lee las sesiones y las cierra.
///
/// Lo que se prueba aqui es la frontera: que de `datos/` salgan tipos de
/// dominio -y no el modelo del contrato-, y que un error de red salga ya
/// tipado como `Fallo`, que es lo que la pantalla sabe pintar.
void main() {
  SesionActiva delContrato({
    int id = 9,
    String? dispositivo,
    DateTime? ultimoUso,
    DateTime? iniciadaEn,
  }) => SesionActiva(
    id: id,
    dispositivo: dispositivo,
    ultimoUso: ultimoUso,
    iniciadaEn: iniciadaEn,
    expiraEn: DateTime.utc(2026, 12, 24, 18, 30),
  );

  group('leer las sesiones', () {
    test('traduce lo del contrato a dominio sin perder nada', () async {
      final api = ApiFalsa()
        ..alPedirSesiones = () async => [
          delContrato(
            id: 9,
            dispositivo: 'Pixel 7 de Jael',
            ultimoUso: DateTime.utc(2026, 11, 24, 18, 30),
            iniciadaEn: DateTime.utc(2026, 11, 1, 9),
          ),
        ];

      final sesiones = await RepositorioAccesoApi(api).sesiones();

      expect(sesiones, hasLength(1));
      final s = sesiones.single;
      expect(s.id, 9);
      expect(s.dispositivo, 'Pixel 7 de Jael');
      expect(s.ultimoUso, DateTime.utc(2026, 11, 24, 18, 30));
      expect(s.iniciadaEn, DateTime.utc(2026, 11, 1, 9));
      expect(s.expiraEn, DateTime.utc(2026, 12, 24, 18, 30));
    });

    test('conserva el orden en que llegaron', () async {
      // El servidor ya las manda por ultimo uso descendente, con las que nunca
      // se refrescaron al final. Reordenar aqui seria discrepar de el.
      final api = ApiFalsa()
        ..alPedirSesiones = () async => [
          delContrato(id: 9, ultimoUso: DateTime.utc(2026, 11, 24)),
          delContrato(id: 4, ultimoUso: DateTime.utc(2026, 11, 20)),
          delContrato(id: 7),
        ];

      final sesiones = await RepositorioAccesoApi(api).sesiones();

      expect(sesiones.map((s) => s.id), [9, 4, 7]);
    });

    test('ninguna sesion es una lista vacia, no un error', () async {
      final api = ApiFalsa()..alPedirSesiones = () async => const [];

      expect(await RepositorioAccesoApi(api).sesiones(), isEmpty);
    });

    test('sin conexion sale como Fallo tipado', () async {
      final api = ApiFalsa()
        ..alPedirSesiones = () async => throw Fallos.sinConexion();

      await expectLater(
        RepositorioAccesoApi(api).sesiones(),
        throwsA(
          isA<Fallo>().having((f) => f.esSinConexion, 'esSinConexion', isTrue),
        ),
      );
    });
  });

  group('cerrar sesiones', () {
    test('cerrar una manda su id', () async {
      final api = ApiFalsa();

      await RepositorioAccesoApi(api).cerrarUnaSesion(12);

      expect(api.sesionesCerradas, [12]);
      expect(api.todasLasSesionesCerradas, isFalse);
    });

    test('cerrar todas no manda ningun id', () async {
      // Son operaciones distintas en el contrato, y confundirlas es caro:
      // cerrar todas incluye la sesion de quien llama.
      final api = ApiFalsa();

      await RepositorioAccesoApi(api).cerrarTodasLasSesiones();

      expect(api.todasLasSesionesCerradas, isTrue);
      expect(api.sesionesCerradas, isEmpty);
    });
  });
}
