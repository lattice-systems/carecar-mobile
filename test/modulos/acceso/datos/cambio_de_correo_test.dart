import 'package:carecar_mobile/api/excepciones.dart';
import 'package:carecar_mobile/api/modelos/problema.dart';
import 'package:carecar_mobile/modulos/acceso/datos/repositorio_acceso_api.dart';
import 'package:carecar_mobile/modulos/acceso/dominio/cambio_de_correo_pendiente.dart';
import 'package:carecar_mobile/modulos/acceso/dominio/fallos_acceso.dart';
import 'package:carecar_mobile/nucleo/datos/fallo.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../ayudas/api_falsa.dart';
import '../../../ayudas/fallos_de_prueba.dart';

/// V2-M01.07 · el repositorio traduce los errores del cambio de correo.
///
/// Aquí está el filo de la historia: **la contraseña equivocada y el correo mal
/// escrito llegan los dos como 400** y solo los separa `Problema.codigo`. Si se
/// confundieran, la pantalla culparía al correo cuando lo que falló fue la
/// contraseña, y la persona corregiría lo que estaba bien.
void main() {
  group('pedir el cambio', () {
    test('devuelve la verificacion pendiente', () async {
      final api = ApiFalsa();

      final pendiente = await RepositorioAccesoApi(api).pedirCambioDeCorreo(
        correo: 'nuevo@example.com',
        contrasenaActual: 'CareCar2026',
      );

      expect(pendiente.id, 12);
      expect(api.ultimoCorreoPedido, 'nuevo@example.com');
      expect(api.ultimaContrasenaDelCambio, 'CareCar2026');
    });

    test('la contrasena equivocada sale como ContrasenaNoCoincide', () async {
      final api = ApiFalsa()
        ..alPedirCambioDeCorreo = (_, _) async => throw DatosInvalidos(
          'La contrasena no coincide',
          problema: problemaDePrueba(
            400,
            codigo: CodigoProblema.credencialesInvalidas,
          ),
        );

      await expectLater(
        RepositorioAccesoApi(api).pedirCambioDeCorreo(
          correo: 'nuevo@example.com',
          contrasenaActual: 'mala',
        ),
        throwsA(isA<ContrasenaNoCoincide>()),
      );
    });

    test('un correo mal escrito NO se confunde con la contrasena', () async {
      // Mismo 400, otro codigo. Es la razón de ser de esta traducción.
      final api = ApiFalsa()
        ..alPedirCambioDeCorreo = (_, _) async => throw DatosInvalidos(
          'Ese correo no tiene formato valido',
          problema: problemaDePrueba(
            400,
            codigo: CodigoProblema.datosInvalidos,
          ),
        );

      await expectLater(
        RepositorioAccesoApi(api).pedirCambioDeCorreo(
          correo: 'no-es-correo',
          contrasenaActual: 'CareCar2026',
        ),
        throwsA(allOf(isA<Fallo>(), isNot(isA<ContrasenaNoCoincide>()))),
      );
    });

    test('un correo de otro cliente sale como CorreoEnUso', () async {
      final api = ApiFalsa()
        ..alPedirCambioDeCorreo = (_, _) async =>
            throw const Conflicto('Ese correo ya es de otro cliente');

      await expectLater(
        RepositorioAccesoApi(api).pedirCambioDeCorreo(
          correo: 'cliente2@example.com',
          contrasenaActual: 'CareCar2026',
        ),
        throwsA(isA<CorreoEnUso>()),
      );
    });

    test(
      'sin conexion sale como Fallo tipado, no como fallo del correo',
      () async {
        final api = ApiFalsa()
          ..alPedirCambioDeCorreo = (_, _) async => throw Fallos.sinConexion();

        await expectLater(
          RepositorioAccesoApi(api).pedirCambioDeCorreo(
            correo: 'nuevo@example.com',
            contrasenaActual: 'CareCar2026',
          ),
          throwsA(
            isA<Fallo>().having(
              (f) => f.esSinConexion,
              'esSinConexion',
              isTrue,
            ),
          ),
        );
      },
    );
  });

  group('confirmar', () {
    test('devuelve el perfil con el correo nuevo', () async {
      final api = ApiFalsa();
      final repositorio = RepositorioAccesoApi(api);
      await repositorio.pedirCambioDeCorreo(
        correo: 'maria.nueva@example.com',
        contrasenaActual: 'CareCar2026',
      );

      final perfil = await repositorio.confirmarCambioDeCorreo(
        id: 12,
        codigo: '123456',
      );

      expect(perfil.correo, 'maria.nueva@example.com');
      expect(api.ultimaVerificacionConfirmada, 12);
      expect(api.ultimoCodigoDeVerificacion, '123456');
    });

    test('un codigo equivocado, usado o vencido sale igual', () async {
      // El contrato no los distingue a proposito: responder distinto
      // permitiria averiguar que codigos existen. La salida es la misma en los
      // tres casos, pedir otro.
      final api = ApiFalsa()
        ..alConfirmarVerificacion = (_, _) async => throw DatosInvalidos(
          'El codigo no es valido, ya se uso o vencio',
          problema: problemaDePrueba(
            400,
            codigo: CodigoProblema.codigoInvalido,
          ),
        );

      await expectLater(
        RepositorioAccesoApi(api)
            .confirmarCambioDeCorreo(id: 12, codigo: '000000'),
        throwsA(isA<CodigoNoValido>()),
      );
    });

    test('si alguien tomo el correo mientras tanto, CorreoEnUso', () async {
      final api = ApiFalsa()
        ..alConfirmarVerificacion = (_, _) async =>
            throw const Conflicto('Ese correo ya es de otro cliente');

      await expectLater(
        RepositorioAccesoApi(api)
            .confirmarCambioDeCorreo(id: 12, codigo: '123456'),
        throwsA(isA<CorreoEnUso>()),
      );
    });
  });

  group('la verificacion pendiente', () {
    test('sabe si ya vencio', () {
      final ahora = DateTime.utc(2026, 11, 26, 21, 40);
      final viva = CambioDeCorreoPendiente(
        id: 1,
        expira: ahora.add(const Duration(minutes: 1)),
      );
      final vencida = CambioDeCorreoPendiente(
        id: 2,
        expira: ahora.subtract(const Duration(seconds: 1)),
      );

      expect(viva.yaVencio(ahora), isFalse);
      // Sirve para no mandar un codigo condenado y poder ofrecer pedir otro.
      expect(vencida.yaVencio(ahora), isTrue);
    });
  });
}
