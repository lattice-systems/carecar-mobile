# carecar-mobile

Aplicación móvil CareCar, construida con Flutter.

## Requisitos

- Flutter SDK 3.47.5 o superior (canal `stable`)
- Dart SDK 3.13.4 o superior (incluido con Flutter)
- Android Studio / Xcode según la plataforma de destino

Verifica que tu entorno esté listo con:

```bash
flutter doctor
```

## Puesta en marcha

```bash
git clone <url-del-repositorio>
cd carecar-mobile
flutter pub get
flutter run
```

## Comandos útiles

```bash
flutter analyze        # análisis estático
flutter test           # pruebas
flutter build apk      # compilación Android
flutter build ios      # compilación iOS
flutter build web      # compilación Web
```

## Estructura

```
lib/            código de la aplicación
test/           pruebas
android/        proyecto Android
ios/            proyecto iOS
web/            proyecto Web
windows/        proyecto Windows
macos/          proyecto macOS
linux/          proyecto Linux
```

## Notas

- El identificador de paquete del proyecto Dart es `carecar_mobile` (los nombres de
  paquete de Dart no admiten guiones); el repositorio se llama `carecar-mobile`.
- El application id / bundle id es `com.carecar.carecar_mobile`.
- Los archivos de configuración local (`android/local.properties`,
  `ios/Flutter/Generated.xcconfig`, `.dart_tool/`, `build/`) se generan
  automáticamente y están excluidos del control de versiones.
