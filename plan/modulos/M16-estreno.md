# M16 · Estreno: prueba de manejo y cotización de auto nuevo

| Campo | Valor |
| --- | --- |
| Hito | H5 |
| Dueño | Daniel |
| Revisa | Haziel |
| Ficha técnica | ✅ Sección 16. Estreno |
| Estado | Borrador |

## Propósito

Convertir el interés del catálogo en una venta: el cliente pide prueba de manejo o cotización y se crea un prospecto en el backend (`ventascrm`), con la toma a cuenta adjunta. Mueve O5.

## Pantallas

- **Quiero probarlo** — modelo, versión, fecha/hora preferida, sucursal.
- **Cotización** — versión, color, enganche, plazo; cálculo de mensualidad estimada (no vinculante) + estimación de toma a cuenta (M03).
- **Mis solicitudes** — estado de pruebas y cotizaciones; vendedor asignado.

## Datos

Reutiliza `prospecto` del módulo `ventascrm` (origen = `APP_CARECAR`, cliente existente). ➕ `solicitud_estreno` (id, cliente_id, modelo_catalogo_id, tipo, preferencia, estimacion_toma_cuenta_id, prospecto_id, estado).

## Historias

| ID | Historia | Criterios de aceptación | B | Depende de |
| --- | --- | --- | --- | --- |
| V2-M16.01 | Como cliente quiero pedir una prueba de manejo | Crea prospecto en backend vía evento de dominio · confirmación | ✅ | V2-M03.02 |
| V2-M16.02 | Como cliente quiero cotizar un auto nuevo con mensualidad estimada | Cálculo en backend · leyenda no vinculante | ✅ | V2-M03.02 |
| V2-M16.03 | Como cliente quiero adjuntar mi estimación de toma a cuenta | Se liga a la solicitud y al prospecto | ✅ | V2-M03.07 |
| V2-M16.04 | Como cliente quiero ver el estado de mis solicitudes | Estado y vendedor asignado | ✅ | V2-M16.01 |

## Fuera de alcance / notas

- La atención del prospecto ocurre en el CRM web (congelado). La app solo crea el prospecto con el origen correcto; el CRM ya lista prospectos.
