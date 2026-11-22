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

## Avance de V2-M20.04

Todo movimiento del sistema v2 pasa por `context.movimiento(token)` (V2-T02.03), que con "reducir movimiento" del sistema entrega un fundido de 120 ms lineal. `test/nucleo/diseno/movimiento_reducido_test.dart` lo vigila de dos formas: un recorrido del código que falla si un componente de `lib/nucleo/diseno/componentes/` trae `Duration(`, `Curves.` o `Cubic(` propios, y una prueba de comportamiento con `Pestanas` en las dos preferencias. Lo que queda fuera es el código v1 (`lib/widgets/movimiento.dart` y las pantallas actuales), que se retira con V2-T02.08 y se migra con V2-T01.05, no antes.

## Avance de V2-M20.06

El contraste se prueba en `test/nucleo/diseno/tokens/colores_test.dart`, en claro y oscuro. Texto y estados piden 4.5 a 1 (WCAG 1.4.3) y los contornos de control piden 3 a 1 (WCAG 1.4.11). Al ampliar la cobertura salieron dos fallas reales que ya estaban en los componentes, y se corrigieron aquí:

- La sugerencia de los campos usaba `textoTerciario`, que da 3.2 a 1 en claro. Ahora usa `textoSecundario`. `textoTerciario` queda solo para deshabilitado, que WCAG exime.
- Los contornos de campo, casilla, interruptor y chip usaban `borde`, que da 1.25 a 1. Se agregó el token `contornoControl` (`#7C8391` en claro, `#6B7280` en oscuro) y esos cuatro componentes lo usan. `borde` sigue para divisores, que no delimitan nada.

Pendiente fuera de esta historia: la auditoría con lector y dispositivo real es V2-M20.07, y el contraste de texto sobre fotos o imágenes no se puede garantizar con tokens.

## Avance de V2-M20.02, V2-M20.03 y V2-M20.08

Estas tres historias recorren todas las pantallas, y las pantallas v2 apenas están naciendo, así que no se pueden cerrar todavía. Lo que sí queda hecho es el mecanismo que las vigila, para que cada pantalla nueva lo pase desde su primer PR:

- **Auditoría de la galería:** `test/accesibilidad/guias_galeria_test.dart` monta cada una de las 17 secciones del sistema y les corre las guías de Flutter: zona táctil de 48 (Android) y 44 (iOS), etiqueta en todo control tocable y contraste de texto en claro y oscuro, más que nada se desborde con letra al 200 %. Son 102 pruebas y hoy todas pasan, así que ningún componente del sistema incumple.
- **Ayudante para pantallas:** `auditarAccesibilidad(tester)` en `test/ayudas/auditoria_accesibilidad.dart` corre esas mismas guías sobre una pantalla ya montada. `PantallaCatalogo` ya la pasa en `test/accesibilidad/guias_pantallas_test.dart`. Cada historia de pantalla suma ahí la suya.
- **Cómo se comprobó que las guías muerden:** un botón de 20 × 20 falla la guía de zona táctil, uno de 48 pasa, uno de 30 falla en iOS y un control sin etiqueta falla la de etiquetas. Ojo: las guías de Flutter ignoran los nodos pegados al borde de la pantalla, porque podrían estar medio fuera. Un botón en la esquina no se mide.
- **Sigue manual:** la prueba con TalkBack y VoiceOver por pantalla que pide V2-M20.02. No se puede automatizar.
- **Pendiente:** las pantallas v1 no se auditan, se retiran con V2-T02.08.
