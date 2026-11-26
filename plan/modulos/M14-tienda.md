# M14 · Tienda de refacciones y accesorios

| Campo | Valor |
| --- | --- |
| Hito | H5 |
| Dueño | Cristian |
| Revisa | Ricardo |
| Ficha técnica | ✅ Sección 14. Tienda de refacciones y accesorios |
| Estado | V2-M14.01, 02, 03 y 05 hechas. V2-M14.04 en borrador, espera a V2-M08.02 |

## Propósito

Vender accesorios y refacciones originales compatibles con el auto del cliente, con apartado y recogida o instalación en el taller. Mueve O5.

## Pantallas

- **Tienda** (`/tienda`, `/tienda?vehiculo={id}`): productos filtrados por el auto elegido (por omisión el primero del garaje) u opción «Todos los productos», buscador por nombre o código y categorías. Cada producto muestra precio, existencia y si le queda al auto o es para cualquiera. Con algo en el carrito, la barra inferior lo abre. La barra superior abre «Mis pedidos».
- **Producto** (`/tienda/productos/{id}`): foto, precio, código, existencia, compatibilidad con el auto elegido, descripción, lista de modelos y años, cantidad, «Agregar al carrito» e «Instalar en mi próxima cita».
- **Carrito y apartado** (`/tienda/carrito`): cantidades, quitar, recoger en mostrador o instalar en una cita con el selector de citas confirmadas futuras, total, aviso de pago en caja y vigencia. Al apartar cierra con la fecha en que vence.
- **Mis pedidos** (`/tienda/pedidos`): del más reciente al más antiguo, con estado, total, piezas y vencimiento.
- **Pedido** (`/tienda/pedidos/{id}`): estado, motivo de cancelación, vencimiento, avance con la hora de cada cambio, productos, total, instalación (elegir o cambiar de cita, o volver a mostrador) y cancelar con confirmación.

Entrada: la tarjeta «Tienda» del catálogo, que es la pantalla de Explorar. Todas las rutas se alcanzan además por enlace (`carecar://tienda/pedidos/5`).

## Datos

| Tabla | Campos | Notas |
| --- | --- | --- |
| `refaccion` (existe) | — | ➕ publicada_en_app, categoria_app, descripcion_app, foto_url, universal_app. |
| `compatibilidad_refaccion` ➕ | id, refaccion_id, modelo, anio_desde, anio_hasta | |
| `pedido_app` ➕ | id, cliente_id, estado, entrega (mostrador o cita), cita_id, total, vence_en, llave_idempotencia, horas de cada cambio y motivo de cancelación | Aparta existencia con movimiento de inventario y bloqueo de fila. Los primeros seis son los de la ficha y el plan. |
| `pedido_app_renglon` ➕ | id, pedido_app_id, refaccion_id, cantidad, precio | |
| `movimiento_inventario` (existe) | ➕ pedido_app_id | Cada apartado o liberación es un movimiento. La existencia nunca se edita directo. |
| `cita` (existe) | — | La instalación liga el pedido a una cita confirmada. |

El diseño técnico (migración, bloqueos, vencimiento, API del personal y eventos) está en `agencia-360-backend/plan/historias-backend.md`, «Diseño de M14».

## Reglas

- **Estados:** `apartado`, `listo`, `entregado` y `cancelado`. Los calcula el servidor y la app no los deduce. Cancelar y cambiar la instalación solo se ofrecen en `apartado` y `listo`.
- **Vigencia:** 48 horas, o hasta el final del día siguiente a la cita si es para instalar. Pasada, el pedido se cancela y libera las piezas. Al cancelar la cita el pedido vuelve a mostrador y al reprogramarla la vigencia se mueve con ella.
- **Límites:** 3 pedidos sin entregar, 10 renglones por pedido y 10 piezas por renglón. La app respeta los dos últimos en el carrito y explica el primero cuando el servidor lo rechaza.
- **Reintentos:** `Idempotency-Key` es obligatoria. La app genera una por intento de apartado y la reusa mientras el carrito no cambie (productos, cantidades y entrega).
- **Pago:** no se cobra en la app. Se paga en caja.

