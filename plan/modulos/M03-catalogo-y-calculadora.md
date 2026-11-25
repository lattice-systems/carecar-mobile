# M03 · Catálogo y calculadora de toma a cuenta

| Campo | Valor |
| --- | --- |
| Hito | H2 |
| Dueño | Cristian |
| Revisa | Haziel |
| Ficha técnica | ✅ Sección 3. Catálogo y calculadora |
| Estado | Listo para historias — **brecha: la calculadora no existe en v1** |

## Propósito

Mostrar lo nuevo de la agencia y despertar el siguiente auto del cliente con una estimación honesta de cuánto vale el suyo. Mueve O1 y O5.

## Pantallas

- **Catálogo** — rejilla/carrusel de modelos activos con foto grande, precio desde, versiones.
- **Detalle de modelo** — galería, colores, versiones, ficha técnica resumida, CTA "Calcular toma a cuenta" y "Quiero probarlo" (M16).
- **Calculadora de toma a cuenta** — elige uno de tus vehículos (o captura otro), km, estado general; muestra rango estimado **no vinculante** y la diferencia contra el modelo elegido.
- **Resultado** — rango, supuestos usados, leyenda "estimación no vinculante", botón para pedir valuación formal (M26).

## Datos

| Tabla | Campos | Notas |
| --- | --- | --- |
| `modelo_catalogo` (ficha) | id, modelo, activo | ➕ marca, anio, version, precio_desde, imagen_url, descripcion (ya existen). |
| `modelo_catalogo_imagen` ➕ | id, modelo_catalogo_id, url, orden, color | Galería. |
| `parametro_toma_cuenta` ➕ | id, modelo, anio, valor_base, depreciacion_anual, factor_km, factor_estado | Tabla editable por la agencia para la estimación. |
| `estimacion_toma_cuenta` ➕ | id, cliente_id, vehiculo_cliente_id, modelo_catalogo_id, km, estado, minimo, maximo, creada_en | Historial de estimaciones (lead suave). |

## API (`/api/v1/app`)

| Método | Ruta | Uso |
| --- | --- | --- |
| GET | `/catalogo` | Existe. |
| GET | `/catalogo/{id}` | Nuevo: detalle con galería y versiones. |
| POST | `/toma-a-cuenta/estimaciones` | Nuevo: devuelve rango mínimo–máximo + supuestos. |
| GET | `/toma-a-cuenta/estimaciones` | Nuevo: mis estimaciones. |

## Historias

| ID | Historia | Criterios de aceptación | B | Depende de |
| --- | --- | --- | --- | --- |
| V2-M03.01 | Como cliente quiero ver el catálogo de modelos actuales para conocer lo nuevo | Solo `activo = true` · foto, nombre, precio desde · vacío y error resueltos | | V2-T02.05 |
| V2-M03.02 | Como cliente quiero el detalle de un modelo con galería y versiones | Galería deslizable con zoom · versiones con precio · ficha resumida | ✅ | V2-M03.01 |
| V2-M03.03 | Como cliente quiero comparar dos o tres modelos lado a lado | Tabla comparativa de precio y especificaciones clave | | V2-M03.02 |
| V2-M03.04 | Como cliente quiero calcular cuánto me darían por mi auto a cuenta de uno nuevo | Elijo uno de mis vehículos (datos precargados) o capturo modelo/año · ajusto km y estado · veo rango mínimo–máximo · **leyenda "estimación no vinculante" siempre visible** | ✅ | V2-M03.01 |
| V2-M03.05 | Como cliente quiero ver la diferencia a pagar contra el modelo que me gustó | Precio del modelo − rango estimado = rango a pagar · también no vinculante | | V2-M03.04 |
| V2-M03.06 | Como agencia quiero que la estimación salga de parámetros que puedo ajustar | La fórmula vive en el backend (`parametro_toma_cuenta`), no en la app · pruebas de la fórmula en backend | ✅ | V2-M03.04 |
| V2-M03.07 | Como cliente quiero guardar y volver a ver mis estimaciones | Lista con fecha y modelo · se puede pedir valuación formal (M26) | ✅ | V2-M03.04 |

## Fuera de alcance / notas

- La estimación **nunca** se presenta como oferta. Texto legal revisado por el PO.

## Avance de V2-M03.01

