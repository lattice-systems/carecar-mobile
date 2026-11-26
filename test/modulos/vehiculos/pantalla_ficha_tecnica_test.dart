import 'dart:async';

import 'package:carecar_mobile/api/excepciones.dart';
import 'package:carecar_mobile/modulos/vehiculos/datos/repositorio_garaje_fake.dart';
import 'package:carecar_mobile/modulos/vehiculos/dominio/ficha_tecnica_vehiculo.dart';
import 'package:carecar_mobile/modulos/vehiculos/dominio/repositorio_ficha_tecnica.dart';
import 'package:carecar_mobile/modulos/vehiculos/dominio/vehiculo_garaje.dart';
import 'package:carecar_mobile/modulos/vehiculos/presentacion/pantalla_ficha_tecnica.dart';
import 'package:carecar_mobile/modulos/vehiculos/presentacion/proveedores_vehiculos.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/boton.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/estado_error.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/estado_vacio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../ayudas/tema_pista.dart';

class _Repo implements RepositorioFichaTecnica {
  _Repo(this.alPedir);
  final Future<FichaTecnicaVehiculo?> Function() alPedir;
  @override
  Future<FichaTecnicaVehiculo?> ficha(VehiculoGaraje vehiculo) => alPedir();
}

const _ficha = FichaTecnicaVehiculo(
  secciones: [
    SeccionFicha(
      titulo: 'Motor',
      especificaciones: [
        EspecificacionFicha(clave: 'Cilindrada', valor: '1.6 L'),
      ],
    ),
    SeccionFicha(
      titulo: 'Transmisión',
      especificaciones: [EspecificacionFicha(clave: 'Caja', valor: 'CVT')],
    ),
  ],
);

Widget _app(
  RepositorioFichaTecnica repo, {
  int id = 1,
  Escenario escenario = Escenario.claro,
  Locale? idioma,
}) => ProviderScope(
  overrides: [
    repositorioGarajeProvider.overrideWithValue(RepositorioGarajeFake()),
    repositorioFichaTecnicaProvider.overrideWithValue(repo),
  ],
  child: idioma == null
      ? conTemaPista(PantallaFichaTecnica(vehiculoId: id), escenario: escenario)
      : conTemaPista(PantallaFichaTecnica(vehiculoId: id), idioma: idioma),
);

void _prueba(String descripcion, Future<void> Function(WidgetTester) cuerpo) {
  testWidgets(descripcion, (tester) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await cuerpo(tester);
  });
}

void main() {
  _prueba('muestra las secciones plegadas y las abre al tocarlas', (
    tester,
  ) async {
    await tester.pumpWidget(_app(_Repo(() async => _ficha)));
    await tester.pumpAndSettle();
    expect(find.text('Ficha técnica'), findsOneWidget);
    expect(find.text('Motor'), findsOneWidget);
    expect(find.text('Transmisión'), findsOneWidget);
    expect(find.text('1.6 L'), findsNothing);

    await tester.tap(find.text('Motor'));
    await tester.pumpAndSettle();
    expect(find.text('Cilindrada'), findsOneWidget);
    expect(find.text('1.6 L'), findsOneWidget);
    expect(find.text('CVT'), findsNothing);

    await tester.tap(find.text('Motor'));
    await tester.pumpAndSettle();
    expect(find.text('1.6 L'), findsNothing);
  });

  _prueba('cada sección lleva una sola flecha: la de desplegar', (
    tester,
  ) async {
    await tester.pumpWidget(_app(_Repo(() async => _ficha)));
    await tester.pumpAndSettle();

    // Antes cada fila mostraba la de desplegar y, a su lado, la de «abre otra
    // pantalla», que aquí no existe.
    expect(find.byIcon(Icons.expand_more), findsNWidgets(2));
    expect(find.byIcon(Icons.chevron_right_rounded), findsNothing);
  });

  _prueba('avisa cuando la ficha sale del respaldo local', (tester) async {
    await tester.pumpWidget(
      _app(
        _Repo(
          () async =>
              const FichaTecnicaVehiculo(secciones: [], delRespaldo: true),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Mostrando la ficha guardada en la app'), findsOneWidget);
  });

  _prueba('el respaldo local traduce sus títulos y claves al idioma', (
    tester,
  ) async {
    const respaldo = FichaTecnicaVehiculo(
      delRespaldo: true,
      secciones: [
        SeccionFicha(
          codigo: 'motor',
          especificaciones: [
            EspecificacionFicha(codigo: 'potencia', valor: '118 hp'),
          ],
        ),
      ],
    );
    await tester.pumpWidget(
      _app(_Repo(() async => respaldo), idioma: const Locale('en')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Engine'));
    await tester.pumpAndSettle();
    expect(find.text('Power'), findsOneWidget);
    expect(find.text('118 hp'), findsOneWidget);
  });

  _prueba('cargando: esqueleto con etiqueta para el lector de pantalla', (
    tester,
  ) async {
    final espera = Completer<FichaTecnicaVehiculo?>();
    await tester.pumpWidget(_app(_Repo(() => espera.future)));
    await tester.pump();
    expect(find.bySemanticsLabel('Cargando la ficha técnica'), findsOneWidget);
    espera.complete(_ficha);
    await tester.pumpAndSettle();
  });

  _prueba('vacío: explica que la agencia la publicará', (tester) async {
    await tester.pumpWidget(_app(_Repo(() async => null)));
    await tester.pumpAndSettle();
    expect(find.byType(EstadoVacio), findsOneWidget);
    expect(find.text('Sin ficha técnica'), findsOneWidget);
  });

  _prueba('error: ofrece reintentar y vuelve a pedir', (tester) async {
    var llamadas = 0;
    await tester.pumpWidget(
      _app(
        _Repo(() async {
          llamadas++;
          if (llamadas == 1) throw Exception('falla');
          return _ficha;
        }),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(EstadoError), findsOneWidget);
    await tester.tap(find.byType(Boton));
    await tester.pumpAndSettle();
    expect(find.text('Motor'), findsOneWidget);
  });

  _prueba('sin conexión: estado de sin conexión', (tester) async {
    await tester.pumpWidget(_app(_Repo(() async => throw const SinConexion())));
    await tester.pumpAndSettle();
    expect(find.byType(EstadoError), findsOneWidget);
    expect(
      tester.widget<EstadoError>(find.byType(EstadoError)).causa,
      CausaError.sinConexion,
    );
  });

  _prueba('un vehículo que ya no está en el garaje cae en vacío', (
    tester,
  ) async {
    await tester.pumpWidget(_app(_Repo(() async => _ficha), id: 99));
    await tester.pumpAndSettle();
    expect(find.byType(EstadoVacio), findsOneWidget);
  });

  for (final e in [Escenario.oscuro, Escenario.letraGrande]) {
    _prueba('se arma sin desbordes en $e', (tester) async {
      await tester.pumpWidget(_app(_Repo(() async => _ficha), escenario: e));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Motor'), findsOneWidget);
    });
  }

  _prueba('habla inglés', (tester) async {
    await tester.pumpWidget(
      _app(_Repo(() async => _ficha), idioma: const Locale('en')),
    );
    await tester.pumpAndSettle();
    expect(find.text('Specifications'), findsOneWidget);
  });
}
