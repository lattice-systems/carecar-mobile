import '../../ayudas/envolver_con_shad.dart';

import 'package:carecar_mobile/api/excepciones.dart';
import 'package:carecar_mobile/api/modelos/modelos.dart';
import 'package:carecar_mobile/pantallas/citas/pantalla_agendar_cita.dart';
import 'package:carecar_mobile/pantallas/citas/pantalla_mis_citas.dart';
import 'package:carecar_mobile/tema/tema_carecar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../ayudas/api_falsa.dart';

const _march = Vehiculo(
  id: 2,
  vin: '3N1CK3CD7RL900001',
  marca: 'Nissan',
  modelo: 'March',
  anio: 2026,
  placas: 'GTO-123-A',
);

DateTime _enDias(int n) {
  final hoy = DateTime.now();
  return DateTime(hoy.year, hoy.month, hoy.day + n);
}

Cita _cita(int id, int enDias, EstadoCita estado, {String hora = '09:00'}) =>
    Cita(
      id: id,
      vehiculoId: _march.id,
      fecha: _enDias(enDias),
      horaInicio: hora,
      horaFin: '10:00',
      estado: estado,
    );

Future<void> _montar(WidgetTester tester, ApiFalsa api) async {
  await tester.pumpWidget(
    MaterialAppConShad(
      theme: TemaCareCar.claro,
      home: PantallaMisCitas(api: api, alCerrarSesion: () {}),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    final vista =
        TestWidgetsFlutterBinding.instance.platformDispatcher.views.first;
    vista.physicalSize = const Size(800, 2000);
    vista.devicePixelRatio = 1;
  });
  tearDown(() {
    TestWidgetsFlutterBinding.instance.platformDispatcher.views.first
      ..resetPhysicalSize()
      ..resetDevicePixelRatio();
  });

  testWidgets('muestra las proximas primero y luego el historial', (
    tester,
  ) async {
    final api = ApiFalsa();
    api.alPedirVehiculos = () async => const [_march];
    api.alPedirCitas = () async => [
      _cita(1, -10, EstadoCita.atendida),
      _cita(2, 5, EstadoCita.confirmada, hora: '11:00'),
      _cita(3, -3, EstadoCita.cancelada),
    ];
    await _montar(tester, api);

    expect(find.text('PRÓXIMAS'), findsOneWidget);
    expect(find.text('HISTORIAL'), findsOneWidget);
    expect(find.text('Confirmada'), findsOneWidget);
    expect(find.text('Atendida'), findsOneWidget);
    expect(find.text('Cancelada'), findsOneWidget);
    expect(find.text('Nissan March'), findsNWidgets(3));
    expect(
      tester.getTopLeft(find.text('PRÓXIMAS')).dy,
      lessThan(tester.getTopLeft(find.text('HISTORIAL')).dy),
    );
    // Solo la confirmada se puede cancelar.
    expect(find.byKey(PantallaMisCitas.botonCancelar(2)), findsOneWidget);
    expect(find.byKey(PantallaMisCitas.botonCancelar(1)), findsNothing);
  });

  testWidgets('sin citas invita a agendar', (tester) async {
    await _montar(tester, ApiFalsa());

    expect(find.text('Aún no tienes citas'), findsOneWidget);
    expect(find.byKey(PantallaMisCitas.botonAgendar), findsOneWidget);
  });

  testWidgets('sin red ofrece reintentar', (tester) async {
    var llamadas = 0;
    final api = ApiFalsa();
    api.alPedirCitas = () async {
      if (llamadas++ == 0) throw const SinConexion();
      return [_cita(2, 5, EstadoCita.confirmada)];
    };
    await _montar(tester, api);

    expect(find.text('Sin conexión'), findsOneWidget);
    await tester.tap(find.byKey(PantallaMisCitas.botonReintentar));
    await tester.pumpAndSettle();
    expect(find.text('Confirmada'), findsOneWidget);
  });

  testWidgets('cancelar pide confirmacion y recarga', (tester) async {
    var cancelada = false;
    final api = ApiFalsa();
    api.alPedirCitas = () async => [
      _cita(2, 5, cancelada ? EstadoCita.cancelada : EstadoCita.confirmada),
    ];
    api.alCancelar = (id) async {
      cancelada = true;
      return _cita(id, 5, EstadoCita.cancelada);
    };
    await _montar(tester, api);

    await tester.tap(find.byKey(PantallaMisCitas.botonCancelar(2)));
    await tester.pumpAndSettle();
    expect(find.text('¿Cancelar esta cita?'), findsOneWidget);

    // Conservar no cancela nada.
    await tester.tap(find.text('Conservar'));
    await tester.pumpAndSettle();
    expect(api.citasCanceladas, isEmpty);

    await tester.tap(find.byKey(PantallaMisCitas.botonCancelar(2)));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(PantallaMisCitas.confirmarCancelacion));
    await tester.pumpAndSettle();

    expect(api.citasCanceladas, [2]);
    expect(find.text('Tu cita fue cancelada.'), findsOneWidget);
    expect(find.text('Cancelada'), findsOneWidget);
  });

  testWidgets('cancelar fuera de plazo muestra el mensaje del conflicto', (
    tester,
  ) async {
    final api = ApiFalsa();
    api.alPedirCitas = () async => [_cita(2, 1, EstadoCita.confirmada)];
    api.alCancelar = (_) async =>
        throw const Conflicto('La cita ya no se puede cancelar.');
    await _montar(tester, api);

    await tester.tap(find.byKey(PantallaMisCitas.botonCancelar(2)));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(PantallaMisCitas.confirmarCancelacion));
    await tester.pumpAndSettle();

    expect(find.text('La cita ya no se puede cancelar.'), findsOneWidget);
  });

  group('agendar', () {
    Disponibilidad franja(int id, DateTime fecha, String hora) =>
        Disponibilidad(
          fecha: fecha,
          franjaId: id,
          horaInicio: hora,
          horaFin: '${int.parse(hora.substring(0, 2)) + 1}:00',
          cupoDisponible: 3,
        );

    testWidgets('elige dia y franja, agenda y vuelve con aviso', (
      tester,
    ) async {
      final manana = _enDias(1);
      final citas = <Cita>[];
      final api = ApiFalsa();
      api.alPedirVehiculos = () async => const [_march];
      api.alPedirCitas = () async => List.of(citas);
      api.alPedirDisponibilidad = (desde, _) async => [
        franja(10, manana, '09:00'),
        franja(11, manana, '11:00'),
      ];
      api.alAgendar = (nueva) async {
        final c = Cita(
          id: 50,
          vehiculoId: nueva.vehiculoId,
          fecha: nueva.fecha,
          horaInicio: '11:00',
          horaFin: '12:00',
          estado: EstadoCita.confirmada,
        );
        citas.add(c);
        return c;
      };
      await _montar(tester, api);

      await tester.tap(find.byKey(PantallaMisCitas.botonAgendar));
      await tester.pumpAndSettle();
      expect(find.text('Tres pasos y listo'), findsOneWidget);

      // Con un solo vehiculo queda elegido; el dia salta al primero con lugar.
      await tester.tap(find.byKey(PantallaAgendarCita.dia(manana)));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(PantallaAgendarCita.franja(11)));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(PantallaAgendarCita.botonConfirmar));
      await tester.pumpAndSettle();

      expect(api.citasAgendadas, hasLength(1));
      expect(api.citasAgendadas.single.franjaId, 11);
      expect(api.citasAgendadas.single.vehiculoId, _march.id);
      expect(find.textContaining('Cita agendada'), findsOneWidget);
      expect(find.text('Confirmada'), findsOneWidget);
    });

    testWidgets('si la franja se ocupa avisa y recarga los horarios', (
      tester,
    ) async {
      final manana = _enDias(1);
      final api = ApiFalsa();
      api.alPedirVehiculos = () async => const [_march];
      api.alPedirDisponibilidad = (desde, _) async => [
        franja(10, manana, '09:00'),
      ];
      api.alAgendar = (_) async =>
          throw const Conflicto('La franja ya no tiene cupo.');

      await tester.pumpWidget(
        MaterialAppConShad(
          theme: TemaCareCar.claro,
          home: PantallaAgendarCita(api: api, alCerrarSesion: () {}),
        ),
      );
      await tester.pumpAndSettle();
      expect(api.llamadasADisponibilidad, 1);

      await tester.tap(find.byKey(PantallaAgendarCita.franja(10)));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(PantallaAgendarCita.botonConfirmar));
      await tester.pumpAndSettle();

      expect(find.text('Horario no disponible'), findsOneWidget);
      expect(find.text('La franja ya no tiene cupo.'), findsOneWidget);
      expect(api.llamadasADisponibilidad, 2);
      // La seleccion se limpia: no se puede reenviar la misma franja.
      final boton = tester.widget<ShadButton>(
        find.byKey(PantallaAgendarCita.botonConfirmar),
      );
      expect(boton.onPressed, isNull);
    });

    testWidgets('un dia sin horarios lo explica', (tester) async {
      final api = ApiFalsa()..alPedirVehiculos = () async => const [_march];
      await tester.pumpWidget(
        MaterialAppConShad(
          theme: TemaCareCar.claro,
          home: PantallaAgendarCita(api: api, alCerrarSesion: () {}),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.textContaining('No hay horarios disponibles'),
        findsOneWidget,
      );
    });
  });

  testWidgets('sin overflow a 320 de ancho', (tester) async {
    tester.view.physicalSize = const Size(320, 1100);
    final manana = _enDias(1);
    final api = ApiFalsa();
    api.alPedirVehiculos = () async => const [_march];
    api.alPedirCitas = () async => [_cita(2, 1, EstadoCita.confirmada)];
    api.alPedirDisponibilidad = (_, _) async => [
      Disponibilidad(
        fecha: manana,
        franjaId: 1,
        horaInicio: '09:00',
        horaFin: '10:00',
        cupoDisponible: 1,
      ),
    ];
    await _montar(tester, api);
    expect(tester.takeException(), isNull);
    await tester.tap(find.byKey(PantallaMisCitas.botonAgendar));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(PantallaAgendarCita.franja(1)));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
