# M08 · Pagos y facturas

| Campo | Valor |
| --- | --- |
| Hito | H5 |
| Dueño | Ricardo |
| Revisa | Daniel |
| Ficha técnica | ✅ Sección 8. Pagos y facturas |
| Estado | En curso: V2-M08.01, V2-M08.02, V2-M08.04, V2-M08.05 y V2-M08.07 hechas; faltan V2-M08.03 y V2-M08.06; pagos y facturas simulados ([ADR 0009](../../docs/decisiones/0009-procesador-de-pagos-y-timbrado.md)) |

## Propósito

Pagar el servicio desde el celular y llevarse la factura sin pasar a caja. Mueve O5.

## Pantallas

- **Pagar orden** — total y desglose del ticket (M04.07), perfil fiscal para facturar (opcional) y botón «Pagar», que abre la hoja de pago propia de la app, simulada (tarjeta guardada o una de las tarjetas de prueba, y «Apple Pay» o «Google Pay» simulados). Dice «Pago simulado, no se cobra». Al terminar, `ResultadoPantalla` con el estado.
- **Métodos de pago** — tarjetas guardadas (marca, últimos 4, vencimiento), predeterminada y borrar. La app nunca ve el número completo. Se abre desde Perfil → Cuenta → «Métodos de pago» y desde «Mis pagos».
- **Datos fiscales** — perfiles con RFC, razón social, régimen, código postal y uso de CFDI; alta, edición, predeterminado y borrar. Se abre desde Perfil → Cuenta → «Datos fiscales».
- **Mis pagos y facturas** — lista paginada con estado, monto, fecha y referencia; detalle con su factura (PDF y XML) para abrir o compartir, y «Facturar» si se pagó sin perfil fiscal. La factura dice «Factura simulada, sin validez fiscal». Se abre desde Perfil → Cuenta → «Mis pagos».

## Datos

| Tabla | Campos | Notas |
| --- | --- | --- |
| `pago_app` ➕ | id, orden_servicio_id, cliente_id, monto, moneda, procesador, intencion_id, llave_idempotencia, metodo (tarjeta/apple_pay/google_pay/caja), marca, ultimos4, estado (pendiente/pagado/fallido/reembolsado), motivo_fallo, perfil_fiscal_id, pagado_en, creado_en | Integrada en V55 (V2-M08.02). `procesador` = `SIMULADO`; `intencion_id` con prefijo `sim_pi_`. `intencion_id` y (`cliente_id`, `llave_idempotencia`) únicos; índices únicos parciales: un solo pago `PAGADO` y un solo `PENDIENTE` por orden. Campos agregados: `vehiculo_cliente_id`, `tipo_tarjeta`, `token_procesador`, `mes_vence`, `anio_vence`, `guardar_tarjeta`, `metodo_pago_id`, `autenticacion` (3-D Secure), `referencia_caja`, `registrado_por` y `actualizado_en`. El dinero no se borra: un reembolso es otra fila con monto negativo que apunta a la original. |
| `metodo_pago` ➕ | id, cliente_id, procesador, cliente_procesador_id, token_procesador, marca, ultimos4, mes_vence, anio_vence, predeterminado, creado_en | Integrada en V55 (V2-M08.04). Sin PAN ni CVV; `token_procesador` es el de la tarjeta de prueba (`tok_sim_…`) y `cliente_procesador_id` es `sim_cus_<id>`. Se agrega `tipo` (crédito o débito). Una tarjeta por cliente y token; un índice único parcial deja una sola predeterminada; hasta 10 por cliente. |
| `perfil_fiscal` ➕ | id, cliente_id, rfc, razon_social, regimen_fiscal, codigo_postal, uso_cfdi, correo, predeterminado, creado_en | Integrada en V54 (V2-M08.05). RFC de 12 (moral) o 13 (física) caracteres con dígito verificador; régimen y uso con los catálogos del SAT de CFDI 4.0; `actualizado_en`; índice único parcial para un solo predeterminado. |
| `factura` (existe) | se agregan tipo (VENTA_UNIDAD/SERVICIO), orden_servicio_id, pago_app_id, perfil_fiscal_id, uuid_fiscal, xml_archivo_id, pdf_archivo_id, timbrada_en | Se reutiliza (R1). Las columnas de la venta de un auto dejan de ser obligatorias y `ck_factura_tipo` exige las de cada tipo ([ADR 0009](../../docs/decisiones/0009-procesador-de-pagos-y-timbrado.md)). |
| `orden_servicio` (existe) | — | El total a pagar sale de su ticket (M04.07). |

