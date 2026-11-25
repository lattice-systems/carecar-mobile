# Publicación y firma de Android

Cómo se firman y distribuyen los APK (V2-T04.02 y V2-T04.03). iOS va aparte: sin cuenta de Apple Developer se instala con Sideloadly ([guía](guia-instalar-ios-sin-mac.md)).

## Dos llaves, ninguna en el repositorio

| Llave | Firma | Secretos de GitHub |
| --- | --- | --- |
| **pruebas** | El APK de prueba de cada merge a `main` (flavor `pruebas`, app «CareCar Pruebas») | `ANDROID_PRUEBAS_LLAVE_BASE64`, `ANDROID_PRUEBAS_LLAVE_CONTRASENA`, `ANDROID_PRUEBAS_LLAVE_ALIAS` |
| **produccion** | Los Release `vX.Y.Z` (flavor `produccion`) y, más adelante, Google Play | `ANDROID_PRODUCCION_LLAVE_BASE64`, `ANDROID_PRODUCCION_LLAVE_CONTRASENA`, `ANDROID_PRODUCCION_LLAVE_ALIAS` |

Están separadas para que filtrar la de pruebas no comprometa la app publicada. `.gitignore` excluye `*.jks`, `*.keystore` y `key.properties`, y `test/config/firma_android_test.dart` vigila que nada de eso esté versionado.

## Crear las llaves (una sola vez)

En una computadora con JDK (`keytool`) y `gh` con sesión iniciada y permiso de administrador del repo:

```bash
scripts/crear-llaves-android.sh
```

Crea `~/.carecar-llaves/carecar-{pruebas,produccion}.jks` con contraseñas al azar y sube los seis secretos. Si una llave ya existe, la reusa y solo vuelve a subir sus secretos.

**Respalda la de producción** (`carecar-produccion.jks` y `carecar-produccion.contrasena`) en el gestor de contraseñas del equipo. Si se pierde, la app ya publicada en la tienda no se puede actualizar.

## Cómo firma CI

`scripts/preparar-firma-android.sh` decodifica el keystore del secreto en `$RUNNER_TEMP` (fuera del repo) y escribe `android/key.properties`, que `android/app/build.gradle.kts` usa para el `release`. Sin secretos avisa y el APK queda con la llave de debug, como antes; el Release lo dice en sus notas.

- `release.yml` (etiqueta `vX.Y.Z`): llave de producción.
- `apk-prueba.yml` (cada merge a `main` que toca código): llave de pruebas; publica `carecar-pruebas.apk` en el pre-release **`prueba-main`**, que se reemplaza en cada merge.

## Instalar el APK de prueba

Abre en el teléfono Android la página de Releases del repositorio, entra a **CareCar Pruebas · main** y descarga `carecar-pruebas.apk`. La primera vez Android pide permitir instalar desde el navegador. Se instala junto a la app de producción porque tiene otro paquete (`com.carecar.carecar_mobile.pruebas`).

## Firmar en local

Copia `android/key.properties.example` a `android/key.properties` y apunta `storeFile` a tu `.jks` fuera del repo. Sin ese archivo, `flutter run --release` firma con la llave de debug.

## R8 y los plugins con clases opcionales

Los builds de release (APK de prueba y Release) pasan por R8. Si un plugin nombra clases que la app no incluye, R8 aborta con `Missing classes` y el APK no se genera; los builds de CI de PR son de depuración y no lo detectan. Las reglas propias viven en `android/app/proguard-rules.pro` (hoy, los reconocedores de chino, devanagari, japonés y coreano de ML Kit, que la bitácora no usa). Al agregar un plugin con código nativo, compila una vez `flutter build apk --release --flavor pruebas -t lib/main_pruebas.dart`; R8 deja las reglas que faltan en `build/app/outputs/mapping/pruebasRelease/missing_rules.txt`.
