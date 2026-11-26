# Sistema de diseño v2 — «Pista»

Estado: **Aceptada** (decisión [0004](../decisiones/0004-sistema-de-diseno-propio.md)). Reemplaza por completo el diseño v1 (`lib/tema/tema_carecar.dart`, `shadcn_ui`). Implementación: [T02](../../plan/modulos/T02-sistema-de-diseno.md).

Avance: los tokens de las secciones 2 a 5 ya existen en código en `lib/nucleo/diseno/tokens/` y `TemaPista` arma el tema claro y oscuro. Los colores de estado del modo claro se oscurecieron un poco respecto a la propuesta inicial para pasar contraste AA sobre su fondo suave.

## 1. Dirección

Lo que mejor se ve hoy en apps automotrices premium: **superficies limpias, fotografía del auto como protagonista, tipografía precisa, un solo acento vivo y movimiento que se siente físico**. Nada de cajas con borde en todo, nada de pantallas llenas de texto gris.

| Sí | No |
| --- | --- |
| Foto grande del auto del cliente (su modelo y color) | Íconos genéricos de coche |
| Una acción principal clara por pantalla | Tres botones del mismo peso |
| Números grandes y monoespaciados (km, precios, horas) | Datos enterrados en párrafos |
| Jerarquía por tamaño y peso | Jerarquía por colores distintos |
| Modo oscuro de primera clase | Oscuro como "inversión" automática |
| Estados vacíos con ilustración y siguiente paso | "No hay datos." |

Personalidad: **confiable, precisa, cálida**. Habla de tú, frases cortas, sin tecnicismos.

Lo que se rechaza por genérico (y la lista de revisión de cada PR con interfaz) está en [`antipatrones-de-ia.md`](antipatrones-de-ia.md).

## 2. Color

Tokens semánticos; ningún componente usa hexadecimales directos. Valores iniciales, **a validar** por la prueba de contraste AA de T02.01 (si un par no pasa, se ajusta el valor, no la regla).

| Token | Claro | Oscuro | Uso |
| --- | --- | --- | --- |
| `fondo` | `#F6F7F9` | `#0A0B0E` | Lienzo de la app |
| `superficie` | `#FFFFFF` | `#14161B` | Tarjetas, hojas |
| `superficieElevada` | `#FFFFFF` | `#1C1F26` | Menús, diálogos |
| `superficieHundida` | `#EEF0F3` | `#1A1D23` | Campos, zonas secundarias. En oscuro es un poco más clara que el fondo: si fuera más oscura, campos, burbujas e interruptores apagados desaparecen |
| `borde` | `#E3E6EB` | `#262A33` | Divisores, contornos sutiles |
| `contornoControl` | `#7C8391` | `#6B7280` | Contorno de campos, casillas, interruptores y chips (3 a 1 contra la superficie) |
| `texto` | `#0B0D12` | `#F3F4F6` | Texto principal |
| `textoSecundario` | `#5B6270` | `#A3A9B5` | Apoyo |
| `textoTerciario` | `#8A909C` | `#6B7280` | Solo deshabilitado y marcas de agua. No pasa 4.5 a 1, no usarlo en texto que haya que leer, como las sugerencias de un campo |
| `acento` | `#2457F5` | `#5B8CFF` | Acción principal, enlaces, foco |
| `sobreAcento` | `#FFFFFF` | `#0A0B0E` | Texto sobre acento |
| `marca` | `#1D3557` | `#8FB0DA` | Logo y momentos de marca de la agencia (con mesura) |
| `exito` | `#117857` | `#34C38F` | Confirmada, vigente, listo |
| `advertencia` | `#A25608` | `#F5A524` | Por vencer, esperando aprobación |
| `peligro` | `#C6291D` | `#F97066` | Vencido, error, cancelar |
| `velo` | `#0B0D12` 48 % | `#000000` 64 % | Fondo de diálogos y hojas |

Cada color de estado tiene variante `…Suave` (fondo tenue, 10–14 % de opacidad sobre `superficie`) para insignias y avisos.

Degradado de héroe (detrás de la foto del auto): de `superficieHundida` a `fondo`, vertical. En oscuro, brillo radial tenue del `acento` al 12 %.

## 3. Tipografía

- **Texto:** Geist (SIL OFL), empaquetada en `assets/fonts`. Respaldo: Inter (ya empaquetada en v1).
- **Números y códigos:** Geist Mono con cifras tabulares — km, VIN, placas, precios, horas, folios.
- **Pesos empaquetados:** Geist 400, 500 y 600. Geist Mono 500. Son los de la tabla y la app no descarga fuentes mientras corre. Si un estilo pide otro peso, como 700, el motor usa el más cercano que sí viene (600). Un peso nuevo entra primero en la tabla y luego en `pubspec.yaml`. Lo vigila `test/nucleo/diseno/tokens/fuentes_empaquetadas_test.dart`.

### Origen de las fuentes

