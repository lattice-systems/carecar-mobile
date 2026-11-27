# 0009 · Pagos y facturas simulados

**Estado:** Aceptada. La aprobaron el SM (Daniel Ojeda Luna) y el PO (Haziel Hernández).

Historia: [V2-M08.01](../../plan/modulos/M08-pagos-y-facturas.md). Aplica a V2-M08.02 a V2-M08.07.

## Contexto

M08 pide pagar la orden de servicio desde la app con tarjeta, Apple Pay o Google Pay. También pide guardar tarjetas, capturar datos fiscales y descargar la factura en PDF y XML. La ficha (sección 8) pide las tablas `pago_app`, `metodo_pago`, `perfil_fiscal`, `factura` y `orden_servicio`, y R1 exige que existan con esos nombres.

Restricciones del equipo:

- **Costo cero y nada de cobros.** Es un proyecto escolar. No se mueve dinero real, no se paga ninguna comisión, cuota ni membresía, y nadie del equipo pone una tarjeta propia.
- **Ninguna cuenta externa.** No se dan de alta servicios de terceros (procesadores de pago, proveedores de timbrado, Apple Developer, consolas de Google). Tampoco se guardan llaves ni secretos nuevos en Azure o en GitHub.
- **Todo funcional.** El flujo completo tiene que funcionar de punta a punta en la app, en el backend y en `mock_api`, con sus pruebas, sin depender de que un tercero esté arriba.
- **Las reglas que ya existían.** La app nunca ve ni envía el número completo de una tarjeta. Un doble toque no cobra dos veces. Hay estados `pendiente`, `pagado`, `fallido` y `reembolsado`. El dinero no se borra: un reembolso es un movimiento inverso.

## Primera propuesta, que no se aprobó

La primera versión de esta ADR comparó procesadores y proveedores de timbrado (PAC) que funcionan en México. Revisó comisiones, SDK de Flutter, 3-D Secure, billeteras, tarjetas guardadas y modo de pruebas (fuentes consultadas el 2026-11-25, al final). Proponía Stripe para cobrar y Facturama para timbrar, los dos en su modo de pruebas.

| | Stripe | Mercado Pago | Conekta / Openpay | Facturama (PAC) |
| --- | --- | --- | --- | --- |
| Costo real | 3.6 % + $3 MXN por cobro | 3.49 % + IVA + $4 por venta | No se revisó | $1,650 MXN al año + $0.50 por folio |
| Modo de pruebas | Gratis, **con cuenta** | Gratis, **con cuenta** | Gratis, **con cuenta** | Sandbox gratis, **con cuenta** y CSD de prueba cargados |
| Lo que exige al equipo | Llave secreta y secreto del webhook en Azure, webhook público, cambiar `MainActivity` a `FlutterFragmentActivity` | SDK propio por plataforma | Paquetes de terceros poco mantenidos | Usuario y contraseña en Azure |
| Apple Pay | Necesita Apple Developer ($99 USD al año) y su *merchant ID* | No confirmado | No revisado | — |

**El SM y el PO no la aprobaron.** Aunque el modo de pruebas no cobra, cada opción obliga a crear cuentas externas a nombre de alguien del equipo, a guardar llaves de terceros y a depender de un servicio que puede cambiar sus condiciones o caerse en plena demostración. Apple Pay, además, cuesta. Nada de eso cabe en las restricciones de arriba.

## Decisión

**Procesador y timbrado simulados, propios del proyecto**, en todos los ambientes. Se cumplen las mismas reglas que con un procesador real, así que el flujo es completo, pero ningún dato sale del sistema y no se cobra nada.

### Backend

- Interfaz **`ProcesadorPagos`** con una sola implementación, **`ProcesadorSimulado`**, que decide por la tarjeta de prueba que eligió la app:
  - una aprobada;
  - una rechazada por fondos insuficientes;
  - una que pide 3-D Secure;
  - una cuyo 3-D Secure falla.
