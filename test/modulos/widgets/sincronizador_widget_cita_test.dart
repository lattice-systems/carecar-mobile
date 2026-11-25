import 'package:carecar_mobile/l10n/idiomas.dart';
import 'package:carecar_mobile/modulos/citas/citas.dart';
import 'package:carecar_mobile/modulos/citas/datos/repositorio_citas_fake.dart';
import 'package:carecar_mobile/modulos/taller/datos/repositorio_taller_fake.dart';
import 'package:carecar_mobile/modulos/taller/taller.dart';
import 'package:carecar_mobile/modulos/widgets/widgets.dart';
import 'package:carecar_mobile/nucleo/eventos/eventos_en_vivo_fake.dart';
import 'package:carecar_mobile/nucleo/eventos/proveedores_eventos.dart';
import 'package:carecar_mobile/nucleo/seguridad/detector_integridad.dart';
import 'package:carecar_mobile/nucleo/seguridad/politica_datos_locales.dart';
import 'package:carecar_mobile/nucleo/seguridad/proveedores_seguridad.dart';
import 'package:carecar_mobile/nucleo/sesion/proveedores_sesion.dart';
import 'package:carecar_mobile/sesion/almacen_sesion.dart';
import 'package:carecar_mobile/sesion/controlador_sesion.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../ayudas/api_falsa.dart';

/// Puerto falso: guarda todo lo que se le pidio mostrar en el widget.
class _PuertoFalso implements PuertoWidgetCita {
  final publicados = <ContenidoWidgetCita>[];
  Object? fallo;

  ContenidoWidgetCita get ultimo => publicados.last;

  @override
  Future<void> publicar(ContenidoWidgetCita contenido) async {
    if (fallo != null) throw fallo!;
    publicados.add(contenido);
  }
}

CitaCliente _cita(
  int id,
  DateTime fecha, {
  String hora = '09:00',
  EstadoDeCita estado = EstadoDeCita.confirmada,
  String? vehiculo = 'Aveo 2021',
}) => CitaCliente(
  id: id,
  vehiculoId: 1,
  fecha: fecha,
  horaInicio: hora,
  horaFin: '10:00',
  estado: estado,
  vehiculoNombre: vehiculo,
);

final _ahora = DateTime(2026, 11, 22, 12);

/// Repositorio del taller que deja cambiar las ordenes abiertas a mitad de la
/// prueba, como cuando el taller avanza la orden.
class _TallerMutable extends RepositorioTallerFake {
  _TallerMutable(this.abiertas) : super(ordenes: const []);

  List<OrdenEnCurso> abiertas;
  int consultas = 0;

  @override
  Future<List<OrdenEnCurso>> enCurso() async {
    consultas++;
    if (falla != null) throw falla!;
    return abiertas;
  }
}

OrdenEnCurso _orden({
  int id = 41,
  EtapaTaller etapa = EtapaTaller.enReparacion,
  DateTime? entrega,
}) => OrdenEnCurso(
  id: id,
  vehiculoId: 1,
  vehiculo: 'Nissan March 2026',
  etapa: etapa,
  avance: 50,
  adicionalesPendientes: 0,
  entregaEstimada: entrega ?? DateTime(2026, 11, 22, 18),
  asesor: 'Laura Méndez',
);

class _Escenario {
  _Escenario(
    this.puerto,
    this.controlador,
    this.repositorio,
    this.taller,
    this.eventos,
  );
  final _TallerMutable taller;
  final EventosEnVivoFake eventos;
  final _PuertoFalso puerto;
  final ControladorSesion controlador;
  final RepositorioCitasFake repositorio;
}

