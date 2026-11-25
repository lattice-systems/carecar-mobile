# M04 · Taller en vivo

| Campo | Valor |
| --- | --- |
| Hito | H3 |
| Dueño | Ricardo |
| Revisa | Juan Pablo |
| Ficha técnica | ✅ Sección 4. Taller en vivo |
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
| V2-M04.02 | Como cliente quiero la línea de tiempo de mi orden con la hora de cada etapa | Etapas en orden con hora · etapa actual animada · ETA visible | ✅ | V2-M04.01, V2-T02.13 |
| V2-M04.03 | Como cliente quiero que la línea de tiempo se actualice sola | Cambio de etapa aparece sin recargar (SSE) · si la app está cerrada llega push | ✅ | V2-M04.02, V2-M06.02 |
| V2-M04.04 | Como cliente quiero ver la inspección multipunto con fotos | Semáforo por punto · fotos ampliables · video reproducible | ✅ | V2-M04.02 |
| V2-M04.05 | Como cliente quiero aprobar o rechazar trabajos adicionales desde la app | Cotización por concepto · aprobar/rechazar uno por uno · firma en pantalla · total se recalcula · auditoría en backend | ✅ | V2-M04.02 |
| V2-M04.06 | Como cliente quiero saber cuándo mi auto está listo | Push + tarjeta "Listo" con total y horario de entrega | ✅ | V2-M04.03 |
| V2-M04.07 | Como cliente quiero que la orden cerrada pase a mi historial con su ticket | Al cerrar, aparece en historial (M02) con ticket | ✅ | V2-M04.06 |

## Avance

**Lote D (V2-M04.01, V2-M04.02, V2-M04.04 y V2-M04.05) · Hecha.** Backend en `agencia-360-backend` (diseño en `plan/historias-backend.md`, contrato v2 2.8.0). App en `lib/modulos/taller/`:

- **Inicio (V2-M04.01):** `TarjetaOrdenEnCurso` dice que el auto está en el taller con la etapa, la entrega estimada, la barra de avance y cuántos trabajos esperan respuesta. Solo aparece con una orden sin entregar; si falla o la orden se entrega, no ocupa lugar. Al tocarla abre `/taller/:ordenId` y al volver se recarga. Va en Inicio v1 (`lib/pantallas/pantalla_inicio.dart`) en un PR aparte (#111), porque esa pantalla no es de este módulo.
- **Línea de tiempo (V2-M04.02):** `/taller/:ordenId` con la etapa actual, su avance, la entrega estimada y el asesor; la `LineaDeTiempo` del sistema con la hora de cada etapa recorrida y las que faltan (la actual respira y lleva la entrega estimada). Las etapas que el taller salta no aparecen. Un aviso lleva a los trabajos por aprobar.
- **Inspección (V2-M04.04):** `/taller/:ordenId/inspeccion` con un `Semaforo` por punto, sus fotos en `GaleriaFotos` (zoom al tocar) y sus videos, que se abren en el reproductor del teléfono; al final, las fotos y videos de la orden. Las URL vencen a los 15 minutos: jalar para recargar las renueva.
- **Adicionales (V2-M04.05):** `/taller/:ordenId/adicionales` con la cotización de cada trabajo (mano de obra, refacciones y total), aprobar o rechazar uno por uno con la firma en pantalla y los totales (orden, aprobados, por aprobar y estimado) que devuelve el backend. La firma usa `LienzoFirmaProvisional` (`presentacion/provisional/`): el sistema solo tiene `Firma` de lectura (V2-T02.12); falta la historia del componente para capturarla.
- **Datos:** `RepositorioTallerApi` con el cliente del núcleo (sin caché) y `RepositorioTallerFake` con la orden de ejemplo; `mock_api` sirve la orden 41 de `cliente1` con fotos de prueba.
- **Pruebas:** `test/modulos/taller/` (dominio y lectura del contrato, repositorio, las tres pantallas, la tarjeta y las rutas), `test/pantallas/inicio_taller_test.dart` y `test/contrato/contrato_taller_test.dart`.

Mientras el ERP siga congelado, el taller abre la orden, la pasa de etapa, registra la inspección y propone adicionales con las rutas `/api/v1/taller/ordenes/...` del backend (rol `SERVICIO`).

**Lote E (V2-M04.03, V2-M04.06 y V2-M04.07) · Hecha.** Backend con diseño en `plan/historias-backend.md` y contrato v2 2.17.0 (`AvisoOrden` con `etapa` y `motivo`, `HorarioEntrega`, `totalEstimado` en `OrdenEnCurso`, `POST /api/v1/taller/ordenes/{id}/renglones`). App:

- **En vivo (V2-M04.03):** usa el canal de eventos del núcleo (`eventosProvider`, `lib/nucleo/eventos/`), que ya abre `GET /eventos`, se reconecta y avisa `conexion.restablecida`. La tarjeta de Inicio y la orden abierta se vuelven a pedir con el aviso `orden` (la orden, solo si es la suya) o al volver el canal, sin pasar por carga; si esa recarga falla, se queda lo que se ve. No hay ruta de eventos por orden: el backend avisa todas las del cliente. El push con la app cerrada lo manda `notificaciones` (V2-M06.07) escuchando el mismo `OrdenServicioCambiada` del backend; mientras no se integre, solo se avisa con la app abierta.
- **Listo (V2-M04.06):** la tarjeta de Inicio cambia a «Tu … está listo» con el total a pagar, el horario para recogerlo (el primer día con horario del taller en `franja_horario`, de la primera a la última hora) y la insignia «Listo para entrega». La orden lo avisa arriba y muestra el total a pagar. El push «tu auto está listo» es el mismo de V2-M04.03 con `motivo = ETAPA` y `etapa = LISTO_PARA_ENTREGA`.
- **Historial (V2-M04.07):** al quedar lista, el backend pasa los adicionales aprobados a renglones de la orden (`trabajo_adicional.incorporado_en`), así el ticket trae lo que se hizo y el total no se cuenta dos veces. Lista o entregada, la orden abre «Ver ticket» (`rutaTicketServicio` del historial, mismo id) y entregada abre también el historial del vehículo.
- **mock_api:** el aviso `orden` sale por el canal de eventos del simulador y `POST /__mock/ordenes/{id}/etapa` hace de taller: pasar la orden 41 a `LISTO_PARA_ENTREGA` la avisa en vivo y la deja en el historial con su ticket.
- **Pruebas:** en `test/modulos/taller/`, la lectura de `totalEstimado` y `horarioEntrega`, la tarjeta «Listo» y su cambio en vivo, la orden lista y entregada, la recarga en vivo (solo de su orden, al volver el canal y sin perder lo que se ve si falla) y las rutas al ticket y al historial; en `test/contrato/contrato_taller_test.dart`, `AvisoOrden` y `HorarioEntrega`.

## Fuera de alcance / notas

- Captura de etapas y evidencias la hace el taller desde el ERP (congelado) → **dependencia externa**: mientras tanto, endpoints internos y datos de ejemplo en backend.
