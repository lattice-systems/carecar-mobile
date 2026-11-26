# M08 · Pagos y facturas

| Campo | Valor |
| --- | --- |
| Hito | H5 |
| Dueño | Ricardo |
| Revisa | Daniel |
| Ficha técnica | ✅ Sección 8. Pagos y facturas |
| Estado | Listo para historias (V2-M08.01 en revisión) |

## Propósito

Pagar el servicio desde el celular y llevarse la factura sin pasar a caja. Mueve O5.

## Pantallas

- **Pagar orden** — total y desglose del ticket (M04.07), perfil fiscal para facturar (opcional) y botón «Pagar», que abre la hoja de pago del procesador (tarjeta guardada o nueva, Apple Pay o Google Pay). Al terminar, `ResultadoPantalla` con el estado.
- **Métodos de pago** — tarjetas guardadas (marca, últimos 4, vencimiento), predeterminada y borrar. La app nunca ve el número completo.
- **Datos fiscales** — perfiles con RFC, razón social, régimen, código postal y uso de CFDI; alta, edición, predeterminado y borrar.
- **Mis pagos y facturas** — lista paginada con estado, monto, fecha y referencia; detalle con su factura (PDF y XML) para abrir o compartir, y «Facturar» si se pagó sin perfil fiscal.

## Datos

| Tabla | Campos | Notas |
| --- | --- | --- |
| `pago_app` ➕ | id, orden_servicio_id, cliente_id, monto, moneda, procesador, intencion_id, llave_idempotencia, metodo (tarjeta/apple_pay/google_pay), marca, ultimos4, estado (pendiente/pagado/fallido/reembolsado), motivo_fallo, perfil_fiscal_id, pagado_en, creado_en | `intencion_id` y `llave_idempotencia` únicos. El dinero no se borra: un reembolso es otra fila con monto negativo que apunta a la original. |
| `metodo_pago` ➕ | id, cliente_id, procesador, cliente_procesador_id, token_procesador, marca, ultimos4, mes_vence, anio_vence, predeterminado, creado_en | Sin PAN ni CVV. Uno predeterminado por cliente. |
| `perfil_fiscal` ➕ | id, cliente_id, rfc, razon_social, regimen_fiscal, codigo_postal, uso_cfdi, correo, predeterminado, creado_en | RFC de 12 (moral) o 13 (física) caracteres; régimen y uso con los catálogos del SAT de CFDI 4.0. |
| `factura` (existe) | se agregan tipo (VENTA_UNIDAD/SERVICIO), orden_servicio_id, pago_app_id, perfil_fiscal_id, uuid_fiscal, xml_archivo_id, pdf_archivo_id, timbrada_en | Se reutiliza (R1). Las columnas de la venta de un auto dejan de ser obligatorias y `ck_factura_tipo` exige las de cada tipo ([ADR 0009](../../docs/decisiones/0009-procesador-de-pagos-y-timbrado.md)). |
| `orden_servicio` (existe) | — | El total a pagar sale de su ticket (M04.07). |

## API (`/api/v1/app`)

| Método | Ruta | Uso | Errores |
| --- | --- | --- | --- |
| POST | `/ordenes/{id}/pagos` | Crea el intento de pago y regresa el `clientSecret` para la hoja de pago. Header `Idempotency-Key`. | 404 orden ajena · 409 `ORDEN_NO_PAGABLE` (no está lista o ya está pagada) · 409 `PAGO_EN_CURSO` |
| GET | `/pagos/{id}` | Estado de un pago (la app consulta al volver de la hoja). | 404 |
| POST | `/pagos/webhook` | Servidor a servidor: confirmación firmada del procesador. Sin JWT. | 400 firma inválida |
| GET | `/pagos` | Mis pagos, paginado y del más nuevo al más viejo. | — |
| GET · DELETE | `/metodos-pago` · `/metodos-pago/{id}` | Tarjetas guardadas; borrar la quita también del procesador. | 404 |
| PUT | `/metodos-pago/{id}/predeterminado` | Marcar la predeterminada. | 404 |
| GET · POST · PUT · DELETE | `/perfiles-fiscales` · `/perfiles-fiscales/{id}` | Datos fiscales. | 400 `DATOS_FISCALES_INVALIDOS` |
| POST | `/pagos/{id}/factura` | Facturar un pago que se hizo sin perfil fiscal. | 409 `YA_FACTURADO` · 422 `TIMBRADO_RECHAZADO` |
| GET | `/facturas/{id}/pdf` · `/facturas/{id}/xml` | URL firmada de vida corta para descargar. | 404 |
| GET | `/eventos` | `pago.confirmado` y `factura.timbrada` en vivo. | — |

## Historias

