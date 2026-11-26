# M12 · Lealtad y recompensas

| Campo | Valor |
| --- | --- |
| Hito | H4 |
| Dueño | Ricardo |
| Revisa | Haziel |
| Ficha técnica | ✅ Sección 12. Lealtad y recompensas |
| Estado | Listo para historias |

## Propósito

Premiar al cliente por volver al taller, completar su perfil, contestar encuestas y referir amigos. Mueve O4 y O5.

## Pantallas

- **Mis puntos** — saldo, nivel (Bronce, Plata u Oro) con barra de progreso al siguiente y accesos a recompensas, movimientos y referir. Entrada desde el perfil o Inicio.
- **Recompensas** — catálogo de recompensas activas con su costo en puntos; las que no alcanzan se ven deshabilitadas con lo que falta.
- **Mis canjes** — código y QR de cada canje con su vigencia y estado (vigente, usado, vencido).
- **Movimientos** — puntos ganados y gastados con motivo y fecha, paginado.
- **Referir** — mi código para compartir y el formulario para registrar a un amigo; lista de mis referidos con su estado.

## Reglas (propuestas, pendientes del PO)

Viven en la configuración del backend (`app.lealtad.*`), no en el código ni en la app; el PO puede cambiarlas sin tocar las historias.

| Regla | Valor propuesto |
| --- | --- |
| Puntos por servicio | 1 punto por cada $10 MXN del total pagado de la orden, truncado ($1,650 → 165 puntos) |
| Niveles | Por puntos **ganados** en los últimos 12 meses: Bronce de 0 a 1,499 · Plata de 1,500 a 3,999 · Oro desde 4,000 |
| Vencimiento de puntos | No vencen en v2 |
| Vigencia de un canje | 30 días; si vence sin usarse, los puntos regresan con un movimiento inverso |
| Recompensa por referido | 500 puntos al cliente cuando la venta de su referido se finaliza |
| Referidos abiertos | Hasta 10 por cliente a la vez |
| Recompensas iniciales (semillas) | Lavado exprés 300 · 10 % en mano de obra 800 · Revisión de frenos 1,200 · Kit de tapetes 1,500 |

## Datos

| Tabla | Campos | Notas |
| --- | --- | --- |
| `movimiento_puntos` ➕ | id, cliente_id, puntos (+/−), motivo (SERVICIO, CANJE, DEVOLUCION_CANJE, REFERIDO, AJUSTE), referencia_tipo, referencia_id, creado_en | Saldo = suma; nunca se borra ni se edita. Único por (motivo, referencia) para que un evento repetido no sume dos veces. |
| `recompensa` ➕ | id, nombre, descripcion, puntos, activa, existencia, creado_en | `existencia` nula = sin límite; con límite se descuenta con bloqueo de fila. |
| `canje` ➕ | id, cliente_id, recompensa_id, codigo, puntos, estado (VIGENTE, USADO, VENCIDO), vence_en, usado_en, creado_en | `codigo` único de 8 caracteres sin letras confusas; el QR lo codifica. |
| `referido` ➕ | id, cliente_id, codigo, nombre, telefono, correo, consentimiento_en, prospecto_id, estado (REGISTRADO, EN_SEGUIMIENTO, COMPRO, DESCARTADO), recompensado_en, creado_en | `codigo` es el código personal del cliente que refiere. |
| `prospecto` (existe) | — | El referido entra como prospecto con origen `REFERIDO` por un evento que escucha `ventascrm`, como ya se hace con Estreno. |

## API (`/api/v1/app`)

| Método | Ruta | Uso | Errores |
| --- | --- | --- | --- |
| GET | `/lealtad` | Saldo, nivel, puntos al siguiente nivel y mi código de referido. | — |
| GET | `/lealtad/movimientos` | Movimientos paginados (20, del más nuevo). | — |
| GET | `/lealtad/recompensas` | Recompensas activas con existencia. | — |
| POST | `/lealtad/canjes` | Canjear `{recompensaId}`; regresa código, QR y vigencia. | 409 `SALDO_INSUFICIENTE` · 409 `RECOMPENSA_AGOTADA` · 404 |
| GET | `/lealtad/canjes` | Mis canjes con estado. | — |
| POST | `/lealtad/referidos` | Registrar a un amigo `{nombre, telefono?, correo?, consentimiento}`. | 400 sin teléfono ni correo o sin consentimiento · 409 `REFERIDO_DUPLICADO` · 409 `LIMITE_REFERIDOS` |
| GET | `/lealtad/referidos` | Mis referidos con su estado. | — |
| GET | `/eventos` | `puntos.movidos` en vivo. | — |
| POST | `/api/v1/lealtad/canjes/{codigo}/usar` | Personal de caja o servicio marca usado un canje (mientras el ERP siga congelado). | 404 · 409 `CANJE_NO_VIGENTE` |

