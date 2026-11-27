import 'package:carecar_mobile/api/modelos/cita.dart';
import 'package:carecar_mobile/nucleo/registro/registro.dart';
import 'package:carecar_mobile/notificaciones/recordatorios.dart';
import 'package:carecar_mobile/notificaciones/servicio_notificaciones.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Doble del plugin: guarda lo programado en memoria.
class _PluginFalso implements PluginNotificaciones {
  _PluginFalso(this._ahora);

  final DateTime _ahora;
  final programadas = <int, DateTime>{};
  final mostradas = <int>[];

  /// A donde lleva cada aviso que se mostro o programo (V2-M06.03).
  final destinos = <int, String?>{};

  @override
  bool get abiertaDesdeAviso => false;
  @override
  String? get destinoDeArranque => null;
  @override
  DateTime ahora() => _ahora;
  @override
  Future<void> inicializar() async {}
  @override
  Future<bool> pedirPermiso() async => true;
  @override
  Future<void> mostrar(
    int id,
    String titulo,
    String cuerpo, {
    String? destino,
  }) async {
    mostradas.add(id);
    destinos[id] = destino;
  }

  @override
  Future<void> programar(
    int id,
    DateTime cuando,
    String titulo,
    String cuerpo, {
    String? destino,
  }) async {
    programadas[id] = cuando;
    destinos[id] = destino;
  }

  @override
  Future<void> cancelar(int id) async => programadas.remove(id);
  @override
  Future<void> cancelarTodas() async => programadas.clear();
  @override
  Future<List<int>> pendientes() async => programadas.keys.toList();
}

/// Plugin que falla con un mensaje que trae datos de una persona.
class _PluginQueFalla extends _PluginFalso {
  _PluginQueFalla(super.ahora, {this.alIniciar = false});

  final bool alIniciar;

  @override
  Future<void> inicializar() async {
    if (alIniciar) throw Exception('sin permiso para ana@correo.mx');
  }

  @override
  Future<void> programar(
    int id,
    DateTime cuando,
    String titulo,
    String cuerpo, {
    String? destino,
  }) async => throw Exception('rechazo 55 1234 5678');
}

Cita _cita(int id, DateTime dia, {EstadoCita estado = EstadoCita.confirmada}) =>
    Cita(
      id: id,
      vehiculoId: 1,
      fecha: dia,
      horaInicio: '10:00:00',
      horaFin: '11:00',
      estado: estado,
    );

void main() {
  final ahora = DateTime(2026, 11, 20, 12);

  group('recordatoriosDe', () {
    test('programa 24 h y 2 h antes con el texto de la agencia', () {
      final r = recordatoriosDe(
        _cita(7, DateTime(2026, 11, 25)),
        ahora: ahora,
        vehiculo: 'Frontier 2024',
      );
      expect(r.map((e) => e.id), [71, 72]);
      expect(r[0].cuando, DateTime(2026, 11, 24, 10));
      expect(r[1].cuando, DateTime(2026, 11, 25, 8));
      expect(
        r[0].cuerpo,
        'Tu cita en Agencia360 es mañana a las 10:00 · Frontier 2024',
      );
    });

    test('salta los que ya pasaron y las citas no confirmadas', () {
      // Manana a las 10: el de 24 h ya paso, queda el de 2 h.
      final r = recordatoriosDe(_cita(3, DateTime(2026, 11, 21)), ahora: ahora);
      expect(r.map((e) => e.id), [IdsNotificacion.dosHoras(3)]);
      expect(
        recordatoriosDe(
          _cita(3, DateTime(2026, 11, 25), estado: EstadoCita.cancelada),
          ahora: ahora,
        ),
        isEmpty,
      );
    });

    test('los ids son deterministas y caben en 32 bits', () {
      expect(IdsNotificacion.confirmacion(12), 120);
      expect(IdsNotificacion.recordatorios(12), [121, 122]);
      expect(IdsNotificacion.dosHoras(1 << 40), lessThan(1 << 31));
    });
  });

  group('ServicioNotificaciones', () {
    late _PluginFalso plugin;
    late ServicioNotificaciones servicio;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      plugin = _PluginFalso(ahora);
      servicio = ServicioNotificaciones(
        plugin,
        await SharedPreferences.getInstance(),
      );
      await servicio.iniciar();
    });

    test('al agendar avisa y programa; al cancelar los quita', () async {
      await servicio.alAgendar(_cita(5, DateTime(2026, 11, 25)));
      expect(plugin.mostradas, [50]);
      expect(plugin.programadas.keys, unorderedEquals([51, 52]));

      await servicio.alCancelar(5);
      expect(plugin.programadas, isEmpty);
    });

    test('cada aviso de cita lleva a «Mis citas» (V2-M06.03)', () async {
      // Sin esto el aviso solo abriria la app, y tocarlo no llevaria a ningun
      // lado: es lo que hace que el toque sepa a donde ir.
      await servicio.alAgendar(_cita(5, DateTime(2026, 11, 25)));

      expect(plugin.destinos[50], destinoDeCitas);
      expect(plugin.destinos[51], destinoDeCitas);
      expect(plugin.destinos[52], destinoDeCitas);
    });

    test(
      'sincronizar cancela las no confirmadas y agrega las que faltan',
      () async {
        await servicio.alAgendar(_cita(1, DateTime(2026, 11, 25)));
        await servicio.sincronizar([
          _cita(1, DateTime(2026, 11, 25), estado: EstadoCita.cancelada),
          _cita(2, DateTime(2026, 11, 26)),
        ]);
        expect(plugin.programadas.keys, unorderedEquals([21, 22]));
      },
    );

    test('apagado no programa y cancela todo', () async {
      await servicio.alAgendar(_cita(1, DateTime(2026, 11, 25)));
      await servicio.cambiarActivo(false);
      expect(plugin.programadas, isEmpty);
      await servicio.sincronizar([_cita(2, DateTime(2026, 11, 26))]);
      expect(plugin.programadas, isEmpty);
    });
  });

  group('fallos que se registran (V2-M22.07)', () {
    late List<String> escrito;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      escrito = [];
      Registro.salida = escrito.add;
      addTearDown(Registro.restaurarSalida);
    });

    test(
      'si no inicia, la app sigue y el registro sale sin el correo',
      () async {
        final servicio = ServicioNotificaciones(
          _PluginQueFalla(ahora, alIniciar: true),
          await SharedPreferences.getInstance(),
        );
        await servicio.iniciar();
        expect(escrito, [
          'No se pudieron iniciar las notificaciones: Exception: sin permiso para [correo]',
        ]);
      },
    );

    test('si falla programar, el registro sale sin el telefono', () async {
      final servicio = ServicioNotificaciones(
        _PluginQueFalla(ahora),
        await SharedPreferences.getInstance(),
      );
      await servicio.iniciar();
      await servicio.alAgendar(_cita(5, DateTime(2026, 11, 25)));
      expect(escrito, isNotEmpty);
      expect(
        escrito,
        everyElement('Fallo una notificacion: Exception: rechazo [telefono]'),
      );
    });
  });
}