El catálogo vive en `lib/modulos/catalogo/` y se abre en la ruta `/catalogo` (exige sesión, como toda ruta de módulo). Sigue la estructura de la guía: `dominio/` con `ModeloVigente` y la interfaz `RepositorioCatalogo` en Dart puro, `datos/` con `RepositorioCatalogoApi`, que lee `GET /catalogo` de `CarecarApi`, y `presentacion/` con los proveedores Riverpod y `PantallaCatalogo`.

- **Solo activos:** el backend ya entrega únicamente los modelos vigentes (`GET /catalogo`), por eso la app no vuelve a filtrar. El DTO no trae `activo`.
- **Tarjeta:** cada modelo usa `TarjetaVehiculo` con foto, nombre ("Mazda CX-5 2024") y detalle ("Signature · Desde $450,000"). Sin foto muestra la silueta.
- **Estados:** cargando con esqueleto, datos, vacío, error con reintento y sin conexión, más recargar jalando hacia abajo.
- **Detalle:** al tocar una tarjeta se abre el detalle, ver el avance de V2-M03.02.

## Avance de V2-M03.02

El detalle de un modelo vive en `lib/modulos/catalogo/` y se abre en `/catalogo/:id` al tocar una tarjeta del catálogo (la foto viaja con el `heroTag` `modelo-<id>`).

