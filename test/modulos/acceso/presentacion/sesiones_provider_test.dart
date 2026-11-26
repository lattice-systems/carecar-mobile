import 'package:carecar_mobile/modulos/acceso/datos/repositorio_acceso_fake.dart';
import 'package:carecar_mobile/modulos/acceso/dominio/fallos_acceso.dart';
import 'package:carecar_mobile/modulos/acceso/dominio/sesion_de_la_cuenta.dart';
import 'package:carecar_mobile/modulos/acceso/presentacion/proveedores_acceso.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../ayudas/fallos_de_prueba.dart';

/// V2-M01.09 · la lista de sesiones y sus dos formas de cerrar.
///
/// El caso con filo no es cerrar: es **cerrar una sesión cuyo `id` ya cambió**.
/// El backend crea una fila nueva en cada refresco, así que la lista que la
/// pantalla tiene en pantalla envejece y un `DELETE` puede llegar tarde y
/// responder 404. Quitarla de la lista entonces le diría al cliente que echó
/// al intruso cuando no lo hizo.
void main() {
  SesionDeLaCuenta sesion(int id) => SesionDeLaCuenta(
    id: id,
    dispositivo: 'Equipo $id',
    ultimoUso: DateTime.utc(2026, 11, 26, 11),
    expiraEn: DateTime.utc(2026, 12, 26),
  );

  ProviderContainer contenedor(RepositorioAccesoFake repo) {
    final c = ProviderContainer(
      overrides: [repositorioAccesoProvider.overrideWithValue(repo)],
    );
    addTearDown(c.dispose);
    return c;
  }

  test('carga las sesiones del repositorio', () async {
    final repo = RepositorioAccesoFake()
      ..sesionesAbiertas = [sesion(9), sesion(4)];
    final c = contenedor(repo);

    final lista = await c.read(sesionesProvider.future);

    expect(lista.map((s) => s.id), [9, 4]);
  });

  test('cerrar una la quita de la lista sin volver a pedirla', () async {
    final repo = RepositorioAccesoFake()
      ..sesionesAbiertas = [sesion(9), sesion(4)];
    final c = contenedor(repo);
    await c.read(sesionesProvider.future);

    await c.read(sesionesProvider.notifier).cerrar(9);

    expect(c.read(sesionesProvider).requireValue.map((s) => s.id), [4]);
    expect(repo.sesionesCerradas, [9]);
    // Una sola lectura: la de la carga inicial.
    expect(repo.llamadasAlLeerSesiones, 1);
  });

  test('cerrar todas deja la lista vacia', () async {
    final repo = RepositorioAccesoFake()
      ..sesionesAbiertas = [sesion(9), sesion(4)];
    final c = contenedor(repo);
    await c.read(sesionesProvider.future);

    await c.read(sesionesProvider.notifier).cerrarTodas();

    expect(c.read(sesionesProvider).requireValue, isEmpty);
    expect(repo.cerroTodas, isTrue);
  });

  group('cuando el id ya cambio', () {
    test('un 404 relee la lista y avisa, en vez de mentir', () async {
      final repo = RepositorioAccesoFake()
        ..sesionesAbiertas = [sesion(9)]
        ..fallaAlCerrar = Fallos.noEncontrado();
      final c = contenedor(repo);
      await c.read(sesionesProvider.future);

      await expectLater(
        c.read(sesionesProvider.notifier).cerrar(9),
        throwsA(isA<SesionYaNoEsta>()),
      );

      // Releyo: la pantalla queda con lo que el servidor dice ahora, no con
      // una lista donde la sesion desaparecio por arte de magia.
      expect(repo.llamadasAlLeerSesiones, 2);
      expect(c.read(sesionesProvider).requireValue.map((s) => s.id), [9]);
    });

    test('cualquier otro fallo sale tal cual y la lista no cambia', () async {
      // Sin conexion no significa «ya no esta»: significa que no se sabe.
      final repo = RepositorioAccesoFake()
        ..sesionesAbiertas = [sesion(9), sesion(4)]
        ..fallaAlCerrar = Fallos.sinConexion();
      final c = contenedor(repo);
      await c.read(sesionesProvider.future);

      await expectLater(
        c.read(sesionesProvider.notifier).cerrar(9),
        throwsA(isA<Object>()),
      );

      expect(c.read(sesionesProvider).requireValue.map((s) => s.id), [9, 4]);
      expect(repo.llamadasAlLeerSesiones, 1);
    });
  });
}
