# M01 · Acceso y perfil

| Campo | Valor |
| --- | --- |
| Hito | H2 |
| Dueño | Jael |
| Revisa | Daniel |
| Ficha técnica | ✅ Sección 1. Acceso y perfil |
| Estado | Listo para historias |

## Propósito

Entrada segura y sin fricción con la cuenta que entrega la agencia, y control total del cliente sobre sus datos de contacto. Mueve O1 y O9.

## Pantallas

- **Bienvenida** — carrusel de 3 tarjetas con lo que hace la app (solo primer arranque).
- **Iniciar sesión** — correo + contraseña, mostrar/ocultar, mensajes claros, bloqueo con cuenta regresiva.
- **Desbloqueo biométrico** — huella/rostro para reabrir la sesión guardada.
- **Cambiar contraseña temporal** — obligatoria en primer ingreso; medidor de fuerza y reglas en vivo.
- **Recuperar contraseña** — pide correo → aviso "revisa tu correo" → enlace profundo abre **Nueva contraseña**.
- **Perfil** — foto/iniciales, nombre (solo lectura), teléfono y correo editables con verificación.
- **Seguridad** — cambiar contraseña, biometría, sesiones y dispositivos activos, cerrar sesión en todos.
- **Cuenta desactivada** — explica qué pasó y cómo contactar a la agencia.

## Datos

| Tabla | Campos | Notas |
| --- | --- | --- |
| `cliente` (ficha) | id, prospecto_id, nombre, telefono, correo | Sin cambios. |
| `cuenta_app` (ficha) | id, cliente_id, **usuario**, contrasena_hash, debe_cambiar_contrasena, activa | ➕ intentos_fallidos, bloqueada_hasta. `usuario` = correo (V2-T05.03). |
| `token_recuperacion` (ficha) | id, cuenta_app_id, token_hash, expira, usado | Enlace de un solo uso (V2-T05.04). |
| `sesion_app` ➕ | id, cuenta_id, token_hash, expira_en, revocada_en, **dispositivo**, **ultimo_uso** | Lista de sesiones activas. |
| `verificacion_contacto` ➕ | id, cliente_id, tipo (correo/telefono), valor_nuevo, codigo_hash, expira, usado | Confirma correo/teléfono antes de guardarlo. |

## API (`/api/v1/app`)

| Método | Ruta | Uso |
| --- | --- | --- |
| POST | `/auth/login` | Existe (v1). |
| POST | `/auth/refrescar` · `/auth/cerrar-sesion` | Existen. |
| POST | `/auth/cambiar-contrasena` | Existe. |
| POST | `/auth/recuperar-contrasena` | Cambia: envía **enlace** (`carecar://restablecer?token=…` + enlace universal https). |
| POST | `/auth/restablecer-contrasena` | Cambia: recibe `token` en vez de código. |
| GET/PATCH | `/perfil` | PATCH nuevo para teléfono/correo (inicia verificación). |
| POST | `/perfil/verificaciones/{id}/confirmar` | Nuevo. |
| GET | `/sesiones` · DELETE `/sesiones/{id}` · DELETE `/sesiones` | Nuevos. |

## Historias

