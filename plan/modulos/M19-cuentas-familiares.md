# M19 · Cuentas familiares y conductores autorizados

| Campo | Valor |
| --- | --- |
| Hito | H6 |
| Dueño | Jael |
| Revisa | Daniel |
| Ficha técnica | ✅ Sección 19. Cuentas familiares |
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

## Decisiones técnicas (27 de noviembre de 2026)

Tomadas por el frente de la app, por delegación del equipo. La ficha técnica no
cubre este módulo, y la ficha de arriba deja abiertos el enlace y la forma de
los permisos.

### La invitación reusa el enlace de un solo uso de M01.04

Ya está hecho y funcionando: `EnlacesApp` traduce `carecar://` a ruta interna
(V2-T01.03) y el flujo de recuperar contraseña (V2-M01.04, PR #152) usa un
enlace de un solo uso por correo. M19.01 agrega un camino,
`carecar://invitacion?token=`, al traductor que ya existe.

**Nada nuevo que construir ni decidir:** ni esquema de enlaces, ni dominio, ni
caducidad de tokens. Y de paso hereda lo ya resuelto ahí, como que un enlace
usado no sirve dos veces.

### Los permisos son cuatro banderas, no una matriz

`acceso_compartido.permisos` es `json` en la base, pero el contrato declarará
**un conjunto cerrado de cuatro**, que son los que la ficha ya nombra: ver,
agendar, avisos, documentos.

Un `json` libre invita a un motor de permisos: reglas por recurso, herencia,
combinaciones que nadie pidió. Cuatro banderas se prueban con cuatro pruebas y
se entienden leyendo la pantalla. Si algún día hace falta una quinta, se
agrega; el `json` deja esa puerta abierta sin pagarla hoy.

### Compartir solo entre clientes que ya existen

La ficha deja abierta una pregunta de producto: si un invitado sin compra
propia puede tener cuenta. **Eso no lo decide el equipo de desarrollo**, así
que se toma el camino conservador que la ficha misma propone como alternativa:
se comparte solo entre clientes existentes.

Es reversible y barato de cambiar: si el PO abre el registro, lo que se agrega
es el alta del invitado, no un cambio en el modelo de acceso.

### Lo que esto implica para el orden

M19 sigue en H6 y **no se puede programar todavía**: las cuatro historias están
en borrador y todas necesitan backend. Lo que estas decisiones quitan de
encima es la infraestructura de invitaciones y el diseño del modelo de
permisos.

