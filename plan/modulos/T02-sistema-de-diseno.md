# T02 · Sistema de diseño v2 (implementación)

| Campo | Valor |
| --- | --- |
| Hito | H1 |
| Dueño | Cristian (todos aportan componentes) |
| Revisa | Haziel |
| Estado | Listo para historias |

Especificación: [`../../docs/diseno/sistema-de-diseno-v2.md`](../../docs/diseno/sistema-de-diseno-v2.md). Aquí solo el trabajo para construirlo en `lib/nucleo/diseno/`.

## Historias

| ID | Historia | Criterios de aceptación | B | Depende de |
| --- | --- | --- | --- | --- |
| V2-T02.01 | Como equipo queremos los tokens v2 en código | `ThemeExtension` con color, tipografía, espacio, radio, elevación, movimiento · claro y oscuro · prueba de contraste AA | | V2-T01.02 |
| V2-T02.02 | Como equipo queremos la tipografía v2 empaquetada | Fuentes en `assets/fonts` (sin descarga en runtime) · escala tipográfica del documento | | V2-T02.01 |
| V2-T02.03 | Como equipo queremos movimiento consistente | Duraciones y curvas como tokens · respeta "reducir movimiento" | | V2-T02.01 |
| V2-T02.04 | Como equipo queremos los componentes base | Botón, campo, selector, casilla, interruptor, chip, avatar, insignia, aviso, diálogo, hoja inferior, menú, pestañas · golden claro/oscuro/200 % | | V2-T02.01 |
| V2-T02.05 | Como equipo queremos los componentes compuestos | Tarjeta de vehículo, fila de lista, encabezado grande, línea de tiempo, calendario, estado vacío, error, esqueleto, barra de navegación, tarjeta de métrica · golden | | V2-T02.04 |
| V2-T02.06 | Como equipo queremos una galería del sistema dentro de la app | Ruta oculta en flavor `desarrollo` con todos los componentes y estados | | V2-T02.05 |
| V2-T02.07 | Como equipo queremos íconos, logo, ícono de app y splash nuevos | Set de íconos único · logo SVG claro/oscuro · ícono adaptativo · splash | | V2-T02.01 |
| V2-T02.08 | Como equipo queremos retirar `shadcn_ui` y la paleta v1 | Sin imports · dependencia eliminada de `pubspec.yaml` | | V2-T01.07 |