| ID | Historia | Criterios de aceptación | B | Depende de |
| --- | --- | --- | --- | --- |
| V2-M01.01 | Como cliente quiero iniciar sesión con la cuenta que me dio la agencia para entrar a mi app | Dado correo y contraseña válidos, cuando inicio sesión, entonces veo Inicio en menos de 2 s con red normal · credenciales malas → mensaje sin revelar si el correo existe · no hay botón de registro en ninguna pantalla · bloqueo por intentos muestra minutos restantes | | V2-T01.02, V2-T02.04 |
| V2-M01.02 | Como cliente quiero ver una bienvenida la primera vez para entender qué puedo hacer | Solo aparece en el primer arranque · se puede saltar · accesible con lector de pantalla | | V2-T02.04 |
| V2-M01.03 | Como cliente con contraseña temporal quiero cambiarla obligatoriamente para proteger mi cuenta | Dado `debe_cambiar_contrasena`, no puedo navegar a otra pantalla hasta cambiarla · reglas en vivo (largo, letra, número) · no acepta la temporal como nueva | | V2-M01.01 |
| V2-M01.04 | Como cliente quiero recuperar mi contraseña con un enlace de un solo uso enviado a mi correo para volver a entrar | Enlace abre la app (deep link) en Nueva contraseña · expira y sirve una sola vez (`usado`) · enlace vencido/usado → pantalla con opción de pedir otro · respuesta igual exista o no el correo | ✅ | V2-T05.04, V2-T01.03 |
| V2-M01.05 | Como cliente quiero desbloquear con huella o rostro para no escribir mi contraseña cada vez | Opt-in tras primer login · si cambia la biometría del equipo se pide contraseña · se puede apagar en Seguridad | | V2-M01.01 |
| V2-M01.06 | Como cliente quiero ver mi perfil para confirmar mis datos | Muestra nombre, correo, teléfono, cliente desde, vehículos · estados de carga/error/sin conexión | | V2-M01.01 |
| V2-M01.07 | Como cliente quiero editar mi teléfono y correo para que la agencia me contacte | Cambio se guarda tras confirmar un código enviado al nuevo dato · al cambiar correo cambia también `cuenta_app.usuario` · validación de formato | ✅ | V2-M01.06, V2-T05.03 |
| V2-M01.08 | Como cliente con cuenta desactivada quiero saber por qué no puedo entrar para contactar a la agencia | 403 de cuenta inactiva → pantalla dedicada con botón de contacto · la sesión local se borra | | V2-M01.01 |
| V2-M01.09 | Como cliente quiero ver y cerrar mis sesiones abiertas en otros celulares para sentirme seguro | Lista con dispositivo y último uso · cerrar una o todas revoca sus tokens | ✅ | V2-M01.01 |
| V2-M01.10 | Como cliente quiero cambiar mi contraseña desde Seguridad cuando yo quiera | Pide la actual · cierra las demás sesiones opcionalmente | | V2-M01.03 |
| V2-M01.11 | Como cliente quiero que la sesión se renueve sola durante 30 días para no volver a escribir mi contraseña | Refresco transparente · si el refresco falla, vuelve a login conservando la pantalla destino | | V2-M01.01 |
| V2-M01.12 | Como cliente quiero que el primer inicio de sesión espere al servidor dormido para no ver un error falso | El backend en Azure se apaga sin tráfico y tarda ~35 s en despertar · el tiempo límite de `ClienteApi` es 60 s (no 20) · tras 8 s sin respuesta el login muestra «Despertando el servidor…» con el botón en carga (la cortina de arranque cambia su texto) · el aviso desaparece al responder, con éxito o con error · sin reintentos automáticos que dupliquen peticiones | | V2-M01.01 |

## Fuera de alcance / notas

- Registro público: **prohibido por ficha**.
- Inicio con Google/Apple: no, la cuenta la crea la agencia.

## Avance de V2-M01.01

**Qué quedó**

- `lib/modulos/acceso/` nace con su contrato público (`acceso.dart`), su dominio y su presentación.
- `dominio/bloqueo_por_intentos.dart` — cuenta cuánto falta del bloqueo por intentos (429 / RIC-5). Dart puro, cero imports. **No arma textos**: entrega números y la presentación elige la clave del ARB.
- `presentacion/pantalla_acceso.dart` — la pantalla v2 con los componentes del sistema. Sin ningún flujo de registro, con nota que explica por qué, y los tres fallos distinguidos: credenciales en rojo, sin conexión y bloqueo en ámbar, porque los dos últimos son esperas y no algo que la persona pueda corregir.
- `presentacion/aviso_bloqueo.dart` — la cuenta regresiva, que baja cada segundo y se quita sola al acabarse.
- `presentacion/espera_servidor.dart` — el «Despertando el servidor…» de V2-M01.12 portado a la v2.
- `presentacion/rutas_acceso.dart` — la ruta, **declarada y no registrada** (ver abajo).
- **42 pruebas** y 21 claves nuevas en `app_es.arb` y `app_en.arb`.

