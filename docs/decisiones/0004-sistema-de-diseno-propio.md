# 0004 · Sistema de diseño propio sobre Material 3

**Estado:** Aceptada

## Contexto

El equipo rechazó el diseño v1. `shadcn_ui` es una adaptación de un sistema pensado para web: componentes con aspecto de escritorio, convive mal con Material y obliga a mezclar dos temas.

## Opciones

1. Seguir con `shadcn_ui` y retocar la paleta.
2. Material 3 puro con un `ColorScheme` de marca.
3. Sistema propio (tokens + componentes) construido sobre los widgets base de Material 3.

## Decisión

Opción 3, especificado en `docs/diseno/sistema-de-diseno-v2.md`. Material aporta accesibilidad, gestos y comportamiento nativo; la identidad visual (color, tipo, forma, movimiento, composición) es propia.

## Consecuencias

- Más trabajo inicial (T02) a cambio de una app con identidad y consistencia.
- Se retira `shadcn_ui` al cerrar H2 (T02.08).
- Todo componente nuevo pasa primero por el sistema (doc + componente + golden).
