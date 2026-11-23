import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Llaves de firma de release: se leen de android/key.properties, que NO se
// versiona (ver android/key.properties.example y docs/publicacion.md).
// Sin ese archivo, release se firma con la llave de debug para que
// `flutter run --release` siga funcionando en local; ese APK no sirve para
// publicar.
val propiedadesFirma = Properties()
val archivoFirma = rootProject.file("key.properties")
if (archivoFirma.exists()) {
    propiedadesFirma.load(FileInputStream(archivoFirma))
}

android {
    namespace = "com.carecar.carecar_mobile"
    // flutter_local_notifications 23 exige compilar contra 37. Solo cambia
    // las APIs disponibles al compilar; targetSdk sigue en 35 (PO-3).
    compileSdk = 37
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        // flutter_local_notifications usa java.time en Android viejos.
        isCoreLibraryDesugaringEnabled = true
    }

    defaultConfig {
        applicationId = "com.carecar.carecar_mobile"
        // Versiones definidas por el PO (respuesta PO-3, 20 oct 2026):
        // minSdk 24 = Android 7.0, targetSdk 35 = Android 15.
        //
        // minSdk se deja en el de Flutter porque ya vale 24, que es justo lo
        // que pidio el PO. targetSdk si se fija a mano: Flutter 3.47 trae 36 y
        // el PO pidio 35.
        minSdk = flutter.minSdkVersion
        targetSdk = 35
        // Version y numero de build salen de `version:` en pubspec.yaml
        // (1.0.0+1 -> versionName 1.0.0, versionCode 1).
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // Flavors (V2-T01.04): nombre, applicationId y permiso de http en claro por
    // ambiente. El sufijo del applicationId deja instalar los tres a la vez. El
    // nombre del flavor es el mismo que el de `Flavor` en lib/config/flavor.dart.
    // Solo `desarrollo` permite http en claro (el mock local); `pruebas` y
    // `produccion` quedan HTTPS. Los iconos distintos viven en
    // src/<flavor>/res (tool/generar_iconos_flavor.py).
    buildFeatures {
        resValues = true
    }
    flavorDimensions += "entorno"
    productFlavors {
        create("desarrollo") {
            dimension = "entorno"
            applicationIdSuffix = ".dev"
            resValue("string", "app_name", "CareCar Dev")
            manifestPlaceholders["usesCleartextTraffic"] = "true"
        }
        create("pruebas") {
            dimension = "entorno"
            applicationIdSuffix = ".pruebas"
            resValue("string", "app_name", "CareCar Pruebas")
            manifestPlaceholders["usesCleartextTraffic"] = "false"
        }
        create("produccion") {
            dimension = "entorno"
            resValue("string", "app_name", "CareCar")
            manifestPlaceholders["usesCleartextTraffic"] = "false"
        }
    }

    signingConfigs {
        if (archivoFirma.exists()) {
            create("release") {
                keyAlias = propiedadesFirma["keyAlias"] as String
                keyPassword = propiedadesFirma["keyPassword"] as String
                storeFile = file(propiedadesFirma["storeFile"] as String)
                storePassword = propiedadesFirma["storePassword"] as String
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (archivoFirma.exists()) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
