import 'package:flutter/widgets.dart';
import 'package:carecar_mobile/nucleo/migracion/interruptor_modulos.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  group('valor por defecto en codigo', () {
    test('todo modulo arranca en v1', () {
      const interruptor = InterruptorModulos.porDefecto;
      for (final m in ModuloMigrable.values) {
        expect(interruptor.de(m), VersionModulo.v1, reason: m.name);
        expect(interruptor.esV2(m), isFalse);
      }
    });

    test('todoV2 enciende cada modulo', () {
      for (final m in ModuloMigrable.values) {
        expect(InterruptorModulos.todoV2.esV2(m), isTrue, reason: m.name);
      }
    });
  });

  group('sobrescribir con --dart-define', () {
    test('MODULOS_V2 enciende solo los modulos nombrados', () {
      final i = InterruptorModulos.desdeValores(v2: 'vehiculos, citas');
      expect(i.esV2(ModuloMigrable.vehiculos), isTrue);
      expect(i.esV2(ModuloMigrable.citas), isTrue);
      expect(i.esV2(ModuloMigrable.catalogo), isFalse);
      expect(i.esV2(ModuloMigrable.asistencia), isFalse);
    });

    test('"todos" enciende todos y MODULOS_V1 apaga los que se indiquen', () {
      final i = InterruptorModulos.desdeValores(v2: 'todos', v1: 'catalogo');
      expect(i.esV2(ModuloMigrable.vehiculos), isTrue);
      expect(i.esV2(ModuloMigrable.catalogo), isFalse);
    });

    test('si un modulo esta en las dos listas gana v1 (el lado seguro)', () {
      final i = InterruptorModulos.desdeValores(v2: 'citas', v1: 'citas');
      expect(i.esV2(ModuloMigrable.citas), isFalse);
    });

    test('sin valores queda el valor por defecto', () {
      final i = InterruptorModulos.desdeValores();
      for (final m in ModuloMigrable.values) {
        expect(i.esV2(m), isFalse);
      }
    });

    test('un nombre que no existe falla en voz alta, no se ignora', () {
      expect(
        () => InterruptorModulos.desdeValores(v2: 'vehiculso'),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.toString(),
            'mensaje',
            allOf(contains('vehiculso'), contains('vehiculos')),
          ),
        ),
      );
    });

    test('ignora mayusculas, espacios y entradas vacias', () {
      final i = InterruptorModulos.desdeValores(v2: ' Citas ,, ');
      expect(i.esV2(ModuloMigrable.citas), isTrue);
    });
  });

  group('rutas', () {
    final rutas = <RouteBase>[
      GoRoute(path: '/x', builder: (_, _) => const SizedBox()),
    ];

    test('en v1 el modulo no entrega rutas v2', () {
      expect(
        InterruptorModulos.porDefecto.rutas(ModuloMigrable.citas, rutas),
        isEmpty,
      );
    });

    test('en v2 entrega las rutas del modulo', () {
      expect(
        InterruptorModulos.todoV2.rutas(ModuloMigrable.citas, rutas),
        rutas,
      );
    });
  });
}
