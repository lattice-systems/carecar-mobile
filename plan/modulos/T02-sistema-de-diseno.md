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

La decisión que pide el criterio, [`docs/decisiones/0006-mapas-y-geocodificacion.md`](../../docs/decisiones/0006-mapas-y-geocodificacion.md) (`flutter_map` con teselas configurables, `geolocator` y `geocoding` nativo, con interfaces en `lib/nucleo/mapas/`), está **Aceptada**, así que el componente ya no está bloqueado. Sigue abierto, antes de publicar en producción, qué proveedor de teselas contrata el PO y cuánto cuesta. No cambia el código: se configura con `TILES_URL` y `TILES_ATTRIBUTION`.

## Avance de V2-T02.09

`Mapa` y `MarcadorEnMovimiento` viven en `lib/nucleo/diseno/componentes/mapa.dart`. La anatomía, los estados y la accesibilidad están en la sección 8 del sistema de diseño.

| Criterio | Dónde se cumple |
| --- | --- |
| Pin arrastrable | `alMoverPin`: arrastre, toque y, sin arrastrar, botones de 48 para ponerlo y moverlo |
| Ubicación propia | `miUbicacion` o «Ver mi ubicación» con `ProveedorUbicacion`. Permiso negado, permiso bloqueado, GPS apagado y tiempo agotado se explican |
| Marcador en movimiento | `enMovimiento`: se desliza con `base` y salta con reducir movimiento |
| Proveedor y geocodificación en una ADR | Decisión 0006, aceptada |
| Golden claro, oscuro y 200 % | `mapa_golden_test.dart` |

También quedan el aviso sin conexión con reintento, las teselas inyectables para probar sin red (`TeselasLisas`, `TeselasSinConexion`, `fuenteTeselasProvider`), `ClienteTeselas` para que los errores no lleven la dirección de la tesela, la sección «Mapa» de la galería y la prueba de arquitectura de los paquetes de mapas.

**Pendiente fuera de esta historia:**

- `MapaProvisional` de `recoleccion` sigue en uso. Por la regla de provisionales ([`trabajo-en-paralelo.md`](../trabajo-en-paralelo.md), sección 4) lo reemplaza el dueño de M17 en su siguiente cambio a esas pantallas. Mientras exista no tiene el arrastre, la alternativa sin arrastre ni el aviso sin conexión, y sus errores de descarga sí pueden llevar a la consola la dirección de la tesela.
- `lib/nucleo/camara/selector_foto.dart` importa `geolocator` solo para abrir los ajustes de la app. Queda anotado como excepción en la prueba de arquitectura.
- El crédito del mapa es texto, no un enlace a la página de licencia de OpenStreetMap.
- Falta probar el componente en un teléfono con teselas reales.

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

Documentado en §8 del sistema de diseño. La galería y los golden (`pantalla_golden_test.dart`) muestran las tarjetas nuevas. Después se migraron las pantallas que usaban un `AppBar` de Material: catálogo (lista, detalle, comparador, calculadora, mis estimaciones), privacidad (puerta del aviso, aviso, hub, mis datos, eliminar cuenta), estreno, asistente y el PDF del comprobante. Las listas, detalles y formularios usan `MarcoPantalla`; el chat, el visor, la calculadora y los formularios de estreno usan `BarraPantalla`. Quedan fuera las pantallas de la v1 (se retiran con V2-T01.07) y los ejemplos.

## Avance de V2-T02.22 (inicio con datos del auto)

Daniel notó que el inicio repetía en el cuerpo la navegación que ya tiene la barra («¿no sería ideal que se vieran datos más relevantes?») y pidió revisar que todas las pantallas se vean como una sola. No es historia de usuario: es un rediseño, como V2-T02.21. Para revisar se corrió la app en web contra `mock_api` y se recorrieron las pantallas v2 en claro; el resultado y las reglas que quedan están en [`antipatrones-de-ia.md`](../../docs/diseno/antipatrones-de-ia.md).

**Inicio**

