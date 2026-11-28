# M07 · Mensajería con el asesor

| Campo | Valor |
| --- | --- |
| Hito | H4 |
| Dueño | Jael |
| Revisa | Ricardo |
| Ficha técnica | ✅ Sección 7. Mensajería con el asesor |
| Estado | Listo para historias |

## Propósito

Conversación directa con el asesor de servicio, ligada a la orden o cita, con fotos y audios. Sustituye llamadas y WhatsApp personal. Mueve O3 y O7.

## Pantallas

- **Conversaciones** — una por orden/cita y una general con la agencia.
- **Chat** — texto, fotos, audio, ubicación; indicadores de enviado/leído; respuestas rápidas.

## Datos

| Tabla | Campos | Notas |
| --- | --- | --- |
| `conversacion` ➕ | id, cliente_id, orden_servicio_id, cita_id, asesor_id, estado | |
| `mensaje` ➕ | id, conversacion_id, autor_tipo, autor_id, texto, adjunto_url, enviado_en, leido_en | |

## API (`/api/v1/app`)

| Método | Ruta | Uso |
| --- | --- | --- |
| GET | `/conversaciones` · `/conversaciones/{id}/mensajes?antesDe=` | |
| POST | `/conversaciones/{id}/mensajes` | Texto o adjunto. |
| SSE | `GET /eventos` (ya existe) | Evento de mensaje nuevo y de lectura, **no WebSocket** (ver decisiones). Nombre y forma por diseñar. |

## Historias

| ID | Historia | Criterios de aceptación | B | Depende de |
| --- | --- | --- | --- | --- |
| V2-M07.01 | Como cliente quiero escribirle a mi asesor sobre mi orden | Conversación ligada a la orden, visible en su detalle · lista de conversaciones con la general · estados de carga, vacío, enviando y fallido · historial paginado sin perder ni repetir mensajes | ✅ | V2-M04.02 |
| V2-M07.02 | Como cliente quiero recibir respuestas en tiempo real | Evento nuevo en el canal SSE (no WebSocket) · al reconectar se recupera lo perdido · push con la app cerrada sin el texto del mensaje | ✅ | V2-M07.01, V2-M06.02 |
| V2-M07.03 | Como cliente quiero mandar fotos | Compresión y límite antes de subir · progreso y cancelar · sin metadatos de ubicación · permiso negado y proceso muerto de Android resueltos | ✅ | V2-M07.01 |
| V2-M07.04 | Como cliente quiero saber si mi mensaje fue leído | Una palomita al enviar, doble al leer, solo en mis mensajes · el cliente marca como leído solo lo que ve | ✅ | V2-M07.02 |
| V2-M07.05 | Como cliente quiero escribir sin conexión y que se envíe después | Cola de V2-M21.03 con estado «pendiente» · orden y sin duplicados · la cola es de la cuenta que la creó | | V2-M21.03 |
| V2-M07.06 | Como cliente quiero mandar audios | **Partida de V2-M07.03** (ver abajo) · sin criterios hasta decidir la dependencia de grabación | ✅ | V2-M07.03 |

### Por qué se partió el audio

V2-M07.03 decía «fotos y audios». **Se parte en dos** y el audio pasa a
V2-M07.06, por tres razones concretas:

1. **Dependencia nueva.** `image_picker` ya está y cubre fotos. Grabar audio
   necesita un paquete de grabación y su permiso de micrófono, y agregar o subir
   dependencias lo confirma Jael antes de tocar `pubspec.yaml`.
2. **Criterios que hoy no se pueden escribir comprobables.** Formato, duración
   máxima, qué hace la grabación si entra una llamada, si el audio se reproduce
   en segundo plano y cómo se ve para quien usa lector de pantalla dependen del
   paquete elegido. Escribirlos ahora sería inventarlos.
3. **Tamaño de PR.** Con fotos, permisos de cámara, compresión, progreso y visor
   ya es una historia completa. Con audio dejaba de caber en un PR revisable
   (Definición de Listo).

V2-M07.06 queda en `Borrador` a propósito. Se saca de borrador cuando alguien la
va a tomar y, en su primer commit, deja escrita la elección del paquete (ADR si
cambia la forma de manejar permisos de dispositivo) y sus criterios.

## Criterios de aceptación

