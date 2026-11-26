# 0009 · Procesador de pagos y timbrado de facturas

**Estado:** Propuesta

Historia: [V2-M08.01](../../plan/modulos/M08-pagos-y-facturas.md).

## Contexto

M08 pide que el cliente pague su orden de servicio desde la app con tarjeta, Apple Pay o Google Pay, guarde sus tarjetas, capture sus datos fiscales y descargue su factura en PDF y XML. La ficha (sección 8) pide las tablas `pago_app`, `metodo_pago`, `perfil_fiscal`, `factura` y `orden_servicio`.

Restricciones que ya fija el plan:

- **La app nunca ve el número completo de la tarjeta.** Los datos de la tarjeta van del teléfono al procesador; la app y el backend solo guardan un token, la marca y los últimos 4 dígitos (`metodo_pago` sin PAN). Así el proyecto queda fuera del alcance más pesado de PCI DSS.
- **3-D Secure** cuando el banco lo pida, **idempotencia** (un toque doble no cobra dos veces) y estados `pendiente`, `pagado` y `fallido` (V2-M08.02).
- **El dinero no se borra:** un reembolso es un movimiento inverso, nunca un `delete` (regla del backend).
- **Las llaves secretas solo viven en el backend** y por variables de entorno (AGENTS.md, seguridad). La app solo tiene la llave pública.
- **Costo cero mientras sea proyecto escolar.** El dueño pidió no pagar nada en ningún ambiente (mismo criterio que la ADR 0007).

Hay que revisar también lo que ya existe. La tabla `factura` del backend (migración V16) es la del ERP para la **venta de un auto**: folio interno y PDF, **sin timbrado y sin XML**, y sus columnas de prospecto, venta y unidad son obligatorias. Una factura de servicio no tiene nada de eso, y la factura que pide M08.06 (PDF **y XML**) solo existe si un PAC (proveedor autorizado por el SAT) la timbra.

Hay dos decisiones: quién procesa los pagos y quién timbra las facturas.

## Opciones

### Procesador de pagos

| | Stripe | Mercado Pago | Conekta / Openpay |
| --- | --- | --- | --- |
| Comisión por tarjeta nacional (página oficial, consultada 2026-11-25) | 3.6 % + $3 MXN por cobro exitoso; +0.5 % tarjeta internacional; sin cuota mensual | 3.49 % + IVA + $4 por venta con el dinero al instante (3.19 % a 14 días, 2.95 % a 30 días); sin cuota mensual | No consultada (se descartan por el SDK) |
| SDK de Flutter | `flutter_stripe` 15.0.0, editor verificado `flutterstripe.io` (mantenido por la comunidad, no por Stripe): hoja de pago lista con 3-D Secure, tarjetas guardadas, Apple Pay y Google Pay | Sin SDK oficial de Flutter; el SDK nativo nuevo es para Android e iOS (campos seguros y tokenización), habría que envolverlo en un plugin propio; los paquetes de Flutter que hay son de terceros | Solo paquetes de terceros poco mantenidos (`conekta_flutter` 1.0.0, `openpay2`) |
| Apple Pay y Google Pay en México | Sí (página de soporte de Stripe) | No confirmado para integraciones propias | No revisado |
| Tarjetas guardadas | Clientes y métodos de pago del procesador; la hoja de pago los muestra | Clientes y tarjetas por API | Por API |
| Modo de pruebas | Gratis, con tarjetas de prueba de 3-D Secure y errores | Gratis, con usuarios y tarjetas de prueba | Gratis |
| Webhook firmado | Sí, con secreto de firma | Sí, con firma | Sí |

### Timbrado (PAC)

1. **Facturama (API).** Ambiente de pruebas (*sandbox*) **gratis y sin tarjeta** en `dev.facturama.mx`, autenticación básica, timbra CFDI 4.0 de prueba sin validez ante el SAT. En producción: módulo API de $1,650 MXN al año más $0.50 por folio (de 1 a 10,000; precios con IVA, página consultada 2026-11-25).
2. **Otro PAC por API** (Finkok, SW Sapien, Facturapi, etc.). Ofrecen ambientes de prueba parecidos; no se revisaron a fondo.
3. **Sin PAC.** La factura sale solo en PDF con folio interno, como la del ERP. No cumple M08.06 (pide XML) y no es una factura fiscal.

## Decisión propuesta

**Procesador: Stripe**, en **modo de pruebas en todos los ambientes** mientras sea proyecto escolar (costo $0: en modo de pruebas no se mueve dinero real).

- La app usa `flutter_stripe` con la **hoja de pago** (`PaymentSheet`): pide la tarjeta, resuelve 3-D Secure, muestra las tarjetas guardadas y ofrece Apple Pay o Google Pay según la plataforma. Así ninguna pantalla nuestra toca los datos de la tarjeta.
- El backend crea un **PaymentIntent** por cada intento de pago con una **llave de idempotencia** guardada en `pago_app`, y crea el **Customer** de Stripe del cliente la primera vez que guarda una tarjeta. El cobro solo se da por **pagado** cuando llega el webhook firmado (`payment_intent.succeeded`), nunca por lo que diga la app.
- **Aislamiento:** ningún módulo importa `flutter_stripe` salvo `lib/nucleo/pagos/`, que define la interfaz `PasarelaPago` (presentar la hoja con el `clientSecret` y devolver `pagado`, `cancelado` o `fallido`) con su implementación de Stripe y un fake para pruebas. En el backend, la interfaz `ProcesadorPagos` con la implementación de Stripe por su API REST (cliente HTTP de Spring, sin SDK, como la ADR 0007) y un `ProcesadorPagosFalso` para `./mvnw verify`.
- **Llaves:** la publicable va en la configuración del flavor de la app (no es secreta); la secreta y el secreto del webhook, solo en el backend como `STRIPE_SECRET_KEY` y `STRIPE_WEBHOOK_SECRET` (secretos de Azure en `pruebas` y `produccion`, `.env` local fuera de git). Cada quien usa su propia cuenta de Stripe en modo de pruebas para su backend local.

