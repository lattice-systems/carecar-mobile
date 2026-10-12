# Contribuir a Agencia360

Estas reglas aplican a todos los repositorios del proyecto: el backend, el ERP frontend, el CRM frontend y la app móvil CareCar (este repositorio). Todos siguen el mismo flujo; solo cambian los checks de cada uno.

## Regla principal

`main` debe permanecer estable. Integramos cambios únicamente mediante pull request (PR), con al menos una aprobación de otra persona y todos los checks requeridos en verde. No hagas push directo a `main`.

## Flujo de trabajo

1. Actualiza tu copia local de `main`.
2. Crea una rama corta para una sola tarea.
3. Haz commits con mensajes claros y publica la rama.
4. Abre un PR hacia `main`, completa la descripción y espera a que termine CI.
5. Atiende los comentarios y consigue al menos una aprobación.
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

- Cada PR necesita al menos **una aprobación de otra persona**.
- Todos los checks requeridos deben terminar correctamente.
- Los workflows deben ejecutarse en cada push y en los PRs dirigidos a `main`.
- Backend: build y pruebas, incluidas las pruebas con Testcontainers.
- ERP frontend: lint, build y pruebas con Vitest y React Testing Library.
- CRM frontend: lint, build y pruebas con Vitest y React Testing Library.
- CareCar mobile: formato, análisis estático, pruebas y build de Android con Flutter.

Los nombres exactos de los checks requeridos se configuran en GitHub después de que los workflows hayan corrido al menos una vez.

### CareCar mobile: CI en cada push

El workflow `.github/workflows/ci.yml` corre en cada push a cualquier rama y en cada PR hacia `main`. Tiene un job por revisión, que corren en paralelo, para que en el PR se vea directamente cuál falló:

| Check | Qué revisa |
| --- | --- |
| `CI / Formato (dart format)` | Que el código de `lib/` y `test/` tenga el formato oficial de Dart |
| `CI / Análisis estático (flutter analyze)` | Errores y reglas de `analysis_options.yaml` (`flutter_lints`) |
| `CI / Pruebas (flutter test)` | Pruebas unitarias y de widgets |
| `CI / Build Android (APK)` | Que la app compile para Android (`flutter build apk --debug`) |

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

Las pruebas viven en `test/` con el sufijo `_test.dart` (por ejemplo, `test/widget_test.dart`).

Las dependencias no se actualizan con bots: los cambios de versión en `pubspec.yaml` se hacen a mano en un PR propio (`build(deps): ...`).

## Protección de `main` en GitHub

Configura una regla de protección para `main` que:

- Exija un PR antes de integrar.
- Exija al menos una aprobación y checks requeridos en verde.
- Exija resolver las conversaciones de revisión.
- Bloquee push directo, force-push y borrado de la rama.
- Evite excepciones de bypass para el trabajo normal.

## Resumen

```text
actualizar main -> crear rama -> commit y push -> abrir PR -> aprobación + CI verde -> merge
```
