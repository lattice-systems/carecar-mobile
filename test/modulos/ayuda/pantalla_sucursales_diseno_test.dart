// V2-M27.02 · diseño: la pantalla de sucursales no se rompe ni se amontona con
// letra al 200 % en una pantalla de 320x568, ni deja que el contenido cruce el
// título al desplazar.
import 'package:carecar_mobile/modulos/ayuda/datos/repositorio_sucursales_fake.dart';
import 'package:carecar_mobile/modulos/ayuda/dominio/sucursal.dart';
import 'package:carecar_mobile/modulos/ayuda/presentacion/pantalla_sucursales.dart';
import 'package:carecar_mobile/modulos/ayuda/presentacion/proveedores_ayuda.dart';
import 'package:carecar_mobile/nucleo/mapas/mapas.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../ayudas/tema_pista.dart';

const _larga = Sucursal(
  id: 2,
  nombre: 'CareCar Plaza Mayor Sucursal Norte Poniente',
  direccion:
      'Boulevard Adolfo López Mateos Poniente 4521, Colonia Jardines de '
      'los Naranjos, 37358 León de los Aldama, Guanajuato',
  latitud: 21.1527,
  longitud: -101.6894,
  telefono: '+52 477 000 0001',
  abiertaAhora: false,
  horarios: [
    HorarioDeDepartamento(
      departamento: Departamento.ventas,
      dias: [1, 2, 3, 4, 6, 7],
      abre: '10:00',
      cierra: '20:00',
      abiertoAhora: false,
    ),
    HorarioDeDepartamento(
      departamento: Departamento.servicio,
      dias: [1, 2, 3, 4, 5],
      abre: '08:00',
      cierra: '18:00',
      abiertoAhora: false,
    ),
    HorarioDeDepartamento(
      departamento: Departamento.servicio,
      dias: [6],
      abre: '09:00',
      cierra: '14:00',
      abiertoAhora: false,
    ),
  ],
);

Widget _app(Escenario escenario, {double ancho = 320}) => ProviderScope(
  overrides: [
    repositorioSucursalesProvider.overrideWithValue(
      RepositorioSucursalesFake(
        sucursales: [...RepositorioSucursalesFake.ejemplo, _larga],
      ),
    ),
    fuenteTeselasProvider.overrideWithValue(TeselasLisas()),
    configuracionTeselasProvider.overrideWithValue(
      ConfiguracionTeselas.openStreetMapDesarrollo,
    ),
    abrirEnlaceDeSucursalProvider.overrideWithValue((_) async => true),
  ],
  child: conTemaPista(
    const PantallaSucursales(),
    escenario: escenario,
    ancho: ancho,
  ),
);

void _vista(WidgetTester tester, Size tamano) {
  tester.view
    ..devicePixelRatio = 1
    ..physicalSize = tamano;
  addTearDown(tester.view.reset);
}

void main() {
  for (final escenario in Escenario.values) {
    testWidgets('320x568 sin desbordar y desplazable ($escenario)', (
      tester,
    ) async {
      _vista(tester, const Size(320, 568));
      await tester.pumpWidget(_app(escenario));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      for (var i = 0; i < 20; i++) {
        if (find.text('Todas las sucursales').evaluate().isNotEmpty) break;
        await tester.dragFrom(const Offset(160, 540), const Offset(0, -300));
        await tester.pump();
        expect(tester.takeException(), isNull);
      }
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Todas las sucursales'), findsOneWidget);
    });
  }

  testWidgets('pantalla ancha sin desbordar', (tester) async {
    _vista(tester, const Size(1024, 768));
    await tester.pumpWidget(_app(Escenario.claro, ancho: 1024));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('CareCar León'), findsWidgets);
  });

  testWidgets('con letra al 200 % el contenido no atraviesa el título', (
    tester,
  ) async {
    _vista(tester, const Size(320, 568));
    await tester.pumpWidget(_app(Escenario.letraGrande));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -700));
    await tester.pumpAndSettle();

    // Con el encabezado recogido, el título grande ya no está a la vista y el
    // contenido (horarios) se sigue pudiendo tocar sin quedar bajo la barra.
    expect(tester.takeException(), isNull);
    expect(find.text('Sucursales').hitTestable(), findsOneWidget);
  });

  testWidgets('el lector de pantalla lee nombre, estado y acciones', (
    tester,
  ) async {
    final semantica = tester.ensureSemantics();
    _vista(tester, const Size(360, 2400));
    await tester.pumpWidget(_app(Escenario.claro, ancho: 360));
    await tester.pumpAndSettle();

    expect(
      find.bySemanticsLabel(RegExp('ubicación de CareCar León')),
      findsOne,
    );
    expect(find.bySemanticsLabel('Cómo llegar'), findsOneWidget);
    expect(find.bySemanticsLabel('Llamar'), findsOneWidget);
    semantica.dispose();
  });
}
