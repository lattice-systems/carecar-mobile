# M11 · Asistencia en camino (SOS)

| Campo | Valor |
| --- | --- |
| Hito | H6 |
| Dueño | Juan Pablo |
| Revisa | Jael |
| Ficha técnica | No |
| Estado | Borrador |

## Propósito

Ayuda inmediata cuando el auto falla en la calle: un botón que comparte ubicación, vehículo y problema con la agencia o la aseguradora. Mueve O4.

## Pantallas

- **SOS** — botón grande con confirmación por deslizamiento; tipo de problema (llanta, batería, choque, sin gasolina, otro).
- **Seguimiento** — estado de la solicitud, contacto, ubicación compartida.
- **Contactos de emergencia** — aseguradora (desde M09), agencia, grúa, 911.
- **Guías rápidas** — cambiar llanta, pasar corriente, qué hacer en un choque (sin conexión).

## Datos

| Tabla | Campos | Notas |
| --- | --- | --- |
| `solicitud_asistencia` ➕ | id, cliente_id, vehiculo_cliente_id, tipo, lat, lng, comentario, estado, creada_en | Ubicación solo mientras dure. |

## API (`/api/v1/app`)

| Método | Ruta | Uso |
| --- | --- | --- |
| POST | `/asistencia` | Crear solicitud. |
| GET | `/asistencia/{id}` | Estado. |

## Historias

| ID | Historia | Criterios de aceptación | B | Depende de |
| --- | --- | --- | --- | --- |
| V2-M11.01 | Como cliente varado quiero pedir ayuda con mi ubicación | Permiso de ubicación explicado · envía vehículo y tipo · confirmación inmediata | ✅ | V2-M02.01 |
| V2-M11.02 | Como cliente quiero llamar rápido a mi aseguradora o a la agencia | Números desde M09/M27 · un toque | | V2-M09.01 |
| V2-M11.03 | Como cliente quiero guías de emergencia sin conexión | Contenido empaquetado en la app | | — |
| V2-M11.04 | Como cliente quiero ver el estado de mi solicitud | Estados recibida/en camino/atendida con push | ✅ | V2-M11.01, V2-M06.02 |
