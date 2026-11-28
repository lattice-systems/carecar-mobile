import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../nucleo/api/proveedores_api.dart';
import '../../../nucleo/idioma/proveedores_idioma.dart';
import '../datos/instalacion_de_la_app.dart';
import '../datos/repositorio_dispositivos_api.dart';
import '../datos/servicio_push_nulo.dart';
import '../dominio/push.dart';

/// De dónde sale el token de push (V2-M06.02). Hoy es el nulo: no hay
/// Firebase, así que no hay token ni peticiones. Activar el push real es
/// sobrescribir este proveedor con la implementación de Firebase.
final servicioPushProvider = Provider<ServicioPush>(
  (ref) => const ServicioPushNulo(),
  name: 'servicioPushProvider',
);

/// `PUT` y `DELETE /dispositivos/{instalacionId}`. Solo se lee cuando hay un
/// token que registrar.
final repositorioDispositivosProvider = Provider<RepositorioDispositivos>(
  (ref) => RepositorioDispositivosApi(ref.watch(apiClienteProvider)),
  name: 'repositorioDispositivosProvider',
);

/// El `instalacionId` de este teléfono, guardado en preferencias.
final instalacionDeLaAppProvider = Provider<InstalacionDeLaApp>(
  (ref) => InstalacionDeLaApp(ref.watch(preferenciasProvider)),
  name: 'instalacionDeLaAppProvider',
);

/// La plataforma que va en el registro. Fuera de iOS se dice `android`: es la
/// única otra que acepta el contrato y la única otra en la que corre la app.
final plataformaPushProvider = Provider<PlataformaPush>(
  (ref) => defaultTargetPlatform == TargetPlatform.iOS
      ? PlataformaPush.ios
      : PlataformaPush.android,
  name: 'plataformaPushProvider',
);
