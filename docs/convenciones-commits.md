# Contribuir a Agencia360

Estas reglas aplican a todos los repositorios del proyecto: el backend, el ERP frontend, el CRM frontend y la app móvil CareCar (este repositorio). Todos siguen el mismo flujo; solo cambian los checks de cada uno.

## Regla principal

`main` debe permanecer estable. Integramos cambios únicamente mediante pull request (PR) con todos los checks requeridos en verde. Por ahora **no se exige aprobación** de otra persona; pedir revisión sigue siendo buena práctica. No hagas push directo a `main`.

## Flujo de trabajo

1. Actualiza tu copia local de `main`.
2. Crea una rama corta para una sola tarea.
3. Haz commits con mensajes claros y publica la rama.
4. Abre un PR hacia `main`, completa la descripción y espera a que termine CI.
5. Si alguien revisa, atiende sus comentarios (la aprobación no es obligatoria por ahora).
6. Cuando todos los checks estén verdes y no queden conversaciones pendientes, integra el PR con **Create a merge commit** (es el único método que permite la regla de `main`) y borra la rama.

## Nombres de ramas

Usa este formato:

```text
<tipo>/<issue>-<descripcion-corta>
```

Ejemplos:

```text
feat/tec-2-git-workflow
fix/api-validar-vin
docs/tec-2-guia-git
```

Tipos comunes: `feat` para una función nueva, `fix` para una corrección, `docs` para documentación, `test` para pruebas, `build` para `pubspec.yaml` y dependencias, y `ci` o `chore` para automatización o mantenimiento.

## Mensajes de commit

Usa este formato:

```text
<tipo>(<alcance>): <verbo + cambio>
```

Ejemplos:

```text
feat(inventario): agregar recepción de refacciones
fix(api): validar formato del VIN
docs(tec-2): documentar flujo de PR
test(carecar): cubrir la pantalla de login
ci(backend): ejecutar pruebas en cada push
```

Escribe mensajes breves y concretos. Evita mensajes como `cambios`, `update` o `fix` sin contexto. El alcance entre paréntesis puede ser un módulo o área; se puede omitir si no aporta claridad.

### Commits atómicos con intención

- Un commit = un cambio con un porqué. Si el asunto necesita "y", probablemente son dos commits.
- El asunto dice **qué**; el cuerpo explica **por qué** (la intención), no repite el diff.
- Para historias de la v2, el alcance es el módulo (`feat(m04): ...`, `docs(plan): ...`) y el cuerpo menciona el ID (`V2-M04.03`).
- Cada PR incluye la actualización de la documentación afectada y de `plan/tablero.md`, **siempre** (regla R2 de `AGENTS.md`).

### Autoría: sin IA como autor ni co-autor

El autor del commit es la persona dueña de la tarea, aunque el código lo haya escrito un agente (Claude, Codex, Antigravity, Copilot…). Están prohibidas las líneas `Co-Authored-By:` de herramientas de IA y las firmas tipo `Generated with …`. Los co-autores humanos sí se permiten.

- Activa el hook una vez por clon: `git config core.hooksPath .githooks` (quita esas líneas automáticamente).
- El check `Autoría / Sin co-autor de IA` rechaza el PR si algún commit las trae.
- Claude Code ya viene configurado sin atribución en `.claude/settings.json`.

## Pull requests

El título del PR debe resumir el cambio. Puedes usar el mismo formato que un commit:

```text
docs(TEC-2): documentar flujo de ramas y PR
```

Incluye en la descripción:

- **Qué cambió:** resumen breve y issue relacionada.
- **Cómo se probó:** pruebas ejecutadas o checks de CI que cubren el cambio.
- **Capturas:** cuando el cambio afecta una pantalla.

Antes de pedir revisión, comprueba que el PR tiene un alcance claro, que CI terminó y que no hay conflictos. Resuelve los comentarios antes de integrar.

## Revisión y checks requeridos

- Por ahora **no se exige aprobación**; la revisión de otra persona se recomienda.
- Todos los checks requeridos deben terminar correctamente.
- Los workflows corren en los PRs dirigidos a `main` y en cada push a `main`; el push a una rama sin PR no corre CI.
- Backend: build y pruebas, incluidas las pruebas con Testcontainers.
- ERP frontend: lint, build y pruebas con Vitest y React Testing Library.
- CRM frontend: lint, build y pruebas con Vitest y React Testing Library.
- CareCar mobile: formato, análisis estático, pruebas y build de Android con Flutter.

Los nombres exactos de los checks requeridos se configuran en GitHub después de que los workflows hayan corrido al menos una vez.

### CareCar mobile: CI en cada PR

