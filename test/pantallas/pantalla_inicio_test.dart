import 'dart:async';

import 'package:carecar_mobile/api/excepciones.dart';
import 'package:carecar_mobile/api/modelos/modelos.dart';
import 'package:carecar_mobile/nucleo/migracion/interruptor_modulos.dart';
import 'package:carecar_mobile/pantallas/citas/pantalla_mis_citas.dart';
import 'package:carecar_mobile/pantallas/pantalla_inicio.dart';
import 'package:carecar_mobile/pantallas/pantalla_login.dart';
import 'package:carecar_mobile/sesion/almacen_sesion.dart';
import 'package:carecar_mobile/sesion/controlador_sesion.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../ayudas/api_falsa.dart';
import '../ayudas/app_enrutada.dart';

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
    AppEnrutadaDePrueba(
      api: api,
      controlador: sesion,
      interruptor: InterruptorModulos.porDefecto,
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
  testWidgets('la sesion restaurada abre el menu y conserva los vehiculos', (
    tester,
  ) async {
    final api = ApiFalsa()..alPedirVehiculos = () async => [_march, _jetta];
    final almacen = AlmacenEnMemoria();
    final anterior = ControladorSesion(api, almacen);
    await anterior.iniciarSesion(
      correo: 'cliente1@example.com',
      contrasena: 'CareCar2026',
    );
    anterior.dispose();

    final restaurada = ControladorSesion(api, almacen);
    addTearDown(restaurada.dispose);
    await restaurada.restaurar();
    await tester.pumpWidget(
      AppEnrutadaDePrueba(
        api: api,
        controlador: restaurada,
        interruptor: InterruptorModulos.porDefecto,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Menú'), findsOneWidget);
    await _tocar(tester, 'Mis vehículos');
    expect(find.text('${_march.modelo} 2020'), findsOneWidget);
    expect(find.text('${_jetta.modelo} 2018'), findsOneWidget);
    expect(api.llamadasAlLogin, 1);
  });

  testWidgets('el refresco conserva el detalle y su rechazo vuelve al login', (
    tester,
  ) async {
    final api = ApiFalsa()..alPedirVehiculos = () async => [_march];
    final sesion = await _montar(tester, api);
    await _tocar(tester, 'Mis vehículos');
    await _tocar(tester, '${_march.modelo} 2020');

    expect(await sesion.renovar(), isTrue);
    await tester.pumpAndSettle();
    expect(find.text(_march.vin), findsOneWidget);

    api.alRefrescar = (_) async =>
        throw const CredencialesInvalidas('La sesión terminó');
    expect(await sesion.renovar(), isFalse);
    await tester.pumpAndSettle();
    expect(find.byKey(PantallaLogin.botonEntrar), findsOneWidget);
    expect(find.text(_march.vin), findsNothing);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text(_march.vin), findsNothing);

    api.alIniciarSesion = (_) async =>
        ApiFalsa.respuesta(debeCambiarContrasena: true);
    await sesion.iniciarSesion(
      correo: 'cliente2@example.com',
      contrasena: 'Temporal123',
    );
    await tester.pumpAndSettle();
    expect(find.text('Menú'), findsNothing);
    expect(find.text('Cambia tu contraseña'), findsOneWidget);
  });

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
      for (final opcion in ['Mis vehículos', 'Citas', 'Catálogo', 'Ajustes']) {
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
        // El ano sale en la insignia de la foto y en «Identificacion».
        expect(find.text('${vehiculo.anio}'), findsWidgets);
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
    // Deja correr los timers de la animacion de entrada del aviso.
    await tester.pump(const Duration(milliseconds: 500));
  });

  testWidgets(
    'agendar e historial abren sus pantallas y el retroceso conserva la sesion',
    (tester) async {
      final api = ApiFalsa()..alPedirVehiculos = () async => [_march];
      final sesion = await _montar(tester, api);
      await _tocar(tester, 'Mis vehículos');
      await _tocar(tester, '${_march.modelo} 2020');
      for (final (opcion, contenido) in [
        ('Agendar cita', 'Tres pasos y listo'),
        ('Historial de servicios', 'Aún no hay servicios'),
      ]) {
        await _tocar(tester, opcion);
        expect(find.text(contenido), findsOneWidget);
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
    expect(find.text('Aún no hay modelos en el catálogo'), findsOneWidget);
    await _tocar(tester, 'Regresar');
    await _tocar(tester, 'Ajustes');
    expect(find.text('María Robles'), findsOneWidget);
    expect(find.text('cliente1@example.com'), findsOneWidget);
    // Una del saludo del menu y otra de Ajustes.
    expect(api.llamadasAPerfil, 2);
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
    // Mientras carga se ve el esqueleto, no un texto de espera.
    expect(find.text('Nombre del cliente'), findsOneWidget);
    espera.completeError(const SinConexion('Sin conexión de prueba'));
    await tester.pumpAndSettle();
    expect(find.text('Sin conexión'), findsOneWidget);
    api.alPedirPerfil = () async => const Perfil(id: 1, nombre: '', correo: '');
    await _tocar(tester, 'Reintentar');
    // Con datos vacios el perfil no inventa nombre ni correo.
    expect(find.text('Nombre del cliente'), findsNothing);
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

  // Telefono chico, normal, horizontal, tablet vertical y escritorio, cada uno
  // con la escala de texto del sistema en 1.0, 1.5 y 2.0.
  for (final tamano in const [
    Size(320, 640),
    Size(375, 812),
    Size(812, 375),
    Size(768, 1024),
    Size(1280, 800),
  ]) {
    for (final escala in const [1.0, 1.5, 2.0]) {
      final nombre = '${tamano.width.toInt()}x${tamano.height.toInt()}';
      testWidgets(
        'pantallas principales sin overflow a $nombre y texto x$escala',
        (tester) async {
          tester.view.physicalSize = tamano;
          tester.view.devicePixelRatio = 1;
          tester.platformDispatcher.textScaleFactorTestValue = escala;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
          final manana = DateTime.now().add(const Duration(days: 1));
          final api = ApiFalsa();
          api.alPedirVehiculos = () async => [_march, _jetta];
          api.alPedirServicios = (_) async => [
            Servicio(
              id: 1,
              fecha: DateTime(2026, 3, 4),
              estatus: 'TERMINADO',
              total: 1850.5,
            ),
          ];
          api.alPedirCitas = () async => [
            Cita(
              id: 1,
              vehiculoId: _march.id,
              fecha: manana,
              horaInicio: '10:00',
              horaFin: '11:00',
              estado: EstadoCita.confirmada,
            ),
          ];
          api.alPedirDisponibilidad = (_, _) async => [
            for (var h = 9; h < 17; h++)
              Disponibilidad(
                fecha: DateTime.now(),
                franjaId: h,
                horaInicio: '${h.toString().padLeft(2, '0')}:00',
                horaFin: '${(h + 1).toString().padLeft(2, '0')}:00',
                cupoDisponible: h == 10 ? 1 : 3,
              ),
          ];
          await _montar(tester, api);
          if (escala == 1.0) {
            // En tablet y escritorio el menu se reparte en columnas.
            final misVehiculos = tester.getTopLeft(find.text('Mis vehículos'));
            final citas = tester.getTopLeft(find.text('Citas'));
            expect((misVehiculos.dy - citas.dy).abs() < 1, tamano.width >= 768);
          }
          await _tocar(tester, 'Mis vehículos');
          await _tocar(tester, '${_jetta.modelo} 2018');
          expect(find.text(_jetta.vin), findsOneWidget);
          await _tocar(tester, 'Historial de servicios');
          await _regresar(tester);
          await _tocar(tester, 'Agendar cita');
          await _regresar(tester);
          await _tocar(tester, 'Manual del propietario');
          expect(
            find.textContaining('No fue posible identificar'),
            findsOneWidget,
          );
          // En escritorio la ficha va junto a la lista: hay una ruta menos.
          while (find.text('Menú').evaluate().isEmpty) {
            await _regresar(tester);
          }
          await _tocar(tester, 'Citas');
          await tester.scrollUntilVisible(
            find.text('PRÓXIMAS'),
            200,
            scrollable: find
                .descendant(
                  of: find.byKey(PantallaMisCitas.lista),
                  matching: find.byType(Scrollable),
                )
                .first,
          );
          expect(find.text('PRÓXIMAS'), findsOneWidget);
          await _regresar(tester);
          await _tocar(tester, 'Ajustes');
          await _regresar(tester);
          await _tocar(tester, 'Catálogo');
          await _regresar(tester);
          expect(find.text('Menú'), findsOneWidget);
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}

Future<void> _regresar(WidgetTester tester) async {
  await tester.binding.handlePopRoute();
  await tester.pumpAndSettle();
}
