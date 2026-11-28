# M19 · Cuentas familiares y conductores autorizados

| Campo | Valor |
| --- | --- |
| Hito | H6 |
| Dueño | Jael |
| Revisa | Daniel |
| Ficha técnica | ✅ Sección 19. Cuentas familiares |
| Estado | Listo para historias |

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
| V2-M19.01 | Como titular quiero invitar a alguien a ver mi vehículo | Solo el titular invita · respuesta igual exista o no el correo · enlace `carecar://invitacion?token=` de un solo uso · sin cola sin conexión | ✅ | V2-M01.04 |
| V2-M19.02 | Como invitado quiero aceptar y ver el vehículo compartido | Cuenta equivocada y enlace inválido resueltos · «Compartido por» en el garaje · permisos respetados por el servidor, no por la app | ✅ | V2-M19.01 |
| V2-M19.03 | Como titular quiero limitar lo que puede hacer el invitado | Cuatro banderas: ver, agendar, avisos, documentos · lo que falta o no se conoce es «apagado» · el cambio se ve de inmediato en la pantalla del invitado | ✅ | V2-M19.02 |
| V2-M19.04 | Como titular quiero revocar un acceso | Efecto inmediato · los permisos no viajan en el JWT · el invitado que está dentro sale con aviso · se borra lo que guardó en su teléfono | ✅ | V2-M19.02 |

## Criterios de aceptación

Lo común a todas: ninguna dirección de correo ni `token` se escribe en logs
(`Registro.depurar` ya los tapa; lo vigila
`test/arquitectura/registro_sin_datos_personales_test.dart`); toda pantalla se
prueba en claro, oscuro y letra al 200 %; y **la app nunca decide un permiso**:
oculta o deshabilita lo que no se puede por claridad, pero quien decide es el
servidor, y todo 403 se maneja con un mensaje, no con una pantalla de error genérico.

Estas acciones **no entran a la cola sin conexión de V2-M21.03**. Invitar,
editar permisos y revocar son decisiones de seguridad: sin red se dice «no se
pudo» y se queda como estaba, nunca «listo» a medias.

### Qué abre cada bandera (propuesta, por confirmar)

La ficha nombra cuatro permisos pero no dice qué toca cada uno. Esta tabla
es la **propuesta** con la que se escriben los criterios; la confirma el PO
(ver «Preguntas abiertas»).

| Bandera | Abre | Nunca abre |
| --- | --- | --- |
| `ver` | Detalle del vehículo, kilometraje, historial de servicios, estado de la orden en el taller | Pagos, facturas, datos fiscales, perfil del titular, chat con el asesor (M07) |
| `agendar` | Crear, reprogramar y cancelar citas de **ese** vehículo | Citas de otros vehículos del titular |
| `avisos` | Recibir los avisos de ese vehículo (taller, citas, mantenimiento) | Avisos de otros vehículos o de la cuenta del titular |
| `documentos` | Ver los documentos de ese vehículo | Subir o borrar documentos |

`ver` es la base: **no se puede apagar**. Quitar todo acceso es revocar (M19.04),
no apagar `ver`.

### V2-M19.01 · Invitar a alguien a ver mi vehículo

Backend: tabla `acceso_compartido` (ficha, sección 19) y el correo con el
enlace. Reusa el mecanismo de enlace de un solo uso de V2-M01.04. **Los
endpoints no están en ninguna tabla todavía**: ver «Pendiente de diseñar».

