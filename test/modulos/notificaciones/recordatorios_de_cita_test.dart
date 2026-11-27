import 'package:carecar_mobile/modulos/citas/citas.dart';
import 'package:carecar_mobile/modulos/notificaciones/notificaciones.dart';
import 'package:carecar_mobile/notificaciones/recordatorios.dart';
import 'package:carecar_mobile/notificaciones/servicio_notificaciones.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// V2-M06.06 · recordatorios de cita aunque no haya red.
///
/// La historia es «ya existen en v1; migrar a v2», y al migrar se quedaron
/// atrás: todos los disparadores viven en `lib/pantallas/citas/`, y desde que
/// V2-T01.09 dejó citas en v2 **la app no programa ningún recordatorio**.
///
/// Esto es la costura que faltaba: el módulo v2 de citas habla con avisos por
/// aquí, con sus propios tipos (`CitaCliente`), sin saber del servicio v1.
void main() {
  late _PluginEspia plugin;
  late ServicioNotificaciones servicio;

  CitaCliente cita({
    int id = 5,
    EstadoDeCita estado = EstadoDeCita.confirmada,
    DateTime? fecha,
  }) => CitaCliente(
    id: id,
    vehiculoId: 1,
    fecha: fecha ?? DateTime(2026, 12, 20),
    horaInicio: '10:00',
    horaFin: '11:00',
    estado: estado,
    vehiculoNombre: 'Jetta 2021',
  );

  ProviderContainer contenedor() {
    plugin = _PluginEspia();
    servicio = ServicioNotificaciones(plugin, null);
    Notificaciones.actual = servicio;
    addTearDown(() {
      Notificaciones.actual = ServicioNotificaciones(PluginNulo(), null);
    });
    final c = ProviderContainer();
    addTearDown(c.dispose);
    return c;
  }

  test('agendar en v2 programa los dos recordatorios', () async {
    final c = contenedor();
    await servicio.iniciar();

    await c.read(recordatoriosDeCitaProvider).alAgendar(cita());

    // 24 h y 2 h antes: los dos ids del bloque de la cita 5.
    expect(plugin.programadas.keys, unorderedEquals([51, 52]));
    // Y llevan a «Mis citas» (V2-M06.03).
    expect(plugin.destinos[51], destinoDeCitas);
  });

  test('confirmar una cita nueva avisa y programa', () async {
    final c = contenedor();
    await servicio.iniciar();

    await c
        .read(recordatoriosDeCitaProvider)
        .alConfirmar(
          CitaAgendada(
            id: 9,
            vehiculoId: 1,
            fecha: DateTime(2026, 12, 20),
            horaInicio: '10:00',
            horaFin: '11:00',
          ),
        );

    // El aviso inmediato de confirmacion y los dos recordatorios.
    expect(plugin.destinos.containsKey(90), isTrue);
    expect(plugin.programadas.keys, unorderedEquals([91, 92]));
  });

  test('cancelar en v2 los quita', () async {
    final c = contenedor();
    await servicio.iniciar();
    await c.read(recordatoriosDeCitaProvider).alAgendar(cita());

    await c.read(recordatoriosDeCitaProvider).alCancelar(5);

    expect(plugin.programadas, isEmpty);
  });

  test('sincronizar deja solo los de las citas confirmadas', () async {
    final c = contenedor();
    await servicio.iniciar();
    await c.read(recordatoriosDeCitaProvider).alAgendar(cita());

    await c.read(recordatoriosDeCitaProvider).sincronizar([
      cita(estado: EstadoDeCita.cancelada),
      cita(id: 7),
    ]);

    expect(plugin.programadas.keys, unorderedEquals([71, 72]));
  });

  test('una cita que ya pasó no programa nada', () async {
    final c = contenedor();
    await servicio.iniciar();

    await c
        .read(recordatoriosDeCitaProvider)
        .alAgendar(cita(fecha: DateTime(2020, 1, 1)));

    expect(plugin.programadas, isEmpty);
  });

  test('sin red igual quedan programados: nadie llama al servidor', () async {
    final c = contenedor();
    await servicio.iniciar();

    await c.read(recordatoriosDeCitaProvider).alAgendar(cita());

    // Es el criterio de la historia: son avisos locales. Si esto dependiera
    // del servidor, el cliente sin señal se quedaria sin recordatorio.
    expect(plugin.programadas, isNotEmpty);
  });
}

/// Un plugin que apunta lo que se le pide, sin tocar la plataforma.
class _PluginEspia implements PluginNotificaciones {
  final programadas = <int, DateTime>{};
  final destinos = <int, String?>{};

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
  }) async => destinos[id] = destino;
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
  @override
  DateTime ahora() => DateTime(2026, 12, 1);
  @override
  bool get abiertaDesdeAviso => false;
  @override
  String? get destinoDeArranque => null;
}
