# 0007 · Proveedor de IA y búsqueda en manuales del asistente

**Estado:** Propuesta

Historia: [V2-M24.01](../../plan/modulos/M24-asistente-carecar.md).

## Contexto

El asistente (M24) contesta preguntas con base en el manual del modelo y año del cliente, citando la página, e identifica testigos del tablero por foto. La ficha (sección 21) pide las tablas `fragmento_manual` (`id`, `manual_id`, `pagina`, `texto`, `embedding`) y `consulta_asistente`.

Restricciones que ya fija el módulo M24:

- La llamada al modelo **solo sale del backend**; la app nunca tiene llaves de IA.
- **Sin datos personales en el prompt**: solo la pregunta, el modelo y año, y fragmentos del manual.
- Si el manual no tiene la respuesta, el asistente lo dice; no inventa.
- Límite de preguntas por cliente al día (`ASISTENTE_LIMITE`) y error propio si el proveedor no responde (`ASISTENTE_NO_DISPONIBLE`).

El backend corre en Azure Container Apps con PostgreSQL en Neon. El dueño y el equipo pidieron **Gemini en producción** y **una opción gratis para pruebas**.

Hay tres decisiones: qué modelo genera las respuestas, cómo se encuentran los fragmentos del manual y qué se usa fuera de producción.

## Opciones

### Modelo que genera las respuestas

1. **Gemini (API de Google, nivel de pago).** Hay un modelo de texto barato (Flash-Lite) y uno más capaz (Flash), los dos aceptan imágenes y Google tiene su propio modelo de embeddings, así que un solo proveedor cubre texto, fotos e índice. En el nivel de pago Google no usa los prompts ni las respuestas para mejorar sus productos.
2. **Claude (API de Anthropic).** Buena calidad para responder con citas y seguir instrucciones. No ofrece un modelo de embeddings propio: haría falta un segundo proveedor para el índice (dos llaves, dos contratos).
3. **OpenAI.** Texto, imágenes y embeddings en un proveedor. Sin ventaja clara sobre Gemini para este caso y el equipo ya eligió Gemini.
4. **Groq o modelos `:free` de OpenRouter.** Gratis con límites diarios, pensados para desarrollo, no para producción. Sirven de reserva para pruebas.

### Cómo se encuentran los fragmentos

1. **Vectores con `pgvector` en Neon.** Cada página tiene su `embedding`; la pregunta se convierte en vector y se buscan las páginas más cercanas **del manual de ese vehículo**. Encuentra páginas aunque el cliente use otras palabras ("la lucecita naranja del motor" contra "testigo de revisión del motor").
2. **Búsqueda de texto completo de PostgreSQL** (`tsvector` en español). Gratis y sin proveedor externo, pero solo encuentra palabras parecidas: falla con sinónimos y frases coloquiales, que es justo como pregunta el cliente.
3. **Las dos juntas.** Vectores como principal y texto completo como respaldo cuando no se puede calcular el vector de la pregunta.

### Fuera de producción

1. **Nivel gratis de Gemini** (proyecto de Google sin facturación). Mismo código y misma API que producción. A cambio, Google **sí usa lo que se le manda en el nivel gratis para mejorar sus productos**, y los límites diarios son bajos y cambian (se consultan por proyecto en Google AI Studio).
2. **Un proveedor falso dentro del backend.** Respuestas fijas y deterministas, sin red ni llave. Es lo único que sirve para pruebas automáticas.
3. **Groq u OpenRouter gratis.** Otra API y otros modelos; obligaría a mantener un segundo adaptador.

## Decisión propuesta

**Modelo:** Gemini en producción, detrás de una interfaz `ProveedorIA` del módulo `asistente` del backend, con el modelo elegido por configuración (nunca en el código):

| Uso | Modelo inicial | Por qué |
| --- | --- | --- |
| Preguntas (M24.03) | `gemini-3.5-flash-lite` | El más barato; la respuesta sale de los fragmentos del manual, no del conocimiento del modelo |
| Fotos de testigos (M24.05) | `gemini-3.8-flash` | Reconocer un ícono en una foto pide más capacidad |
| Embeddings (M24.02 y M24.03) | `gemini-embedding-2` | Mismo proveedor; la dimensión del vector se fija en la migración |

