# AGENTS.md — cómo se trabaja en `carecar-mobile`

Archivo canónico para **cualquier** agente de código (Claude Code, Codex, Antigravity/Gemini, Cursor…) y para las personas. `CLAUDE.md` y `GEMINI.md` solo apuntan aquí. Si algo choca con otro documento, gana este orden:

1. **Ficha técnica v2.1** — [`docs/ficha-tecnica/`](docs/ficha-tecnica/README.md). Obligatoria, sí o sí.
2. **Este archivo** (reglas de trabajo).
3. **Plan maestro v2** — [`plan/`](plan/README.md) (propósito, hitos, módulos, reparto, tablero).
4. Decisiones de arquitectura — [`docs/decisiones/`](docs/decisiones/).
5. Sistema de diseño v2 — [`docs/diseno/`](docs/diseno/sistema-de-diseno-v2.md).
6. `README.md` y el resto de `docs/`.

Idioma: **español** en docs, commits, PR, nombres de dominio y comentarios.

---

## 1. El proyecto en tres líneas

App móvil **CareCar** (Flutter, Android + iOS) para clientes postventa de la agencia. Consume la API de `agencia-360-backend` (módulo `carecarapp`, `/api/v1/app`). El MVP v1 ya está en `main`; ahora construimos la **v2 nueva** sobre la ficha técnica: más módulos, nuevo diseño, nueva arquitectura. Prioridad del equipo: **móvil > backend**. CRM y ERP web están **congelados** (no se tocan).

## 2. Reglas no negociables

| # | Regla |
| --- | --- |
| R1 | **La ficha se cumple.** Ninguna historia puede quitar, renombrar o contradecir tablas, campos o funciones de la ficha. Toda historia que toque un módulo de la ficha actualiza [`plan/cumplimiento-ficha.md`](plan/cumplimiento-ficha.md). |
| R2 | **Documentación siempre, sin excepción.** Todo PR actualiza la documentación afectada (plan, tablero, módulo, README, decisiones, diseño). Un PR sin cambio en docs se rechaza salvo que el PR mismo explique por qué ningún documento cambió… y aun así actualiza `plan/tablero.md`. |
| R3 | **Sin IA como autor o co-autor.** Prohibido `Co-Authored-By:` de Claude/Codex/Gemini/Copilot/Antigravity y prohibidas líneas tipo "Generated with". El autor es la persona dueña de la tarea. Lo vigilan el hook [`.githooks/commit-msg`](.githooks/commit-msg) y el workflow `Autoría`. |
| R4 | **Commits atómicos con intención.** Un commit = un cambio con un porqué. Formato `<tipo>(<alcance>): <verbo + cambio>` ([`docs/convenciones-commits.md`](docs/convenciones-commits.md)). El cuerpo explica el **porqué**, no el qué. Nada de `wip`, `update`, `fix` solos. |
| R5 | **Nada directo a `main`.** Rama `<tipo>/<id-historia>-<descripcion>` → PR → checks verdes (incluido `Sin co-autor de IA`) → merge commit. La revisión de otra persona se recomienda pero **no es obligatoria** (por ahora). Abre el PR en cuanto la rama tenga algo revisable (borrador si hace falta). |
| R6 | **Todos contribuyen.** Las 6 personas programan, sin importar su rol Scrum. El reparto vive en [`plan/equipo-y-reparto.md`](plan/equipo-y-reparto.md). |
| R7 | **Sin fechas en el plan.** Se planea con objetivos, hitos y criterios de salida; nunca con calendarios. |
| R8 | **Sin secretos en el repo.** `.env`, llaves y tokens fuera de git (ver `.gitignore`). |
| R9 | **CRM y ERP congelados.** Si una historia los necesita, se documenta como dependencia en el tablero y no se toca su repo. |

Primera vez en el repo (una sola vez por clon):

```bash
git config core.hooksPath .githooks   # activa el hook que quita co-autores de IA
```

## 3. Roles de agente

Los roles son los mismos en cualquier herramienta. En Claude Code existen como subagentes en [`.claude/agents/`](.claude/agents/); en Codex/Antigravity el agente **adopta el rol** que el humano le pida ("actúa como planificador").

| Rol | Modelo sugerido (Claude) | Hace | No hace |
| --- | --- | --- | --- |
| **Sincronizador** | Haiku | Baja cambios de todos los repos y **descarta todo lo local** (`fetch` → `reset --hard origin/main` → `clean -fd`). Reporta estado. | Commits, push, decidir nada. |
| **Planificador** (estratega) | Opus | Lee ficha + plan, diseña módulos nuevos, parte módulos en historias con criterios comprobables, escribe decisiones (ADR), mantiene `plan/`. Propone sin límites; la ficha es el único piso. | Escribir código de producto. |
| **Orquestador** | Sonnet | Administra el trabajo: lee el tablero, asigna historias a implementadores (una por worktree), vigila WIP, que cada PR traiga docs y commits atómicos, y mueve el tablero. | Implementar historias él mismo. |
| **Implementador** | Sonnet | Toma **una** historia, la hace con TDD en su rama/worktree, commits atómicos, actualiza docs y tablero, abre el PR. | Tomar más de una historia a la vez; tocar alcance ajeno. |

