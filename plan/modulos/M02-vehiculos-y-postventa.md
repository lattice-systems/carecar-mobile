# M02 · Mis vehículos y postventa

| Campo | Valor |
| --- | --- |
| Hito | H2 |
| Dueño | Juan Pablo (garaje, manuales, citas) · Ricardo (historial, tickets) |
| Revisa | Cristian |
| Ficha técnica | ✅ Módulo 2 (APP-3.1, APP-3.2, APP-3.3) |
| Estado | Listo para historias |

## Propósito

El corazón de la app: el garaje del cliente, todo lo que se le ha hecho a cada auto y la forma más fácil de volver al taller. Mueve O1, O2 y O4.

## Pantallas

- **Garaje** — tarjetas grandes con foto del modelo/color, placas, km, próximo servicio y cita activa; deslizable si hay varios autos.
- **Detalle del vehículo** — encabezado con foto, VIN copiable, placas, año, km; pestañas: Resumen · Historial · Manuales · Ficha técnica.
- **Ficha técnica** — especificaciones por modelo y año en secciones plegables.
- **Manual** — visor PDF con índice, búsqueda, zoom, descarga y compartir; respaldo local si no hay red.
- **Historial** — línea de tiempo infinita (paginada) con filtro por año y tipo, total por orden.
- **Ticket** — desglose mano de obra + refacciones = total; PDF descargable y compartible.
- **Agendar cita** — elige vehículo → fecha (calendario con días llenos marcados) → franja con cupo → motivo → confirmar.
- **Mis citas** — próximas y pasadas con estado (confirmada, atendida, no asistió, cancelada); cancelar; agregar al calendario.
- **Comprobante de cita** — código QR para recepción en el taller.

## Datos

Tablas de la ficha: `vehiculo_cliente`, `manual`, `orden_servicio`, `orden_refaccion`, `franja_horario`, `cita` (ver alineación en T05). Extensiones:

| Tabla | Campos | Notas |
| --- | --- | --- |
| `cita` ➕ | motivo, comentario, codigo_qr | Motivo del servicio (mantenimiento, ruido, revisión…). |
| `ficha_tecnica_modelo` ➕ | id, modelo, anio, seccion, clave, valor | Especificaciones por modelo y año (hoy viven en la app). |

## API (`/api/v1/app`)

| Método | Ruta | Uso |
| --- | --- | --- |
| GET | `/vehiculos` · `/vehiculos/{id}/manuales` | Existen. |
| GET | `/vehiculos/{id}/ficha-tecnica` | Nuevo. |
| GET | `/vehiculos/{id}/servicios?pagina=&anio=` | Existe; se usa paginación completa. |
| GET | `/servicios/{id}` · `/servicios/{id}/ticket` | Detalle nuevo; ticket existe. |
| GET | `/agenda/disponibilidad?desde=&hasta=` | Existe; rango de fechas. |
| GET/POST | `/citas` · POST `/citas/{id}/cancelar` | Existen; POST suma `motivo`. |
| GET | `/citas/{id}/comprobante` | Nuevo (QR + PDF). |

## Historias

| ID | Historia | Criterios de aceptación | B | Depende de |
| --- | --- | --- | --- | --- |
| V2-M02.01 | Como cliente quiero ver mi garaje con todos mis vehículos para elegir uno | Tarjeta por vehículo con modelo, año, placas, km · vacío explica que la agencia registra los autos al entregarlos · sin conexión muestra lo guardado | | V2-T01.02, V2-T02.05 |
| V2-M02.02 | Como cliente quiero el detalle de un vehículo para ver sus datos y kilometraje | VIN copiable · km "actualizado por el taller el <fecha de cierre>" · accesos a historial, manuales, ficha | | V2-M02.01 |
| V2-M02.03 | Como cliente quiero abrir el manual de mi modelo y año para consultarlo | Se asocia por modelo y año · índice, búsqueda, zoom · descarga y compartir · respaldo local | | V2-M02.02 |
| V2-M02.04 | Como cliente quiero la ficha técnica de mi vehículo para conocer sus especificaciones | Datos desde la API por modelo/año · secciones plegables · respaldo local mientras el backend no los tenga | ✅ | V2-M02.02 |
| V2-M02.05 | Como cliente quiero el historial de servicios de mi auto para saber qué se le ha hecho | Paginación infinita · filtro por año · cada orden muestra fecha de cierre, estatus y total | | V2-T05.06 |
| V2-M02.06 | Como cliente quiero el ticket de cada servicio para revisar el cobro | Mano de obra + refacciones (cantidad × precio) = total · PDF descargable/compartible | | V2-M02.05 |
| V2-M02.07 | Como cliente quiero ver la disponibilidad del taller en un calendario para elegir día | Días sin cupo deshabilitados · cupo por franja y fecha según `franja_horario.capacidad` | | V2-T05.07 |
| V2-M02.08 | Como cliente quiero agendar una cita eligiendo vehículo, fecha, franja y motivo | Confirmación con resumen · 409 por cupo lleno → ofrece franjas cercanas · 409 por cita duplicada → muestra la existente | ✅ | V2-M02.07 |
| V2-M02.09 | Como cliente quiero ver mis citas próximas y pasadas con su estado | Estados confirmada/atendida/no asistió/cancelada con color y texto · paginación | | V2-M02.08 |
| V2-M02.10 | Como cliente quiero cancelar una cita desde la app | Confirmación con diálogo · solo citas confirmadas futuras · libera el cupo | | V2-M02.09 |
| V2-M02.11 | Como cliente quiero un comprobante con QR de mi cita para recepción rápida | QR con id firmado · PDF · agregable a Wallet (M25) | ✅ | V2-M02.08 |
| V2-M02.12 | Como cliente quiero agregar la cita a mi calendario del teléfono | Evento con dirección del taller y recordatorio | | V2-M02.08 |
| V2-M02.13 | Como cliente quiero reprogramar una cita sin cancelarla | Elige nueva franja; la anterior se libera en la misma operación | ✅ | V2-M02.10 |

## Fuera de alcance / notas

- La orden de servicio la crea y cierra el taller desde el ERP (congelado); la app solo lee. El estado en vivo es M04.
