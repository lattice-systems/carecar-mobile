import 'package:carecar_mobile/nucleo/dispositivo/nombre_del_dispositivo.dart';
import 'package:carecar_mobile/sesion/almacen_sesion.dart';
import 'package:carecar_mobile/sesion/controlador_sesion.dart';
import 'package:flutter_test/flutter_test.dart';

import '../ayudas/api_falsa.dart';

/// V2-M01.09 · el login manda el nombre del equipo.
///
/// Sin esto la lista de «mis sesiones abiertas» muestra todas las sesiones
/// iguales y el criterio de la historia no se cumple. Pero leer el nombre toca
/// la plataforma, asi que lo que mas importa probar es lo otro: **que no poder
/// leerlo no impida entrar**.
void main() {
  ControladorSesion controlador(ApiFalsa api, {LectorDelDispositivo? lector}) =>
      ControladorSesion(api, AlmacenEnMemoria(), lector);

  test('manda el nombre del equipo junto con las credenciales', () async {
    final api = ApiFalsa();
    final sesion = controlador(
      api,
      lector: () async => (equipo: 'Pixel 7', sistema: 'Android 14'),
    );

    await sesion.iniciarSesion(
      correo: 'cliente1@example.com',
      contrasena: 'CareCar2026',
    );

    expect(api.ultimaPeticion!.dispositivo, 'Pixel 7 · Android 14');
    expect(sesion.estado, isA<Autenticada>());
  });

  test('si no se puede leer el nombre, entra igual y sin la llave', () async {
    // El plugin puede fallar en un equipo raro o con permisos recortados.
    // Quedarse fuera de la app por no saber como se llama el telefono seria
    // mucho peor que una sesion sin nombre en la lista.
    final api = ApiFalsa();
    final sesion = controlador(
      api,
      lector: () async => throw StateError('sin plataforma'),
    );

    await sesion.iniciarSesion(
      correo: 'cliente1@example.com',
      contrasena: 'CareCar2026',
    );

    expect(sesion.estado, isA<Autenticada>());
    expect(api.ultimaPeticion!.dispositivo, isNull);
    expect(api.ultimaPeticion!.toJson().containsKey('dispositivo'), isFalse);
  });

  test('sin lector tampoco manda nada: el nombre es opcional', () async {
    // Es como queda el controlador en las pruebas y en cualquier flujo que no
    // lo inyecte. El contrato lo declara opcional justo para esto.
    final api = ApiFalsa();
    final sesion = controlador(api);

    await sesion.iniciarSesion(
      correo: 'cliente1@example.com',
      contrasena: 'CareCar2026',
    );

    expect(sesion.estado, isA<Autenticada>());
    expect(api.ultimaPeticion!.dispositivo, isNull);
  });
}