**Timbrado: Facturama**, en su **sandbox en todos los ambientes** (costo $0).

- El backend timbra al confirmarse el pago si el cliente eligió un perfil fiscal; si no, la orden queda facturable después desde «Mis pagos».
- Interfaz `Timbrador` con la implementación de Facturama y un `TimbradorFalso` para pruebas. Credenciales como `FACTURAMA_USUARIO` y `FACTURAMA_CONTRASENA`.
- El PDF y el XML que regresa el PAC se guardan en el módulo `archivos` (como las evidencias del taller) y se sirven con URL firmada de vida corta.

**Tabla `factura`:** se reutiliza, como pide la ficha, agregando columnas y sin quitar ninguna (R1). Se agrega `tipo` (`VENTA_UNIDAD` o `SERVICIO`), `orden_servicio_id`, `pago_app_id`, `perfil_fiscal_id`, `uuid_fiscal`, `xml_archivo_id`, `pdf_archivo_id` y `timbrada_en`. Las columnas de la venta de un auto (`prospecto_id`, `venta_id`, `vehiculo_id` y las `unidad_*`) dejan de ser obligatorias y una restricción `ck_factura_tipo` exige las de cada tipo. El código del ERP (`facturacion`) no cambia: sus facturas siguen siendo `VENTA_UNIDAD` con los mismos datos.

## Consecuencias

- **Dependencia nueva en la app:** `flutter_stripe`, que pasa por la revisión de dependencias del CI. Pide `MainActivity` como `FlutterFragmentActivity` (hoy es `FlutterActivity`) y un tema basado en AppCompat en Android; en iOS, versión mínima 13 (la app ya está en 15).
- **Apple Pay (M08.03)** necesita un *merchant ID* en la cuenta de Apple Developer del equipo y su certificado cargado en Stripe; **Google Pay** se prueba con el ambiente de pruebas de Google. Sin eso, el botón no aparece y el resto de M08 no se detiene.
- **Webhook:** el backend expone `POST /api/v1/app/pagos/webhook` sin JWT, que solo acepta peticiones con la firma válida de Stripe, y procesa cada evento una sola vez (guarda su id). Para probarlo en local se usa la CLI de Stripe (`stripe listen`).
- **Facturas de prueba sin validez:** en sandbox el XML lleva un UUID de prueba. La app y el PDF dicen «Factura de prueba, sin validez fiscal» mientras el timbrado sea de sandbox.
- **Datos fiscales:** RFC, régimen fiscal, código postal y uso de CFDI se validan con los catálogos del SAT de CFDI 4.0 (el CP debe ser el del domicilio fiscal y el nombre igual al de la constancia; si no coinciden, el PAC rechaza el timbrado y la app lo explica).
- **Pruebas automáticas sin red:** CI corre con `ProcesadorPagosFalso` y `TimbradorFalso` en el backend y con el fake de `PasarelaPago` en la app. El `mock_api` simula el PaymentIntent, el webhook y la factura.

**Lo que decide el PO antes de cobrar de verdad** (fuera del alcance de M08 mientras sea escolar):

1. Activar la cuenta de Stripe en modo real con el RFC, el domicilio y la CLABE de la agencia, y aceptar la comisión (3.6 % + $3 MXN por cobro con la página de hoy).
2. Contratar el módulo API de Facturama ($1,650 MXN al año más $0.50 por folio con la página de hoy) y cargar el certificado de sello digital (CSD) de la agencia.
3. Revisar el aviso de privacidad (V2-M22.10) para nombrar a Stripe y a Facturama como encargados de datos.

## Qué se necesita para aceptarla

1. El PO confirma Stripe y Facturama, y que todos los ambientes usan modo de pruebas mientras sea proyecto escolar.
2. Alguien del equipo crea la cuenta de Stripe en modo de pruebas y la de Facturama en sandbox para `pruebas`, y guarda sus llaves como secretos de Azure.
3. SM y PO aprueban este archivo en el PR; solo entonces V2-M08.02 escribe código.

## Fuentes (consultadas el 2026-11-25)

- [Stripe · Precios en México](https://stripe.com/en-mx/pricing)
- [Stripe · Métodos de pago admitidos en México](https://support.stripe.com/questions/supported-payment-methods-in-mexico)
- [`flutter_stripe` en pub.dev](https://pub.dev/packages/flutter_stripe)
- [Mercado Pago · Checkouts y comisiones](https://www.mercadopago.com.mx/herramientas-para-vender/check-out?code=homemp)
- [Mercado Pago · SDK nativo](https://www.mercadopago.com.mx/developers/en/news/2025/06/11/The-Mercado-Pago-Native-SDK-is-now-available-)
- [Facturama · API, sandbox](https://facturama.mx/docs/es/api-reference/introduction)
- [Facturama · Planes y folios de API](https://facturama.mx/planes-facturacion)
