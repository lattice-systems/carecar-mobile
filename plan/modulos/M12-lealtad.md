# M12 · Lealtad y recompensas

| Campo | Valor |
| --- | --- |
| Hito | H4 |
| Dueño | Cristian |
| Revisa | Haziel |
| Ficha técnica | No |
| Estado | Borrador |

## Propósito

Premiar al cliente por volver al taller, completar su perfil, contestar encuestas y referir amigos. Mueve O4 y O5.

## Pantallas

- **Mis puntos** — saldo, nivel (Bronce/Plata/Oro), progreso al siguiente nivel.
- **Recompensas** — catálogo canjeable (lavado, descuento en servicio, accesorios).
- **Movimientos** — puntos ganados y canjeados.
- **Referir** — código y enlace para compartir; recompensa al comprar el referido.

## Datos

| Tabla | Campos | Notas |
| --- | --- | --- |
| `movimiento_puntos` ➕ | id, cliente_id, puntos (+/−), motivo, referencia, creado_en | Saldo = suma; nunca se borra. |
| `recompensa` ➕ | id, nombre, puntos, activa, existencia | |
| `canje` ➕ | id, cliente_id, recompensa_id, codigo, estado | Código canjeable en caja. |
| `referido` ➕ | id, cliente_id, codigo, prospecto_id, estado | Alimenta `ventascrm`. |

## Historias

| ID | Historia | Criterios de aceptación | B | Depende de |
| --- | --- | --- | --- | --- |
| V2-M12.01 | Como cliente quiero ver mis puntos y nivel | Saldo por suma de movimientos · nivel por reglas del backend | ✅ | — |
| V2-M12.02 | Como cliente quiero ganar puntos al pagar un servicio | Evento de orden cerrada/pagada suma puntos | ✅ | V2-M04.07 |
| V2-M12.03 | Como cliente quiero canjear recompensas | Canje descuenta puntos y genera código QR · sin saldo negativo (bloqueo de fila) | ✅ | V2-M12.01 |
| V2-M12.04 | Como cliente quiero referir a un amigo | Enlace con código · el referido entra como prospecto en el backend · recompensa al cerrar venta | ✅ | V2-M12.01 |
| V2-M12.05 | Como cliente quiero ver mis movimientos de puntos | Paginado, con motivo | ✅ | V2-M12.01 |
