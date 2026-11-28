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

## Recordatorios sin red (V2-M06.06)

**Al migrar a la v2 los recordatorios se quedaron sin disparador.** Existen y
funcionan desde la v1, pero todo lo que los enciende vive en
`lib/pantallas/citas/` y en el perfil v1; el módulo v2 de citas nunca llamaba
al servicio. Desde que `V2-T01.09` dejó citas en v2, **agendar una cita no
dejaba ningún recordatorio de 24 h ni de 2 h**. No era una migración pendiente
de forma: era una función perdida.

La costura es `RecordatoriosDeCita`, en este módulo: el de citas habla con ella
y con sus propios tipos (`CitaCliente`, `CitaAgendada`), sin saber que debajo
vive el servicio de la v1.

| Método | Cuándo |
| --- | --- |
| `alConfirmar` | El taller acaba de confirmar una cita: aviso inmediato y los dos recordatorios |
| `alAgendar` | Una cita de la lista: deja sus recordatorios al día |
| `alCancelar` | Cita cancelada: se quitan |
| `sincronizar` | Al abrir «Mis citas»: quita los que ya no van y agrega los que faltan |

**La lógica de cuándo suena cada uno no se duplicó.** Vive en
`recordatorios.dart` y ya estaba probada; `RecordatoriosDelServicioV1` traduce
los tipos y la reusa. Copiarla para que hablara de tipos v2 habría sido copiar
reglas de negocio, que es la forma de que un día dejen de coincidir.

Son avisos **locales**, y ahí está el criterio: los programa el teléfono, no el
servidor, así que suenan sin red.

**Lo que falta y no puedo hacer yo:** las tres llamadas van dentro de
`lib/modulos/citas/`, que es carpeta de Juan Pablo
(`plan/trabajo-en-paralelo.md`, secciones 5 y 6). Las escribe la dueña de la
historia o él en un PR chico aparte.


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

## El contrato de la bandeja y las preferencias (v2 2.30.0)

Escrito antes del código, para poder construir la M06.04 y la M06.05 contra
`mock_api` sin esperar al backend (`plan/trabajo-en-paralelo.md`). Cinco
operaciones nuevas en **`api/agencia360-api-app-v2.yaml`**: `GET
/notificaciones`, `POST /notificaciones/leidas`, `POST
/notificaciones/{id}/leida` y `GET`/`PUT /notificaciones/preferencias`.

Va en el contrato **v2** porque el v1 quedó congelado como referencia de la app
v1; lo dice su propia descripción y todo cambio nuevo entra solo en el v2.

Tres decisiones que conviene revisar antes de programar contra ellas:

| Decisión | Por qué |
| --- | --- |
| `noLeidas` viaja en **cada página** y es el total de la cuenta | Es lo que la app pinta en el contador del ícono, y pedirlo aparte sería una llamada más en cada entrada |
| `PROMOCIONES` nace **apagada**, las demás encendidas | Lo comercial se pide, no se asume |
| El horario silencioso es **de la cuenta**, no por categoría, y lo respeta el **servidor** al enviar | Un aviso que no se manda no despierta a nadie; filtrarlo en la app no sirve con la app cerrada. Si `desde` > `hasta` el rango cruza la medianoche (22:00–07:00), que es el caso normal |

`GET /notificaciones/preferencias` devuelve **todas** las categorías, también
las que nadie ha tocado, con su valor por omisión: así la app no tiene que
saber cuáles existen ni qué se asume cuando falta una.

Se guarda lo que la persona **eligió**, no solo lo que apagó. Guardar solo las
apagadas volvía imposible prender `PROMOCIONES`, porque al no estar en la lista
caía otra vez en su valor por omisión. Lo encontró una prueba a mano contra el
simulador, no la lectura del código.

### El estado real del backend, al 27 de noviembre de 2026

Juan Pablo (`PabloDev24`) construyó **hoy** el módulo `notificaciones` del
backend. Esto es lo que ya existe en su `main`, comprobado contra `origin`:

| Pieza | Estado |
| --- | --- |
| `PUT` y `DELETE /dispositivos/{instalacionId}` | **Hechos** y declarados en su contrato v2 2.30.0 |
| Tablas `dispositivo_push` y `notificacion` | **Hechas** (migración V60) |
| Envío por FCM (`EnvioPushFcm`, `AvisosService`) | **Hecho** — es el grueso de V2-M06.07 |
| Endpoint HTTP de la bandeja | **No existe**: hay `Bandeja`/`BandejaJdbc` por dentro, pero nada expuesto |
| `preferencia_notificacion` | **No existe**; la V60 dice literalmente que es de V2-M06.05 |

Es decir: **la M06.02 ya no espera al backend** —espera la decisión de Firebase
en un repositorio público—, y la M06.04 y la M06.05 sí siguen sin endpoint real,
aunque ya se pueden construir contra `mock_api`.

La tabla `notificacion` trae dos columnas que este contrato **no** expone,
`evento` y `datos`, pensadas para que la app resuelva el destino y para
depurar. Queda la pregunta para Juan Pablo: si la app las necesita, se agregan
como opcionales sin romper nada.

### Las dos copias del contrato v2 se separaron

