import 'dart:io';

import 'package:carecar_mobile/config/flavor.dart';
import 'package:flutter_test/flutter_test.dart';

/// Vigila que lo nativo diga lo mismo que `Flavor` (V2-T01.04): no se puede
/// compilar iOS aqui, asi que al menos se comprueban los archivos.
void main() {
  final gradle = File('android/app/build.gradle.kts').readAsStringSync();

  String bloque(String flavor) {
    final inicio = gradle.indexOf('create("$flavor")');
    expect(inicio, isNonNegative, reason: 'falta el flavor $flavor en Gradle');
    final fin = gradle.indexOf('}', inicio);
    return gradle.substring(inicio, fin);
  }

  group('Android', () {
    for (final f in Flavor.values) {
      test('${f.name}: nombre y permiso de http en claro coinciden', () {
        final b = bloque(f.name);
        expect(b, contains('"${f.nombreApp}"'));
        expect(
          b,
          contains('"usesCleartextTraffic"] = "${f.permiteHttpEnClaro}"'),
        );
      });
    }

    test('el manifiesto usa el marcador y el nombre del flavor', () {
      final m = File('android/app/src/main/AndroidManifest.xml')
          .readAsStringSync();
      expect(
        m,
        contains(r'android:usesCleartextTraffic="${usesCleartextTraffic}"'),
      );
      expect(m, contains('android:label="@string/app_name"'));
    });

    test('desarrollo y pruebas traen su propio icono', () {
      for (final f in ['desarrollo', 'pruebas']) {
        expect(
          File('android/app/src/$f/res/mipmap-xxxhdpi/ic_launcher.png')
              .existsSync(),
          isTrue,
        );
      }
    });
  });

  group('iOS', () {
    test('solo el Info.plist de desarrollo abre ATS', () {
      final base = File('ios/Runner/Info.plist').readAsStringSync();
      final dev = File('ios/Runner/Info-desarrollo.plist').readAsStringSync();
      expect(base, isNot(contains('NSAppTransportSecurity')));
      expect(dev, contains('NSAllowsArbitraryLoads'));
    });

    test('Info-desarrollo.plist solo difiere del base por ATS', () {
      final base = File('ios/Runner/Info.plist').readAsStringSync();
      final dev = File('ios/Runner/Info-desarrollo.plist').readAsStringSync();
      final sinAts = dev.replaceFirst(
        RegExp(
          r'\t<key>NSAppTransportSecurity</key>.*?</dict>\n',
          dotAll: true,
        ),
        '',
      );
      expect(sinAts, base);
    });

    for (final f in Flavor.values) {
      test('${f.name}: scheme, xcconfig y nombre existen', () {
        expect(
          File('ios/Runner.xcodeproj/xcshareddata/xcschemes/${f.name}.xcscheme')
              .existsSync(),
          isTrue,
        );
        final x = File('ios/Flutter/${f.name}.xcconfig').readAsStringSync();
        expect(x, contains('APP_DISPLAY_NAME = ${f.nombreApp}'));
        expect(
          x.contains('Info-desarrollo.plist'),
          f.permiteHttpEnClaro,
          reason: 'solo desarrollo usa el plist con ATS abierto',
        );
      });
    }
  });

  group('CI (V2-M22.09)', () {
    for (final archivo in [
      '.github/workflows/release.yml',
      '.github/workflows/ipa-sin-firma.yml',
    ]) {
      test('$archivo rechaza un API_BASE_URL que no sea https', () {
        final flujo = File(archivo).readAsStringSync();
        expect(flujo, contains('Exigir HTTPS en API_BASE_URL'));
        expect(flujo, contains(r'"$API_BASE_URL" != https://*'));
      });
    }
  });
}
