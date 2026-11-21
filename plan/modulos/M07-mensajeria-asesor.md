# M07 · Mensajería con el asesor

| Campo | Valor |
| --- | --- |
| Hito | H4 |
| Dueño | Jael |
| Revisa | Ricardo |
| Ficha técnica | No |
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
