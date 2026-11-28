import 'package:carecar_mobile/api/excepciones.dart';
import 'package:carecar_mobile/modulos/vehiculos/datos/repositorio_garaje_fake.dart';
import 'package:carecar_mobile/modulos/vehiculos/dominio/repositorio_garaje.dart';
import 'package:carecar_mobile/modulos/vehiculos/dominio/vehiculo_garaje.dart';
import 'package:carecar_mobile/modulos/vehiculos/presentacion/pantalla_garaje.dart';
import 'package:carecar_mobile/modulos/vehiculos/presentacion/proveedores_vehiculos.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/boton_cerrar.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/boton_regresar.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/estado_error.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/estado_vacio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons_300.dart';

import '../../ayudas/tema_pista.dart';

class _Repo implements RepositorioGaraje {
  _Repo(this.alPedir);
  final Future<List<VehiculoGaraje>> Function() alPedir;
  @override
  Future<List<VehiculoGaraje>> vehiculos() => alPedir();
}

Widget _app(
  RepositorioGaraje repo, {
  Escenario escenario = Escenario.claro,
  Locale? idioma,
}) => ProviderScope(
  overrides: [repositorioGarajeProvider.overrideWithValue(repo)],
  child: idioma == null
      ? conTemaPista(const PantallaGaraje(), escenario: escenario)
      : conTemaPista(const PantallaGaraje(), idioma: idioma),
);

void main() {
  testWidgets('es raíz de pestaña: sin regresar ni cerrar, con su icono', (
    tester,
  ) async {
    await tester.pumpWidget(_app(RepositorioGarajeFake()));
    await tester.pumpAndSettle();

    // La barra de pestañas lleva a las demás pantallas: no hay a dónde
    // regresar, y «Cerrar» es de las pantallas que se abren encima de otra.
    expect(find.byType(BotonRegresar), findsNothing);
    expect(find.byType(BotonCerrar), findsNothing);
    expect(find.byIcon(LucideIcons300.car), findsWidgets);
    expect(find.text('Mi garaje'), findsOneWidget);
  });

  testWidgets('una tarjeta por vehiculo con modelo, anio, placas y km', (
    tester,
  ) async {
    await tester.pumpWidget(_app(RepositorioGarajeFake()));
    await tester.pumpAndSettle();
    expect(find.text('Mi garaje'), findsOneWidget);
    // Una tarjeta por auto: la marca aparte, el modelo y el anio como titulo,
    // y las placas y el km (lo que haya) como datos.
    expect(find.text('Mazda'), findsOneWidget);
    expect(find.text('CX-5 2024'), findsOneWidget);
    expect(find.text('ABC-123'), findsOneWidget);
    expect(find.text('12,500 km'), findsOneWidget);
    // El segundo auto trae el modelo con la marca y sin placas ni km.
    expect(find.text('Mazda 3 2022'), findsOneWidget);
    expect(find.text('Sin placas'), findsNothing);
  });

  testWidgets('en ingles traduce el titulo y el kilometraje', (tester) async {
    await tester.pumpWidget(
      _app(RepositorioGarajeFake(), idioma: const Locale('en')),
    );
    await tester.pumpAndSettle();
    expect(find.text('My garage'), findsOneWidget);
    expect(find.text('12,500 km'), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('ABC-123')), findsOneWidget);
  });

  testWidgets('vacio explica que la agencia registra los autos', (
    tester,
  ) async {
    await tester.pumpWidget(_app(RepositorioGarajeFake(datos: const [])));
    await tester.pumpAndSettle();
    expect(find.byType(EstadoVacio), findsOneWidget);
    expect(find.text('Aún no tienes vehículos'), findsOneWidget);
    expect(
      find.textContaining('La agencia registra tus autos'),
      findsOneWidget,
    );
  });

  testWidgets('mientras carga muestra el esqueleto y lo anuncia', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(_Repo(() => Future.delayed(const Duration(seconds: 5), () => []))),
    );
    expect(find.bySemanticsLabel('Cargando tu garaje'), findsOneWidget);
    await tester.pump(const Duration(seconds: 6));
  });

  testWidgets('un fallo muestra el error y reintenta', (tester) async {
    var intentos = 0;
    await tester.pumpWidget(
      _app(
        _Repo(() async {
          intentos++;
          if (intentos == 1) throw Exception('fallo');
          return RepositorioGarajeFake().vehiculos();
        }),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(EstadoError), findsOneWidget);
    await tester.tap(find.text('Reintentar'));
    await tester.pumpAndSettle();
    expect(intentos, 2);
    expect(find.text('CX-5 2024'), findsOneWidget);
  });

  testWidgets('sin conexion y sin copia guardada lo dice distinto', (
    tester,
  ) async {
    await tester.pumpWidget(_app(_Repo(() async => throw const SinConexion())));
    await tester.pumpAndSettle();
    expect(find.text('Sin conexión'), findsOneWidget);
  });

  testWidgets('se ve en los tres escenarios sin desbordar', (tester) async {
    for (final escenario in Escenario.values) {
      await tester.pumpWidget(
        _app(RepositorioGarajeFake(), escenario: escenario),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }
  });
}
