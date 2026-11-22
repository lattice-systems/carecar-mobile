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
| `superficieHundida` | `#EEF0F3` | `#07080A` | Campos, zonas secundarias |
| `borde` | `#E3E6EB` | `#262A33` | Divisores, contornos sutiles |
| `texto` | `#0B0D12` | `#F3F4F6` | Texto principal |
| `textoSecundario` | `#5B6270` | `#A3A9B5` | Apoyo |
| `textoTerciario` | `#8A909C` | `#6B7280` | Marcas de agua, deshabilitado |
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
- **Radios:** `control` 10 · `tarjeta` 16 · `hoja` 28 (arriba) · `pildora` 999.
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

Compuestos: `TarjetaVehiculo` (héroe), `FilaLista`, `EncabezadoGrande` (colapsa al desplazar), `LineaDeTiempo`, `Calendario` (días con cupo), `SelectorFranja`, `EstadoVacio`, `EstadoError`, `Esqueleto`, `BarraNavegacion`, `TarjetaMetrica` (cifra + etiqueta), `TarjetaAccion`, `VisorPdf`, `GaleriaFotos`, `Semaforo` (inspección), `Firma`, `Mapa` (pin y seguimiento), `Grafica` (con tabla accesible), `DeslizarParaConfirmar`.

Cada componente documenta: anatomía, variantes, estados (normal, presionado, foco, deshabilitado, cargando, error), accesibilidad (`Semantics`, orden de foco) y golden en claro, oscuro y 200 %.

## 9. Escritura (UX copy)

- Verbos concretos en botones: «Agendar cita», no «Continuar».
- Errores: qué pasó + qué hacer. «No pudimos conectar. Revisa tu internet y vuelve a intentarlo.»
- Estimaciones siempre con «Estimación no vinculante».
- Fechas relativas cuando ayudan («mañana a las 9:00»), absolutas en comprobantes.

## 10. Proceso

1. ¿Falta algo? Se propone aquí (PR de docs) → se construye en `lib/nucleo/diseno` con golden → se usa.
2. Revisión visual con capturas claro/oscuro en cada PR con UI.
3. Este documento se actualiza en el mismo PR que cambia un token o componente.
