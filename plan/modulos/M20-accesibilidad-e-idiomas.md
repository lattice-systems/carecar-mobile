# M20 · Accesibilidad e idiomas

| Campo | Valor |
| --- | --- |
| Hito | H2 (base) → H7 (auditoría) |
| Dueño | Cristian |
| Revisa | Haziel |
| Ficha técnica | No (frente transversal; se cumple dentro de las funcionalidades de la ficha) |
| Estado | Listo para historias |

## Propósito

Que cualquier persona use CareCar: lector de pantalla, letra grande, contraste, movimiento reducido, español e inglés. Mueve O9.

## Historias

| ID | Historia | Criterios de aceptación | B | Depende de |
| --- | --- | --- | --- | --- |
| V2-M20.01 | Como equipo queremos textos fuera del código | `flutter_localizations` + ARB `es` (base) y `en` · ninguna cadena visible en código (lint) | | V2-T01.02 |
| V2-M20.02 | Como cliente con lector de pantalla quiero entender cada pantalla | `Semantics` en componentes del sistema · orden de foco lógico · prueba con TalkBack y VoiceOver por pantalla | | V2-T02.05 |
| V2-M20.03 | Como cliente con letra grande quiero que nada se corte | Escala 200 % sin desbordes en todas las pantallas (prueba de widget con `textScaler`) | | V2-T02.05 |
| V2-M20.04 | Como cliente sensible al movimiento quiero animaciones reducidas | Respeta "reducir movimiento" del sistema | | V2-T02.03 |
| V2-M20.05 | Como cliente angloparlante quiero la app en inglés | Traducción completa · cambia con el idioma del sistema o desde Ajustes | | V2-M20.01 |
| V2-M20.06 | Como equipo queremos contraste AA garantizado | Prueba automática de contraste de tokens claro/oscuro | | V2-T02.01 |
| V2-M20.07 | Como equipo queremos una auditoría WCAG 2.2 AA | Informe en `docs/` y hallazgos convertidos en historias | | H6 |
| V2-M20.08 | Como cliente quiero objetivos táctiles cómodos | Mínimo 48 × 48 dp en todo control | | V2-T02.05 |
