import 'package:carecar_mobile/api/modelos/traslado.dart';
import 'package:carecar_mobile/modulos/recoleccion/datos/repositorio_recoleccion_fake.dart';
import 'package:carecar_mobile/modulos/recoleccion/recoleccion.dart';
import 'package:carecar_mobile/nucleo/eventos/eventos_en_vivo_fake.dart';
import 'package:carecar_mobile/nucleo/eventos/proveedores_eventos.dart';
import 'package:carecar_mobile/nucleo/navegacion/rutas.dart';
import 'package:carecar_mobile/pantallas/pantalla_inicio.dart';
import 'package:carecar_mobile/pantallas/pantalla_login.dart';
import 'package:carecar_mobile/sesion/almacen_sesion.dart';
import 'package:carecar_mobile/sesion/controlador_sesion.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../ayudas/api_falsa.dart';
import '../../ayudas/app_enrutada.dart';

final _traslado = TrasladoDetalle(
  id: 5,
  citaId: 9,
  tipo: 'recoger',
  estado: EstadoTraslado.recogido,
  costo: 150,
  fecha: DateTime(2026, 12),
  ventanaInicio: '07:00',
  ventanaFin: '09:00',
);

Future<void> _montar(WidgetTester tester, {bool conSesion = true}) async {
  final api = ApiFalsa();
  final sesion = ControladorSesion(api, AlmacenEnMemoria());
  addTearDown(sesion.dispose);
  if (conSesion) {
    await sesion.iniciarSesion(correo: 'a@b.mx', contrasena: 'CareCar2026');
  }
  await tester.pumpWidget(
    AppEnrutadaDePrueba(
      api: api,
      controlador: sesion,
      overrides: [
        eventosEnVivoProvider.overrideWithValue(EventosEnVivoFake()),
        repositorioRecoleccionProvider.overrideWithValue(
          RepositorioRecoleccionFake(
            traslados: [_traslado],
            checklists: {
              5: ChecklistTraslado(
                trasladoId: 5,
                km: 10,
                gasolina: NivelGasolina.lleno,
                registradoEn: DateTime.utc(2026, 12),
              ),
            },
          ),
        ),
      ],
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('con sesion /recoleccion/traslados/5 abre el seguimiento', (
    tester,
  ) async {
    await _montar(tester);
    enrutadorDe(tester).go(rutaSeguimientoTraslado(5));
    // La linea de tiempo respira sin parar: pumpAndSettle no terminaria.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(PantallaSeguimientoTraslado), findsOneWidget);
  });

  testWidgets('el checklist cuelga del seguimiento', (tester) async {
    await _montar(tester);
    enrutadorDe(tester).go(rutaChecklistTraslado(5));
    await tester.pumpAndSettle();

    expect(find.byType(PantallaChecklistTraslado), findsOneWidget);
  });

  testWidgets('el checklist acepta el traslado contrario y abre en Comparar', (
    tester,
  ) async {
    await _montar(tester);
    enrutadorDe(tester)
        .go(rutaChecklistTraslado(5, contrario: 6, comparar: true));
    await tester.pumpAndSettle();

    expect(find.text('Al recoger'), findsOneWidget);
    expect(find.text('Aún no se puede comparar'), findsOneWidget);
  });

  testWidgets('el traslado de entregar abre en su pestana', (tester) async {
    await _montar(tester);
    enrutadorDe(
      tester,
    ).go(rutaChecklistTraslado(6, contrario: 5, tipo: TipoTraslado.entregar));
    await tester.pumpAndSettle();

    expect(find.text('Al entregar'), findsOneWidget);
    expect(find.text('Aún no hay checklist'), findsOneWidget);
  });

  test('la ruta del checklist arma sus parametros', () {
    expect(rutaChecklistTraslado(5), '/recoleccion/traslados/5/checklist');
    expect(
      rutaChecklistTraslado(
        6,
        contrario: 5,
        tipo: TipoTraslado.entregar,
        comparar: true,
      ),
      '/recoleccion/traslados/6/checklist?contrario=5&tipo=entregar&ver=comparar',
    );
  });

  testWidgets('un id que no es numero vuelve al inicio', (tester) async {
    await _montar(tester);
    enrutadorDe(tester).go('/recoleccion/traslados/abc');
    await tester.pumpAndSettle();

    expect(find.byType(PantallaSeguimientoTraslado), findsNothing);
    expect(find.byType(PantallaInicio), findsOneWidget);
  });

  testWidgets('sin sesion manda al acceso', (tester) async {
    await _montar(tester, conSesion: false);
    enrutadorDe(tester).go(rutaSeguimientoTraslado(5));
    await tester.pumpAndSettle();

    expect(find.byType(PantallaLogin), findsOneWidget);
    expect(find.byType(PantallaSeguimientoTraslado), findsNothing);
    expect(Rutas.publicas, isNot(contains(rutaSeguimientoTraslado(5))));
  });
}
