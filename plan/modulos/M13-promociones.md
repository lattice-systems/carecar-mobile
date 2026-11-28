# M13 · Promociones y novedades

| Campo | Valor |
| --- | --- |
| Hito | H4 |
| Dueño | Haziel |
| Revisa | Cristian |
| Ficha técnica | ✅ Sección 13. Promociones y novedades |
| Estado | Cerrado con catálogo simulado en dev. Catálogo oficial pendiente. |

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


## Simulación de catálogo en dev

CareCar Dev muestra «Para ti» y «Novedades» con datos ficticios del simulador. La promoción vigente se limita al March de la semilla. Una oferta vencida sirve como control. Novedades usa una imagen local y un detalle de ejemplo.

Al agendar desde la promoción, el cliente puede elegir entre sus vehículos elegibles. El simulador verifica elegibilidad y vigencia antes de guardar el cupón ficticio en la cita. Una vista consentida se registra una vez por promoción y cliente. Si ese cliente confirma una cita con el cupón, el simulador registra la fecha de conversión.

La [prueba de contrato del simulador](../../test/contrato/mock_api_v2_test.dart) verifica los cuatro recorridos. Para una demostración con franjas cercanas al día de la prueba, usa [el servidor de flujo](../../mock_api/pruebas/servidor_flujo.js) desde la raíz del repositorio y compila la variante desarrollo. El catálogo y las publicaciones oficiales quedan pendientes de la agencia.
