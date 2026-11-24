import 'dart:async';

import 'package:carecar_mobile/api/excepciones.dart';
import 'package:carecar_mobile/l10n/idiomas.dart';
import 'package:carecar_mobile/modulos/asistencia/datos/repositorio_asistencia_fake.dart';
import 'package:carecar_mobile/modulos/asistencia/dominio/repositorio_asistencia.dart';
import 'package:carecar_mobile/modulos/asistencia/dominio/solicitud_asistencia.dart';
import 'package:carecar_mobile/modulos/asistencia/presentacion/pantalla_pedir_ayuda.dart';
import 'package:carecar_mobile/modulos/asistencia/presentacion/proveedores_asistencia.dart';
import 'package:carecar_mobile/modulos/vehiculos/datos/repositorio_garaje_fake.dart';
import 'package:carecar_mobile/modulos/vehiculos/presentacion/proveedores_vehiculos.dart';
import 'package:carecar_mobile/nucleo/diseno/tema_pista.dart';
import 'package:carecar_mobile/nucleo/eventos/eventos_en_vivo_fake.dart';
import 'package:carecar_mobile/nucleo/eventos/proveedores_eventos.dart';
import 'package:carecar_mobile/nucleo/mapas/mapas.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Repositorio cuyo POST responde 409 y cuyo GET ya trae la solicitud abierta
/// (otra persona o otro telefono la creo mientras el cliente llenaba la
/// pantalla).
class _CarreraConAbierta implements RepositorioAsistencia {
  _CarreraConAbierta(this.existente);

  final SolicitudAsistencia existente;
  bool consultada = false;

  @override
  Future<SolicitudAsistencia> pedirAyuda({
    required int vehiculoId,
    required TipoAsistencia tipo,
    Coordenada? ubicacion,
    String? comentario,
  }) async => throw const SolicitudAbierta();

  @override
  Future<SolicitudAsistencia?> activa() async {
    if (!consultada) {
      consultada = true;
      return null;
    }
    return existente;
  }

  @override
  Future<SolicitudAsistencia> obtener(int id) async => existente;
}