Future<_Escenario> _montar(
  WidgetTester tester, {
  List<CitaCliente> citas = const [],
  List<OrdenEnCurso> ordenes = const [],
  Object? falloTaller,
  Object? falloAlCargar,
  bool conSesion = true,
  Locale idioma = const Locale('es'),
  PoliticaDatosLocales? politica,
}) async {
  tester.platformDispatcher.localesTestValue = [idioma];
  addTearDown(tester.platformDispatcher.clearLocalesTestValue);
  final puerto = _PuertoFalso();
  final taller = _TallerMutable(ordenes)..falla = falloTaller;
  final eventos = EventosEnVivoFake();
  final repositorio = RepositorioCitasFake(
    citas: citas,
    error: falloAlCargar,
    reloj: () => _ahora,
  );
  final controlador = ControladorSesion(ApiFalsa(), AlmacenEnMemoria());
  if (conSesion) {
    await controlador.iniciarSesion(
      correo: 'cliente@carecar.mx',
      contrasena: 'Secreta1!',
    );
  }
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        puertoWidgetCitaProvider.overrideWithValue(puerto),
        repositorioCitasProvider.overrideWithValue(repositorio),
        repositorioTallerProvider.overrideWithValue(taller),
        eventosEnVivoProvider.overrideWithValue(eventos),
        relojCitasProvider.overrideWithValue(() => _ahora),
        controladorSesionProvider.overrideWithValue(controlador),
        if (politica != null)
          politicaDatosLocalesProvider.overrideWithValue(politica),
      ],
      child: MaterialApp(
        localizationsDelegates: delegadasDeIdioma,
        supportedLocales: idiomasSoportados,
        localeResolutionCallback: resolverIdioma,
        builder: (context, child) =>
            SincronizadorDelWidgetDeCita(child: child!),
        home: const Text('inicio'),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return _Escenario(puerto, controlador, repositorio, taller, eventos);
}

