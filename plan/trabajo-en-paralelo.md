# Trabajo en paralelo

Cómo trabajamos las 6 personas (y sus agentes) a la vez sin esperarnos ni pisarnos. Complementa el flujo de una historia de [`../AGENTS.md`](../AGENTS.md) y la Definición de Listo de [`README.md`](README.md). Si algo de aquí choca con `AGENTS.md`, gana `AGENTS.md`.

La idea de fondo: **casi ninguna dependencia bloquea de verdad**. Lo que falta se simula (backend), se sustituye por algo provisional (componentes) o se aísla por carpeta (código de otros). Solo esperamos lo que no se puede simular.

## 1. Qué bloquea y qué no

| Dependencia pendiente | ¿Bloquea? | Cómo se avanza |
| --- | --- | --- |
| Historia de backend (`V2-T05.xx` o la parte **B** de una historia) | **No** | Contrato primero + `mock_api` (sección 2). En el tablero se marca `(simulable)`. |
| Componente del sistema de diseño (historia `V2-T02.xx`) | **No** | Componente provisional en tu módulo (sección 4). En el tablero se marca `(provisional)`. |
| Datos que produce otro módulo (p. ej. "que exista una cita") | **No** | Se siembran en `mock_api` y en el fake de tu repositorio. |
| Pantalla o flujo de otro módulo que tu historia usa de verdad | Sí | Toma otra historia; avisa al dueño si es urgente. |
| `V2-T01.02` (esqueleto `lib/nucleo` + `lib/modulos`) | Sí, para código en `lib/modulos/` | Mientras se integra, toma lo de la columna "Ahora" de la sección 10. |
| Un hito (`H2`, `H6`) | Según [`hitos.md`](hitos.md) | Los hitos ordenan, no encierran: si no tienes nada en el hito activo, toma del siguiente. |

Toda historia de módulo necesita implícitamente `V2-T01.02`, aunque su fila no lo diga: el código vive en `lib/modulos/`.

## 2. Contrato primero

Ninguna historia de app espera a una historia **B**. El orden es contrato → simulación → app y backend a la vez:

1. **Contrato.** El dueño de la historia (que lo es de punta a punta) describe el endpoint nuevo o el cambio en `agencia-360-backend/docs/api/agencia360-api-app-v2.yaml` con un PR chico `docs(api): ...`, y lo copia en `api/` de este repo. Mientras `V2-T05.02` no exista, el contrato es la tabla **API** del archivo del módulo en [`modulos/`](modulos/README.md).
2. **Simulación.** El mismo dueño agrega el endpoint a `mock_api`, con sus errores en formato `Problema` (ver sección 6 para no chocar en ese archivo).
3. **App.** Se programa contra el fake del repositorio en pruebas y contra `mock_api` al correr la app (`--dart-define=API_BASE_URL=http://10.0.2.2:3000/api/v1/app`).
4. **Backend.** En paralelo, en `agencia-360-backend`, contra el mismo contrato. El diseño técnico (tablas, migración, eventos, endpoints) se escribe en el primer commit de la historia en `agencia-360-backend/plan/historias-backend.md`.
5. **Cambio a la API real.** Cuando el backend se integra, la app solo cambia la URL. Si el backend tuvo que cambiar el contrato, primero se corrige el contrato, luego `mock_api` y la app.

`V2-T05.02` (contrato v2) es la primera historia de Ricardo: sin ella, cada quien describe su endpoint en su módulo y se copia al contrato cuando nazca.

## 3. Interfaces y fakes en el núcleo

Cada módulo arranca contra un fake, nunca contra la red:

- **Interfaz** del repositorio en `lib/modulos/<modulo>/dominio/` (Dart puro), p. ej. `RepositorioCitas`.
- **Implementación real** en `datos/`, que recibe la API del núcleo (`carecarApiProvider`); nunca un `http.Client` propio.
- **Fake** en memoria en `datos/` (como `repositorio_avisos_fake.dart` del módulo `ejemplo` de `V2-T01.02`), con datos de ejemplo y la opción de fallar a pedido.
- **Proveedor** `repositorioCitasProvider` en `presentacion/`. Las pruebas y el flavor `desarrollo` lo sustituyen con `ProviderScope(overrides: [...])`.

Así una pantalla se construye, se prueba y se integra antes de que exista el endpoint. Pasar de fake a `mock_api` y de `mock_api` al backend real no cambia la pantalla, solo el proveedor o la URL.

`V2-T01.08` (Jael) deja las piezas comunes: errores de API tipados, la vista de cinco estados (cargando, datos, vacío, error, sin conexión) y fakes reutilizables para pruebas. Hasta que se integre, cada módulo copia el patrón del módulo `ejemplo` y luego se pasa a las piezas comunes.

