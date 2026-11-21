# M10 · Garantía y campañas de seguridad

| Campo | Valor |
| --- | --- |
| Hito | H3 |
| Dueño | Ricardo |
| Revisa | Haziel |
| Ficha técnica | ✅ Sección 10. Garantía y campañas de seguridad |
| Estado | Listo para historias |

## Propósito

Mostrar la cobertura de garantía de cada auto y avisar de campañas de seguridad (recalls) por VIN para atenderlas en la agencia. Mueve O4 y O6.

## Pantallas

- **Garantía** — cobertura por componente con km/fecha límite y barra de consumo.
- **Campañas** — campañas abiertas para el VIN, gravedad, qué hacer, botón Agendar.

## Datos

| Tabla | Campos | Notas |
| --- | --- | --- |
| `garantia` ➕ | id, vehiculo_cliente_id, componente, inicia_en, vence_en, km_limite | |
| `campana_seguridad` ➕ | id, codigo, titulo, descripcion, gravedad, modelo, anio_desde, anio_hasta, vin_desde, vin_hasta | |
| `campana_vehiculo` ➕ | id, campana_seguridad_id, vehiculo_cliente_id, estado (abierta/agendada/atendida) | |

## API (`/api/v1/app`)

| Método | Ruta | Uso |
| --- | --- | --- |
| GET | `/vehiculos/{id}/garantia` | |
| GET | `/vehiculos/{id}/campanas` | |

## Historias

| ID | Historia | Criterios de aceptación | B | Depende de |
| --- | --- | --- | --- | --- |
| V2-M10.01 | Como cliente quiero ver qué cubre mi garantía y hasta cuándo | Por componente con fecha y km límite contra km actual | ✅ | V2-M02.02 |
| V2-M10.02 | Como cliente quiero saber si mi auto tiene una campaña de seguridad | Cruce por modelo/año/rango de VIN · badge en Garaje | ✅ | V2-M02.01 |
| V2-M10.03 | Como cliente quiero agendar la atención de una campaña | Agendar con motivo "Campaña <código>" · estado pasa a agendada | ✅ | V2-M10.02, V2-M02.08 |
| V2-M10.04 | Como cliente quiero un aviso cuando salga una campaña para mi auto | Push con gravedad · no silenciable si es crítica | ✅ | V2-M06.02 |
| V2-M10.05 | Como cliente quiero saber que mi garantía está por vencer | Aviso 60 y 15 días antes / 1 000 km antes | ✅ | V2-M06.02 |
