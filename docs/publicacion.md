# Publicación y ambientes

Cómo compilar CareCar para staging y producción, firmar los builds y publicarlos en Google Play y App Store.

> [!IMPORTANT]
> Las llaves de firma, las cuentas de desarrollador y la URL de staging **no están en el repositorio** y no se deben crear desde aquí. Las aporta el responsable del proyecto (ver «Qué falta» al final).

---

## 1. Dirección de la API (`--dart-define`)

La app no tiene dirección por omisión: se pasa al compilar con `API_BASE_URL`.

| Ambiente | Comando |
| --- | --- |
| Local, celular por USB (`adb reverse tcp:8080 tcp:8080`) | `--dart-define=API_BASE_URL=http://localhost:8080/api/v1/app` |
| Local, emulador Android | `--dart-define=API_BASE_URL=http://10.0.2.2:8080/api/v1/app` |
| **Staging** | `--dart-define=API_BASE_URL=https://STAGING-POR-DEFINIR.example/api/v1/app` |
| Producción | `--dart-define=API_BASE_URL=https://PRODUCCION-POR-DEFINIR.example/api/v1/app` |

> [!WARNING]
> `STAGING-POR-DEFINIR.example` y `PRODUCCION-POR-DEFINIR.example` son **marcadores**: todavía no existe un servidor de staging con HTTPS. Reemplázalos cuando el equipo lo defina.

Para no repetir la URL, se puede guardar en un archivo JSON **fuera de git** y usar `--dart-define-from-file`:

```bash
# config/staging.json (agrega config/*.json al .gitignore si guardas datos sensibles)
{ "API_BASE_URL": "https://STAGING-POR-DEFINIR.example/api/v1/app" }

flutter run --release --dart-define-from-file=config/staging.json
```

### HTTPS obligatorio

- **Dart:** en compilaciones release, `ApiConfig.para` rechaza cualquier dirección que no sea `https` (`lib/api/api_config.dart`) y la app muestra el error de arranque.
- **Android:** el tráfico sin cifrar solo se permite en debug (`android/app/src/debug/AndroidManifest.xml`); en release se aplica el valor por omisión de Android 9+ (bloqueado).
- **iOS:** App Transport Security bloquea `http` por omisión; no se agregan excepciones en `Info.plist`.

---

## 2. Versión y número de build

Salen de `version:` en `pubspec.yaml` (`1.0.0+1` → nombre `1.0.0`, build `1`). Android los toma con `flutter.versionName`/`flutter.versionCode` e iOS con `FLUTTER_BUILD_NAME`/`FLUTTER_BUILD_NUMBER`.

Antes de cada publicación **sube el número de build** (las tiendas rechazan uno repetido). También se puede sobrescribir: `--build-name=1.1.0 --build-number=7`.

---

## 3. Android · Google Play

### Firma

1. El responsable genera (una sola vez) el keystore de subida y lo guarda **fuera del repo** con respaldo seguro:
   ```bash
   keytool -genkey -v -keystore ~/llaves/carecar-release.jks -keyalg RSA -keysize 2048 -validity 10000 -alias carecar
   ```
2. Copia `android/key.properties.example` a `android/key.properties` (ignorado por git) y llena `storePassword`, `keyPassword`, `keyAlias` y `storeFile`.
3. `android/app/build.gradle.kts` lee ese archivo. Si no existe, release se firma con la llave de debug (sirve para probar en local, **no para publicar**).

En CI, el keystore se guardaría como secreto (base64) y se escribiría a disco en el job; hoy CI solo compila debug.

### Compilar y publicar

```bash
flutter build appbundle --release --dart-define=API_BASE_URL=https://.../api/v1/app
# -> build/app/outputs/bundle/release/app-release.aab
```

1. Cuenta de Google Play Console (pago único) a nombre de la agencia.
2. Crear la app con el id `com.carecar.carecar_mobile` y activar **Play App Signing**.
3. Llenar ficha (descripción, capturas, ícono 512 px), clasificación de contenido, **seguridad de los datos** y URL del aviso de privacidad.
4. Subir el `.aab` a **Prueba interna**, probar, y promover a cerrada/producción.

---

## 4. iOS · App Store

Requiere una Mac con Xcode y una cuenta del **Apple Developer Program** (cuota anual).

1. En Xcode (`ios/Runner.xcworkspace`) → *Signing & Capabilities*: elegir el *Team* y dejar firma automática. Bundle id actual: `com.carecar.carecarMobile`.
2. En App Store Connect crear la app con ese bundle id.
3. Compilar y subir:
   ```bash
   flutter build ipa --release --dart-define=API_BASE_URL=https://.../api/v1/app
   # -> build/ios/ipa/*.ipa ; se sube con Transporter o `xcrun altool`/Xcode Organizer
   ```
4. Probar con **TestFlight**, llenar privacidad («App Privacy»), capturas y enviar a revisión.

CI compila iOS **sin firmar** (`flutter build ios --no-codesign`) solo para detectar errores de compilación.

---

## 5. Qué falta (lo aporta el responsable)

- [ ] Keystore de subida de Android y sus contraseñas (en `android/key.properties`, fuera de git).
- [ ] Cuenta de Google Play Console.
- [ ] Cuenta del Apple Developer Program y *Team ID*.
- [ ] URL HTTPS de staging (y de producción).
- [ ] URL del aviso de privacidad (la piden ambas tiendas).
