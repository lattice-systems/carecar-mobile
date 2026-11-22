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

- `ci.yml` (job `Build Android (APK)`): `flutter build apk --debug --build-number=<run_number>`.
- `release.yml` (nuevo): corre al empujar una etiqueta `v*.*.*`. Pasos: (1) verifica que la etiqueta sea `v` + la versión del pubspec y que su commit esté en `main`, si no falla con mensaje claro; (2) compila `flutter build apk --release --build-name=<pubspec> --build-number=<run_number>`; (3) crea el GitHub Release con `gh` y adjunta `carecar-vX.Y.Z.apk`. Es el único workflow con `contents: write`; no usa acciones de terceros nuevas.
- La pantalla de perfil ya lee la versión del paquete (`leerVersionApp`, con `package_info_plus`); no hay versión escrita a mano que cambiar (el `1.0.0` de `lib/config/version_app.dart` es solo el respaldo si la lectura falla).

**Cómo sacar una versión**

1. Por PR, sube `version` en `pubspec.yaml` (p. ej. `1.1.0+1`; el `+n` da igual) y actualiza lo que corresponda en docs.
2. Integra el PR a `main` (CI en verde).
3. Desde `main` actualizado: `git tag vX.Y.Z && git push origin vX.Y.Z`.
4. El workflow `Release` publica el Release con el APK. Si la etiqueta no coincide con el pubspec, falla antes de compilar; bórrala (`git push origin :refs/tags/vX.Y.Z`; `git tag -d vX.Y.Z`) y repite desde el paso 1 o 3.

**Límites conocidos**

- Mientras no exista V2-T04.02 el APK va firmado con la **llave de debug** (el `build.gradle.kts` ya cae a debug si no hay `key.properties`); el Release lo dice. No sirve para tiendas.
- `github.run_number` cuenta por workflow: el número de build de `ci.yml` y el de `release.yml` son series distintas. Para el APK de prueba por merge (V2-T04.03) habrá que decidir una sola serie si ambos se instalan sobre el mismo teléfono.
- Solo Android: el equipo no tiene Mac, así que el job de iOS no cambia y el Release no incluye IPA.
- Las notas del Release son fijas; las automáticas son V2-T04.05.

