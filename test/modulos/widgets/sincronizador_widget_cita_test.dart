import 'package:carecar_mobile/l10n/idiomas.dart';
import 'package:carecar_mobile/modulos/citas/citas.dart';
import 'package:carecar_mobile/modulos/citas/datos/repositorio_citas_fake.dart';
import 'package:carecar_mobile/modulos/widgets/widgets.dart';
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

class _Escenario {
  _Escenario(this.puerto, this.controlador, this.repositorio);
  final _PuertoFalso puerto;
  final ControladorSesion controlador;
  final RepositorioCitasFake repositorio;
}

Future<_Escenario> _montar(
  WidgetTester tester, {
  List<CitaCliente> citas = const [],
  Object? falloAlCargar,
  bool conSesion = true,
  Locale idioma = const Locale('es'),
}) async {
  tester.platformDispatcher.localesTestValue = [idioma];
  addTearDown(tester.platformDispatcher.clearLocalesTestValue);
  final puerto = _PuertoFalso();
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
        relojCitasProvider.overrideWithValue(() => _ahora),
        controladorSesionProvider.overrideWithValue(controlador),
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
  return _Escenario(puerto, controlador, repositorio);
}

void main() {
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
    final e = await _montar(
      tester,
      citas: [_cita(1, DateTime(2026, 11, 1))],
    );
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
    ProviderScope.containerOf(
      tester.element(find.text('inicio')),
    ).invalidate(misCitasProvider);
    await tester.pumpAndSettle();

    expect(e.puerto.ultimo.hayCita, isTrue);
  });

  testWidgets('sin sesion el widget no conserva datos de ninguna cita', (
    tester,
  ) async {
    final e = await _montar(
      tester,
      citas: [_cita(2, DateTime(2026, 11, 25))],
    );
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

  testWidgets('un sistema sin widgets no afecta a la app', (tester) async {
    final puerto = _PuertoFalso()..fallo = StateError('sin widgets');
    final controlador = ControladorSesion(ApiFalsa(), AlmacenEnMemoria());
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          puertoWidgetCitaProvider.overrideWithValue(puerto),
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
