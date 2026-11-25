# T02 · Sistema de diseño v2 (implementación)

| Campo | Valor |
| --- | --- |
| Hito | H1 |
| Dueño | Cristian (todos aportan componentes; también V2-T02.13 y V2-T02.14, que entregó en los PR 37 y 42) |
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
| V2-T02.15 | Como equipo queremos los componentes `BurbujaMensaje` y `CampoMensaje` para que el asistente (M24) y la mensajería con el asesor (M07) se vean y se comporten igual | `BurbujaMensaje` propia y ajena (colores por token, radio y cola por lado), con hora y fuentes opcionales al pie ("Manual, pág. N" tocable con 48 de zona táctil) · estado enviando, enviado y fallido con reintentar · `CampoMensaje` multilínea que crece hasta 5 líneas, botón enviar deshabilitado sin texto y botón adjuntar opcional · lector de pantalla: "Tú: …" / "CareCar: …" · golden en claro, oscuro y letra al 200 % · documentado en `sistema-de-diseno-v2.md` | | V2-T02.04 |
| V2-T02.16 | Como cliente quiero una app moderna y ligera al tacto para que se sienta de alta gama | Superficie de vidrio líquido con desenfoque recortado · buscador cápsula · botones y campos de una línea en píldora · rebote táctil en lugar de salpicadura (sin rebote con reducir movimiento) · login oscuro legible: logo, barra de estado y avisos · claro, oscuro y letra al 200 % sin desbordes | | V2-T02.04 |
| V2-T02.17 | Como cliente quiero que los botones redondos de la app se vean y respondan igual para que se sienta una sola app | `BotonCircular` de 48 con variante tonal y acento, estado marcado opcional, rebote táctil y nombre para el lector · lo usan enviar y adjuntar de `CampoMensaje` y 👍/👎 del asistente · claro, oscuro y letra al 200 % | | V2-T02.16 |
| V2-T02.18 | Como cliente quiero que todos los botones y campos se comporten igual para que la app se sienta una sola | Prueba en CI que falla si `lib/modulos/` usa `IconButton`, `TextButton`, `ElevatedButton`, `FilledButton`, `OutlinedButton`, `TextField`, `Card`, `ListTile` o `Chip` de Material, o importa `shadcn_ui` o `lib/widgets/` (v1) · los usos actuales pasan a `BotonCircular`, `BotonPildora` o al componente del sistema que corresponda | | V2-T02.17 |
| V2-T02.19 | Como cliente quiero los botones de vidrio de la propuesta para que la app se sienta ligera y de alta gama | Variante `vidrio` en `BotonPildora` y `BotonCircular`: fondo translúcido del color del texto al 6 %, borde de luz al 14 %, texto `texto` e ícono `acento`, rebote · legible en claro y oscuro · se usa en acciones secundarias (Reprogramar, Agendar revisión, adjuntar, 👍/👎 sin marcar) | | V2-T02.17 |

| V2-T02.20 | Como equipo queremos componentes de estilo portada para que las pantallas de detalle tengan un protagonista visual y no se vean genéricas | `CabeceraPortada` (portada grande sobre fondo difuminado y teñido, con acción principal y secundaria) · `Estante` (carrusel horizontal con «Ver todo») · `GrupoLista`/`FilaGrupo` (lista agrupada con ícono en cuadro de color) · `BotonPildora` (lleno y tonal) · `BarraPortada` (transparente arriba, opaca al desplazar) · `EncabezadoGrande(translucido: true)` · ningún contenido atraviesa el título al desplazar · golden en claro, oscuro y 200 % · en la galería | | V2-T02.04 |

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

Los componentes compuestos se entregan por tandas, un PR a la vez, en `lib/nucleo/diseno/componentes/`. Con la tanda 4 ya están todos los compuestos de la lista del documento. `LineaDeTiempo` pasó a V2-T02.13 y `Calendario` con `SelectorFranja` a V2-T02.14 (Juan Pablo), para repartir H1, pero Cristian ya los entregó en el PR 37 (tanda 3), así que esas dos historias quedan cubiertas por ese PR.

| Tanda | Componentes | Estado |
| --- | --- | --- |
| 1 | `EstadoVacio`, `EstadoError` (con `CausaError.sinConexion`), `Esqueleto` (con `.linea` y `.circulo`), `TarjetaMetrica`, `FilaLista` | Hecho |
| 2 | `BarraNavegacion` (con `DestinoNavegacion` y globo de pendientes), `EncabezadoGrande` (sliver que se encoge), `TarjetaVehiculo` (héroe con `Hero` opcional), `TarjetaAccion` | Hecho |
| 3 | `LineaDeTiempo` (con `PasoLinea` y `EstadoPaso`), `Calendario` (días sin cupo tachados), `SelectorFranja` (con `FranjaHoraria`) | Hecho |
| 4 | `Semaforo` (con `EstadoSemaforo`: bien, atención, urgente), `VisorPdf` (con `FabricaVisorPdf` para probarlo sin el motor nativo) | Hecho |

