# 0007 · Proveedor de IA y búsqueda en manuales del asistente

**Estado:** Aceptada (SM Daniel y PO Haziel, 2026-11-23)

Historia: [V2-M24.01](../../plan/modulos/M24-asistente-carecar.md).

## Contexto

El asistente (M24) contesta preguntas con base en el manual del modelo y año del cliente, citando la página, e identifica testigos del tablero por foto. La ficha (sección 21) pide las tablas `fragmento_manual` (`id`, `manual_id`, `pagina`, `texto`, `embedding`) y `consulta_asistente`.

Restricciones que ya fija el módulo M24:

- La llamada al modelo **solo sale del backend**; la app nunca tiene llaves de IA.
- **Sin datos personales en el prompt**: solo la pregunta, el modelo y año, y fragmentos del manual.
- Si el manual no tiene la respuesta, el asistente lo dice; no inventa.
- Límite de preguntas por cliente al día (`ASISTENTE_LIMITE`) y error propio si el proveedor no responde (`ASISTENTE_NO_DISPONIBLE`).

El backend corre en Azure Container Apps con PostgreSQL en Neon. El dueño pidió **Gemini** y **costo cero en todos los ambientes, también en producción**: no se paga nada.

Hay tres decisiones: qué modelo genera las respuestas, cómo se encuentran los fragmentos del manual y qué se usa fuera de producción.

## Opciones

### Modelo que genera las respuestas

1. **Gemini (API de Google).** Tiene nivel gratis sin tarjeta que incluye texto (Flash-Lite y Flash), imágenes y su propio modelo de embeddings, así que un solo proveedor cubre texto, fotos e índice a costo cero. En el nivel gratis Google usa lo enviado para mejorar sus productos; en el de pago no.
2. **Claude (API de Anthropic).** Buena calidad para responder con citas y seguir instrucciones, pero sin nivel gratis permanente para producción y sin modelo de embeddings propio (haría falta un segundo proveedor).
3. **OpenAI.** Texto, imágenes y embeddings en un proveedor, pero de pago. Descartado por el costo cero.
4. **Groq o modelos `:free` de OpenRouter.** Gratis con límites diarios, pero sin embeddings ni (en general) imágenes en el mismo proveedor. Sirven de reserva si la cuota de Gemini no alcanza.

### Cómo se encuentran los fragmentos

1. **Vectores con `pgvector` en Neon.** Cada página tiene su `embedding`; la pregunta se convierte en vector y se buscan las páginas más cercanas **del manual de ese vehículo**. Encuentra páginas aunque el cliente use otras palabras ("la lucecita naranja del motor" contra "testigo de revisión del motor").
2. **Búsqueda de texto completo de PostgreSQL** (`tsvector` en español). Gratis y sin proveedor externo, pero solo encuentra palabras parecidas: falla con sinónimos y frases coloquiales, que es justo como pregunta el cliente.
3. **Las dos juntas.** Vectores como principal y texto completo como respaldo cuando no se puede calcular el vector de la pregunta.

### Fuera de producción

1. **Nivel gratis de Gemini** (proyecto de Google sin facturación). Mismo código y misma API que producción. A cambio, Google **sí usa lo que se le manda en el nivel gratis para mejorar sus productos**, y los límites diarios son bajos y cambian (se consultan por proyecto en Google AI Studio).
2. **Un proveedor falso dentro del backend.** Respuestas fijas y deterministas, sin red ni llave. Es lo único que sirve para pruebas automáticas.
3. **Groq u OpenRouter gratis.** Otra API y otros modelos; obligaría a mantener un segundo adaptador.

## Decisión propuesta

**Costo cero:** se usa el **nivel gratis de Gemini en todos los ambientes**, con un proyecto de Google **sin cuenta de facturación vinculada**. Según los términos de Gemini, el uso solo pasa a ser de pago si el proyecto tiene facturación activa; sin ella, Google no puede cobrar, y al agotarse la cuota del día las llamadas fallan en vez de cobrarse. Nadie del equipo vincula facturación a ese proyecto: hacerlo exige reemplazar esta decisión.

**Modelo:** Gemini detrás de una interfaz `ProveedorIA` del módulo `asistente` del backend, con el modelo elegido por configuración (nunca en el código):

