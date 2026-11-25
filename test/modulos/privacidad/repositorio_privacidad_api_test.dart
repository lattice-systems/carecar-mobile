import 'package:carecar_mobile/api/excepciones.dart';
import 'package:carecar_mobile/api/modelos/modelos.dart';
import 'package:carecar_mobile/modulos/privacidad/datos/repositorio_privacidad_api.dart';
import 'package:carecar_mobile/modulos/privacidad/dominio/privacidad.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../ayudas/api_falsa.dart';

Problema _problema(String codigo, int status) => Problema.fromJson({
  'timestamp': '2026-11-25T18:00:00Z',
  'status': status,
  'error': 'x',
  'message': 'x',
  'path': '/api/v1/app/privacidad/aceptaciones',
  'codigo': codigo,
});

final _aviso = AvisoPrivacidad(
  id: 3,
  version: 2,
  texto: 'Primero.\n\nSegundo.\n\n\nTercero.\n  \nCuarto.',
  vigenteDesde: DateTime.utc(2026, 11, 25, 18),
  aceptado: false,
);

/// Lo que falla al aceptar cuando el servidor responde [error].
Future<FalloPrivacidad> _falloAlAceptar(Object error) async {
  final api = ApiFalsa()
    ..alAceptarAvisoDePrivacidad = (_) => Future.error(error);
  try {
    await RepositorioPrivacidadApi(api).aceptar(3);
  } on FalloPrivacidad catch (f) {
    return f;
  }
  fail('no fallo');
}

void main() {
  group('RepositorioPrivacidadApi (V2-M22.01)', () {
    test('lee el aviso vigente sin aceptar', () async {
      final api = ApiFalsa()..alPedirAvisoDePrivacidad = () async => _aviso;

      final aviso = await RepositorioPrivacidadApi(api).avisoVigente();

      expect(aviso.id, 3);
      expect(aviso.version, 2);
      expect(aviso.vigenteDesde, DateTime.utc(2026, 11, 25, 18));
      expect(aviso.aceptado, isFalse);
      expect(aviso.aceptadoEn, isNull);
    });

    test('lee cuando lo acepto', () async {
      final api = ApiFalsa()
        ..alPedirAvisoDePrivacidad = () async => AvisoPrivacidad(
          id: 3,
          version: 2,
          texto: 'Texto.',
          vigenteDesde: DateTime.utc(2026, 11, 25, 18),
          aceptado: true,
          aceptadoEn: DateTime.utc(2026, 11, 26, 9),
        );

      final aviso = await RepositorioPrivacidadApi(api).avisoVigente();

      expect(aviso.aceptado, isTrue);
      expect(aviso.aceptadoEn, DateTime.utc(2026, 11, 26, 9));
    });

    test(
      'parte el texto en parrafos y descarta las lineas en blanco',
      () async {
        final api = ApiFalsa()..alPedirAvisoDePrivacidad = () async => _aviso;

        final aviso = await RepositorioPrivacidadApi(api).avisoVigente();

        expect(aviso.parrafos, ['Primero.', 'Segundo.', 'Tercero.', 'Cuarto.']);
      },
    );

    test('acepta el aviso con su id', () async {
      int? enviado;
      final api = ApiFalsa()
        ..alAceptarAvisoDePrivacidad = (id) async {
          enviado = id;
          return AceptacionAviso(
            avisoId: id,
            version: 2,
            aceptadoEn: DateTime.utc(2026, 11, 26, 9),
          );
        };

      await RepositorioPrivacidadApi(api).aceptar(3);

      expect(enviado, 3);
    });

    test('traduce los errores por su codigo, no por el texto', () async {
      expect(
        await _falloAlAceptar(
          Conflicto('x', problema: _problema('AVISO_NO_VIGENTE', 409)),
        ),
        isA<AvisoNoVigente>(),
      );
      expect(
        await _falloAlAceptar(Conflicto('Hay un aviso más reciente')),
        isA<PrivacidadNoDisponible>(),
        reason: 'un 409 sin codigo no es AVISO_NO_VIGENTE',
      );
      expect(
        await _falloAlAceptar(const SinConexion()),
        isA<PrivacidadSinConexion>(),
      );
      expect(
        await _falloAlAceptar(const NoEncontrado('no existe')),
        isA<PrivacidadNoDisponible>(),
      );
    });

    test(
      'al leer, la falta de conexion y los demas errores se distinguen',
      () async {
        for (final (error, esperado) in <(Object, Matcher)>[
          (const SinConexion(), isA<PrivacidadSinConexion>()),
          (const NoEncontrado('no existe'), isA<PrivacidadNoDisponible>()),
          (StateError('raro'), isA<StateError>()),
        ]) {
          final api = ApiFalsa()
            ..alPedirAvisoDePrivacidad = () => Future.error(error);
          await expectLater(
            RepositorioPrivacidadApi(api).avisoVigente(),
            throwsA(esperado),
          );
        }
      },
    );
  });
}