`EstadoVacio` y `EstadoError` se desplazan si no caben, porque a letra al 200 % desbordaban. `Esqueleto` no se anuncia al lector de pantalla: quien lo use avisa "cargando" una sola vez en el contenedor. `TarjetaMetrica` reduce la cifra para que una larga no desborde.

`BarraNavegacion` siempre muestra la etiqueta, sin ocultar texto en los destinos inactivos, y anuncia "Inicio, 1 de 5". `EncabezadoGrande` calcula sus alturas con el tamaño de letra del sistema y reserva dos líneas de título cuando la letra pasa de 1.3, porque a 200 % el título se partía y desbordaba 35 px. `TarjetaVehiculo` sin foto usa la silueta en `textoTerciario`, como pide el documento.

`LineaDeTiempo` hace respirar el paso actual y lo deja quieto con reducir movimiento. `Calendario` empieza la semana en lunes, usa nombres de mes en español sin depender de `intl` y recibe `hoy` para que las pruebas no dependan del reloj. Los días fuera de rango o sin cupo se tachan y se anuncian como "20 de noviembre, sin cupo". `SelectorFranja` reutiliza `ChipPista` y dice el cupo con texto ("09:00 · 3 lugares"). Las horas y los textos de fecha llegan ya formateados desde quien los usa.

`Semaforo` lleva icono y texto propios en cada estado, y sus tres tonos pasan AA en claro y oscuro. `VisorPdf` usa `pdfx`, que ya era dependencia, así que no suma paquetes. Recibe una función `cargar` que entrega los bytes, sin saber si vienen de la red o de un archivo. Muestra esqueleto mientras carga, `EstadoError` con reintento y un contador "Pagina 2 de 5". No busca texto dentro del PDF: ese riesgo sigue abierto para V2-M02.03. Los golden de toda T02.05 quedan para V2-T03.02.

## Avance de V2-T02.13 y V2-T02.14

El PR 37 entregó `LineaDeTiempo`, `Calendario` y `SelectorFranja` antes de que se repartieran a Juan Pablo. V2-T02.14 quedó completa con ese PR. A V2-T02.13 le faltaban dos criterios, que se cierran aquí:

- `LineaDeTiempoPaginada` es la variante larga para el historial. Dibuja solo los pasos visibles, agrega "Ver más" al final y, con `cargarAlLlegar`, pide la siguiente página una sola vez al llegar. Con `cargandoMas` muestra un esqueleto.
- El lector de pantalla ahora anuncia "Etapa 3 de 5, en curso, En reparación", como pide el criterio, en lugar de "paso 3 de 5".

Los golden de las dos historias quedan para V2-T03.02, igual que el resto de T02.

## Avance de V2-T02.06

La galería del sistema vive en `lib/modulos/galeria/` y se abre en la ruta `/galeria`. Muestra todos los componentes de T02.04, T02.05 y T02.10 a T02.14, cada uno con sus estados (deshabilitado, cargando, error, vacío, con tono), en 17 secciones. Arriba tiene tres interruptores para verlos en oscuro y con letra al 150 % y al 200 %.

- **Solo desarrollo:** la ruta se registra con `kDebugMode` en `registro_de_rutas.dart`. Cuando exista el flavor `desarrollo` (V2-T01.04) hay que condicionarla a ese flavor, que es lo que pide el criterio. Como toda ruta de módulo, exige sesión.
- **Pruebas:** `test/modulos/galeria/galeria_test.dart` monta cada sección en claro, oscuro y letra al 200 %, así que sirve de prueba de humo de todo el sistema junto.
- **Hallazgo:** al montar el visor de PDF en un contenedor de 320 de alto, su esqueleto de carga desbordaba 80 px. Ahora el bloque grande es flexible.
- **Pendiente:** los golden de todas las secciones, que dependen de V2-T03.02.

## Nota sobre V2-T02.09

`Mapa` está bloqueada por una decisión: el criterio exige elegir proveedor de mapas y geocodificación en una ADR. Se propone en [`docs/decisiones/0006-mapas-y-geocodificacion.md`](../../docs/decisiones/0006-mapas-y-geocodificacion.md) (`flutter_map` con teselas configurables, `geolocator` y `geocoding` nativo, todo detrás de interfaces en `lib/nucleo/mapas/`). Mientras esté en `Propuesta` no se escribe código del componente. Lo que falta para aceptarla es que el PO confirme el proveedor de teselas de producción y su costo.

## Avance del estilo portada