| ID | Historia | Criterios de aceptación | B | Depende de |
| --- | --- | --- | --- | --- |
| V2-M08.01 | Como equipo queremos elegir el procesador de pagos y el PAC para cobrar y facturar desde la app sin costo mientras sea proyecto escolar | [ADR 0009](../../docs/decisiones/0009-procesador-de-pagos-y-timbrado.md) compara opciones disponibles en México (comisiones, SDK de Flutter, 3-D Secure, Apple Pay y Google Pay, tarjetas guardadas, modo de pruebas) y la aprueban SM y PO | | — |
| V2-M08.02 | Como cliente quiero pagar mi orden con tarjeta desde la app para no pasar a caja | Desde una orden lista para entrega (M04.06) o su ticket, «Pagar» muestra total y desglose · la hoja de pago del procesador pide la tarjeta y resuelve 3-D Secure · un segundo toque o un reintento con la misma `Idempotency-Key` no crea otro cobro · el pago solo queda `pagado` cuando llega el webhook firmado; mientras, `pendiente` · rechazo o 3-D Secure fallido: `fallido` con el motivo y se puede reintentar · el ticket marca «Pagado» con fecha y referencia · `PantallaSegura` en la pantalla | ✅ | V2-M08.01, V2-M04.06 |
| V2-M08.03 | Como cliente quiero pagar con Apple Pay o Google Pay para no capturar mi tarjeta | En iOS aparece Apple Pay y en Android Google Pay dentro de la hoja de pago, solo si el teléfono lo tiene configurado · el pago queda con `metodo` `apple_pay` o `google_pay` · sin configurar, la hoja ofrece solo tarjeta | ✅ | V2-M08.02 |
| V2-M08.04 | Como cliente quiero guardar mis tarjetas para pagar más rápido | Al pagar, casilla «Guardar tarjeta» · se guardan token, marca, últimos 4 y vencimiento, nunca el número · en «Métodos de pago» marco una predeterminada y borro con confirmación (también se borra en el procesador) · la hoja de pago muestra las guardadas con la predeterminada primero · solo veo las mías | ✅ | V2-M08.02 |
| V2-M08.05 | Como cliente quiero capturar mis datos fiscales para facturar mis servicios | Alta, edición y borrado de varios perfiles · RFC con formato y dígito verificador del SAT (persona física 13, moral 12) · código postal de 5 dígitos · régimen y uso de CFDI de los catálogos de CFDI 4.0 y solo combinaciones válidas para el tipo de persona · uno predeterminado · error del servidor `DATOS_FISCALES_INVALIDOS` explicado por campo | ✅ | — |
| V2-M08.06 | Como cliente quiero descargar mi factura en PDF y XML para mi contabilidad | Si al pagar elegí perfil fiscal, la factura se timbra al confirmarse el pago; si no, «Facturar» en el detalle del pago · aviso en vivo `factura.timbrada` · abrir y compartir el PDF y el XML con la hoja del sistema · mientras el timbrado sea de pruebas, el PDF y la app dicen «Factura de prueba, sin validez fiscal» · `TIMBRADO_RECHAZADO` explica qué dato corregir | ✅ | V2-M08.05, V2-M08.02 |
| V2-M08.07 | Como cliente quiero ver todos mis pagos para saber qué pagué y cuándo | Lista paginada (20 por página, del más nuevo) con orden, monto, fecha, estado (`pendiente`, `pagado`, `fallido`, `reembolsado`) y referencia · el detalle lleva a su ticket y a su factura · vacío, error y sin conexión resueltos · `PantallaSegura` | ✅ | V2-M08.02 |

## Fuera de alcance / notas

- **Modo de pruebas en todos los ambientes** mientras sea proyecto escolar (ADR 0009): no se mueve dinero real ni se emiten facturas con validez. Activar cobros y timbrado reales es decisión del PO (cuenta de Stripe activada, módulo API de Facturama y CSD de la agencia).
- Fuera de M08: OXXO, transferencias, meses sin intereses, propinas y pagar citas por adelantado. Los reembolsos los hace la agencia (no hay botón en la app); la app solo muestra el estado `reembolsado`.
- Apple Pay necesita el *merchant ID* en la cuenta de Apple Developer del equipo; mientras no exista, M08.03 se prueba solo en Android.
- Los puntos por pagar (V2-M12.02) escuchan `pago.confirmado` cuando M08.02 esté integrado; antes se ganan al cerrar la orden.

## Privacidad de pantalla

Las pantallas de pago y facturas se envuelven con `PantallaSegura` (`lib/nucleo/privacidad/`, V2-M22.06) para bloquear capturas en Android; ver [`docs/seguridad/ocultar-en-selector.md`](../../docs/seguridad/ocultar-en-selector.md). Su prueba usa `ProteccionDeCapturaFake`.