| # | Dado / Cuando / Entonces |
| --- | --- |
| 1 | **Dado** un vehículo del cliente, **entonces** el detalle ofrece «Compartir vehículo»; en un vehículo que **le compartieron**, esa opción **no existe** (nadie re-comparte) y el servidor lo rechaza aunque se llame directo. |
| 2 | **Dado** el formulario, **entonces** pide correo y las cuatro banderas (con `ver` encendida y fija, y las otras tres apagadas por omisión) y una caducidad **opcional**; sin caducidad el acceso no vence. |
| 3 | **Dado** un correo mal formado o una caducidad en el pasado, **entonces** la app lo marca sin llamar a la API. |
| 4 | **Dado** el correo del propio titular, **entonces** el servidor responde 422 y la app dice «No puedes compartir un vehículo contigo». |
| 5 | **Dado** un correo que **no** es de un cliente de la agencia, **entonces** la respuesta es **idéntica** a la de uno que sí lo es (mismo código, mismo texto: «Si esa persona es cliente, recibirá la invitación»). Es el mismo criterio de V2-M01.04: la respuesta no revela quién es cliente. |
| 6 | **Dado** una invitación ya pendiente para ese vehículo y ese correo, **entonces** no se crea otra: se reenvía la misma o se responde 409 con «Ya invitaste a esta persona». |
| 7 | **Dado** el enlace del correo, **entonces** es `carecar://invitacion?token=…`, `EnlacesApp` lo traduce a la ruta interna de aceptar invitación, y un enlace sin `token` o con uno malformado lleva a «Esta invitación no es válida» sin llamar a la API. |
| 8 | **Dado** un enlace ya usado, **entonces** no sirve una segunda vez (hereda V2-M01.04). |
| 9 | **Dado** el vehículo de otra persona, **cuando** se intenta invitar, **entonces** 404, igual que uno inexistente. |
| 10 | **Dado** demasiados envíos seguidos, **entonces** el servidor responde 429 y la app dice cuánto esperar. |
| 11 | **Dado** que no hay conexión, **entonces** el botón explica que se necesita conexión; no se encola. |
| 12 | **Dado** una invitación enviada, **entonces** aparece en «Personas con acceso» como «Invitación enviada», con el correo, hasta que se acepte o se revoque. |

### V2-M19.02 · Aceptar y ver el vehículo compartido

Backend: aceptar la invitación, y que **todos los endpoints de vehículo
verifiquen en el servidor** el acceso y la bandera de quien pregunta.

| # | Dado / Cuando / Entonces |
| --- | --- |
| 1 | **Dado** el enlace abierto con sesión, **entonces** la pantalla Invitación muestra quién invita (nombre del titular), qué vehículo (modelo y año; las placas parciales) y qué podrá hacer, con **Aceptar** y **Ahora no**. «Ahora no» no llama a la API y **no consume** el enlace. |
| 2 | **Dado** el enlace abierto sin sesión, **entonces** pasa por el acceso y, al entrar, **regresa a la invitación** (la guardia ya hace esto con `desde`, V2-M06.03). |
| 3 | **Dado** una persona que entra con una cuenta **distinta** a la invitada, **entonces** el servidor responde 403 y la pantalla dice «Esta invitación es para otra cuenta», **sin mostrar el correo completo** y sin consumir el enlace; ofrece cerrar sesión para entrar con la correcta. |
| 4 | **Dado** un enlace vencido, usado o de una invitación ya revocada, **entonces** se muestra una sola pantalla, «Esta invitación ya no es válida, pídele al titular otra», que no distingue cuál de las tres fue. |
| 5 | **Dado** que se acepta, **entonces** el enlace se consume una sola vez; **un segundo toque, o aceptar desde dos celulares a la vez, no falla**: lleva al garaje con el vehículo ya compartido. |
| 6 | **Dado** el garaje, **entonces** el vehículo compartido aparece con la etiqueta «Compartido por <titular>» **en texto**, no solo con un color, y separado de los propios. |
| 7 | **Dado** un invitado sin la bandera `agendar`, **entonces** la app muestra «Agendar cita» deshabilitado con la razón; y **si se llama a la API igual, el servidor responde 403** (prueba de integración en el backend, no solo en la app). |
| 8 | **Dado** un 403 por permiso en cualquier acción, **entonces** la app dice «El titular no te dio permiso para esto» y no pierde lo que la persona estaba escribiendo. |
| 9 | **Dado** un invitado, **entonces** **no** ve pagos, facturas, perfil del titular ni el chat con el asesor de ese vehículo, aunque tenga `ver` (ver tabla de banderas). |
| 10 | **Dado** el acceso con `vence_en` ya pasado, **entonces** el servidor lo trata **igual que uno revocado** en cada petición, sin depender de un proceso que corra después. |
| 11 | **Dado** que no hay conexión, **entonces** el garaje muestra lo ya guardado y aceptar una invitación explica que necesita conexión. |

### V2-M19.03 · Limitar lo que puede hacer el invitado

Backend: `acceso_compartido.permisos` sigue siendo `json` en la base, pero el
contrato declara **solo cuatro llaves**: `ver`, `agendar`, `avisos`, `documentos`.

