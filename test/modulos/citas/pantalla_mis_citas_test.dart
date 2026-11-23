import 'package:carecar_mobile/api/excepciones.dart';
import 'package:carecar_mobile/l10n/idiomas.dart';
import 'package:carecar_mobile/modulos/citas/citas.dart';
import 'package:carecar_mobile/modulos/citas/datos/repositorio_citas_fake.dart';
import 'package:carecar_mobile/modulos/citas/dominio/fallos_agenda.dart';
import 'package:carecar_mobile/modulos/vehiculos/datos/repositorio_garaje_fake.dart';
import 'package:carecar_mobile/modulos/vehiculos/vehiculos.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/dialogo.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/esqueleto.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/estado_error.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/estado_vacio.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/insignia.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../ayudas/tema_pista.dart';

/// Lunes 23 de noviembre de 2026, a mediodia.
final _ahora = DateTime(2026, 11, 23, 12);

CitaCliente _cita(
  int id, {
  EstadoDeCita estado = EstadoDeCita.confirmada,
  int dia = 26,
  int vehiculoId = 1,
}) => CitaCliente(
  id: id,
  vehiculoId: vehiculoId,
  franjaId: id,
  fecha: DateTime(2026, 11, dia),
  horaInicio: '09:00',
  horaFin: '10:00',
  estado: estado,
);

/// Una proxima y una de cada estado pasado.
List<CitaCliente> _variadas() => [
  _cita(1),
  _cita(2, estado: EstadoDeCita.atendida, dia: 10),
  _cita(3, estado: EstadoDeCita.noAsistio, dia: 12, vehiculoId: 2),
  _cita(4, estado: EstadoDeCita.cancelada, dia: 15),
  _cita(5, dia: 20),
];

Widget _app(
  RepositorioCitasFake citas, {
  Escenario escenario = Escenario.claro,
  Locale idioma = idiomaBase,
  int tamano = 20,
}) => ProviderScope(
  overrides: [
    repositorioCitasProvider.overrideWithValue(citas),
    repositorioGarajeProvider.overrideWithValue(RepositorioGarajeFake()),
    relojCitasProvider.overrideWithValue(() => _ahora),
    tamanoPaginaCitasProvider.overrideWithValue(tamano),
  ],
  child: conTemaPista(
    const PantallaMisCitas(),
    escenario: escenario,
    idioma: idioma,
  ),
);

RepositorioCitasFake _repo([List<CitaCliente>? citas]) =>
    RepositorioCitasFake(citas: citas ?? _variadas(), reloj: () => _ahora);