**Hallazgos en el árbol actual**

- **Tres de los cuatro criterios ya los cumplía la lógica de la v1**: no hay registro, el 401 del contrato es genérico y por eso no revela si el correo existe, y el cuarto —ver Inicio en menos de 2 s— resulta ser del enrutador, porque el guardia de sesión saca de `/acceso` a quien ya entró. Lo genuinamente nuevo era el bloqueo con minutos restantes.
- **`FalloDeSesion` solo cargaba el texto ya armado** por `_textoDelBloqueo`, escrito al fallar: a los diez minutos de un bloqueo de quince seguía diciendo quince. Se le agregó `esperaSegundos`, opcional, sin cambiar nada de la v1.
- **La arquitectura v2 no tiene hoy dónde poner utilidades pequeñas compartidas.** Esta historia duplicó dos por reglas distintas: el reloj inyectable, porque R1 prohíbe importar el de `citas/presentacion/`, y el umbral de espera del servidor con su aviso, porque R3 prohíbe importar `lib/widgets/`. Las dos copias quedan comentadas en ambos sentidos. Su lugar es `lib/nucleo/`, pero subirlas obliga a tocar carpetas de otros para migrarlas y ninguna historia lo cubre. **Va a repetirse con cada módulo nuevo.**
- **Las trece pruebas que comprueban la redirección por el widget** (`find.byType(PantallaLogin)`) y no por la ruta, en los módulos de otras cuatro personas, son lo que hace caro encender este módulo. Con `AppEnrutadaDePrueba` usando `todoV2` por omisión, agregar el valor al enum las pone rojas de golpe.

**Decisiones**

- **La pantalla no navega.** El guardia de sesión ya redirige a quien tiene sesión, así que la pantalla no recibe callbacks de éxito ni llama a `go`: solo pide la sesión y muestra lo que pasa. Es también lo que cumple el criterio de los 2 s.
- **El botón se bloquea también con la sesión ya iniciada**, no solo mientras entra. Lo encontró la prueba del doble toque: al terminar un login exitoso, `entrando` vuelve a ser falso y un segundo toque pedía otra sesión al servidor. Depender de que el enrutador llegue primero es frágil, y con cinco intentos y 15 minutos de bloqueo una petición de más sale caro.
- **El fin del bloqueo se guarda una sola vez**, cuando el fallo aparece. El `Retry-After` dice cuántos segundos faltan *desde que falló*, así que recalcularlo en cada `build` reinicia la cuenta —basta escribir en un campo— y el usuario vería «15 min» para siempre.
- **La ruta queda declarada y sin registrar.** Encenderla hoy dejaría «¿Olvidaste tu contraseña?» muerto hasta V2-M01.04 —el cliente **perdería** algo que la v1 sí le da—, mandaría a cambiar la contraseña temporal a una pantalla v1, y rompería las trece pruebas ajenas. El detalle del encendido está en el dartdoc de `rutas_acceso.dart`.
- **El dominio no escribe textos.** Al contrario del `esperaLegible` de la v1, que devolvía «15 minutos» en español. Lo exige la regla del módulo y lo vigila `test/l10n/sin_cadenas_en_codigo_test.dart`, que de hecho rechazó un `Text('CareCar')` escrito a mano: la marca también vive en el ARB, con la nota de que es nombre propio y no se traduce.

**Pendiente / fuera de alcance:** encender la ruta (pide V2-M01.03 y V2-M01.04); subir el reloj y la espera del servidor a `lib/nucleo/` (historia del núcleo); demostrar la pantalla en celular, que es lo que le falta a la fila de `cumplimiento-ficha.md` para pasar a ✅; y una captura en claro, oscuro y letra grande para el PR.

## Avance de V2-M01.03

**Qué quedó**

