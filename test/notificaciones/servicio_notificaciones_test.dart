import 'package:carecar_mobile/api/modelos/cita.dart';
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

  @override
  bool get abiertaDesdeAviso => false;
  @override
  DateTime ahora() => _ahora;
  @override
  Future<void> inicializar() async {}
  @override
  Future<bool> pedirPermiso() async => true;
  @override
  Future<void> mostrar(int id, String titulo, String cuerpo) async =>
      mostradas.add(id);
  @override
  Future<void> programar(
    int id,
    DateTime cuando,
    String titulo,
    String cuerpo,
  ) async => programadas[id] = cuando;
  @override
  Future<void> cancelar(int id) async => programadas.remove(id);
  @override
  Future<void> cancelarTodas() async => programadas.clear();
  @override
  Future<List<int>> pendientes() async => programadas.keys.toList();
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
}