- **Contrato:** `GET /catalogo/{modeloId}` entra al contrato 1.3.0 con los esquemas `DetalleModeloCatalogo`, `ImagenModelo`, `VersionModelo` y `EspecificacionModelo`. El diseño del backend (tablas `modelo_catalogo_imagen` y `modelo_catalogo_especificacion`, capas, errores y pruebas pedidas) está en `agencia-360-backend/plan/historias-backend.md` (backend#68). La implementación en el backend sigue pendiente: la app trabaja contra `mock_api`, que ya sirve el detalle con galería, versiones y ficha, y responde 404 a un modelo retirado o inexistente.
- **Pantalla:** `PantallaDetalleModelo` muestra la portada, la descripción, la galería (`GaleriaFotos`: se pasa con el dedo o con flechas y al tocar abre el visor con zoom), las versiones con su precio (tocar otra versión abre su detalle, la actual no es tocable) y la ficha resumida. Una sección sin datos no se muestra y, sin galería, la portada es la única foto. Resuelve los cinco estados y explica un modelo que ya no está vigente.
- **Sin conexión:** `CarecarApiConCache` guarda el detalle por id y ahora también guarda todos los campos del catálogo (antes solo `id` y `modelo`).
- **Contrato en la app:** la copia de `api/agencia360-api-app-v1.yaml` pasa a 1.3.0 y trae también lo que el backend ya había agregado a 1.2 (`Vehiculo.color`, `Cita.vehiculo`, el enum de `Servicio.estatus` y los campos completos de `ModeloCatalogo`). `Cita.vehiculo` queda declarado como pendiente en la prueba de contrato.
- **Fuera de esta historia:** los botones "Calcular toma a cuenta" (V2-M03.04) y "Quiero probarlo" (M16) se agregan con sus historias, y la captura de galería y ficha desde el ERP o el CRM no entra porque están congelados.
- **Pruebas:** `test/modulos/catalogo/detalle_modelo_test.dart` cubre la lectura del DTO, el repositorio, los cinco estados, las secciones vacías, claro, oscuro y letra grande, las guías de accesibilidad y las rutas. La prueba de contrato comprueba además el detalle contra `mock_api` cuando está levantada.

## Avance de V2-M03.03

El comparador vive en `lib/modulos/catalogo/` y se abre en `/catalogo/comparar?ids=1,2,3`. No necesita backend: reutiliza `GET /catalogo/{modeloId}` de V2-M03.02, una llamada por modelo, y por eso la historia no es B.

- **Cómo se elige:** en el catálogo, el botón de la barra activa el modo comparar (solo aparece si hay al menos dos modelos con id). Cada tarjeta muestra una casilla, se eligen de dos a tres y la cuarta se bloquea. El botón de abajo dice cuántos faltan y se habilita con dos. Salir del modo borra la selección.
- **Tabla:** una columna por modelo y una fila por dato, con el precio primero y luego la ficha técnica de todos. Las etiquetas se unen sin distinguir mayúsculas ni espacios de los bordes y salen en el orden en que aparecen. Un dato que un modelo no tiene dice "Sin dato". El precio más bajo se resalta con texto, no solo con color, y no se resalta si hay empate o ningún precio.
- **Ajuste a pantallas chicas:** cada columna mide 160 px y la tabla se desliza de lado cuando no cabe, por ejemplo con tres modelos o con la letra al 200 %. Cada celda lee al lector de pantalla "dato, modelo: valor".
- **Estados:** cargando con esqueleto, datos, error con reintento, sin conexión, modelo retirado (`NoEncontrado`) y enlace con ids que no sirven (menos de dos, más de tres, repetidos o no numéricos), que explica cómo llegar en lugar de fallar.
- **Dominio:** `dominio/comparativa.dart` en Dart puro con `filasDeFicha`, `indiceMasBarato` e `idsDeComparativa`.
- **Pruebas:** `test/modulos/catalogo/comparador_test.dart` cubre el dominio, los estados, claro, oscuro y letra grande, las guías de accesibilidad, el modo comparar del catálogo y las rutas.


## Avance de V2-M03.04

La calculadora vive en `lib/modulos/catalogo/` y se abre en `/catalogo/calculadora`, con `?modelo=<id>` cuando el cliente viene del detalle de un modelo (el botón "Calcular toma a cuenta" de ese detalle). El diseño del backend, que cubre también V2-M03.06 y V2-M03.07, está en `agencia-360-backend/plan/historias-backend.md` (backend#69) y el contrato sube a 1.4.0 con `POST` y `GET /toma-a-cuenta/estimaciones`.

- **Qué se pide:** el cliente elige uno de sus vehículos, que parte del primero con su kilometraje ya puesto, o captura marca, modelo (el tipo, como Versa) y año. Ajusta kilometraje (de 0 a 999,999) y estado general (excelente, bueno, regular o malo) y pide la estimación.
- **Qué ve:** el rango mínimo a máximo en pesos y los supuestos con que se calculó (antigüedad, kilometraje esperado y margen). La app no recalcula nada: la fórmula vive solo en el backend. Cada estimación se guarda en el servidor al calcularla, que es lo que usará V2-M03.07 para listarlas.
- **Leyenda:** "Estimación no vinculante" está siempre visible arriba, antes y después del resultado. El texto es provisional y lo debe revisar el PO.
- **Errores:** un 422 (`SIN_PARAMETROS_DE_VALUACION`) explica que la agencia aún no valúa ese auto y manda a pedir una valuación formal. También se resuelven datos rechazados, sin conexión, vehículo o modelo que ya no están y error inesperado. El botón no responde mientras calcula.
- **Capa de API:** `NuevaEstimacionTomaCuenta` (con constructores `deVehiculo` y `capturado`, que impiden mandar las dos formas), `EstimacionTomaCuenta`, `SupuestosEstimacion` y `EstadoVehiculo`, más `estimarTomaACuenta` y `paginaDeEstimaciones` en `CarecarApi`. El listado ya está en la interfaz porque la prueba de contrato exige las dos operaciones del contrato, pero su pantalla es de V2-M03.07.
- **mock_api:** aplica la misma fórmula del diseño del backend con seis parámetros de ejemplo (`parametrosTomaCuenta` en `mock_api/semillas/catalogo.json`), que no son valores de la agencia.
- **Fuera de esta historia:** la diferencia contra el modelo elegido (V2-M03.05), la edición de parámetros (V2-M03.06, el alta de parámetros queda por SQL mientras el ERP esté congelado) y la lista de estimaciones guardadas (V2-M03.07).
- **Pruebas:** `test/modulos/catalogo/calculadora_test.dart` cubre la lectura de kilometraje y año, el repositorio, la captura con validación, los cinco tipos de falla, claro, oscuro y letra grande, las guías de accesibilidad y las rutas. `test/contrato/contrato_test.dart` pasa a 19 operaciones y 26 esquemas y valida contra `mock_api` cuando está levantada.

## Avance de V2-M03.05

La diferencia a pagar sale de la misma estimación de V2-M03.04 y aparece pegada al resultado cuando la calculadora se abrió desde un modelo (`?modelo=<id>`) y ese modelo tiene precio de lista. No necesita backend: la respuesta ya trae `precioDestino`, el precio de lista del modelo al momento de estimar.

- **Cuenta:** `diferenciaAPagar` (Dart puro, `dominio/toma_a_cuenta.dart`) da el rango a pagar como precio menos el máximo estimado y precio menos el mínimo estimado, sin bajar de cero. Es el criterio de la historia: precio del modelo menos rango estimado igual rango a pagar.
- **Si el auto alcanza:** cuando hasta el valor más bajo cubre el precio, la tarjeta muestra $0 y dice que alcanzaría para el precio de lista, en lugar de un rango engañoso.
- **No vinculante:** la tarjeta lo repite en su texto y la leyenda de arriba sigue siempre visible.
- **Sin modelo o sin precio:** no se muestra la tarjeta. La calculadora abierta sin modelo funciona como en V2-M03.04.
- **Pruebas:** `test/modulos/catalogo/calculadora_test.dart` cubre la resta, el precio ausente, el piso en cero, el caso cubierto, la tarjeta en pantalla, claro, oscuro y letra grande, y las guías de accesibilidad.

## Avance de V2-M03.07

Las estimaciones guardadas se ven en `/catalogo/estimaciones`, desde el botón de historial de la barra de la calculadora. No hay paso de guardar: el backend guarda cada estimación al calcularla (diseño en backend#69), así que esta historia solo las lee con `GET /toma-a-cuenta/estimaciones`.

- **Lista:** de la más reciente a la más antigua, con fecha, rango y, si hubo, el modelo contra el que se estimó. Se piden de a 20 con el botón "Ver más". Si falla una página siguiente, avisa y deja reintentar sin perder lo ya cargado.
- **Detalle:** tocar una fila abre una hoja con la leyenda no vinculante, el rango, los supuestos y la diferencia a pagar tal como se vieron. No recalcula: un cambio de parámetros de la agencia no reescribe lo ya mostrado. `ResultadoEstimacion` y `DiferenciaEstimacion` salieron a `tarjetas_estimacion.dart` para compartirse con la calculadora.
- **Estados:** cargando con esqueleto, datos, vacío con botón a la calculadora, error con reintento y sin conexión, y recargar jalando hacia abajo.
- **Pendiente de otra historia:** pedir una valuación formal desde una estimación es V2-M26.01, que depende de esta.
- **Pruebas:** `test/modulos/catalogo/mis_estimaciones_test.dart` cubre el repositorio, la lista, el detalle, la paginación y su fallo, los cinco estados, claro, oscuro y letra grande, las guías de accesibilidad y las rutas.

## Avance de V2-M03.06

El backend ya está construido (backend#84). La fórmula vive en `CalculadoraTomaCuenta`, sin Spring ni base y con `BigDecimal` para que los resultados sean exactos, y sus valores salen de `parametro_toma_cuenta`. La migración `V34` crea esa tabla y `estimacion_toma_cuenta`, y `POST` y `GET /api/v1/app/toma-a-cuenta/estimaciones` ya responden según el contrato que la app usa.

- **Pruebas en el backend:** `CalculadoraTomaCuentaTest` cubre un auto nuevo, con los kilómetros esperados, con el doble y con cero, cada estado, los límites de 0.5 y 1.2 del ajuste por kilómetros y el redondeo a 100. `TomaCuentaIntegrationTest` cubre 201, 400, 404, 422, 401 y 403, el orden y la paginación del historial y que una estimación guardada no cambie si cambia el parámetro.
- **Pendiente del PO:** los valores reales de `parametro_toma_cuenta`. La migración no trae filas, así que contra el backend real todo auto responde 422 (`SIN_PARAMETROS_DE_VALUACION`) hasta que se capturen por SQL, porque el ERP está congelado. Los parámetros de `mock_api` son solo ejemplos.
- **Pendiente del PO:** el texto de la leyenda no vinculante es provisional y debe revisarlo.

## Rediseño: encabezados ligeros (V2-T02.21)

El catálogo, el detalle del modelo, el comparador, la calculadora y «Mis estimaciones» dejaron el `AppBar` de Material: el catálogo y el detalle usan `MarcoPantalla` (el botón de comparar va en la barra, con regreso a la izquierda; el botón «Comparar» de abajo es una `BarraInferior`) y el comparador, la calculadora y las estimaciones usan `BarraPantalla`. Sin cambios de lógica ni de criterios.
