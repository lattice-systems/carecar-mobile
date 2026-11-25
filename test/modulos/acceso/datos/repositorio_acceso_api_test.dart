import 'package:carecar_mobile/api/excepciones.dart';
import 'package:carecar_mobile/api/modelos/problema.dart';
import 'package:carecar_mobile/modulos/acceso/datos/repositorio_acceso_api.dart';
import 'package:carecar_mobile/modulos/acceso/dominio/fallos_acceso.dart';
import 'package:carecar_mobile/nucleo/datos/fallo.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../ayudas/api_falsa.dart';
import '../../../ayudas/fallos_de_prueba.dart';

/// V2-M01.04 · el repositorio de acceso contra la API.
///
/// Traduce lo que el contrato dice en codigos a fallos que la pantalla
/// entiende. El caso con filo: **un enlace vencido o usado y una contrasena
/// que no cumple llegan los dos como 400**, y solo los separa
/// `Problema.codigo` (`CODIGO_INVALIDO` contra `DATOS_INVALIDOS`).
void main() {
  group('pedir el enlace', () {
    test('manda el correo al servidor', () async {
      final api = ApiFalsa();
      final repositorio = RepositorioAccesoApi(api);

      await repositorio.pedirEnlaceDeRecuperacion('cliente1@example.com');

      expect(api.llamadasAlRecuperar, 1);
      expect(api.ultimoCorreoDeRecuperacion, 'cliente1@example.com');
    });

    test('un correo que no existe termina igual de bien', () async {
      // El contrato responde 202 exista o no la cuenta, para no revelar que
      // correos hay registrados. El repositorio no debe inventar un error.
      final api = ApiFalsa();
      final repositorio = RepositorioAccesoApi(api);

      await expectLater(
        repositorio.pedirEnlaceDeRecuperacion('nadie@example.com'),
        completes,
      );
    });

    test('sin conexion sale tipado', () async {
      final api = ApiFalsa()
        ..alRecuperarContrasena = (_) async => throw const SinConexion();
      final repositorio = RepositorioAccesoApi(api);

      await expectLater(
        repositorio.pedirEnlaceDeRecuperacion('cliente1@example.com'),
        throwsA(isA<SinConexion>()),
      );
    });
  });

  group('restablecer con el enlace', () {
    test('manda el token y la contrasena nueva', () async {
      final api = ApiFalsa();
      final repositorio = RepositorioAccesoApi(api);

      await repositorio.restablecerConEnlace(
        token: 'abc123',
        contrasenaNueva: 'carecar2026',
      );

      expect(api.ultimoRestablecimiento?.token, 'abc123');
      expect(api.ultimoRestablecimiento?.contrasenaNueva, 'carecar2026');
      // La forma del enlace no manda correo ni codigo.
      expect(api.ultimoRestablecimiento?.correo, isNull);
      expect(api.ultimoRestablecimiento?.codigo, isNull);
    });

    test('un enlace vencido o usado se traduce a EnlaceNoValido', () async {
      final api = ApiFalsa()
        ..alRestablecerContrasena = (_) async => throw DatosInvalidos(
          'El enlace ya no sirve.',
          problema: problemaDePrueba(
            400,
            codigo: CodigoProblema.codigoInvalido,
          ),
        );
      final repositorio = RepositorioAccesoApi(api);

      await expectLater(
        repositorio.restablecerConEnlace(
          token: 'gastado',
          contrasenaNueva: 'carecar2026',
        ),
        throwsA(isA<EnlaceNoValido>()),
      );
    });

    test('una contrasena que no cumple NO se confunde con el enlace', () async {
      // Los dos son 400. Si se confundieran, la pantalla ofreceria «pide otro
      // enlace» cuando lo unico malo era la contrasena.
      final api = ApiFalsa()
        ..alRestablecerContrasena = (_) async => throw DatosInvalidos(
          'Revisa los datos.',
          problema: problemaDePrueba(
            400,
            codigo: CodigoProblema.datosInvalidos,
          ),
        );
      final repositorio = RepositorioAccesoApi(api);

      await expectLater(
        repositorio.restablecerConEnlace(
          token: 'abc123',
          contrasenaNueva: 'ab',
        ),
        throwsA(allOf(isA<DatosInvalidos>(), isNot(isA<EnlaceNoValido>()))),
      );
    });

    test('un 400 sin codigo tampoco se confunde con el enlace', () async {
      final api = ApiFalsa()
        ..alRestablecerContrasena = (_) async =>
            throw DatosInvalidos('Algo', problema: problemaDePrueba(400));
      final repositorio = RepositorioAccesoApi(api);

      await expectLater(
        repositorio.restablecerConEnlace(
          token: 'abc123',
          contrasenaNueva: 'carecar2026',
        ),
        throwsA(isNot(isA<EnlaceNoValido>())),
      );
    });
  });

  group('el fallo de dominio sobrevive a RepositorioBase', () {
    test('EnlaceNoValido no se convierte en error del servidor', () async {
      // `pedir` tipa todo lo que no sea `ExcepcionApi`, y un fallo de dominio
      // es una `Exception` normal: si la traduccion ocurriera **dentro** de
      // `pedir`, saldria convertido en `ErrorDelServidor` y la pantalla
      // perderia el unico dato que necesita. Por eso la traduccion va fuera.
      final api = ApiFalsa()
        ..alRestablecerContrasena = (_) async => throw DatosInvalidos(
          'El enlace ya no sirve.',
          problema: problemaDePrueba(
            400,
            codigo: CodigoProblema.codigoInvalido,
          ),
        );
      final repositorio = RepositorioAccesoApi(api);

      try {
        await repositorio.restablecerConEnlace(
          token: 'gastado',
          contrasenaNueva: 'carecar2026',
        );
        fail('debio lanzar');
      } on EnlaceNoValido {
        // Lo correcto.
      } on Fallo catch (fallo) {
        fail('se convirtio en ${fallo.runtimeType} y se perdio el motivo');
      }
    });

    test('lo que no se traduce si sale como Fallo tipado', () async {
      final api = ApiFalsa()
        ..alRestablecerContrasena = (_) async =>
            throw const FormatException('respuesta rara');
      final repositorio = RepositorioAccesoApi(api);

      await expectLater(
        repositorio.restablecerConEnlace(
          token: 'abc123',
          contrasenaNueva: 'carecar2026',
        ),
        throwsA(isA<Fallo>()),
      );
    });
  });
}
