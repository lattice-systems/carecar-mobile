# M08 · Pagos y facturas

| Campo | Valor |
| --- | --- |
| Hito | H5 |
| Dueño | Ricardo |
| Revisa | Daniel |
| Ficha técnica | No (usa `orden_servicio.total` de la ficha) |
| Estado | Borrador |

## Propósito

Pagar el servicio desde el celular y llevarse la factura sin pasar a caja. Mueve O5.

## Pantallas

- **Pagar orden** — total, desglose, método (tarjeta guardada, nueva, Apple Pay/Google Pay), confirmación.
- **Métodos de pago** — tarjetas tokenizadas por el procesador (la app nunca ve el número completo).
- **Datos fiscales** — RFC, razón social, régimen, CP, uso de CFDI; varios perfiles.
- **Mis pagos y facturas** — lista con estado; descarga de PDF y XML; reenviar por correo.

## Datos

| Tabla | Campos | Notas |
| --- | --- | --- |
| `pago_app` ➕ | id, orden_servicio_id, cliente_id, monto, procesador, referencia, estado, creado_en | El dinero no se borra: reembolso = movimiento inverso (regla del backend). |
| `metodo_pago` ➕ | id, cliente_id, token_procesador, marca, ultimos4, vence | Sin PAN. |
| `perfil_fiscal` ➕ | id, cliente_id, rfc, razon_social, regimen, cp, uso_cfdi | |
| `factura` (existe) | — | Se reutiliza el módulo `facturacion` del backend. |

## API (`/api/v1/app`)

| Método | Ruta | Uso |
| --- | --- | --- |
| POST | `/ordenes/{id}/pagos` | Crea intención de pago. |
| POST | `/pagos/webhook` (servidor a servidor) | Confirmación del procesador. |
| GET/POST/DELETE | `/metodos-pago` | |
| GET/POST/PUT | `/perfiles-fiscales` | |
| GET | `/facturas` · `/facturas/{id}/pdf` · `/facturas/{id}/xml` | |

## Historias

| ID | Historia | Criterios de aceptación | B | Depende de |
| --- | --- | --- | --- | --- |
| V2-M08.01 | Como equipo queremos elegir el procesador de pagos | Decisión (ADR) comparando opciones disponibles en México, comisiones y SDK Flutter | | — |
| V2-M08.02 | Como cliente quiero pagar mi orden con tarjeta desde la app | 3-D Secure · idempotencia · estado pendiente/pagado/fallido · el ticket marca "pagado" | ✅ | V2-M08.01, V2-M04.06 |
| V2-M08.03 | Como cliente quiero pagar con Apple Pay o Google Pay | Botón nativo según plataforma | ✅ | V2-M08.02 |
| V2-M08.04 | Como cliente quiero guardar mis tarjetas | Tokenizadas · borrar · predeterminada | ✅ | V2-M08.02 |
| V2-M08.05 | Como cliente quiero capturar mis datos fiscales | Validación de RFC y CP · varios perfiles | ✅ | — |
| V2-M08.06 | Como cliente quiero descargar mi factura PDF y XML | Disponible al timbrar · compartir/guardar | ✅ | V2-M08.05 |
| V2-M08.07 | Como cliente quiero ver todos mis pagos | Lista paginada con estado y referencia | ✅ | V2-M08.02 |