## API (`/api/v1/app`)

| Método | Ruta | Uso | Errores |
| --- | --- | --- | --- |
| POST | `/ordenes/{id}/pagos` | Crea el intento de pago `pendiente` con el token de prueba, la marca y los últimos 4 que manda la hoja propia. Header `Idempotency-Key`. Si la tarjeta de prueba pide 3-D Secure, lo dice. | 404 orden ajena · 409 `ORDEN_NO_PAGABLE` (no está lista o ya está pagada) · 409 `PAGO_EN_CURSO` |
| GET | `/pagos/{id}` | Estado de un pago (la app consulta al volver de la hoja). | 404 |
| POST | `/pagos/{id}/autenticacion` | Resultado del 3-D Secure simulado; confirma o falla el pago. | 404 · 409 `PAGO_NO_PENDIENTE` |
| GET | `/pagos` | Mis pagos, paginado y del más nuevo al más viejo. | — |
| GET · DELETE | `/metodos-pago` · `/metodos-pago/{id}` | Tarjetas guardadas (simuladas). | 404 |
| PUT | `/metodos-pago/{id}/predeterminado` | Marcar la predeterminada. | 404 |
| GET | `/catalogos-fiscales` | Regímenes fiscales y usos de CFDI de CFDI 4.0, con la persona a la que aplican y los regímenes que acepta cada uso. | — |
| GET · POST · PUT · DELETE | `/perfiles-fiscales` · `/perfiles-fiscales/{id}` | Datos fiscales; el primero queda predeterminado. | 400 `DATOS_FISCALES_INVALIDOS` con `campos` · 404 ajeno |
| POST | `/pagos/{id}/factura` | Facturar un pago que se hizo sin perfil fiscal. | 409 `YA_FACTURADO` · 422 `TIMBRADO_RECHAZADO` |
| GET | `/facturas/{id}/pdf` · `/facturas/{id}/xml` | URL firmada de vida corta para descargar. | 404 |
| GET | `/eventos` | `pago.confirmado` y `factura.timbrada` en vivo. | — |
| POST | `/api/v1/caja/ordenes/{id}/pagada-en-caja` | Personal (roles `CAJA` y `ADMINISTRADOR`): marca la orden como pagada en caja, con su referencia opcional, para que no se pague dos veces en la app. Un intento pendiente queda `fallido` con `PAGADA_EN_CAJA`. | 404 · 409 `ORDEN_NO_PAGABLE` |

## Historias

