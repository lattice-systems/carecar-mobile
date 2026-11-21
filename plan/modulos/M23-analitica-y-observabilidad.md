# M23 · Analítica y observabilidad

| Campo | Valor |
| --- | --- |
| Hito | H2 (errores) → H7 (tablero de objetivos) |
| Dueño | Haziel |
| Revisa | Jael |
| Ficha técnica | No (frente transversal; se cumple dentro de las funcionalidades de la ficha) |
| Estado | Listo para historias |

## Propósito

Saber si la app falla y si cumple sus objetivos (O1–O10), sin rastrear de más. Mueve O8 y mide todos los demás.

## Historias

| ID | Historia | Criterios de aceptación | B | Depende de |
| --- | --- | --- | --- | --- |
| V2-M23.01 | Como equipo queremos reportes de crashes y errores | Herramienta elegida por ADR (p. ej. Firebase Crashlytics o Sentry) · símbolos subidos en CI · sin datos personales | | V2-T04.02 |
| V2-M23.02 | Como equipo queremos un catálogo de eventos de producto | `docs/analitica/eventos.md` con nombre, propiedades y objetivo que mide | | — |
| V2-M23.03 | Como equipo queremos medir el embudo de citas | Eventos ver disponibilidad → elegir franja → confirmar → atendida | | V2-M23.02, V2-M02.08 |
| V2-M23.04 | Como cliente quiero decidir si comparto analítica | Interruptor en Ajustes; apagado = cero eventos | | V2-M23.02 |
| V2-M23.05 | Como equipo queremos medir rendimiento | Arranque en frío, tiempo a primera pantalla útil, cuadros perdidos | | V2-M23.01 |
| V2-M23.06 | Como equipo queremos un tablero de objetivos | Panel con indicadores O1–O10 enlazado en `plan/proposito.md` | ✅ | V2-M23.03 |
