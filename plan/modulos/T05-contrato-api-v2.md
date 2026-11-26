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

## Avance de V2-T05.01

Estado: **En revisión**.

- **Backend:** catálogo de módulos de la v2 en `agencia-360-backend/plan/README.md`. `postventa` vive en `servicio`, `pagosapp` en `caja` y `facturacion`, y el asistente dentro de `carecarapp`; los módulos nuevos nacen con su primera historia. Se crea `archivos` (V2-T05.09); `ModularityTests` lo verifica.

## Avance de V2-T05.02

Estado: **Hecha**.

- **Backend:** `agencia-360-backend/docs/api/agencia360-api-app-v2.yaml`, versión 2.0.0. Es copia del v1 en 1.4.0 con la descripción de la v2; no agrega ni quita rutas, todas siguen bajo `/api/v1/app`. El v1 queda congelado en 1.4.0 como referencia de la app v1 instalada. Diseño en `agencia-360-backend/plan/historias-backend.md`.
- **App:** copia en `api/agencia360-api-app-v2.yaml`. La [prueba del simulador v2](../../test/contrato/mock_api_v2_test.dart) comprueba las operaciones registradas y respuestas HTTP contra esa copia. `contrato_test.dart` sigue cubriendo v1.
- **Desde aquí:** cada historia B escribe sus rutas en el v2 bajo la etiqueta de su módulo, sube la versión menor y copia el archivo a este repo al integrar.

## Avance de V2-T05.03

Estado: **Hecha**.

- **Backend:** `cuenta_app.usuario` (único), lleno con el correo del cliente; el login y la recuperación buscan la cuenta por ese usuario. El módulo de clientes expone `DirectorioClientes.cambiarCorreo` y publica `CorreoDeClienteCambiado`; la cuenta cambia de usuario en la misma transacción. Diseño en `agencia-360-backend/plan/historias-backend.md`.
- **App:** sin cambios; el login sigue mandando `correo`. V2-M01.07 usa `cambiarCorreo` al confirmar el correo nuevo.

## Avance de V2-T05.04

Estado: **Hecha**.

- **Backend:** `token_recuperacion` (`cuenta_app_id`, `token_hash`, `expira`, `usado`, más `codigo_hash`, `usado_en` e `intentos`) reemplaza a `codigo_recuperacion`, que se borra tras pasar sus códigos. El correo trae un enlace de un solo uso (`carecar://restablecer-contrasena?token=...`, configurable con `RECUPERACION_ENLACE`) y el código de 6 dígitos para la app v1; usar uno cierra el otro.
- **Contrato:** v2 en 2.3.0. `POST /auth/restablecer-contrasena` acepta `token` o `correo` con `codigo`. Compatible con la app v1.
- **App:** sin cambios en esta historia; V2-M01.04 abre el enlace y manda `token`.

## Avance de V2-T05.05

Estado: **Hecha**.

- **Backend:** `manual.archivo` se renombra a `archivo_pdf` (sigue siendo la clave del PDF). Sin cambios de rutas.
- **App:** sin cambios.

## Avance de V2-T05.06

Estado: **Hecha**.

- **Backend:** la tabla `servicio` pasa a ser `orden_servicio`, con sus mismos ids, y gana `mano_de_obra`, `refacciones`, `estatus` y `fecha_cierre`; la base exige `total = mano_de_obra + refacciones`. Los renglones de `renglon_servicio` se reparten en `orden_refaccion` (`refaccion_id`, `cantidad`, `precio`, más `concepto` e `importe`) y `orden_mano_de_obra`, que se agrega para no perder el detalle de la mano de obra. Las órdenes existentes quedan `TERMINADO` con su fecha de cierre. Diseño en `agencia-360-backend/plan/historias-backend.md`.
- **Estatus:** los mismos cuatro de PO-5 que ya devuelve la app (`RECIBIDO`, `EN_PROCESO`, `TERMINADO`, `ENTREGADO`); `Servicio.estatus` ahora sale de la orden.
- **Contrato:** v2 en 2.2.0, solo cambia la descripción de `Servicio.estatus`. Sin rutas nuevas ni cambios de forma.
- **App:** sin cambios. Copia del contrato en `api/agencia360-api-app-v2.yaml`. Desbloquea V2-M02.05 y V2-M02.06.

## Avance de V2-T05.07

Estado: **Hecha**.

- **Backend:** tabla `franja_horario` (`dia_semana`, `hora_inicio`, `hora_fin`, `capacidad`, más `activa`) sembrada con el horario que tenía `HorarioTaller`: lunes a sábado, de 9:00 a 17:00, franjas de una hora con capacidad 3. `cita.franja_id` pasa a ser el id de esa tabla, con FK, y las citas existentes se migran por día de la semana y hora de inicio. El cupo es la capacidad de la franja menos sus citas confirmadas de esa fecha. Diseño en `agencia-360-backend/plan/historias-backend.md`.
- **Contrato:** v2 en 2.1.0. Mismas rutas y formas; `franjaId` queda descrito como id de `franja_horario` y una franja de otro día o inactiva responde 400.
- **App:** sin cambios. Ya toma `franjaId` de la disponibilidad y lo manda con su fecha al agendar y reprogramar. Copia del contrato en `api/agencia360-api-app-v2.yaml`.
- **Franjas:** no hay pantalla para editarlas (el ERP está congelado); se cambian con SQL sobre `franja_horario`.

## Avance de V2-T05.08

Estado: **En revisión**.

- **Órdenes en vivo:** `GET /eventos` (Server-Sent Events, token de la app). Cuando cambia una orden de servicio de sus vehículos llega el evento `orden` con `ordenId`, `vehiculoId` y `estatus`; la app vuelve a consultar. Latido cada 25 s y cierre a los 30 min para reconectar con el token.
- **Chat:** WebSocket STOMP en `/ws` con `Authorization: Bearer` en el `CONNECT`; solo `/user/queue/...` y `/app/...`. Lo usará M07.
- **Contrato:** v2 en 2.4.0 (`/eventos`, esquema `AvisoOrden` y la sección de tiempo real en `info`). Desbloquea V2-M04.03.

## Avance de V2-T05.09

Estado: **En revisión**.

- **Backend:** módulo `archivos` con `AlmacenArchivos` (guardar, leer, borrar, URL temporal). Por omisión guarda en la tabla `archivo` de PostgreSQL (Neon en producción); en desarrollo puede usar una carpeta. Solo JPEG, PNG, WebP y PDF hasta 20 MB.
- **URL firmadas:** `/api/v1/archivos/{carpeta}/{id}?expira=&firma=`, vencen a los 15 minutos y no piden token.
- **App:** sin cambios; recibirá estas URL en las evidencias (M04), documentos (M09) y traslados (M17).