- Lo que la ficha pide del procesador se guarda con valores simulados: `pago_app.procesador = SIMULADO`, `intencion_id` y `token_procesador` con prefijo `sim_`.
- Cada intento de pago lleva su **llave de idempotencia** (`Idempotency-Key`). El pago nace `pendiente` y se confirma en un paso aparte, como lo haría el aviso de un procesador real. Después queda `pagado` o `fallido` con su motivo y se avisa en vivo con `pago.confirmado`.
- El personal puede marcar una orden como **pagada en caja**, para que nadie la pague dos veces mientras la caja del ERP siga congelada.
- Interfaz **`Timbrador`** con una sola implementación, **`TimbradorSimulado`**:
  - arma el XML con la estructura de CFDI 4.0 (emisor, receptor, conceptos e IVA) y un timbre simulado (UUID, fecha y un sello que dice `SIMULADO`);
  - genera el PDF con OpenPDF, que ya es dependencia del backend;
  - rechaza como lo haría un PAC (`TIMBRADO_RECHAZADO` con el dato a corregir).
- El PDF y el XML se guardan en el módulo `archivos` y la app los descarga con su token por `GET /facturas/{id}/pdf` y `/xml` (ver «Ajustes al implementar»).
- **Emisor de prueba:** el RFC de prueba del SAT `EKU9003173C9` («ESCUELA KEMPER URGATE», código postal 42501, régimen 601) en `application.properties`. No es secreto. Cambiar al de la agencia es cambiar esas propiedades.
- **Qué dice la factura:**
  - un concepto por renglón del ticket;
  - mano de obra con clave 78181500 (mantenimiento y reparación de vehículos) y unidad E48 (unidad de servicio); refacciones con su clave de pieza del catálogo del SAT;
  - IVA de 16 %, método de pago PUE (una sola exhibición);
  - forma de pago 04 (tarjeta de crédito) o 28 (débito) según la tarjeta de prueba. Las billeteras simuladas van con 04.
- **Catálogos del SAT dentro del proyecto:** régimen fiscal y uso de CFDI de CFDI 4.0, con la persona a la que aplica cada clave y los regímenes que acepta cada uso. Se sirven en `GET /catalogos-fiscales` para que la app y el backend usen la misma lista. La validación del RFC (forma, fecha y dígito verificador) es código propio.
- **Pruebas sin red y sin falsos especiales:** como la implementación simulada es la de producción, `./mvnw verify` prueba el mismo código que corre en Azure.

### App

- **Hoja de pago propia** en `lib/modulos/pagos/` (interfaz `PasarelaPago` en `dominio/tarjetas.dart` y `PasarelaSimulada` en `datos/`), hecha con el sistema de diseño. Se pensó en `lib/nucleo/pagos/`, pero solo la usa M08, así que vive en su módulo (V2-M08.02):
  - pide tarjeta, vencimiento y CVV y los valida en el teléfono (algoritmo de Luhn, fecha y largo);
  - **solo acepta las tarjetas de prueba listadas**, para que nadie escriba una real por error;
  - **nunca envía el número completo**: manda un token de prueba, la marca y los últimos 4. El backend nunca recibe ni guarda un número de tarjeta;
  - pantalla de 3-D Secure simulada («Tu banco pide confirmar»);
  - en Android muestra «Google Pay» y en iPhone «Apple Pay» como billeteras simuladas. Son botones de la hoja propia; no usan las billeteras del teléfono ni piden cuentas.
- **Sin dependencias nuevas** (no entra `flutter_stripe`). `MainActivity` no cambia, ni la configuración de Android o iOS, ni los flavors.
- **Leyendas visibles:** «Pago simulado, no se cobra» en la hoja de pago y en el detalle del pago; «Factura simulada, sin validez fiscal» en la app y en el PDF.
- Las pantallas de pago, tarjetas, datos fiscales y facturas van con `PantallaSegura` (V2-M22.06).
- `mock_api` simula lo mismo con las mismas reglas, para trabajar sin backend.

## Consecuencias