Lo común a todas: el texto de los mensajes **no se escribe en logs** (se usa
`Registro.depurar`, y lo vigila `test/arquitectura/registro_sin_datos_personales_test.dart`);
toda pantalla se prueba en claro, oscuro y letra al 200 %; y una conversación o
mensaje de otro cliente **nunca** se distingue de uno que no existe (siempre
404, nunca 403).

### V2-M07.01 · Escribirle a mi asesor sobre mi orden

Backend: tablas `conversacion` y `mensaje` (ficha, sección 7) y los tres
endpoints de la tabla de API. La forma de abrir la conversación de una orden o
cita que todavía no tiene mensajes **no está en la tabla de API y queda por
diseñar** (ver «Pendiente de diseñar»).

| # | Dado / Cuando / Entonces |
| --- | --- |
| 1 | **Dado** el detalle de una orden, **cuando** el cliente toca «Escribir a mi asesor», **entonces** se abre la conversación cuyo `orden_servicio_id` es esa orden; si no existía, se crea una sola vez (tocar dos veces o desde dos celulares no crea dos). |
| 2 | **Dado** una orden de otro cliente, **cuando** se pide su conversación, **entonces** la API responde 404 y la app muestra «No encontramos esta conversación», la misma pantalla que para una inexistente. |
| 3 | **Dado** el listado de Conversaciones, **entonces** muestra una por orden o cita con actividad y **siempre** la general con la agencia, aunque no tenga mensajes; ordenadas por el último mensaje, con vista previa de una línea y contador de no leídos. |
| 4 | **Dado** que se abre el chat, **mientras** carga el historial, **entonces** se ven esqueletos de burbujas y el campo para escribir ya está disponible (no pantalla en blanco ni solo un círculo girando). |
| 5 | **Dado** una conversación sin mensajes, **entonces** el chat dice con texto propio que aún no hay mensajes y qué se puede preguntar, y el campo está habilitado. |
| 6 | **Dado** que falla la carga del historial, **entonces** se muestra el error con «Reintentar» y, si ya había mensajes cargados, **se conservan** a la vista. |
| 7 | **Dado** que el cliente envía un texto, **entonces** la burbuja aparece al instante en estado «enviando»; con la respuesta 201 pasa a «enviado»; si falla, queda marcada «No se pudo enviar» con **Reintentar** y **Descartar**. |
| 8 | **Dado** un envío fallido, **cuando** se reintenta, **entonces** viaja con la **misma clave de idempotencia** y, si el primer intento sí llegó al servidor y solo se perdió la respuesta, **no se duplica** el mensaje. |
| 9 | **Dado** un texto vacío o solo de espacios, **entonces** el botón de enviar está deshabilitado y no se llama a la API. |
| 10 | **Dado** un texto más largo que el límite del contrato, **entonces** la app lo impide con un contador visible antes de enviar, y si el servidor responde 422 muestra el límite, no un error genérico. El valor del límite **lo declara el contrato**; mientras no exista queda pendiente de diseñar. |
| 11 | **Dado** el historial paginado con `antesDe`, **cuando** se llega al inicio de lo cargado, **entonces** se piden los mensajes anteriores sin mover la posición de lectura; el cursor es por identificador, de modo que **dos mensajes con la misma marca de tiempo no se repiten ni se pierden** entre páginas. |
| 12 | **Dado** un mensaje cuyo `autor_tipo` el servidor no declara en el contrato, **entonces** se pinta como de la agencia y no rompe la pantalla. |
| 13 | **Dado** una conversación con `asesor_id` nulo, **entonces** el encabezado dice «Agencia», no un nombre vacío. |
| 14 | **Dado** una conversación en estado cerrado, **entonces** el historial sigue visible, el campo de texto queda deshabilitado y explica por qué. Los valores de `estado` **no los declara la ficha**: quedan por diseñar con backend. |
| 15 | **Dado** la pantalla de contacto de V2-M27.03, **entonces** su acceso al chat (que esa historia dejó esperando a esta) abre la conversación general. |
| 16 | **Dado** un lector de pantalla, **entonces** cada burbuja se lee con autor, hora y estado («Tú, 10:32, enviado»). |

### V2-M07.02 · Recibir respuestas en tiempo real

Backend: evento de mensaje nuevo en `GET /eventos` (nombre y forma por diseñar).
**No hay WebSocket ni STOMP** (decisión de arriba): se agrega un tipo de evento al
canal que ya usan taller, garantía, lealtad y asistencia.

