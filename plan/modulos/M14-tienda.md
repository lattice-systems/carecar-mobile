# M14 · Tienda de refacciones y accesorios

| Campo | Valor |
| --- | --- |
| Hito | H5 |
| Dueño | Cristian |
| Revisa | Ricardo |
| Ficha técnica | ✅ Sección 14. Tienda de refacciones y accesorios |
| Estado | Borrador |

## Propósito

Vender accesorios y refacciones originales compatibles con el auto del cliente, con apartado y recogida o instalación en el taller. Mueve O5.

## Pantallas

- **Tienda** — filtrada por "compatible con mi <modelo año>", categorías, búsqueda.
- **Producto** — fotos, precio, existencia, compatibilidad, "instalar en mi próxima cita".
- **Carrito y apartado** — recoger en mostrador o instalar en cita; pago en app (M08) o en caja.
- **Mis pedidos** — estado (apartado, listo, entregado, cancelado).

## Datos

| Tabla | Campos | Notas |
| --- | --- | --- |
| `refaccion` (existe) | — | ➕ publicada_en_app, foto_url, descripcion_app. |
| `compatibilidad_refaccion` ➕ | id, refaccion_id, modelo, anio_desde, anio_hasta | |
| `pedido_app` ➕ | id, cliente_id, estado, entrega (mostrador/cita), cita_id, total | Aparta existencia con movimiento de inventario (bloqueo de fila). |
| `pedido_app_renglon` ➕ | id, pedido_app_id, refaccion_id, cantidad, precio | |
| `movimiento_inventario` (existe) | — | Cada apartado, venta o liberación es un movimiento; la existencia nunca se edita directo. |

## Historias

| ID | Historia | Criterios de aceptación | B | Depende de |
| --- | --- | --- | --- | --- |
| V2-M14.01 | Como cliente quiero ver accesorios compatibles con mi auto | Filtro por vehículo seleccionado · existencia visible | ✅ | V2-M02.01 |
| V2-M14.02 | Como cliente quiero apartar productos | Apartado reserva existencia por tiempo limitado · se libera al vencer | ✅ | V2-M14.01 |
| V2-M14.03 | Como cliente quiero que me instalen lo comprado en mi cita | Pedido ligado a la cita; el taller lo ve en la orden | ✅ | V2-M14.02, V2-M02.08 |
| V2-M14.04 | Como cliente quiero pagar mi pedido en la app | Reusa M08 | ✅ | V2-M08.02 |
| V2-M14.05 | Como cliente quiero seguir mis pedidos | Estados con push | ✅ | V2-M06.02 |
