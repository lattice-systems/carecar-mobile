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
