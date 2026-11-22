# Plan maestro de CareCar v2

Todo lo que el equipo (y sus agentes) necesita para saber **qué** construir, **por qué**, **en qué orden** y **quién**. Sin fechas: objetivos, hitos y criterios de salida.

| Documento | Para qué |
| --- | --- |
| [`proposito.md`](proposito.md) | Propósito, visión, principios y objetivos O1–O10 con su indicador |
| [`hitos.md`](hitos.md) | Hitos H0–H7 con criterios de salida (hito activo marcado con ▶) |
| [`modulos/README.md`](modulos/README.md) | Catálogo de 27 módulos y 5 frentes técnicos, con dueño y revisor |
| [`modulos/`](modulos/) | Un archivo por módulo: pantallas, datos, API e historias con criterios |
| [`tablero.md`](tablero.md) | Estado de las 206 historias (fuente única del avance) |
| [`equipo-y-reparto.md`](equipo-y-reparto.md) | Quién hace qué en cada hito y cómo se revisa |
| [`cumplimiento-ficha.md`](cumplimiento-ficha.md) | Matriz funcionalidad por funcionalidad contra la ficha técnica v2.0 |
| [`arquitectura-v2.md`](arquitectura-v2.md) | Forma objetivo del código de la app |

Relacionados: ficha técnica en [`../docs/ficha-tecnica/`](../docs/ficha-tecnica/README.md), decisiones en [`../docs/decisiones/`](../docs/decisiones/README.md), sistema de diseño en [`../docs/diseno/`](../docs/diseno/sistema-de-diseno-v2.md), reglas en [`../AGENTS.md`](../AGENTS.md). Plan del backend: `agencia-360-backend/plan/`.

## Definición de Listo (DoR)

Una historia pasa de `Borrador` a `Lista` cuando:

- Tiene formato *Como / quiero / para* y criterios de aceptación comprobables.
- Sus dependencias están `Hecha` o se pueden simular (API simulada, datos de ejemplo).
- Si es **B**, existe su historia espejo en el plan del backend con endpoint y tabla definidos.
- Si toca UI, los componentes existen en el sistema de diseño o hay historia T02 para crearlos.
- Si su módulo está en la ficha, se sabe qué fila de `cumplimiento-ficha.md` mueve.
- Cabe en un PR revisable.

## Cómo se mantiene este plan

- Cada PR que avanza una historia actualiza `tablero.md` y el archivo de su módulo (R2 de `AGENTS.md`).
- Módulos e historias nuevas los propone el planificador (o cualquiera) con PR `docs(plan): ...`.
- Un hito se cierra con un PR que marca sus criterios de salida con evidencia y mueve el ▶ al siguiente.
- Nunca se agregan fechas.
