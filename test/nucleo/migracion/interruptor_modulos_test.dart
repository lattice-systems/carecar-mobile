import 'package:flutter/widgets.dart';
import 'package:carecar_mobile/nucleo/migracion/interruptor_modulos.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  group('valor por defecto en codigo', () {
    test('lo que existia en v1 arranca en v2, menos la recuperacion', () {
      const interruptor = InterruptorModulos.porDefecto;
      for (final m in ModuloMigrable.values) {
        expect(
          interruptor.esV2(m),
          m != ModuloMigrable.recuperacion,
          reason: m.name,
        );
      }
    });

    test('la recuperacion sigue en v1 hasta que el enlace del correo abra la '
        'app (V2-T01.10)', () {
      expect(
        InterruptorModulos.porDefecto.de(ModuloMigrable.recuperacion),
        VersionModulo.v1,
      );
    });

    test('todoV1 apaga cada modulo: es la v1 de las pruebas', () {
      for (final m in ModuloMigrable.values) {
        expect(
          InterruptorModulos.todoV1.de(m),
          VersionModulo.v1,
          reason: m.name,
        );
      }
    });

    test('todoV2 enciende cada modulo', () {
      for (final m in ModuloMigrable.values) {
        expect(InterruptorModulos.todoV2.esV2(m), isTrue, reason: m.name);
      }
    });
  });

  group('sobrescribir con --dart-define', () {
    test('MODULOS_V1 apaga solo los modulos nombrados', () {
      final i = InterruptorModulos.desdeValores(v1: 'vehiculos, citas');
      expect(i.esV2(ModuloMigrable.vehiculos), isFalse);
      expect(i.esV2(ModuloMigrable.citas), isFalse);
      expect(i.esV2(ModuloMigrable.catalogo), isTrue);
      expect(i.esV2(ModuloMigrable.asistencia), isTrue);
    });

    test('MODULOS_V1=todos devuelve todo a la v1: la salida de emergencia', () {
      final i = InterruptorModulos.desdeValores(v1: 'todos');
      for (final m in ModuloMigrable.values) {
        expect(i.esV2(m), isFalse, reason: m.name);
      }
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
        expect(i.de(m), InterruptorModulos.porDefecto.de(m), reason: m.name);
      }
    });

    test(
      'MODULOS_V2=recuperacion prueba la recuperacion v2 sin tocar el resto',
      () {
        final i = InterruptorModulos.desdeValores(v2: 'recuperacion');
        expect(i.esV2(ModuloMigrable.recuperacion), isTrue);
        expect(i.esV2(ModuloMigrable.acceso), isTrue);
      },
    );

    test('MODULOS_V1=acceso devuelve solo el acceso a la v1', () {
      final i = InterruptorModulos.desdeValores(v1: 'acceso');
      expect(i.esV2(ModuloMigrable.acceso), isFalse);
      expect(i.esV2(ModuloMigrable.citas), isTrue);
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
      final i = InterruptorModulos.desdeValores(v1: ' Citas ,, ');
      expect(i.esV2(ModuloMigrable.citas), isFalse);
      expect(i.esV2(ModuloMigrable.vehiculos), isTrue);
    });
  });

  group('rutas', () {
    final rutas = <RouteBase>[
      GoRoute(path: '/x', builder: (_, _) => const SizedBox()),
    ];

    test('en v1 el modulo no entrega rutas v2', () {
      expect(
        InterruptorModulos.todoV1.rutas(ModuloMigrable.citas, rutas),
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