| ID | Historia | Criterios de aceptación | B | Depende de |
| --- | --- | --- | --- | --- |
| V2-M08.01 | Como equipo queremos elegir el procesador de pagos y el PAC para cobrar y facturar desde la app sin costo mientras sea proyecto escolar [ADR 0009](../../docs/decisiones/0009-procesador-de-pagos-y-timbrado.md) compara opciones disponibles en México (comisiones, SDK de Flutter, 3-D Secure, Apple Pay y Google Pay, tarjetas guardadas, modo de pruebas) y la aprueban SM y PO · ✅ aprobada por SM (Daniel Ojeda Luna) y PO (Haziel Hernández): pagos y timbrado simulados y propios, sin cuentas externas ni costo | | — |
| V2-M08.02 | Como cliente quiero pagar mi orden con tarjeta desde la app para no pasar a caja | Desde una orden lista para entrega (M04.06) o su ticket, «Pagar» muestra total y desglose · la hoja de pago propia (simulada) pide una tarjeta de prueba, la valida (Luhn, vencimiento, CVV), manda solo token, marca y últimos 4, y resuelve el 3-D Secure simulado · un segundo toque o un reintento con la misma `Idempotency-Key` no crea otro cobro · el pago nace `pendiente` y queda `pagado` al confirmarse en el backend · rechazo o 3-D Secure fallido: `fallido` con el motivo y se puede reintentar · el ticket marca «Pagado» con fecha y referencia · una orden marcada «pagada en caja» ya no se puede pagar · la hoja dice «Pago simulado, no se cobra» · `PantallaSegura` en la pantalla | ✅ | V2-M08.01, V2-M04.06 |
| V2-M08.03 | Como cliente quiero pagar con Apple Pay o Google Pay para no capturar mi tarjeta | En iOS aparece «Apple Pay» y en Android «Google Pay» como billeteras simuladas de la hoja propia (no usan la billetera del teléfono ni piden cuentas) · el pago queda con `metodo` `apple_pay` o `google_pay` · la hoja dice que es simulado | ✅ | V2-M08.02 |
| V2-M08.04 | Como cliente quiero guardar mis tarjetas para pagar más rápido | Al pagar, casilla «Guardar tarjeta» · se guardan token, marca, últimos 4 y vencimiento, nunca el número · en «Métodos de pago» marco una predeterminada y borro con confirmación · la hoja de pago muestra las guardadas con la predeterminada primero · solo veo las mías | ✅ | V2-M08.02 |
| V2-M08.05 | Como cliente quiero capturar mis datos fiscales para facturar mis servicios | ✅ Alta, edición y borrado de varios perfiles · RFC con formato y dígito verificador del SAT (persona física 13, moral 12) · código postal de 5 dígitos · régimen y uso de CFDI de los catálogos de CFDI 4.0 y solo combinaciones válidas para el tipo de persona · uno predeterminado · error del servidor `DATOS_FISCALES_INVALIDOS` explicado por campo | ✅ | — |
| V2-M08.06 | Como cliente quiero descargar mi factura en PDF y XML para mi contabilidad | Si al pagar elegí perfil fiscal, la factura se timbra al confirmarse el pago; si no, «Facturar» en el detalle del pago · aviso en vivo `factura.timbrada` · abrir y compartir el PDF y el XML con la hoja del sistema · el timbrado es simulado: XML con la estructura de CFDI 4.0 y timbre simulado, PDF con OpenPDF, y el PDF y la app dicen «Factura simulada, sin validez fiscal» · `TIMBRADO_RECHAZADO` explica qué dato corregir | ✅ | V2-M08.05, V2-M08.02 |
| V2-M08.07 | Como cliente quiero ver todos mis pagos para saber qué pagué y cuándo | Lista paginada (20 por página, del más nuevo) con orden, monto, fecha, estado (`pendiente`, `pagado`, `fallido`, `reembolsado`) y referencia · el detalle lleva a su ticket y a su factura · vacío, error y sin conexión resueltos · `PantallaSegura` | ✅ | V2-M08.02 |

## Fuera de alcance / notas

- **Simulado en todos los ambientes** ([ADR 0009](../../docs/decisiones/0009-procesador-de-pagos-y-timbrado.md), aceptada por SM y PO): `ProcesadorSimulado` y `TimbradorSimulado` en el backend y la hoja de pago propia en la app. No hay Stripe, Facturama ni ningún tercero: nada de cuentas externas, llaves ni costo. No se mueve dinero real ni se emiten facturas con validez. Un procesador o PAC reales serían otra implementación de las mismas interfaces, con una ADR nueva del PO.
- Fuera de M08: OXXO, transferencias, meses sin intereses, propinas y pagar citas por adelantado. Los reembolsos los hace la agencia (no hay botón en la app); la app solo muestra el estado `reembolsado`.
- Apple Pay y Google Pay reales quedan fuera: necesitan cuentas (Apple Developer cuesta $99 USD al año). M08.03 se cumple con billeteras simuladas.
- Emisor de prueba: RFC `EKU9003173C9` («ESCUELA KEMPER URGATE», CP 42501, régimen 601) en `application.properties`. Conceptos: mano de obra 78181500 con unidad E48, refacciones con su clave, IVA 16 %, PUE, forma de pago 04 o 28.
- Los puntos por pagar (V2-M12.02) escuchan `pago.confirmado` (V2-M08.02): se suman al pagar o al entregar, lo que pase primero, una sola vez por orden.

## Avance de V2-M08.01