- `dominio/reglas_contrasena.dart` — las reglas de la contraseña, una respuesta por regla para poder marcarlas en vivo. Dart puro, cero imports.
- `dominio/repositorio_acceso.dart` y `datos/repositorio_acceso_api.dart` — la frontera del módulo con el servidor. **Primer uso real de `RepositorioBase`** (V2-T01.08), que había quedado construido y sin adoptar.
- `datos/repositorio_acceso_fake.dart` — el fake, que usa la misma base que el de verdad.
- `presentacion/pantalla_cambiar_contrasena.dart` — la pantalla, con `ListaDeReglas` marcándose al escribir.
- `presentacion/rutas_acceso.dart` — la ruta del cambio, **declarada y no registrada**.
- **29 pruebas** y 15 claves nuevas en `app_es.arb` y `app_en.arb`.

**El criterio decía «mayúscula» y se corrigió**

El criterio pedía «reglas en vivo (largo, número, **mayúscula**)». Se verificó en las cuatro fuentes y la mayúscula no está en ninguna:

| Fuente | Qué dice |
| --- | --- |
| **Ficha v2.1** (`.docx`) | Solo «Cambio obligatorio de la contraseña temporal». No define reglas de composición, y la palabra «mayúscula» **no aparece en todo el documento** |
| **Contrato v1 (1.5.0) y v2 (2.1.0)** | `minLength 8`, `maxLength 72`, «Al menos una letra y un número; distinta de la actual» |
| **`ReglasContrasena.java` del backend** | 8 a 72, `isLetter` y `isDigit`. **Sin mayúscula** |
| Pantalla v1 | «Al menos 8 caracteres, con letra y número» |

Pedirla habría rechazado contraseñas que el servidor acepta —`carecar2026`, que tiene su propia prueba— y habría mostrado una regla que nadie hace cumplir. Confirmado con el equipo: **manda lo que implementó Ricardo**. El criterio de arriba quedó corregido a «largo, letra, número».

**Hallazgos**

- **`contrasenaCambiadaProvider` no tenía ninguna prueba**, pese a que esta historia depende de él. Su comentario dice que se apaga al cerrar sesión y nada lo garantizaba: si se quedara encendido, **el siguiente cliente que entrara en ese teléfono con una contraseña temporal se saltaría el cambio obligatorio**. Funciona; ahora queda fijado desde `test/modulos/acceso/cambio_obligatorio_test.dart`.
- **El backend usa `Character::isLetter` y `isDigit`, que son Unicode.** Con una expresión ASCII, `mañana2026` fallaría en la app y pasaría en el servidor. La app usa `\p{L}` y `\p{Nd}` para espejearlo, con prueba.
- **Una de mis pruebas pasaba sin probar nada**: el `tap` del botón no lo alcanzaba porque la pantalla es más alta que el viewport de 360×800 y quedaba bajo el pliegue. Se arregla con `ensureVisible`, y queda comentado en el ayudante.

**Decisiones**

- **El botón se bloquea también tras un cambio exitoso**, no solo mientras guarda. Lo encontró la prueba del doble toque, y aquí es peor que en el login: el segundo intento manda la contraseña temporal, que ya dejó de ser válida, y el servidor responde un 401 sobre una operación que sí funcionó.
- **Las reglas se muestran todas desde el principio**, no solo las que faltan, para que nadie descubra a base de errores qué se le pide. Y `estaVacia` se distingue de «mal»: a quien acaba de abrir la pantalla no se le reclaman tres reglas incumplidas.
- **No se le pide al servidor lo que ya sabemos que va a rechazar**: sin reglas cumplidas o sin confirmación coincidente, no hay petición.
- **La contraseña actual es opcional en las reglas**, porque en la recuperación por enlace (V2-M01.04) no se conoce y esa historia reutiliza esta clase.
- **No se repitieron las pruebas del guardia.** Sus casos ya están en `test/nucleo/navegacion/guardia_sesion_test.dart`; lo que se fijó aquí es el apretón de manos, que la pantalla ponga exactamente la bandera que el guardia lee.

