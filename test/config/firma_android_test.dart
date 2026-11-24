import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// V2-T04.02 y V2-T04.03 (Android): la firma sale de GitHub Secrets y nunca
/// del repositorio, con una llave de pruebas separada de la de producción.
void main() {
  String leer(String ruta) => File(ruta).readAsStringSync();

  test('release.yml firma con los secretos de produccion', () {
    final flujo = leer('.github/workflows/release.yml');
    expect(flujo, contains('scripts/preparar-firma-android.sh'));
    expect(flujo, contains('secrets.ANDROID_PRODUCCION_LLAVE_BASE64'));
    expect(flujo, isNot(contains('ANDROID_PRUEBAS_')));
  });

  test('cada merge a main publica el APK de pruebas con su propia llave', () {
    final flujo = leer('.github/workflows/apk-prueba.yml');
    expect(flujo, contains('branches: [main]'));
    expect(flujo, contains('secrets.ANDROID_PRUEBAS_LLAVE_BASE64'));
    expect(flujo, isNot(contains('ANDROID_PRODUCCION_')));
    expect(flujo, contains('--flavor pruebas'));
    expect(flujo, contains('--prerelease'));
  });

  test('el keystore se escribe fuera del repositorio', () {
    final script = leer('scripts/preparar-firma-android.sh');
    expect(script, contains(r'RUNNER_TEMP'));
    expect(script, contains('android/key.properties'));
  });

  test('git ignora llaves y key.properties', () {
    final ignorados = leer('.gitignore');
    for (final patron in ['*.jks', '*.keystore', 'key.properties']) {
      expect(ignorados, contains(patron));
    }
    final versionados = Process.runSync('git', ['ls-files']).stdout as String;
    expect(versionados, isNot(contains('key.properties\n')));
    expect(versionados, isNot(contains('.jks')));
  });
}
