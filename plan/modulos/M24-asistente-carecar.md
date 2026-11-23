# M24 · Asistente CareCar (IA)

| Campo | Valor |
| --- | --- |
| Hito | H6 (se adelanta por decisión del dueño: no bloquea H1–H5) |
| Dueño | Daniel |
| Revisa | Cristian |
| Ficha técnica | ✅ Sección 21. Asistente CareCar (IA) |
| Estado | Lista (refinado) |

## Propósito

Un asistente que contesta preguntas del cliente **con base en el manual de su modelo y año** (citando la página), identifica testigos del tablero por foto y lleva a la acción (agendar, llamar SOS). Mueve O4.

## Pantallas

- **Pregúntale a tu auto** — chat con respuestas citadas ("Manual, pág. 214") y botón para abrir el PDF en esa página. Se entra desde el detalle del vehículo (cada conversación es de **un** vehículo).
- **¿Qué significa esta luz?** — cámara → testigo identificado → gravedad → qué hacer → agendar.
- **Sugerencias** — preguntas frecuentes al abrir el chat vacío.

## Datos

| Tabla | Campos | Notas |
| --- | --- | --- |
| `fragmento_manual` ➕ | id, manual_id, pagina, texto, embedding | Índice de búsqueda por página. Cómo se llena `embedding` (y con qué modelo) lo fija el ADR de V2-M24.01. |
| `consulta_asistente` ➕ | id, cliente_id, vehiculo_cliente_id, pregunta, respuesta, fuentes (json), util (bool) | Sin datos personales en el prompt. `fuentes` = lista de `{manual_id, pagina}`. |

## API (`/api/v1/app`)

| Método | Ruta | Uso |
| --- | --- | --- |
| POST | `/asistente/preguntas` | Respuesta con fuentes. Primero completa (V2-M24.03); en streaming con V2-M24.09. |
| POST | `/asistente/testigos` | Imagen → testigo identificado. |
| POST | `/asistente/consultas/{id}/calificacion` | 👍/👎 |

Errores nuevos del contrato (en el `Problema`): `ASISTENTE_LIMITE` (se pasó del límite de preguntas del día), `ASISTENTE_SIN_MANUAL` (el vehículo no tiene manual indexado), `ASISTENTE_NO_DISPONIBLE` (el proveedor de IA no responde).

## Reglas del módulo

- **La llamada al modelo siempre sale del backend.** La app nunca tiene llaves de IA; la llave vive en un secreto de Azure.
- **Sin datos personales en el prompt**: solo la pregunta, el modelo/año y los fragmentos del manual. Nada de nombre, correo, teléfono, VIN ni placas.
- **No inventa**: si no hay fragmentos relevantes del manual de ese vehículo, la respuesta lo dice y ofrece hablar con la agencia.
- **Aviso visible** en cada pantalla del asistente: "Respuestas generadas con IA a partir de tu manual. Ante una falla, consulta a tu asesor."
- Cinco estados resueltos (cargando, datos, vacío, error con reintento, sin conexión). Sin conexión el asistente no funciona y lo dice.

## Historias

