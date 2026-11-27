import 'package:geolocator/geolocator.dart';

/// Abre la pantalla de ajustes **de la app** en el sistema.
///
/// Es la unica salida cuando un permiso quedo negado para siempre: ni Android
/// ni iOS vuelven a mostrar su dialogo, y la app no puede concederse nada a si
/// misma. La usan la camara (V2-M24.05) y los avisos (V2-M06.01).
///
/// ## Por que `Geolocator`
///
/// `Geolocator.openAppSettings()` abre los ajustes de la app, **no** los de
/// ubicacion: pese al nombre del paquete no es especifico de ubicacion, y
/// `geolocator` ya es dependencia. La alternativa era sumar `app_settings`
/// solo para esta llamada.
///
/// Vive en el nucleo por la decision 0006: los paquetes de ubicacion no salen
/// de aqui. Asi ningun modulo importa `geolocator` para abrir una pantalla.
Future<void> abrirAjustesDeLaApp() => Geolocator.openAppSettings();
