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

## V2-T03.01 · Análisis estático

Sobre `flutter_lints` se activan `avoid_void_async` para conservar el `Future` de las operaciones asíncronas, `no_adjacent_strings_in_list` para detectar comas omitidas en listas y `prefer_final_in_for_each` para declarar inmutable la variable de iteración cuando corresponda. El job de análisis exige cero avisos e informes con `flutter analyze --fatal-infos --fatal-warnings`.

## V2-T03.02 · Pruebas golden

Se usa `matchesGoldenFile` de `flutter_test`. Las suites Portada y Mensajes cargan directamente los archivos de Inter, JetBrains Mono y Material Icons y cubren cinco muestras de la galería en claro, oscuro y letra al 200 %. El job de pruebas de Linux compara las imágenes y usa el reporte expandido para registrar los errores de preparación. El procedimiento de ejecución y regeneración está en el [sistema de diseño v2](../../docs/diseno/sistema-de-diseno-v2.md#pruebas-golden).

## V2-T03.03 · Flujo principal en Android

La [prueba de integración](../../integration_test/flujo_principal_test.dart) arranca CareCar, inicia sesión, abre el garaje, agenda y cancela en la interfaz. Al regresar a Mis citas verifica que la cancelación sigue visible después de volver a consultar el servidor. CI usa un emulador Android de API 35 y el mock en memoria, con franjas de fecha relativa para que el guion siga funcionando con el calendario real.

Desde la raíz del repo, puedes correr `npm ci --prefix mock_api` y `bash tool/probar_flujo_android.sh emulator-5554` con un emulador abierto. En PowerShell inicia `node mock_api/pruebas/servidor_flujo.js` en una terminal. En otra ejecuta `flutter test integration_test/flujo_principal_test.dart -d emulator-5554 --flavor desarrollo '--dart-define=MODULOS_V2=vehiculos,citas'`. Usa una instalación de desarrollo dedicada a pruebas porque el guion reinicia su sesión local.

## V2-T03.04 · Cobertura visible

El job de pruebas publica `cobertura-carecar` con `coverage/lcov.info` y muestra en el resumen las líneas ejecutadas y los archivos instrumentados del total de `lib/`, `dominio/` y `datos/`. La meta inicial es de **85 % de líneas instrumentadas por capa** en dominio y datos. Es una meta de seguimiento. La primera ejecución fija la línea base y los archivos sin datos quedan visibles en el resumen.

Para reproducir el informe, ejecuta `flutter test --coverage` y `node tool/resumir_cobertura.js` desde la raíz del repo.

## V2-T03.05 · Evidencia de los criterios de aceptación

Las pruebas de aceptación usan el título `V2-Mxx.nn: <criterio>` y se enlazan en la [matriz de la ficha](../cumplimiento-ficha.md#evidencia-automática-por-criterio). La [prueba de arquitectura](../../test/arquitectura/criterios_en_matriz_test.dart) detecta pruebas identificadas sin enlace, enlaces obsoletos y nombres que no coinciden. El registro empieza con 18 pruebas existentes de acceso, garaje, citas, catálogo y asistente. Cada historia amplía su evidencia al cubrir más criterios.

## V2-T03.06 · Contrato de la API simulada

La [prueba de contrato](../../test/contrato/mock_api_v2_test.dart) coteja el inventario real de métodos y rutas con `api/agencia360-api-app-v2.yaml`. Comprueba las respuestas `Problema` de las operaciones protegidas y casos autenticados de JSON, PDF y SSE. CI instala las dependencias del mock y ejecuta la prueba con semillas en memoria. [Ejecución local](../../mock_api/README.md#agregar-un-módulo)

La cobertura de respuestas autenticadas es por casos representativos. La variante `multipart/form-data` de `POST /vehiculos/{vehiculoId}/lecturas-km` queda pendiente en el simulador de M05.

## V2-T03.08 · Mock por módulo

`server.js` arranca json-server, registra guardia y módulos, y devuelve `Problema` en las rutas desconocidas. Las rutas y sus datos persistentes viven en `modulos/` y `semillas/`. `npm run reset` reúne las colecciones de todas las semillas y vuelve a crear `db.json`. Los módulos con colecciones incorporadas tras el primer MVP conservan la inicialización de los archivos persistidos anteriores. [Guía del mock](../../mock_api/README.md#agregar-un-módulo)