Future<void> _montar(
  WidgetTester tester, {
  RepositorioAsistencia? repo,
  RepositorioGarajeFake? garaje,
  UbicacionFalsa? ubicacion,
  Size tamano = const Size(800, 1800),
  double escala = 1,
}) async {
  tester.view.physicalSize = tamano;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        eventosEnVivoProvider.overrideWithValue(EventosEnVivoFake()),
        repositorioAsistenciaProvider.overrideWithValue(
          repo ?? RepositorioAsistenciaFake(),
        ),
        repositorioGarajeProvider.overrideWithValue(
          garaje ?? RepositorioGarajeFake(),
        ),
        proveedorUbicacionProvider.overrideWithValue(
          ubicacion ?? UbicacionFalsa(),
        ),
      ],
      child: MaterialApp(
        theme: TemaPista.claro(),
        locale: const Locale('es'),
        localizationsDelegates: delegadasDeIdioma,
        supportedLocales: idiomasSoportados,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(escala),
            disableAnimations: true,
          ),
          child: child!,
        ),
        home: const PantallaPedirAyuda(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _tocar(WidgetTester tester, String texto) async {
  await tester.ensureVisible(find.text(texto).first);
  await tester.pumpAndSettle();
  await tester.tap(find.text(texto).first);
  await tester.pumpAndSettle();
}

Future<void> _deslizar(WidgetTester tester) async {
  final perilla = find.byKey(const ValueKey('perilla'));
  await tester.ensureVisible(perilla);
  await tester.pumpAndSettle();
  await tester.drag(perilla, const Offset(700, 0));
  await tester.pumpAndSettle();
}

Future<void> _llenarLoBasico(WidgetTester tester) async {
  await _tocar(tester, 'Mazda CX-5 2024');
  await _tocar(tester, 'Llanta');
}

void main() {
  testWidgets('trae vehiculos, tipos, ubicacion y el control de deslizar', (
    tester,
  ) async {
    await _montar(tester);
    expect(find.text('Pedir ayuda'), findsWidgets);
    expect(find.text('Mazda CX-5 2024'), findsOneWidget);
    expect(find.text('Mazda 3 2022'), findsOneWidget);
    for (final tipo in [
      'Llanta',
      'Batería',
      'Choque',
      'Sin gasolina',
      'Otro',
    ]) {
      expect(find.text(tipo), findsOneWidget);
    }
    expect(find.text('Compartir mi ubicación'), findsOneWidget);
    expect(find.text('Desliza para pedir ayuda'), findsOneWidget);
  });

  testWidgets('sin vehiculo y tipo, deslizar no envia nada', (tester) async {
    final repo = RepositorioAsistenciaFake();
    await _montar(tester, repo: repo);
    await _deslizar(tester);
    expect(repo.pedidos, isEmpty);
    await _tocar(tester, 'Mazda CX-5 2024');
    await _deslizar(tester);
    expect(repo.pedidos, isEmpty, reason: 'falta el tipo');
  });

  testWidgets(
    'crea la solicitud con vehiculo, tipo y ubicacion y da el folio',
    (tester) async {
      final repo = RepositorioAsistenciaFake();
      await _montar(
        tester,
        repo: repo,
        ubicacion: UbicacionFalsa(
          posicion: const Coordenada(19.4326, -99.1332),
        ),
      );
      await _llenarLoBasico(tester);
      await _tocar(tester, 'Compartir mi ubicación');
      expect(find.text('Ubicación lista para enviar'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'Frente a la gasolinera');
      await _deslizar(tester);

      final pedido = repo.pedidos.single;
      expect(pedido.vehiculoId, 1);
      expect(pedido.tipo, TipoAsistencia.llanta);
      expect(pedido.ubicacion, const Coordenada(19.4326, -99.1332));
      expect(pedido.comentario, 'Frente a la gasolinera');
      expect(find.text('Folio 1'), findsOneWidget);
      expect(find.text('Solicitud recibida'), findsWidgets);
      expect(find.text('Compartida con la agencia'), findsOneWidget);
      // La pantalla no pone las coordenadas a la vista ni las repite.
      expect(find.textContaining('19.43'), findsNothing);
    },
  );

  testWidgets('sin compartir ubicacion se envia sin coordenadas', (
    tester,
  ) async {
    final repo = RepositorioAsistenciaFake();
    final ubicacion = UbicacionFalsa();
    await _montar(tester, repo: repo, ubicacion: ubicacion);
    await _llenarLoBasico(tester);
    await _deslizar(tester);
    expect(repo.pedidos.single.ubicacion, isNull);
    expect(ubicacion.consultasDePosicion, 0);
    expect(find.text('No compartida'), findsOneWidget);
  });

  testWidgets('permiso denegado: explica y deja enviar sin ubicacion', (
    tester,
  ) async {
    final repo = RepositorioAsistenciaFake();
    await _montar(
      tester,
      repo: repo,
      ubicacion: UbicacionFalsa(permiso: PermisoUbicacion.denegado),
    );
    await _llenarLoBasico(tester);
    await _tocar(tester, 'Compartir mi ubicación');
    expect(find.textContaining('No diste permiso'), findsOneWidget);
    expect(find.text('Dónde estás y qué pasó'), findsOneWidget);
    await _tocar(tester, 'Enviar sin ubicación');
    expect(find.textContaining('No diste permiso'), findsNothing);
    await _deslizar(tester);
    expect(repo.pedidos.single.ubicacion, isNull);
  });

  testWidgets('permiso bloqueado para siempre manda a Ajustes', (tester) async {
    await _montar(
      tester,
      ubicacion: UbicacionFalsa(permiso: PermisoUbicacion.denegadoParaSiempre),
    );
    await _tocar(tester, 'Compartir mi ubicación');
    expect(find.textContaining('bloqueado'), findsOneWidget);
    expect(find.textContaining('Ajustes'), findsOneWidget);
  });

  testWidgets(
    'servicio apagado y tiempo agotado tienen su mensaje y reintento',
    (tester) async {
      final ubicacion = UbicacionFalsa(error: const UbicacionServicioApagado());
      await _montar(tester, ubicacion: ubicacion);
      await _tocar(tester, 'Compartir mi ubicación');
      expect(find.textContaining('está apagada'), findsOneWidget);

      ubicacion.error = const UbicacionTiempoAgotado();
      await _tocar(tester, 'Intentar de nuevo');
      expect(find.textContaining('a tiempo'), findsOneWidget);

      ubicacion.error = null;
      await _tocar(tester, 'Intentar de nuevo');
      expect(find.text('Ubicación lista para enviar'), findsOneWidget);
    },
  );

  testWidgets('sin conexion al enviar avisa y deja intentar de nuevo', (
    tester,
  ) async {
    final repo = RepositorioAsistenciaFake(fallo: const SinConexion());
    await _montar(tester, repo: repo);
    await _llenarLoBasico(tester);
    await _deslizar(tester);
    expect(find.textContaining('Sin conexión'), findsOneWidget);
    expect(find.textContaining('911'), findsOneWidget);
    expect(find.text('Desliza para pedir ayuda'), findsOneWidget);
    repo.fallo = null;
    await _deslizar(tester);
    expect(find.text('Folio 1'), findsOneWidget);
  });

  testWidgets('vehiculo ajeno (404) explica y deja elegir otro', (
    tester,
  ) async {
    final repo = RepositorioAsistenciaFake(
      fallo: const NoEncontrado('No existe'),
    );
    await _montar(tester, repo: repo);
    await _llenarLoBasico(tester);
    await _deslizar(tester);
    expect(find.textContaining('No encontramos ese vehículo'), findsOneWidget);
  });

  testWidgets('si ya hay una solicitud abierta al entrar, la muestra', (
    tester,
  ) async {
    final repo = RepositorioAsistenciaFake(
      abierta: SolicitudAsistencia(
        id: 41,
        vehiculoId: 1,
        tipo: TipoAsistencia.bateria,
        estado: EstadoSolicitud.enCamino,
        creadaEn: DateTime(2026, 11, 23, 10),
      ),
    );
    await _montar(tester, repo: repo);
    expect(find.text('Folio 41'), findsOneWidget);
    expect(
      find.textContaining('Ya tenías una solicitud abierta'),
      findsOneWidget,
    );
    expect(find.text('Desliza para pedir ayuda'), findsNothing);
  });

  testWidgets('un 409 al enviar muestra la solicitud que ya existia', (
    tester,
  ) async {
    final repo = _CarreraConAbierta(
      SolicitudAsistencia(
        id: 77,
        vehiculoId: 2,
        tipo: TipoAsistencia.choque,
        estado: EstadoSolicitud.recibida,
        creadaEn: DateTime(2026, 11, 23, 10),
      ),
    );
    await _montar(tester, repo: repo);
    await _llenarLoBasico(tester);
    await _deslizar(tester);
    expect(find.text('Folio 77'), findsOneWidget);
    expect(
      find.textContaining('Ya tenías una solicitud abierta'),
      findsOneWidget,
    );
  });

  group('cinco estados', () {
    testWidgets('cargando', (tester) async {
      final espera = Completer<void>();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            repositorioAsistenciaProvider.overrideWithValue(
              RepositorioAsistenciaFake(espera: espera.future),
            ),
            repositorioGarajeProvider.overrideWithValue(
              RepositorioGarajeFake(),
            ),
            proveedorUbicacionProvider.overrideWithValue(UbicacionFalsa()),
          ],
          child: MaterialApp(
            theme: TemaPista.claro(),
            locale: const Locale('es'),
            localizationsDelegates: delegadasDeIdioma,
            supportedLocales: idiomasSoportados,
            home: const PantallaPedirAyuda(),
          ),
        ),
      );
      await tester.pump();
      expect(find.bySemanticsLabel('Cargando'), findsOneWidget);
      espera.complete();
      await tester.pumpAndSettle();
      expect(find.text('Desliza para pedir ayuda'), findsOneWidget);
    });

    testWidgets('error al consultar la solicitud abierta, con reintento', (
      tester,
    ) async {
      final repo = RepositorioAsistenciaFake(
        falloAlConsultar: const SinConexion(),
      );
      await _montar(tester, repo: repo);
      expect(find.text('Reintentar'), findsOneWidget);
      repo.falloAlConsultar = null;
      await _tocar(tester, 'Reintentar');
      expect(find.text('Desliza para pedir ayuda'), findsOneWidget);
    });

    testWidgets('garaje vacio', (tester) async {
      await _montar(tester, garaje: RepositorioGarajeFake(datos: const []));
      expect(find.text('Aún no tienes vehículos'), findsOneWidget);
      expect(find.text('Desliza para pedir ayuda'), findsNothing);
    });

    testWidgets('error del garaje con reintento', (tester) async {
      await _montar(tester, garaje: RepositorioGarajeFake(fallar: true));
      expect(find.text('Reintentar'), findsOneWidget);
    });
  });

  testWidgets('cada tipo de problema se anuncia como seleccionable', (
    tester,
  ) async {
    final semantica = tester.ensureSemantics();
    await _montar(tester);
    await _tocar(tester, 'Choque');
    expect(
      tester.getSemantics(find.text('Choque')),
      matchesSemantics(
        label: 'Choque',
        isButton: true,
        isSelected: true,
        isEnabled: true,
        hasEnabledState: true,
        hasSelectedState: true,
        hasTapAction: true,
      ),
    );
    semantica.dispose();
  });

  testWidgets('con letra al 200 % y pantalla chica no se desborda', (
    tester,
  ) async {
    await _montar(tester, tamano: const Size(320, 568), escala: 2);
    expect(tester.takeException(), isNull);
    await _llenarLoBasico(tester);
    await _tocar(tester, 'Compartir mi ubicación');
    expect(tester.takeException(), isNull);
    await _deslizar(tester);
    expect(find.textContaining('Folio'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('ningun contenido atraviesa el titulo al desplazar', (
    tester,
  ) async {
    await _montar(tester, tamano: const Size(390, 500));
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -300));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.byType(BackdropFilter), findsWidgets);
  });
}
