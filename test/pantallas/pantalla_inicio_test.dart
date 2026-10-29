import 'dart:async';

import 'package:carecar_mobile/api/excepciones.dart';
import 'package:carecar_mobile/api/modelos/modelos.dart';
import 'package:carecar_mobile/main.dart';
import 'package:carecar_mobile/pantallas/pantalla_inicio.dart';
import 'package:carecar_mobile/pantallas/pantalla_login.dart';
import 'package:carecar_mobile/sesion/almacen_sesion.dart';
import 'package:carecar_mobile/sesion/controlador_sesion.dart';
import 'package:carecar_mobile/tema/tema_carecar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../ayudas/api_falsa.dart';

const _march = Vehiculo(
  id: 5,
  vin: '3N1CK3CD0LL123456',
  modelo: 'Nissan March Sense',
  anio: 2020,
);
const _jetta = Vehiculo(
  id: 6,
  vin: '3VWDB7AJ0JM654321',
  modelo: 'Volkswagen Jetta Comfortline',
  anio: 2018,
);

Future<ControladorSesion> _montar(
  WidgetTester tester,
  ApiFalsa api, {
  bool login = false,
}) async {
  final sesion = ControladorSesion(api, AlmacenEnMemoria());
  addTearDown(sesion.dispose);
  if (!login) {
    await sesion.iniciarSesion(
      correo: 'cliente1@example.com',
      contrasena: 'CareCar2026',
    );
  }
  await tester.pumpWidget(
    MaterialApp(
      theme: TemaCareCar.claro,
      home: FlujoCareCar(controlador: sesion, api: api),
    ),
  );
  await tester.pumpAndSettle();
  return sesion;
}

