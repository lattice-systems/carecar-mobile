import 'dart:async';
import 'dart:io';

import 'package:carecar_mobile/api/excepciones.dart';
import 'package:carecar_mobile/api/modelos/problema.dart';
import 'package:carecar_mobile/nucleo/datos/fallo.dart';
import 'package:flutter_test/flutter_test.dart';

/// V2-T01.08 · criterio 1: errores de API tipados desde el `Problema` del
/// contrato y los fallos de red.
///
/// El nucleo no inventa una taxonomia nueva: reutiliza la jerarquia sellada
/// `ExcepcionApi` de `lib/api`, que ya cubre los seis casos que pide la
/// historia. Lo que agrega es [falloDe], para que **nada** llegue a la vista
/// sin tipar, y las preguntas que hoy cada pantalla resuelve a mano.
void main() {
  Problema problema(int status, {CodigoProblema? codigo, String? message}) =>
      Problema(
        timestamp: '2026-11-23T20:00:00Z',
        status: status,
        error: 'Error',
        message: message ?? 'Mensaje del backend.',
        path: '/api/v1/app/vehiculos',
        codigo: codigo ?? CodigoProblema.desconocido,
      );

  group('los seis casos de la historia estan tipados', () {
    test('sin conexion', () {
      const fallo = SinConexion();
      expect(fallo, isA<Fallo>());
      expect(fallo.esSinConexion, isTrue);
      expect(fallo.esReintentable, isTrue);
      expect(fallo.sesionTerminada, isFalse);
    });

    test('sesion terminada: 401 y 403', () {
      final vencida = CredencialesInvalidas(
        'Tu sesión terminó. Inicia sesión de nuevo.',
        problema: problema(401, codigo: CodigoProblema.credencialesInvalidas),
      );
      final desactivada = CuentaDesactivada(
        'Tu cuenta está desactivada.',
        problema: problema(403, codigo: CodigoProblema.cuentaDesactivada),
      );

      expect(vencida.sesionTerminada, isTrue);
      expect(desactivada.sesionTerminada, isTrue);
      // Volver a pedir lo mismo con la misma sesion da el mismo error.
      expect(vencida.esReintentable, isFalse);
      expect(desactivada.esReintentable, isFalse);
    });

    test('no encontrado', () {
      final fallo = NoEncontrado(
        'No encontramos lo que buscas.',
        problema: problema(404),
      );
      expect(fallo.status, 404);
      expect(fallo.esReintentable, isFalse);
    });

    test('conflicto, que se distingue por su codigo', () {
      final sinCupo = Conflicto(
        'Esa franja ya no tiene lugar.',
        problema: problema(409, codigo: CodigoProblema.franjaSinCupo),
      );
      final fueraDePlazo = Conflicto(
        'Ya pasó el plazo.',
        problema: problema(409, codigo: CodigoProblema.fueraDePlazo),
      );

      // Los dos son 409: sin el codigo la app no podria separarlos (RIC-15).
      expect(sinCupo.codigo, CodigoProblema.franjaSinCupo);
      expect(fueraDePlazo.codigo, CodigoProblema.fueraDePlazo);
    });

    test('validacion', () {
      final fallo = DatosInvalidos(
        'Revisa los datos.',
        problema: problema(400, codigo: CodigoProblema.datosInvalidos),
      );
      expect(fallo.codigo, CodigoProblema.datosInvalidos);
      expect(fallo.esReintentable, isFalse);
    });

    test('servidor', () {
      final fallo = ErrorDelServidor(
        'Ocurrió un error inesperado. Intenta de nuevo más tarde.',
        problema: problema(500),
        status: 500,
      );
      expect(fallo.status, 500);
      // Un 5xx suele ser pasajero: ofrecer reintentar es lo correcto.
      expect(fallo.esReintentable, isTrue);
    });
  });

  group('el codigo nunca es nulo', () {
    test('sin problema del backend, es desconocido', () {
      expect(const SinConexion().codigo, CodigoProblema.desconocido);
    });

    test('cuando el backend no manda codigo, es desconocido', () {
      expect(
        NoEncontrado('No existe.', problema: problema(404)).codigo,
        CodigoProblema.desconocido,
      );
    });
  });

  group('falloDe normaliza lo que no viene tipado', () {
    test('una ExcepcionApi pasa tal cual, sin envolverse', () {
      const original = SinConexion();
      expect(falloDe(original), same(original));
    });

    test('un SocketException se convierte en sin conexion', () {
      final fallo = falloDe(const SocketException('falló el DNS'));
      expect(fallo, isA<SinConexion>());
      expect(fallo.esSinConexion, isTrue);
    });

    test('un TimeoutException se convierte en sin conexion', () {
      expect(falloDe(TimeoutException('tardó demasiado')), isA<SinConexion>());
    });

    test('cualquier otra cosa se convierte en error del servidor', () {
      final fallo = falloDe(ArgumentError('un bug nuestro'));
      expect(fallo, isA<ErrorDelServidor>());
      expect(fallo.esReintentable, isTrue);
    });

    test(
      'el mensaje de un error desconocido se le puede mostrar al usuario',
      () {
        // Nunca se filtra el texto del error tecnico: diria «Invalid argument».
        final fallo = falloDe(
          ArgumentError('contrasenaNueva: must not be null'),
        );
        expect(fallo.mensaje, isNot(contains('contrasenaNueva')));
        expect(fallo.mensaje, isNot(isEmpty));
      },
    );
  });
}