- Se quitaron los tres accesos redondos (repetían la barra y el botón flotante casi tapaba el último). `InicioNuevo` recibe los destinos como `alAbrirVehiculos`, `alAbrirCitas` y `alAbrirCatalogo`, que usa la barra y las tarjetas.
- Muestra, en este orden, el taller en curso, la próxima cita y el próximo servicio **del auto que se ve en el carrusel** (`servicioDelAuto`); la invitación a agendar va al final. `AutoInicio` lleva `id` y `marcaAparte` (la marca no se repite si el modelo ya la trae, como en el garaje).
- Cada tarjeta lleva su separación inferior: se acabó el hueco de 44 px entre el taller y la cita.

**Consistencia**

- `TarjetaOrdenEnCurso` pasó a `TarjetaResumen`; antes dibujaba otra tarjeta (borde y medallón) en la misma pantalla.
- `TarjetaResumen` suma `pista` (lector de pantalla) y `estadoConIcono`.
- `formatearMiles` (`lib/nucleo/idioma/formato_numeros.dart`): el inicio decía «18.450 km» y el resto «18,450 km». Los demás módulos tienen su copia de la regla `es_MX`; migrarlos a `formatearMiles` queda como limpieza.
- Seis cadenas de los accesos salieron de los `.arb`.

**Hallazgos de la revisión que V2-T02.22 no toca:** se atienden en V2-T02.23 y V2-T02.24 (abajo) salvo el último.

- Ajustes seguía en v1 (cabecera héroe, etiquetas en mayúsculas, acentos verdeazulados): se migró en V2-T02.24.
- Con la configuración por omisión (`InterruptorModulos.porDefecto`, todo en v1) Vehículos, Citas y Catálogo abren las pantallas v1 aunque sus historias v2 estén hechas; la apariencia solo era una con `--dart-define=MODULOS_V2=todos` (resuelto en [V2-T01.09](T01-arquitectura-v2.md): la v2 es el valor por defecto).

## Avance de V2-T02.23 (consistencia entre pantallas)

Segunda pasada de la revisión de V2-T02.22, pantalla por pantalla contra la app corriendo.

- **Salida visible.** `historial`, `ticket`, `taller/orden`, `inspección`, `adicionales` y la ficha técnica armaban `EncabezadoGrande` a mano y quedaban sin botón de regreso; «Pedir ayuda» llevaba una copia del marco con un cierre azul, y guías y llamar rápido otra. Las nueve pasan a `MarcoPantalla` (con `conRegreso` los detalles). Una prueba de arquitectura (`solo_componentes_del_sistema_test.dart`) falla si un módulo vuelve a armar el encabezado: así no se puede olvidar el botón.
- **«Tu auto»** (detalle del vehículo) pasa de cuadrícula 2×2 de tarjetas iguales a un `GrupoLista` con chevron, como el resto de la app; se van unas 150 líneas de medición manual de texto. El kilometraje usa `formatearMiles`.
- **`CuadroFecha`** sube al sistema de diseño y reemplaza a las dos copias (la del inicio y la de la lista de citas, que se veían distintas).
- La guía de revisión y los casos están en [`antipatrones-de-ia.md`](../../docs/diseno/antipatrones-de-ia.md).

**Pendiente** (detectado, no tocado aquí): `Mis estimaciones`, `Mis solicitudes` (estreno) y `Comparar modelos` usaban `BarraPantalla` y `GrupoLista` y `TarjetaResumen` dos flechas distintas: se atendió en V2-T02.25. La regla de números `es_MX` sigue copiada en otros módulos y se migra a `formatearMiles` poco a poco.

## Avance de V2-T02.24 (Ajustes en el lenguaje v2)

Ajustes se abre desde el avatar del inicio en toda compilación y era lo más lejano al resto: cabecera héroe de degradado, rótulos en MAYÚSCULAS («MI PERFIL», «CUENTA»), interruptor y acentos verdeazulados de la paleta retirada, «Cerrar sesión» arriba y abajo, animaciones en cascada y un diálogo y una hoja de shadcn.