## Historias

| ID | Historia | Criterios de aceptación | B | Depende de |
| --- | --- | --- | --- | --- |
| V2-M12.01 | Como cliente quiero ver mis puntos y nivel para saber cuánto llevo y qué me falta para subir | Saldo = suma de `movimiento_puntos` del cliente · nivel por puntos ganados en 12 meses con las reglas de `app.lealtad.*` · barra de progreso con los puntos que faltan (en Oro dice que ya está en el máximo) · el lector lee saldo, nivel y lo que falta · cliente nuevo: 0 puntos en Bronce, sin error · vacío, error y sin conexión resueltos | ✅ | — |
| V2-M12.02 | Como cliente quiero ganar puntos al pagar un servicio para que volver al taller me convenga | Al entregarse una orden con total (`OrdenServicioCambiada` a `ENTREGADA`, M04.07) se suman los puntos de la regla; con M08.02 integrado se suman al confirmarse el pago (`pago.confirmado`) y no también al entregar · el mismo evento repetido no suma dos veces (único por motivo y referencia) · aviso en vivo `puntos.movidos` y el ticket dice cuántos ganó | ✅ | V2-M04.07 |
| V2-M12.03 | Como cliente quiero canjear recompensas para usar mis puntos en la agencia | Confirmación con el costo y el saldo que queda · el canje descuenta los puntos y crea un código con QR vigente 30 días · dos canjes al mismo tiempo nunca dejan el saldo negativo (bloqueo de fila del cliente) · `SALDO_INSUFICIENTE` y `RECOMPENSA_AGOTADA` explicados · «Mis canjes» con su estado · el personal lo marca usado con `/api/v1/lealtad/canjes/{codigo}/usar` · al vencer sin usarse, los puntos regresan con `DEVOLUCION_CANJE` | ✅ | V2-M12.01 |
| V2-M12.04 | Como cliente quiero referir a un amigo para que la agencia lo atienda y yo gane puntos si compra | Mi código personal se comparte con la hoja del sistema · registro a mi amigo con nombre y teléfono o correo y confirmo que aceptó que lo contacten (sin la casilla no se envía) · el backend crea el prospecto con origen `REFERIDO` en `ventascrm` por evento · si ya es cliente o prospecto, `REFERIDO_DUPLICADO` sin decir de quién · hasta 10 abiertos · cuando la venta del prospecto se finaliza (`ProspectoFinalizado`) gano 500 puntos una sola vez · «Mis referidos» con estado | ✅ | V2-M12.01 |
| V2-M12.05 | Como cliente quiero ver mis movimientos de puntos para entender de dónde salió mi saldo | Lista paginada (20, del más nuevo) con puntos (+ en verde, − en el color de texto), motivo en palabras, fecha y a qué se refiere (orden, canje o referido) · la suma de la lista completa es el saldo de V2-M12.01 · vacío, error y sin conexión resueltos | ✅ | V2-M12.01 |

## Fuera de alcance / notas

- Las **reglas son propuestas** hasta que el PO las confirme; cambiarlas solo toca la configuración del backend.
- Puntos por completar el perfil o contestar encuestas (propósito del módulo): el motivo `AJUSTE` ya existe, pero las historias que los otorguen van con M15 o con una historia nueva del planificador.
- Los datos del amigo los escribe quien lo refiere: el aviso de privacidad (V2-M22.10) debe decir que se usan solo para que la agencia lo contacte. El prospecto se crea en `ventascrm` por evento; el CRM web sigue congelado y lo ve como cualquier prospecto.
- Canjear en caja con el QR desde el ERP queda para cuando se descongele; mientras, el endpoint del personal.