## 4. Componentes provisionales

Si tu pantalla necesita un componente del catálogo ([`../docs/diseno/sistema-de-diseno-v2.md`](../docs/diseno/sistema-de-diseno-v2.md)) que aún no existe:

1. Busca su historia `V2-T02.xx` en el tablero. Si no hay, pide al planificador que la cree (o créala tú con un PR `docs(plan): ...`).
2. Haz un provisional en `lib/modulos/<modulo>/presentacion/provisional/`, solo con tokens y componentes que ya existen (nada de colores ni medidas sueltas).
3. Ponle arriba el comentario `// PROVISIONAL: se reemplaza por <Componente> de V2-T02.xx`.
4. No lo exportes en `<modulo>.dart` ni lo uses desde otro módulo. No lleva golden.
5. Cuando la historia T02 se integre, el dueño del módulo lo reemplaza en su siguiente PR que toque esa pantalla. Un hito no cierra con provisionales: `grep -rn "PROVISIONAL" lib/` debe salir vacío.

Esto no contradice la decisión 0004: el componente del sistema se sigue construyendo primero en `lib/nucleo/diseno`; el provisional es andamio temporal de una pantalla, no un componente nuevo.

## 5. Propiedad por carpeta

Cada quien escribe casi siempre en sus carpetas. Si necesitas cambiar algo en la de otra persona, haz un PR chico aparte y avísale; no lo mezcles con tu historia.

| Carpeta | Dueño |
| --- | --- |
| `lib/modulos/<modulo>/` y `test/modulos/<modulo>/` | Dueño del módulo ([`modulos/README.md`](modulos/README.md)) |
| `lib/nucleo/diseno/` y `test/nucleo/diseno/` | Cristian (T02) |
| `lib/nucleo/api/`, `lib/nucleo/sesion/` | Daniel (T01). Jael en lo que agregue `V2-T01.08` |
| `lib/nucleo/navegacion/`, `lib/app.dart`, `lib/main*.dart` | Daniel (T01.03, T01.04) |
| `test/arquitectura/` (reglas de dependencia, V2-T01.06) | Daniel (T01). Si tu PR lo rompe, usa el `<modulo>.dart` del otro módulo; no agregues excepciones sin avisarle |
| `lib/nucleo/datos_locales/` | Jael (M21) |
| `lib/nucleo/notificaciones/` | Jael (M06) |
| `lib/nucleo/l10n/` | Cristian (M20); todos agregan claves (sección 6) |
| `lib/nucleo/observabilidad/` | Haziel (M23) |
| `mock_api/` | Haziel (T03); todos agregan sus endpoints (sección 6) |
| Backend: paquete de Modulith del módulo | Dueño de las historias **B** del módulo (`agencia-360-backend/plan/historias-backend.md`) |
| Backend: `docs/api/` (contrato) | Ricardo (T05); todos agregan sus endpoints |

Nombres de carpeta de módulo para que M02 no sea un cuello de botella: `acceso` (M01), `vehiculos` (M02 garaje, detalle, manuales y ficha técnica: Juan Pablo), `citas` (M02 agenda y citas: Juan Pablo), `historial` (M02 historial y tickets: Ricardo), `catalogo` (M03), `taller` (M04), `mantenimiento` (M05), `notificaciones` (M06), `mensajeria` (M07), `pagos` (M08), `documentos` (M09), `garantia` (M10), `asistencia` (M11), `lealtad` (M12), `promociones` (M13), `tienda` (M14), `encuestas` (M15), `estreno` (M16), `recoleccion` (M17), `bitacora` (M18), `familia` (M19), `privacidad` (M22), `asistente` (M24), `widgets` (M25), `valuacion` (M26), `ayuda` (M27). Si una carpeta ya existe con otro nombre, gana la existente.

## 6. Archivos calientes

Son los archivos que todos tocan. Cada uno tiene una regla para que dos PR no choquen.