- **La pantalla** (`lib/pantallas/pantalla_ajustes.dart` y `perfil/pantalla_perfil.dart`) pasa a `MarcoPantalla`, `TarjetaResumen` con `Avatar`, un `GrupoLista` por tema y el selector de idioma. Se conservan el nombre de cada fila, sus llaves (`PantallaPerfil.boton…`), los textos y los flujos; las filas que otras personas agregan (como «Mis puntos») siguen siendo un `_Opcion(...)` más.
- **Los overlays**: confirmar el cierre es un `Dialogo` de peligro y el contacto una `HojaInferior`, con el tema de la pantalla (el tema raíz v1 solo trae los tokens claros).
- **El sistema** suma `FilaGrupo.llave`, `FilaGrupo.conChevron`, `ControlInterruptor` y las llaves de las acciones de `Dialogo`; y arregla `GrupoLista`: el adorno final ya no le quita la mitad del espacio al texto (afecta a todas las filas con adorno; se regeneraron los tres golden del grupo).
- **Higiene**: doce PNG de diferencias de golden fallido se habían colado en un commit; se quitan y `failures/` queda ignorado.

**Sigue en v1 desde Ajustes:** «Cambiar contraseña» abre la pantalla v1 (`PantallaCambiarContrasena`); su versión v2 es V2-M01.10 (Jael). Los avisos breves (`mostrarToast`) también son de la v1. V2-M01.06 puede mover Ajustes a un módulo `perfil` sin cambiar su aspecto.

## Avance de V2-T02.25 (las pantallas v2 que faltaban)

Se repasaron una por una las pantallas de los módulos antes de encender la v2 por defecto ([V2-T01.09](T01-arquitectura-v2.md)): con ese cambio llegan a todas las personas, así que ya no pueden verse distintas.

- **Un solo marco.** `Mis estimaciones` y `Comparar modelos` (catálogo) y `Mis solicitudes`, `Quiero probarlo` y `Cotización` (estreno) pasan de `Scaffold` + `BarraPantalla` a `MarcoPantalla`. Las listas llevan «Regresar»; los formularios, «Cerrar» (se abren encima del detalle del modelo), con el modelo como subtítulo del encabezado. Cargando, vacío y error conservan el marco. `BarraPantalla` queda para el chat, el visor de PDF, la calculadora y el checklist con pestañas.
- **Un solo estilo de lista.** Las estimaciones y las versiones de un modelo pasan de `FilaLista` a `GrupoLista`; ninguna pantalla usa ya `FilaLista` (si nadie lo necesita, se retira).
- **La próxima cita** de `Mis citas` era otra tarjeta héroe (degradado, etiqueta en mayúsculas, día de 84 px). Ahora es la `TarjetaResumen` del inicio con el `CuadroFecha` en el tono del estado; Comprobante, Reprogramar y Cancelar quedan debajo. El inicio, que solo muestra citas confirmadas, pinta el mismo cuadro en el mismo tono: antes la misma cita era azul en el inicio y verde en «Mis citas».
- **Una sola flecha.** Filas y tarjetas tocables llevan la misma (`LucideIcons300.chevronRight`, el set único de V2-T02.07) en el mismo color, `textoTerciario`: `FilaLista` y `Semaforo` la llevaban en `textoSecundario`. Las pruebas que contaban flechas cuentan las de la lista, sin confundirse con la de una tarjeta.
- **`EstadoError` traducido.** Sus textos por omisión estaban escritos a mano («Sin conexion», sin tilde y siempre en español) y los usan 44 pantallas; ahora salen de `AppLocalizations` (cinco cadenas nuevas).

## Avance de V2-T02.26 (segunda pasada a las pantallas v2)

Con la v2 por defecto ([V2-T01.09](T01-arquitectura-v2.md)) se recorrieron en la app corriendo las pantallas que V2-T02.25 no tocó (asistencia, vehículos, garantía, lealtad, tienda, valuación, privacidad, taller, citas, catálogo). La mayoría ya era coherente; esto es lo que no:

