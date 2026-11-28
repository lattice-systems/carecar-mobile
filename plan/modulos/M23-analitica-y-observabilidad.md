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
| V2-M23.01 | Como equipo queremos reportes de crashes y errores | Agencia360 recibe categorías consentidas de Flutter y cierres por fallo de Android · símbolos Dart subidos en CI · sin datos personales en el evento | ✅ | V2-T04.02 |
| V2-M23.02 | Como equipo queremos un catálogo de eventos de producto | `docs/analitica/eventos.md` con nombre, propiedades y objetivo que mide | | — |
| V2-M23.03 | Como equipo queremos medir el embudo de citas | Eventos ver disponibilidad → elegir franja → confirmar → atendida | | V2-M23.02, V2-M02.08 |
| V2-M23.04 | Como cliente quiero decidir si comparto analítica | Interruptor en Ajustes; apagado = cero eventos | | V2-M23.02 |
| V2-M23.05 | Como equipo queremos medir rendimiento | Arranque en frío, tiempo a primera pantalla útil, cuadros perdidos | | V2-M23.01 |
| V2-M23.06 | Como equipo queremos un tablero de objetivos | Panel con indicadores O1–O10 enlazado en `plan/proposito.md` | ✅ | V2-M23.03 |

## Implementación y evidencia

- El [catálogo](../../docs/analitica/eventos.md) define las propiedades y la fuente de cada evento. El interruptor de Ajustes guarda una elección por dispositivo y empieza apagado.
- La agenda v1 y v2 emite los pasos de disponibilidad, elección y confirmación. El backend deriva la asistencia de la cita o de una orden cerrada vinculada.
- La app en profile o release registra arranque de Dart hasta el primer cuadro, primera pantalla visible al terminar la cortina y cuadros perdidos estimados según la frecuencia de pantalla. La muestra inicial usa hasta 120 cuadros y termina cinco segundos después de la primera pantalla si no alcanza ese límite.
- El [ADR de diagnóstico](../../docs/decisiones/0010-diagnostico-de-carecar.md) detalla los conteos de Flutter y de cierres por fallo en Android 11 o posterior, el consentimiento y los símbolos de distribución. [La corrida de dev](../../.github/workflows/apk-simbolos-dev.yml) conserva el APK, los símbolos y la verificación de correspondencia por arquitectura. Se descargó y verificó el artefacto Android del PR #231, con correspondencia y simbolización por arquitectura. [Corrida de CI](https://github.com/lattice-systems/carecar-mobile/actions/runs/46102214831) · [APK, símbolos y verificación](https://github.com/lattice-systems/carecar-mobile/actions/runs/46102214831/artifacts/15245534947). La validación de iOS se aplazó.
- El [tablero](../../docs/analitica/tablero.md) enlaza los diez objetivos y declara qué indicadores requieren más fuentes.
