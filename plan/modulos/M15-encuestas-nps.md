# M15 · Encuestas y NPS

| Campo | Valor |
| --- | --- |
| Hito | H4 |
| Dueño | Haziel |
| Revisa | Juan Pablo |
| Ficha técnica | No |
| Estado | Listo para historias |

## Propósito

Medir la satisfacción después de cada servicio y cerrar el ciclo cuando algo salió mal. Mueve O7.

## Pantallas

- **Encuesta post-servicio** — NPS 0–10, 3 preguntas cortas (tiempo, trato, limpieza), comentario, calificar al asesor.
- **Gracias** — si NPS ≤ 6, ofrece "¿Quieres que te contactemos?".
- **Respuesta de la agencia** — aparece en la bandeja.

## Datos

| Tabla | Campos | Notas |
| --- | --- | --- |
| `encuesta_servicio` ➕ | id, orden_servicio_id, cliente_id, nps, tiempo, trato, limpieza, comentario, pide_contacto, respondida_en | Una por orden. |

## Historias

| ID | Historia | Criterios de aceptación | B | Depende de |
| --- | --- | --- | --- | --- |
| V2-M15.01 | Como cliente quiero calificar mi servicio al recogerlo | Se ofrece al cerrar orden (push + tarjeta) · una vez por orden · se puede posponer | ✅ | V2-M04.07 |
| V2-M15.02 | Como cliente insatisfecho quiero que me contacten | NPS ≤ 6 → opción de contacto que crea tarea para la agencia | ✅ | V2-M15.01 |
| V2-M15.03 | Como cliente quiero ver la respuesta de la agencia | Llega a la bandeja (M06) | ✅ | V2-M06.04 |
| V2-M15.04 | Como agencia queremos el NPS por periodo y asesor | Endpoint de agregados para analítica (M23) | ✅ | V2-M15.01 |
