import 'package:carecar_mobile/api/excepciones.dart';
import 'package:carecar_mobile/api/modelos/problema.dart';
import 'package:carecar_mobile/nucleo/datos/fallo.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fallos_de_prueba.dart';
import 'repositorio_falso.dart';

/// V2-T01.08 · criterio 4: fakes reutilizables con latencia y fallo a pedido.
///
/// Se prueban porque tienen logica propia. Un fake que miente —que no falla
/// cuando se le pide, o que responde al instante cuando se le pidio latencia—
/// hace que las pruebas de los modulos pasen por la razon equivocada.
void main() {
  group('responde con lo que tiene', () {
    test('devuelve el valor', () async {
      final repositorio = RepositorioFalso(['uno', 'dos']);
      expect(await repositorio.leer(), ['uno', 'dos']);
    });

    test('cuenta las llamadas', () async {
      final repositorio = RepositorioFalso('x');
      await repositorio.leer();
      await repositorio.leer();
      expect(repositorio.llamadas, 2);
    });

    test(
      'el valor se puede cambiar entre llamadas, como una recarga',
      () async {
        final repositorio = RepositorioFalso(['uno']);
        expect(await repositorio.leer(), ['uno']);

        repositorio.valor = ['uno', 'dos'];
        expect(await repositorio.leer(), ['uno', 'dos']);
      },
    );
  });

  group('latencia', () {
    test('sin latencia responde de inmediato', () async {
      final repositorio = RepositorioFalso('x');
      expect(repositorio.latencia, Duration.zero);
      expect(await repositorio.leer(), 'x');
    });

    test('con latencia, algo mas rapido termina antes', () async {
      final repositorio = RepositorioFalso(
        'x',
        latencia: const Duration(milliseconds: 60),
      );

      final orden = <String>[];
      final lectura = repositorio.leer().then((_) => orden.add('lectura'));
      await Future<void>.delayed(
        const Duration(milliseconds: 10),
        () => orden.add('mientras tanto'),
      );
      await lectura;

      // Es lo que hace util la latencia: deja ver el esqueleto y probar que
      // una pantalla no parpadea.
      expect(orden, ['mientras tanto', 'lectura']);
    });
  });

  group('fallo a pedido', () {
    test('falla siempre con el fallo que se le dio', () async {
      final repositorio = RepositorioFalso('x', falla: Fallos.sinConexion());

      await expectLater(repositorio.leer(), throwsA(isA<SinConexion>()));
      await expectLater(repositorio.leer(), throwsA(isA<SinConexion>()));
    });

    test('fallarUnaVez falla la primera y despues funciona', () async {
      // Es el caso de «Reintentar»: falla, el usuario toca el boton y entra.
      final repositorio = RepositorioFalso('x')
        ..fallarUnaVez(Fallos.servidor());

      await expectLater(repositorio.leer(), throwsA(isA<ErrorDelServidor>()));
      expect(await repositorio.leer(), 'x');
    });

    test('dejar de fallar vuelve a responder', () async {
      final repositorio = RepositorioFalso('x', falla: Fallos.servidor());
      await expectLater(repositorio.leer(), throwsA(isA<Fallo>()));

      repositorio.falla = null;
      expect(await repositorio.leer(), 'x');
    });
  });

  group('se comporta como un repositorio de verdad', () {
    test('una excepcion sin tipar sale convertida en Fallo', () async {
      // Usa la misma base que los repositorios reales, asi que una prueba no
      // puede ver un error sin tipar que en produccion si vendria tipado.
      final repositorio = RepositorioFalso<String>('x')
        ..reventarUnaVez(const FormatException('no es un entero'));

      await expectLater(repositorio.leer(), throwsA(isA<Fallo>()));
    });

    test(
      'un Error se propaga tal cual, como en los repositorios reales',
      () async {
        final repositorio = RepositorioFalso<String>('x')
          ..reventarUnaVez(ArgumentError('un bug del mapeo'));

        await expectLater(repositorio.leer(), throwsA(isA<ArgumentError>()));
      },
    );
  });

  group('los fallos de prueba cubren los tipos del contrato', () {
    test('cada constructor da el tipo que dice', () {
      expect(Fallos.sinConexion(), isA<SinConexion>());
      expect(Fallos.sesionTerminada(), isA<CredencialesInvalidas>());
      expect(Fallos.cuentaDesactivada(), isA<CuentaDesactivada>());
      expect(Fallos.noEncontrado(), isA<NoEncontrado>());
      expect(Fallos.validacion(), isA<DatosInvalidos>());
      expect(Fallos.servidor(), isA<ErrorDelServidor>());
      expect(Fallos.demasiadosIntentos(), isA<DemasiadosIntentos>());
    });

    test('el conflicto lleva su codigo, que es con lo que se distingue', () {
      final fallo = Fallos.conflicto(CodigoProblema.franjaSinCupo);
      expect(fallo, isA<Conflicto>());
      expect(fallo.codigo, CodigoProblema.franjaSinCupo);
    });

    test('la espera del 429 llega legible a la pantalla', () {
      final fallo =
          Fallos.demasiadosIntentos(esperaSegundos: 900) as DemasiadosIntentos;
      expect(fallo.esperaLegible, '15 minutos');
    });

    test('los que traen Problema traen su status', () {
      expect(Fallos.noEncontrado().status, 404);
      expect(Fallos.validacion().status, 400);
      expect(Fallos.servidor().status, 500);
      // Sin conexion nunca tuvo respuesta, asi que no hay status.
      expect(Fallos.sinConexion().status, isNull);
    });
  });
}
