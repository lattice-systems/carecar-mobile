import 'dart:io';

import 'package:carecar_mobile/api/excepciones.dart';
import 'package:carecar_mobile/nucleo/conexion/senal_de_conexion.dart';
import 'package:carecar_mobile/nucleo/datos/repositorio_base.dart';
import 'package:flutter_test/flutter_test.dart';

/// V2-M21.04 · saber si estoy sin conexión.
///
/// La señal **no pregunta si hay wifi**: pregunta si la agencia contesta. Es
/// la diferencia que importa en el sótano del taller, donde el teléfono se ve
/// conectado y no llega nada.
///
/// Por eso se deduce de lo que ya pasa: cada llamada de repositorio pasa por
/// `RepositorioBase.pedir`, y ahí se sabe si hubo respuesta o no. Cero
/// dependencias nuevas, cero sondeos, cero batería.
void main() {
  late SenalDeConexion senal;

  setUp(() {
    senal = SenalDeConexion();
    SenalDeConexion.actual = senal;
  });

  tearDown(() => SenalDeConexion.actual = SenalDeConexion());

  test('nace en línea: no se asume lo peor sin motivo', () {
    expect(senal.sinConexion, isFalse);
  });

  test('una falla de red la pone sin conexión', () {
    senal.fallo(const SinConexion(null));
    expect(senal.sinConexion, isTrue);
  });

  test('una respuesta buena la devuelve a en línea', () {
    senal.fallo(const SinConexion(null));

    senal.acerto();

    expect(senal.sinConexion, isFalse);
  });

  test('un error del servidor NO es falta de conexión', () {
    // El servidor contestó: hay red. Decir «sin conexión» mandaría a la
    // persona a revisar su wifi por un problema que no es suyo.
    senal.fallo(const ErrorDelServidor('truena'));
    expect(senal.sinConexion, isFalse);
  });

  test('avisa solo cuando cambia, para no repintar de más', () {
    var avisos = 0;
    senal.addListener(() => avisos++);

    senal.fallo(const SinConexion(null));
    senal.fallo(const SinConexion(null));
    senal.fallo(const SinConexion(null));

    expect(avisos, 1);
  });

  group('enganchada a los repositorios', () {
    test('una llamada que truena por red la prende', () async {
      final repo = _RepositorioDePrueba();

      await expectLater(
        repo.traer(() => throw const SocketException('sin ruta')),
        throwsA(isA<SinConexion>()),
      );

      expect(senal.sinConexion, isTrue);
    });

    test('la siguiente llamada buena la apaga', () async {
      final repo = _RepositorioDePrueba();
      await expectLater(
        repo.traer(() => throw const SocketException('sin ruta')),
        throwsA(isA<SinConexion>()),
      );

      await repo.traer(() async => 'listo');

      expect(senal.sinConexion, isFalse);
    });

    test('un bug nuestro no se confunde con falta de red', () async {
      final repo = _RepositorioDePrueba();

      await expectLater(
        repo.traer(() => throw ArgumentError('bug')),
        throwsA(isA<ArgumentError>()),
      );

      expect(senal.sinConexion, isFalse);
    });
  });
}

class _RepositorioDePrueba with RepositorioBase {
  Future<T> traer<T>(Future<T> Function() hacer) => pedir(hacer);
}
