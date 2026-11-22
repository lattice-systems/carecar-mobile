# T02 · Sistema de diseño v2 (implementación)

| Campo | Valor |
| --- | --- |
| Hito | H1 |
| Dueño | Cristian (todos aportan componentes) · Juan Pablo (V2-T02.13 y V2-T02.14) |
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
| V2-T02.05 | Como equipo queremos los componentes compuestos | Tarjeta de vehículo, fila de lista, encabezado grande, estado vacío, error, esqueleto, barra de navegación, tarjeta de métrica, tarjeta de acción, visor PDF y semáforo · golden · la línea de tiempo pasa a V2-T02.13 y el calendario con el selector de franja a V2-T02.14 | | V2-T02.04 |
| V2-T02.06 | Como equipo queremos una galería del sistema dentro de la app | Ruta oculta en flavor `desarrollo` con todos los componentes y estados | | V2-T02.05, V2-T02.13, V2-T02.14 |
| V2-T02.07 | Como equipo queremos íconos, logo, ícono de app y splash nuevos | Set de íconos único · logo SVG claro/oscuro · ícono adaptativo · splash | | V2-T02.01 |
| V2-T02.08 | Como equipo queremos retirar `shadcn_ui` y la paleta v1 | Sin imports · dependencia eliminada de `pubspec.yaml` | | V2-T01.07 |
| V2-T02.09 | Como equipo queremos un componente `Mapa` para ubicar direcciones y seguir traslados | Pin arrastrable, ubicación propia y marcador en movimiento · proveedor de mapas y geocodificación elegido en una decisión (ADR) · golden claro/oscuro/200 % | | V2-T02.04 |
| V2-T02.10 | Como equipo queremos un componente `Grafica` para mostrar cifras en el tiempo | Barras y líneas con los tokens · tabla alternativa para lector de pantalla · golden | | V2-T02.04 |
| V2-T02.11 | Como equipo queremos un componente `DeslizarParaConfirmar` para acciones que no deben dispararse por error | Deslizar completo confirma; soltar antes regresa · alternativa accesible con botón y diálogo · golden | | V2-T02.04 |
| V2-T02.12 | Como equipo queremos los componentes `GaleriaFotos` y `Firma` del catálogo | Galería con zoom y comparación antes/después · firma de solo lectura en imagen · golden | | V2-T02.04 |
| V2-T02.13 | Como equipo queremos el componente `LineaDeTiempo` para mostrar etapas con su hora | Etapas pasadas, actual y futuras con su hora y un texto opcional · la actual se anima y respeta reducir movimiento · variante larga y paginada para el historial · el lector de pantalla anuncia "etapa 3 de 6, en curso" · pruebas en claro, oscuro y letra al 200 % · golden cuando V2-T03.02 lo permita · lo usan V2-M02.05, V2-M04.02, V2-M11.04 y V2-M17.03 | | V2-T02.04 |
| V2-T02.14 | Como equipo queremos los componentes `Calendario` y `SelectorFranja` para elegir día y hora con cupo | `Calendario` mensual con los días sin cupo deshabilitados y explicados al lector de pantalla · cambio de mes y rango de fechas permitido · `SelectorFranja` con la hora y el cupo restante de cada franja, deshabilitada si no hay cupo · zonas táctiles de 48 · pruebas en claro, oscuro y letra al 200 % · golden cuando V2-T03.02 lo permita · lo usan V2-M02.07 y V2-M02.08 | | V2-T02.04 |

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
| `Insignia`, `ChipPista`, `Avatar`, `Aviso` (con `Tono` compartido: neutro, información, éxito, advertencia, peligro) | Hecho |
| `CampoTexto`, `CampoContrasena`, `Selector`, `Casilla`, `Interruptor` (con `CampoBase`: etiqueta visible, ayuda y error con icono) | Hecho |
| `Dialogo` y `mostrarDialogo`, `HojaInferior` y `mostrarHojaInferior`, `Menu` con `ItemMenu`, `Pestanas` (zonas táctiles de 48, velo y movimiento de los tokens, respetan reducir movimiento) | Hecho |

## Avance de V2-T02.11

`DeslizarParaConfirmar` vive en `lib/nucleo/diseno/componentes/deslizar_para_confirmar.dart`. Hay que arrastrar la perilla al 90 % del recorrido (`umbral`) para confirmar, y soltar antes la regresa con el resorte del sistema. Con un lector de pantalla activo, o con `forzarAlternativa`, se cambia por un `Boton` que pide confirmación en un `Dialogo`. Con reducir movimiento la perilla regresa sin animar. Pruebas en `test/nucleo/diseno/componentes/deslizar_para_confirmar_test.dart`. El golden queda para V2-T03.02.

