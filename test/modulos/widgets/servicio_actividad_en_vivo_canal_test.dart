import 'package:carecar_mobile/modulos/widgets/datos/servicio_actividad_en_vivo_canal.dart';
import 'package:carecar_mobile/modulos/widgets/datos/servicio_actividad_en_vivo_nulo.dart';
import 'package:carecar_mobile/modulos/widgets/dominio/actividad_en_vivo.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const _metodos = MethodChannel(ServicioActividadEnVivoCanal.nombreCanal);
const _eventos = EventChannel(ServicioActividadEnVivoCanal.nombreCanalTokens);

const _estado = EstadoDeActividad(
  etapa: 'EN_REPARACION',
  estatus: 'EN_PROCESO',
  avance: 43,
  adicionalesPendientes: 1,
  entregaEstimada: 1795392000,
);

TestDefaultBinaryMessenger get _mensajero =>
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    _mensajero.setMockMethodCallHandler(_metodos, null);
    _mensajero.setMockStreamHandler(_eventos, null);
  });

  group('sin el puente nativo enlazado', () {
    test('no esta disponible y nada lanza', () async {
      final servicio = ServicioActividadEnVivoCanal();

      expect(await servicio.disponible(), isFalse);
      expect(await servicio.iniciar(41, _estado), isFalse);
      await servicio.actualizar(41, _estado);
      await servicio.terminar(41, estadoFinal: _estado.entregada());
      await servicio.terminarTodas();
      expect(await servicio.activas(), isEmpty);
      expect(await servicio.tokensDe(41).toList(), isEmpty);
    });

    test('un error de la plataforma tambien es «no disponible»', () async {
      _mensajero.setMockMethodCallHandler(
        _metodos,
        (_) async => throw PlatformException(code: 'ACTIVIDADES_APAGADAS'),
      );
      final servicio = ServicioActividadEnVivoCanal();

      expect(await servicio.disponible(), isFalse);
      expect(await servicio.iniciar(41, _estado), isFalse);
      expect(await servicio.activas(), isEmpty);
    });

    test('sin confirmar que hay puente no escucha los tokens', () async {
      var escuchado = false;
      _mensajero.setMockStreamHandler(
        _eventos,
        MockStreamHandler.inline(onListen: (_, _) => escuchado = true),
      );
      final servicio = ServicioActividadEnVivoCanal();

      expect(await servicio.tokensDe(41).toList(), isEmpty);
      expect(escuchado, isFalse);
    });
  });

  group('con el puente nativo', () {
    late List<MethodCall> llamadas;

    setUp(() {
      llamadas = [];
      _mensajero.setMockMethodCallHandler(_metodos, (llamada) async {
        llamadas.add(llamada);
        return switch (llamada.method) {
          'disponible' => true,
          'iniciar' => true,
          'activas' => <Object?>[41, 7],
          _ => null,
        };
      });
    });

    test('inicia la actividad con la orden y el content-state', () async {
      final servicio = ServicioActividadEnVivoCanal();

      expect(await servicio.disponible(), isTrue);
      expect(await servicio.iniciar(41, _estado), isTrue);

      final iniciar = llamadas.last;
      expect(iniciar.method, 'iniciar');
      expect(iniciar.arguments, {
        'ordenId': 41,
        'estado': {
          'etapa': 'EN_REPARACION',
          'estatus': 'EN_PROCESO',
          'avance': 43,
          'adicionalesPendientes': 1,
          'entregaEstimada': 1795392000,
        },
      });
    });

    test('actualiza, termina y termina todas por el mismo canal', () async {
      final servicio = ServicioActividadEnVivoCanal();

      await servicio.actualizar(41, _estado);
      await servicio.terminar(41, estadoFinal: _estado.entregada());
      await servicio.terminar(7);
      await servicio.terminarTodas();

      expect(llamadas.map((l) => l.method), [
        'actualizar',
        'terminar',
        'terminar',
        'terminarTodas',
      ]);
      expect(llamadas[0].arguments, {
        'ordenId': 41,
        'estado': _estado.comoContentState(),
      });
      expect(
        (llamadas[1].arguments as Map)['estado'],
        _estado.entregada().comoContentState(),
      );
      expect(llamadas[2].arguments, {'ordenId': 7});
    });

    test('lee las ordenes con actividad viva', () async {
      expect(await ServicioActividadEnVivoCanal().activas(), [41, 7]);
    });

    test('da solo los tokens validos de la orden pedida', () async {
      _mensajero.setMockStreamHandler(
        _eventos,
        MockStreamHandler.inline(
          onListen: (_, eventos) {
            eventos
              ..success({'ordenId': 41, 'pushToken': 'aabb'})
              ..success({'ordenId': 7, 'pushToken': 'ccdd'})
              ..success({'ordenId': 41, 'pushToken': 'no-es-hex'})
              ..success('basura')
              ..success({'ordenId': 41, 'pushToken': 'EEFF'})
              ..endOfStream();
          },
        ),
      );
      final servicio = ServicioActividadEnVivoCanal();
      await servicio.disponible();

      expect(await servicio.tokensDe(41).toList(), ['aabb', 'EEFF']);
    });

    test('un error en el flujo de tokens no sube', () async {
      _mensajero.setMockStreamHandler(
        _eventos,
        MockStreamHandler.inline(
          onListen: (_, eventos) {
            eventos
              ..error(code: 'SIN_TOKEN')
              ..success({'ordenId': 41, 'pushToken': 'aabb'})
              ..endOfStream();
          },
        ),
      );
      final servicio = ServicioActividadEnVivoCanal();
      await servicio.disponible();

      expect(await servicio.tokensDe(41).toList(), ['aabb']);
    });
  });

  group('servicio nulo (Android y pruebas)', () {
    test('no esta disponible y no hace nada', () async {
      const servicio = ServicioActividadEnVivoNulo();

      expect(await servicio.disponible(), isFalse);
      expect(await servicio.iniciar(41, _estado), isFalse);
      await servicio.actualizar(41, _estado);
      await servicio.terminar(41);
      await servicio.terminarTodas();
      expect(await servicio.activas(), isEmpty);
      expect(await servicio.tokensDe(41).toList(), isEmpty);
    });
  });
}