| # | Dado / Cuando / Entonces |
| --- | --- |
| 1 | **Dado** «Personas con acceso», **entonces** cada persona muestra las cuatro banderas con una explicación en lenguaje claro de lo que abre cada una. |
| 2 | **Dado** una respuesta del servidor con una llave de permiso que la app no conoce, **entonces** se ignora; **dado** una llave que falta, **entonces** se trata como **apagada**. El caso seguro es negar, no conceder. |
| 3 | **Dado** el interruptor de `ver`, **entonces** está encendido y no se puede apagar; el servidor responde 422 si se intenta. |
| 4 | **Dado** que el titular cambia una bandera, **entonces** el interruptor muestra «guardando» y **no** se pinta como cambiado hasta que el servidor confirma; si falla (sin red, 5xx), vuelve a su valor anterior y se avisa. |
| 5 | **Dado** dos cambios rápidos seguidos, **entonces** al terminar la pantalla refleja lo que **guardó el servidor**, no lo último que se tocó. |
| 6 | **Dado** que el titular apaga `agendar` mientras el invitado llena el formulario de una cita, **cuando** el invitado envía, **entonces** recibe el 403 con el mensaje de permiso y vuelve al detalle con «Agendar» ya deshabilitado. |
| 7 | **Dado** que el titular apaga `documentos` o `avisos`, **entonces** el invitado deja de ver los documentos y de recibir los avisos de ese vehículo desde su siguiente consulta; los avisos ya recibidos no se borran. |
| 8 | **Dado** una invitación todavía sin aceptar, **entonces** sus banderas se pueden editar y el invitado acepta con las vigentes. |
| 9 | **Dado** el titular, **entonces** puede cambiar o quitar la caducidad; una fecha pasada se rechaza. |
| 10 | **Dado** un invitado que llama al endpoint de editar permisos (el suyo o el de otro), **entonces** 404; solo el titular edita. |

### V2-M19.04 · Revocar un acceso

Backend: revocar y emitir el evento por el canal SSE (nombre por diseñar).

| # | Dado / Cuando / Entonces |
| --- | --- |
| 1 | **Dado** «Personas con acceso», **cuando** el titular toca Revocar, **entonces** una confirmación nombra a la persona y el vehículo, y solo al confirmar se revoca. |
| 2 | **Dado** un acceso revocado, **cuando** el invitado hace **cualquier** petición sobre ese vehículo con un token de acceso **todavía vigente**, **entonces** recibe 404 o 403 de inmediato, sin periodo de gracia. Es la prueba que importa: **los permisos no viajan dentro del JWT**; el servidor los consulta en cada petición, o el invitado conservaría el acceso hasta que su token caduque. |
| 3 | **Dado** el invitado dentro de la pantalla del vehículo cuando le quitan el acceso, **entonces** la pantalla sale sola hacia el garaje con el aviso «Ya no tienes acceso a <vehículo>»; **no** queda en blanco ni con un error genérico. Llega por el canal SSE y, si el canal estaba caído, por el 403 de su siguiente petición. |
| 4 | **Dado** el garaje del invitado, **entonces** el vehículo desaparece. |
| 5 | **Dado** lo que el invitado tenía guardado en su teléfono de ese vehículo (base local de V2-M21.01, documentos descargados, recordatorios locales de cita), **entonces** se borra al enterarse de la revocación, para que no siga a la vista sin conexión. |
| 6 | **Dado** una revocación ya hecha, **cuando** se repite (segundo toque, otro celular), **entonces** responde bien (idempotente) y la lista queda igual. |
| 7 | **Dado** una invitación aún sin aceptar, **cuando** se revoca, **entonces** su enlace deja de servir. |
| 8 | **Dado** un acceso vencido, **entonces** aparece como «Vencido» y se puede quitar de la lista. |
| 9 | **Dado** que no hay conexión, **entonces** el titular lee «No se pudo revocar, el acceso sigue activo» y la lista **no** lo marca como revocado. |
| 10 | **Dado** una revocación, **entonces** la cuenta, la sesión y los demás vehículos del invitado no se tocan. |
| 11 | **Dado** el titular, **entonces** la lista de «Personas con acceso» se ve igual con 0, 1 o muchos invitados (vacío explica cómo compartir). |

## Pendiente de diseñar

