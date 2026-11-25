import 'package:carecar_mobile/l10n/idiomas.dart';
import 'package:carecar_mobile/modulos/bitacora/bitacora.dart';
import 'package:carecar_mobile/modulos/bitacora/datos/repositorio_bitacora_fake.dart';
import 'package:carecar_mobile/modulos/citas/citas.dart';
import 'package:carecar_mobile/modulos/citas/datos/repositorio_citas_fake.dart';
import 'package:carecar_mobile/modulos/mantenimiento/datos/repositorio_mantenimiento_fake.dart';
import 'package:carecar_mobile/modulos/mantenimiento/mantenimiento.dart';
import 'package:carecar_mobile/modulos/taller/datos/repositorio_taller_fake.dart';
import 'package:carecar_mobile/modulos/taller/taller.dart';
import 'package:carecar_mobile/modulos/vehiculos/datos/repositorio_garaje_fake.dart';
import 'package:carecar_mobile/modulos/vehiculos/vehiculos.dart';
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

/// Puerto falso: guarda lo que se le pidio mostrar y cuantas veces se borro.
class _PuertoFalso implements PuertoWidgets {
  final publicados = <ContenidoWidget>[];
  int borrados = 0;
  Object? fallo;

  ContenidoWidget? ultimoDe(TipoWidget tipo) {
    for (final c in publicados.reversed) {
      if (c.tipo == tipo) return c;
    }
    return null;
  }

  int vecesPublicado(TipoWidget tipo) =>
      publicados.where((c) => c.tipo == tipo).length;

  @override
  Future<void> publicar(ContenidoWidget contenido) async {
    if (fallo != null) throw fallo!;
    publicados.add(contenido);
  }

  @override
  Future<void> borrarTodo() async {
    if (fallo != null) throw fallo!;
    borrados++;
    publicados.clear();
  }
}

final _ahora = DateTime(2026, 11, 22, 12);

CitaCliente _cita(
  int id,
  DateTime fecha, {
  EstadoDeCita estado = EstadoDeCita.confirmada,
}) => CitaCliente(
  id: id,
  vehiculoId: 1,
  fecha: fecha,
  horaInicio: '09:00',
  horaFin: '10:00',
  estado: estado,
  vehiculoNombre: 'Aveo 2021',
);

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

OrdenEnCurso _orden({EtapaTaller etapa = EtapaTaller.enReparacion}) =>
    OrdenEnCurso(
      id: 41,
      vehiculoId: 1,
      vehiculo: 'Nissan March 2026',
      etapa: etapa,
      avance: 50,
      adicionalesPendientes: 0,
      entregaEstimada: DateTime(2026, 11, 22, 18),
      asesor: 'Laura Méndez',
    );

Gasto _carga(int id, DateTime fecha, int km, double litros, double monto) =>
    Gasto(
      id: id,
      vehiculoId: 1,
      tipo: TipoGasto.gasolina,
      monto: monto,
      fecha: fecha,
      litros: litros,
      km: km,
    );

final _gastos = [
  _carga(1, DateTime(2026, 11, 2), 1000, 30, 700),
  _carga(2, DateTime(2026, 11, 20), 1360, 30, 750),
];

const _autos = [
  VehiculoGaraje(
    id: 1,
    modelo: 'Aveo',
    anio: 2021,
    marca: 'Chevrolet',
    placas: 'ABC-123',
    vin: 'JM3KFBDM0R0123456',
  ),
];

class _Escenario {
  _Escenario(this.puerto, this.controlador, this.taller, this.eventos);
  final _PuertoFalso puerto;
  final ControladorSesion controlador;
  final _TallerMutable taller;
  final EventosEnVivoFake eventos;

  ProviderContainer contenedor(WidgetTester tester) =>
      ProviderScope.containerOf(tester.element(find.text('inicio')));
}