| Uso | Modelo inicial | Por qué |
| --- | --- | --- |
| Preguntas (M24.03) | `gemini-3.5-flash-lite` | El más barato; la respuesta sale de los fragmentos del manual, no del conocimiento del modelo |
| Fotos de testigos (M24.05) | `gemini-3.5-flash-lite` (o `gemini-3.8-flash` si la evaluación lo pide) | Más cuota gratis que Flash; se cambia por configuración |
| Embeddings (M24.02 y M24.03) | `gemini-embedding-2` | Mismo proveedor; la dimensión del vector se fija en la migración |

El backend llama a la API REST de Gemini con el cliente HTTP de Spring (sin SDK, para no sumar dependencias que vigila Trivy). La llave del proyecto del equipo vive en el secreto `gemini-api-key` de Azure, expuesto como `GEMINI_API_KEY`.

**Búsqueda:** opción 3. `pgvector` con índice HNSW por distancia coseno, filtrado por `manual_id`, las 5 páginas más cercanas. Si el vector de la pregunta no se puede calcular (cuota agotada o proveedor caído), se usa la búsqueda de texto completo para no dejar al cliente sin respuesta. Si ninguna página pasa el umbral de parecido, el asistente dice que no lo encontró en el manual.

**Por ambiente:**

| Ambiente | Proveedor | Llave |
| --- | --- | --- |
| Pruebas automáticas (`./mvnw verify`, `flutter test`, CI) | `ProveedorIAFalso`: respuestas fijas con citas, sin red ni llave | Ninguna |
| Backend local de cada quien | Nivel gratis de Gemini, solo manuales de ejemplo y preguntas inventadas | Personal, en `.env` local (fuera de git), de un proyecto propio para no gastar la cuota del backend en Azure |
| Backend en Azure (flavors `pruebas` y `produccion`) | Nivel gratis de Gemini | Del proyecto del equipo sin facturación, en el secreto de Azure |

Se elige por configuración: `asistente.proveedor=gemini|falso`. Si la cuota de Flash-Lite se agota, la reserva es **Gemma 4 31B** (el id exacto del modelo se confirma al programar) con la **misma llave y la misma API**, que tiene mucha más cuota diaria pero menos tokens por minuto; no hace falta un segundo proveedor.

**Lo que cuesta no pagar** (se acepta a sabiendas):

- **Google usa lo que se le manda para mejorar sus productos** (términos del nivel gratis). Por eso al modelo solo le llegan la pregunta ya limpia de datos personales, el modelo y año, y fragmentos del manual (público). El aviso de privacidad (V2-M22.01) lo dice con claridad.
- **Cuota diaria baja y que Google puede cambiar.** Se consulta por proyecto en Google AI Studio. Cuando se agota, el asistente responde `ASISTENTE_NO_DISPONIBLE` hasta el día siguiente (se reinicia a medianoche, hora del Pacífico).
- **Sin garantía de servicio.** Para un proyecto escolar con pocos usuarios alcanza; si algún día tuviera clientes reales en volumen, se reemplaza esta decisión.

## Costo

**$0.** No hay facturación vinculada, así que no hay forma de que llegue un cobro.

Como referencia, por si algún día se decide pagar: precios de la página oficial de Google consultada el 2026-11-23 (dólares por millón de tokens, nivel de pago):

| Modelo | Entrada | Salida |
| --- | --- | --- |
| `gemini-3.5-flash-lite` | $0.30 | $2.50 |
| `gemini-3.8-flash` | $0.75 hasta el 31-dic-2026, $1.50 desde el 1-ene-2027 | $3.75 hasta el 31-dic-2026, $7.50 desde el 1-ene-2027 |
| `gemini-embedding-2` | $0.20 (por confirmar en la página) | — |

Una pregunta lleva unos 3 000 tokens de entrada (instrucciones, 5 páginas del manual y la pregunta) y unos 300 de salida.

| Concepto | Cálculo | Costo |
| --- | --- | --- |
| 1 000 preguntas con Flash-Lite | 3 M × $0.30 + 0.3 M × $2.50 | **≈ $1.65** |
| Lo mismo con Flash (precio 2027) | 3 M × $1.50 + 0.3 M × $7.50 | ≈ $6.75 |
| Vectores de 1 000 preguntas | 50 mil tokens × $0.20 | ≈ $0.01 |
| Indexar un manual de 400 páginas | 200 mil tokens × $0.20 | ≈ $0.04 |