El backend llama a la API REST de Gemini con el cliente HTTP de Spring (sin SDK, para no sumar dependencias que vigila Trivy). La llave vive en el secreto `gemini-api-key` de Azure, expuesto como `GEMINI_API_KEY`.

**Búsqueda:** opción 3. `pgvector` con índice HNSW por distancia coseno, filtrado por `manual_id`, las 5 páginas más cercanas. Si el vector de la pregunta no se puede calcular (cuota agotada o proveedor caído), se usa la búsqueda de texto completo para no dejar al cliente sin respuesta. Si ninguna página pasa el umbral de parecido, el asistente dice que no lo encontró en el manual.

**Fuera de producción** (pedido del equipo: gratis):

| Ambiente | Proveedor | Datos permitidos |
| --- | --- | --- |
| Pruebas automáticas (`./mvnw verify`, `flutter test`, CI) | `ProveedorIAFalso`: respuestas fijas con citas, sin red ni llave | Ninguno real |
| Backend local de cada quien | Nivel gratis de Gemini: proyecto de Google **sin facturación** y llave personal en `.env` local (fuera de git) | **Solo manuales de ejemplo y preguntas inventadas**, nunca datos de clientes, porque el nivel gratis se usa para entrenar |
| Backend en Azure (lo usan los flavors `pruebas` y `produccion`) | Gemini de pago, proyecto con facturación | Datos reales |

Si los límites del nivel gratis de Gemini no alcanzan para desarrollar, la reserva es Groq con un adaptador compatible con la API de OpenAI, solo en local. Se elige por configuración: `asistente.proveedor=gemini|falso`.

## Costo estimado

Precios de la página oficial de Google consultada el 2026-11-23 (dólares por millón de tokens, nivel estándar de pago):

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

Las fotos se cobran como tokens de entrada; el costo por foto se mide con las primeras pruebas y se anota aquí antes de aceptar esta decisión.

**Tope:** alerta de presupuesto en Google Cloud a 10 dólares al mes. Con el límite por cliente (abajo) eso alcanza para miles de preguntas.

## Límites y fallas

- **Por cliente y por día:** 20 preguntas y 5 fotos. Al pasarse, `ASISTENTE_LIMITE` con la hora en que se libera.
- **Proveedor caído o lento:** espera máxima de 20 s y un reintento; luego `ASISTENTE_NO_DISPONIBLE`. La app ofrece llamar a la agencia. No hay un segundo proveedor en producción.

## Privacidad

- **Lo que sale hacia Google:** la pregunta, el modelo y año, y los fragmentos del manual. Antes de enviarla, el backend borra de la pregunta lo que parezca correo, teléfono, VIN o placa, porque el cliente puede escribirlos sin querer.
- **Lo que nunca sale:** nombre, cliente, cuenta ni token.
- **En el nivel de pago:** Google no usa prompts ni respuestas para mejorar sus productos.
- **En el nivel gratis:** sí los usa, y por eso ahí solo van datos inventados.
- **Retención:** `consulta_asistente` guarda pregunta, respuesta y fuentes 180 días. La cancelación ARCO (V2-M22.03) las borra antes.
- **Aviso de privacidad:** el de la app (V2-M22.01) menciona el uso de un proveedor de IA.

## Calidad

Umbral para cerrar H6 (V2-M24.07): **al menos 80 %** de las preguntas del conjunto de evaluación con la página correcta entre las citas.

## Consecuencias

- Una sola llave y un solo proveedor para texto, fotos y vectores.
- El índice depende del modelo de embeddings: cambiarlo obliga a reindexar todos los manuales. El comando de reindexado de V2-M24.02 lo cubre.
- Los modelos se cambian por configuración. Si Google retira uno o sube su precio, se cambia sin tocar código.
- Las pruebas automáticas nunca llaman a un proveedor real: no cuestan y no fallan por cuota.
- Cada quien necesita su propia llave gratis para probar el asistente contra un modelo real en local. Sin llave, el backend local usa el proveedor falso.

## Pendiente antes de aceptar

- Confirmar en la página oficial el precio de `gemini-embedding-2` y medir el costo de una foto.
- Crear el proyecto de Google con facturación y la alerta de presupuesto (lo hace el dueño; la llave va directo al secreto de Azure, nunca al chat ni al repo).
