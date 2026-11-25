import 'dart:async';

import 'package:carecar_mobile/l10n/idiomas.dart';
import 'package:carecar_mobile/modulos/catalogo/catalogo.dart';
import 'package:carecar_mobile/modulos/estreno/dominio/estreno.dart';
import 'package:carecar_mobile/modulos/estreno/estreno.dart';
import 'package:carecar_mobile/modulos/estreno/presentacion/pantalla_cotizacion_estreno.dart';
import 'package:carecar_mobile/modulos/estreno/presentacion/pantalla_mis_solicitudes.dart';
import 'package:carecar_mobile/modulos/estreno/presentacion/pantalla_prueba_manejo.dart';
import 'package:carecar_mobile/modulos/estreno/presentacion/proveedores_estreno.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/boton_pildora.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/estado_error.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/estado_vacio.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/insignia.dart';
import 'package:carecar_mobile/nucleo/diseno/tema_pista.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../ayudas/auditoria_accesibilidad.dart';
import '../../ayudas/tema_pista.dart';

const _mensualidad = MensualidadEstimada(
  precio: 300000,
  enganche: 30000,
  montoFinanciado: 270000,
  tasaAnual: 0.1499,
  plazoMeses: 48,
  mensualidad: 7512.93,
  leyenda: 'Estimación no vinculante.',
);

/// Repositorio falso: guarda lo que se pidió y falla cuando se le dice.
class _Repo implements RepositorioEstreno {
  final pruebas =
      <({DateTime fecha, FranjaPreferida franja, int? estimacion})>[];
  final cotizaciones = <({double enganche, int plazo, int? estimacion})>[];
  final calculos = <({double enganche, int plazo})>[];

  /// Fallos al pedir (prueba o cotización), uno por intento y en orden.
  final fallosAlPedir = <FalloEstreno>[];

  /// Fallos al listar, uno por intento y en orden.
  final fallosAlListar = <FalloEstreno>[];

  /// Si se asigna, pedir (prueba o cotización) espera a que se complete.
  Completer<void>? esperaAlPedir;

  /// Cada cálculo espera a su Completer, en orden de llegada; sin ellos
  /// responde de inmediato.
  final esperasAlCalcular = <Completer<MensualidadEstimada>>[];
  FalloEstreno? falloAlCalcular;
  PaginaDeSolicitudes pagina = const PaginaDeSolicitudes(
    solicitudes: [],
    pagina: 0,
    hayMas: false,
  );

  /// Lo que devuelve el servidor: repite lo pedido y ya trae vendedor.
  SolicitudDeEstreno _solicitud(
    TipoSolicitud tipo, {
    DateTime? fecha,
    FranjaPreferida? franja,
    MensualidadEstimada? cotizacion,
  }) => SolicitudDeEstreno(
    id: 1,
    tipo: tipo,
    modelo: 'Nissan Kicks 2026',
    estado: EstadoSolicitud.enAtencion,
    vendedor: 'Vera',
    fecha: fecha,
    franja: franja,
    cotizacion: cotizacion,
    creadaEn: DateTime(2026, 11, 24),
  );

  @override
  Future<MensualidadEstimada> calcular({
    required int modeloId,
    required double enganche,
    required int plazoMeses,
  }) async {
    calculos.add((enganche: enganche, plazo: plazoMeses));
    if (esperasAlCalcular.isNotEmpty) {
      return esperasAlCalcular.removeAt(0).future;
    }
    final fallo = falloAlCalcular;
    if (fallo != null) throw fallo;
    return _mensualidad;
  }

  @override
  Future<SolicitudDeEstreno> pedirPrueba({
    required int modeloId,
    required DateTime fecha,
    required FranjaPreferida franja,
    int? estimacionId,
  }) async {
    await esperaAlPedir?.future;
    if (fallosAlPedir.isNotEmpty) throw fallosAlPedir.removeAt(0);
    pruebas.add((fecha: fecha, franja: franja, estimacion: estimacionId));
    return _solicitud(TipoSolicitud.pruebaManejo, fecha: fecha, franja: franja);
  }