## Avance de V2-T02.10

`Grafica` vive en `lib/nucleo/diseno/componentes/grafica.dart`, con `PuntoGrafica` y `TipoGrafica` (barras o líneas). Se dibuja con `CustomPaint` y los colores de los tokens, sin dependencias nuevas. El dibujo se excluye de la semántica y cada gráfica trae una tabla con los mismos datos: con un lector de pantalla activo la tabla se muestra sola, y cualquiera la alterna con "Ver como tabla". Sin datos muestra un mensaje que explica por qué. Con reducir movimiento la animación de entrada pasa a fundido corto. Pruebas en `test/nucleo/diseno/componentes/grafica_test.dart`. El golden queda para V2-T03.02.

## Avance de V2-T02.12

`GaleriaFotos`, `ComparacionAntesDespues` y `Firma` viven en `lib/nucleo/diseno/componentes/`. Reciben `ImageProvider`, así que no se acoplan a assets ni a la red. Cada foto lleva una `descripcion` obligatoria que lee el lector de pantalla.

- `GaleriaFotos` se pasa con el dedo o con flechas de 48, muestra "2 de 5" y al tocar abre `mostrarVisorFoto`, a pantalla completa con zoom de pellizco.
- `ComparacionAntesDespues` es una barra que se arrastra entre el antes y el después. Para el lector de pantalla es un control deslizante que sube y baja de 10 en 10 por ciento.
- `Firma` es de solo lectura, con fondo claro fijo para que el trazo se lea en modo oscuro. Sin imagen explica que aún no hay firma.

Pruebas en `test/nucleo/diseno/componentes/fotos_firma_test.dart`. El golden queda para V2-T03.02. `lib/widgets/galeria_auto.dart` es de v1 y se retira con V2-T02.08, no se toca aquí.

## Avance de V2-T02.05

Los componentes compuestos se entregan por tandas, un PR a la vez, en `lib/nucleo/diseno/componentes/`. Lo que falta de la lista del documento: `VisorPdf` y `Semaforo`. `LineaDeTiempo` pasó a V2-T02.13 y `Calendario` con `SelectorFranja` a V2-T02.14 (Juan Pablo), para repartir H1, pero Cristian ya los entregó en el PR 37 (tanda 3), así que esas dos historias quedan cubiertas por ese PR.

| Tanda | Componentes | Estado |
| --- | --- | --- |
| 1 | `EstadoVacio`, `EstadoError` (con `CausaError.sinConexion`), `Esqueleto` (con `.linea` y `.circulo`), `TarjetaMetrica`, `FilaLista` | Hecho |
| 2 | `BarraNavegacion` (con `DestinoNavegacion` y globo de pendientes), `EncabezadoGrande` (sliver que se encoge), `TarjetaVehiculo` (héroe con `Hero` opcional), `TarjetaAccion` | Hecho |
| 3 | `LineaDeTiempo` (con `PasoLinea` y `EstadoPaso`), `Calendario` (días sin cupo tachados), `SelectorFranja` (con `FranjaHoraria`) | Hecho |

`EstadoVacio` y `EstadoError` se desplazan si no caben, porque a letra al 200 % desbordaban. `Esqueleto` no se anuncia al lector de pantalla: quien lo use avisa "cargando" una sola vez en el contenedor. `TarjetaMetrica` reduce la cifra para que una larga no desborde.

`BarraNavegacion` siempre muestra la etiqueta, sin ocultar texto en los destinos inactivos, y anuncia "Inicio, 1 de 5". `EncabezadoGrande` calcula sus alturas con el tamaño de letra del sistema y reserva dos líneas de título cuando la letra pasa de 1.3, porque a 200 % el título se partía y desbordaba 35 px. `TarjetaVehiculo` sin foto usa la silueta en `textoTerciario`, como pide el documento.

`LineaDeTiempo` hace respirar el paso actual y lo deja quieto con reducir movimiento. `Calendario` empieza la semana en lunes, usa nombres de mes en español sin depender de `intl` y recibe `hoy` para que las pruebas no dependan del reloj. Los días fuera de rango o sin cupo se tachan y se anuncian como "20 de noviembre, sin cupo". `SelectorFranja` reutiliza `ChipPista` y dice el cupo con texto ("09:00 · 3 lugares"). Las horas y los textos de fecha llegan ya formateados desde quien los usa.
