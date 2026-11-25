import 'dart:async';

import 'package:carecar_mobile/modulos/privacidad/dominio/arco.dart';
import 'package:carecar_mobile/modulos/privacidad/presentacion/proveedores_arco.dart';
import 'package:carecar_mobile/nucleo/eventos/eventos_en_vivo.dart';
import 'package:carecar_mobile/nucleo/eventos/eventos_en_vivo_fake.dart';
import 'package:carecar_mobile/nucleo/eventos/proveedores_eventos.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'repositorio_arco_falso.dart';

/// Espera a que el estado cumpla [condicion], dejando correr el reloj real.
Future<void> _hasta(
  ProviderContainer c,
  bool Function(SolicitudDeArco?) condicion,
) async {
  for (var i = 0; i < 100; i++) {
    final valor = c.read(accesoArcoProvider).value;
    if (c.read(accesoArcoProvider).hasValue && condicion(valor)) return;
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
  fail('el estado no llego a lo esperado: ${c.read(accesoArcoProvider)}');
}

void main() {
  late RepositorioArcoFalso repo;
  late EventosEnVivoFake eventos;
  late ProviderContainer c;
  late ProviderSubscription<AsyncValue<SolicitudDeArco?>> escucha;

  void montar({Duration intervalo = const Duration(milliseconds: 10)}) {
    c = ProviderContainer(
      overrides: [
        repositorioArcoProvider.overrideWithValue(repo),
        eventosEnVivoProvider.overrideWithValue(eventos),
        intervaloArcoProvider.overrideWithValue(intervalo),
      ],
    );
    addTearDown(c.dispose);
    // Como la pantalla: mientras alguien lo escucha, el estado vive.
    escucha = c.listen(accesoArcoProvider, (_, _) {});
  }

  setUp(() {
    repo = RepositorioArcoFalso();
    eventos = EventosEnVivoFake();
  });

  group('accesoArcoProvider (V2-M22.02)', () {
    test('es la ultima solicitud de acceso, no la de otros derechos', () async {
      repo.listas.add([
        solicitudArco(9, EstadoArco.resuelta, tipo: TipoArco.cancelacion),
        solicitudArco(5, EstadoArco.fallida),
        solicitudArco(2, EstadoArco.resuelta),
      ]);
      montar();

      await _hasta(c, (s) => s != null);

      expect(c.read(accesoArcoProvider).value!.id, 5);
    });

    test('sin ninguna solicitud de acceso es nulo', () async {
      repo.listas.add([
        solicitudArco(9, EstadoArco.resuelta, tipo: TipoArco.cancelacion),
      ]);
      montar();

      await c.read(accesoArcoProvider.future);

      expect(c.read(accesoArcoProvider).value, isNull);
    });

    test(
      'si no se puede leer al abrir, queda el error para reintentar',
      () async {
        repo.listas.add(const ArcoSinConexion());
        montar();

        await expectLater(
          c.read(accesoArcoProvider.future),
          throwsA(isA<ArcoSinConexion>()),
        );
        expect(c.read(accesoArcoProvider).hasError, isTrue);
      },
    );

    test(
      'pedir deja la solicitud pendiente y la sigue hasta que se resuelve',
      () async {
        repo.listas.addAll([
          const <SolicitudDeArco>[],
          [solicitudArco(1, EstadoArco.pendiente)],
          [solicitudArco(1, EstadoArco.pendiente)],
          [solicitudArco(1, EstadoArco.resuelta)],
        ]);
        repo.alPedir = solicitudArco(1, EstadoArco.pendiente);
        montar();
        await c.read(accesoArcoProvider.future);

        await c.read(accesoArcoProvider.notifier).pedir();

        expect(c.read(accesoArcoProvider).value!.estado, EstadoArco.pendiente);
        await _hasta(c, (s) => s?.estado == EstadoArco.resuelta);
        expect(repo.pedidos, 1);
        // Resuelta, ya no pregunta.
        final lecturas = repo.lecturas;
        await Future<void>.delayed(const Duration(milliseconds: 80));
        expect(repo.lecturas, lecturas);
      },
    );

    test('un evento arco.estado la refresca sin esperar al intervalo', () async {
      repo.listas.addAll([
        [solicitudArco(1, EstadoArco.pendiente)],
        [solicitudArco(1, EstadoArco.resuelta)],
      ]);
      montar(intervalo: const Duration(hours: 1));
      await c.read(accesoArcoProvider.future);
      expect(c.read(accesoArcoProvider).value!.estado, EstadoArco.pendiente);
      // La conexion se abre cuando alguien escucha; deja que el flujo arranque.
      await Future<void>.delayed(Duration.zero);

      eventos.emitir('arco.estado', {
        'solicitudId': 1,
        'tipo': 'ACCESO',
        'estado': 'RESUELTA',
      });

      await _hasta(c, (s) => s?.estado == EstadoArco.resuelta);
    });

    test('al reconectarse el canal vuelve a preguntar', () async {
      repo.listas.addAll([
        [solicitudArco(1, EstadoArco.pendiente)],
        [solicitudArco(1, EstadoArco.resuelta)],
      ]);
      montar(intervalo: const Duration(hours: 1));
      await c.read(accesoArcoProvider.future);
      await Future<void>.delayed(Duration.zero);

      eventos.emitir(eventoReconectado);

      await _hasta(c, (s) => s?.estado == EstadoArco.resuelta);
    });

    test('un evento de otra cosa no la refresca', () async {
      repo.listas.add([solicitudArco(1, EstadoArco.pendiente)]);
      montar(intervalo: const Duration(hours: 1));
      await c.read(accesoArcoProvider.future);
      await Future<void>.delayed(Duration.zero);
      final antes = repo.lecturas;

      eventos.emitir('orden', {'ordenId': 3});
      await Future<void>.delayed(const Duration(milliseconds: 30));

      expect(repo.lecturas, antes);
    });

    test(
      'si falla al refrescar conserva lo que habia y sigue intentando',
      () async {
        repo.listas.addAll([
          [solicitudArco(1, EstadoArco.pendiente)],
          const ArcoSinConexion(),
          [solicitudArco(1, EstadoArco.resuelta)],
        ]);
        montar();

        await _hasta(c, (s) => s?.estado == EstadoArco.resuelta);

        expect(c.read(accesoArcoProvider).hasError, isFalse);
      },
    );

    test(
      'pedir que falla relanza el fallo y deja el estado como estaba',
      () async {
        repo.listas.add(const <SolicitudDeArco>[]);
        repo.alPedir = const ArcoSinConexion();
        montar();
        await c.read(accesoArcoProvider.future);

        await expectLater(
          c.read(accesoArcoProvider.notifier).pedir(),
          throwsA(isA<ArcoSinConexion>()),
        );
        expect(c.read(accesoArcoProvider).value, isNull);
      },
    );

    test('al salir de la pantalla deja de preguntar', () async {
      repo.listas.add([solicitudArco(1, EstadoArco.pendiente)]);
      montar();
      await c.read(accesoArcoProvider.future);
      await Future<void>.delayed(const Duration(milliseconds: 40));
      expect(repo.lecturas, greaterThan(1));

      escucha.close();
      await Future<void>.delayed(const Duration(milliseconds: 30));
      final lecturas = repo.lecturas;
      await Future<void>.delayed(const Duration(milliseconds: 60));

      expect(repo.lecturas, lecturas);
    });

    test('si la pantalla se cierra con una lectura en vuelo, no truena al '
        'llegar', () async {
      repo.listas.add([solicitudArco(1, EstadoArco.pendiente)]);
      montar(intervalo: const Duration(hours: 1));
      await c.read(accesoArcoProvider.future);
      await Future<void>.delayed(Duration.zero);
      repo.esperaAlListar = Completer<void>();
      eventos.emitir('arco.estado', {
        'solicitudId': 1,
        'tipo': 'ACCESO',
        'estado': 'RESUELTA',
      });
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(repo.lecturas, 2, reason: 'la lectura quedo esperando');

      escucha.close();
      await Future<void>.delayed(const Duration(milliseconds: 20));
      repo.esperaAlListar!.complete();
      await Future<void>.delayed(const Duration(milliseconds: 20));

      // Un error sin atrapar de la lectura tardia haria fallar la prueba.
      expect(repo.lecturas, 2);
    });

    test(
      'si la lectura en vuelo falla con la pantalla cerrada, tampoco truena',
      () async {
        repo.listas.addAll([
          [solicitudArco(1, EstadoArco.pendiente)],
          const ArcoSinConexion(),
        ]);
        montar(intervalo: const Duration(hours: 1));
        await c.read(accesoArcoProvider.future);
        await Future<void>.delayed(Duration.zero);
        repo.esperaAlListar = Completer<void>();
        eventos.emitir('arco.estado', {
          'solicitudId': 1,
          'tipo': 'ACCESO',
          'estado': 'FALLIDA',
        });
        await Future<void>.delayed(const Duration(milliseconds: 20));

        escucha.close();
        await Future<void>.delayed(const Duration(milliseconds: 20));
        repo.esperaAlListar!.complete();
        await Future<void>.delayed(const Duration(milliseconds: 20));

        expect(repo.lecturas, 2);
      },
    );

    test('lo pedido que llega con la pantalla ya cerrada no truena', () async {
      repo.listas.add(const <SolicitudDeArco>[]);
      repo.alPedir = solicitudArco(1, EstadoArco.pendiente);
      repo.esperaAlPedir = Completer<void>();
      montar();
      await c.read(accesoArcoProvider.future);

      final pedido = c.read(accesoArcoProvider.notifier).pedir();
      await Future<void>.delayed(const Duration(milliseconds: 10));
      escucha.close();
      await Future<void>.delayed(const Duration(milliseconds: 20));
      repo.esperaAlPedir!.complete();

      await pedido;
      await Future<void>.delayed(const Duration(milliseconds: 20));
    });

    test('una fallida o una vencida no se siguen preguntando', () async {
      repo.listas.add([solicitudArco(1, EstadoArco.fallida)]);
      montar();
      await c.read(accesoArcoProvider.future);

      await Future<void>.delayed(const Duration(milliseconds: 60));

      expect(repo.lecturas, 1);
    });
  });
}