  @override
  Future<SolicitudDeEstreno> pedirCotizacion({
    required int modeloId,
    required double enganche,
    required int plazoMeses,
    int? estimacionId,
  }) async {
    await esperaAlPedir?.future;
    if (fallosAlPedir.isNotEmpty) throw fallosAlPedir.removeAt(0);
    cotizaciones.add((
      enganche: enganche,
      plazo: plazoMeses,
      estimacion: estimacionId,
    ));
    return _solicitud(TipoSolicitud.cotizacion, cotizacion: _mensualidad);
  }

  @override
  Future<PaginaDeSolicitudes> solicitudes({int pagina = 0}) async {
    if (fallosAlListar.isNotEmpty) throw fallosAlListar.removeAt(0);
    return this.pagina;
  }
}

DetalleModelo _detalle({double? precio = 300000}) => DetalleModelo(
  modelo: ModeloVigente(
    id: 7,
    nombre: 'Kicks',
    marca: 'Nissan',
    anio: 2026,
    precioDesde: precio,
  ),
);

Estimacion _estimacion(int id, String marca) => Estimacion(
  id: id,
  creadaEn: DateTime(2026, 11, 20),
  marca: marca,
  modelo: 'March',
  anio: 2018,
  km: 60000,
  estado: EstadoAuto.bueno,
  minimo: 120000,
  maximo: 140000,
  edadAnios: 8,
  kmEsperado: 80000,
  margen: 0.08,
);

ProviderScope _escena(
  _Repo repo,
  Widget hijo, {
  double? precio = 300000,
  List<Estimacion> estimaciones = const [],
}) => ProviderScope(
  overrides: [
    repositorioEstrenoProvider.overrideWithValue(repo),
    detalleModeloProvider(7)
        .overrideWith((_) async => _detalle(precio: precio)),
    estimacionesParaAdjuntarProvider.overrideWith((_) async => estimaciones),
    relojEstrenoProvider.overrideWithValue(() => DateTime(2026, 11, 24, 10)),
  ],
  child: hijo,
);

Widget _app(
  Widget pantalla,
  _Repo repo, {
  double? precio = 300000,
  List<Estimacion> estimaciones = const [],
  Escenario escenario = Escenario.claro,
}) => _escena(
  repo,
  conTemaPista(pantalla, escenario: escenario),
  precio: precio,
  estimaciones: estimaciones,
);

/// Con las rutas reales del módulo, para probar a dónde lleva cada toque.
Widget _appConRutas(_Repo repo, String inicial) => _escena(
  repo,
  MaterialApp.router(
    locale: idiomaBase,
    localizationsDelegates: delegadasDeIdioma,
    supportedLocales: idiomasSoportados,
    theme: TemaPista.claro(),
    routerConfig: GoRouter(initialLocation: inicial, routes: rutasEstreno),
  ),
);

void _prueba(String descripcion, Future<void> Function(WidgetTester) cuerpo) =>
    testWidgets(descripcion, (tester) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await cuerpo(tester);
    });

/// Deja correr los cuadros que hacen falta para que se vea lo que ya llegó,
/// sin esperar a lo que sigue pendiente (un esqueleto nunca "se asienta").
Future<void> _dejarCorrer(WidgetTester tester) async {
  for (var i = 0; i < 3; i++) {
    await tester.pump();
  }
}

BotonPildora _botonEnviarCotizacion(WidgetTester tester) =>
    tester.widget<BotonPildora>(
      find.ancestor(
        of: find.textContaining(RegExp('Enviar cotización|Enviando')),
        matching: find.byType(BotonPildora),
      ),
    );

/// Elige el 26 de noviembre en la tarde, lo que casi todas las pruebas piden.
Future<void> _elegirDiaYTarde(WidgetTester tester) async {
  await tester.tap(find.textContaining('26 nov'));
  await tester.tap(find.text('Tarde (13 a 18 h)'));
  await tester.pump();
}

