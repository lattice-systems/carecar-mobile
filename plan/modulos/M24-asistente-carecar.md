# M24 · Asistente CareCar (IA)

| Campo | Valor |
| --- | --- |
| Hito | H6 |
| Dueño | Daniel |
| Revisa | Cristian |
| Ficha técnica | ✅ Sección 21. Asistente CareCar (IA) |
| Estado | Borrador |

## Propósito

Un asistente que contesta preguntas del cliente **con base en el manual de su modelo y año** (citando la página), identifica testigos del tablero por foto y lleva a la acción (agendar, llamar SOS). Mueve O4.

## Pantallas

- **Pregúntale a tu auto** — chat con respuestas citadas ("Manual, pág. 214") y botón para abrir el PDF en esa página.
- **¿Qué significa esta luz?** — cámara → testigo identificado → gravedad → qué hacer → agendar.
- **Sugerencias** — preguntas frecuentes por modelo.

## Datos

| Tabla | Campos | Notas |
| --- | --- | --- |
| `fragmento_manual` ➕ | id, manual_id, pagina, texto, embedding | Índice de búsqueda semántica (pgvector). |
| `consulta_asistente` ➕ | id, cliente_id, vehiculo_cliente_id, pregunta, respuesta, fuentes (json), util (bool) | Sin datos personales en el prompt. |

## API (`/api/v1/app`)

| Método | Ruta | Uso |
| --- | --- | --- |
| POST | `/asistente/preguntas` | Respuesta en streaming con fuentes. |
| POST | `/asistente/testigos` | Imagen → testigo identificado. |
| POST | `/asistente/consultas/{id}/calificacion` | 👍/👎 |

## Historias

| ID | Historia | Criterios de aceptación | B | Depende de |
| --- | --- | --- | --- | --- |
| V2-M24.01 | Como equipo queremos elegir el proveedor de modelo y la arquitectura RAG | ADR: proveedor, costo, privacidad, dónde corre la llamada (siempre backend, nunca llave en la app) | | — |
| V2-M24.02 | Como equipo queremos indexar los manuales por página | Al subir un manual se extrae texto por página y se generan embeddings | ✅ | V2-M24.01 |
| V2-M24.03 | Como cliente quiero preguntar algo de mi auto y recibir una respuesta citada | Solo usa el manual de su modelo/año · cada respuesta cita páginas · si no está en el manual, lo dice | ✅ | V2-M24.02 |
| V2-M24.04 | Como cliente quiero abrir el manual en la página citada | Toque en la cita abre el visor en esa página | | V2-M24.03, V2-M02.03 |
| V2-M24.05 | Como cliente quiero fotografiar una luz del tablero y saber qué significa | Identificación con gravedad · si es roja sugiere detenerse y SOS (M11) | ✅ | V2-M24.01 |
| V2-M24.06 | Como cliente quiero agendar desde la respuesta | Botón precarga motivo en Agendar cita | | V2-M24.03 |
| V2-M24.07 | Como equipo queremos medir la calidad de respuestas | Calificación 👍/👎 y conjunto de preguntas de evaluación por modelo | ✅ | V2-M24.03 |