| # | Dado / Cuando / Entonces |
| --- | --- |
| 1 | **Dado** el chat abierto, **cuando** llega el evento de mensaje nuevo de esa conversación, **entonces** la burbuja aparece sin recargar. |
| 2 | **Dado** un evento de un mensaje que la pantalla ya tiene (por ejemplo, la respuesta al propio envío), **entonces** **no se duplica**: se concilia por identificador. |
| 3 | **Dado** que el canal se cae y vuelve (`conexion.restablecida`), **entonces** el chat pide los mensajes posteriores al último que tiene. El canal **no reenvía** lo perdido, así que esta consulta es lo único que evita huecos. |
| 4 | **Dado** el evento de una conversación distinta a la abierta, **entonces** sube el contador de no leídos en la lista y el chat abierto no cambia. |
| 5 | **Dado** un evento con datos incompletos o de un nombre que la app no conoce, **entonces** se ignora sin romper el canal ni las demás pantallas. |
| 6 | **Dado** que la persona está leyendo mensajes viejos (desplazada hacia arriba), **cuando** llega uno nuevo, **entonces** la vista no salta; aparece un aviso «Mensaje nuevo» que baja al final al tocarlo. |
| 7 | **Dado** que el canal solo está abierto mientras alguna pantalla lo escucha, **entonces** al salir del chat la suscripción se cancela. |
| 8 | **Dado** que el canal y un `POST` reciben 401 al mismo tiempo, **entonces** se refresca la sesión **una sola vez** y los dos reintentan con el token nuevo (reusar un refresh gastado cierra las sesiones de la cuenta). |
| 9 | **Dado** la app cerrada o en segundo plano y una respuesta del asesor, **entonces** llega un push de categoría «mensajes» (la que ya ofrecen las preferencias de V2-M06.05) y tocarlo abre esa conversación por una ruta **interna** (V2-M06.03). |
| 10 | **Dado** el payload del push, **entonces** **no incluye el texto del mensaje** ni el nombre del asesor: solo «Tienes un mensaje nuevo» y el destino (regla de V2-M06.02). |
| 11 | **Dado** que el cliente tiene abierta esa misma conversación, **entonces** no recibe el aviso del sistema duplicado. |
| 12 | **Dado** la categoría «mensajes» apagada o el horario silencioso, **entonces** no hay push (lo respeta el servidor), pero el mensaje **sí** está en el chat al abrirlo. |

### V2-M07.03 · Mandar fotos

Backend: aceptar adjunto en `POST /conversaciones/{id}/mensajes` y servirlo con
autorización. La forma (multipart o subida previa) queda por diseñar. Sin
dependencia nueva: `image_picker`.

| # | Dado / Cuando / Entonces |
| --- | --- |
| 1 | **Dado** el botón de adjuntar, **entonces** ofrece cámara y galería. |
| 2 | **Dado** el permiso de cámara negado, **entonces** la pantalla explica y ofrece **Abrir ajustes** (con `abrirAjustesDeLaApp()` del núcleo) y la galería sigue funcionando. |
| 3 | **Dado** una foto elegida, **entonces** se **comprime antes de subir** a un lado mayor y calidad fijos. Propuesta a confirmar con backend: 1600 px y calidad 80. |
| 4 | **Dado** una foto HEIC (iOS), **entonces** se convierte a JPEG antes de subir. |
| 5 | **Dado** una foto con ubicación GPS en sus metadatos, **entonces** el archivo que sale **ya no la trae**. |
| 6 | **Dado** una foto que sigue pasando del límite tras comprimir, **entonces** se avisa con el límite en MB y **no se intenta subir**. |
| 7 | **Dado** la subida en curso, **entonces** la burbuja muestra el progreso y un botón de cancelar; cancelar no deja mensaje a medias en la conversación. |
| 8 | **Dado** una subida que falla, **entonces** la foto se conserva en la burbuja con **Reintentar**, y el reintento no crea un segundo mensaje. |
| 9 | **Dado** que Android mató la app mientras estaba abierta la cámara, **cuando** la app regresa, **entonces** se recupera la foto con `retrieveLostData` y sigue el envío. Es el caso que se pierde sin darse cuenta. |
| 10 | **Dado** una foto recibida, **entonces** la miniatura abre un visor a pantalla completa con descripción para lector de pantalla; la dirección del adjunto **requiere sesión** (no es pública ni adivinable). |
| 11 | **Dado** que no hay conexión, **entonces** el botón de adjuntar avisa que las fotos necesitan conexión (la cola sin red de V2-M07.05 es solo de texto). |