## API (`/api/v1/app`)

Contrato 2.21.0, etiqueta `Tienda`. Todas responden además 401, 403 `CUENTA_DESACTIVADA` y 404 en lo ajeno.

| Método | Ruta | Uso | Errores propios |
| --- | --- | --- | --- |
| GET | `/tienda/productos` | `vehiculoId`, `categoria`, `q` y paginación (V2-M14.01) | 400 · 404 |
| GET | `/tienda/productos/{productoId}` | Con `vehiculoId` dice `compatible` (V2-M14.01) | 404 |
| POST | `/tienda/pedidos` | `{renglones, entrega, citaId}` con `Idempotency-Key`. 201, o 200 con el ya creado (V2-M14.02 y V2-M14.03) | 400 · 404 · 409 `SIN_EXISTENCIA`, `CITA_NO_DISPONIBLE` o `LIMITE_APARTADOS` · 422 `PRODUCTO_INCOMPATIBLE` |
| GET | `/tienda/pedidos` y `/tienda/pedidos/{pedidoId}` | Mis pedidos y el detalle (V2-M14.05) | 400 · 404 |
| POST | `/tienda/pedidos/{pedidoId}/cancelar` | Libera las piezas (V2-M14.02) | 404 · 409 `PEDIDO_NO_CANCELABLE` |
| PUT | `/tienda/pedidos/{pedidoId}/instalacion` | `{citaId}` o nulo para mostrador (V2-M14.03) | 400 · 404 · 409 `CITA_NO_DISPONIBLE` o `PEDIDO_NO_MODIFICABLE` · 422 `PRODUCTO_INCOMPATIBLE` |
| GET | `/eventos` | Aviso en vivo `pedido.estado` con `pedidoId` y `estado` | — |

## Historias

Cada criterio se comprueba con una prueba automática. La parte de la app vive en `test/modulos/tienda/`.

| ID | Historia | Criterios de aceptación | B | Depende de |
| --- | --- | --- | --- | --- |
| V2-M14.01 | Como cliente quiero ver los accesorios y refacciones compatibles con mi auto para no comprar algo que no le quede | **Dado** mi garaje, **cuando** abro la tienda, **entonces** veo lo compatible con mi primer auto y lo universal, con su existencia. **Cuando** elijo otro auto o «Todos los productos», **entonces** cambia la lista. **Cuando** elijo una categoría o escribo un nombre o código, **entonces** la lista se filtra. **Dado** un producto agotado, **entonces** se ve «Agotado» y no se puede pedir. La tienda resuelve cargando, datos, vacío, error y sin conexión | ✅ | V2-M02.01 |
| V2-M14.02 | Como cliente quiero apartar productos para que me los guarden mientras voy por ellos | **Dado** un carrito, **cuando** lo aparto, **entonces** se reserva la existencia y veo cuándo vence y que pago en caja. **Dado** que se perdió la respuesta, **cuando** reintento el mismo carrito, **entonces** se manda la misma llave y no se duplica. **Los** 409 `SIN_EXISTENCIA` y `LIMITE_APARTADOS` se explican sin perder el carrito. **Dado** un pedido sin entregar, **cuando** confirmo cancelarlo, **entonces** queda cancelado y libera las piezas. **Dado** uno vencido, **entonces** se ve cancelado porque venció | ✅ | V2-M14.01 |
| V2-M14.03 | Como cliente quiero que me instalen lo comprado en mi cita para no hacer otro viaje | **Dado** que aparto o que ya tengo un pedido abierto, **cuando** elijo instalar, **entonces** solo se ofrecen mis citas confirmadas que no han pasado. **Dado** un producto, **cuando** toco «Instalar en mi próxima cita», **entonces** entra al carrito ligado a la cita más próxima de un auto al que le quede. **Sin** citas, se ofrece agendar. **Los** errores `CITA_NO_DISPONIBLE`, `PRODUCTO_INCOMPATIBLE` y `PEDIDO_NO_MODIFICABLE` se explican. El taller ve el pedido en la orden (parte B) | ✅ | V2-M14.02, V2-M02.08 |
| V2-M14.04 | Como cliente quiero pagar mi pedido en la app para solo recogerlo | Reusa M08. Fuera de este avance porque V2-M08.02 no existe: la app dice que se paga en caja | ✅ | V2-M08.02 |
| V2-M14.05 | Como cliente quiero seguir mis pedidos para saber cuándo pasar por ellos | **Dado** mis pedidos, **cuando** abro la lista o uno, **entonces** veo su estado (apartado, listo, entregado o cancelado). **Cuando** llega `pedido.estado` o vuelve la conexión, **entonces** se actualizan sin pasar por carga, y si falla se queda lo que se ve. **Dado** un pedido ajeno, **entonces** se dice que no se encontró. El push con la app cerrada llega con M06 | ✅ | V2-M14.02, V2-M06.02 (solo push) |

