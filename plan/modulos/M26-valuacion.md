# M26 · Valuación y toma a cuenta avanzada

| Campo | Valor |
| --- | --- |
| Hito | H5 |
| Dueño | Cristian |
| Revisa | Ricardo |
| Ficha técnica | No (continúa la calculadora de M03, que sigue siendo no vinculante) |
| Estado | Borrador |

## Propósito

Pasar de la estimación no vinculante a una **valuación formal**: el cliente sube fotos guiadas, agenda inspección y recibe una oferta de la agencia. Mueve O5.

## Historias

| ID | Historia | Criterios de aceptación | B | Depende de |
| --- | --- | --- | --- | --- |
| V2-M26.01 | Como cliente quiero pedir una valuación formal desde mi estimación | Crea solicitud ligada a `estimacion_toma_cuenta` | ✅ | V2-M03.07 |
| V2-M26.02 | Como cliente quiero subir fotos guiadas de mi auto | 8 tomas guiadas (frente, laterales, interior, tablero con km…) con silueta | ✅ | V2-M26.01 |
| V2-M26.03 | Como cliente quiero agendar la inspección física | Reusa agenda con motivo "Valuación" | ✅ | V2-M26.01, V2-M02.08 |
| V2-M26.04 | Como cliente quiero recibir la oferta y aceptarla o rechazarla | Oferta con vigencia · se liga al prospecto de M16 | ✅ | V2-M26.03 |
| V2-M26.05 | Como cliente quiero ver cómo cambia el valor de mi auto con el tiempo | Gráfica de valor estimado por mes | ✅ | V2-M03.04 |