Future<void> _tocar(WidgetTester tester, String texto) async {
  final elemento = find.text(texto).last;
  await tester.ensureVisible(elemento);
  await tester.tap(elemento);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'login existente abre las tres opciones y cerrar sesion borra el token',
    (tester) async {
      final api = ApiFalsa();
      final sesion = await _montar(tester, api, login: true);
      await tester.enterText(
        find.byKey(PantallaLogin.campoCorreo),
        'cliente1@example.com',
      );
      await tester.enterText(
        find.byKey(PantallaLogin.campoContrasena),
        'CareCar2026',
      );
      await tester.tap(find.byKey(PantallaLogin.botonEntrar));
      await tester.pumpAndSettle();
      expect(find.text('Menú'), findsOneWidget);
      for (final opcion in ['Mis vehículos', 'Catálogo', 'Ajustes']) {
        expect(find.text(opcion), findsOneWidget);
      }
      expect(api.llamadasAlLogin, 1);
      await tester.tap(find.byKey(PantallaInicio.botonCerrarSesion));
      await tester.pumpAndSettle();
      expect(sesion.haySesion, isFalse);
      expect(await sesion.obtenerToken(), isNull);
      expect(find.byKey(PantallaLogin.botonEntrar), findsOneWidget);
    },
  );

  testWidgets(
    'carga, selecciona cada vehiculo y conserva la lista al regresar',
    (tester) async {
      final espera = Completer<List<Vehiculo>>();
      final api = ApiFalsa()..alPedirVehiculos = () => espera.future;
      final sesion = await _montar(tester, api);
      await tester.tap(find.text('Mis vehículos'));
      await tester.pump();
      expect(find.text('Cargando vehículos…'), findsOneWidget);
      espera.complete([_march, _jetta]);
      await tester.pumpAndSettle();
      for (final vehiculo in [_march, _jetta]) {
        await _tocar(tester, '${vehiculo.modelo} ${vehiculo.anio}');
        expect(find.text(vehiculo.vin), findsOneWidget);
        expect(find.text('${vehiculo.anio}'), findsOneWidget);
        expect(find.text('No disponible'), findsWidgets);
        await _tocar(tester, 'Regresar');
        expect(
          find.text('${vehiculo.modelo} ${vehiculo.anio}'),
          findsOneWidget,
        );
      }
      expect(api.llamadasAVehiculos, 1);
      await _tocar(tester, 'Regresar');
      expect(find.text('Menú'), findsOneWidget);
      expect(sesion.haySesion, isTrue);
    },
  );

  testWidgets('lista vacia y error con reintento', (tester) async {
    final api = ApiFalsa()
      ..alPedirVehiculos = () async =>
          throw const SinConexion('Sin conexión de prueba');
    await _montar(tester, api);
    await _tocar(tester, 'Mis vehículos');
    expect(find.text('No se pudieron cargar tus vehículos'), findsOneWidget);
    api.alPedirVehiculos = () async => [];
    await _tocar(tester, 'Reintentar');
    expect(find.text('No tienes vehículos asociados'), findsOneWidget);
    expect(api.llamadasAVehiculos, 2);
  });

  testWidgets(
    'opciones del vehiculo son placeholders y el retroceso conserva la sesion',
    (tester) async {
      final api = ApiFalsa()..alPedirVehiculos = () async => [_march];
      final sesion = await _montar(tester, api);
      await _tocar(tester, 'Mis vehículos');
      await _tocar(tester, '${_march.modelo} 2020');
      for (final opcion in ['Agendar cita', 'Historial de servicios']) {
        await _tocar(tester, opcion);
        expect(find.text('PRÓXIMAMENTE'), findsOneWidget);
        await _tocar(tester, 'Regresar');
        expect(find.text(_march.vin), findsOneWidget);
      }
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('${_march.modelo} 2020'), findsOneWidget);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('Menú'), findsOneWidget);
      expect(sesion.haySesion, isTrue);
      expect(api.llamadasAlLogin, 1);
    },
  );

  testWidgets('catalogo regresa al menu y ajustes muestra el perfil real', (
    tester,
  ) async {
    final api = ApiFalsa();
    await _montar(tester, api);
    await _tocar(tester, 'Catálogo');
    expect(find.text('PRÓXIMAMENTE'), findsOneWidget);
    await _tocar(tester, 'Regresar');
    await _tocar(tester, 'Ajustes');
    expect(find.text('María Robles'), findsOneWidget);
    expect(find.text('cliente1@example.com'), findsOneWidget);
    expect(api.llamadasAPerfil, 1);
    await _tocar(tester, 'Regresar');
    expect(find.text('Menú'), findsOneWidget);
  });

  testWidgets('perfil en carga, error y datos ausentes sin inventar valores', (
    tester,
  ) async {
    final espera = Completer<Perfil>();
    final api = ApiFalsa()..alPedirPerfil = () => espera.future;
    await _montar(tester, api);
    await tester.tap(find.text('Ajustes'));
    await tester.pump();
    expect(find.text('Cargando perfil…'), findsOneWidget);
    espera.completeError(const SinConexion('Sin conexión de prueba'));
    await tester.pumpAndSettle();
    expect(find.text('No se pudo cargar tu perfil'), findsOneWidget);
    api.alPedirPerfil = () async => const Perfil(id: 1, nombre: '', correo: '');
    await _tocar(tester, 'Reintentar');
    expect(find.text('No disponible'), findsNWidgets(2));
  });

  testWidgets(
    'cerrar sesion desde detalle descarta toda la navegacion autenticada',
    (tester) async {
      final api = ApiFalsa()..alPedirVehiculos = () async => [_march];
      await _montar(tester, api);
      await _tocar(tester, 'Mis vehículos');
      await _tocar(tester, '${_march.modelo} 2020');
      await tester.tap(find.byKey(PantallaInicio.botonCerrarSesion));
      await tester.pumpAndSettle();
      expect(find.byKey(PantallaLogin.botonEntrar), findsOneWidget);
      expect(find.text(_march.vin), findsNothing);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text(_march.vin), findsNothing);
    },
  );

  for (final ancho in [320.0, 375.0, 768.0, 1280.0]) {
    testWidgets('menus y detalle sin overflow a ancho $ancho', (tester) async {
      tester.view.physicalSize = Size(ancho, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final api = ApiFalsa()..alPedirVehiculos = () async => [_march, _jetta];
      await _montar(tester, api);
      final misVehiculos = tester.getTopLeft(find.text('Mis vehículos'));
      final catalogo = tester.getTopLeft(find.text('Catálogo'));
      expect((misVehiculos.dy - catalogo.dy).abs() < 1, ancho >= 768);
      await _tocar(tester, 'Mis vehículos');
      await _tocar(tester, '${_jetta.modelo} 2018');
      expect(find.text(_jetta.vin), findsOneWidget);
      await _tocar(tester, 'Manual del propietario');
      expect(find.textContaining('No fue posible identificar'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