- **Comprobante de la cita:** la lista «Detalles de la cita» (y la de recolección) iba sin el margen lateral de los botones y la tarjeta llegaba de borde a borde.
- **Ficha técnica:** cada sección mostraba dos flechas (desplegar y «abre otra pantalla»); queda la de desplegar (`conChevron: false`).
- **Emergencias:** las guías salían dos veces (estante de portadas de color y lista); queda la lista, con el encabezado «Guías». La tarjeta «¿Necesitas ayuda ahora?» usaba `bordeHoja` (solo redondea arriba) y se veía con la base recta.
- **Pedir ayuda:** el primer título era la etiqueta pequeña de la lista y los otros dos, títulos de sección; los tres son ahora el mismo.

**Sigue como estaba:** la calculadora de toma a cuenta conserva `BarraPantalla` (título pequeño) porque desplaza a mano hasta el resultado con un controlador propio; pasarla a `MarcoPantalla` pide darle un controlador al marco.

## Avance de V2-T02.02

| Criterio | Dónde se cumple |
| --- | --- |
| Fuentes en `assets/fonts` sin descarga en tiempo de ejecución | Geist 400, 500 y 600 y Geist Mono 500 en TTF estáticos, con `Geist-OFL.txt`, declaradas en `pubspec.yaml`. No hay `google_fonts` ni direcciones de fuentes en `lib/` |
| Escala tipográfica del documento | Se comparó `Tipografia` con la tabla de la sección 3 del sistema de diseño: los diez estilos coinciden en tamaño, interlineado, peso y tracking, así que no cambió ningún valor. Lo cubre `tipografia_test.dart` |

- `fuentes_empaquetadas_test.dart` comprueba que cada familia declara solo los pesos de la escala, que cada archivo existe y trae ese peso, que la licencia está y que nada descarga fuentes.
- La versión, la dirección y las huellas están en [la sección 3 del sistema de diseño](../../docs/diseno/sistema-de-diseno-v2.md#origen-de-las-fuentes). El APK crece unos 249 KB (estimado con deflate, sin compilarlo).
- Se regeneraron los 18 golden en Linux con Flutter 3.47.9, el parche del CI. Antes se comprobó que ese entorno reproduce sin diferencias las referencias anteriores.
- Inter y JetBrains Mono se quedan: las usa la v1 y son el respaldo de los tokens.
- Algunos componentes e inicio piden peso 700 con `copyWith`. Con Geist se pinta en 600. Falta decidir si pasan a 600 en el código o si la escala suma el 700.
- Con letra al 200 %, el golden de `GrupoLista` parte «Notificaciones» a media palabra cuando la fila lleva un valor a la derecha. Ya pasaba con Inter y se corrige aparte.

## Avance de V2-T02.07

| Criterio | Dónde se cumple |
| --- | --- |
| Set de íconos único | Lucide de trazo 1.5 (`LucideIcons300`) en toda la app, también en las pantallas v1 y en los botones que dibuja Material. Lo vigila `test/arquitectura/un_solo_set_de_iconos_test.dart` |
| Logo SVG claro y oscuro | `assets/marca/agencia360-logo.svg` y `agencia360-logo-oscuro.svg`, trazados del logo anterior sin rediseño. Sustituyen a los PNG |
| Ícono adaptativo | `mipmap-anydpi-v26/ic_launcher.xml` con fondo, símbolo en vector y capa monocroma. Los sabores desarrollo y pruebas conservan su franja |
| Splash | Azul de marca del sistema y cortina de Flutter con el símbolo en SVG |

- Los PNG del ícono para Android 7 o anterior y para iOS se quedan, porque el dibujo no cambió.
- Falta ver el ícono adaptativo y el splash en un teléfono real.
- La splash y el ícono de iOS no se probaron en un Mac, porque las pruebas de macOS están en pausa.