### V2-M07.04 · Saber si mi mensaje fue leído

Backend: marcar como leídos los mensajes de la conversación y un evento de
lectura (ambos por diseñar). El modelo solo tiene `enviado_en` y `leido_en`:
**no existe un estado «entregado»** y la app no lo inventa.

| # | Dado / Cuando / Entonces |
| --- | --- |
| 1 | **Dado** un mensaje mío con `leido_en` nulo, **entonces** muestra **una** palomita; con `leido_en`, **dos**. Mensajes del asesor no llevan palomitas. |
| 2 | **Dado** un mensaje «enviando» o «fallido», **entonces** no muestra palomitas, sino su estado. |
| 3 | **Dado** que el asesor lee, **entonces** el evento de lectura cambia las palomitas en vivo; tras una reconexión se vuelve a consultar y quedan al día. |
| 4 | **Dado** un lector de pantalla, **entonces** dice «Leído a las 10:32» o «Enviado, sin leer». |
| 5 | **Dado** el chat en primer plano con mensajes del asesor a la vista, **entonces** la app los marca como leídos. |
| 6 | **Dado** la app en segundo plano, la pantalla tapada o un mensaje que llegó mientras se leía más arriba (aviso «Mensaje nuevo» sin tocar), **entonces** **no** se marca como leído. Sin esta regla un push que se abre «a medias» deja al asesor creyendo que se leyó. |
| 7 | **Dado** que marcar como leído falla por red, **entonces** el chat sigue usable y se reintenta al volver la conexión; la operación es idempotente. |
| 8 | **Dado** que se leyó todo, **entonces** el contador de no leídos de la lista baja a cero. |

### V2-M07.05 · Escribir sin conexión

Reusa la cola de V2-M21.03 (decisión de arriba): **no se construye una segunda
cola**. También depende de V2-M21.01, porque la cola vive en la base local.

| # | Dado / Cuando / Entonces |
| --- | --- |
| 1 | **Dado** que no hay conexión, **cuando** el cliente envía un texto, **entonces** la burbuja queda «pendiente» (reloj) al final de la conversación y la lista de conversaciones lo refleja. |
| 2 | **Dado** varios mensajes pendientes, **cuando** vuelve la conexión, **entonces** se envían **en el orden en que se escribieron**. |
| 3 | **Dado** que el servidor recibió el mensaje pero la respuesta se perdió, **entonces** el reintento (misma clave de idempotencia) **no lo duplica**. |
| 4 | **Dado** que la app se cierra con mensajes pendientes, **entonces** al abrirla siguen ahí y se envían. |
| 5 | **Dado** un envío confirmado, **entonces** la burbuja pendiente se **reemplaza** por la del servidor, sin duplicar ni brincar. |
| 6 | **Dado** un error permanente (4xx: conversación cerrada o inexistente), **entonces** el mensaje pasa a «fallido» con **Reintentar** y **Descartar** y **no se reintenta solo**; con 5xx o tiempo agotado sí, con espera creciente (V2-M21.03). |
| 7 | **Dado** que se cierra la sesión con mensajes pendientes, **entonces** la app avisa cuántos hay antes de cerrar; y **cuando entra otra cuenta en el mismo teléfono, los pendientes de la anterior no se envían ni se ven**. |
| 8 | **Dado** el chat sin red, **entonces** el historial ya guardado se lee y hay un aviso de sin conexión (V2-M21.04). |

## Pendiente de diseñar

Nada de esto está en la tabla de API de arriba y **no se declara como hecho**.
Quien tome la historia B lo diseña en su primer commit en
`agencia-360-backend/plan/historias-backend.md` y en el contrato v2, antes de programarlo.

| Falta | La necesita |
| --- | --- |
| Abrir o crear la conversación de una orden o cita (`POST /conversaciones` o equivalente idempotente) | M07.01 |
| Valores de `conversacion.estado` y límite de longitud del texto | M07.01 |
| Encabezado o campo de **clave de idempotencia** en `POST /conversaciones/{id}/mensajes` | M07.01, M07.05 |
| Evento SSE de mensaje nuevo (nombre y datos) | M07.02 |
| Subida y descarga autorizada de adjuntos, y su límite de tamaño | M07.03 |
| Marcar leídos (`POST /conversaciones/{id}/leidos`) y evento de lectura | M07.04 |

