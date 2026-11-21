# M04 · Taller en vivo

| Campo | Valor |
| --- | --- |
| Hito | H3 |
| Dueño | Ricardo |
| Revisa | Juan Pablo |
| Ficha técnica | No (extiende `orden_servicio` de la ficha) |
| Estado | Listo para historias |

## Propósito

Que el cliente sepa en todo momento qué le están haciendo a su auto, cuánto falta y cuánto costará, y que apruebe trabajos extra sin llamadas. Mueve O3.

## Pantallas

- **Orden en curso** (tarjeta fija en Inicio) — etapa actual, avance, hora estimada de entrega, asesor.
- **Línea de tiempo** — Recibido → Diagnóstico → Esperando aprobación → En reparación → Control de calidad → Lavado → Listo para entrega → Entregado, con hora de cada paso.
- **Inspección multipunto** — semáforo (verde/amarillo/rojo) por punto revisado con fotos y video del técnico.
- **Aprobación de trabajos adicionales** — cotización por concepto, aprobar/rechazar uno por uno, firma en pantalla.
- **Listo para recoger** — resumen, total, pagar ahora (M08) o en caja.

## Datos

| Tabla | Campos | Notas |
| --- | --- | --- |
| `orden_servicio` (ficha) | id, vehiculo_cliente_id, mano_de_obra, total, estatus, fecha_cierre | ➕ cita_id, asesor_id, entrega_estimada. |
| `etapa_orden` ➕ | id, orden_servicio_id, etapa, inicio, fin, nota | Línea de tiempo. |
| `punto_inspeccion` ➕ | id, orden_servicio_id, punto, resultado, comentario | Multipunto. |
| `evidencia_orden` ➕ | id, orden_servicio_id, punto_inspeccion_id, tipo, url | Fotos/videos (almacenamiento de objetos). |
| `trabajo_adicional` ➕ | id, orden_servicio_id, concepto, mano_de_obra, refacciones, total, estado, respondido_en, firma_url | pendiente/aprobado/rechazado. |

## API (`/api/v1/app`)

| Método | Ruta | Uso |
| --- | --- | --- |
| GET | `/ordenes/activas` | Órdenes abiertas del cliente. |
| GET | `/ordenes/{id}` | Detalle con etapas, inspección y adicionales. |
| GET | `/ordenes/{id}/eventos` (SSE) | Cambios en vivo; respaldo con push (M06). |
| POST | `/ordenes/{id}/adicionales/{aid}/respuesta` | Aprobar o rechazar con firma. |

## Historias

| ID | Historia | Criterios de aceptación | B | Depende de |
| --- | --- | --- | --- | --- |
| V2-M04.01 | Como cliente quiero ver en Inicio que mi auto está en el taller | Tarjeta aparece si hay orden abierta · desaparece al entregarse | ✅ | V2-M02.05 |
| V2-M04.02 | Como cliente quiero la línea de tiempo de mi orden con la hora de cada etapa | Etapas en orden con hora · etapa actual animada · ETA visible | ✅ | V2-M04.01 |
| V2-M04.03 | Como cliente quiero que la línea de tiempo se actualice sola | Cambio de etapa aparece sin recargar (SSE) · si la app está cerrada llega push | ✅ | V2-M04.02, V2-M06.02 |
| V2-M04.04 | Como cliente quiero ver la inspección multipunto con fotos | Semáforo por punto · fotos ampliables · video reproducible | ✅ | V2-M04.02 |
| V2-M04.05 | Como cliente quiero aprobar o rechazar trabajos adicionales desde la app | Cotización por concepto · aprobar/rechazar uno por uno · firma en pantalla · total se recalcula · auditoría en backend | ✅ | V2-M04.02 |
| V2-M04.06 | Como cliente quiero saber cuándo mi auto está listo | Push + tarjeta "Listo" con total y horario de entrega | ✅ | V2-M04.03 |
| V2-M04.07 | Como cliente quiero que la orden cerrada pase a mi historial con su ticket | Al cerrar, aparece en historial (M02) con ticket | ✅ | V2-M04.06 |

## Fuera de alcance / notas

- Captura de etapas y evidencias la hace el taller desde el ERP (congelado) → **dependencia externa**: mientras tanto, endpoints internos y datos de ejemplo en backend.