void _prueba(String descripcion, Future<void> Function(WidgetTester) cuerpo) =>
    testWidgets(descripcion, (tester) async {
      tester.view.physicalSize = const Size(800, 8000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await cuerpo(tester);
    });

Future<void> _tocar(WidgetTester tester, Finder f) async {
  await tester.ensureVisible(f);
  await tester.pumpAndSettle();
  await tester.tap(f);
  await tester.pumpAndSettle();
}

void main() {
  group('V2-M02.09 ver mis citas', () {
    _prueba('mientras carga muestra esqueleto y lo anuncia', (tester) async {
      await tester.pumpWidget(_app(_repo()));
      expect(find.byType(Esqueleto), findsWidgets);
      expect(find.bySemanticsLabel('Cargando tus citas'), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.byType(Esqueleto), findsNothing);
    });

    _prueba('separa proximas de pasadas', (tester) async {
      await tester.pumpWidget(_app(_repo()));
      await tester.pumpAndSettle();
      expect(find.text('Próximas'), findsOneWidget);
      expect(find.text('Pasadas'), findsOneWidget);
      // Una proxima y cuatro pasadas, cada una con su insignia.
      expect(find.byType(Insignia), findsNWidgets(5));
      final proximas = tester.getTopLeft(find.text('Próximas')).dy;
      final pasadas = tester.getTopLeft(find.text('Pasadas')).dy;
      final confirmadaHoy = tester.getTopLeft(find.text('Confirmada').first).dy;
      expect(confirmadaHoy, greaterThan(proximas));
      expect(confirmadaHoy, lessThan(pasadas));
    });

    _prueba('cada estado lleva texto, no solo color', (tester) async {
      await tester.pumpWidget(_app(_repo()));
      await tester.pumpAndSettle();
      expect(find.text('Confirmada'), findsNWidgets(2));
      expect(find.text('Atendida'), findsOneWidget);
      expect(find.text('No asistió'), findsOneWidget);
      expect(find.text('Cancelada'), findsOneWidget);
      for (final insignia in tester.widgetList<Insignia>(
        find.byType(Insignia),
      )) {
        expect(insignia.conIcono, isTrue);
      }
    });

    _prueba('muestra fecha, hora y vehiculo de la cita', (tester) async {
      await tester.pumpWidget(_app(_repo()));
      await tester.pumpAndSettle();
      expect(find.textContaining('26 nov'), findsOneWidget);
      expect(find.textContaining('09:00'), findsWidgets);
      expect(find.text('Mazda CX-5 2024'), findsWidgets);
      expect(find.text('Mazda 3 2022'), findsOneWidget);
    });

    _prueba('sin proximas lo dice y deja ver las pasadas', (tester) async {
      await tester.pumpWidget(
        _app(_repo([_cita(2, estado: EstadoDeCita.atendida, dia: 10)])),
      );
      await tester.pumpAndSettle();
      expect(find.text('No tienes citas próximas.'), findsOneWidget);
      expect(find.text('Atendida'), findsOneWidget);
    });

    _prueba('pagina: carga mas citas al pedirlo', (tester) async {
      final citas = [
        for (var i = 1; i <= 5; i++)
          _cita(i, estado: EstadoDeCita.atendida, dia: i),
      ];
      await tester.pumpWidget(_app(_repo(citas), tamano: 2));
      await tester.pumpAndSettle();
      expect(find.text('Atendida'), findsNWidgets(2));
      await _tocar(tester, find.text('Cargar más citas'));
      expect(find.text('Atendida'), findsNWidgets(4));
      await _tocar(tester, find.text('Cargar más citas'));
      expect(find.text('Atendida'), findsNWidgets(5));
      expect(find.text('Cargar más citas'), findsNothing);
    });

    _prueba('sin citas explica y ofrece agendar', (tester) async {
      await tester.pumpWidget(_app(_repo(const [])));
      await tester.pumpAndSettle();
      expect(find.byType(EstadoVacio), findsOneWidget);
      expect(find.text('Aún no tienes citas'), findsOneWidget);
      expect(find.text('Agendar cita'), findsOneWidget);
    });

    _prueba('un error ofrece reintentar y recupera', (tester) async {
      await tester.pumpWidget(
        _app(RepositorioCitasFake(error: Exception('x'))),
      );
      await tester.pumpAndSettle();
      expect(find.byType(EstadoError), findsOneWidget);
      expect(find.text('Reintentar'), findsOneWidget);
    });

    _prueba('sin conexion lo dice', (tester) async {
      await tester.pumpWidget(
        _app(RepositorioCitasFake(error: const SinConexion())),
      );
      await tester.pumpAndSettle();
      expect(find.text('Sin conexion'), findsOneWidget);
    });

    for (final escenario in [Escenario.oscuro, Escenario.letraGrande]) {
      _prueba('se arma sin desbordes en $escenario', (tester) async {
        await tester.pumpWidget(_app(_repo(), escenario: escenario));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(find.text('Atendida'), findsOneWidget);
      });
    }

    _prueba('en ingles traduce estados y secciones', (tester) async {
      await tester.pumpWidget(_app(_repo(), idioma: const Locale('en')));
      await tester.pumpAndSettle();
      expect(find.text('Upcoming'), findsOneWidget);
      expect(find.text('Past'), findsOneWidget);
      expect(find.text('Attended'), findsOneWidget);
      expect(find.text('No-show'), findsOneWidget);
    });
  });

  group('V2-M02.10 cancelar una cita', () {
    _prueba('solo las confirmadas futuras ofrecen cancelar', (tester) async {
      await tester.pumpWidget(_app(_repo()));
      await tester.pumpAndSettle();
      // La cita 5 esta confirmada pero ya paso: no se puede cancelar.
      expect(find.text('Cancelar cita'), findsOneWidget);
    });

    _prueba('pide confirmacion con un dialogo y deja mantenerla', (
      tester,
    ) async {
      final repo = _repo();
      await tester.pumpWidget(_app(repo));
      await tester.pumpAndSettle();
      await _tocar(tester, find.text('Cancelar cita'));
      expect(find.byType(Dialogo), findsOneWidget);
      expect(find.text('¿Cancelar esta cita?'), findsOneWidget);
      await _tocar(tester, find.text('Mantener cita'));
      expect(find.byType(Dialogo), findsNothing);
      expect(find.text('Cancelar cita'), findsOneWidget);
      expect(
        (await repo.misCitas()).citas.first.estado,
        EstadoDeCita.confirmada,
      );
    });

    _prueba('al confirmar cancela, avisa que libero el horario', (
      tester,
    ) async {
      final repo = _repo();
      await tester.pumpWidget(_app(repo));
      await tester.pumpAndSettle();
      await _tocar(tester, find.text('Cancelar cita'));
      await _tocar(tester, find.text('Sí, cancelar'));
      expect(
        find.text('Cita cancelada. El horario quedó libre.'),
        findsOneWidget,
      );
      expect(find.text('Cancelar cita'), findsNothing);
      expect(find.text('Cancelada'), findsNWidgets(2));
      expect(
        (await repo.misCitas()).citas.first.estado,
        EstadoDeCita.cancelada,
      );
    });

    _prueba('si ya no se puede cancelar lo explica', (tester) async {
      await tester.pumpWidget(_app(_RepoQueRechaza(_variadas())));
      await tester.pumpAndSettle();
      await _tocar(tester, find.text('Cancelar cita'));
      await _tocar(tester, find.text('Sí, cancelar'));
      expect(find.text('Esta cita ya no se puede cancelar.'), findsOneWidget);
    });

    _prueba('un error de red al cancelar se explica y deja reintentar', (
      tester,
    ) async {
      await tester.pumpWidget(_app(_RepoQueFalla(_variadas())));
      await tester.pumpAndSettle();
      await _tocar(tester, find.text('Cancelar cita'));
      await _tocar(tester, find.text('Sí, cancelar'));
      expect(
        find.text('No pudimos cancelar tu cita. Intenta de nuevo.'),
        findsOneWidget,
      );
      expect(find.text('Cancelar cita'), findsOneWidget);
    });
  });
}

class _RepoQueRechaza extends RepositorioCitasFake {
  _RepoQueRechaza(List<CitaCliente> citas)
    : super(citas: citas, reloj: () => _ahora);

  @override
  Future<CitaCliente> cancelar(int citaId) async =>
      throw const CitaNoModificable();
}

class _RepoQueFalla extends RepositorioCitasFake {
  _RepoQueFalla(List<CitaCliente> citas)
    : super(citas: citas, reloj: () => _ahora);

  @override
  Future<CitaCliente> cancelar(int citaId) async => throw const SinConexion();
}
