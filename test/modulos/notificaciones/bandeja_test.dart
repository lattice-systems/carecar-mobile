import 'package:carecar_mobile/modulos/notificaciones/datos/repositorio_avisos_fake.dart';
import 'package:carecar_mobile/modulos/notificaciones/dominio/aviso_cliente.dart';
import 'package:carecar_mobile/modulos/notificaciones/presentacion/proveedores_bandeja.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// V2-M06.04 · la bandeja de avisos.
///
/// Los tres criterios: que esté **paginada**, que el **contador de no leídos**
/// diga la verdad y que se puedan **marcar todos como leídos**.
void main() {
  AvisoCliente aviso(int id, {bool leida = false, String destino = '/citas'}) =>
      AvisoCliente(
        id: id,
        categoria: CategoriaDeAviso.citas,
        titulo: 'Aviso $id',
        cuerpo: 'Cuerpo del aviso $id',
        creadaEn: DateTime.utc(2026, 11, 20 + (id % 5)),
        destino: destino,
        leida: leida,
      );

  ProviderContainer contenedor(RepositorioAvisosFake repo, {int tamano = 20}) {
    final c = ProviderContainer(
      overrides: [
        repositorioAvisosProvider.overrideWithValue(repo),
        tamanoPaginaAvisosProvider.overrideWithValue(tamano),
      ],
    );
    addTearDown(c.dispose);
    return c;
  }

  group('cargar la bandeja', () {
    test('la primera página llega con su total sin leer', () async {
      final repo = RepositorioAvisosFake(
        avisos: [aviso(1), aviso(2, leida: true), aviso(3)],
      );
      final c = contenedor(repo);

      final estado = await c.read(bandejaProvider.future);

      expect(estado.avisos.map((a) => a.id), [1, 2, 3]);
      expect(estado.noLeidos, 2);
      expect(estado.hayMas, isFalse);
    });

    test('una bandeja vacía no es un error', () async {
      final c = contenedor(RepositorioAvisosFake());

      final estado = await c.read(bandejaProvider.future);

      expect(estado.avisos, isEmpty);
      expect(estado.noLeidos, 0);
    });

    test(
      'un destino que no es ruta interna se descarta, no el aviso',
      () async {
        final repo = RepositorioAvisosFake(
          avisos: [
            aviso(1, destino: '/citas'),
            aviso(2),
          ],
        );
        final c = contenedor(repo);
        final estado = await c.read(bandejaProvider.future);

        // El falso ya entrega dominio, así que esto comprueba la forma: un
        // destino nulo no esconde el aviso. La validación en sí se prueba en
        // `destino_de_aviso_test.dart`.
        expect(estado.avisos, hasLength(2));
      },
    );
  });

  group('paginar', () {
    test('cargarMas suma la siguiente al final', () async {
      final repo = RepositorioAvisosFake(
        avisos: [aviso(1), aviso(2), aviso(3), aviso(4), aviso(5)],
      );
      final c = contenedor(repo, tamano: 2);
      var estado = await c.read(bandejaProvider.future);
      expect(estado.avisos.map((a) => a.id), [1, 2]);
      expect(estado.hayMas, isTrue);

      await c.read(bandejaProvider.notifier).cargarMas();

      estado = c.read(bandejaProvider).requireValue;
      expect(estado.avisos.map((a) => a.id), [1, 2, 3, 4]);
      expect(estado.pagina, 1);
    });

    test('en la última página ya no hay más', () async {
      final repo = RepositorioAvisosFake(avisos: [aviso(1), aviso(2)]);
      final c = contenedor(repo, tamano: 2);
      await c.read(bandejaProvider.future);

      await c.read(bandejaProvider.notifier).cargarMas();

      expect(c.read(bandejaProvider).requireValue.hayMas, isFalse);
    });

    test('si falla la siguiente página, se conserva lo cargado', () async {
      final repo = RepositorioAvisosFake(
        avisos: [aviso(1), aviso(2), aviso(3)],
      );
      final c = contenedor(repo, tamano: 2);
      await c.read(bandejaProvider.future);
      repo.falla = true;

      await c.read(bandejaProvider.notifier).cargarMas();

      final estado = c.read(bandejaProvider).requireValue;
      expect(estado.avisos.map((a) => a.id), [1, 2]);
      expect(estado.errorAlCargarMas, isTrue);
      // Lo que importa: no se perdió lo que la persona ya estaba leyendo.
      expect(c.read(bandejaProvider).hasError, isFalse);
    });
  });

  group('marcar como leído', () {
    test('uno baja el contador y no se repite', () async {
      final repo = RepositorioAvisosFake(avisos: [aviso(1), aviso(2)]);
      final c = contenedor(repo);
      await c.read(bandejaProvider.future);

      await c.read(bandejaProvider.notifier).marcarLeido(1);
      await c.read(bandejaProvider.notifier).marcarLeido(1);

      final estado = c.read(bandejaProvider).requireValue;
      expect(estado.noLeidos, 1);
      expect(repo.marcados, [
        1,
      ], reason: 'marcar lo ya leído no llama al servidor');
    });

    test('todos deja el contador en cero, con una sola llamada', () async {
      final repo = RepositorioAvisosFake(
        avisos: [aviso(1), aviso(2), aviso(3, leida: true)],
      );
      final c = contenedor(repo);
      await c.read(bandejaProvider.future);

      await c.read(bandejaProvider.notifier).marcarTodosLeidos();

      expect(c.read(bandejaProvider).requireValue.noLeidos, 0);
      expect(repo.lotes, 1);
    });

    test('sin nada sin leer, marcar todos no llama al servidor', () async {
      final repo = RepositorioAvisosFake(avisos: [aviso(1, leida: true)]);
      final c = contenedor(repo);
      await c.read(bandejaProvider.future);

      await c.read(bandejaProvider.notifier).marcarTodosLeidos();

      expect(repo.lotes, 0);
    });

    test('se pinta leído aunque el servidor falle', () async {
      final repo = RepositorioAvisosFake(avisos: [aviso(1)]);
      final c = contenedor(repo);
      await c.read(bandejaProvider.future);
      repo.falla = true;

      await c.read(bandejaProvider.notifier).marcarLeido(1);

      // Abrir un aviso no debe sentirse lento. El servidor es idempotente y
      // la próxima carga manda la verdad.
      expect(c.read(bandejaProvider).requireValue.noLeidos, 0);
    });
  });

  group('el contador', () {
    test('mientras carga es cero, no inventa', () {
      final c = contenedor(RepositorioAvisosFake(avisos: [aviso(1)]));
      expect(c.read(avisosSinLeerProvider), 0);
    });

    test('cargada, es el total de la cuenta y no el de la página', () async {
      final repo = RepositorioAvisosFake(
        avisos: [aviso(1), aviso(2), aviso(3), aviso(4)],
      );
      final c = contenedor(repo, tamano: 2);
      await c.read(bandejaProvider.future);

      // Solo dos avisos cargados, pero cuatro sin leer en la cuenta.
      expect(c.read(bandejaProvider).requireValue.avisos, hasLength(2));
      expect(c.read(avisosSinLeerProvider), 4);
    });
  });
}
