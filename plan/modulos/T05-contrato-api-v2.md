# T05 · Contrato API v2 y backend de la app

| Campo | Valor |
| --- | --- |
| Hito | H1 (contrato y alineación con ficha) y siempre |
| Dueño | Ricardo |
| Revisa | Juan Pablo |
| Repo | `agencia-360-backend` (todo **B**) — plan espejo en `agencia-360-backend/plan/` |
| Estado | Listo para historias |

## Propósito

Que el backend tenga **exactamente** las tablas de la ficha y un contrato v2 que crece sin romper la app v1 instalada.

## Historias

| ID | Historia | Criterios de aceptación | B | Depende de |
| --- | --- | --- | --- | --- |
| V2-T05.01 | Como equipo queremos módulos Modulith nuevos para la v2 | Paquetes `notificaciones`, `postventa` (taller en vivo, mantenimiento, garantía), `lealtad`, `pagosapp`, `asistente` según se necesiten · `ModularityTests` verde | ✅ | — |
| V2-T05.02 | Como equipo queremos el contrato `agencia360-api-app-v2.yaml` | Nace como copia de v1 + endpoints nuevos · v1 sigue respondiendo igual · copia en `carecar-mobile/api/` | ✅ | — |
| V2-T05.03 | Como PO quiero `cuenta_app.usuario` como en la ficha | Migración nueva agrega `usuario` (= correo, único) y lo llena · login usa `usuario` · al cambiar correo se actualiza | ✅ | — |
| V2-T05.04 | Como PO quiero `token_recuperacion` como en la ficha | Migración crea `token_recuperacion` (id, cuenta_app_id, token_hash, expira, usado) · recuperación por enlace de un solo uso · `codigo_recuperacion` se retira tras migrar | ✅ | — |
| V2-T05.05 | Como PO quiero `manual.archivo_pdf` como en la ficha | Migración renombra `archivo` → `archivo_pdf` · código y pruebas actualizados | ✅ | — |
| V2-T05.06 | Como PO quiero `orden_servicio` y `orden_refaccion` como en la ficha | Migración lleva `servicio`/`renglon_servicio` a `orden_servicio` (+ `mano_de_obra`, `estatus`, `fecha_cierre`) y `orden_refaccion` (refaccion_id, cantidad, precio) · datos migrados · total = mano de obra + refacciones | ✅ | — |
| V2-T05.07 | Como PO quiero `franja_horario` como en la ficha | Tabla con dia_semana, hora_inicio, hora_fin, capacidad · sembrada con el horario hoy en `HorarioTaller` · `cita.franja_id` con FK · cupo por franja y fecha | ✅ | — |
| V2-T05.08 | Como equipo queremos eventos en vivo para la app | SSE para órdenes y WebSocket para chat detrás de JWT | ✅ | V2-T05.01 |
| V2-T05.09 | Como equipo queremos almacenamiento de archivos para evidencias y documentos | Interfaz de almacenamiento con implementación local y en la nube · URLs firmadas de corta vida | ✅ | — |
| V2-T05.10 | Como equipo queremos datos de ejemplo para cada módulo nuevo | `scripts/cargar-datos-de-ejemplo.sh` extendido | ✅ | — |
