# T03 · Calidad y pruebas

| Campo | Valor |
| --- | --- |
| Hito | H1 (base) y siempre |
| Dueño | Haziel (aceptación) · todos escriben pruebas |
| Revisa | Daniel |
| Estado | Listo para historias |

## Historias

| ID | Historia | Criterios de aceptación | B | Depende de |
| --- | --- | --- | --- | --- |
| V2-T03.01 | Como equipo queremos reglas de análisis más estrictas | `analysis_options.yaml` con lints estrictos acordados · CI sin avisos | | — |
| V2-T03.02 | Como equipo queremos pruebas golden | Herramienta de golden elegida · fuentes reales · corren en CI (Linux) | | V2-T02.01 |
| V2-T03.03 | Como equipo queremos `integration_test` del flujo principal | Login → garaje → agendar → cancelar contra `mock_api` en CI (emulador) | | V2-T01.03 |
| V2-T03.04 | Como equipo queremos cobertura visible | Reporte de cobertura en CI · meta alta en `dominio/` y `datos/` | | — |
| V2-T03.05 | Como PO quiero que cada criterio de aceptación tenga su prueba | Convención de nombre `V2-Mxx.nn: <criterio>` en las pruebas · enlazadas desde `cumplimiento-ficha.md` | | — |
| V2-T03.06 | Como equipo queremos que la API simulada siga al contrato v2 | `mock_api` y prueba de contrato actualizadas con cada endpoint nuevo | | V2-T05.02 |
| V2-T03.07 | Como equipo queremos pruebas en celular físico por hito | Guion de prueba manual en `docs/pruebas/` y evidencia por hito | | — |
| V2-T03.08 | Como equipo queremos la API simulada partida por módulo para que varias personas agreguen endpoints a la vez sin chocar | Rutas de cada módulo en `mock_api/modulos/<modulo>.js` y su semilla en `mock_api/semillas/<modulo>.json` · `server.js` solo los junta · los endpoints de hoy responden igual (mismos casos de error y formato `Problema`) · `npm run reset` arma la base desde todas las semillas · `mock_api/README.md` explica cómo agregar un módulo | | — |

## V2-T03.02 · Pruebas golden

Se usa `matchesGoldenFile` de `flutter_test`. Las suites Portada y Mensajes cargan directamente los archivos de Inter, JetBrains Mono y Material Icons y cubren cinco muestras de la galería en claro, oscuro y letra al 200 %. El job de pruebas de Linux compara las imágenes y usa el reporte expandido para registrar los errores de preparación. El procedimiento de ejecución y regeneración está en el [sistema de diseño v2](../../docs/diseno/sistema-de-diseno-v2.md#pruebas-golden).
