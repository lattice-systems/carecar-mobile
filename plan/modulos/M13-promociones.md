# M13 · Promociones y novedades

| Campo | Valor |
| --- | --- |
| Hito | H4 |
| Dueño | Haziel |
| Revisa | Cristian |
| Ficha técnica | ✅ Sección 13. Promociones y novedades |
| Estado | Borrador |

## Propósito

Ofertas relevantes para **ese** cliente (por modelo, año, kilometraje, servicio pendiente), no spam. Mueve O5.

## Pantallas

- **Para ti** (sección en Inicio) — carrusel de promociones segmentadas.
- **Detalle de promoción** — condiciones, vigencia, cupón, CTA (agendar, comprar, cotizar).
- **Novedades** — noticias de la agencia (eventos, nuevos modelos).

## Datos

| Tabla | Campos | Notas |
| --- | --- | --- |
| `promocion` ➕ | id, titulo, cuerpo, imagen_url, inicia_en, termina_en, segmento (json), cta, cupon | Segmento: modelo, anio, km, mantenimiento pendiente. |
| `promocion_vista` ➕ | id, promocion_id, cliente_id, vista_en, usada_en | Medir conversión. |

## Historias

| ID | Historia | Criterios de aceptación | B | Depende de |
| --- | --- | --- | --- | --- |
| V2-M13.01 | Como cliente quiero ver promociones que apliquen a mi auto | Filtradas por segmento en backend · vigentes | ✅ | V2-M02.01 |
| V2-M13.02 | Como cliente quiero usar una promoción al agendar | Cupón se adjunta a la cita | ✅ | V2-M13.01, V2-M02.08 |
| V2-M13.03 | Como cliente quiero ver novedades de la agencia | Lista con imagen y detalle | ✅ | — |
| V2-M13.04 | Como agencia queremos saber qué promociones funcionan | Vistas y usos registrados (M23) | ✅ | V2-M13.01 |