Los cuatro endpoints son nuevos y **no se declaran como hechos**. Quien tome la
historia B los diseña en su primer commit en
`agencia-360-backend/plan/historias-backend.md` y en el contrato v2.

| Falta | La necesita |
| --- | --- |
| Crear invitación (vehículo, correo, banderas, caducidad) y reenviarla | M19.01 |
| Qué hace el servidor con un correo que no es de cliente: no crear fila o crear una huérfana. La respuesta a la app es igual en los dos casos | M19.01 |
| Ver la invitación por su `token` y aceptarla | M19.02 |
| Listar accesos de un vehículo (titular) y vehículos compartidos conmigo, con `compartido_por` en `GET /vehiculos` | M19.01, M19.02 |
| Editar banderas y caducidad | M19.03 |
| Revocar, y el evento SSE de acceso revocado o cambiado | M19.04 |
| Cuántas invitaciones activas por vehículo | M19.01 |
| Que **todos** los endpoints de vehículo, cita, documento y aviso apliquen la bandera (esto toca varios módulos del backend, no solo `acceso_compartido`) | M19.02 |

## Preguntas abiertas para el PO

| Pregunta | Efecto |
| --- | --- |
| **¿Un invitado sin compra propia puede tener cuenta?** Ya estaba anotada. Mientras no se decida, se comparte solo entre clientes existentes. | Si es sí, se agrega el alta del invitado; el modelo de acceso no cambia |
| ¿Qué cubre exactamente cada bandera? La tabla de arriba es propuesta; en especial, que un invitado **no** ve pagos, facturas ni el chat. | Cambia los criterios M19.02.9 y la dependencia con M07 |
| ¿Al revocar se avisa al invitado con un push, o solo se entera al entrar? Aquí solo si está dentro de la app. | Decide si hay evento de push nuevo |
| ¿Qué pasa con las citas que el invitado agendó? Se propone que **siguen** y las ve el titular. | Evita citas huérfanas |
| ¿La respuesta igual exista o no el correo es aceptable? Protege la privacidad de los clientes, pero un titular que escribe mal el correo no se entera. | Podría pedir confirmar el correo dos veces en el formulario |
| ¿El invitado puede dejar de ver un vehículo por sí mismo? Se propone V2-M19.05, abajo. | Fila nueva |
| ¿Si el titular vende o transfiere el vehículo se revocan sus accesos? Se propone que sí, y es una regla del backend. | Criterio nuevo de M19.04 |

### V2-M19.05 · Dejar de ver un vehículo compartido (propuesta)

**No está en el tablero y no la crea este cambio**: la ficha solo pide compartir
con permisos, y esto es una idea que nace de escribir los criterios. Si el PO la
acepta, entra como `Borrador` con estos criterios de partida:

| # | Dado / Cuando / Entonces |
| --- | --- |
| 1 | **Dado** un vehículo compartido conmigo, **cuando** toco «Dejar de ver este vehículo» y confirmo, **entonces** el acceso queda revocado y se borra lo guardado en mi teléfono (igual que M19.04.4 y .5). |
| 2 | **Dado** que lo hago, **entonces** el titular lo ve en su lista como «El invitado dejó de ver este vehículo». |
| 3 | **Dado** que no hay conexión, **entonces** se explica que necesita conexión y el vehículo sigue ahí. |

## Cómo se actualiza el tablero

No lo hizo este cambio (otro agente trabajaba ahí). Lo que conviene mover:

- V2-M19.01 a .04: `Lista`. Cumplen la Definición de Listo; su dependencia de
  V2-M01.04 no bloquea y el backend se trabaja contra el contrato y `mock_api`.
- Antes de programar V2-M19.02 conviene que el PO conteste la pregunta de qué
  cubre cada bandera: es la que más puede cambiar sus criterios.
- V2-M19.05: solo si el PO acepta la propuesta.
- Cumplimiento de ficha: sin cambio. La fila de la sección 19 sigue en ⬜ hasta
  que haya código; `acceso_compartido.permisos` se queda como `json`.


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

M19 sigue en H6. Sus historias ya tienen criterios comprobables (arriba) y las
cuatro necesitan backend, que se trabaja contra el contrato y `mock_api`. Lo que
estas decisiones quitan de encima es la infraestructura de invitaciones y el diseño del modelo de
permisos.