Flujo típico en Claude Code: `sincronizador` → `planificador` (si la historia no está lista) → `orquestador` reparte → N × `implementador` en paralelo (worktrees) → humano revisa PR.

## 4. Flujo de una historia

1. **Elegir** del tablero ([`plan/tablero.md`](plan/tablero.md)) una historia `Lista` del hito activo, asignada a ti (o sin dueño en tu frente).
2. **Rama** desde `main` actualizado: `feat/v2-m04-03-linea-de-tiempo-taller`.
3. **Tablero**: primer commit mueve la historia a `En curso` con tu nombre (`docs(tablero): tomar V2-M04.03`).
   - Si es **B**, el siguiente commit escribe su diseño (tablas, migración, eventos, endpoints con errores) en `agencia-360-backend/plan/historias-backend.md` y el endpoint en el contrato. No se espera a que alguien más lo diseñe.
   - Si depende de una historia de backend sin integrar, **no esperes**: trabaja contra el contrato y `mock_api` (dependencia `(simulable)` en el tablero).
4. **TDD**: prueba que falla → código mínimo → refactor. Un commit por paso con intención.
5. **Docs**: ficha del módulo (`plan/modulos/`), README, decisiones, diseño, cumplimiento de ficha — lo que aplique.
6. **Verificar local**: `dart format lib test && flutter analyze && flutter test`.
7. **PR** con la plantilla; enlaza la historia; capturas si hay UI (claro y oscuro).
8. **Tablero**: `En revisión` en el PR; `Hecha` lo marca quien integra.

**Trabajo en paralelo.** Las estrategias para que las 6 personas avancen a la vez sin esperarse ni pisarse (contrato primero con `mock_api`, interfaces y fakes, componentes provisionales, propiedad por carpeta, reglas de los archivos calientes, WIP, interruptor v1/v2, agentes y qué puede tomar cada quien) están en [`plan/trabajo-en-paralelo.md`](plan/trabajo-en-paralelo.md). Síguelas en cada historia.

## 5. Definición de Hecho (DoD)

- Criterios de aceptación de la historia comprobados (prueba automática por criterio cuando se pueda).
- `dart format`, `flutter analyze` sin avisos, `flutter test` verde, CI verde.
- Cumple R1–R4; documentación y tablero actualizados en el mismo PR.
- UI: usa solo tokens/componentes del sistema de diseño v2; probado en claro, oscuro, letra grande (200 %) y pantalla chica; textos con lector de pantalla.
- Errores de red, vacío, carga y sin conexión resueltos (nada de pantallas en blanco).
- Revisado por otra persona del equipo cuando sea posible (recomendado, no obligatorio por ahora).

## 6. Comandos

```bash
flutter pub get
flutter run --flavor desarrollo -t lib/main_desarrollo.dart   # mock_api (en emulador Android usa 10.0.2.2)
dart format lib test        # formato
flutter analyze             # análisis estático
flutter test                # pruebas
flutter build apk --debug --flavor desarrollo -t lib/main_desarrollo.dart   # lo que compila CI (los tres flavors)
cd mock_api && npm install && npm start   # API simulada en :3000
```

## 7. Arquitectura

- **Hoy (v1):** `lib/api` (cliente `http` a mano, interfaz `CarecarApi`), `lib/sesion` (`ChangeNotifier` + almacén seguro), `lib/pantallas`, `lib/widgets`, `lib/tema` (`shadcn_ui` + Material). Contrato en `api/agencia360-api-app-v1.yaml`.
- **Objetivo (v2):** por módulo funcional (`lib/modulos/<modulo>/{datos,dominio,presentacion}`) sobre un núcleo común (`lib/nucleo/`). Ver [`docs/decisiones/`](docs/decisiones/) y [`plan/arquitectura-v2.md`](plan/arquitectura-v2.md). Mientras una decisión esté `Propuesta`, no se migra código por ella.
- El contrato OpenAPI es compartido con el backend: un cambio de contrato se hace **primero** en `agencia-360-backend/docs/api/` y se copia aquí en el mismo hito.

## 8. Diseño

El diseño v1 queda **retirado**. Todo lo nuevo sigue [`docs/diseno/sistema-de-diseno-v2.md`](docs/diseno/sistema-de-diseno-v2.md): si un componente no existe ahí, se agrega primero al sistema (doc + componente + prueba golden) con su historia `V2-T02.xx`. Mientras esa historia no se integra, la pantalla que lo necesita no espera: usa un **provisional** en `lib/modulos/<modulo>/presentacion/provisional/`, hecho solo con tokens y componentes existentes y marcado `// PROVISIONAL: se reemplaza por <Componente> de V2-T02.xx` ([`plan/trabajo-en-paralelo.md`](plan/trabajo-en-paralelo.md), sección 4). Ningún hito cierra con provisionales.

## 9. Seguridad

Tokens solo en `flutter_secure_storage`; nunca registrar datos personales en logs (se usa `Registro.depurar`, que tapa correo, teléfono, VIN y token; lo vigila `test/arquitectura/registro_sin_datos_personales_test.dart`); HTTPS fuera de local; OWASP Mobile Top 10 como checklist en cada historia que toque datos del cliente.