Se agregaron al sistema `BotonPildora`, `CabeceraPortada` (con `AccionPortada`), `Estante`, `GrupoLista` (con `FilaGrupo`) y la opción `translucido` de `EncabezadoGrande`, documentados en la sección 8 del sistema de diseño y presentes en la galería (`secciones_portada.dart`). Traen pruebas de widget en claro, oscuro y letra al 200 
## Avance del estilo portada

Se agregaron al sistema `BotonPildora`, `CabeceraPortada` (con `AccionPortada`), `Estante`, `GrupoLista` (con `FilaGrupo`) y la opción `translucido` de `EncabezadoGrande`, documentados en la sección 8 del sistema de diseño y presentes en la galería (`secciones_portada.dart`). Traen pruebas de widget en claro, oscuro y letra al 200 % y golden en `test/nucleo/diseno/componentes/goldens/`, con la fuente de prueba de Flutter hasta que V2-T03.02 deje las reales.

## Avance de V2-T02.15

- `lib/nucleo/diseno/componentes/burbuja_mensaje.dart`: `BurbujaMensaje`, `AutorMensaje`, `EstadoEnvio` y `FuenteMensaje`.
- `lib/nucleo/diseno/componentes/campo_mensaje.dart`: `CampoMensaje`.
- Pruebas en `test/nucleo/diseno/componentes/mensajes_test.dart`, 15 en total:
  - lado y color por autor;
  - 80 % del ancho;
  - lector de pantalla;
  - fuentes de 48 tocables;
  - enviando y fallido con reintentar;
  - envío recortado y vacío;
  - crecimiento hasta 5 líneas;
  - adjuntar opcional;
  - botones de 48 con nombre;
  - deshabilitado;
  - sin desbordes en los tres escenarios.
- Golden en claro, oscuro y letra al 200 %, a partir de la sección «Mensajes» de la galería.
- Los textos («Enviando…», «Reintentar», «Escribe un mensaje», etc.) van en español por omisión y se pueden cambiar por parámetro, igual que `EstadoError`. Cada módulo los pasa traducidos (M20).

## Avance de V2-T02.16

Estilo de vidrio líquido y píldora, propuesto con Antigravity y terminado en este PR:
- `SuperficieLiquida`, `CampoBusquedaLiquido` y `ReboteTactil`, con sus pruebas;
- forma píldora en botones y campos;
- login oscuro.

Lo que se veía mal en el Xiaomi y se corrigió:
- `superficieHundida` en oscuro era más negra que el fondo: desaparecían la burbuja del asistente, el campo de mensaje, el interruptor apagado y los botones deshabilitados;
- el indicador de «Cargando» era invisible sobre el botón azul;
- la firma vacía era una caja blanca en oscuro;
- «Agendar cita» se partía en dos líneas;
- el logo y la barra de estado no se leían en el login;
- los avisos del login salían en cajas claras de la v1.

Después (PR del campo de chat): `CampoMensaje` pasa a píldora con `Radios.campoChat` (24) para igualar los campos del login; con varias líneas queda como cápsula.

Pendiente fuera de este PR: la gráfica de línea no ajusta su escala a los datos (la línea queda pegada arriba).

## Encabezados ligeros (rediseño V2-T02.21)

Daniel pidió que las pantallas dejaran de verse como plantilla: «que no se vea mucha IA, con buen diseño, consistente y reutilizable». Se retiraron `CabeceraPortada`, `BarraPortada`, `AccionPortada`, `PortadaVehiculo` y `PortadaMantenimiento` (la pieza grande con fondo difuminado) y los cuatro marcos copiados por módulo (`MarcoBitacora`, `MarcoPantallaCita`, `MarcoPantallaMantenimiento`, `MarcoPantallaRecoleccion`, con sus barras inferiores, secciones y botones «Cerrar»). En su lugar, en `lib/nucleo/diseno/componentes/`:

- `EncabezadoGrande` rehecho (barra fija + título grande que se recoge), `BotonRegresar` y `BotonCerrar` (círculos de vidrio iguales), `BarraPantalla` (barra quieta para visor y pestañas).
- `MarcoPantalla` (+ `BarraInferior`, `SeccionPantalla`): el único marco de detalle y formulario.
- `TarjetaAuto` (+ `SiluetaAuto`, `tinteDeColorAuto`): el auto del cliente, en el inicio, el garaje y el detalle; `TarjetaVehiculo` usa la misma silueta cuando no hay foto.
- `TarjetaResumen` (con barra de avance), `FilaAcciones` y `ResultadoPantalla`.

Documentado en §8 del sistema de diseño. La galería y los golden (`pantalla_golden_test.dart`) muestran las tarjetas nuevas. Pendiente de la misma historia: migrar a `MarcoPantalla` las pantallas que aún usan un `AppBar` de Material (catálogo, privacidad, estreno, asistente, cambio de contraseña).
