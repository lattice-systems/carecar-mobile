import 'package:package_info_plus/package_info_plus.dart';

/// Version de la app leida del paquete; con respaldo si la lectura falla.
Future<String> leerVersionApp() async {
  try {
    final info = await PackageInfo.fromPlatform();
    return info.version.isEmpty ? '1.0.0' : info.version;
  } on Object {
    return '1.0.0';
  }
}
