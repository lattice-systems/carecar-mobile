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