La primera propuesta (Stripe y Facturama en modo de pruebas) **no se aprobó**: aun sin cobrar, pedía cuentas externas, llaves de terceros en Azure y Apple Developer de pago. La [ADR 0009](../../docs/decisiones/0009-procesador-de-pagos-y-timbrado.md) se reescribió como **Aceptada** con pagos y timbrado simulados y propios, aprobada por el SM (Daniel Ojeda Luna) y el PO (Haziel Hernández). La comparación original queda en la ADR como historia de la decisión. Los criterios de V2-M08.02, 03, 04 y 06 se ajustaron a la simulación sin perder ninguna regla: idempotencia, estados, 3-D Secure, sin número de tarjeta y dinero que no se borra.

## Avance de V2-M08.05

**Qué quedó**

- **Backend** (`carecarapp`): migración `V54__crear_perfil_fiscal.sql` con `CHECK` del RFC, del código postal y del régimen, y un índice único parcial que deja un solo predeterminado por cliente. `Rfc` valida forma, fecha real, RFC genéricos y el dígito verificador del SAT. `CatalogoFiscal` trae los 19 regímenes y 22 usos de CFDI 4.0 (sin CP01 ni CN01, que no sirven para facturar un servicio) con la persona a la que aplican y los regímenes que acepta cada uso. `DatosFiscales.validar` junta todos los errores por campo.
- **Errores por campo**: `ApiError` y `Problema` ganan `campos` (opcional, se omite vacío), con `CamposInvalidosException`. Sirve para cualquier formulario futuro.
- **Concurrencia**: un candado de transacción por cliente (`pg_advisory_xact_lock`) evita que dos altas a la vez dejen dos predeterminados; el índice parcial es la red de seguridad.
- **Privacidad**: los perfiles entran en la copia de mis datos (V2-M22.02) y se borran al cancelar la cuenta (V2-M22.03).
- **App** (`lib/modulos/pagos/`): lista «Datos fiscales» y formulario con las mismas reglas que el backend, régimen y uso filtrados por la persona que dice el RFC, y los errores del servidor sobre su campo. Ambas pantallas van con `PantallaSegura`. Rutas `/datos-fiscales`, `/datos-fiscales/nuevo` y `/datos-fiscales/{id}`; la entrada está en Perfil → Cuenta.
- **mock_api**: `/catalogos-fiscales` y `/perfiles-fiscales` con las mismas reglas.
- **Pruebas**: 28 en el backend (dominio, servicio con Mockito e integración HTTP) y 44 en la app (dominio, repositorio, pantallas, ruta segura y contrato), más la de `campos` en `errores_v11_test.dart`. 60 claves nuevas en español e inglés.

**Decisiones**

- **El catálogo vive en el código, no en una tabla**: lo publica el SAT, cambia pocas veces y así la app y el backend no se desfasan (la app lo pide a `/catalogos-fiscales`).
- **La persona sale del RFC** (12 moral, 13 física); no se pregunta aparte, para que no se contradigan.
- **Se valida antes de tomar el candado**, para no bloquear por una petición que de todos modos se rechaza.
- **La factura guardará su propia copia del receptor** (V2-M08.06), así que editar o borrar un perfil no cambia facturas ya emitidas.

**Pendiente / fuera de alcance:** usar el perfil al pagar (V2-M08.02) y al facturar (V2-M08.06); demostrar en celular, que es lo que le falta a la fila de `cumplimiento-ficha.md` para pasar a ✅.

## Avance de V2-M08.02, V2-M08.04 y V2-M08.07

**Qué quedó**

