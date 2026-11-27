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

## Cómo quedó el permiso (V2-M06.01)

El diálogo del sistema **se muestra una sola vez en la vida de la instalación**
en Android 13 y después. Pedirlo en frío gasta ese único tiro y deja la app sin
avisos para siempre, así que el orden es parte del diseño, no un adorno:

1. `PantallaPermisoAvisos` (`/avisos/permiso`) explica los tres motivos por los
   que la app avisa y promete que no hay publicidad.
2. Solo si la persona toca **Activar avisos** se llama al sistema.
3. **Ahora no** ni siquiera lo toca: guarda el tiro para cuando los quiera.
4. Negados, el perfil muestra «Apagados» y la pantalla ofrece **Abrir ajustes**,
   que es la única forma real de reactivarlos. La abre
   `abrirAjustesDeLaApp()` del núcleo, no el módulo: la decisión 0006 deja los
   paquetes de ubicación dentro de `lib/nucleo/`, y quien hoy abre esa pantalla
   es `geolocator`.

La pantalla aparece **al entrar a la cuenta**, como última compuerta de
`redirigirPorSesion`: después del candado, del cambio obligatorio de
contraseña y del aviso de privacidad. Ese orden es deliberado —explicar los
avisos puede esperar a que la cuenta esté en orden; aceptar el aviso de
privacidad no— y está probado en `test/nucleo/navegacion/guardia_sesion_test.dart`.

Después de contestar, la pantalla sale sola: regresa al perfil si se entró de
ahi, o al inicio si fue la guardia la que mandó.

**La compuerta solo existe cuando alguien entró de verdad.** Se enciende con la
clave `avisos.por_explicar`, que se pone al pasar de `Autenticando` a
`Autenticada`; con preferencias vacías responde que no falta nada. Es lo que
evita que aparezca en las pruebas de otros frentes que arrancan la app
enrutada, y está probado en `test/nucleo/avisos/`.

**El permiso es del teléfono, no de la cuenta:** quien ya contestó no vuelve a
pasar por la explicación aunque entre con otra cuenta en el mismo equipo.

**Lo que esta historia no hace:** registrar el token FCM ni recibir push. Eso
es **V2-M06.02**, que ya encuentra el permiso resuelto.

## A dónde lleva tocar un aviso (V2-M06.03)

El destino viaja **dentro** del aviso, en su carga útil, y no en el código que
lo recibe. Antes no viajaba nada: `mostrar` y `programar` no mandaban
`payload`, el manejador del toque descartaba la respuesta y **cualquier** aviso
abría «Mis citas», con la ruta escrita a mano en la pantalla de inicio v1.

Los tres estados del criterio salen de por dónde entra el destino:

| Estado de la app | Cómo llega |
| --- | --- |
| Abierta o en segundo plano | El plugin entrega el toque con su carga útil; el servicio lo publica y el enrutador navega con `go` |
| **Cerrada** | No hay toque que escuchar: el sistema arranca la app y el destino solo está en `getNotificationAppLaunchDetails`. Se usa como `initialLocation` del enrutador, no con `go` —llamar a `go` antes de montarlo truena— |

El cuarto criterio, «si requiere login, vuelve al destino tras entrar», **no
necesitó código nuevo**: la guardia ya manda al acceso con `desde` y regresa
sola. Queda comprobado en `test/nucleo/avisos/tocar_un_aviso_test.dart`.

**El destino es dato de fuera, no ruta de confianza.** En un push lo escribe el
servidor, así que `destinoDeAviso()` solo acepta una ruta interna: nada con
esquema, nada de `//host`. Es la misma regla que la guardia aplica a `desde`, y
por lo mismo: un destino sin revisar es una redirección abierta.

**Sobre la dependencia de V2-M06.02:** esa historia decide **de dónde sale** el
aviso, no cómo se encamina el toque. Esto quedo hecho contra los avisos locales
que ya existen —los recordatorios de cita, que ahora llevan a `/citas`— y el
push de M06.02 entra por el mismo camino sin cambiarlo.

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
