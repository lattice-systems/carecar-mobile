# M06 · Notificaciones y bandeja

| Campo | Valor |
| --- | --- |
| Hito | H3 |
| Dueño | Jael |
| Revisa | Daniel |
| Ficha técnica | ✅ Sección 6. Notificaciones |
| Estado | Listo para historias |

## Propósito

Un solo sistema de avisos (push + bandeja en la app) que usan todos los módulos, con control total del cliente. Base de O3 y O4.

## Pantallas

- **Bandeja** — avisos agrupados por día, no leídos resaltados, deslizar para archivar, toque abre el destino (deep link).
- **Preferencias** — por categoría: taller en vivo, citas, mantenimiento, documentos, promociones, mensajes; horario silencioso.
- **Permiso** — pantalla previa que explica para qué se piden notificaciones antes del diálogo del sistema.

## Datos

| Tabla | Campos | Notas |
| --- | --- | --- |
| `dispositivo_push` ➕ | id, cuenta_app_id, token_fcm, plataforma, idioma, actualizado_en | Uno por instalación. |
| `notificacion` ➕ | id, cliente_id, categoria, titulo, cuerpo, destino, leida_en, creada_en | Bandeja. |
| `preferencia_notificacion` ➕ | id, cliente_id, categoria, push, silencio_desde, silencio_hasta | |

## API (`/api/v1/app`)

| Método | Ruta | Uso |
| --- | --- | --- |
| PUT | `/dispositivos/{instalacionId}` | Registrar token FCM. |
| GET | `/notificaciones?pagina=` · POST `/notificaciones/{id}/leida` · POST `/notificaciones/leidas` | Bandeja. |
| GET/PUT | `/notificaciones/preferencias` | Preferencias. |

## Historias

| ID | Historia | Criterios de aceptación | B | Depende de |
| --- | --- | --- | --- | --- |
| V2-M06.01 | Como cliente quiero que se me explique por qué la app pide notificaciones | Pantalla previa · si niego, la app funciona y Ajustes ofrece reactivar | | V2-T01.03 |
| V2-M06.02 | Como cliente quiero recibir push de la agencia en Android e iOS | Token FCM registrado tras login y borrado al cerrar sesión · payload sin datos personales sensibles | ✅ | V2-M06.01 |
| V2-M06.03 | Como cliente quiero que tocar una notificación me lleve a su pantalla | Deep link con app cerrada, en segundo plano y abierta · si requiere login, vuelve al destino tras entrar | | V2-M06.02 |
| V2-M06.04 | Como cliente quiero una bandeja con todos mis avisos | Paginada · no leídos con contador en el ícono · marcar todas como leídas | ✅ | V2-M06.02 |
| V2-M06.05 | Como cliente quiero elegir qué avisos recibir y un horario silencioso | Por categoría · respetado por el backend al enviar | ✅ | V2-M06.04 |
| V2-M06.06 | Como cliente quiero recordatorios de cita aunque no tenga red | Recordatorios locales 24 h y 2 h antes (ya existen en v1; migrar a v2) | | V2-M02.08 |
| V2-M06.07 | Como equipo queremos un servicio único de envío en el backend | Módulo `notificaciones` en Modulith escucha eventos de dominio (cita, orden, documento…) | ✅ | V2-T05.01 |