void main() {
  group('Quiero probarlo (V2-M16.01)', () {
    _prueba('no deja enviar hasta elegir dia y franja, y confirma', (
      tester,
    ) async {
      final repo = _Repo();
      await tester.pumpWidget(
        _app(const PantallaPruebaManejo(modeloId: 7), repo),
      );
      await tester.pumpAndSettle();
      expect(find.text('Nissan Kicks 2026'), findsOneWidget);

      BotonPildora botonEnviar() => tester.widget<BotonPildora>(
        find.widgetWithText(BotonPildora, 'Enviar solicitud'),
      );
      expect(botonEnviar().alPresionar, isNull);
      await tester.tap(find.text('Enviar solicitud'));
      await tester.pump();
      expect(repo.pruebas, isEmpty);

      await _elegirDiaYTarde(tester);
      expect(botonEnviar().alPresionar, isNotNull);
      await tester.tap(find.text('Enviar solicitud'));
      await tester.pumpAndSettle();

      final pedida = repo.pruebas.single;
      expect(pedida.fecha, DateTime(2026, 11, 26));
      expect(pedida.franja, FranjaPreferida.tarde);
      expect(pedida.estimacion, isNull);
      expect(find.textContaining('Un asesor te contactará'), findsOneWidget);
      expect(find.text('Ver mis solicitudes'), findsOneWidget);
      // La confirmación repite lo pedido y dice quién atiende.
      expect(find.textContaining('26 nov'), findsOneWidget);
      expect(find.text('Tarde (13 a 18 h)'), findsOneWidget);
      expect(find.textContaining('Te atiende Vera'), findsOneWidget);
    });

    _prueba('los dias empiezan mañana', (tester) async {
      await tester.pumpWidget(
        _app(const PantallaPruebaManejo(modeloId: 7), _Repo()),
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('24 nov'), findsNothing);
      expect(find.textContaining('25 nov'), findsOneWidget);
    });

    _prueba('una solicitud repetida se explica', (tester) async {
      final repo = _Repo()..fallosAlPedir.add(const EstrenoDuplicada());
      await tester.pumpWidget(
        _app(const PantallaPruebaManejo(modeloId: 7), repo),
      );
      await tester.pumpAndSettle();
      await _elegirDiaYTarde(tester);
      await tester.tap(find.text('Enviar solicitud'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Ya pediste esto'), findsOneWidget);
    });

    _prueba('sin conexion se explica y se puede reintentar', (tester) async {
      final repo = _Repo()..fallosAlPedir.add(const EstrenoSinConexion());
      await tester.pumpWidget(
        _app(const PantallaPruebaManejo(modeloId: 7), repo),
      );
      await tester.pumpAndSettle();
      await _elegirDiaYTarde(tester);

      await tester.tap(find.text('Enviar solicitud'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Revisa tu internet'), findsOneWidget);
      expect(repo.pruebas, isEmpty);

      await tester.tap(find.text('Enviar solicitud'));
      await tester.pumpAndSettle();
      expect(repo.pruebas, hasLength(1));
      expect(find.textContaining('Un asesor te contactará'), findsOneWidget);
    });

    _prueba('mientras envia lo dice y no deja volver a enviar', (tester) async {
      final repo = _Repo()..esperaAlPedir = Completer<void>();
      await tester.pumpWidget(
        _app(const PantallaPruebaManejo(modeloId: 7), repo),
      );
      await tester.pumpAndSettle();
      await _elegirDiaYTarde(tester);
      await tester.tap(find.text('Enviar solicitud'));
      await tester.pump();

      expect(find.text('Enviando…'), findsOneWidget);
      expect(find.text('Enviar solicitud'), findsNothing);
      final boton = tester.widget<BotonPildora>(
        find.widgetWithText(BotonPildora, 'Enviando…'),
      );
      expect(boton.alPresionar, isNull);

      repo.esperaAlPedir!.complete();
      await tester.pumpAndSettle();
      expect(find.textContaining('Un asesor te contactará'), findsOneWidget);
      expect(repo.pruebas, hasLength(1));
    });
  });

  group('Toma a cuenta (V2-M16.03)', () {
    final estimaciones = [_estimacion(3, 'Nissan'), _estimacion(4, 'Mazda')];

    _prueba('la prueba manda la estimacion que se eligio', (tester) async {
      final repo = _Repo();
      await tester.pumpWidget(
        _app(
          const PantallaPruebaManejo(modeloId: 7),
          repo,
          estimaciones: estimaciones,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('¿Dejas tu auto a cuenta?'), findsOneWidget);

      await _elegirDiaYTarde(tester);
      await tester.tap(find.textContaining('Mazda'));
      await tester.pump();
      await tester.tap(find.text('Enviar solicitud'));
      await tester.pumpAndSettle();
      expect(repo.pruebas.single.estimacion, 4);
    });

    _prueba('la cotizacion manda la estimacion que se eligio', (tester) async {
      final repo = _Repo();
      await tester.pumpWidget(
        _app(
          const PantallaCotizacionEstreno(modeloId: 7),
          repo,
          estimaciones: estimaciones,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.textContaining('Nissan March'));
      await tester.pump();
      await tester.tap(find.text('Enviar cotización'));
      await tester.pumpAndSettle();
      expect(repo.cotizaciones.single.estimacion, 3);
    });

    _prueba('sin estimaciones no ofrece la seccion', (tester) async {
      await tester.pumpWidget(
        _app(const PantallaCotizacionEstreno(modeloId: 7), _Repo()),
      );
      await tester.pumpAndSettle();
      expect(find.text('¿Dejas tu auto a cuenta?'), findsNothing);
    });
  });

  group('Cotización (V2-M16.02)', () {
    _prueba('calcula al abrir y muestra la leyenda no vinculante', (
      tester,
    ) async {
      final repo = _Repo();
      await tester.pumpWidget(
        _app(const PantallaCotizacionEstreno(modeloId: 7), repo),
      );
      await tester.pumpAndSettle();
      expect(find.text('Precio desde \$300,000'), findsOneWidget);
      expect(find.text('Mínimo \$30,000'), findsOneWidget);
      expect(find.text('\$7,513'), findsOneWidget);
      expect(find.text('Estimación no vinculante.'), findsOneWidget);

      await tester.tap(find.text('Enviar cotización'));
      await tester.pumpAndSettle();
      final pedida = repo.cotizaciones.single;
      expect((pedida.enganche, pedida.plazo), (30000.0, 48));
      expect(find.textContaining('Un asesor te contactará'), findsOneWidget);
      // La confirmación repite la mensualidad y el plazo, y dice quién atiende.
      expect(find.text('\$7,513'), findsOneWidget);
      expect(find.textContaining('48 meses'), findsOneWidget);
      expect(find.textContaining('Te atiende Vera'), findsOneWidget);
    });

    _prueba('ofrece los cinco plazos y vuelve a calcular con el elegido', (
      tester,
    ) async {
      final repo = _Repo();
      await tester.pumpWidget(
        _app(const PantallaCotizacionEstreno(modeloId: 7), repo),
      );
      await tester.pumpAndSettle();
      for (final meses in [12, 24, 36, 48, 60]) {
        expect(find.text('$meses meses'), findsWidgets);
      }

      await tester.tap(find.text('24 meses').first);
      await tester.pumpAndSettle();
      expect(repo.calculos.last.plazo, 24);
    });

    _prueba('un modelo sin precio lo explica', (tester) async {
      await tester.pumpWidget(
        _app(
          const PantallaCotizacionEstreno(modeloId: 7),
          _Repo(),
          precio: null,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('aún no tiene precio'), findsOneWidget);
      expect(find.text('Enviar cotización'), findsNothing);
    });

    _prueba('si el servidor rechaza el enganche, muestra su mensaje', (
      tester,
    ) async {
      final repo = _Repo()
        ..falloAlCalcular = const EstrenoDatosInvalidos(
          'El enganche debe ser de al menos \$32990',
        );
      await tester.pumpWidget(
        _app(const PantallaCotizacionEstreno(modeloId: 7), repo),
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('al menos \$32990'), findsOneWidget);
      expect(find.text('\$7,513'), findsNothing);
      final boton = tester.widget<BotonPildora>(
        find.widgetWithText(BotonPildora, 'Enviar cotización'),
      );
      expect(boton.alPresionar, isNull);
    });

    _prueba('una cotizacion repetida se explica', (tester) async {
      final repo = _Repo()..fallosAlPedir.add(const EstrenoDuplicada());
      await tester.pumpWidget(
        _app(const PantallaCotizacionEstreno(modeloId: 7), repo),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Enviar cotización'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Ya pediste esto'), findsOneWidget);
    });

    _prueba('mientras envia lo dice y no deja volver a enviar', (tester) async {
      final repo = _Repo()..esperaAlPedir = Completer<void>();
      await tester.pumpWidget(
        _app(const PantallaCotizacionEstreno(modeloId: 7), repo),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Enviar cotización'));
      await tester.pump();

      expect(find.text('Enviando…'), findsOneWidget);
      expect(find.text('Enviar cotización'), findsNothing);
      final boton = tester.widget<BotonPildora>(
        find.widgetWithText(BotonPildora, 'Enviando…'),
      );
      expect(boton.alPresionar, isNull);

      repo.esperaAlPedir!.complete();
      await tester.pumpAndSettle();
      expect(find.textContaining('Un asesor te contactará'), findsOneWidget);
      expect(repo.cotizaciones, hasLength(1));
    });

    _prueba('mientras calcula lo dice y no deja enviar', (tester) async {
      final calculo = Completer<MensualidadEstimada>();
      final repo = _Repo()..esperasAlCalcular.add(calculo);
      await tester.pumpWidget(
        _app(const PantallaCotizacionEstreno(modeloId: 7), repo),
      );
      await _dejarCorrer(tester);

      expect(find.text('Calculando tu mensualidad…'), findsOneWidget);
      expect(find.text('\$7,513'), findsNothing);
      expect(_botonEnviarCotizacion(tester).alPresionar, isNull);

      calculo.complete(_mensualidad);
      await tester.pumpAndSettle();
      expect(find.text('Calculando tu mensualidad…'), findsNothing);
      expect(find.text('\$7,513'), findsOneWidget);
      expect(_botonEnviarCotizacion(tester).alPresionar, isNotNull);
    });

    _prueba('al cambiar el plazo no se queda la mensualidad anterior', (
      tester,
    ) async {
      final repo = _Repo();
      await tester.pumpWidget(
        _app(const PantallaCotizacionEstreno(modeloId: 7), repo),
      );
      await tester.pumpAndSettle();
      expect(find.text('\$7,513'), findsOneWidget);

      repo.esperasAlCalcular.add(Completer<MensualidadEstimada>());
      await tester.tap(find.text('24 meses').first);
      await _dejarCorrer(tester);
      expect(find.text('\$7,513'), findsNothing);
      expect(_botonEnviarCotizacion(tester).alPresionar, isNull);
    });

    _prueba(
      'al escribir el enganche se oculta la mensualidad hasta recalcular',
      (tester) async {
        final repo = _Repo();
        await tester.pumpWidget(
          _app(const PantallaCotizacionEstreno(modeloId: 7), repo),
        );
        await tester.pumpAndSettle();
        expect(repo.calculos, hasLength(1));

        await tester.enterText(find.byType(TextField), '40000');
        await tester.pump();
        expect(find.text('\$7,513'), findsNothing);
        expect(_botonEnviarCotizacion(tester).alPresionar, isNull);

        await tester.pumpAndSettle(const Duration(milliseconds: 500));
        expect(repo.calculos.last.enganche, 40000);
        expect(find.text('\$7,513'), findsOneWidget);
      },
    );

    _prueba('una respuesta vieja no pisa a la nueva', (tester) async {
      final primera = Completer<MensualidadEstimada>();
      final segunda = Completer<MensualidadEstimada>();
      final repo = _Repo()..esperasAlCalcular.addAll([primera, segunda]);
      await tester.pumpWidget(
        _app(const PantallaCotizacionEstreno(modeloId: 7), repo),
      );
      await _dejarCorrer(tester);
      await tester.tap(find.text('24 meses').first);
      await _dejarCorrer(tester);
      expect(repo.calculos.map((c) => c.plazo), [48, 24]);

      segunda.complete(
        const MensualidadEstimada(
          precio: 300000,
          enganche: 30000,
          montoFinanciado: 270000,
          tasaAnual: 0.1499,
          plazoMeses: 24,
          mensualidad: 5000,
          leyenda: 'Estimación no vinculante.',
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('\$5,000'), findsOneWidget);

      // Llega tarde la del plazo anterior: no debe sustituir a la nueva.
      primera.complete(_mensualidad);
      await tester.pumpAndSettle();
      expect(find.text('\$5,000'), findsOneWidget);
      expect(find.text('\$7,513'), findsNothing);
    });
  });

  group('Mis solicitudes (V2-M16.04)', () {
    _prueba('sin solicitudes lo dice', (tester) async {
      await tester.pumpWidget(_app(const PantallaMisSolicitudes(), _Repo()));
      await tester.pumpAndSettle();
      expect(find.byType(EstadoVacio), findsOneWidget);
    });

    _prueba('muestra el estado con texto y quien atiende', (tester) async {
      final repo = _Repo()
        ..pagina = PaginaDeSolicitudes(
          solicitudes: [
            SolicitudDeEstreno(
              id: 1,
              tipo: TipoSolicitud.cotizacion,
              modelo: 'Nissan Kicks 2026',
              estado: EstadoSolicitud.enAtencion,
              vendedor: 'Vera',
              cotizacion: _mensualidad,
              creadaEn: DateTime(2026, 11, 24),
            ),
          ],
          pagina: 0,
          hayMas: false,
        );
      await tester.pumpWidget(_app(const PantallaMisSolicitudes(), repo));
      await tester.pumpAndSettle();
      expect(find.text('Nissan Kicks 2026'), findsOneWidget);
      expect(find.widgetWithText(Insignia, 'En atención'), findsOneWidget);
      expect(find.textContaining('Te atiende Vera'), findsOneWidget);
    });

    _prueba('sin conexion ofrece reintentar y recupera', (tester) async {
      final repo = _Repo()..fallosAlListar.add(const EstrenoSinConexion());
      await tester.pumpWidget(_app(const PantallaMisSolicitudes(), repo));
      await tester.pumpAndSettle();
      expect(find.byType(EstadoError), findsOneWidget);
      expect(find.byType(EstadoVacio), findsNothing);

      await tester.tap(find.text('Reintentar'));
      await tester.pumpAndSettle();
      expect(find.byType(EstadoError), findsNothing);
      expect(find.byType(EstadoVacio), findsOneWidget);
    });

    _prueba('desde la confirmacion se llega a la lista', (tester) async {
      await tester.pumpWidget(_appConRutas(_Repo(), rutaPruebaManejo(7)));
      await tester.pumpAndSettle();
      await _elegirDiaYTarde(tester);
      await tester.tap(find.text('Enviar solicitud'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Ver mis solicitudes'));
      await tester.pumpAndSettle();
      expect(find.byType(PantallaMisSolicitudes), findsOneWidget);
    });
  });

  group('Claro, oscuro y letra grande', () {
    _prueba('las tres pantallas se ven sin desbordar', (tester) async {
      for (final escenario in Escenario.values) {
        for (final pantalla in const [
          PantallaPruebaManejo(modeloId: 7),
          PantallaCotizacionEstreno(modeloId: 7),
          PantallaMisSolicitudes(),
        ]) {
          await tester.pumpWidget(
            _app(
              pantalla,
              _Repo(),
              escenario: escenario,
              estimaciones: [_estimacion(3, 'Nissan')],
            ),
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        }
      }
    });

    _prueba('las tres pantallas pasan la auditoria de accesibilidad', (
      tester,
    ) async {
      for (final escenario in [Escenario.claro, Escenario.oscuro]) {
        for (final pantalla in const [
          PantallaPruebaManejo(modeloId: 7),
          PantallaCotizacionEstreno(modeloId: 7),
          PantallaMisSolicitudes(),
        ]) {
          await tester.pumpWidget(
            _app(
              pantalla,
              _Repo(),
              escenario: escenario,
              estimaciones: [_estimacion(3, 'Nissan')],
            ),
          );
          await tester.pumpAndSettle();
          await auditarAccesibilidad(tester);
        }
      }
    });
  });
}