- **Backend** (`carecarapp`): migración `V55__crear_pago_app_y_metodo_pago.sql`. `ProcesadorSimulado` es la única implementación de `ProcesadorPagos`: decide por la tarjeta de prueba (aprobada, fondos insuficientes, pide 3-D Secure, 3-D Secure que falla) y da `intencion_id` `sim_pi_…`. `PagosAppService` revisa que la orden sea del cliente, esté lista para entrega o entregada, tenga línea de tiempo del taller, total mayor a 0 y no esté pagada (409 `ORDEN_NO_PAGABLE`); un intento pendiente de menos de 15 minutos responde 409 `PAGO_EN_CURSO` y uno más viejo queda `fallido` con `AUTENTICACION_VENCIDA`. La misma `Idempotency-Key` devuelve el mismo pago con 200; con otra orden es 400. Un candado por orden (`pg_advisory_xact_lock`) evita dos cobros a la vez y los índices únicos parciales son la red de seguridad.
- **Pagada en caja**: `POST /api/v1/caja/ordenes/{id}/pagada-en-caja` (roles `CAJA` y `ADMINISTRADOR`) deja un pago `CAJA` `PAGADO` con quien lo registró; desde ahí la app ya no la cobra.
- **Evento y puntos**: al quedar pagado se publica `PagoConfirmado` dentro del módulo y `pago.confirmado` en `/eventos`. `LealtadAppService` suma los puntos bajo el candado del saldo del cliente, una sola vez por orden.
- **Tarjetas guardadas**: con `guardarTarjeta` se guardan al aprobarse el pago (marca, últimos 4, tipo, vencimiento y token de prueba); la primera queda predeterminada. `GET`, `PUT …/predeterminado` y `DELETE` de `/metodos-pago`; una vencida no se puede usar (400).
- **Ticket**: `GET /servicios/{id}` gana `pago` (con qué, referencia y fecha) y `pagable`.
- **Privacidad**: los pagos (sin token) y las tarjetas guardadas entran en la copia de mis datos (V2-M22.02); al cancelar la cuenta se borra el token de los pagos y se borran las tarjetas (V2-M22.03). Los pagos se conservan: el dinero no se borra.
- **App** (`lib/modulos/pagos/`): `PantallaPagarOrden` (`/pagar-orden/{id}`) con el desglose, la tarjeta predeterminada o una de prueba, la casilla «Guardar tarjeta», los datos fiscales predeterminados para la factura, la confirmación del banco simulada y el resultado con «Intentar otra vez» (llave nueva) o «Ver mis pagos». Sin conexión se reintenta con la misma llave. `PantallaMisPagos` (`/pagos`), paginada de 20 y en vivo con `pago.confirmado`; `PantallaPago` (`/pagos/{id}`) con el motivo del fallo, «Confirmar con tu banco» y «Ver el ticket»; `PantallaMetodosPago` (`/metodos-pago`). Todas con `PantallaSegura`. El ticket muestra «Pagado» con la referencia y el botón «Pagar» cuando `pagable`.
- **Tarjetas de prueba** (las mismas en backend, app y mock): 4242 4242 4242 4242 (Visa, se aprueba), 5555 5555 5555 4444 (Mastercard), 4000 0566 5566 5556 (Visa débito), 4000 0000 0000 9995 (fondos insuficientes), 4000 0000 0000 3220 (pide confirmar) y 4000 0084 0000 1629 (el banco no confirma). La app las revisa con Luhn, vencimiento y CVV y solo manda el token.
- **mock_api**: los mismos endpoints con las mismas reglas, puntos al pagar y `POST /__mock/ordenes/{id}/pagada-en-caja`.
- **Pruebas**: 27 en el backend (dominio, servicio con Mockito e integración HTTP) más la de lealtad bajo candado; en la app, dominio de tarjetas, repositorio, las cuatro pantallas, la ruta segura, el contrato y el ticket, cada pantalla con la auditoría de accesibilidad en 320.

**Decisiones**

- **La pasarela vive en el módulo** `lib/modulos/pagos/` y no en `lib/nucleo/pagos/`: solo la usa M08 ([ADR 0009](../../docs/decisiones/0009-procesador-de-pagos-y-timbrado.md)).
- **Pagar una orden exige su línea de tiempo del taller**: un servicio registrado ya hecho se paga en la agencia.
- **El 3-D Secure se responde en la misma pantalla** y queda pendiente si la persona se va; se puede confirmar desde el detalle del pago o vence a los 15 minutos.

**Pendiente / fuera de alcance:** factura al pagar (V2-M08.06), billeteras simuladas (V2-M08.03) y demostrar en celular.

## Privacidad de pantalla

Las pantallas de pago y facturas se envuelven con `PantallaSegura` (`lib/nucleo/privacidad/`, V2-M22.06) para bloquear capturas en Android; ver [`docs/seguridad/ocultar-en-selector.md`](../../docs/seguridad/ocultar-en-selector.md). Su prueba usa `ProteccionDeCapturaFake`.