| ID | Historia | Criterios de aceptación | B | Depende de |
| --- | --- | --- | --- | --- |
| V2-M24.01 | Como equipo queremos elegir el proveedor de modelo y la arquitectura RAG para que el asistente sea útil, barato y respete la privacidad | ADR `docs/decisiones/0007-asistente-ia.md` que compara al menos dos opciones de modelo y dos de búsqueda (vectores con `pgvector` en Neon contra búsqueda de texto completo de Postgres por página) · costo estimado por 1 000 preguntas y tope mensual · privacidad: qué datos salen, retención del proveedor y que no entrena con ellos · la llamada corre solo en el backend con la llave en un secreto de Azure · límite de preguntas por cliente por día · qué pasa si el proveedor se cae · cómo se llena `fragmento_manual.embedding` · aprobado por SM y PO en el PR | | — |
| V2-M24.02 | Como equipo queremos indexar los manuales por página para que el asistente busque solo en el manual correcto y pueda citar la página | Al registrar o cambiar `manual.archivo_pdf` se extrae el texto de cada página a `fragmento_manual` (`manual_id`, `pagina`, `texto`, `embedding` según el ADR) · reindexar el mismo manual no duplica fragmentos · un PDF escaneado sin texto queda marcado "sin texto" y no rompe el proceso · comando de administración para indexar los manuales que ya existen · prueba con un PDF de ejemplo de 3 páginas | ✅ | V2-M24.01, V2-T05.05 |
| V2-M24.03 | Como cliente quiero preguntar algo de mi auto y recibir una respuesta citada para resolver dudas sin buscar en el manual | Pantalla "Pregúntale a tu auto" desde el detalle del vehículo · solo usa fragmentos del manual de ese vehículo (modelo y año) · cada respuesta trae al menos una cita `{manual_id, pagina}` que se ve como "Manual, pág. N" · si no está en el manual lo dice sin inventar y ofrece llamar a la agencia · `ASISTENTE_SIN_MANUAL` y `ASISTENTE_LIMITE` con mensaje propio · se guarda en `consulta_asistente` · prompt sin datos personales (prueba que lo verifica en el backend) · aviso de IA visible · cinco estados · contrato y `mock_api` con respuestas de ejemplo | ✅ | V2-M24.02 (simulable), V2-T02.15 (provisional) |
| V2-M24.04 | Como cliente quiero abrir el manual en la página citada para comprobar la respuesta | Tocar una cita abre el manual en esa página · `VisorPdf` acepta `paginaInicial` (cambio al sistema de diseño con su prueba) · si el PDF no carga, error con reintento · el lector de pantalla anuncia "Manual, página N, abrir" | | V2-M24.03, V2-M02.03 |
| V2-M24.05 | Como cliente quiero fotografiar una luz del tablero y saber qué significa para decidir si puedo seguir manejando | Cámara o galería · la foto viaja sin EXIF ni ubicación y no se guarda en el teléfono · respuesta: nombre del testigo, gravedad (roja, amarilla, informativa), qué hacer y cita del manual si existe · roja: aviso de detenerse y botón SOS (M11.01; mientras no esté, llamar a la agencia) · si no la reconoce lo dice y propone describirla por texto · permiso de cámara denegado explicado con salida a ajustes · cinco estados | ✅ | V2-M24.01, V2-T02.15 (provisional) |
| V2-M24.06 | Como cliente quiero agendar desde la respuesta para atender el problema sin volver a explicarlo | Botón "Agendar revisión" en la respuesta y en un testigo rojo o amarillo · abre Agendar cita con el vehículo elegido y el motivo precargado (editable) · prueba de navegación con los datos precargados | | V2-M24.03, V2-M02.08 |
| V2-M24.07 | Como equipo queremos medir la calidad de respuestas para saber si el asistente ayuda y mejorarlo | 👍/👎 en cada respuesta guarda `util` en `consulta_asistente` · conjunto de evaluación de al menos 20 preguntas por modelo con su página esperada en `docs/asistente/evaluacion/` · script que corre el conjunto y reporta el % de respuestas con la cita correcta · umbral mínimo acordado en el ADR antes de cerrar H6 | ✅ | V2-M24.03 |
| V2-M24.08 | Como cliente quiero ver preguntas sugeridas para empezar sin saber qué escribir | Con la conversación vacía se muestran de 4 a 6 sugerencias con `ChipPista` · tocar una la envía como pregunta · lista genérica en la app (mantenimiento, presión de llantas, testigos, capacidad de aceite) · textos traducidos (M20) | | V2-M24.03 |
| V2-M24.09 | Como cliente quiero ver la respuesta mientras se escribe para no esperar en blanco | `POST /asistente/preguntas` responde en streaming (SSE) y las citas llegan al final · la app pinta el texto por partes y anuncia al lector de pantalla solo la respuesta completa · cortar la conexión a la mitad deja la respuesta parcial marcada con opción de reintentar | ✅ | V2-M24.03 |

## Avance de V2-M24.01

ADR [0007](../../docs/decisiones/0007-asistente-ia.md) en `Propuesta`:

- **Costo cero en todos los ambientes:** nivel gratis de Gemini con un proyecto **sin facturación**, así que no hay cobro posible.
- **Modelos:** detrás de `ProveedorIA` en el backend, elegidos por configuración. Flash-Lite para preguntas y fotos, y `gemini-embedding-2` para el índice.
- **Búsqueda:** `pgvector` en Neon, filtrada por manual, con texto completo de respaldo.
- **Pruebas automáticas:** proveedor falso, sin red.
- **Precio de no pagar:**
  - Google puede usar lo enviado para mejorar sus productos; por eso nada personal sale del backend y el aviso de privacidad lo dice.
  - La cuota diaria es compartida, así que hay límite de 10 preguntas y 3 fotos por cliente, más un tope global.
- **Calidad:** al menos 80 % de citas correctas.

Falta para aceptarlo: crear el proyecto del equipo sin facturación, anotar su cuota y la aprobación de SM y PO.

## Componentes que faltan

- **V2-T02.15 · `BurbujaMensaje` y `CampoMensaje`** (sistema de diseño): burbuja de mensaje propia y ajena con fuentes opcionales al pie, y campo de escritura con botón de enviar y adjuntar. Los usa este módulo y M07 (mensajería con el asesor). Mientras no se integre, las pantallas usan un provisional en `lib/modulos/asistente/presentacion/provisional/`.

## Orden sugerido

1. V2-M24.01 (ADR): define proveedor, búsqueda y costos. Sin esto no se programa nada del backend.
2. V2-M24.03 contra `mock_api` (la app avanza sin esperar el backend) en paralelo con V2-M24.02 en el backend.
3. V2-M24.04, V2-M24.06 y V2-M24.08 (solo app).
4. V2-M24.05, V2-M24.07 y V2-M24.09.

## Cumplimiento de la ficha

Mueve las dos filas de la sección 21 en [`../cumplimiento-ficha.md`](../cumplimiento-ficha.md): "Preguntas sobre el manual del vehículo" con V2-M24.02 y V2-M24.03, e "Identificación de testigos del tablero" con V2-M24.05.
