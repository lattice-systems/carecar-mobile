import 'package:carecar_mobile/api/modelos/vehiculo.dart';
import 'package:carecar_mobile/modulos/documentos/datos/repositorio_documentos_fake.dart';
import 'package:carecar_mobile/modulos/documentos/documentos.dart';
import 'package:carecar_mobile/modulos/vehiculos/vehiculos.dart';
import 'package:carecar_mobile/nucleo/privacidad/pantalla_segura.dart';
import 'package:carecar_mobile/nucleo/privacidad/proteccion_de_captura.dart';
import 'package:carecar_mobile/pantallas/pantalla_login.dart';
import 'package:carecar_mobile/sesion/almacen_sesion.dart';
import 'package:carecar_mobile/sesion/controlador_sesion.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../ayudas/api_falsa.dart';
import '../../ayudas/app_enrutada.dart';
import 'ayudas_documentos.dart';

Future<ProteccionDeCapturaFake> _montar(
  WidgetTester tester, {
  bool conSesion = true,
}) async {
  tester.view.physicalSize = const Size(800, 2400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  tester.platformDispatcher.accessibilityFeaturesTestValue =
      const FakeAccessibilityFeatures(disableAnimations: true);
  addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
  tester.platformDispatcher.localesTestValue = const [Locale('es')];
  addTearDown(tester.platformDispatcher.clearLocalesTestValue);
  final api = ApiFalsa()
    ..alPedirVehiculos = () async => [
      const Vehiculo(
        id: 5,
        vin: 'VIN5',
        modelo: 'March',
        anio: 2020,
        marca: 'Nissan',
        placas: 'GTO-501-S',
      ),
    ];
  final sesion = ControladorSesion(api, AlmacenEnMemoria());
  addTearDown(sesion.dispose);
  if (conSesion) {
    await sesion.iniciarSesion(correo: 'a@b.mx', contrasena: 'CareCar2026');
  }
  final proteccion = ProteccionDeCapturaFake();
  await tester.pumpWidget(
    AppEnrutadaDePrueba(
      api: api,
      controlador: sesion,
      idioma: const Locale('es'),
      overrides: [
        repositorioDocumentosProvider.overrideWithValue(
          RepositorioDocumentosFake(documentos: documentosDeEjemplo()),
        ),
        proteccionDeCapturaProvider.overrideWithValue(proteccion),
      ],
    ),
  );
  await tester.pumpAndSettle();
  return proteccion;
}

void main() {
  test('la ruta lleva el id del vehiculo', () {
    expect(rutaDocumentosVehiculo(5), '/documentos/5');
  });

  testWidgets('/documentos/:vehiculoId abre los documentos del auto', (
    tester,
  ) async {
    await _montar(tester);
    enrutadorDe(tester).go(rutaDocumentosVehiculo(5));
    await tester.pumpAndSettle();

    expect(find.byType(PantallaDocumentos), findsOneWidget);
    expect(find.text('Póliza de seguro'), findsOneWidget);
  });

  testWidgets('los documentos no se pueden capturar (V2-M22.06)', (
    tester,
  ) async {
    final proteccion = await _montar(tester);
    enrutadorDe(tester).go(rutaDocumentosVehiculo(5));
    await tester.pumpAndSettle();

    expect(find.byType(PantallaSegura), findsOneWidget);
    expect(proteccion.bloqueada, isTrue);

    enrutadorDe(tester).go('/');
    await tester.pumpAndSettle();
    expect(proteccion.bloqueada, isFalse);
  });

  testWidgets('sin sesion manda al acceso en vez de mostrar documentos', (
    tester,
  ) async {
    await _montar(tester, conSesion: false);
    enrutadorDe(tester).go(rutaDocumentosVehiculo(5));
    await tester.pumpAndSettle();

    expect(find.byType(PantallaDocumentos), findsNothing);
    expect(find.byType(PantallaLogin), findsOneWidget);
  });

  testWidgets('la fila Documentos del detalle abre los documentos del auto', (
    tester,
  ) async {
    await _montar(tester);
    enrutadorDe(tester).go(rutaDetalleVehiculo(5));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Documentos'));
    await tester.tap(find.text('Documentos'));
    await tester.pumpAndSettle();

    expect(find.byType(PantallaDocumentos), findsOneWidget);
    expect(find.text('Póliza de seguro'), findsOneWidget);
  });
}