**Pendiente / fuera de alcance:** encender las rutas del módulo, que ahora solo espera a **V2-M01.04** y a actualizar las trece pruebas ajenas; demostrar la pantalla en celular, que es lo que le falta a la fila de `cumplimiento-ficha.md` para pasar a ✅; y las capturas en claro, oscuro y letra grande.

## Avance de V2-M01.04

**Qué quedó**

- `PeticionRestablecer.conEnlace` en `lib/api/modelos/sesion.dart` — la forma con `token` que declara el contrato v2, junto a la del código de 6 dígitos de la v1, que no se tocó.
- `dominio/fallos_acceso.dart` — `EnlaceNoValido`.
- `dominio/correo.dart` — `pareceCorreo`, que ahora comparten el acceso y la recuperación.
- `dominio/repositorio_acceso.dart` y `datos/` — `pedirEnlaceDeRecuperacion` y `restablecerConEnlace`, con la traducción del código del contrato al fallo de dominio.
- `presentacion/pantalla_recuperar.dart` y `presentacion/pantalla_nueva_contrasena.dart`.
- Las rutas `/recuperar` y `/restablecer` declaradas, **sin registrar**.
- **26 pruebas** y 18 claves nuevas en `app_es.arb` y `app_en.arb`.

**Lo que ya estaba y no hubo que hacer**

El andamiaje de enlaces profundos es de **V2-T01.03**: `Rutas.restablecer`, el mapeo de `carecar://restablecer?token=…` y del enlace universal `https://<host>/app/restablecer?token=…`, y la ruta ya figuraba entre las públicas. Esta historia solo le colgó pantallas. Hay una prueba de la vuelta completa: el enlace llega a la pantalla con su token, porque si el camino o el nombre del parámetro no coincidieran, el correo abriría una pantalla que dice «enlace roto».

**Los dos 400 que no se pueden confundir**

Es el filo de la historia. Un enlace vencido o usado y una contraseña que no cumple **llegan los dos como 400**, y solo los separa `Problema.codigo` (`CODIGO_INVALIDO` contra `DATOS_INVALIDOS`):

| Qué pasó | Qué ve la persona |
| --- | --- |
| Enlace vencido o usado | Se **retira el formulario** y se ofrece **pedir otro enlace**. Ahí no hay nada que corregir |
| Contraseña rechazada | Se **conserva el formulario** para corregir, y **no** se ofrece pedir otro: el enlace estaba bien, y mandar a pedir otro sería hacer empezar de cero sin motivo |
| Sin conexión | Advertencia, y el enlace se conserva |

**Hallazgos**

