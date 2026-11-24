import 'dart:io';

import 'package:carecar_mobile/api/excepciones.dart';
import 'package:carecar_mobile/nucleo/datos/fallo.dart';
import 'package:carecar_mobile/nucleo/datos/repositorio_base.dart';
import 'package:flutter_test/flutter_test.dart';

/// V2-T01.08 · criterio 2: una base de repositorio que convierte cada llamada
/// en datos o en un [Fallo].
///
/// El hueco que cierra: hoy los repositorios de los modulos dejan pasar las
/// `ExcepcionApi` del cliente, que ya vienen tipadas, pero **nada protege el
/// resto de la llamada**. Si el mapeo del DTO revienta con un `TypeError`
/// porque el backend cambio un campo, eso llega a la vista sin tipar y la
/// pantalla lo pinta como «error generico». Con la base, lo que sale de un
/// repositorio es dato o es [Fallo]; no hay tercera opcion.
class _RepositorioDePrueba with RepositorioBase {
  Future<T> llamar<T>(Future<T> Function() hacer) => pedir(hacer);
}

void main() {
  final repositorio = _RepositorioDePrueba();

  group('cuando la llamada funciona', () {
    test('devuelve los datos sin tocarlos', () async {
      final datos = await repositorio.llamar(() async => ['uno', 'dos']);
      expect(datos, ['uno', 'dos']);
    });

    test('respeta el tipo, incluido uno que puede ser nulo', () async {
      final nada = await repositorio.llamar<String?>(() async => null);
      expect(nada, isNull);
    });
  });

  group('cuando la llamada falla', () {
    test('una ExcepcionApi sale tal cual, sin envolverse', () async {
      const original = NoEncontrado('No existe.');
      await expectLater(
        repositorio.llamar<void>(() async => throw original),
        throwsA(same(original)),
      );
    });

    test(
      'una excepcion sin tipar sale como Fallo, no como la original',
      () async {
        await expectLater(
          repositorio.llamar<void>(
            // El caso real: el mapeo del DTO no pudo leer un numero.
            () async => throw const FormatException('no es un entero'),
          ),
          throwsA(isA<Fallo>()),
        );
      },
    );

    test(
      'un Error se propaga tal cual: es un bug, no una falla prevista',
      () async {
        // Convertirlo tendria dos costos: el reporte de fallos veria «error del
        // servidor» en vez del tipo real, y Riverpod —que no reintenta los
        // `Error` pero si las `Exception`— ejecutaria el bug cuatro veces.
        await expectLater(
          repositorio.llamar<void>(() async => throw TypeError()),
          throwsA(isA<TypeError>()),
        );
      },
    );

    test('una falla de red sin tipar sale como sin conexion', () async {
      await expectLater(
        repositorio.llamar<void>(
          () async => throw const SocketException('sin ruta al servidor'),
        ),
        throwsA(isA<SinConexion>()),
      );
    });

    test('el detalle tecnico no se filtra al usuario', () async {
      try {
        await repositorio.llamar<void>(
          () async =>
              throw const FormatException('contrasenaNueva no es un entero'),
        );
        fail('debio lanzar');
      } on Fallo catch (fallo) {
        expect(fallo.mensaje, isNot(contains('contrasenaNueva')));
      }
    });

    test('no envuelve dos veces: un Fallo ya convertido pasa igual', () async {
      // Un repositorio que llama a otro no debe apilar conversiones.
      const original = SinConexion();
      await expectLater(
        repositorio.llamar<void>(
          () => repositorio.llamar<void>(() async => throw original),
        ),
        throwsA(same(original)),
      );
    });
  });

  group('el rastro del error se conserva', () {
    test('la pila apunta a donde reviento, no a la base', () async {
      StackTrace? pila;
      try {
        await repositorio.llamar<void>(() async => throw _reventar());
      } on Fallo catch (_, s) {
        pila = s;
      }

      // Sin preservar la pila, depurar un TypeError del mapeo seria imposible:
      // todas las fallas apuntarian a la misma linea de repositorio_base.
      expect(pila, isNotNull);
      expect(pila.toString(), contains('_reventar'));
    });
  });

  group('se puede adoptar sin cambiar el repositorio', () {
    test('un repositorio con constructor const puede usar el mixin', () async {
      // Importa de verdad: los repositorios que ya existen son `const`
      // (`RepositorioCatalogoApi`, por ejemplo), asi que adoptar la base no
      // les obliga a dejar de serlo. El mixin no declara campos.
      const repositorio = _RepositorioConst('ok');
      expect(await repositorio.leer(), 'ok');
    });
  });
}

class _RepositorioConst with RepositorioBase {
  const _RepositorioConst(this.dato);

  final String dato;

  Future<String> leer() => pedir(() async => dato);
}

Never _reventar() => throw const FormatException('revento aqui');
