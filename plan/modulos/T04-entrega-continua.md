# T04 · Entrega continua y distribución

| Campo | Valor |
| --- | --- |
| Hito | H1 (interna) → H7 (tiendas) |
| Dueño | Daniel |
| Revisa | Ricardo |
| Estado | Listo para historias |

## Historias

| ID | Historia | Criterios de aceptación | B | Depende de |
| --- | --- | --- | --- | --- |
| V2-T04.01 | Como equipo queremos versión automática | `version` de `pubspec.yaml` y número de build desde CI · etiqueta git por release | | — |
| V2-T04.02 | Como equipo queremos firmar builds en CI sin secretos en el repo | Llaves en GitHub Secrets · keystore de pruebas separado del de producción | | V2-T04.01 |
| V2-T04.03 | Como equipo queremos un APK/IPA de prueba por cada merge a `main` | Distribución interna (p. ej. Firebase App Distribution / TestFlight) para las 6 personas | | V2-T04.02 |
| V2-T04.04 | Como equipo queremos el check `Autoría` requerido | Agregado a la protección de `main` · **Hecha con V2-H0.03**: `Sin co-autor de IA` es check requerido del ruleset de `main` | | — |
| V2-T04.05 | Como equipo queremos notas de versión automáticas | Generadas de los commits convencionales entre etiquetas | | V2-T04.01 |
| V2-T04.06 | Como equipo queremos publicar en pista interna de Google Play y App Store | Fichas, capturas, política de privacidad | | H6 |

## Avance de V2-T04.01

**Fuente única:** `version: x.y.z+n` de `pubspec.yaml`. El nombre de versión (`x.y.z`) se cambia a mano por PR; el número de build **no se edita**: CI lo pone con `--build-number=${{ github.run_number }}` (monótono), que prevalece sobre el `+n` del pubspec. Android lee ambos de ahí (`flutter.versionName` / `flutter.versionCode`).

**Dónde se aplica**

- `ci.yml` (job `Build Android (APK)`): `flutter build apk --debug --flavor <desarrollo|pruebas|produccion> -t lib/main_<flavor>.dart --build-number=<run_number>` (los tres flavors, V2-T01.04).
- `release.yml` (nuevo): corre al empujar una etiqueta `v*.*.*`. Pasos: (1) verifica que la etiqueta sea `v` + la versión del pubspec y que su commit esté en `main`, si no falla con mensaje claro; (2) compila `flutter build apk --release --flavor produccion -t lib/main_produccion.dart --build-name=<pubspec> --build-number=<run_number>`; desde V2-T01.04 la dirección es la del flavor y la variable `API_BASE_URL`, si existe, solo la sobrescribe (ya no falla si falta); (3) crea el GitHub Release con `gh` y adjunta `carecar-vX.Y.Z.apk`. Es el único workflow con `contents: write`; no usa acciones de terceros nuevas.
- La pantalla de perfil ya lee la versión del paquete (`leerVersionApp`, con `package_info_plus`); no hay versión escrita a mano que cambiar (el `1.0.0` de `lib/config/version_app.dart` es solo el respaldo si la lectura falla).

**Cómo sacar una versión**

1. Por PR, sube `version` en `pubspec.yaml` (p. ej. `1.1.0+1`; el `+n` da igual) y actualiza lo que corresponda en docs.
2. Integra el PR a `main` (CI en verde).
3. Desde `main` actualizado: `git tag vX.Y.Z && git push origin vX.Y.Z`.
4. El workflow `Release` publica el Release con el APK. Si la etiqueta no coincide con el pubspec, falla antes de compilar; bórrala (`git push origin :refs/tags/vX.Y.Z`; `git tag -d vX.Y.Z`) y repite desde el paso 1 o 3.

**Límites conocidos**

- Sin los secretos de V2-T04.02 el APK va firmado con la **llave de debug** (el `build.gradle.kts` ya cae a debug si no hay `key.properties`); el Release lo dice. No sirve para tiendas.
- `github.run_number` cuenta por workflow: el número de build de `ci.yml` y el de `release.yml` son series distintas. Para el APK de prueba por merge (V2-T04.03) habrá que decidir una sola serie si ambos se instalan sobre el mismo teléfono.
- iOS: el equipo no tiene Mac; el Release adjunta un IPA **sin firmar** para sideload (ver "Avance de V2-T04.03" abajo).
- Las notas del Release salen de los commits (V2-T04.05); por eso importa el formato `tipo(alcance): verbo + cambio`.


## Avance de V2-T04.05: notas de versión automáticas

