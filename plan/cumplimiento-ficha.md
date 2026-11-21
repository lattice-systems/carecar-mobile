# Matriz de cumplimiento de la ficha técnica v1.1

Cada requisito de la [ficha](../docs/ficha-tecnica/README.md) tiene una fila. Una fila pasa a ✅ solo con **prueba automática enlazada** (app y/o backend). Toda historia que toque M01–M03 actualiza esta tabla en su PR.

Leyenda: ✅ cumple con prueba · 🟡 cumple sin prueba o en v1 (falta v2) · ❌ brecha · ➕ extensión v2 permitida (no contradice la ficha).

Estado inicial levantado contra `main` de `carecar-mobile` (PR #12) y `agencia-360-backend` (PR #57).

## Tablas

| Tabla (ficha) | Campos (ficha) | En backend hoy | Estado | Historia que lo cierra |
| --- | --- | --- | --- | --- |
| `cliente` | id, prospecto_id, nombre, telefono, correo | Igual (+ auditoría) | 🟡 | V2-M01.07 |
| `cuenta_app` | id, cliente_id, usuario, contrasena_hash, debe_cambiar_contrasena, activa | **Falta `usuario`** (se usa `cliente.correo`); extra `intentos_fallidos`, `bloqueada_hasta` | ❌ | V2-T05.03 |
| `token_recuperacion` | id, cuenta_app_id, token_hash, expira, usado | Existe como **`codigo_recuperacion`** (código, no enlace; `cuenta_id`, `codigo_hash`, `expira_en`, `usado_en`) | ❌ | V2-T05.04, V2-M01.04 |
| `vehiculo_cliente` | id, cliente_id, vehiculo_id, vin, modelo, anio, placas, kilometraje | Igual (+ `color`) | 🟡 | V2-M02.01 |
| `manual` | id, modelo, anio, archivo_pdf | Campo se llama **`archivo`** (+ `marca`, tamaño) | ❌ | V2-T05.05 |
| `orden_servicio` | id, vehiculo_cliente_id, mano_de_obra, total, estatus, fecha_cierre | Existe como **`servicio`** (sin `mano_de_obra`, `estatus`, `fecha_cierre`; tiene `fecha`, `subtotal`, `iva`) | ❌ | V2-T05.06 |
| `orden_refaccion` | id, orden_servicio_id, refaccion_id, cantidad, precio | Existe como **`renglon_servicio`** | ❌ | V2-T05.06 |
| `franja_horario` | id, dia_semana, hora_inicio, hora_fin, capacidad | **No existe** (horario en código: `HorarioTaller`) | ❌ | V2-T05.07 |
| `cita` | id, vehiculo_cliente_id, franja_id, fecha, estado | Igual (+ `cliente_id`, horas, `cancelada_en`); `franja_id` sin FK porque no hay tabla | 🟡 | V2-T05.07 |
| `modelo_catalogo` | id, modelo, activo | Igual (+ marca, año, versión, precio, imagen, descripción) | 🟡 | V2-M03.01 |

## Funcionalidades

| Módulo | Requisito (ficha) | App v1 | Estado | Historia v2 |
| --- | --- | --- | --- | --- |
| 1 | Inicio de sesión con la cuenta de la agencia, sin registro público | Hecho | 🟡 | V2-M01.01 |
| 1 | Cambio obligatorio de la contraseña temporal | Hecho | 🟡 | V2-M01.03 |
| 1 | Recuperación de contraseña **por correo** con **enlace de un solo uso** que expira | Hecho con **código** de 6 dígitos | ❌ | V2-M01.04 |
| 1 | Gestión del perfil: el cliente edita teléfono y correo | Perfil de solo lectura parcial | ❌ | V2-M01.06, V2-M01.07 |
| 1 | La cuenta puede desactivarse (la app lo respeta) | Backend responde 403 | 🟡 | V2-M01.08 |
| 2 | Consulta de vehículos del cliente | Hecho | 🟡 | V2-M02.01 |
| 2 | Manuales y fichas técnicas por modelo y año | Hecho (PDF + respaldo local) | 🟡 | V2-M02.03, V2-M02.04 |
| 2 | Kilometraje lo actualiza el taller al cerrar servicio (la app lo muestra) | Se muestra | 🟡 | V2-M02.02 |
| 2 | Historial digital de servicios | Hecho (primera página) | 🟡 | V2-M02.05 |
| 2 | Ticket por orden (mano de obra + refacciones = total) | PDF del ticket | 🟡 | V2-M02.06 |
| 2 | Agendar cita en horarios disponibles (cupo por franja y fecha) | Hecho | 🟡 | V2-M02.08 |
| 2 | Cancelar cita desde la app | Hecho | 🟡 | V2-M02.10 |
| 2 | Estados de cita: confirmada, atendida, no asistió, cancelada | Hecho | 🟡 | V2-M02.09 |
| 3 | Catálogo de modelos actuales (`activo`) | Hecho | 🟡 | V2-M03.01 |
| 3 | **Mini calculadora de toma a cuenta con estimación no vinculante** | **No existe** | ❌ | V2-M03.04, V2-M03.05 |
| — | Android e iOS | Hecho | 🟡 | V2-T04.03 |

## Decisión pendiente para el PO

Las brechas de tablas (`token_recuperacion`, `orden_servicio`, `orden_refaccion`, `franja_horario`, `cuenta_app.usuario`, `manual.archivo_pdf`) se cierran con **migraciones nuevas** en el backend que dejen los nombres y campos de la ficha (renombrar o crear y migrar datos). Los campos extra se conservan como ➕. Ver [`T05-contrato-api-v2.md`](modulos/T05-contrato-api-v2.md).
