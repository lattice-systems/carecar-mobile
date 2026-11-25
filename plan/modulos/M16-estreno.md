# M16 · Estreno: prueba de manejo y cotización de auto nuevo

| Campo | Valor |
| --- | --- |
| Hito | H5 |
| Dueño | Daniel |
| Revisa | Haziel |
| Ficha técnica | ✅ Sección 16. Estreno |
| Estado | Listo para historias |

## Propósito

Convertir el interés del catálogo en una venta: el cliente pide prueba de manejo o cotización y se crea un prospecto en el backend (`ventascrm`), con la toma a cuenta adjunta. Mueve O5.

## Pantallas

Se entra desde el detalle de un modelo del catálogo (M03.02) con dos píldoras: «Quiero probarlo» (llena) y «Cotizar» (vidrio). Todo con componentes del sistema y el estilo vidrio líquido.

- **Quiero probarlo** — modelo ya elegido; día (`Calendario`, desde mañana) y franja mañana/tarde (`ChipPista`); estimación de toma a cuenta opcional; píldora «Enviar». Confirmación con lo pedido y «Un asesor te contactará».
- **Cotización** — enganche (campo con mínimo visible) y plazo (`ChipPista` con los plazos permitidos); la mensualidad se recalcula en el backend al cambiar algo y se muestra grande con la leyenda no vinculante; estimación de toma a cuenta opcional; «Enviar cotización».
- **Mis solicitudes** — lista con `Insignia` de estado (Recibida, En atención con nombre del vendedor, Cerrada); acceso desde Perfil y desde la confirmación.
- Sucursal: fuera hasta V2-M27.02 (hoy la agencia es una).

## Datos

Reutiliza `prospecto` del módulo `ventascrm` (origen = `APP_CARECAR`, cliente existente). ➕ `solicitud_estreno` (id, cliente_id, modelo_catalogo_id, tipo, preferencia, estimacion_toma_cuenta_id, prospecto_id, estado).

## Historias

| ID | Historia | Criterios de aceptación | B | Depende de |
| --- | --- | --- | --- | --- |
| V2-M16.01 | Como cliente quiero pedir una prueba de manejo | Día (desde mañana) y franja · confirmación con lo pedido · el CRM recibe un prospecto con origen `APP` asignado a un vendedor · duplicado abierto explicado · cinco estados (carga, error con reintento, sin conexión, éxito, duplicado) | ✅ | V2-M03.02 |
| V2-M16.02 | Como cliente quiero cotizar un auto nuevo con mensualidad estimada | Enganche con mínimo y plazos permitidos · mensualidad calculada en el backend y leyenda no vinculante siempre visible · modelo sin precio explicado · enviar la cotización crea la solicitud | ✅ | V2-M03.02 |
| V2-M16.03 | Como cliente quiero adjuntar mi estimación de toma a cuenta | Elegir una de mis estimaciones (M03.07) en prueba o cotización · queda ligada a la solicitud y al prospecto | ✅ | V2-M03.07 |
| V2-M16.04 | Como cliente quiero ver el estado de mis solicitudes | Lista paginada con estado en `Insignia` con texto y vendedor cuando hay · vacío y error resueltos | ✅ | V2-M16.01 |

## Diseño técnico

Contrato 2.10.0 y backend en [`historias-backend.md`](https://github.com/lattice-systems/agencia-360-backend/blob/main/plan/historias-backend.md) (sección M16): `POST /estreno/cotizaciones/calculo`, `POST /estreno/solicitudes`, `GET /estreno/solicitudes`. App: módulo `lib/modulos/estreno/` con `RepositorioEstreno` (API y falso) y `mock_api` primero.

## Fuera de alcance / notas

- La atención del prospecto ocurre en el CRM web (congelado). La app solo crea el prospecto con el origen correcto; el CRM ya lista prospectos.
