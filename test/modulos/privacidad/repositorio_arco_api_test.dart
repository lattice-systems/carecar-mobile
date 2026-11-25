import 'dart:convert';
import 'dart:typed_data';

import 'package:carecar_mobile/api/excepciones.dart';
import 'package:carecar_mobile/api/modelos/modelos.dart';
import 'package:carecar_mobile/modulos/privacidad/datos/repositorio_arco_api.dart';
import 'package:carecar_mobile/modulos/privacidad/dominio/arco.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../ayudas/api_falsa.dart';

SolicitudArco _api(
  int id,
  String estado, {
  String tipo = 'ACCESO',
  DateTime? creada,
  DateTime? resuelta,
  DateTime? vence,
}) => SolicitudArco(
  id: id,
  tipo: tipo,
  estado: estado,
  creadaEn: creada ?? DateTime.utc(2026, 11, 25, 18),
  resueltaEn: resuelta,
  venceEn: vence,
);

void main() {
  group('SolicitudDeArco (V2-M22.02)', () {
    SolicitudDeArco de(TipoArco tipo, EstadoArco estado) => SolicitudDeArco(
      id: 1,
      tipo: tipo,
      estado: estado,
      creadaEn: DateTime.utc(2026, 11, 25),
    );

    test('solo un acceso resuelto tiene archivo que descargar', () {
      for (final tipo in TipoArco.values) {
        for (final estado in EstadoArco.values) {
          expect(
            de(tipo, estado).puedeDescargar,
            tipo == TipoArco.acceso && estado == EstadoArco.resuelta,
            reason: '$tipo $estado',
          );
        }
      }
    });
  });

  group('RepositorioArcoApi (V2-M22.02)', () {
    test('lista las solicitudes con su tipo y su estado', () async {
      final api = ApiFalsa()
        ..alPedirSolicitudesArco = () async => [
          _api(
            4,
            'RESUELTA',
            resuelta: DateTime.utc(2026, 11, 25, 18, 0, 2),
            vence: DateTime.utc(2026, 12, 2, 18, 0, 2),
          ),
          _api(3, 'PENDIENTE'),
          _api(2, 'FALLIDA'),
          _api(1, 'VENCIDA'),
        ];

      final lista = await RepositorioArcoApi(api).solicitudes();

      expect(lista.map((s) => s.id), [4, 3, 2, 1]);
      expect(lista.map((s) => s.estado), [
        EstadoArco.resuelta,
        EstadoArco.pendiente,
        EstadoArco.fallida,
        EstadoArco.vencida,
      ]);
      expect(lista.first.tipo, TipoArco.acceso);
      expect(lista.first.resueltaEn, DateTime.utc(2026, 11, 25, 18, 0, 2));
      expect(lista.first.venceEn, DateTime.utc(2026, 12, 2, 18, 0, 2));
    });

    test('lee los cuatro tipos de derecho', () async {
      final api = ApiFalsa()
        ..alPedirSolicitudesArco = () async => [
          _api(1, 'RESUELTA', tipo: 'ACCESO'),
          _api(2, 'RESUELTA', tipo: 'RECTIFICACION'),
          _api(3, 'RESUELTA', tipo: 'CANCELACION'),
          _api(4, 'RESUELTA', tipo: 'OPOSICION'),
        ];

      final lista = await RepositorioArcoApi(api).solicitudes();

      expect(lista.map((s) => s.tipo), TipoArco.values);
    });

    test('un tipo o un estado que la app no conoce no la tumba', () async {
      final api = ApiFalsa()
        ..alPedirSolicitudesArco = () async => [
          _api(1, 'ESTADO_NUEVO'),
          _api(2, 'RESUELTA', tipo: 'PORTABILIDAD'),
        ];

      final lista = await RepositorioArcoApi(api).solicitudes();

      // El estado raro se trata como fallido (se puede volver a pedir); el
      // tipo raro se descarta: la app solo sabe mostrar los suyos.
      expect(lista.map((s) => s.id), [1]);
      expect(lista.single.estado, EstadoArco.fallida);
    });

    test('pide el acceso y devuelve la solicitud pendiente', () async {
      final api = ApiFalsa()
        ..alPedirAccesoArco = () async => _api(7, 'PENDIENTE');

      final s = await RepositorioArcoApi(api).pedirAcceso();

      expect(s.id, 7);
      expect(s.estado, EstadoArco.pendiente);
      expect(s.tipo, TipoArco.acceso);
    });

    test('descarga el archivo de esa solicitud', () async {
      int? pedido;
      final api = ApiFalsa()
        ..alDescargarArchivoArco = (id) async {
          pedido = id;
          return Uint8List.fromList(utf8.encode('{"cliente":{}}'));
        };

      final bytes = await RepositorioArcoApi(api).descargar(4);

      expect(pedido, 4);
      expect(utf8.decode(bytes), '{"cliente":{}}');
    });

    test('traduce los errores de cada operacion', () async {
      Future<FalloArco> fallo(
        Future<void> Function(RepositorioArcoApi) f,
      ) async {
        try {
          await f(RepositorioArcoApi(ApiFalsa()));
        } on FalloArco catch (e) {
          return e;
        }
        fail('no fallo');
      }

      Future<FalloArco> alPedir(Object error) => fallo((r) async {
        final api = ApiFalsa()..alPedirAccesoArco = () => Future.error(error);
        await RepositorioArcoApi(api).pedirAcceso();
      });
      Future<FalloArco> alDescargar(Object error) => fallo((r) async {
        final api = ApiFalsa()
          ..alDescargarArchivoArco = (_) => Future.error(error);
        await RepositorioArcoApi(api).descargar(4);
      });
      Future<FalloArco> alListar(Object error) => fallo((r) async {
        final api = ApiFalsa()
          ..alPedirSolicitudesArco = () => Future.error(error);
        await RepositorioArcoApi(api).solicitudes();
      });

      expect(await alPedir(const SinConexion()), isA<ArcoSinConexion>());
      expect(await alListar(const SinConexion()), isA<ArcoSinConexion>());
      expect(await alDescargar(const SinConexion()), isA<ArcoSinConexion>());
      // 404: no es de esta cuenta, no esta lista o ya vencio.
      expect(
        await alDescargar(const NoEncontrado('no existe')),
        isA<ArchivoArcoNoDisponible>(),
      );
      expect(
        await alPedir(const ErrorDelServidor('x')),
        isA<ArcoNoDisponible>(),
      );
      expect(
        await alDescargar(const ErrorDelServidor('x')),
        isA<ArcoNoDisponible>(),
      );
      // Un 404 al pedir o listar no es «archivo no disponible».
      expect(
        await alPedir(const NoEncontrado('no existe')),
        isA<ArcoNoDisponible>(),
      );
    });
  });

  group('RepositorioArcoApi.cancelarCuenta (V2-M22.03)', () {
    Future<FalloArco> fallo(Object error) async {
      final api = ApiFalsa()..alCancelarCuentaArco = (_) => Future.error(error);
      try {
        await RepositorioArcoApi(api).cancelarCuenta('Secreta123');
      } on FalloArco catch (f) {
        return f;
      }
      fail('Debio fallar con un FalloArco');
    }

    test('pide la cancelacion con la contrasena y termina', () async {
      final recibidas = <String>[];
      final api = ApiFalsa()
        ..alCancelarCuentaArco = (contrasena) async {
          recibidas.add(contrasena);
          return _api(9, 'RESUELTA', tipo: 'CANCELACION');
        };

      await RepositorioArcoApi(api).cancelarCuenta('Secreta123');

      expect(recibidas, ['Secreta123']);
    });

    test('una contrasena equivocada (400) no borra nada y se dice', () async {
      expect(
        await fallo(const DatosInvalidos('La contraseña no es correcta')),
        isA<ContrasenaIncorrecta>(),
      );
    });

    test('el bloqueo (429) trae cuanto esperar', () async {
      final f = await fallo(
        const DemasiadosIntentos('bloqueada', esperaSegundos: 900),
      );

      expect(f, isA<CancelacionBloqueada>());
      expect((f as CancelacionBloqueada).espera, const Duration(minutes: 15));
    });

    test('un bloqueo sin Retry-After no inventa un tiempo', () async {
      for (final segundos in [null, 0, -3]) {
        final f = await fallo(
          DemasiadosIntentos('bloqueada', esperaSegundos: segundos),
        );

        expect(f, isA<CancelacionBloqueada>(), reason: '$segundos');
        expect((f as CancelacionBloqueada).espera, isNull, reason: '$segundos');
      }
    });

    test('una cuenta que ya estaba cerrada (403) no es un error', () async {
      expect(
        await fallo(const CuentaDesactivada('desactivada')),
        isA<CuentaYaCerrada>(),
      );
    });

    test('sin red es ArcoSinConexion y lo demas, ArcoNoDisponible', () async {
      expect(await fallo(const SinConexion()), isA<ArcoSinConexion>());
      expect(await fallo(const ErrorDelServidor('x')), isA<ArcoNoDisponible>());
      expect(
        await fallo(const CredencialesInvalidas('vencida')),
        isA<ArcoNoDisponible>(),
      );
      expect(
        await fallo(const NoEncontrado('no existe')),
        isA<ArcoNoDisponible>(),
      );
    });
  });
}
