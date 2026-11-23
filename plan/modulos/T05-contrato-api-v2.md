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
| V2-T05.11 | Como equipo queremos desplegar la API en Azure automáticamente en cada merge a `main` | Workflow que construye la imagen en formato OCI, la publica en GHCR y actualiza `ca-agencia360-api` · entrada a Azure por OIDC con identidad administrada (variables de repositorio, sin secretos) · verificación de `/actuator/health` tras desplegar · ver `agencia-360-backend/docs/despliegue-azure-neon.md` (dueño: Daniel) | ✅ | — |

## Avance de V2-T05.02

Estado: **Hecha**.

- **Backend:** `agencia-360-backend/docs/api/agencia360-api-app-v2.yaml`, versión 2.0.0. Es copia del v1 en 1.4.0 con la descripción de la v2; no agrega ni quita rutas, todas siguen bajo `/api/v1/app`. El v1 queda congelado en 1.4.0 como referencia de la app v1 instalada. Diseño en `agencia-360-backend/plan/historias-backend.md`.
- **App:** copia en `api/agencia360-api-app-v2.yaml`. La prueba de contrato (`test/contrato/contrato_test.dart`) sigue leyendo el v1; pasarla al v2 es V2-T03.06.
- **Desde aquí:** cada historia B escribe sus rutas en el v2 bajo la etiqueta de su módulo, sube la versión menor y copia el archivo a este repo al integrar.

## Avance de V2-T05.07

Estado: **En revisión**.

- **Backend:** tabla `franja_horario` (`dia_semana`, `hora_inicio`, `hora_fin`, `capacidad`, más `activa`) sembrada con el horario que tenía `HorarioTaller`: lunes a sábado, de 9:00 a 17:00, franjas de una hora con capacidad 3. `cita.franja_id` pasa a ser el id de esa tabla, con FK, y las citas existentes se migran por día de la semana y hora de inicio. El cupo es la capacidad de la franja menos sus citas confirmadas de esa fecha. Diseño en `agencia-360-backend/plan/historias-backend.md`.
- **Contrato:** v2 en 2.1.0. Mismas rutas y formas; `franjaId` queda descrito como id de `franja_horario` y una franja de otro día o inactiva responde 400.
- **App:** sin cambios. Ya toma `franjaId` de la disponibilidad y lo manda con su fecha al agendar y reprogramar. Copia del contrato en `api/agencia360-api-app-v2.yaml`.
- **Franjas:** no hay pantalla para editarlas (el ERP está congelado); se cambian con SQL sobre `franja_horario`.