`AGENTS.md` §7 dice que un cambio de contrato se hace primero en
`agencia-360-backend/docs/api/`. **El contrato v2 sí está ahí** y va en la
**2.30.0**, con tres rutas que la copia de este repositorio no tiene:
`/dispositivos/{instalacionId}`, `/ordenes/{ordenId}/actividad-en-vivo` y
`/vehiculos/{vehiculoId}/documentos`. Esta copia, a su vez, tiene
`/analitica/eventos`, que allá no está.

Por eso estas rutas entran como **2.31.0** y no 2.30.0: ese número ya está
tomado del otro lado y dos 2.30.0 distintas serían peor que ir una versión
adelante.

**Pendiente del equipo**, no de esta historia: volver a sincronizar las dos
copias, y copiar estas rutas al backend como pide §7. También falta
`agencia-360-backend/plan/historias-backend.md`, que §4.3 menciona y no existe.

## Cómo quedó la bandeja (V2-M06.04)

Se construyó contra el contrato v2 2.31.0 y `mock_api`, porque el endpoint HTTP
del backend todavía no existe: las tablas sí (migración V60) y la `Bandeja`
interna también, pero nada expuesto. Es lo que `plan/trabajo-en-paralelo.md`
pide hacer en vez de esperar.

Los tres criterios:

| Criterio | Cómo queda |
| --- | --- |
| Paginada | `BandejaNotifier` con `cargarMas`, que pide la siguiente página 400 px antes del fondo. Si esa página falla, **se conserva lo cargado** y se dice; no se pierde lo que la persona estaba leyendo |
| No leídos con contador | `noLeidos` viene en cada página y es de **toda la cuenta**, no de lo cargado. Con la bandeja a medio paginar, contar lo cargado daría un número más chico que el real |
| Marcar todas como leídas | Un botón que desaparece cuando ya no hay nada sin leer, y una sola llamada |

### Dos decisiones que conviene revisar

**Se pinta leído antes de que el servidor conteste.** Abrir un aviso no debe
sentirse lento, el endpoint es idempotente y la próxima carga manda la verdad.
Si la llamada falla, lo peor es que el aviso vuelva a verse sin leer.

**El no leído se distingue con punto, con negrita y con texto**, no solo con
color: un punto de color no lo ve quien no distingue tonos. El lector de
pantalla lo anuncia como «Sin leer. <título>».

### El contador en el ícono de la barra: pendiente de T02

El criterio dice «no leídos con contador en el ícono». El contador está en la
fila **Mis avisos** del perfil, que es la entrada a la bandeja. Ponerlo en el
ícono de la barra de navegación necesita que `DestinoNavegacion` acepte una
insignia, y eso vive en `lib/nucleo/diseno/componentes/`, carpeta de Cristian
(T02). **Queda como PR chico aparte que hay que pedirle**, como manda
`plan/trabajo-en-paralelo.md` sección 5.

### La categoría desconocida no tumba la bandeja

`CategoriaDeAviso.desconocida` no la manda el servidor: existe para que agregar
una categoría del lado del backend no rompa la pantalla. Un aviso de categoría
nueva se sigue leyendo; solo pierde su icono propio y cae en la campana.

El `destino` se valida **al traducir** con la regla de V2-M06.03, no al tocar:
así la pantalla recibe un destino que sirve o un nulo, y no tiene que
desconfiar de él. Un destino inválido no esconde el aviso — se pierde el toque,
no el mensaje.

## Las preferencias y el horario silencioso (V2-M06.05)

Construida contra el contrato y `mock_api`: la tabla `preferencia_notificacion`
no existe en el backend —la propia migración V60 dice que es trabajo de esta
historia—, así que el endpoint real llegará después.

### No hay botón de guardar

Cada interruptor guarda al tocarse. Una pantalla de interruptores con botón
obliga a recordar que falta confirmar, y la mitad de la gente se sale sin
tocarlo.

El precio es que cada cambio tiene que pintarse al instante y **revertirse si
el servidor falla**. Un interruptor que se queda mintiendo es peor que uno
lento: la persona creería que apagó algo que sigue encendido. Cuando falla, el
control vuelve a su lugar y la pantalla lo dice.

Se usa lo que **contesta** el servidor, no lo que se mandó: si el backend
normaliza algo, la pantalla queda con la verdad.

### El rango que cruza la medianoche es el caso normal

22:00 a 07:00 es lo que la gente configura de verdad. Tratarlo como un rango
cualquiera dejaría **la noche entera sin silencio**, que es justo lo contrario
de lo que se pidió. `HorarioSilencioso.silencia()` lo resuelve y tiene su
prueba; la pantalla además lo dice en palabras, para que nadie crea que lo
configuró mal.

Dos detalles que se decidieron ahí:

- **`desde == hasta` no silencia nada.** Silenciar el día entero sería una
  sorpresa desagradable para quien eligió dos horas iguales.
- **Una hora que no se puede leer deja el horario en nulo**, no en una hora
  inventada: mejor sin silencio que silenciando a una hora que nadie eligió.

### Quién respeta el silencio

**El servidor, al enviar.** Es el criterio de la historia y no un detalle: un
aviso que no se manda no despierta a nadie, y filtrarlo en la app no sirve con
la app cerrada. `HoraDelDia` y `HorarioSilencioso` viven en el dominio para
poder decírselo a la persona y para probarlo, no para decidirlo.

La categoría `desconocida` no se le manda al servidor: el contrato no la
declara y sería un 400. Existe solo para que una categoría nueva del backend no
tumbe la pantalla.

