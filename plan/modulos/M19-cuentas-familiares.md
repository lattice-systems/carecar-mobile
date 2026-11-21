# M19 · Cuentas familiares y conductores autorizados

| Campo | Valor |
| --- | --- |
| Hito | H6 |
| Dueño | Jael |
| Revisa | Daniel |
| Ficha técnica | No (respeta: la cuenta del titular la crea la agencia) |
| Estado | Borrador |

## Propósito

Que el titular comparta un vehículo con su familia o chofer con permisos limitados (ver, agendar, recibir avisos), sin compartir contraseña. Mueve O4.

## Pantallas

- **Compartir vehículo** — invitar por correo, elegir permisos, caducidad opcional.
- **Invitación** — el invitado acepta; si no tiene cuenta, la agencia la valida (sin registro público).
- **Personas con acceso** — lista, editar permisos, revocar.

## Datos

| Tabla | Campos | Notas |
| --- | --- | --- |
| `acceso_compartido` ➕ | id, vehiculo_cliente_id, titular_cliente_id, invitado_correo, invitado_cuenta_id, permisos (json), estado, vence_en | |

## Historias

| ID | Historia | Criterios de aceptación | B | Depende de |
| --- | --- | --- | --- | --- |
| V2-M19.01 | Como titular quiero invitar a alguien a ver mi vehículo | Invitación por correo con enlace de un solo uso | ✅ | V2-M01.04 |
| V2-M19.02 | Como invitado quiero aceptar y ver el vehículo compartido | Garaje muestra "compartido por <titular>" · permisos respetados en backend | ✅ | V2-M19.01 |
| V2-M19.03 | Como titular quiero limitar lo que puede hacer el invitado | Permisos ver/agendar/avisos/documentos | ✅ | V2-M19.02 |
| V2-M19.04 | Como titular quiero revocar un acceso | Efecto inmediato; el invitado deja de ver el vehículo | ✅ | V2-M19.02 |

## Fuera de alcance / notas

- Decisión de PO necesaria: ¿un invitado sin compra propia puede tener cuenta? Si no, solo se comparte entre clientes existentes.
