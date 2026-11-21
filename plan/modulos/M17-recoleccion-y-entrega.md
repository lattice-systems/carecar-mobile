# M17 · Recolección y entrega a domicilio

| Campo | Valor |
| --- | --- |
| Hito | H5 |
| Dueño | Juan Pablo |
| Revisa | Ricardo |
| Ficha técnica | No (extiende `cita`) |
| Estado | Borrador |

## Propósito

Que el cliente no tenga que llevar su auto: la agencia lo recoge y lo devuelve. Mueve O2 y O5.

## Pantallas

- **Opción al agendar** — "Recoger en mi domicilio" con dirección, horario y costo.
- **Direcciones** — guardadas con mapa.
- **Seguimiento del chofer** — en camino, recogido, en taller, de regreso, entregado; ubicación del chofer en mapa.
- **Checklist de entrega** — fotos del auto al recoger/entregar, km, gasolina, firma.

## Datos

| Tabla | Campos | Notas |
| --- | --- | --- |
| `direccion_cliente` ➕ | id, cliente_id, alias, calle, colonia, cp, ciudad, lat, lng | |
| `traslado` ➕ | id, cita_id, direccion_cliente_id, tipo (recoger/entregar), chofer_id, estado, costo | |
| `checklist_traslado` ➕ | id, traslado_id, km, gasolina, fotos (json), firma_url | |

## Historias

| ID | Historia | Criterios de aceptación | B | Depende de |
| --- | --- | --- | --- | --- |
| V2-M17.01 | Como cliente quiero guardar mis direcciones | Autocompletado y pin en mapa · validación de zona de cobertura | ✅ | — |
| V2-M17.02 | Como cliente quiero pedir recolección al agendar | Costo y horario visibles · se ligan a la cita | ✅ | V2-M02.08, V2-M17.01 |
| V2-M17.03 | Como cliente quiero seguir al chofer | Estados con push · mapa en vivo solo durante el traslado | ✅ | V2-M17.02 |
| V2-M17.04 | Como cliente quiero el checklist con fotos del estado de mi auto | Fotos y firma al recoger y al entregar | ✅ | V2-M17.03 |
