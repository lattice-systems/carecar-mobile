import 'package:carecar_mobile/api/excepciones.dart';
import 'package:carecar_mobile/modulos/taller/taller.dart';
import 'package:carecar_mobile/modulos/widgets/datos/repositorio_actividad_en_vivo_fake.dart';
import 'package:carecar_mobile/modulos/widgets/datos/servicio_actividad_en_vivo_fake.dart';
import 'package:carecar_mobile/modulos/widgets/dominio/actividad_en_vivo.dart';
import 'package:carecar_mobile/modulos/widgets/presentacion/coordinador_de_actividad_en_vivo.dart';
import 'package:flutter_test/flutter_test.dart';

OrdenEnCurso _orden({
  int id = 41,
  EtapaTaller etapa = EtapaTaller.enReparacion,
  int avance = 43,
  int adicionalesPendientes = 0,
}) => OrdenEnCurso(
  id: id,
  vehiculoId: 1,
  vehiculo: 'Nissan March 2026',
  etapa: etapa,
  avance: avance,
  adicionalesPendientes: adicionalesPendientes,
  entregaEstimada: DateTime(2026, 11, 27, 18),
);

/// Deja correr los avisos de tokens y los registros pendientes.
Future<void> _drenar() async {
  for (var i = 0; i < 10; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}

class _Escenario {
  _Escenario({
    ServicioActividadEnVivoFake? servicio,
    RepositorioActividadEnVivoFake? repositorio,
  }) : servicio = servicio ?? ServicioActividadEnVivoFake(),
       repositorio = repositorio ?? RepositorioActividadEnVivoFake() {
    coordinador = CoordinadorDeActividadEnVivo(
      servicio: this.servicio,
      repositorio: () {
        repositoriosPedidos++;
        return this.repositorio;
      },
    );
  }

  final ServicioActividadEnVivoFake servicio;
  final RepositorioActividadEnVivoFake repositorio;
  late final CoordinadorDeActividadEnVivo coordinador;
  var repositoriosPedidos = 0;
}

void main() {
  group('con una orden en curso', () {
    test('inicia la actividad con el estado de la orden', () async {
      final e = _Escenario();

      await e.coordinador.alCambiarLasOrdenes([_orden()]);

      expect(e.servicio.vivas.keys, [41]);
      expect(e.servicio.vivas[41], EstadoDeActividad.deOrden(_orden()));
    });

    test('manda cada push token al backend, sin repetir', () async {
      final e = _Escenario();
      await e.coordinador.alCambiarLasOrdenes([_orden()]);

      e.servicio.emitirToken(41, 'aabb');
      await _drenar();
      e.servicio.emitirToken(41, 'aabb');
      await _drenar();
      // ActivityKit roto el token: el nuevo tambien se registra.
      e.servicio.emitirToken(41, 'ccdd');
      await _drenar();

      expect(e.repositorio.registrados, [(41, 'aabb'), (41, 'ccdd')]);
    });

    test('la actualiza solo cuando cambia su estado', () async {
      final e = _Escenario();
      await e.coordinador.alCambiarLasOrdenes([_orden()]);
      await e.coordinador.alCambiarLasOrdenes([_orden()]);
      final siguiente = _orden(
        etapa: EtapaTaller.esperandoAprobacion,
        avance: 29,
        adicionalesPendientes: 1,
      );

      await e.coordinador.alCambiarLasOrdenes([siguiente]);

      expect(e.servicio.llamadas, ['iniciar:41', 'actualizar:41']);
      expect(e.servicio.vivas[41], EstadoDeActividad.deOrden(siguiente));
    });

    test(
      'al entregar la termina con el estado final y no la reinicia',
      () async {
        final e = _Escenario();
        await e.coordinador.alCambiarLasOrdenes([_orden()]);

        // `GET /ordenes/activas` ya no la trae: se entrego.
        await e.coordinador.alCambiarLasOrdenes([]);
        await e.coordinador.alCambiarLasOrdenes([]);

        expect(e.servicio.vivas, isEmpty);
        expect(
          e.servicio.finales[41],
          EstadoDeActividad.deOrden(_orden()).entregada(),
        );
        expect(e.servicio.llamadas, ['iniciar:41', 'terminar:41']);
      },
    );

    test('una orden que llega ya entregada no inicia actividad', () async {
      final e = _Escenario();

      await e.coordinador.alCambiarLasOrdenes([
        _orden(etapa: EtapaTaller.entregado),
      ]);

      expect(e.servicio.vivas, isEmpty);
      expect(e.servicio.llamadas, isEmpty);
    });

    test('cada orden abierta tiene su propia actividad', () async {
      final e = _Escenario();

      await e.coordinador.alCambiarLasOrdenes([_orden(), _orden(id: 7)]);
      e.servicio
        ..emitirToken(41, 'aa')
        ..emitirToken(7, 'bb');
      await _drenar();

      expect(e.servicio.vivas.keys, unorderedEquals([41, 7]));
      expect(
        e.repositorio.registrados,
        unorderedEquals([(41, 'aa'), (7, 'bb')]),
      );
    });
  });

  group('cuando no hay Live Activities', () {
    test('no inicia nada ni toca la red', () async {
      final e = _Escenario(
        servicio: ServicioActividadEnVivoFake(estaDisponible: false),
      );

      await e.coordinador.alCambiarLasOrdenes([_orden()]);
      await e.coordinador.alCerrarSesion();

      expect(e.servicio.vivas, isEmpty);
      expect(e.servicio.llamadas, isNot(contains('iniciar:41')));
      expect(e.repositoriosPedidos, 0);
    });

    test(
      'si el sistema no la deja iniciar, lo intenta en el siguiente cambio',
      () async {
        final servicio = ServicioActividadEnVivoFake(iniciaActividades: false);
        final e = _Escenario(servicio: servicio);
        await e.coordinador.alCambiarLasOrdenes([_orden()]);
        expect(servicio.vivas, isEmpty);

        servicio.iniciaActividades = true;
        await e.coordinador.alCambiarLasOrdenes([_orden()]);

        expect(servicio.vivas.keys, [41]);
        expect(servicio.escuchas, 1);
      },
    );
  });

  group('errores del backend', () {
    test('un 409 ORDEN_CERRADA termina la actividad y no reintenta', () async {
      final e = _Escenario(
        repositorio: RepositorioActividadEnVivoFake(entregadas: {41}),
      );
      await e.coordinador.alCambiarLasOrdenes([_orden()]);

      e.servicio.emitirToken(41, 'aabb');
      await _drenar();
      // La lista aun no se refresca y la trae: no se vuelve a iniciar.
      await e.coordinador.alCambiarLasOrdenes([_orden()]);
      e.servicio.emitirToken(41, 'ccdd');
      await _drenar();

      expect(e.servicio.vivas, isEmpty);
      expect(e.servicio.finales.containsKey(41), isTrue);
      expect(e.servicio.llamadas.where((l) => l == 'iniciar:41'), hasLength(1));
      expect(e.repositorio.registrados, isEmpty);
      expect(e.servicio.escuchas, 0);
    });

    test('sin red no se rompe y reintenta en el siguiente cambio', () async {
      final repositorio = RepositorioActividadEnVivoFake(
        falla: const SinConexion('sin red'),
      );
      final e = _Escenario(repositorio: repositorio);
      await e.coordinador.alCambiarLasOrdenes([_orden()]);
      e.servicio.emitirToken(41, 'aabb');
      await _drenar();
      expect(repositorio.registrados, isEmpty);

      repositorio.falla = null;
      await e.coordinador.alCambiarLasOrdenes([_orden()]);
      await _drenar();

      expect(repositorio.registrados, [(41, 'aabb')]);
      expect(e.servicio.vivas.keys, [41]);
    });
  });

  group('sesion', () {
    test('al cerrar sesion da de baja cada actividad y las termina', () async {
      final servicio = ServicioActividadEnVivoFake(
        // Una de una ejecucion anterior de la app, sin token conocido.
        previas: {9: EstadoDeActividad.deOrden(_orden(id: 9))},
      );
      final e = _Escenario(servicio: servicio);
      await e.coordinador.alCambiarLasOrdenes([_orden(), _orden(id: 9)]);
      servicio.emitirToken(41, 'aabb');
      await _drenar();

      await e.coordinador.alCerrarSesion();

      expect(e.repositorio.bajas, unorderedEquals([(41, 'aabb'), (9, null)]));
      expect(servicio.llamadas.last, 'terminarTodas');
      expect(servicio.vivas, isEmpty);
      expect(servicio.escuchas, 0);
    });

    test('si la baja falla, igual termina todas sin lanzar', () async {
      final repositorio = RepositorioActividadEnVivoFake();
      final e = _Escenario(repositorio: repositorio);
      await e.coordinador.alCambiarLasOrdenes([_orden()]);
      repositorio.falla = const SinConexion('sin red');

      await e.coordinador.alCerrarSesion();

      expect(e.servicio.vivas, isEmpty);
      expect(e.servicio.llamadas.last, 'terminarTodas');
    });

    test('si no se puede armar el registro, igual las termina', () async {
      final servicio = ServicioActividadEnVivoFake();
      final coordinador = CoordinadorDeActividadEnVivo(
        servicio: servicio,
        repositorio: () => throw StateError('apiClienteProvider no inyectado'),
      );
      await coordinador.alCambiarLasOrdenes([_orden()]);

      await coordinador.alCerrarSesion();

      expect(servicio.vivas, isEmpty);
      expect(servicio.llamadas.last, 'terminarTodas');
    });

    test('al perder la sesion termina todas sin tocar la red', () async {
      final e = _Escenario();
      await e.coordinador.alCambiarLasOrdenes([_orden()]);

      await e.coordinador.alPerderLaSesion();

      expect(e.servicio.vivas, isEmpty);
      expect(e.repositorio.bajas, isEmpty);
      // Una sesion nueva vuelve a iniciar la actividad.
      await e.coordinador.alCambiarLasOrdenes([_orden()]);
      expect(e.servicio.vivas.keys, [41]);
    });

    test(
      'termina las de una ejecucion anterior que ya no estan abiertas',
      () async {
        final servicio = ServicioActividadEnVivoFake(
          previas: {9: EstadoDeActividad.deOrden(_orden(id: 9))},
        );
        final e = _Escenario(servicio: servicio);

        await e.coordinador.alCambiarLasOrdenes([_orden()]);

        expect(servicio.vivas.keys, [41]);
        expect(servicio.llamadas, contains('terminar:9'));
      },
    );

    test('detenido ya no registra tokens', () async {
      final e = _Escenario();
      await e.coordinador.alCambiarLasOrdenes([_orden()]);

      e.coordinador.detener();
      e.servicio.emitirToken(41, 'aabb');
      await _drenar();

      expect(e.repositorio.registrados, isEmpty);
      expect(e.servicio.escuchas, 0);
      // Detener no quita la actividad: sigue en la pantalla bloqueada.
      expect(e.servicio.vivas.keys, [41]);
    });
  });
}
