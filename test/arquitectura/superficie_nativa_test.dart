import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// V2-M22.08: lo que la app expone o le pide al sistema, comprobado en el
/// manifiesto de Android y en `pubspec.yaml`. Son los controles de la revisión
/// MASVS que se pueden vigilar sin correr la app (`docs/seguridad/
/// revision-masvs-l1.md`): si uno falla, no se arregla el texto de la prueba,
/// se decide si el cambio es correcto y se actualiza la revisión.
///
/// Los permisos de red y el tráfico en claro por flavor ya los vigila
/// `test/config/flavors_nativos_test.dart` (V2-M22.09).
const _rutaManifiesto = 'android/app/src/main/AndroidManifest.xml';

/// Los permisos revisados y para qué sirve cada uno. Uno nuevo debe pasar por la
/// revisión (minimizar el acceso a datos sensibles, MASVS-PRIVACY-1).
const _permisosRevisados = <String, String>{
  'android.permission.INTERNET': 'hablar con el backend',
  'android.permission.POST_NOTIFICATIONS':
      'recordatorios de citas y mantenimiento',
  'android.permission.RECEIVE_BOOT_COMPLETED':
      'reprogramar los recordatorios al reiniciar el teléfono',
  'android.permission.ACCESS_FINE_LOCATION':
      'pedir ayuda en carretera y agendar la recolección',
  'android.permission.ACCESS_COARSE_LOCATION':
      'lo mismo, si la persona solo da la ubicación aproximada',
  // V2-M01.05. Lo pide `local_auth` para usar BiometricPrompt. No da acceso a
  // ningún dato biométrico: la app solo recibe un sí o un no del sistema.
  // Revisado en AUTH-2 y PRIVACY-1 de `docs/seguridad/revision-masvs-l1.md`.
  'android.permission.USE_BIOMETRIC':
      'desbloquear la app con huella o rostro, si la persona lo prende',
};

/// Dependencias que traen una superficie que esta revisión no cubre. Agregar
/// una exige revisar antes ese frente (MASVS-PLATFORM-2 para los WebViews) y
/// actualizar el documento.
const _dependenciasQueExigenRevision = <String, String>{
  'webview_flutter': 'MASVS-PLATFORM-2 (WebViews)',
  'webview_flutter_android': 'MASVS-PLATFORM-2 (WebViews)',
  'webview_flutter_wkwebview': 'MASVS-PLATFORM-2 (WebViews)',
  'flutter_inappwebview': 'MASVS-PLATFORM-2 (WebViews)',
  'flutter_webview_plugin': 'MASVS-PLATFORM-2 (WebViews)',
};

String _manifiesto() => File(_rutaManifiesto).readAsStringSync();

/// Las etiquetas de apertura de [nombre] (`<service ...>`), con sus atributos.
Iterable<String> _etiquetas(String xml, String nombre) =>
    RegExp('<$nombre\\b[^>]*>', dotAll: true).allMatches(xml).map((m) => m[0]!);

String? _atributo(String etiqueta, String nombre) =>
    RegExp('android:$nombre\\s*=\\s*"([^"]*)"').firstMatch(etiqueta)?[1];

void main() {
  group('manifiesto de Android (V2-M22.08)', () {
    test('las copias de seguridad de la app están apagadas', () {
      // Sin esto, la caché con datos personales y los datos cifrados de la
      // sesión viajan a la copia de seguridad en la nube de Google y por adb
      // (MASVS-STORAGE-2).
      final aplicacion = _etiquetas(_manifiesto(), 'application').single;

      expect(_atributo(aplicacion, 'allowBackup'), 'false');
    });

    test('solo la actividad principal es accesible desde otras apps', () {
      final xml = _manifiesto();
      final accesibles = <String>[];
      for (final componente in [
        'activity',
        'activity-alias',
        'service',
        'receiver',
        'provider',
      ]) {
        for (final etiqueta in _etiquetas(xml, componente)) {
          final nombre = _atributo(etiqueta, 'name') ?? '?';
          final exportado = _atributo(etiqueta, 'exported');
          // Explícito en todos: sin el atributo, el valor depende de si tiene
          // filtros de intención y de la versión de Android.
          expect(
            exportado,
            isNotNull,
            reason: '<$componente $nombre> no declara android:exported',
          );
          if (exportado == 'true') accesibles.add(nombre);
        }
      }

      expect(accesibles, ['.MainActivity']);
    });

    test('la compilación no se puede depurar', () {
      expect(
        _atributo(
          _etiquetas(_manifiesto(), 'application').single,
          'debuggable',
        ),
        isNull,
      );
    });

    test('pide solo los permisos revisados', () {
      final pedidos = RegExp(r'<uses-permission[^>]*android:name="([^"]+)"')
          .allMatches(_manifiesto())
          .map((m) => m[1]!)
          .toSet();

      expect(
        pedidos.difference(_permisosRevisados.keys.toSet()),
        isEmpty,
        reason:
            'Permiso nuevo en el manifiesto: revisa si hace falta (MASVS-PRIVACY-1), '
            'agrégalo a esta lista con su motivo y a docs/seguridad/revision-masvs-l1.md.',
      );
      expect(
        _permisosRevisados.keys.toSet().difference(pedidos),
        isEmpty,
        reason: 'Un permiso revisado ya no se pide: quítalo de esta lista y del documento.',
      );
    });
  });

  group('dependencias (V2-M22.08)', () {
    test('no hay WebViews ni otras superficies sin revisar', () {
      final pubspec = File('pubspec.yaml').readAsStringSync();
      for (final MapEntry(key: paquete, value: control)
          in _dependenciasQueExigenRevision.entries) {
        expect(
          RegExp('^\\s+$paquete\\s*:', multiLine: true).hasMatch(pubspec),
          isFalse,
          reason: '«$paquete» exige revisar $control antes de agregarlo.',
        );
      }
    });
  });
}