## Preguntas abiertas

| Pregunta | Para quién |
| --- | --- |
| ¿Se confirma que el push de un mensaje no lleva texto? Es lo seguro (la pantalla bloqueada lo muestra), pero un chat sin vista previa se siente pobre. | PO |
| ¿El cliente puede apagar que el asesor vea que leyó? La ficha no lo pide; no se agrega. | PO |
| ¿Leer una conversación marca como leído el aviso de la bandeja de V2-M06.04 que la anunciaba? | Jael |
| ¿Fotos sin conexión entran a la cola de M21? Aquí se dice que no, por peso; es un acuerdo que no estaba escrito. | Jael |
| La pantalla menciona **ubicación** y ninguna historia la cubre (`lib/nucleo/mapas/` ya existe). No se agrega sola; si se quiere, es una historia nueva. | PO |
| Interacción con M19: la conversación pertenece al titular. **Un invitado de un vehículo compartido no ve el chat.** | PO |

## Cómo se actualiza el tablero

No lo hizo este cambio (otro agente trabajaba ahí). Lo que conviene mover:

- V2-M07.01, .02, .03 y .04: `Lista`. Cumplen la Definición de Listo: sus
  dependencias de backend no bloquean y se trabajan contra el contrato y `mock_api`.
- V2-M07.03: renombrar a «Mandar fotos».
- V2-M07.06: fila nueva, «Mandar audios», `Borrador`, depende de V2-M07.03.
- V2-M07.05: dejarla en `Borrador` hasta que V2-M21.03 exista. Una cola de
  operaciones no se puede simular de forma honesta.
- Cumplimiento de ficha: sin cambio. La fila de la sección 7 sigue en ⬜ hasta que
  haya código; nada de aquí quita ni renombra tablas o campos.


## Fuera de alcance / notas

- La bandeja del asesor vive en el ERP (congelado) → dependencia externa; mientras, endpoint interno de respuesta para pruebas.

## Decisiones técnicas (27 de noviembre de 2026)

Tomadas por el frente de la app, por delegación del equipo. La ficha técnica
(sección 7) solo fija las tablas `conversacion` y `mensaje`, así que el
transporte y los adjuntos quedaban abiertos.

### El tiempo real va por el canal SSE que ya existe, no por WebSocket

La tabla de arriba propone `WS /conversaciones/tiempo-real` con STOMP. **Se
descarta.** La app ya tiene un canal de eventos en vivo por SSE:
`GET /eventos` en el contrato, `lib/nucleo/eventos/` con su analizador y su
reconexión, y lo usan taller (V2-M04.03), garantía, lealtad y asistencia.

Un WebSocket con STOMP sería una **segunda** pila de tiempo real: dependencia
nueva en la app, infraestructura nueva en el backend, otra lógica de
reconexión y otro juego de pruebas. Para un chat no compra nada: mandar un
mensaje es un `POST` normal, y lo único que necesita empujarse del servidor al
cliente es el mensaje entrante, que es exactamente lo que SSE hace.

Así que M07.02 agrega un tipo de evento al canal, no un canal.

### Los adjuntos se parten en dos historias

`image_picker` ya es dependencia y cubre fotos (se usa en V2-M24.05 y en la
bitácora). **Las fotos entran sin dependencia nueva.** El audio sí la necesita,
así que M07.03 se parte: fotos primero, audio después, y el audio se decide
cuando toque y no ahora.

La ubicación que menciona la pantalla ya existe en `lib/nucleo/mapas/`.

### Sin conexión reusa la cola de M21.03

M07.05 no construye una segunda cola: usa la de operaciones pendientes de
V2-M21.03, que ya está diseñada con claves de idempotencia. Un mensaje es una
operación encolable como cualquier otra.

### Lo que esto implica para el orden

M07 sigue en H4. Sus historias ya tienen criterios comprobables (arriba) y
las cuatro que necesitan backend se trabajan contra el contrato y `mock_api`.
Lo que estas decisiones quitan de encima es la parte de infraestructura: ya no hace falta decidir ni construir
una pila de tiempo real.

