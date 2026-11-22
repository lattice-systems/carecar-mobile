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
| V2-T02.09 | Como equipo queremos un componente `Mapa` para ubicar direcciones y seguir traslados | Pin arrastrable, ubicación propia y marcador en movimiento · proveedor de mapas y geocodificación elegido en una decisión (ADR) · golden claro/oscuro/200 % | | V2-T02.04 |
| V2-T02.10 | Como equipo queremos un componente `Grafica` para mostrar cifras en el tiempo | Barras y líneas con los tokens · tabla alternativa para lector de pantalla · golden | | V2-T02.04 |
| V2-T02.11 | Como equipo queremos un componente `DeslizarParaConfirmar` para acciones que no deben dispararse por error | Deslizar completo confirma; soltar antes regresa · alternativa accesible con botón y diálogo · golden | | V2-T02.04 |
| V2-T02.12 | Como equipo queremos los componentes `GaleriaFotos` y `Firma` del catálogo | Galería con zoom y comparación antes/después · firma de solo lectura en imagen · golden | | V2-T02.04 |

## Avance de V2-T02.01

Los tokens viven en `lib/nucleo/diseno/tokens/` y el tema en `lib/nucleo/diseno/tema_pista.dart`. Pruebas en `test/nucleo/diseno/`.

| Criterio | Dónde se cumple |
| --- | --- |
| `ThemeExtension` con color, tipografía, espacio, radio, elevación y movimiento | `TokensPista` junto con `Espaciado`, `Radios` y `Movimiento`, que son constantes de acceso directo |
| Claro y oscuro | `TokensPista.claro`, `TokensPista.oscuro`, `TemaPista.claro()` y `TemaPista.oscuro()` |
| Prueba de contraste AA | `colores_test.dart` revisa 17 pares por modo con `Contraste.razon` |

Notas para quien siga con T02.02 a T02.04:

- Los componentes leen los tokens con `TokensPista.de(context)`. Espaciado, radios y movimiento se usan directo desde sus clases.
- `Tipografia` ya pide Geist y GeistMono con Inter y JetBrainsMono de respaldo. Al empaquetar Geist en T02.02 no hay que tocar los componentes.
- `Movimiento` trae `paraAccesibilidad(reducir:)`, que devuelve el fundido de 120 ms. T02.03 solo debe conectarlo a la preferencia del sistema.
- `micro` va en mayúsculas, y quien lo use debe aplicar `toUpperCase()` al texto.
- `TemaPista` no se aplica todavía en `main.dart`, porque la decisión 0004 sigue en Propuesta y las reglas piden no migrar código por una decisión en ese estado.

## Avance de V2-T02.03

Los componentes piden su movimiento con `context.movimiento(Movimiento.base)` desde `lib/nucleo/diseno/movimiento_contexto.dart`. Si el sistema tiene activada la opción de reducir movimiento, el token se convierte en un fundido lineal de 120 ms. Las duraciones y curvas ya eran tokens desde T02.01. La prueba `movimiento_contexto_test.dart` cubre el token y una animación real.

## Avance de V2-T02.04

Los componentes base se entregan por tandas, un PR a la vez. Viven en `lib/nucleo/diseno/componentes/`. Las pruebas cubren claro, oscuro y letra al 200 % con `conTemaPista` (`test/ayudas/tema_pista.dart`). Los golden se agregan cuando V2-T03.02 deje listas las fuentes reales y la herramienta.

| Componente | Estado |
| --- | --- |
| `Boton` (principal, secundario, terciario, peligro, tres tamaños, carga) | Hecho |
| Campo, selector, casilla, interruptor, chip, avatar, insignia, aviso, diálogo, hoja inferior, menú, pestañas | Pendiente |