- `scripts/notas-de-version.sh vX.Y.Z` toma los commits sin merges desde la etiqueta `v*` anterior (o todo el historial si es la primera) y los agrupa: `feat` → **Novedades**, `fix` → **Correcciones**, `perf` → **Rendimiento**; lo demás (docs, test, build, ci, chore, refactor) solo se cuenta. Cada línea queda «Descripción (alcance)». Ignora etiquetas que no empiezan con `v` (como `prueba-main`).
- `release.yml` las pone al inicio de las notas del Release, antes de la línea del APK, la firma y el IPA.
- Prueba: `test/config/notas_de_version_test.dart` arma un repo temporal con dos etiquetas y revisa las secciones.

## Avance de V2-T04.02 y V2-T04.03 (Android)

- **Firma sin secretos en el repo:** dos keystores, `pruebas` y `produccion`, en GitHub Secrets (`ANDROID_{PRUEBAS,PRODUCCION}_LLAVE_{BASE64,CONTRASENA,ALIAS}`). `scripts/preparar-firma-android.sh` los escribe en `$RUNNER_TEMP` y genera `android/key.properties`; sin secretos se firma con debug y se avisa. Detalle y cómo crear las llaves: [`docs/publicacion.md`](../../docs/publicacion.md).
- **Release:** `release.yml` firma con la llave de producción y las notas dicen con qué llave salió.
- **APK por merge:** `apk-prueba.yml` compila el flavor `pruebas` en release con la llave de pruebas y lo publica en el pre-release fijo `prueba-main` (distribución interna gratis: el equipo lo descarga desde GitHub). Con su propio `run_number` y paquete `.pruebas`, no choca con la serie de los Release.
- Probado en local: con una llave desechable, `flutter build apk --release --flavor pruebas` sale firmada con ella (`apksigner verify`).
- **Llaves creadas** (2026-11-24) con `scripts/crear-llaves-android.sh` en la computadora de Daniel (`~/.carecar-llaves/`), y sus seis secretos subidos al repo. **Pendiente:** respaldar `carecar-produccion.jks` y `carecar-produccion.contrasena` en el gestor de contraseñas del equipo. iOS sigue sin firma: no hay cuenta de Apple Developer de paga.

## Avance de V2-T04.03: IPA sin firmar para sideload

**Por qué sideload y no TestFlight.** En el equipo hay **un solo iPhone**, nadie tiene Mac ni la membresía de Apple Developer. TestFlight (el criterio de V2-T04.03) y la firma en CI de iOS (V2-T04.02) necesitan esa membresía. Mientras no exista, el iPhone se prueba con un IPA sin firmar que Sideloadly firma en Windows con un Apple ID gratis. Guía paso a paso: [`docs/guia-instalar-ios-sin-mac.md`](../../docs/guia-instalar-ios-sin-mac.md).

**Qué hay**

- `ipa-sin-firma.yml`: `workflow_dispatch` (a mano) y `workflow_call`. En `macos-latest` corre `flutter build ios --release --no-codesign --flavor produccion -t lib/main_produccion.dart --build-name=<pubspec> --build-number=<run_number>` (la variable `API_BASE_URL`, si existe, sobrescribe la dirección), mete `Runner.app` en `Payload/`, lo comprime con `zip -qry` y lo sube con `actions/upload-artifact` sin zip alrededor (`archive: false`) por 30 días. Nombre: `carecar-vX.Y.Z-build<n>.ipa` a mano; `carecar-vX.Y.Z.ipa` desde Release.
- `release.yml`: después de publicar el Release con el APK, el job `ipa` llama a `ipa-sin-firma.yml` y `adjuntar-ipa` sube el IPA al mismo Release. Si la etiqueta no pasa la verificación no se gastan minutos de macOS; si falla iOS, el APK ya quedó publicado.
- Probado tras integrar el PR #72: la corrida manual en `main` tardó unos 4 minutos y dejó `carecar-v1.0.0-build1.ipa` (30 MB) con `Payload/Runner.app/` en la raíz, bundle id `com.carecar.carecarMobile`, versión `1.0.0 (1)`, iOS mínimo 15.0 y la `API_BASE_URL` de la variable dentro de `App.framework`. Se descarga directo desde el navegador; con `gh` usa `gh api …/actions/artifacts/<id>/zip`, porque `gh run download` lo descomprime.
- Decisión: workflow propio en vez de solo un job en `release.yml`, para poder sacar un IPA de `main` sin etiquetar versión; Release lo reusa para que haya una sola receta.

**Límites conocidos**

- No corre en cada merge (los minutos de macOS son caros) y no hay distribución a las 6 personas: V2-T04.03 sigue `Lista` hasta tener TestFlight (o Firebase App Distribution) y V2-T04.02 sigue sin firma de iOS.
- Apple ID gratis: la firma dura 7 días, máximo 3 apps por sideload y 10 App IDs por semana. Push remotas, App Groups (el widget de V2-M25.01 cuando entre al proyecto Xcode), enlaces universales e iniciar sesión con Apple no funcionarían; detalle en la guía.
- `github.run_number` del IPA manual es otra serie distinta de la de CI y de Release.