- **Costo $0 y ninguna cuenta.** No hay llaves, secretos ni servicios de terceros que mantener, y la demostración no depende de nadie más.
- **No se mueve dinero ni hay facturas con validez fiscal.** Es lo que pide un proyecto escolar, y la app lo dice en cada pantalla donde importa.
- **PCI DSS fuera de alcance:** ningún número de tarjeta viaja ni se guarda. Aunque sea simulado, la app conserva la regla de no enviarlo.
- **El cambio a uno real queda abierto.** Un procesador o un PAC reales serían otra implementación de `ProcesadorPagos` o `Timbrador` (y de `PasarelaPago` en la app), decididos en una ADR nueva por el PO. Las tablas, los estados, el contrato y las pantallas no cambian.
- **Apple Pay y Google Pay reales quedan fuera.** Necesitarían cuentas (Apple Developer cuesta $99 USD al año). Las billeteras simuladas cumplen V2-M08.03 en la demostración.
- **Tabla `factura`:** se reutiliza como pide la ficha, agregando columnas y sin quitar ninguna (R1):
  - se agregan `tipo` (`VENTA_UNIDAD` o `SERVICIO`), `orden_servicio_id`, `pago_app_id`, `perfil_fiscal_id`, `uuid_fiscal`, `xml_archivo_id`, `pdf_archivo_id` y `timbrada_en`;
  - las columnas de la venta de un auto dejan de ser obligatorias, y la restricción `ck_factura_tipo` exige las de cada tipo;
  - el código del ERP (`facturacion`) no cambia: sus facturas siguen siendo `VENTA_UNIDAD`.
  - La factura copia los datos del receptor, así que borrar un perfil fiscal no la cambia.
- **Datos fiscales:** se validan con las reglas de CFDI 4.0 (V2-M08.05). Entran en la copia de mis datos (V2-M22.02) y se borran al cancelar la cuenta (V2-M22.03). Las facturas se conservan.
- **Puntos de lealtad (V2-M12.02):** se dan al pagar o al entregar la orden, lo que pase primero, y una sola vez por orden.

## Ajustes al implementar V2-M08.03 y V2-M08.06

Cambian el cómo, no la decisión:

- **Descarga por endpoint, no por URL firmada.** El PDF y el XML se sirven en el cuerpo de `GET /facturas/{id}/pdf` y `/xml`, como adjunto, `no-store` y solo para el dueño (404 si es ajena), igual que el ticket. Una URL firmada no agrega nada a la app y pediría otra llave.
- **El ERP no ve las facturas de la app.** Su entidad `Factura` (`facturacion`) gana `@SQLRestriction("tipo = 'VENTA_UNIDAD'")`; lo demás de ese módulo no cambia. Las de la app son `FacturaApp` en `carecarapp`, con la restricción contraria, y comparten la secuencia de folios con la serie `A`.
- **También se facturan los pagos de pedidos de la tienda** (V2-M14.04): `tipo` `PEDIDO_APP` con `pedido_app_id`; los conceptos son los renglones del pedido.
- **Claves de los conceptos:** mano de obra 78181500/E48 y refacciones 25174800/H87 (accesorios y partes de vehículos, pieza). El IVA se desglosa de los precios con IVA del ticket y el total de la factura es el del pago.
- **Rechazos del timbrado simulado:** razón social de persona moral con el régimen societario («S.A. de C.V.», como pide CFDI 4.0) y código postal menor a 01000; responden 422 `TIMBRADO_RECHAZADO` con `campos`. Si el timbrado al pagar falla, el pago queda `facturable` y se factura después.
- **El XML solo se acepta en la carpeta `facturas`** del módulo `archivos`; las demás siguen sin aceptarlo.

## Fuentes de la primera propuesta (consultadas el 2026-11-25)

- [Stripe · Precios en México](https://stripe.com/en-mx/pricing)
- [Stripe · Métodos de pago admitidos en México](https://support.stripe.com/questions/supported-payment-methods-in-mexico)
- [`flutter_stripe` en pub.dev](https://pub.dev/packages/flutter_stripe)
- [Mercado Pago · Checkouts y comisiones](https://www.mercadopago.com.mx/herramientas-para-vender/check-out?code=homemp)
- [Mercado Pago · SDK nativo](https://www.mercadopago.com.mx/developers/en/news/2025/06/11/The-Mercado-Pago-Native-SDK-is-now-available-)
- [Facturama · API, sandbox](https://facturama.mx/docs/es/api-reference/introduction)
- [Facturama · Planes y folios de API](https://facturama.mx/planes-facturacion)
- [Facturama · CSD de prueba](https://facturama.mx/docs/es/catalogos/csds-pruebas)