| Archivo | Regla |
| --- | --- |
| `pubspec.yaml` y `pubspec.lock` | Cada dependencia nueva va en **su propio PR chico** `build(deps): agregar <paquete> para V2-xxx`, sin nada más, y se integra en cuanto CI pase. Tu historia se rebasa sobre él. Si dos PR chocan, quien integra después rebasa y regenera el lock con `flutter pub get`; el lock nunca se combina a mano. |
| Registro de rutas | Cada módulo expone sus rutas en `lib/modulos/<modulo>/<modulo>_rutas.dart` (una lista de rutas). El enrutador de la app (fuera de `nucleo/`, que no conoce módulos) solo las junta: agregar un módulo es una línea. Hasta `V2-T01.03` no se registran rutas; las pantallas se prueban desde pruebas de widget. |
| Proveedores (inyección) | Sin registro central: cada módulo declara sus proveedores en su carpeta. `main.dart` solo inyecta los del núcleo. |
| ARB de textos (`lib/nucleo/l10n/app_es.arb`, `app_en.arb`) | Claves con el prefijo de la carpeta del módulo (`citasTituloAgendar`, `accesoErrorCredenciales`); textos compartidos con prefijo `comun` (los cuida Cristian). El archivo va **ordenado por clave**, así cada módulo cae en su propia zona. Solo se agregan claves; nunca se renombran ni reordenan las de otros. Hasta que `V2-M20.01` se integre, los textos de cada módulo viven en una clase de constantes de su carpeta y se pasan al ARB de una vez. |
| `mock_api/` | Cada módulo registra sus rutas en `mock_api/modulos/<modulo>.js` y separa las colecciones persistentes en `mock_api/semillas/<modulo>.json`. `server.js` ensambla los módulos. [Cómo agregar un módulo](../mock_api/README.md#agregar-un-módulo) |
| Migraciones Flyway (backend) | El número de versión **se toma al final**: al rebasar sobre `origin/main` justo antes de integrar, nombra tu migración con el siguiente número libre (el mayor de `main` + 1; los huecos viejos no se rellenan). Si mientras tanto alguien integró ese número, renombra **tu** archivo (nunca uno integrado) y vuelve a correr `./mvnw verify`. Si ya la habías aplicado en tu base local, recréala. |
| Contrato OpenAPI | Tus rutas y esquemas juntos, bajo la etiqueta (`tag`) de tu módulo. No reordenes ni reformatees lo de otros. |
| [`tablero.md`](tablero.md) | Solo editas **tu fila** (estado y PR). Nunca se regenera el archivo ni se reformatea la tabla con un script o un formateador. En un conflicto, conserva en cada fila el **estado más avanzado** (`Borrador` < `Lista` < `En curso` < `En revisión` < `Hecha`) y junta los números de PR de ambos lados. Filas nuevas, totales y marcas `(simulable)`/`(provisional)` solo en PR del planificador. |
| `modulos/<modulo>.md` | Lo edita el dueño del módulo. El avance de cada historia va en su propia sección `## Avance de V2-xxx` al final del archivo. |
| [`cumplimiento-ficha.md`](cumplimiento-ficha.md) | Solo las filas que mueve tu historia. |
| Conteos en [`equipo-y-reparto.md`](equipo-y-reparto.md) y totales | Solo el planificador, en el mismo PR que agrega o mueve historias. |

## 7. WIP, PR chicos e integración frecuente

- **Una historia `En curso` por persona.** Al abrir su PR pasa a `En revisión` y, mientras esperas CI o revisión, puedes tomar la siguiente `En curso`. Atender comentarios de tus PR va antes que avanzar la nueva.
- Si ya tienes dos historias `En revisión`, antes de tomar otra integra las tuyas o revisa PR de otros.
- **PR chicos:** una historia, o una tanda de una historia grande (como hicieron `V2-T02.04` y `V2-T02.05`). La historia sigue `En curso` y acumula sus PR en la columna PR. Abre el PR en borrador en cuanto haya algo revisable.
- **Integra varias veces al día:** `git fetch && git rebase origin/main` al empezar y antes de cada push. Con checks verdes se integra (no se exige aprobación). Una rama que vive mucho acumula conflictos.

## 8. Interruptor de rutas v1/v2

Para integrar pantallas a medias sin romper la app v1:

- Hasta `V2-T01.05`, las pantallas v2 no se alcanzan desde la navegación v1: solo desde pruebas y, cuando existan, desde la galería de `V2-T02.06` en el flavor `desarrollo` (`V2-T01.04`).
- Con `V2-T01.05` (hecho), cada módulo tiene su interruptor v1/v2 (`--dart-define=MODULOS_V2=...` / `MODULOS_V1=...`; desde `V2-T01.09` el valor por defecto en código es todo en v2; la recuperación de contraseña es la excepción, V2-T01.10): un módulo nuevo se prueba encendido en desarrollo y queda fuera del valor por defecto hasta que esté completo (guía en [`arquitectura-v2.md`](arquitectura-v2.md#migrar-un-módulo-con-el-interruptor-v1v2-v2-t0105)); cablearlo por flavor llega con `V2-T01.04`. Así una pantalla incompleta llega a `main` sin que nadie la vea en el build de prueba.
- Nada que se integre puede romper un flujo v1 que hoy funciona.

## 9. Agentes

Cada persona puede correr su propio equipo de agentes (roles en [`../AGENTS.md`](../AGENTS.md)), siempre sobre **sus** historias:

- `sincronizador` antes de empezar; luego un `orquestador` que lee el tablero y reparte **tus** historias.
- Un `implementador` por historia, cada uno en su worktree: `git worktree add ../wt-<id> -b feat/v2-<id>-<descripcion> origin/main`. El worktree se borra al integrar.
- Dentro del límite de WIP el paralelismo sale de tres lados: la historia `En curso` más las que están `En revisión` (cada una en su worktree para atender comentarios); en una historia con **B**, dos implementadores a la vez, uno en `agencia-360-backend` y otro en `carecar-mobile` contra `mock_api`, con el mismo contrato; y el `planificador` refinando o diseñando la siguiente historia mientras tanto.
- Los agentes no tocan filas del tablero ni carpetas de otras personas, y firman como la persona dueña (sin co-autor de IA).

## 10. Qué puede tomar cada quien desde ya

"Ahora" no necesita `V2-T01.02`. "Al integrarse V2-T01.02" se toma en cuanto el esqueleto llegue a `main`. En negritas, las historias llave: desbloquean a los demás y van primero.

| Persona | Ahora | Al integrarse V2-T01.02 | Después |
| --- | --- | --- | --- |
| Daniel | `V2-T01.02` (en curso) · `V2-T04.01` | **`V2-T01.03`** (rutas: desbloquea `V2-T03.03`, `V2-M01.04`, `V2-M06.01`) · `V2-T01.04` · `V2-T01.06` | `V2-T01.05`, `V2-T04.02`, `V2-M22.05`, `V2-M22.06` |
| Haziel | **`V2-T03.02`** (golden: los componentes lo esperan) · **`V2-T03.08`** (`mock_api` por módulo) · `V2-T03.01` · `V2-T03.04` · `V2-T03.05` · `V2-T03.07` · `V2-M23.02` | `V2-M27.05` · `V2-M27.01` (B simulable) | `V2-T03.06` cuando exista `V2-T05.02`; `V2-T03.03` cuando exista `V2-T01.03` |
| Cristian | `V2-T02.05` (tandas que faltan) · `V2-T02.02` · `V2-T02.07` · `V2-T02.09` | **`V2-M20.01`** (textos al ARB) · `V2-M03.01` (provisional) | `V2-T02.06` cuando estén `V2-T02.05`, `V2-T02.13` y `V2-T02.14`; `V2-M03.02` |
| Ricardo | **`V2-T05.02`** (contrato v2: base de "contrato primero") · `V2-T05.07` · `V2-T05.06` · `V2-T05.03` · `V2-T05.04` · `V2-T05.01` · `V2-T05.09` · `V2-T05.10` | `V2-M02.05` (simulable) | `V2-M02.06`, `V2-M04.01` |
| Juan Pablo | `V2-M11.03` (sin dependencias) | `V2-M02.01` (provisional) · `V2-M02.07` (simulable) | `V2-M02.02`, `V2-M02.08`, `V2-M11.03` |
| Jael | Revisar el PR de `V2-T01.02` (es revisora de T01) · PR `build(deps)` de `drift` y su cifrado para `V2-M21.01` | **`V2-T01.08`** (núcleo de datos) · `V2-M21.01` | `V2-M01.02`, `V2-M01.01`, `V2-M21.04` (provisional) |

Si todo lo tuyo está bloqueado, aplica "Nunca sin trabajo" de [`equipo-y-reparto.md`](equipo-y-reparto.md).

## Rama `dev` y CI en dos niveles

Para que los builds no frenen la integración, el trabajo diario va a `dev` y `main` queda como la rama estable.

| Qué | PR a `dev` / push a `dev` | PR `dev` → `main` / push a `main` |
| --- | --- | --- |
| Formato, análisis, `flutter test` | Sí | Sí |
| Integración Android (emulador), APK, iOS | No (se saltan) | Sí |
| `Autoría` (sin co-autor de IA) | Sí | Sí |
| CodeQL, revisión de dependencias, pines TLS | No | Sí |

- Rama de trabajo desde `dev`, PR a `dev`; integra quien abre el PR al pasar la CI rápida.
- Cuando `dev` junta una tanda de historias, se abre un PR `dev` → `main` y se integra con merge commit, sin squash, para no divergir.
- Mantén `dev` al día con `main` (`git merge origin/main`) tras cada integración a `main`.
- Los jobs saltados cuentan como aprobados para los checks requeridos, así que la protección de `dev` exige solo los checks rápidos.
