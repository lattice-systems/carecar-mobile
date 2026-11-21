# M05 · Mantenimiento inteligente

| Campo | Valor |
| --- | --- |
| Hito | H3 |
| Dueño | Juan Pablo |
| Revisa | Ricardo |
| Ficha técnica | ✅ Sección 5. Mantenimiento inteligente |
| Estado | Listo para historias |

## Propósito

Decirle al cliente **qué** servicio toca, **cuándo** y **cuánto** cuesta antes de que lo pregunte, y llevarlo a agendar en un toque. Mueve O2 y O4.

## Pantallas

- **Plan de mantenimiento** — servicios por km/tiempo del modelo (5 000, 10 000…), hechos vs. pendientes.
- **Próximo servicio** (tarjeta en Garaje e Inicio) — km/fecha estimados, precio estimado, botón Agendar.
- **Actualizar kilometraje** — el cliente registra su km actual (foto del odómetro opcional).
- **Paquetes de servicio** — qué incluye cada servicio y su precio.

## Datos

| Tabla | Campos | Notas |
| --- | --- | --- |
| `plan_mantenimiento` ➕ | id, modelo, anio_desde, anio_hasta, km, meses, nombre, precio_estimado | Por modelo. |
| `concepto_mantenimiento` ➕ | id, plan_mantenimiento_id, concepto | Qué incluye. |
| `lectura_km` ➕ | id, vehiculo_cliente_id, km, fuente (taller/cliente), foto_url, registrada_en | El taller sigue siendo la fuente oficial (ficha). |

## API (`/api/v1/app`)

| Método | Ruta | Uso |
| --- | --- | --- |
| GET | `/vehiculos/{id}/mantenimiento` | Plan con estado y próximo. |
| POST | `/vehiculos/{id}/lecturas-km` | Lectura del cliente. |

## Historias

| ID | Historia | Criterios de aceptación | B | Depende de |
| --- | --- | --- | --- | --- |
| V2-M05.01 | Como cliente quiero ver el plan de mantenimiento de mi modelo | Lista por km/meses con hechos (cruzados con historial) y pendientes | ✅ | V2-M02.05 |
| V2-M05.02 | Como cliente quiero saber cuándo toca mi próximo servicio | Estimación por km promedio diario (lecturas) y por tiempo; gana lo que llegue primero | ✅ | V2-M05.01 |
| V2-M05.03 | Como cliente quiero registrar mi kilometraje actual | Validación: no menor a la última lectura oficial · foto opcional · el km oficial (taller) no se sobrescribe | ✅ | V2-M05.02 |
| V2-M05.04 | Como cliente quiero agendar el servicio recomendado en un toque | Abre Agendar cita con vehículo y motivo precargados | | V2-M05.02, V2-M02.08 |
| V2-M05.05 | Como cliente quiero un recordatorio cuando se acerque mi servicio | Push a 1 000 km o 2 semanas antes (configurable) | ✅ | V2-M06.02 |
| V2-M05.06 | Como cliente quiero ver qué incluye cada servicio y su precio estimado | Conceptos y precio con leyenda de estimado | ✅ | V2-M05.01 |
