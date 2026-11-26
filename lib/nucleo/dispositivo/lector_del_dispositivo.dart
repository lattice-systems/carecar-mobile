import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';

import 'nombre_del_dispositivo.dart';

/// Lee el modelo y la version del sistema del equipo · V2-M01.09.
///
/// **Es el unico archivo que depende de `device_info_plus`.** Todo lo demas
/// trabaja contra [LectorDelDispositivo], asi que cambiar de plugin o pasar a
/// un canal nativo propio toca solo esto.
///
/// Lo que se lee son **datos del modelo, no de la persona**: ni un
/// identificador del equipo ni nada que la senale. Es lo que pide
/// `Registro.depurar` del lado de seguridad y lo que el contrato espera en
/// `dispositivo`.
Future<DatosDelDispositivo> leerDatosDelDispositivo() async {
  final info = DeviceInfoPlugin();

  if (Platform.isAndroid) {
    final android = await info.androidInfo;
    return (
      equipo: equipoDe(marca: android.manufacturer, modelo: android.model),
      sistema: 'Android ${android.version.release}',
    );
  }

  if (Platform.isIOS) {
    final ios = await info.iosInfo;
    return (
      // `utsname.machine` da «iPhone15,2»; `name` es el nombre que la persona
      // le puso al telefono y **si** la identifica, asi que no se manda.
      equipo: ios.modelName,
      sistema: '${ios.systemName} ${ios.systemVersion}',
    );
  }

  // La app solo se publica en Android y iOS. En cualquier otra plataforma -las
  // pruebas de escritorio, por ejemplo- no se inventa un nombre.
  return (equipo: null, sistema: null);
}
