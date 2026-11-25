import 'package:carecar_mobile/modulos/asistencia/asistencia.dart';
import 'package:carecar_mobile/modulos/bitacora/datos/repositorio_bitacora_fake.dart';
import 'package:carecar_mobile/modulos/bitacora/presentacion/pantalla_bitacora.dart';
import 'package:carecar_mobile/modulos/citas/citas.dart';
import 'package:carecar_mobile/modulos/citas/datos/repositorio_citas_fake.dart';
import 'package:carecar_mobile/modulos/mantenimiento/datos/repositorio_mantenimiento_fake.dart';
import 'package:carecar_mobile/modulos/mantenimiento/presentacion/pantalla_plan_mantenimiento.dart';
import 'package:carecar_mobile/modulos/mantenimiento/presentacion/proveedores_mantenimiento.dart';
import 'package:carecar_mobile/modulos/recoleccion/datos/repositorio_recoleccion_fake.dart';
import 'package:carecar_mobile/modulos/recoleccion/recoleccion.dart';
import 'package:carecar_mobile/modulos/vehiculos/datos/repositorio_garaje_fake.dart';
import 'package:carecar_mobile/modulos/vehiculos/presentacion/pantalla_garaje.dart';
import 'package:carecar_mobile/modulos/vehiculos/presentacion/proveedores_vehiculos.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/boton_regresar.dart';
import 'package:carecar_mobile/nucleo/mapas/mapas.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../ayudas/tema_pista.dart';
import 'bitacora/arnes_bitacora.dart';

/// V2-M02 / V2-M17 ajustes visuales: toda pantalla raiz de un modulo, la que
/// se abre desde el menu o un enlace, debe tener «Regresar».
Widget _con(Widget pantalla, {Escenario escenario = Escenario.claro}) =>
    ProviderScope(
      overrides: [
        repositorioGarajeProvider.overrideWithValue(RepositorioGarajeFake()),
        repositorioCitasProvider.overrideWithValue(
          RepositorioCitasFake(reloj: () => DateTime(2026, 11, 23, 12)),
        ),
        repositorioMantenimientoProvider.overrideWithValue(
          RepositorioMantenimientoFake(),
        ),
        repositorioRecoleccionProvider.overrideWithValue(
          RepositorioRecoleccionFake(),
        ),
        configuracionTeselasProvider.overrideWithValue(
          const ConfiguracionTeselas(
            urlPlantilla: 'http://localhost:1/{z}/{x}/{y}.png',
            atribucion: '© Mapas de prueba',
          ),
        ),
        geocodificadorProvider.overrideWithValue(GeocodificadorFalso()),
      ],
      child: conTemaPista(pantalla, escenario: escenario),
    );

void main() {
  final raices = <String, Widget Function()>{
    'Mi garaje': () => const PantallaGaraje(),
    'Mis citas': () => const PantallaMisCitas(),
    'Guias de emergencia': () => const PantallaGuias(),
    'Mis direcciones': () => const PantallaMisDirecciones(),
    'Mantenimiento': () => const PantallaPlanMantenimiento(vehiculoId: 5),
  };

  for (final escenario in Escenario.values) {
    for (final raiz in raices.entries) {
      testWidgets('${raiz.key} tiene Regresar ($escenario)', (tester) async {
        tester.view.physicalSize = const Size(800, 3200);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        final semantica = tester.ensureSemantics();
        await tester.pumpWidget(_con(raiz.value(), escenario: escenario));
        await tester.pumpAndSettle();
        expect(find.byType(BotonRegresar), findsOneWidget);
        expect(find.bySemanticsLabel('Regresar'), findsOneWidget);
        semantica.dispose();
      });
    }
  }

  testWidgets('Bitacora tiene Regresar', (tester) async {
    tester.view.physicalSize = const Size(800, 3200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      aplicacion(
        const PantallaBitacora(vehiculoId: 4, nombre: 'Aveo 2022'),
        repo: RepositorioBitacoraFake(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(BotonRegresar), findsOneWidget);
  });
}
