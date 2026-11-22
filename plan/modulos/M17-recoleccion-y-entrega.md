# M17 · Recolección y entrega a domicilio

| Campo | Valor |
| --- | --- |
| Hito | H5 |
| Dueño | Juan Pablo |
| Revisa | Ricardo |
| Ficha técnica | ✅ Sección 17. Recolección y entrega a domicilio |
| Estado | Listo para historias |

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

## API (`/api/v1/app`)

| Método | Ruta | Uso |
| --- | --- | --- |
| GET/POST | `/direcciones` | Listar y guardar direcciones; 422 si queda fuera de la zona de cobertura. |
| PUT/DELETE | `/direcciones/{id}` | Editar y borrar (solo las propias). |
| GET | `/recoleccion/cotizacion?direccionId=&fecha=` | Costo y franja de recolección para esa dirección y fecha. |
| POST | `/citas` | Suma `recoleccion: { direccionId }` y crea los `traslado` de recoger y entregar ligados a la cita. |
| GET | `/traslados/{id}` | Estado y, solo en `en_camino` o `de_regreso`, la ubicación del chofer. |
| GET | `/traslados/{id}/checklist` | Fotos (URL firmadas), km, gasolina y firma al recoger y al entregar. |

## Historias

| ID | Historia | Criterios de aceptación | B | Depende de |
| --- | --- | --- | --- | --- |
| V2-M17.01 | Como cliente quiero guardar mis direcciones para pedir recolección sin escribirlas cada vez | Alta con alias, calle, colonia, CP y ciudad, y pin en el mapa · si queda fuera de la zona de cobertura se avisa antes de guardar · editar y borrar · solo veo las mías | ✅ | V2-T02.09 |
| V2-M17.02 | Como cliente quiero pedir que recojan mi auto al agendar para no tener que llevarlo | En la confirmación de la cita, opción "Recoger en mi domicilio" con una dirección guardada · costo y franja visibles antes de confirmar · se crean los traslados de recoger y entregar ligados a la cita · fuera de cobertura la opción no aparece | ✅ | V2-M02.08, V2-M17.01 |
| V2-M17.03 | Como cliente quiero seguir al chofer para saber cuándo llega | Estados `en_camino`, `recogido`, `en_taller`, `de_regreso`, `entregado` en una línea de tiempo con push · el mapa con el chofer solo aparece en `en_camino` y `de_regreso` | ✅ | V2-M17.02, V2-M06.02, V2-T02.09 |
| V2-M17.04 | Como cliente quiero ver el checklist con fotos del estado de mi auto para comprobar cómo lo recogieron y cómo me lo entregaron | Al recoger y al entregar: fotos, km, gasolina y firma · el cliente compara ambas entregas · fotos servidas con URL firmada de vida corta | ✅ | V2-M17.03, V2-T05.09, V2-T02.12 |

## Fuera de alcance / notas

- El chofer captura el checklist con una herramienta interna; mientras el ERP siga congelado se carga con un endpoint interno o con datos de ejemplo. La app solo consulta.
- El proveedor de mapas y geocodificación se decide en la historia del componente `Mapa` (V2-T02.09) con una decisión (ADR).