void main() {
  testWidgets('en equipo comprometido el widget no muestra datos de citas', (
    tester,
  ) async {
    final politica = PoliticaDatosLocales(EstadoIntegridad.comprometido);
    final e = await _montar(
      tester,
      citas: [_cita(2, DateTime(2026, 11, 25))],
      politica: politica,
    );
    expect(e.puerto.ultimo.hayCita, isFalse);
    expect(e.puerto.ultimo.vehiculo, isNull);
  });

  testWidgets('si el equipo resulta comprometido despues, se vacia el widget', (
    tester,
  ) async {
    final politica = PoliticaDatosLocales();
    final e = await _montar(
      tester,
      citas: [_cita(2, DateTime(2026, 11, 25))],
      politica: politica,
    );
    expect(e.puerto.ultimo.hayCita, isTrue);

    politica.actualizar(EstadoIntegridad.comprometido);
    await tester.pumpAndSettle();

    expect(e.puerto.ultimo.hayCita, isFalse);
  });

  testWidgets('muestra la proxima cita confirmada con dia, horario y auto', (
    tester,
  ) async {
    final e = await _montar(
      tester,
      citas: [
        _cita(1, DateTime(2026, 12, 5)),
        _cita(2, DateTime(2026, 11, 25), hora: '10:30'),
        _cita(3, DateTime(2026, 11, 23), estado: EstadoDeCita.cancelada),
      ],
    );
    final c = e.puerto.ultimo;
    expect(c.hayCita, isTrue);
    expect(c.titulo, 'Próxima cita');
    expect(c.fecha, contains('25'));
    expect(c.horario, '10:30 a 10:00');
    expect(c.vehiculo, 'Aveo 2021');
    expect(c.enlace, 'carecar://citas/2/comprobante');
  });

  testWidgets('sin citas por venir invita a agendar', (tester) async {
    final e = await _montar(tester, citas: [_cita(1, DateTime(2026, 11, 1))]);
    final c = e.puerto.ultimo;
    expect(c.hayCita, isFalse);
    expect(c.mensaje, 'No tienes citas próximas');
    expect(c.accion, 'Agendar cita');
    expect(c.enlace, enlaceAgendarWidget);
  });

  testWidgets('los textos siguen el idioma del telefono', (tester) async {
    final e = await _montar(
      tester,
      citas: [_cita(2, DateTime(2026, 11, 25))],
      idioma: const Locale('en'),
    );
    expect(e.puerto.ultimo.titulo, 'Next appointment');
    expect(e.puerto.ultimo.horario, '09:00 to 10:00');
  });

  testWidgets('al cancelar la cita el widget pasa a la siguiente', (
    tester,
  ) async {
    final e = await _montar(
      tester,
      citas: [
        _cita(2, DateTime(2026, 11, 25)),
        _cita(1, DateTime(2026, 12, 5)),
      ],
    );
    expect(e.puerto.ultimo.enlace, 'carecar://citas/2/comprobante');

    final contenedor = ProviderScope.containerOf(
      tester.element(find.text('inicio')),
    );
    contenedor
        .read(misCitasProvider.notifier)
        .reemplazar(
          _cita(2, DateTime(2026, 11, 25), estado: EstadoDeCita.cancelada),
        );
    await tester.pumpAndSettle();

    expect(e.puerto.ultimo.enlace, 'carecar://citas/1/comprobante');
  });

  testWidgets('al agendar y recargar las citas aparece la nueva', (
    tester,
  ) async {
    final e = await _montar(tester);
    expect(e.puerto.ultimo.hayCita, isFalse);

    // El repositorio cambia (se agendo) y la lista se invalida.
    await e.repositorio.agendar(
      vehiculoId: 1,
      franja: FranjaDisponible(
        franjaId: 1,
        fecha: DateTime(2026, 11, 26),
        horaInicio: '09:00',
        horaFin: '10:00',
        cupo: 2,
      ),
      motivo: MotivoCita.mantenimiento,
    );
    ProviderScope.containerOf(tester.element(find.text('inicio')))
        .invalidate(misCitasProvider);
    await tester.pumpAndSettle();

    expect(e.puerto.ultimo.hayCita, isTrue);
  });

  testWidgets('sin sesion el widget no conserva datos de ninguna cita', (
    tester,
  ) async {
    final e = await _montar(tester, citas: [_cita(2, DateTime(2026, 11, 25))]);
    expect(e.puerto.ultimo.hayCita, isTrue);

    await e.controlador.cerrarSesion();
    await tester.pumpAndSettle();

    final c = e.puerto.ultimo;
    expect(c.hayCita, isFalse);
    expect(c.vehiculo, isNull);
    expect(c.fecha, isNull);
  });

  testWidgets('sin sesion desde el arranque no muestra ninguna cita', (
    tester,
  ) async {
    final e = await _montar(
      tester,
      conSesion: false,
      citas: [_cita(2, DateTime(2026, 11, 25))],
    );
    expect(e.puerto.ultimo.hayCita, isFalse);
  });

  testWidgets('si no se pueden cargar las citas conserva lo ultimo mostrado', (
    tester,
  ) async {
    final e = await _montar(tester, falloAlCargar: Exception('sin red'));
    expect(e.puerto.publicados, isEmpty);
  });

  testWidgets('con orden abierta muestra auto, etapa y entrega', (
    tester,
  ) async {
    final e = await _montar(
      tester,
      citas: [_cita(2, DateTime(2026, 11, 25))],
      ordenes: [_orden()],
    );
    final c = e.puerto.ultimo;
    expect(c.hayCita, isTrue);
    expect(c.titulo, 'Tu auto en el taller');
    expect(c.fecha, 'En reparación');
    expect(c.horario, startsWith('Entrega estimada:'));
    expect(c.horario, contains('18:00'));
    expect(c.vehiculo, 'Nissan March 2026');
    expect(c.enlace, 'carecar://taller/41');
  });

  testWidgets('con orden abierta no se publica ninguna cita', (tester) async {
    final e = await _montar(
      tester,
      citas: [_cita(2, DateTime(2026, 11, 25))],
      ordenes: [_orden()],
    );
    expect(
      e.puerto.publicados.where((c) => c.enlace.contains('citas')),
      isEmpty,
    );
  });

  testWidgets('sin hora estimada no dice cuando entregan', (tester) async {
    final e = await _montar(
      tester,
      ordenes: [
        const OrdenEnCurso(
          id: 7,
          vehiculoId: 1,
          vehiculo: 'Aveo',
          etapa: EtapaTaller.recibido,
          avance: 0,
          adicionalesPendientes: 0,
        ),
      ],
    );
    expect(e.puerto.ultimo.fecha, 'Recibido');
    expect(e.puerto.ultimo.horario, isNull);
  });

  testWidgets('los textos del taller siguen el idioma del telefono', (
    tester,
  ) async {
    final e = await _montar(
      tester,
      ordenes: [_orden()],
      idioma: const Locale('en'),
    );
    expect(e.puerto.ultimo.titulo, 'Your car at the workshop');
    expect(e.puerto.ultimo.horario, startsWith('Estimated pickup:'));
  });

  testWidgets('al entregarse la orden vuelve a la proxima cita', (
    tester,
  ) async {
    final e = await _montar(
      tester,
      citas: [_cita(2, DateTime(2026, 11, 25))],
      ordenes: [_orden()],
    );
    e.taller.abiertas = [];
    e.eventos.emitir('orden', {'ordenId': 41});
    await tester.pumpAndSettle();

    expect(e.puerto.ultimo.enlace, 'carecar://citas/2/comprobante');
  });

  testWidgets('un evento de orden actualiza la etapa con la app abierta', (
    tester,
  ) async {
    final e = await _montar(tester, ordenes: [_orden()]);
    expect(e.puerto.ultimo.fecha, 'En reparación');

    e.taller.abiertas = [_orden(etapa: EtapaTaller.listoParaEntrega)];
    e.eventos.emitir('orden', {'ordenId': 41});
    await tester.pumpAndSettle();

    expect(e.puerto.ultimo.fecha, 'Listo para entrega');
  });

  testWidgets('al reconectar el canal vuelve a consultar las ordenes', (
    tester,
  ) async {
    final e = await _montar(tester, ordenes: [_orden()]);
    final antes = e.taller.consultas;

    e.eventos.emitir('conexion.restablecida');
    await tester.pumpAndSettle();

    expect(e.taller.consultas, greaterThan(antes));
  });

  testWidgets('otros eventos no vuelven a consultar las ordenes', (
    tester,
  ) async {
    final e = await _montar(tester, ordenes: [_orden()]);
    final antes = e.taller.consultas;

    e.eventos.emitir('asistencia.estado', {'solicitudId': 1});
    await tester.pumpAndSettle();

    expect(e.taller.consultas, antes);
  });

  testWidgets('al volver a primer plano vuelve a consultar las ordenes', (
    tester,
  ) async {
    final e = await _montar(tester, ordenes: [_orden()]);
    e.taller.abiertas = [_orden(etapa: EtapaTaller.lavado)];

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();

    expect(e.puerto.ultimo.fecha, 'Lavado');
  });

  testWidgets('al cerrar sesion se borra el auto del widget', (tester) async {
    final e = await _montar(tester, ordenes: [_orden()]);
    expect(e.puerto.ultimo.vehiculo, 'Nissan March 2026');

    await e.controlador.cerrarSesion();
    await tester.pumpAndSettle();

    final c = e.puerto.ultimo;
    expect(c.hayCita, isFalse);
    expect(c.vehiculo, isNull);
    expect(c.fecha, isNull);
    expect(c.enlace, enlaceAgendarWidget);
  });

  testWidgets('sin sesion no se consultan las ordenes ni se abre el canal', (
    tester,
  ) async {
    final e = await _montar(tester, conSesion: false, ordenes: [_orden()]);
    expect(e.taller.consultas, 0);
    expect(e.eventos.aperturas, 0);
  });

  testWidgets('si las ordenes no cargan se muestra la proxima cita', (
    tester,
  ) async {
    final e = await _montar(
      tester,
      citas: [_cita(2, DateTime(2026, 11, 25))],
      falloTaller: Exception('sin red'),
    );
    expect(e.puerto.ultimo.enlace, 'carecar://citas/2/comprobante');
  });

  testWidgets('si falla al actualizar conserva la orden que ya mostraba', (
    tester,
  ) async {
    final e = await _montar(
      tester,
      citas: [_cita(2, DateTime(2026, 11, 25))],
      ordenes: [_orden()],
    );
    e.taller.falla = Exception('sin red');
    e.eventos.emitir('orden', {'ordenId': 41});
    await tester.pumpAndSettle();

    expect(e.puerto.ultimo.enlace, 'carecar://taller/41');
  });

  testWidgets('en equipo comprometido el widget no muestra el auto', (
    tester,
  ) async {
    final e = await _montar(
      tester,
      ordenes: [_orden()],
      politica: PoliticaDatosLocales(EstadoIntegridad.comprometido),
    );
    expect(e.puerto.ultimo.hayCita, isFalse);
    expect(e.puerto.ultimo.vehiculo, isNull);
    expect(e.taller.consultas, 0);
  });

  testWidgets('un sistema sin widgets no afecta a la app', (tester) async {
    final puerto = _PuertoFalso()..fallo = StateError('sin widgets');
    final controlador = ControladorSesion(ApiFalsa(), AlmacenEnMemoria());
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          puertoWidgetCitaProvider.overrideWithValue(puerto),
          repositorioTallerProvider.overrideWithValue(_TallerMutable([])),
          eventosEnVivoProvider.overrideWithValue(EventosEnVivoFake()),
          controladorSesionProvider.overrideWithValue(controlador),
        ],
        child: MaterialApp(
          localizationsDelegates: delegadasDeIdioma,
          supportedLocales: idiomasSoportados,
          builder: (context, child) =>
              SincronizadorDelWidgetDeCita(child: child!),
          home: const Text('inicio'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('inicio'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