## Diseño de la app

Módulo nuevo en `lib/modulos/tienda/`, sin interruptor v1/v2. Sus rutas se registran con una línea en `registro_de_rutas.dart` y `catalogo` solo importa `tienda.dart`. `tienda` no importa `catalogo`.

- **Dominio:** `RepositorioTienda`, `Producto`, `Pedido`, `Carrito` (límites y huella) y `PedidoRechazado` con un motivo por código.
- **Datos:** `repositorio_tienda_api.dart` y `repositorio_tienda_fake.dart`. `ClienteApi.enviar` ahora admite encabezados propios para la llave de idempotencia.
- **Carrito:** vive en memoria y se vacía al cambiar la sesión, igual que el auto elegido. No se guarda en el teléfono.
- **Citas y vehículos:** usa `repositorioCitasProvider` y `relojCitasProvider` de `citas.dart` y `garajeProvider` de `vehiculos.dart`. Las confirmadas futuras se filtran en la app.
- **Compatibilidad:** la decide el servidor. Para «Instalar en mi próxima cita» se consulta el producto con el vehículo de cada cita hasta encontrar una compatible.
- **En vivo:** lista de pedidos, detalle, productos y producto se vuelven a pedir con `pedido.estado` y al volver la conexión. Lo que ya se ve se conserva si la recarga falla.
- **Componentes:** todos existen. No hay historia T02 nueva ni provisionales.
- **Textos:** claves `tienda*` en `app_es.arb` y `app_en.arb`.
- **Simulador:** `mock_api/modulos/tienda.js` con `semillas/tienda.json`. Emisor `POST /__mock/pedidos/{id}/estado` para marcar listo, entregado o cancelado. No tiene proceso programado: cada consulta vence primero lo pasado de hora y sigue a la cita ligada.

## Avance de V2-M14.01, V2-M14.02, V2-M14.03 y V2-M14.05

La app está construida y probada contra el repositorio falso, con el contrato 2.21.0 y su simulador. Las pruebas cubren cada criterio, los temas claro y oscuro, la letra al 200 % y una pantalla de 320 de ancho. El contrato se comprueba en `test/contrato/contrato_tienda_test.dart`.

Pendientes:

- Probar la app contra el backend real y demostrar el flujo en celular.
- La entrada por la interfaz está en el catálogo v2. Mientras `catalogo` siga en v1 por omisión (interruptor de V2-T01.05), en esa compilación la tienda solo se abre por enlace.
- Push con la app cerrada, con M06.
- Pago en la app (V2-M14.04), cuando exista V2-M08.02.
- El carrito no sobrevive a cerrar la app. Si la respuesta de un apartado se pierde y la app se cierra antes de reintentar, el pedido aparece en «Mis pedidos».
- La pantalla no tiene un reloj propio: un apartado que vence con ella abierta cambia con el aviso en vivo o al recargar.
- **Pendiente del PO:** confirmar que el precio de la refacción incluye IVA y los plazos de vigencia.

## Fuera de alcance / notas

- Publicar productos, surtir y entregar pedidos son endpoints del personal. El ERP web sigue congelado, así que no hay pantalla.
- No hay envíos a domicilio.
