# M07 · Mensajería con el asesor

| Campo | Valor |
| --- | --- |
| Hito | H4 |
| Dueño | Jael |
| Revisa | Ricardo |
| Ficha técnica | ✅ Sección 7. Mensajería con el asesor |
| Estado | Borrador |

## Propósito

Conversación directa con el asesor de servicio, ligada a la orden o cita, con fotos y audios. Sustituye llamadas y WhatsApp personal. Mueve O3 y O7.

## Pantallas

- **Conversaciones** — una por orden/cita y una general con la agencia.
- **Chat** — texto, fotos, audio, ubicación; indicadores de enviado/leído; respuestas rápidas.

## Datos

| Tabla | Campos | Notas |
| --- | --- | --- |
| `conversacion` ➕ | id, cliente_id, orden_servicio_id, cita_id, asesor_id, estado | |
| `mensaje` ➕ | id, conversacion_id, autor_tipo, autor_id, texto, adjunto_url, enviado_en, leido_en | |

## API (`/api/v1/app`)

| Método | Ruta | Uso |
| --- | --- | --- |
| GET | `/conversaciones` · `/conversaciones/{id}/mensajes?antesDe=` | |
| POST | `/conversaciones/{id}/mensajes` | Texto o adjunto. |
| WS | `/conversaciones/tiempo-real` | Mensajes en vivo (STOMP/WebSocket). |

## Historias

| ID | Historia | Criterios de aceptación | B | Depende de |
| --- | --- | --- | --- | --- |
| V2-M07.01 | Como cliente quiero escribirle a mi asesor sobre mi orden | Conversación ligada a la orden · aparece en el detalle de la orden | ✅ | V2-M04.02 |
| V2-M07.02 | Como cliente quiero recibir respuestas en tiempo real | WebSocket con reconexión · push si la app está cerrada | ✅ | V2-M07.01, V2-M06.02 |
| V2-M07.03 | Como cliente quiero mandar fotos y audios | Compresión antes de subir · límite de tamaño · progreso | ✅ | V2-M07.01 |
| V2-M07.04 | Como cliente quiero saber si mi mensaje fue leído | Doble palomita al leer | ✅ | V2-M07.02 |
| V2-M07.05 | Como cliente quiero escribir sin conexión y que se envíe después | Cola local (M21) con estado "pendiente" | | V2-M21.03 |

## Fuera de alcance / notas

- La bandeja del asesor vive en el ERP (congelado) → dependencia externa; mientras, endpoint interno de respuesta para pruebas.

## Decisiones técnicas (27 de noviembre de 2026)

Tomadas por el frente de la app, por delegación del equipo. La ficha técnica
(sección 7) solo fija las tablas `conversacion` y `mensaje`, así que el
transporte y los adjuntos quedaban abiertos.

### El tiempo real va por el canal SSE que ya existe, no por WebSocket

La tabla de arriba propone `WS /conversaciones/tiempo-real` con STOMP. **Se
descarta.** La app ya tiene un canal de eventos en vivo por SSE:
`GET /eventos` en el contrato, `lib/nucleo/eventos/` con su analizador y su
reconexión, y lo usan taller (V2-M04.03), garantía, lealtad y asistencia.

Un WebSocket con STOMP sería una **segunda** pila de tiempo real: dependencia
nueva en la app, infraestructura nueva en el backend, otra lógica de
reconexión y otro juego de pruebas. Para un chat no compra nada: mandar un
mensaje es un `POST` normal, y lo único que necesita empujarse del servidor al
cliente es el mensaje entrante, que es exactamente lo que SSE hace.

Así que M07.02 agrega un tipo de evento al canal, no un canal.

### Los adjuntos se parten en dos historias

`image_picker` ya es dependencia y cubre fotos (se usa en V2-M24.05 y en la
bitácora). **Las fotos entran sin dependencia nueva.** El audio sí la necesita,
así que M07.03 se parte: fotos primero, audio después, y el audio se decide
cuando toque y no ahora.

La ubicación que menciona la pantalla ya existe en `lib/nucleo/mapas/`.

### Sin conexión reusa la cola de M21.03

M07.05 no construye una segunda cola: usa la de operaciones pendientes de
V2-M21.03, que ya está diseñada con claves de idempotencia. Un mensaje es una
operación encolable como cualquier otra.

### Lo que esto implica para el orden

M07 sigue en H4 y **no se puede programar todavía**: sus cinco historias están
en borrador y cuatro necesitan backend. Lo que estas decisiones quitan de
encima es la parte de infraestructura: ya no hace falta decidir ni construir
una pila de tiempo real.