Future<_Escenario> _montar(
  WidgetTester tester, {
  List<CitaCliente> citas = const [],
  List<OrdenEnCurso> ordenes = const [],
  List<VehiculoGaraje> autos = _autos,
  List<Gasto>? gastos,
  Object? falloCitas,
  Object? falloTaller,
  Object? falloGaraje,
  Object? falloPlan,
  Object? falloGastos,
  bool conSesion = true,
  Locale idioma = const Locale('es'),
  PoliticaDatosLocales? politica,
}) async {
  tester.platformDispatcher.localesTestValue = [idioma];
  addTearDown(tester.platformDispatcher.clearLocalesTestValue);
  final puerto = _PuertoFalso();
  final taller = _TallerMutable(ordenes)..falla = falloTaller;
  final eventos = EventosEnVivoFake();
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
        puertoWidgetsProvider.overrideWithValue(puerto),
        repositorioCitasProvider.overrideWithValue(
          RepositorioCitasFake(
            citas: citas,
            error: falloCitas,
            reloj: () => _ahora,
          ),
        ),
        repositorioTallerProvider.overrideWithValue(taller),
        repositorioGarajeProvider.overrideWithValue(
          falloGaraje == null
              ? RepositorioGarajeFake(datos: autos)
              : RepositorioGarajeFake(fallar: true),
        ),
        repositorioMantenimientoProvider.overrideWithValue(
          RepositorioMantenimientoFake(error: falloPlan),
        ),
        repositorioBitacoraProvider.overrideWithValue(
          RepositorioBitacoraFake(
            gastos: gastos ?? const [],
            error: falloGastos,
          ),
        ),
        eventosEnVivoProvider.overrideWithValue(eventos),
        relojCitasProvider.overrideWithValue(() => _ahora),
        relojBitacoraProvider.overrideWithValue(() => _ahora),
        controladorSesionProvider.overrideWithValue(controlador),
        if (politica != null)
          politicaDatosLocalesProvider.overrideWithValue(politica),
      ],
      child: MaterialApp(
        localizationsDelegates: delegadasDeIdioma,
        supportedLocales: idiomasSoportados,
        localeResolutionCallback: resolverIdioma,
        builder: (context, child) => SincronizadorDeWidgets(child: child!),
        home: const Text('inicio'),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return _Escenario(puerto, controlador, taller, eventos);
}