El workflow `.github/workflows/ci.yml` corre en cada PR hacia `main` y en cada push a `main` (al integrar). Un job previo, `Detectar cambios de código`, salta los demás si el PR solo cambia documentación (`docs/`, `plan/`, `.claude/`, `.githooks/` o archivos `.md`); un job saltado cuenta como aprobado. Tiene un job por revisión, que corren en paralelo, para que en el PR se vea directamente cuál falló:

| Check | Qué revisa |
| --- | --- |
| `CI / Formato (dart format)` | Que el código de `lib/` y `test/` tenga el formato oficial de Dart |
| `CI / Análisis estático (flutter analyze)` | Errores y reglas de `analysis_options.yaml` (`flutter_lints`) |
| `CI / Pruebas (flutter test)` | Pruebas unitarias y de widgets |
| `CI / Build Android (APK)` | Que la app compile para Android (`flutter build apk --debug`) |

El job `Build iOS (sin firma)` (runner de macOS) no es un check requerido y hoy está en pausa: se salta mientras la variable de repositorio `MACOS_ACTIVO` no valga `true` ([`pausa-de-macos.md`](pausa-de-macos.md)).

El workflow `.github/workflows/autoria.yml` corre en cada PR hacia `main`:

| Check | Qué revisa |
| --- | --- |
| `Autoría / Sin co-autor de IA` | Que ningún commit del PR declare a una IA como co-autor ni lleve la firma `Generated with …` |

Además hay dos revisiones de seguridad:

| Check | Cuándo corre | Qué revisa |
| --- | --- | --- |
| `CodeQL / Análisis de CodeQL (GitHub Actions)` | Push y PR a `main`, y todos los lunes | CodeQL todavía no soporta Dart, así que revisa los workflows de `.github/workflows/` (inyección de comandos, permisos de más). Los hallazgos aparecen en **Security → Code scanning** |
| `Dependency Review / Revisión de dependencias nuevas/cambiadas` | Solo en PR | Bloquea el PR si agrega un paquete de `pubspec.lock` con vulnerabilidad alta o crítica, y deja un comentario con el resumen |

Antes de hacer push, corre lo mismo en local:

```bash
dart format lib test     # corrige el formato
flutter analyze          # análisis estático
flutter test             # pruebas
flutter build apk --debug  # opcional: tarda unos minutos
```

### CareCar mobile: workflows que no son checks

No corren en los PR ni bloquean el merge:

| Workflow | Cuándo corre | Qué hace |
| --- | --- | --- |
| `Release` (`release.yml`) | Al empujar una etiqueta `vX.Y.Z` | Publica un GitHub Release con el APK y después le adjunta el IPA sin firmar (solo con la variable `MACOS_ACTIVO` en `true`; hoy en pausa, ver [`pausa-de-macos.md`](pausa-de-macos.md)) |
| `IPA sin firma` (`ipa-sin-firma.yml`) | A mano (Actions → Run workflow) y llamado por `Release` | Compila iOS en release sin firmar en macOS, lo empaqueta en `Payload/` como `carecar-<versión>.ipa` y lo sube como artefacto por 30 días. Se instala con Sideloadly: [`guia-instalar-ios-sin-mac.md`](guia-instalar-ios-sin-mac.md) |

Las pruebas viven en `test/` con el sufijo `_test.dart` (por ejemplo, `test/widget_test.dart`).

Las dependencias no se actualizan con bots: los cambios de versión en `pubspec.yaml` se hacen a mano en un PR propio (`build(deps): ...`).

## Protección de `main` en GitHub

Configura una regla de protección para `main` que:

- Exija un PR antes de integrar.
- Exija checks requeridos en verde (incluido `Sin co-autor de IA`); por ahora **sin aprobaciones obligatorias**.
- Exija resolver las conversaciones de revisión.
- Bloquee push directo, force-push y borrado de la rama.
- Evite excepciones de bypass para el trabajo normal.

## Resumen

```text
actualizar main -> crear rama -> commit y push -> abrir PR -> CI verde -> merge
```

## Historial de `main` reescrito

El historial de `main` se reescribió para quitar las líneas `Co-Authored-By` de herramientas de IA de los commits anteriores (código, autores y fechas sin cambios; los co-autores humanos se conservaron). Si tienes un clon anterior:

```bash
git fetch origin
git checkout main
git reset --hard origin/main      # descarta tu main viejo
```

Si tenías una rama propia basada en el `main` viejo, pásala al nuevo con `git rebase --onto origin/main <main-viejo> <tu-rama>` o vuelve a crearla. Nunca hagas push de ramas basadas en el historial viejo: reintroducirían los commits antiguos.