| Dato | Valor |
| --- | --- |
| Versión | `v1.9.2` de [vercel/geist-font](https://github.com/vercel/geist-font/releases/tag/v1.9.2) |
| Paquete | <https://github.com/vercel/geist-font/releases/download/v1.9.2/geist-font-v1.9.2.zip> |
| SHA-256 del paquete | `15f066d58dcb99fb10014a49913009fdaf41e464cfb8851a44b44e593c95d3d8` |
| Licencia | SIL Open Font License 1.1, en `assets/fonts/Geist-OFL.txt` |

Los archivos son los TTF estáticos del paquete, sin modificar. Solo cambia el nombre.

| En `assets/fonts` | En el paquete (`geist-font/`) | SHA-256 |
| --- | --- | --- |
| `Geist-400.ttf` | `Geist/ttf/Geist-Regular.ttf` | `2c460a7a71063e53491f343d44b382267bc0cf496e31db64865f962af3152e68` |
| `Geist-500.ttf` | `Geist/ttf/Geist-Medium.ttf` | `e9099e006d4934cae4a8c7d14a1ca2ea724ee2f69f9bdd5b2ffe715baf5524fc` |
| `Geist-600.ttf` | `Geist/ttf/Geist-SemiBold.ttf` | `01923aa148e5202ae70a2e11b2ab4dc41b80bcc374aedccc913d47bb2f591c06` |
| `GeistMono-500.ttf` | `GeistMono/ttf/GeistMono-Medium.ttf` | `34c0828460d47e697655bc9d730027a4b8baf6e6c9aa46f5f32b653b4797cf36` |
| `Geist-OFL.txt` | `OFL.txt` | `021caa749f89fecd7c2e40a50499de29e84d2bc19251659b47d499c2fbfffc17` |

Las cuatro fuentes suman 531 KB sin comprimir y unos 249 KB con compresión deflate, que es la estimación de lo que crece el APK. La app no tiene pantalla de licencias, así que no se registra en `LicenseRegistry`. Cada TTF lleva el aviso de derechos y de licencia en sus metadatos. Si algún día se agrega esa pantalla, hay que registrar `Geist-OFL.txt`.

`shadcn_ui` trae su propia copia variable de Geist bajo `packages/shadcn_ui/`, que es de la v1 y se va con V2-T02.08.

| Token | Tamaño / interlineado | Peso | Tracking |
| --- | --- | --- | --- |
| `display` | 40 / 44 | 600 | −1 % |
| `titulo1` | 28 / 34 | 600 | −0.5 % |
| `titulo2` | 22 / 28 | 600 | 0 |
| `titulo3` | 18 / 24 | 600 | 0 |
| `cuerpo` | 16 / 24 | 400 | 0 |
| `cuerpoFuerte` | 16 / 24 | 500 | 0 |
| `cuerpoChico` | 14 / 20 | 400 | 0 |
| `etiqueta` | 13 / 16 | 500 | +0.2 % |
| `micro` | 11 / 14 | 600 | +6 %, mayúsculas |
| `cifra` | 32 / 36 | 500 (Mono) | −2 % |

Reglas: máximo tres tamaños por pantalla; nunca menos de 11; todo escala con la preferencia del sistema hasta 200 % (M20.03).

## 4. Espacio, forma y elevación

- **Espaciado** (base 4): `1`=4, `2`=8, `3`=12, `4`=16, `5`=20, `6`=24, `8`=32, `10`=40, `14`=56, `18`=72. Margen lateral de pantalla: 16 (teléfono), 24 (tableta). Ancho máximo de contenido: 640.
- **Radios:** `control` 10 · `tarjeta` 16 · `hoja` 28 (arriba) · `campoChat` 24 · `pildora` 999. `bordeHoja` solo redondea arriba: es para las hojas inferiores; una tarjeta usa `bordeTarjeta` (Emergencias dibujaba su tarjeta de ayuda con la base recta, V2-T02.26).
- **Elevación:** claro = sombra suave en dos capas (`0 1 2 / 6 %` + `0 8 24 / 6 %`); oscuro = sin sombra, se sube un tono de superficie. Bordes solo cuando no hay contraste de superficie.
- **Objetivo táctil** mínimo 48 × 48.

## 5. Movimiento

| Token | Duración | Curva | Uso |
| --- | --- | --- | --- |
| `rapido` | 120 ms | `easeOut` | Estados de botón, interruptores |
| `base` | 220 ms | `cubic(0.2, 0, 0, 1)` | Aparecer/desaparecer, cambios de contenido |
| `enfatico` | 360 ms | `cubic(0.05, 0.7, 0.1, 1)` | Transiciones de pantalla, hojas |
| `resorte` | física (amortiguación 0.85) | — | Arrastrar hojas, tarjetas deslizables |

Momentos firma: la foto del auto viaja (héroe) de Garaje a Detalle; la etapa activa del taller "respira"; confirmar una cita dibuja una palomita. Con "reducir movimiento" todo pasa a fundido de 120 ms.

## 6. Iconografía e imagen

- **Un solo set de íconos (V2-T02.07):** Lucide de trazo 1.5, desde `LucideIcons300` (paquete `lucide_icons_flutter`). Se eligió 1.5 porque la fuente no trae el 1.75 que se había propuesto y el trazo fino acompaña mejor a Geist. Lucide no tiene variantes rellenas, así que el estado marcado se distingue por color, píldora y lector de pantalla, nunca por el ícono. Los botones que Material dibuja solo (regresar, cerrar, menú) usan el mismo set por `actionIconTheme`. La prueba `test/arquitectura/un_solo_set_de_iconos_test.dart` impide volver a `Icons` o `CupertinoIcons`.
- **Logo (V2-T02.07):** `assets/marca/agencia360-logo.svg` (letras marino, para fondo claro) y `agencia360-logo-oscuro.svg` (letras claras, para fondo oscuro). Son un trazado del logo que ya existía, sin rediseño. `agencia360-icono.svg` es el símbolo sobre su cuadro marino.
- **Ícono de app (V2-T02.07):** en Android 8 o posterior es adaptativo, con fondo `azul_arranque`, el símbolo en vector dentro de la zona segura y capa monocroma para los íconos temáticos. Los sabores desarrollo y pruebas conservan su franja.
- **Splash (V2-T02.07):** el del sistema es solo el azul de marca y la cortina de Flutter dibuja el símbolo en SVG, para que no haya salto entre los dos.
- Fotos del auto con fondo transparente por modelo y color (`assets/autos/`); si falta el color exacto, silueta del modelo en `textoTerciario`.
- Ilustraciones de estados vacíos en línea, monocromas con toque de `acento`.

## 7. Navegación

Barra inferior con 5 destinos: **Inicio · Mi auto · Servicio · Explorar · Cuenta**.

| Destino | Contiene |
| --- | --- |
| Inicio | Saludo, héroe del auto, acciones rápidas (Agendar, Manual, Documentos, SOS), taller en vivo, próxima cita, mantenimiento, Para ti |
| Mi auto | Garaje, detalle, historial, manuales, ficha técnica, documentos, garantía, bitácora |
| Servicio | Citas, taller en vivo, recolección, pagos, mensajes |
| Explorar | Catálogo, calculadora de toma a cuenta, tienda, promociones, estreno |
| Cuenta | Perfil, seguridad, notificaciones, lealtad, familia, ayuda, ajustes |

## 8. Componentes

Base: `Boton` (principal, secundario, terciario, peligro; chico/normal/grande; con carga), `CampoTexto`, `CampoContrasena`, `Selector`, `Casilla`, `Interruptor` (y `ControlInterruptor`, el control suelto), `Chip` (en código `ChipPista`, para no chocar con el `Chip` de Material), `Avatar`, `Insignia`, `Aviso` (info/éxito/advertencia/peligro), `Dialogo`, `HojaInferior`, `Menu`, `Pestanas`.

Compuestos: `TarjetaVehiculo` (foto de un modelo del catálogo), `TarjetaAuto` (el auto del cliente), `TarjetaResumen`, `FilaLista`, `EncabezadoGrande` (colapsa al desplazar, opcionalmente translúcido), `BarraPantalla`, `MarcoPantalla` (con `BarraInferior` y `SeccionPantalla`), `FilaAcciones`, `ResultadoPantalla`, `BotonRegresar`, `BotonCerrar`, `Estante`, `GrupoLista`, `BotonPildora`, `BotonCircular`, `LineaDeTiempo`, `Calendario` (días con cupo), `SelectorFranja`, `EstadoVacio`, `EstadoError`, `Esqueleto`, `BarraNavegacion`, `TarjetaMetrica` (cifra + etiqueta), `TarjetaAccion`, `VisorPdf`, `GaleriaFotos`, `Semaforo` (inspección), `Firma`, `Mapa` (pin y seguimiento), `Grafica` (con tabla accesible), `DeslizarParaConfirmar`, `BurbujaMensaje` y `CampoMensaje` (chat).

**Zona táctil del `Calendario`:** cada día mide 48 de alto. En teléfonos de 320 de ancho se angosta a unos 42, porque siete columnas de 48 no caben. Es la única excepción aceptada a los 48 (V2-M20.08) y cumple WCAG 2.2 AA.

**Navegación en píldora (rediseño del inicio, V2-T02.21).** Inspirada en la app móvil de Claude: menos héroes y tarjetas de color, más aire y listas limpias.

| Componente | Qué es |
| --- | --- |
| `BarraFlotante` | Barra inferior que flota con margen, de vidrio y con sombra; el destino activo va en una píldora más oscura y siempre se ve icono y texto. Reutiliza `DestinoNavegacion`. Cada destino mide al menos 48 y anuncia su posición. `BarraFlotante.altoReservado` dice cuánto margen inferior necesita el contenido. |
| `GrupoAccionesPildora` | De una a tres acciones de icono dentro de una misma píldora de vidrio (la de la derecha del encabezado). Cada acción mide 48 × 48. |
| `BotonAccionFlotante` | La acción principal de la pantalla, en píldora del color de acento (degradado hacia el marino de marca, resplandor del mismo color y texto `sobreAcento`), con icono y texto sobre el contenido. Una por pantalla. |

El inicio (`lib/nucleo/inicio/inicio_nuevo.dart`) gira alrededor del auto del cliente y de lo que le importa de él, no de un menú: **los destinos viven solo en la barra y el cuerpo no los repite con accesos** (V2-T02.22). Arriba el saludo y el avatar (abre perfil y ajustes); luego la `TarjetaAuto` (se desliza si hay varios autos, con puntos debajo; la marca no se repite cuando el modelo ya la trae, como en el garaje). Debajo, todo en `TarjetaResumen` y de lo más concreto a lo más estimado: lo que el taller tiene en curso (`TarjetaOrdenEnCurso`); la próxima cita (el día en un `CuadroFecha`); el próximo servicio del auto que se está viendo (`TarjetaProximoServicioDelAuto`, la misma tarjeta que el plan de mantenimiento, con la barra del avance de kilometraje; cambia al deslizar el carrusel y no ocupa lugar si el plan falla o aún no hay un próximo estimado); y, solo si no hay cita, la invitación a agendar: lo vacío nunca va por encima de lo que sí hay. Cada tarjeta lleva su propia separación inferior (16), así que no sobran huecos cuando alguna no se ve. Abajo, el botón flotante y la barra. El fondo es el `fondo` liso, como en las demás pantallas. Mientras llegan los autos se ve un esqueleto; sin autos, una tarjeta que lo explica. Con letra a más de 130 % las placas bajan debajo del nombre y la tarjeta crece; a más de 150 % el botón flotante se esconde y la reserva del final de la lista crece, para que nada quede tapado. Si las peticiones de autos o citas fallan, el inicio se pinta igual con los estados vacíos. Por ahora los destinos de la barra abren su pantalla encima del inicio; convertirlos en pestañas reales (cada una con su propio navegador) es el siguiente paso. `BarraNavegacion` (ancha, pegada al borde) sigue en el sistema para quien la necesite.

**Vidrio (V2-T02.19):** `BotonPildora` y `BotonCircular` tienen variante `vidrio`: fondo del color del texto al 6 %, borde de luz al 14 %, texto `texto` e ícono `acento`, con rebote. Es el estilo de las acciones secundarias de toda la app (la propuesta «Liquid Glass»); `BotonCircular` es de vidrio por omisión.

**`BotonCircular`** (V2-T02.17): botón de un ícono, círculo de 48 con `ReboteTactil`. Variante `tonal` (fondo `superficieHundida`, ícono `textoSecundario`) y `acento` (fondo `acentoSuave`, ícono `acento`). Con `iconoMarcado` es interruptor: marcado se ve como acento y el lector lo anuncia seleccionado. Deshabilitado: fondo hundido, ícono terciario, sin rebote. Lo usan enviar (acento) y adjuntar de `CampoMensaje`, y 👍/👎 del asistente.

**`VisorPdf.paginaInicial`** (V2-M24.04): abre el documento en esa página (por omisión la 1) y el contador empieza ahí; si el documento tiene menos páginas, abre en la última. La fábrica del visor recibe la página para pasarla al motor nativo.

### Vidrio líquido y píldora (V2-T02.16)

Propuesta de estilo hecha con Daniel: superficies de vidrio y controles redondos, dibujados por Flutter, así que se ven igual en Android y en iOS.

- **`SuperficieLiquida`:**
  - desenfoque del fondo siempre recortado a su forma (sin recorte, el blur se sale y mancha);
  - tinte translúcido y bisel de luz de 1 px.
- **`CampoBusquedaLiquido`:** buscador en cápsula sobre esa superficie.
- **Forma píldora:** botones y campos de una línea usan `Radios.bordePildora`. Los campos de varias líneas siguen con `bordeTarjeta`, salvo `CampoMensaje`: usa `Radios.bordeCampoChat` (24, la mitad de su alto de una línea), así con una línea es píldora como el login y al crecer queda como cápsula sin cortar el texto.
- **`ReboteTactil`:**
  - reemplaza la salpicadura de Material con un encogimiento corto al presionar (`Movimiento.toqueBajada` de 70 ms y `toqueSubida` de 100 ms);
  - con reducir movimiento no se encoge;
  - el interruptor además vibra levemente.
- **Login:** oscuro, con resplandor azul, campos de vidrio en píldora, logo con letras claras (`agencia360-logo-oscuro.svg`) y barra de estado en claro.

### Mensajes (chat)

Para el asistente (M24) y la mensajería con el asesor (M07). Un solo par de componentes para que todos los chats de la app se vean igual.

**`BurbujaMensaje`.**
- **Lado y color:** la propia va a la derecha con `acento` y texto `sobreAcento`; la ajena va a la izquierda sobre `superficieHundida` con texto `texto`.
- **Forma:** radio `tarjeta`; la esquina inferior del lado de quien habla es de 4, como cola.
- **Ancho:** nunca pasa del 80 % del disponible.
- **Hora:** opcional, en `micro`.
- **Fuentes:** opcionales al pie, por ejemplo «Manual, pág. 214». Son botones subrayados con ícono de libro, de al menos 48 de alto, con su propia etiqueta para el lector, por ejemplo «Manual, página 214, abrir».
- **Estados de envío:** solo en mensajes propios.
  - `enviando` muestra «Enviando…».
  - `fallido` muestra «No se envió» en `peligro` con el botón «Reintentar» de 48.
  - `enviado` no muestra nada.
- **Lector de pantalla:** oye «Tú: texto, hora» o «CareCar: texto, hora» en un solo nodo.

**`CampoMensaje`.**
- **Forma:** campo sobre `superficieHundida` en píldora (`Radios.bordeCampoChat`); con foco, borde de `acento`. `iconoAdjuntar` cambia el ícono de adjuntar (el asistente usa una cámara, V2-M24.05).
- **Alto:** crece con el texto hasta 5 líneas y después se desplaza por dentro.
- **Enviar:** ícono en `acento`, deshabilitado mientras no haya texto, sin contar espacios. Al enviar entrega el texto recortado y se vacía.
- **Adjuntar:** solo aparece si la pantalla lo pide.
- **Botones:** los dos miden 48 y tienen nombre propio para el lector («Enviar», «Adjuntar»).

Golden en `test/nucleo/diseno/componentes/goldens/mensajes_*.png`.

### Encabezados y marcos de pantalla

Toda pantalla de detalle o de formulario se arma igual: **barra, título grande, contenido**. No hay «héroes» decorativos (una pieza grande con fondo difuminado): lo único con color pleno de una pantalla es lo que esa pantalla trata (el auto, el QR de un comprobante, el avance del próximo servicio). Solo usan tokens; en oscuro no hay sombra y se sube de superficie; el movimiento pasa por `context.movimiento`.

**`EncabezadoGrande`.** Sliver fijo con dos partes. La *barra* (56 de alto, más la zona del reloj) lleva a la izquierda `BotonRegresar` (si `conRegreso`) y a la derecha las `acciones`; al recogerse muestra el título pequeño (`titulo3`) entre ambos. El *título grande* (`titulo1`, hasta dos líneas) con el `subtitulo` debajo va alineado a la izquierda, sube por detrás de la barra y se desvanece en la primera mitad del recorrido, mientras el pequeño aparece en la segunda: nunca se ven los dos. Con `translucido` la barra recogida desenfoca (σ hasta 30) y deja asomar el color del contenido, pero su fondo solo baja a 92 % de opacidad: el texto de abajo no se lee a través del título. Las alturas se miden con el tamaño de letra y el ancho reales, así que a 200 % el título no se corta. Accesibilidad: un solo encabezado para el lector (el grande y, recogido, el pequeño).

**`BotonRegresar` y `BotonCerrar`.** Botones circulares de vidrio de 48 con el icono en el color de texto (`BotonCircular` con `colorIcono`), iguales entre sí. «Regresar» hace `pop` si hay historial y, si no, va al inicio; es para las raíces de un módulo. «Cerrar» (`Navigator.maybePop`) es para lo que se abre encima de otra pantalla (formularios, comprobantes). Las acciones de la derecha usan `BotonCircular` o `GrupoAccionesPildora`.

**`MarcoPantalla`.** La única implementación del marco: `EncabezadoGrande` translúcido, contenido en `slivers` (ancho máximo 640, centrado), recarga jalando (`alRefrescar`) y `barraInferior`. Sin `acciones` ni regreso lleva «Cerrar». `MarcoPantalla.estado` pone un estado de pantalla completa (cargando, vacío, error) bajo el mismo título. Van con él `BarraInferior` (acciones fijas al pie, respeta el área segura) y `SeccionPantalla` (título de sección como encabezado accesible, con `nota` opcional). Ningún módulo arma su propio `Scaffold` con encabezado. **Ningún módulo arma el encabezado a mano:** un `EncabezadoGrande` suelto se quedaba sin botón de regreso o de cierre (V2-T02.23), y `test/arquitectura/solo_componentes_del_sistema_test.dart` falla si aparece uno en `lib/modulos/`.

**`BarraPantalla`.** La versión quieta de la barra, para pantallas que no se desplazan como lista (visor de PDF, pestañas, chat, formularios con su propio desplazamiento, la calculadora): regreso, título con subtítulo y acciones, sobre `fondo` con una línea inferior. El título va en una línea (con puntos suspensivos) para que la barra no crezca con la letra grande. **Regla:** toda pantalla de `lib/modulos/` abre con `MarcoPantalla` (listas, detalles, formularios) o con `BarraPantalla` (lo demás); ya no se usa el `AppBar` de Material. Hoy usan `BarraPantalla` el chat del asistente, el visor de PDF (manual y comprobante), la calculadora y el checklist con pestañas; una lista o un formulario con barra pequeña es un error (V2-T02.25 migró «Mis estimaciones», «Comparar modelos», «Mis solicitudes» y los formularios de estreno). Una lista lleva «Regresar»; un formulario o comprobante que se abre encima de otra pantalla lleva «Cerrar» y pone el modelo o el auto como `subtitulo`, no como un segundo título dentro del cuerpo.

**`TarjetaAuto`.** Bloque de color con la silueta del auto (`SiluetaAuto`, dibujada con trazos), el modelo, las placas y el kilometraje. Sin `alToque` es solo informativa. `tinte` viene del color del auto (`tinteDeColorAuto`: rojo → `peligro`, verde → `exito`, amarillo/naranja → `advertencia`, lo demás → `acento`); el degradado baja hacia el marino de `marca` con el acento y a una variante de la misma tonalidad con los demás. Sin `titulo` (cuando el encabezado ya lo dice) queda la silueta con las placas y el kilometraje. Con letra a más de 130 % las placas bajan y la tarjeta crece (`TarjetaAuto.altoPara`). El texto es `sobreAcento` sobre el relleno. La usan el inicio, el garaje y el detalle del vehículo.

**`EstadoError`.** El estado de error de pantalla completa: icono, título, mensaje y «Reintentar». Sus textos por omisión (error genérico y sin conexión) salen de `AppLocalizations`, con tilde y en el idioma de la app; una pantalla solo los pasa si tiene algo más que decir, no para traducirlos (V2-T02.25).

**`TarjetaResumen`.** De qué trata la pantalla: cuadro pleno del tono con su icono (el mismo que el de `FilaGrupo`) o una `visual` propia, título, subtítulo, detalle, insignia de estado y, si aplica, barra de avance (`progreso` de 0 a 1 y `etiquetaProgreso`). Mismo fondo y sombra que `GrupoLista`. Con `alToque` es un botón con chevron; `pista` le dice al lector qué pasa al tocarla y `estadoConIcono` suma a la insignia el icono de su tono. El lector oye un solo nodo, con el avance en porcentaje. La usan el inicio (taller, cita y próximo servicio), el plan de mantenimiento, la próxima cita de «Mis citas» (con sus acciones debajo) y las demás pantallas de detalle: una sola familia de tarjetas de resumen. La flecha de toda fila o tarjeta tocable es la misma (`LucideIcons300.chevronRight`) y del mismo color, `textoTerciario` (V2-T02.25).

**`CuadroFecha`.** El día y el mes de una cita en un cuadro pleno del tono, de 40 de ancho y con texto `sobreAcento`: el mismo cuadro que el de icono de `TarjetaResumen` y `GrupoLista`, con la fecha en lugar del icono. Es el `visual` de la próxima cita en el inicio y el inicio de cada fila de la lista de citas, así que la fecha de una cita se ve igual en los dos. El color sale del estado de la cita; el estado también se dice con texto.

**`FilaAcciones`.** La acción principal (`BotonPildora` llena) y la secundaria (vidrio) de una pantalla, justo bajo el encabezado. Dos acciones se reparten la fila; con una sola, con `apiladas` o con letra grande van una debajo de la otra.

**`ResultadoPantalla`.** El cierre de un flujo (cita confirmada, cita reprogramada): marca redonda del tono con una palomita que entra con un rebote (quieta con «reducir movimiento»), título, mensaje, un `contenido` opcional y las acciones apiladas. Sin encabezado ni regreso: la acción principal es la salida.

**Regla en CI (V2-T02.18):** `test/arquitectura/solo_componentes_del_sistema_test.dart` falla si `lib/modulos/` usa `IconButton`, `TextButton`, `ElevatedButton`, `FilledButton`, `OutlinedButton`, `TextField`, `Card`, `ListTile` o `Chip` de Material, o importa `shadcn_ui` o `lib/widgets/` (v1). El mensaje dice qué componente usar. Los provisionales (`presentacion/provisional/`) quedan fuera.

**`BotonPildora`.** Píldora de ancho flexible con ícono opcional y texto. Variantes: `lleno` (acción principal, `acento`), `tonal` (secundaria, `acentoSuave`) y `peligro` (destructiva como cancelar una cita: `peligroSuave` con texto `peligro`, V2-T02.18). Con `cargando` muestra un indicador en lugar del ícono, no responde y el lector oye «<texto>, cargando». Estados: normal, presionado (se encoge a 96 % con `rapido`; con reducir movimiento no se encoge), foco y hover (velo del 10 %), deshabilitado (`superficieHundida` y `textoTerciario`). Mínimo 48 de alto; el texto se parte en líneas con letra al 200 %. Semántica: botón con el texto como etiqueta y estado habilitado.

**`Estante`.** Título grande (`titulo2`) como encabezado, enlace «Ver todo» opcional (48 de zona táctil, etiqueta «Ver todo: título») y carrusel horizontal de `hijos` de ancho `anchoTarjeta` que, al soltar, se alinea a una tarjeta con el resorte del sistema. El `alto` lo fija quien lo usa y debe dar cabida a la tarjeta con letra al 200 %.

**`GrupoLista` y `FilaGrupo`.** Es el estilo de lista de la app: ninguna pantalla usa ya `FilaLista` (filas sueltas sobre el fondo), que queda en el sistema solo para el caso sin tarjeta. Lista agrupada: tarjeta de radio `tarjeta` con filas separadas por líneas finas que empiezan después del ícono. Cada fila lleva ícono en cuadro redondeado de color (`colorIcono`), título, subtítulo, adorno final y chevron si es tocable. `encabezado` (etiqueta, como encabezado accesible) y `pie` (texto de apoyo) van fuera de la tarjeta. Cada fila es un solo nodo para el lector de pantalla con título y subtítulo; el adorno final no se lee, así que si es una cifra que importa (puntos, un importe) se dice en palabras con `etiquetaFin` («Ganaste 230 puntos» por «+230»). El adorno final toma su ancho natural (hasta la mitad de la fila) y el texto, todo el resto: antes se repartían el espacio libre a partes iguales y el texto se partía aunque cupiera (V2-T02.24). `conChevron: false` quita la flecha de una fila tocable que no lleva a otra pantalla (una con interruptor, «Cerrar sesión», o una sección que se despliega, como las de la ficha técnica) y `llave` identifica la fila. `GrupoLista` no pone margen lateral: lo pone quien lo usa, el mismo que los botones de su pantalla (`Espaciado.e4`); el comprobante de la cita lo olvidó y la tarjeta llegaba de borde a borde. `ControlInterruptor` es el interruptor sin su fila, para usarlo de adorno final; `Interruptor` lo usa por dentro.

**Ajustes (V2-T02.24).** Se abre desde el avatar del inicio y está armado con lo mismo que el resto: `MarcoPantalla` con regreso y título grande; el perfil en una `TarjetaResumen` con el `Avatar` (sin nombre ni correo se omite: no se inventa nada; mientras carga, un `Esqueleto`; si falla, la tarjeta explica y «Reintentar», y el resto de Ajustes sigue a la vista); el selector de idioma; y un `GrupoLista` por tema (Cuenta, Notificaciones, Ayuda, Acerca de) con el título en minúsculas. «Cerrar sesión» está una sola vez, en su propio grupo, con el cuadro de icono en `peligro` y sin flecha. Confirmar el cierre es un `Dialogo` de peligro y «Contactar a la agencia» una `HojaInferior`; las dos se montan bajo el tema de la aplicación, así que la pantalla les vuelve a aplicar el suyo (si no, saldrían siempre en claro). Los textos siguen escritos a mano porque la pantalla es de la v1 (`lib/pantallas/perfil/`) y aún no está en `lib/modulos`.

Golden en `test/nucleo/diseno/componentes/goldens/` (claro, oscuro y 200 %). Todos están en la galería.

Cada componente documenta: anatomía, variantes, estados (normal, presionado, foco, deshabilitado, cargando, error), accesibilidad (`Semantics`, orden de foco) y golden en claro, oscuro y 200 %.

### Mapa

`Mapa` (V2-T02.09, decisión [0006](../decisiones/0006-mapas-y-geocodificacion.md)) vive en `lib/nucleo/diseno/componentes/mapa.dart`. Es el único componente que importa `flutter_map` y `latlong2`: quien lo usa habla en `Coordenada` e importa `lib/nucleo/mapas/mapas.dart`.

**Anatomía.** Un recuadro de radio `tarjeta` (260 de alto por omisión, `alto`) con las teselas, los marcadores y el crédito abajo a la derecha. Debajo, y solo cuando aplican, van el aviso de teselas con «Reintentar», «Ver mi ubicación», el aviso de ubicación y los controles del pin. Ningún control tapa el crédito.

| Parte | Cómo se ve | Con qué se activa |
| --- | --- | --- |
| Pin | `location_on` de 48 en `acento` con aro `superficie`. La punta marca la coordenada | `pin` |
| Pin editable | El mismo, se arrastra y trae sus botones | `alMoverPin` (sin él es de solo lectura) |
| Ubicación propia | Punto de 24 en `acento` con aro | `miUbicacion` o `proveedorUbicacion` |
| Marcador en movimiento | Ficha redonda de 48 con borde `acento` e ícono (`local_shipping` por omisión) | `enMovimiento` (`MarcadorEnMovimiento`) |

**Pin.** La pantalla guarda la coordenada: el mapa la entrega al tocar, al soltar el arrastre (no en cada paso) o al usar los botones. Arrastrar el pin le gana al desplazamiento del mapa y al de la página que lo contiene, y no sale del recuadro. Para ponerlo y moverlo sin arrastrar hay «Poner el pin en el centro» (cuando no hay pin) y cuatro `BotonCircular` de 48 (norte, sur, oeste y este) que lo mueven 24 puntos de pantalla, así que cuanto más cerca está el mapa más fino es el paso.

**Cámara.** Abre en el pin, el marcador en movimiento o la ubicación propia, en ese orden, y sin ninguno en `centroInicial` (León, Guanajuato). Si el pin o el marcador en movimiento cambian a un punto que no se ve, el mapa lo sigue. No se puede girar.

**Ubicación propia y permiso.** Con `proveedorUbicacion` la posición se lee una sola vez, solo cuando la persona toca «Ver mi ubicación». El mapa no pide permisos al abrirse ni sigue la posición. Permiso negado, permiso bloqueado, ubicación apagada y tiempo agotado tienen cada uno su aviso, y el resto del mapa sigue funcionando.

**Sin conexión.** Si una tesela falla aparece un aviso con «Reintentar». El pin, los marcadores y los botones siguen disponibles.

**Movimiento.** El marcador en movimiento se desliza con el token `base`. Con «reducir movimiento» salta a la posición nueva sin animar, como pide la decisión 0006.

**Oscuro.** Las teselas son claras, así que se atenúan con `fondo` al 40 %. No se invierten.

**Accesibilidad.** El mapa es un solo nodo con nombre («Mapa con un pin.», «Mapa sin pin.» o «Mapa de seguimiento.») o con la `descripcion` que dé la pantalla, más la etiqueta del marcador y «Se muestra tu ubicación.» cuando aplican. El nombre por omisión no dice coordenadas. El crédito se lee aparte. Al mover el pin con un botón se anuncia, por ejemplo, «Pin movido al norte». Todos los controles miden al menos 48 y los avisos se anuncian solos.

**Teselas y privacidad.** `teselas` es la `ConfiguracionTeselas` del build (`configuracionTeselasProvider`): URL y crédito se configuran, no se escriben en las pantallas. Por la política de OpenStreetMap, cada descarga lleva en el `User-Agent` el identificador de la app, el crédito está siempre a la vista, la caché del paquete queda activa y no se descarga por adelantado fuera de lo visible. Los errores de descarga salen sin la dirección de la tesela (`ClienteTeselas`), porque esa ruta dice qué zona mira la persona y el paquete los escribe en la consola.

**Pruebas.** `fuenteTeselas` reemplaza la red con `TeselasLisas` o `TeselasSinConexion` (en pantallas, `fuenteTeselasProvider`). Pruebas en `test/nucleo/diseno/componentes/mapa_test.dart` y golden en `goldens/mapa_*.png`. `test/arquitectura/paquetes_de_mapas_test.dart` vigila que los paquetes no salgan de su sitio.

```dart
Mapa(
  teselas: ref.watch(configuracionTeselasProvider),
  fuenteTeselas: ref.watch(fuenteTeselasProvider),
  pin: _pin,
  alMoverPin: _ponerPin,
)
```

### Pruebas golden

Las pruebas de Pantalla, Mensajes y Mapa usan `matchesGoldenFile` de `flutter_test`. El ayudante `test/ayudas/fuentes_golden.dart` lee de `assets/fonts/` los mismos pesos de Geist y Geist Mono que declara `pubspec.yaml`, más Inter y JetBrains Mono de respaldo. Material Icons sale del directorio de recursos que prepara `flutter test`. Cada prueba fija el tamaño y la densidad de pantalla y compara una referencia por escenario.

Desde la raíz de CareCar, corre las tres suites con Flutter y las dependencias ya instaladas:

```bash
flutter test test/nucleo/diseno/componentes/pantalla_golden_test.dart test/nucleo/diseno/componentes/mensajes_golden_test.dart test/nucleo/diseno/componentes/mapa_golden_test.dart
```

Las referencias se generan en Linux con el mismo parche de Flutter que usa CI. La rasterización de texto e íconos puede variar en Windows aunque el diseño sea el mismo. Si el cambio visual es intencional, agrega `--update-goldens` al comando en Linux y revisa las PNG resultantes antes de incluirlas en el PR. El check **Pruebas (flutter test)** ejecuta la comparación exacta en Ubuntu. Si falla, adjunta el artefacto `diferencias-golden`, donde `*_testImage.png` es la captura del runner y `*_masterImage.png` es la referencia con la que se comparó.

## 9. Escritura (UX copy)

- Verbos concretos en botones: «Agendar cita», no «Continuar».
- Errores: qué pasó + qué hacer. «No pudimos conectar. Revisa tu internet y vuelve a intentarlo.»
- Estimaciones siempre con «Estimación no vinculante».
- Fechas relativas cuando ayudan («mañana a las 9:00»), absolutas en comprobantes.
- Números con separador de miles de México en todo el español: `formatearMiles` (`lib/nucleo/idioma/formato_numeros.dart`). «18,450 km», nunca «18.450 km».

## 10. Proceso

1. ¿Falta algo? Se propone aquí (PR de docs) → se construye en `lib/nucleo/diseno` con golden → se usa. Mientras se construye, quien lo necesita usa un provisional en su módulo ([`plan/trabajo-en-paralelo.md`](../../plan/trabajo-en-paralelo.md), sección 4) y lo reemplaza al integrarse el componente.
2. Revisión visual con capturas claro/oscuro en cada PR con UI.
3. Este documento se actualiza en el mismo PR que cambia un token o componente.
