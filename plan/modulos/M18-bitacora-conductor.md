# M18 · Bitácora del conductor

| Campo | Valor |
| --- | --- |
| Hito | H6 |
| Dueño | Juan Pablo |
| Revisa | Cristian |
| Ficha técnica | No |
| Estado | Borrador |

## Propósito

Que el cliente registre cargas de gasolina y gastos para conocer el rendimiento y el costo real de su auto; las lecturas alimentan la predicción de mantenimiento (M05). Mueve O4 y O6.

## Pantallas

- **Bitácora** — cargas y gastos por vehículo.
- **Nueva carga** — litros, precio, km, foto del ticket (lectura automática por OCR en el dispositivo).
- **Estadísticas** — km/l, costo por km, gasto mensual, comparación con el promedio del modelo.

## Datos

| Tabla | Campos | Notas |
| --- | --- | --- |
| `gasto_vehiculo` ➕ | id, vehiculo_cliente_id, tipo (gasolina/estacionamiento/casetas/lavado/otro), monto, litros, km, fecha, ticket_url | Cada km alimenta `lectura_km` (fuente cliente). |

## Historias

| ID | Historia | Criterios de aceptación | B | Depende de |
| --- | --- | --- | --- | --- |
| V2-M18.01 | Como cliente quiero registrar una carga de gasolina | Validaciones numéricas · km no menor al anterior | ✅ | V2-M05.03 |
| V2-M18.02 | Como cliente quiero llenar la carga desde la foto del ticket | OCR en el dispositivo (ML Kit) · el cliente confirma | | V2-M18.01 |
| V2-M18.03 | Como cliente quiero ver mi rendimiento y gasto | Gráficas km/l y $/mes · accesibles (tabla alternativa) | | V2-M18.01 |
| V2-M18.04 | Como cliente quiero registrar otros gastos | Tipos fijos + otro | ✅ | V2-M18.01 |
| V2-M18.05 | Como cliente quiero exportar mi bitácora | CSV/PDF | | V2-M18.03 |
