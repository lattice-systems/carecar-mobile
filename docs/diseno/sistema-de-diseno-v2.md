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
- **Radios:** `control` 10 · `tarjeta` 16 · `hoja` 28 (arriba) · `campoChat` 24 · `pildora` 999.
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

- Un solo set de íconos de trazo (Lucide, trazo 1.75) — decisión final en T02.07.
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

Base: `Boton` (principal, secundario, terciario, peligro; chico/normal/grande; con carga), `CampoTexto`, `CampoContrasena`, `Selector`, `Casilla`, `Interruptor`, `Chip` (en código `ChipPista`, para no chocar con el `Chip` de Material), `Avatar`, `Insignia`, `Aviso` (info/éxito/advertencia/peligro), `Dialogo`, `HojaInferior`, `Menu`, `Pestanas`.

Compuestos: `TarjetaVehiculo` (héroe), `FilaLista`, `EncabezadoGrande` (colapsa al desplazar, opcionalmente translúcido), `CabeceraPortada`, `BarraPortada`, `Estante`, `GrupoLista`, `BotonPildora`, `BotonCircular`, `LineaDeTiempo`, `Calendario` (días con cupo), `SelectorFranja`, `EstadoVacio`, `EstadoError`, `Esqueleto`, `BarraNavegacion`, `TarjetaMetrica` (cifra + etiqueta), `TarjetaAccion`, `VisorPdf`, `GaleriaFotos`, `Semaforo` (inspección), `Firma`, `Mapa` (pin y seguimiento), `Grafica` (con tabla accesible), `DeslizarParaConfirmar`, `BurbujaMensaje` y `CampoMensaje` (chat).

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
- **Login:** oscuro, con resplandor azul, campos de vidrio en píldora, logo con letras claras (`agencia360-logo-oscuro.png`) y barra de estado en claro.

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

### Estilo portada

Para pantallas con aire, esquinas generosas y una pieza protagonista (referencia de ritmo: las apps de música; sin copiar marcas, íconos ni recursos de nadie). Solo usan tokens; en oscuro no hay sombra y se sube de superficie; el movimiento pasa por `context.movimiento`.

**`EncabezadoGrande(translucido: true)`.** Título grande en negrita que se contrae a una barra compacta. Con `translucido` la barra contraída desenfoca (σ hasta 30) y deja asomar el color del contenido, pero su fondo solo baja a 92 % de opacidad con el desplazamiento: el texto de abajo no se lee a través del título. Expandido no tiene desenfoque. Accesibilidad: sigue siendo un encabezado; con letra grande reserva dos líneas.

**`BotonPildora`.** Píldora de ancho flexible con ícono opcional y texto. Variantes: `lleno` (acción principal, `acento`) y `tonal` (secundaria, `acentoSuave`). Estados: normal, presionado (se encoge a 96 % con `rapido`; con reducir movimiento no se encoge), foco y hover (velo del 10 %), deshabilitado (`superficieHundida` y `textoTerciario`). Mínimo 48 de alto; el texto se parte en líneas con letra al 200 %. Semántica: botón con el texto como etiqueta y estado habilitado.

**`CabeceraPortada`.** Pieza cuadrada con radio `hoja` y sombra suave (foto, silueta o ícono grande) sobre un fondo hecho con la misma pieza desenfocada (σ 40) y un degradado del `tinte` (por defecto `acento`, 42 % en claro y 55 % en oscuro) que termina en `fondo`, sin borde duro. Debajo: título (`titulo1`), subtítulo y hasta dos `BotonPildora` (principal llena, secundaria tonal; `AccionPortada`). Con letra grande los botones se apilan. Semántica: la pieza es una imagen con `descripcion`, el título es encabezado, el fondo se excluye. Si el `Scaffold` que la contiene usa `extendBodyBehindAppBar`, reserva la altura de la barra (más la zona del reloj) arriba de la pieza, así la portada empieza debajo de la barra y no queda detrás del título.

**`BotonRegresar`.** Botón circular de vidrio para volver: hace `pop` si hay historial y, si no, va al inicio. Semántica «Regresar», zona táctil de 48. Lo llevan `BarraPortada` y, con `conRegreso: true`, `EncabezadoGrande` (pantallas raíz abiertas desde el menú: garaje, mis citas, emergencias, mis direcciones).

**`BarraPortada`.** Barra superior (`AppBar`) de las pantallas con `CabeceraPortada` a pantalla completa (`Scaffold(extendBodyBehindAppBar: true)`). Arriba del todo es transparente para que el fondo de la portada llegue al borde; al desplazar (`scrolledUnder`) pasa a `fondo` opaco, así ninguna tarjeta se ve a través del título ni del botón de regreso. Título opcional.

**`Estante`.** Título grande (`titulo2`) como encabezado, enlace «Ver todo» opcional (48 de zona táctil, etiqueta «Ver todo: título») y carrusel horizontal de `hijos` de ancho `anchoTarjeta` que, al soltar, se alinea a una tarjeta con el resorte del sistema. El `alto` lo fija quien lo usa y debe dar cabida a la tarjeta con letra al 200 %.

**`GrupoLista` y `FilaGrupo`.** Lista agrupada: tarjeta de radio `tarjeta` con filas separadas por líneas finas que empiezan después del ícono. Cada fila lleva ícono en cuadro redondeado de color (`colorIcono`), título, subtítulo, adorno final y chevron si es tocable. `encabezado` (etiqueta, como encabezado accesible) y `pie` (texto de apoyo) van fuera de la tarjeta. Cada fila es un solo nodo para el lector de pantalla.

Golden en `test/nucleo/diseno/componentes/goldens/` (claro, oscuro y 200 %), con la fuente de prueba de Flutter hasta que V2-T03.02 deje las reales. Todos están en la galería.

Cada componente documenta: anatomía, variantes, estados (normal, presionado, foco, deshabilitado, cargando, error), accesibilidad (`Semantics`, orden de foco) y golden en claro, oscuro y 200 %.

## 9. Escritura (UX copy)

- Verbos concretos en botones: «Agendar cita», no «Continuar».
- Errores: qué pasó + qué hacer. «No pudimos conectar. Revisa tu internet y vuelve a intentarlo.»
- Estimaciones siempre con «Estimación no vinculante».
- Fechas relativas cuando ayudan («mañana a las 9:00»), absolutas en comprobantes.

## 10. Proceso

1. ¿Falta algo? Se propone aquí (PR de docs) → se construye en `lib/nucleo/diseno` con golden → se usa. Mientras se construye, quien lo necesita usa un provisional en su módulo ([`plan/trabajo-en-paralelo.md`](../../plan/trabajo-en-paralelo.md), sección 4) y lo reemplaza al integrarse el componente.
2. Revisión visual con capturas claro/oscuro en cada PR con UI.
3. Este documento se actualiza en el mismo PR que cambia un token o componente.