- **Traducir a un fallo de dominio tiene que ir fuera de `pedir`, no dentro.** Un fallo de dominio es una `Exception` normal y `RepositorioBase.pedir` tipa todo lo que no sea `ExcepcionApi`, así que traducir dentro lo convertiría en `ErrorDelServidor` y la pantalla perdería el único dato que necesita. Soy la primera en adoptar `RepositorioBase` —`citas` traduce sus 409 sin usarlo—, así que esto habría esperado al siguiente. Queda en tres lugares: el aviso en el código, una prueba que falla si alguien lo mueve adentro, y la guía de [`lib/modulos/README.md`](../../lib/modulos/README.md#el-núcleo-de-datos).
- **Un enlace sin token** (`carecar://restablecer` a secas) no estaba en los criterios. La pantalla arranca en el estado de enlace no válido sin pedir contraseña: pedírsela a quien de todos modos no va a poder guardarla es perderle el tiempo.
- **El patrón del doble toque apareció por tercera vez.** En las tres pantallas, terminar la operación dejaba el botón otra vez habilitado. Aquí se previó desde la prueba en lugar de descubrirlo.

**Decisiones**

- **`PeticionRestablecer` gana una forma en vez de cambiar la que hay.** El contrato acepta las dos y la pantalla v1 sigue mandando correo y código sin tocarse. Cada forma manda **solo sus campos**: un `correo` vacío junto al token haría que el backend intentara la forma v1 y respondiera 400 por datos inválidos, y eso se vería como «el enlace no sirve» cuando el enlace estaba bien.
- **El aviso de «revisa tu correo» dice «si ese correo tiene una cuenta».** El contrato responde 202 exista o no, para no revelar qué cuentas hay; una redacción descuidada en la app tiraría por la borda esa protección, y quien se equivocó al teclear tiene que entender que puede no llegarle nada.
- **La validación del correo salió a `dominio/`** en vez de duplicarse, y la pantalla de acceso se reescribió para usarla. A diferencia del reloj y del aviso de espera del servidor —duplicados porque chocaban con R1 y R3 y no tenían dónde vivir—, esta sí tiene casa.
- **`ListaDeReglas` gana `mostrarDistinta`**: en la recuperación no hay contraseña temporal que conocer, así que esa regla siempre se cumpliría y sólo confundiría.

**Pendiente / fuera de alcance:** encender las rutas del módulo. **Esta historia cerró el segundo de los tres bloqueos**, así que ya solo falta actualizar las trece pruebas ajenas que comprueban la redirección por el widget y no por la ruta — es mecánico, pero toca código de otras cuatro personas y merece su propia historia. También falta demostrarlo en celular con un correo real, que es lo que le falta a la fila de `cumplimiento-ficha.md` para pasar a ✅, y las capturas.

## Avance de V2-M01.11

**Qué quedó**

`test/modulos/acceso/sesion_de_30_dias_test.dart`, con **cinco pruebas de integración**. Ni una línea de código de producción.

**Por qué no hizo falta construir nada**

Los dos criterios ya funcionaban, y conviene que quede escrito de dónde sale cada uno:

| Criterio | Quién lo cumple ya |
| --- | --- |
| Refresco transparente | `ControladorSesion.renovar()` con su guardia `_refrescoEnCurso`, más el reintento ante 401 de `ClienteApi` (Sprint 3, TEC-6 T3/T4) |
| Si falla, vuelve a login conservando el destino | `enrutadorProvider` escucha `estadoSesionProvider` con `refreshListenable`, y `redirigirPorSesion` arma `/acceso?desde=…` (V2-T01.03) |

Las piezas estaban probadas **por separado**: el controlador rota el par (`test/sesion/controlador_sesion_test.dart`), el cliente reintenta una vez (`test/api/sesion_con_refresco_test.dart`) y el guardia sabe guardar el destino (`guardia_sesion_test.dart`). Lo que nadie había probado es **la suma**, que es justo lo que dicen los criterios y lo que pide la DoD.

**Las dos pruebas que importan**

- **«El par nuevo queda guardado, no el gastado.»** Es el riesgo más caro de esta historia. El refresh es de un solo uso y, según Ricardo, reusar uno gastado hace que el backend **cierre todas las sesiones de la cuenta** porque lo toma como posible robo. Se comprobó empíricamente en el Sprint 3 montando dos sesiones; ahora queda fijado desde el nivel de la app, no solo del almacén.
- **«Si la sesión muere estando en una pantalla privada, se guarda el destino.»** Se agregó después de ver que la primera versión **no probaba el criterio**: comprobaba que iba a `/acceso`, pero el usuario estaba en el inicio y no había destino que conservar, así que la aserción pasaba sin probar nada. El criterio es otro: estabas en `/garaje`, el refresco murió y no deberías perder dónde ibas.

**Pendiente / fuera de alcance:** el riesgo que no se puede cerrar desde la app —si el proceso muere entre que el servidor consume el token viejo y la app guarda el nuevo, el guardado ya está gastado y el siguiente refresco cierra todas las sesiones—. La única solución es que el servidor acepte el token anterior unos segundos; **vale proponérselo a Ricardo**. Y demostrar los 30 días en celular, que es lo que le falta a la fila de `cumplimiento-ficha.md`.