## Límites y fallas

Cuota gratis del proyecto del equipo, leída en Google AI Studio el 2026-11-23 (Google puede cambiarla; se revisa ahí):

| Modelo | Por minuto | Tokens por minuto | Por día |
| --- | --- | --- | --- |
| `gemini-3.5-flash-lite` | 15 | 250 000 | 500 |
| `gemini-embedding-2` | 100 | 30 000 | 1 000 |
| Gemma 4 31B (reserva) | 30 | 16 000 | 14 400 |
| `gemini-3.8-flash` | 5 | 250 000 | 20 |

La cuota es **por proyecto**, compartida por todos los clientes, así que se reparte:

- **Por cliente y por día:** 10 preguntas y 3 fotos. Al pasarse, `ASISTENTE_LIMITE` con la hora en que se libera.
- **Tope global del backend por día:** 450 llamadas a Flash-Lite (90 % de las 500 del día, entre preguntas y fotos). Al llegar, las preguntas pasan a Gemma 4; las fotos responden `ASISTENTE_NO_DISPONIBLE` (Gemma no se usa para fotos). Con 10 preguntas y 3 fotos por cliente, alcanza para unos 35 clientes activos al día.
- **Fotos con Flash-Lite por omisión:** Flash solo da 20 por día. Se pasa a Flash por configuración solo si la evaluación muestra que Flash-Lite no reconoce bien los testigos.
- **Indexar manuales despacio:** los embeddings dan 1 000 por día y 30 000 tokens por minuto (unas 60 páginas por minuto), y las preguntas también gastan uno cada una. El comando de V2-M24.02 indexa como máximo 500 páginas por día, hace pausas para no pasar el límite por minuto y reanuda al día siguiente. Se indexa una sola vez por manual.
- **Proveedor caído, lento o sin cuota:** espera máxima de 20 s y un reintento; luego `ASISTENTE_NO_DISPONIBLE`. La app ofrece llamar a la agencia.

## Privacidad

- **Lo que sale hacia Google:** la pregunta, el modelo y año, y los fragmentos del manual. Antes de enviarla, el backend borra de la pregunta lo que parezca correo, teléfono, VIN o placa, porque el cliente puede escribirlos sin querer.
- **Lo que nunca sale:** nombre, cliente, cuenta ni token.
- **Nivel gratis:** Google puede usar las preguntas, los fragmentos y las respuestas para mejorar sus productos, y personas pueden revisarlos. Por eso nada personal sale del backend y el aviso de privacidad lo dice.
- **Retención:** `consulta_asistente` guarda pregunta, respuesta y fuentes 180 días. La cancelación ARCO (V2-M22.03) las borra antes.
- **Aviso de privacidad:** el de la app (V2-M22.01) dice que las preguntas al asistente se procesan con un servicio de IA de Google que puede usarlas para mejorar sus productos, y que no se deben escribir datos personales.

## Calidad

Umbral para cerrar H6 (V2-M24.07): **al menos 80 %** de las preguntas del conjunto de evaluación con la página correcta entre las citas.

## Consecuencias

- Costo cero garantizado: sin facturación vinculada no hay cobro posible.
- Una sola llave y un solo proveedor para texto, fotos y vectores.
- El asistente puede quedarse sin cuota algún día; la app lo explica y ofrece llamar a la agencia.
- El índice depende del modelo de embeddings: cambiarlo obliga a reindexar todos los manuales. El comando de reindexado de V2-M24.02 lo cubre.
- Los modelos se cambian por configuración. Si Google retira uno o cambia la cuota gratis, se cambia sin tocar código.
- Las pruebas automáticas nunca llaman a un proveedor real: no cuestan y no fallan por cuota.
- Cada quien necesita su propia llave gratis para probar el asistente contra un modelo real en local. Sin llave, el backend local usa el proveedor falso.

## Pendiente antes de aceptar

- ~~Crear el proyecto del equipo sin facturación y anotar su cuota~~: hecho (plan Free, cuota en la tabla de arriba).
- ~~Guardar su llave en el secreto de Azure~~: hecho por el dueño desde su terminal (`gemini-api-key`, expuesto como `GEMINI_API_KEY`).
- ~~Aprobación de SM y PO~~: hecha (SM Daniel en el PR; PO Haziel de palabra, registrada en el PR).
