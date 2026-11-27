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

### Pantallas de catálogo, tienda y valuación

- Las pantallas de M03, M14 y M26 pasan las guías en sus pruebas de módulo, en claro, oscuro y letra al 200 %. Las de catálogo y valuación se prueban además en 320 de ancho, como ya hacía la tienda.
- **Excepción aceptada en V2-M20.08:** en teléfonos de 320 de ancho cada día del `Calendario` mide unos 42 de ancho y conserva 48 de alto, porque siete columnas de 48 suman 336. Se acepta porque supera el mínimo de WCAG 2.2 AA (24 × 24) y las otras salidas, como desplazar el mes de lado, son peores para quien lo usa. La prueba de agendar inspección exige al menos 40 de ancho y 48 de alto.

### Recorrido por las rutas del resto de módulos

`test/accesibilidad/rutas/` monta la app con el enrutador real y abre las pantallas de lealtad, pagos, garantía, taller, historial, mantenimiento, bitácora, recolección, asistencia, vehículos, citas, mi perfil y sesiones. Cada una se prueba en 320 de ancho, en claro y oscuro con las guías de Flutter y con letra al 200 % sin desbordes. El ayudante es `test/ayudas/auditoria_rutas.dart`: una pantalla nueva suma su ruta al archivo de su módulo.

| Qué encontró | Cómo quedó |
| --- | --- |
| Días del calendario de 37.7 de ancho al agendar, reprogramar y agendar una campaña | El calendario usa todo el ancho de su tarjeta y mide 41.1, dentro de la excepción de arriba |
| Código de canje y de referido con 34 de alto | Miden al menos 48 |
| La tarjeta del asistente, en el detalle del auto, tenía un toque sin nombre para el lector | El encabezado es el único botón que abre el asistente |
| El chat del asistente se desbordaba con letra al 200 % | Los avisos ocupan un tercio del alto como mucho y el texto de ayuda del campo, dos líneas |

- Las tres historias siguen abiertas: falta la prueba con TalkBack y VoiceOver, y las pantallas de acceso esperan a que su módulo se encienda en v2.

### Pantallas de taller, historial, garantía, lealtad y pagos

- Las pantallas de M04 (orden, inspección y adicionales), M02 (historial y ticket), M10 (garantía, campañas, campaña y agendar), M12 (lealtad, movimientos, recompensas, canjes y referir) y M08 (datos fiscales, perfil fiscal, pagar orden, mis pagos, pago y métodos de pago) pasan la auditoría en sus pruebas de módulo: `auditarAccesibilidad` en claro y oscuro a 320 de ancho, y sin desbordes con letra al 200 %.
- Las pruebas de módulo encontraron además que Mis pagos tronaba sin pagos (el estado vacío pedía la altura intrínseca); ya se corrigió. Agendar una campaña se prueba con la excepción del calendario (40 × 48) y los códigos de canje y de referido con la corrección del recorrido por rutas.
- Los ayudantes de prueba de esos módulos (`appTaller`, `appGarantia`, `appLealtad`, `appPagos` y `appCobro`) aceptan `ancho`, para montar cada pantalla en un teléfono chico.

## Avance de V2-M20.01 (fase 1)

Los textos salen del código con `flutter_localizations` e `intl`, y `flutter gen-l10n` genera `AppLocalizations` a partir de `lib/l10n/app_es.arb` (base) y `app_en.arb`. Los archivos generados (`lib/l10n/app_localizations*.dart`) se versionan, igual que el resto del código.

- **Idioma:** `MaterialApp` usa el del sistema si es `es` o `en`, y español en cualquier otro caso (`resolverIdioma` en `lib/l10n/idiomas.dart`). El generador pone `en` primero y por defecto Flutter caería ahí, por eso se resuelve a mano. El selector desde Ajustes es V2-M20.05.
- **Primer consumidor:** el módulo `catalogo` ya no tiene textos en el código. Su dominio dejó de armar frases ("Desde $450,000"): ahora entrega el precio como número y la pantalla lo formatea. Los precios son en pesos mexicanos y se escriben igual en cualquier idioma, así que el formato de moneda no sigue al idioma de la app (`es_MX`).
- **Guarda:** `test/l10n/sin_cadenas_en_codigo_test.dart` falla si un archivo de `lib/modulos` o `lib/nucleo` trae `Text('...')` o un argumento de texto (`titulo:`, `tooltip:`, `label:`…) escrito a mano, y falla si `app_es.arb` y `app_en.arb` no tienen las mismas claves. La galería y el módulo de ejemplo están exentos porque no los ve ninguna persona usuaria. No ve cadenas dentro de ternarios ni de `??`.
- **Fase 2 hecha:** los 13 componentes del sistema (`Aviso`, `BarraNavegacion`, `Boton`, `Calendario`, `ComparacionAntesDespues`, `DeslizarParaConfirmar`, `Firma`, `GaleriaFotos`, `Grafica`, `LineaDeTiempo`, `Pestanas`, `SelectorFranja` y `VisorPdf`) ya no llevan texto en el código. Sus etiquetas para el lector de pantalla y sus textos por defecto salen de `AppLocalizations`. Los textos por defecto que antes eran parámetros con valor (`mensajeVacio` de `Grafica`, `SelectorFranja` y `GaleriaFotos`, `mensajeConfirmacion` de `DeslizarParaConfirmar`) ahora son opcionales: si quien usa el componente no los da, se toma el texto traducido. Los meses y los días del calendario se formatean con `intl`, así que cambian con el idioma. La lista `pendientes` de la guarda quedó vacía y `test/l10n/componentes_en_ingles_test.dart` comprueba que cinco de los componentes cambian de texto en inglés. La v1 se retira con V2-T02.08 y no se migra.

## Avance de V2-M20.05

La app v2 sale en inglés con el idioma del sistema o con la elección de la persona en Ajustes.

- **Traducción:** todo texto de `lib/modulos` y `lib/nucleo` vive en `app_es.arb` y `app_en.arb` (la guarda de V2-M20.01 lo exige y comprueba que tengan las mismas claves). Con el sistema en inglés la app sale en inglés, y con un idioma que no traducimos sale en español.
- **Elección en Ajustes:** `SelectorIdioma` (`lib/nucleo/idioma/selector_idioma.dart`) ofrece Automático, Español y English. Cambia al instante, sin reiniciar. La elección se guarda en `SharedPreferences` con la clave `idioma_elegido` y `idiomaElegidoProvider` la entrega a `MaterialApp.locale`. Automático borra la elección y vuelve a mandar el idioma del sistema. Un código guardado que la app ya no traduce se ignora.
- **Provisional:** la pantalla de Ajustes de hoy es la v1 y se retira con V2-T02.08. El selector está en ella con el tema Pista puesto (la v1 aún no lo usa) y se mueve a Ajustes v2.
- **Alcance:** las pantallas v1 siguen en español porque se retiran y no se migran (decisión de V2-M20.01). La traducción de cada pantalla v2 nueva la exige la guarda desde su primera línea.
- **Pruebas:** `test/nucleo/idioma/selector_idioma_test.dart` cubre el idioma del sistema (es, en y uno no traducido), elegir, recordar, volver a Automático y un valor guardado inválido, más claro, oscuro y letra grande. `test/pantallas/perfil/pantalla_perfil_test.dart` comprueba que Ajustes muestra el selector.

