import 'dart:math';

import 'package:carecar_mobile/modulos/notificaciones/datos/instalacion_de_la_app.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// V2-M06.02 · el `instalacionId` que va en `/dispositivos/{instalacionId}`.
///
/// El contrato pide 8 a 64 caracteres con letras, dígitos y guiones. Tiene que
/// ser el mismo en cada arranque: si cambiara, cada apertura dejaría un
/// dispositivo nuevo en el servidor y el viejo seguiría recibiendo avisos.
void main() {
  final patron = RegExp(r'^[A-Za-z0-9-]{8,64}$');
  final uuidV4 = RegExp(
    r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
  );

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('genera un UUID v4 que cumple el contrato', () async {
    final prefs = await SharedPreferences.getInstance();

    final id = await InstalacionDeLaApp(prefs).obtener();

    expect(id, matches(patron));
    expect(id, matches(uuidV4));
  });

  test('es el mismo en el siguiente arranque', () async {
    final prefs = await SharedPreferences.getInstance();

    final primero = await InstalacionDeLaApp(prefs).obtener();
    final segundo = await InstalacionDeLaApp(prefs).obtener();

    expect(segundo, primero);
  });

  test('dos instalaciones no comparten identificador', () async {
    final prefs = await SharedPreferences.getInstance();
    final otra = InstalacionDeLaApp(null, azar: Random(1));

    expect(
      await otra.obtener(),
      isNot(await InstalacionDeLaApp(prefs).obtener()),
    );
  });

  test('un valor guardado que no cumple el contrato se reemplaza', () async {
    SharedPreferences.setMockInitialValues({
      InstalacionDeLaApp.clave: 'mal id!',
    });
    final prefs = await SharedPreferences.getInstance();

    final id = await InstalacionDeLaApp(prefs).obtener();

    expect(id, matches(uuidV4));
    expect(prefs.getString(InstalacionDeLaApp.clave), id);
  });

  test('sin preferencias dura lo que dure el proceso', () async {
    final instalacion = InstalacionDeLaApp(null);

    expect(await instalacion.obtener(), await instalacion.obtener());
  });
}
