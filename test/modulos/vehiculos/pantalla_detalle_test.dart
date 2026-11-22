import 'package:carecar_mobile/api/excepciones.dart';
import 'package:carecar_mobile/modulos/vehiculos/datos/repositorio_garaje_fake.dart';
import 'package:carecar_mobile/modulos/vehiculos/dominio/repositorio_garaje.dart';
import 'package:carecar_mobile/modulos/vehiculos/dominio/vehiculo_garaje.dart';
import 'package:carecar_mobile/modulos/vehiculos/presentacion/pantalla_detalle_vehiculo.dart';
import 'package:carecar_mobile/modulos/vehiculos/presentacion/proveedores_vehiculos.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/estado_error.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/estado_vacio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../ayudas/tema_pista.dart';

class _Repo implements RepositorioGaraje {
  _Repo(this.alPedir);
  final Future<List<VehiculoGaraje>> Function() alPedir;
  @override
  Future<List<VehiculoGaraje>> vehiculos() => alPedir();
}

Widget _app(
  RepositorioGaraje repo, {
  int id = 1,
  Escenario escenario = Escenario.claro,
  Locale? idioma,
}) => ProviderScope(
  overrides: [repositorioGarajeProvider.overrideWithValue(repo)],
  child: idioma == null
      ? conTemaPista(
          PantallaDetalleVehiculo(vehiculoId: id),
          escenario: escenario,
        )
      : conTemaPista(PantallaDetalleVehiculo(vehiculoId: id), idioma: idioma),
);

void main() {
  testWidgets('muestra vin, placas, anio, color, version y km', (tester) async {
    await tester.pumpWidget(_app(RepositorioGarajeFake()));
    await tester.pumpAndSettle();
    expect(find.text('Detalle del vehículo'), findsOneWidget);
    expect(find.text('Mazda CX-5 2024'), findsOneWidget);
    expect(find.text('JM3KFBDM0R0123456'), findsOneWidget);
    expect(find.text('ABC-123'), findsOneWidget);
    expect(find.text('Rojo'), findsOneWidget);
    expect(find.text('Signature'), findsOneWidget);
    expect(find.text('12,500 km'), findsOneWidget);
  });

  testWidgets('el km dice cuando lo actualizo el taller', (tester) async {
    await tester.pumpWidget(_app(RepositorioGarajeFake()));
    await tester.pumpAndSettle();
    expect(find.textContaining('Actualizado por el taller el'), findsOneWidget);
    expect(find.textContaining('2026'), findsOneWidget);
  });

  testWidgets('sin fecha de cierre lo dice en vez de inventarla', (
    tester,
  ) async {
    final repo = RepositorioGarajeFake(
      datos: const [
        VehiculoGaraje(
          id: 1,
          modelo: 'CX-5',
          anio: 2024,
          kilometraje: 900,
          vin: 'VIN1',
        ),
      ],
    );
    await tester.pumpWidget(_app(repo));
    await tester.pumpAndSettle();
    expect(find.text('900 km'), findsOneWidget);
    expect(find.text('Aún sin actualización del taller'), findsOneWidget);
  });

  testWidgets('sin km registrado lo dice y no muestra fecha', (tester) async {
    await tester.pumpWidget(_app(RepositorioGarajeFake(), id: 2));
    await tester.pumpAndSettle();
    expect(find.text('Sin kilometraje registrado'), findsOneWidget);
    expect(find.textContaining('Actualizado por el taller'), findsNothing);
  });

  testWidgets('copiar el VIN lo deja en el portapapeles y avisa', (
    tester,
  ) async {
    String? copiado;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (llamada) async {
        if (llamada.method == 'Clipboard.setData') {
          copiado =
              (llamada.arguments as Map<Object?, Object?>)['text'] as String?;
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    await tester.pumpWidget(_app(RepositorioGarajeFake()));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Copiar VIN'));
    await tester.pumpAndSettle();
    expect(copiado, 'JM3KFBDM0R0123456');
    expect(find.text('VIN copiado'), findsOneWidget);
  });

  testWidgets('los accesos a historial, manuales y ficha se ven y explican '
      'que aun no estan', (tester) async {
    await tester.pumpWidget(_app(RepositorioGarajeFake()));
    await tester.pumpAndSettle();
    expect(find.text('Historial de servicios'), findsOneWidget);
    expect(find.text('Manuales'), findsOneWidget);
    expect(find.text('Ficha técnica'), findsOneWidget);
    expect(find.text('Disponible pronto'), findsNWidgets(3));
    expect(
      find.bySemanticsLabel('Manuales. Disponible pronto'),
      findsOneWidget,
    );
  });

  testWidgets('un id que no esta en el garaje explica y no deja en blanco', (
    tester,
  ) async {
    await tester.pumpWidget(_app(RepositorioGarajeFake(), id: 99));
    await tester.pumpAndSettle();
    expect(find.byType(EstadoVacio), findsOneWidget);
    expect(find.text('No encontramos el vehículo'), findsOneWidget);
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
    expect(find.text('Mazda CX-5 2024'), findsOneWidget);
  });

  testWidgets('sin conexion y sin copia guardada lo dice distinto', (
    tester,
  ) async {
    await tester.pumpWidget(_app(_Repo(() async => throw const SinConexion())));
    await tester.pumpAndSettle();
    expect(find.text('Sin conexion'), findsOneWidget);
  });

  testWidgets('en ingles traduce los textos', (tester) async {
    await tester.pumpWidget(
      _app(RepositorioGarajeFake(), idioma: const Locale('en')),
    );
    await tester.pumpAndSettle();
    expect(find.text('Vehicle details'), findsOneWidget);
    expect(find.text('Service history'), findsOneWidget);
    expect(find.text('Coming soon'), findsNWidgets(3));
    expect(find.textContaining('Updated by the workshop on'), findsOneWidget);
  });

  testWidgets('se ve en claro, oscuro y letra grande sin desbordar', (
    tester,
  ) async {
    for (final escenario in Escenario.values) {
      await tester.pumpWidget(
        _app(RepositorioGarajeFake(), escenario: escenario),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }
  });
}