void main() {
  group('con datos', () {
    testWidgets('publica los cinco widgets, cada uno con sus claves', (
      tester,
    ) async {
      final e = await _montar(
        tester,
        citas: [_cita(2, DateTime(2026, 11, 25))],
        ordenes: [_orden()],
        gastos: _gastos,
      );
      for (final tipo in TipoWidget.values) {
        expect(e.puerto.ultimoDe(tipo), isNotNull, reason: '$tipo');
      }
      final cita = e.puerto.ultimoDe(TipoWidget.proximaCita)!;
      expect(cita.hayDatos, isTrue);
      expect(cita.datos['dia'], '25');
      expect(cita.enlace, 'carecar://citas/2/comprobante');

      final taller = e.puerto.ultimoDe(TipoWidget.taller)!;
      expect(taller.datos['etapa'], 'En reparación');
      expect(taller.datos['paso'], 4);
      expect(taller.enlace, 'carecar://taller/41');

      final mant = e.puerto.ultimoDe(TipoWidget.mantenimiento)!;
      expect(mant.hayDatos, isTrue);
      expect(mant.datos['servicio'], 'Servicio de 10,000 km');
      expect(mant.enlace, 'carecar://mantenimiento/1');

      final bit = e.puerto.ultimoDe(TipoWidget.bitacora)!;
      expect(bit.datos['rendimiento'], '12.0');
      expect(bit.datos['gasto'], r'$1,450');
      expect(bit.enlace, 'carecar://bitacora/1');

      final acc = e.puerto.ultimoDe(TipoWidget.accesos)!;
      expect(acc.datos['enlace_comprobante'], 'carecar://citas/2/comprobante');
    });

    testWidgets('los textos siguen el idioma del telefono', (tester) async {
      final e = await _montar(
        tester,
        citas: [_cita(2, DateTime(2026, 11, 25))],
        ordenes: [_orden()],
        idioma: const Locale('en'),
      );
      expect(
        e.puerto.ultimoDe(TipoWidget.proximaCita)!.datos['titulo'],
        'Next appointment',
      );
      expect(
        e.puerto.ultimoDe(TipoWidget.taller)!.datos['titulo'],
        'Live workshop',
      );
    });

    testWidgets('no viajan asesor, placas ni VIN', (tester) async {
      final e = await _montar(
        tester,
        citas: [_cita(2, DateTime(2026, 11, 25))],
        ordenes: [_orden()],
        gastos: _gastos,
      );
      final todo = e.puerto.publicados
          .expand((c) => c.almacen.values)
          .join('|');
      for (final privado in ['Laura', 'ABC-123', 'JM3KFBDM0R0123456']) {
        expect(todo, isNot(contains(privado)));
      }
    });
  });

  group('vacio', () {
    testWidgets('sin citas, ordenes, plan ni gastos cada widget invita', (
      tester,
    ) async {
      final e = await _montar(tester);
      expect(e.puerto.ultimoDe(TipoWidget.proximaCita)!.hayDatos, isFalse);
      expect(e.puerto.ultimoDe(TipoWidget.taller)!.hayDatos, isFalse);
      expect(e.puerto.ultimoDe(TipoWidget.bitacora)!.hayDatos, isFalse);
      expect(e.puerto.ultimoDe(TipoWidget.taller)!.datos['accion'], 'Agendar');
    });

    testWidgets('sin vehiculos mantenimiento y bitacora quedan vacios', (
      tester,
    ) async {
      final e = await _montar(tester, autos: const [], gastos: _gastos);
      expect(e.puerto.ultimoDe(TipoWidget.mantenimiento)!.hayDatos, isFalse);
      expect(e.puerto.ultimoDe(TipoWidget.bitacora)!.hayDatos, isFalse);
    });
  });

  group('error', () {
    testWidgets('si fallan las citas no publica ninguna cita ni se rompe', (
      tester,
    ) async {
      final e = await _montar(tester, falloCitas: Exception('sin red'));
      expect(e.puerto.ultimoDe(TipoWidget.proximaCita), isNull);
      expect(e.puerto.ultimoDe(TipoWidget.taller), isNotNull);
      expect(tester.takeException(), isNull);
    });

    testWidgets('si fallan ordenes, plan y gastos conserva lo anterior', (
      tester,
    ) async {
      final e = await _montar(
        tester,
        falloTaller: Exception('sin red'),
        falloPlan: Exception('sin red'),
        falloGastos: Exception('sin red'),
      );
      expect(e.puerto.ultimoDe(TipoWidget.taller), isNull);
      expect(e.puerto.ultimoDe(TipoWidget.mantenimiento), isNull);
      expect(e.puerto.ultimoDe(TipoWidget.bitacora), isNull);
    });

    testWidgets('si falla el garaje no publica mantenimiento ni bitacora', (
      tester,
    ) async {
      final e = await _montar(tester, falloGaraje: Exception('sin red'));
      expect(e.puerto.ultimoDe(TipoWidget.mantenimiento), isNull);
      expect(e.puerto.ultimoDe(TipoWidget.bitacora), isNull);
    });

    testWidgets('si falla al actualizar conserva la orden que ya mostraba', (
      tester,
    ) async {
      final e = await _montar(tester, ordenes: [_orden()]);
      e.taller.falla = Exception('sin red');
      e.eventos.emitir('orden', {'ordenId': 41});
      await tester.pumpAndSettle();
      expect(e.puerto.ultimoDe(TipoWidget.taller)!.hayDatos, isTrue);
    });
  });

  group('cuando se actualiza', () {
    testWidgets('un evento de orden actualiza la etapa con la app abierta', (
      tester,
    ) async {
      final e = await _montar(tester, ordenes: [_orden()]);
      expect(e.puerto.ultimoDe(TipoWidget.taller)!.datos['paso'], 4);

      e.taller.abiertas = [_orden(etapa: EtapaTaller.listoParaEntrega)];
      e.eventos.emitir('orden', {'ordenId': 41});
      await tester.pumpAndSettle();

      expect(e.puerto.ultimoDe(TipoWidget.taller)!.datos['paso'], 7);
    });

    testWidgets('al entregarse la orden el taller vuelve a estar vacio', (
      tester,
    ) async {
      final e = await _montar(tester, ordenes: [_orden()]);
      e.taller.abiertas = [];
      e.eventos.emitir('orden', {'ordenId': 41});
      await tester.pumpAndSettle();
      expect(e.puerto.ultimoDe(TipoWidget.taller)!.hayDatos, isFalse);
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

    testWidgets('otros eventos no consultan las ordenes', (tester) async {
      final e = await _montar(tester, ordenes: [_orden()]);
      final antes = e.taller.consultas;
      e.eventos.emitir('asistencia.estado', {'solicitudId': 1});
      await tester.pumpAndSettle();
      expect(e.taller.consultas, antes);
    });

    testWidgets('al volver a primer plano consulta de nuevo las ordenes', (
      tester,
    ) async {
      final e = await _montar(tester, ordenes: [_orden()]);
      e.taller.abiertas = [_orden(etapa: EtapaTaller.lavado)];
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();
      expect(e.puerto.ultimoDe(TipoWidget.taller)!.datos['paso'], 6);
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
      e
          .contenedor(tester)
          .read(misCitasProvider.notifier)
          .reemplazar(
            _cita(2, DateTime(2026, 11, 25), estado: EstadoDeCita.cancelada),
          );
      await tester.pumpAndSettle();
      expect(
        e.puerto.ultimoDe(TipoWidget.proximaCita)!.enlace,
        'carecar://citas/1/comprobante',
      );
      // Los accesos tambien apuntan al comprobante de la nueva proxima cita.
      expect(
        e.puerto.ultimoDe(TipoWidget.accesos)!.datos['enlace_comprobante'],
        'carecar://citas/1/comprobante',
      );
    });

    testWidgets('un gasto nuevo actualiza la bitacora', (tester) async {
      final e = await _montar(tester, gastos: _gastos);
      expect(e.puerto.ultimoDe(TipoWidget.bitacora)!.datos['gasto'], r'$1,450');

      await e
          .contenedor(tester)
          .read(gastosProvider(1).notifier)
          .registrar(
            BorradorGasto(
              tipo: TipoGasto.lavado,
              monto: 50,
              fecha: DateTime(2026, 11, 21),
            ),
          );
      await tester.pumpAndSettle();

      expect(e.puerto.ultimoDe(TipoWidget.bitacora)!.datos['gasto'], r'$1,500');
    });

    testWidgets('no repinta un widget cuyo contenido no cambio', (
      tester,
    ) async {
      final e = await _montar(tester, ordenes: [_orden()], gastos: _gastos);
      final antes = e.puerto.vecesPublicado(TipoWidget.bitacora);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();
      expect(e.puerto.vecesPublicado(TipoWidget.bitacora), antes);
    });
  });

  group('sesion y seguridad', () {
    testWidgets('al cerrar sesion se borra todo', (tester) async {
      final e = await _montar(
        tester,
        citas: [_cita(2, DateTime(2026, 11, 25))],
        ordenes: [_orden()],
        gastos: _gastos,
      );
      expect(e.puerto.borrados, 0);

      await e.controlador.cerrarSesion();
      await tester.pumpAndSettle();

      expect(e.puerto.borrados, 1);
      expect(e.puerto.publicados, isEmpty);
    });

    testWidgets('sin sesion no se piden datos ni se abre el canal', (
      tester,
    ) async {
      final e = await _montar(
        tester,
        conSesion: false,
        citas: [_cita(2, DateTime(2026, 11, 25))],
        ordenes: [_orden()],
      );
      expect(e.puerto.borrados, greaterThan(0));
      expect(e.puerto.publicados, isEmpty);
      expect(e.taller.consultas, 0);
      expect(e.eventos.aperturas, 0);
    });

    testWidgets('en equipo comprometido no se publica nada', (tester) async {
      final e = await _montar(
        tester,
        ordenes: [_orden()],
        politica: PoliticaDatosLocales(EstadoIntegridad.comprometido),
      );
      expect(e.puerto.publicados, isEmpty);
      expect(e.taller.consultas, 0);
    });

    testWidgets('si el equipo resulta comprometido despues, se borra todo', (
      tester,
    ) async {
      final politica = PoliticaDatosLocales();
      final e = await _montar(tester, ordenes: [_orden()], politica: politica);
      expect(e.puerto.publicados, isNotEmpty);

      politica.actualizar(EstadoIntegridad.comprometido);
      await tester.pumpAndSettle();

      expect(e.puerto.borrados, greaterThan(0));
      expect(e.puerto.publicados, isEmpty);
    });

    testWidgets('un sistema sin widgets no afecta a la app', (tester) async {
      final puerto = _PuertoFalso()..fallo = StateError('sin widgets');
      final controlador = ControladorSesion(ApiFalsa(), AlmacenEnMemoria());
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            puertoWidgetsProvider.overrideWithValue(puerto),
            repositorioTallerProvider.overrideWithValue(_TallerMutable([])),
            eventosEnVivoProvider.overrideWithValue(EventosEnVivoFake()),
            controladorSesionProvider.overrideWithValue(controlador),
          ],
          child: MaterialApp(
            localizationsDelegates: delegadasDeIdioma,
            supportedLocales: idiomasSoportados,
            builder: (context, child) => SincronizadorDeWidgets(child: child!),
            home: const Text('inicio'),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('inicio'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
