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

## Ajustes en el lenguaje v2 (V2-T02.24)

Ajustes (`lib/pantallas/perfil/pantalla_perfil.dart`, v1) ya se ve como el resto de la app: marco con regreso, el perfil en una tarjeta de resumen, grupos de lista, interruptor del sistema y diálogo y hoja del sistema. Es solo el aspecto: nada de lo que piden las historias de abajo cambia.

- **V2-M01.06 (Ver mi perfil)** puede mover esta pantalla a un módulo `perfil` y completar sus estados; los textos siguen escritos a mano y habría que pasarlos a `app_es.arb`/`app_en.arb`.
- **V2-M01.10 (Cambiar mi contraseña desde Seguridad)** ya sustituyó a la pantalla v1 que abría «Cambiar contraseña»: la fila lleva a `/mi-contrasena` cuando hay enrutador, y la v1 se queda solo para cuando Ajustes se monta sin él.
- Quien agregue una fila a Ajustes agrega un `_Opcion(...)` a su sección en `pantalla_perfil.dart`; el aspecto y la llave de la fila salen solos.

## Avance de V2-M01.05

**Es un candado local, no otra forma de iniciar sesión.** Los tokens siguen en el almacén seguro y la sesión se renueva igual (V2-M01.11); la biometría solo decide si la app se abre sin escribir la contraseña. Decirlo importa porque la otra lectura —«entrar con la huella»— haría pensar que la huella sustituye a la contraseña en el servidor, y no.

`local_auth` queda detrás de `LectorBiometrico` (`lib/nucleo/biometria/`), con un solo archivo que lo importa. Pide configuración nativa: `MainActivity` hereda de `FlutterFragmentActivity` —el `BiometricPrompt` de Android se monta como fragmento, y con `FlutterActivity` falla en tiempo de ejecución—, el manifiesto declara `USE_BIOMETRIC` y el `Info.plist` describe el uso de Face ID.

**Siempre hay salida con la contraseña**, y es lo que vuelve segura la comodidad: si el sensor falla o la biometría se borra, nadie se queda fuera de su cuenta. Esa salida **cierra la sesión** a propósito: si solo navegara, la guardia traería de vuelta al desbloqueo en el siguiente toque.

**Prenderlo exige identificarse ahí mismo.** Prenderlo sin comprobar que funciona dejaría a la persona encerrada fuera en el siguiente arranque. Y el interruptor va **suelto** en el perfil, no como `fin` de una fila de `GrupoLista`: ese grupo envuelve la fila en `Semantics(excludeSemantics: true)` y el lector de pantalla no lo leería.

**Quien acaba de escribir su contraseña no tiene que poner la huella encima.** El candado se abre solo cuando el login pasa por `Autenticando`, que es justo lo que distingue entrar escribiendo de restaurar la sesión guardada.

### El criterio del cambio de biometría, con su límite escrito

Al prenderlo se guarda una **firma**: qué clases de biometría tenía el equipo. Si al abrir no coincide, el candado se apaga y se pide la contraseña. Eso cubre que se borren todas, que se quite el rostro o que aparezca una clase nueva. **No cubre que alguien agregue otra huella del mismo tipo**: el sistema sigue reportando «huella» y `local_auth` no expone más. Verlo exigiría una llave del Keystore creada con `setInvalidatedByBiometricEnrollment`, es decir un canal nativo propio por plataforma. Queda anotado aquí y en la revisión MASVS (AUTH-2) en vez de fingir que el criterio cubre más de lo que cubre.

Diez pruebas, con un lector falso porque en una prueba no hay `BiometricPrompt`: el estado del candado, la comparación de firmas —incluido que sin firma guardada se pida la contraseña, por el lado seguro—, la guardia, y la app enrutada abriendo con huella buena, fallando y con la biometría cambiada. **Falta probarlo en un celular de verdad**: aquí no hay RAM para el emulador y iOS no se compila.

## Avance de V2-M01.02

Quien decide mostrarla es la **guardia de rutas**, y va antes que todo, incluido el login: la bienvenida es del primer arranque, no de la cuenta, así que tiene que verla también quien todavía no ha entrado. Por eso el estado vive en `lib/nucleo/bienvenida/` y no en el módulo: la guardia está en el núcleo y no puede importar un módulo.

«Una sola vez» se recuerda en las preferencias del dispositivo (`bienvenida_vista`), con las mismas que ya usaba el idioma. **Sin preferencias se responde que no falta verla**: mostrarla sin poder recordarlo la repetiría en cada arranque, y eso es peor que no mostrarla.

Saltarla y terminarla hacen lo mismo —marcar que ya se vio—, porque el criterio es que no vuelva a estorbar, no que se lea completa. «Saltar» está arriba y alcanzable desde la primera lámina, no al final del recorrido.

Lector de pantalla: cada lámina anuncia su título como **encabezado** y luego el texto; los puntos de abajo quedan fuera del árbol de semántica, porque son decorativos y repetir «paso 2 de 3» en tres nodos solo estorba.

Seis pruebas: la guardia (pendiente va antes del login, en la bienvenida se queda, vista no estorba), el estado (primer arranque, que lo recuerde, y sin preferencias) y la app enrutada (aparece, se salta y lleva al acceso, y no vuelve).

## Avance de V2-M01.08

El 403 se atiende **en un solo lugar**: `ClienteApi._pedir`, el embudo por el que pasan todas las peticiones con token. La cuenta se puede desactivar con la persona dentro, así que el 403 puede llegar en cualquier pantalla; resolverlo pantalla por pantalla habría dejado huecos. Ahí se avisa con `alCuentaDesactivada` —un callback, como `renovarSesion`, para que la capa de datos no dependa de la de sesión— y `ControladorSesion` borra la sesión local y marca `SinSesion(porCuentaDesactivada: true)`. Solo se avisa si **hay** token: un 403 sin sesión no tiene sesión que cerrar.

De ahí en adelante decide la guardia (`redirigirPorSesion`), que ya es pura y probada: con esa marca, **cualquier** ruta —incluido el login— lleva a `/cuenta-desactivada`. El camino vive en `Rutas` y no en el módulo porque la guardia está en el núcleo y no puede importar un módulo.

**Dos pruebas que ya existían cambiaron de expectativa, a propósito.** Esperaban que un 403 al entrar se quedara en el login mostrando el mensaje del servidor (`controlador_sesion_test.dart` y la del login v1). Ese mensaje invitaba a reintentar algo que no se arregla reintentando, y el criterio pide una **pantalla dedicada**. Las dos quedaron reescritas diciendo por qué.

La pantalla es un callejón a propósito: sin campos y sin «intentar de nuevo». Solo llamar a la agencia, escribirle, o volver al login si fue un error —y volver exige `reconocerCuentaDesactivada()`, porque si no la guardia regresaría ahí para siempre—. El `tel:` y el `mailto:` pasan por `abrirEnlaceProvider` para que la prueba no toque la plataforma.

## Avance de V2-M01.10

Pantalla propia (`PantallaMiContrasena`, ruta `/mi-contrasena`) y **no** un modo de la del cambio obligatorio: esa a propósito no tiene salida (V2-M01.03) y mezclarlas haría frágil justo el criterio que la define. Reusa `ReglasContrasena` y `ListaDeReglas`, así que la contraseña nueva se revisa con las mismas reglas en vivo. **No toca el contrato ni el backend.**

**El criterio dice «cierra las demás sesiones» y eso no se puede hacer hoy.** El contrato solo tiene `DELETE /sesiones`, que cierra **todas, incluida la de quien llama**, y la app no puede saber cuál de la lista es este celular: eso espera el claim `sid` en el JWT, que es de `shared` y de otra persona. Las opciones eran tres: no ofrecerlo —y dejar sin salida a quien cambia su contraseña porque sospecha que alguien entró—, decir «las demás» y cerrar también esta —mentir—, o decirlo tal cual. Se eligió lo tercero: la casilla dice «cerrar sesión en todos mis dispositivos» y explica que incluye este, y al terminar la app suelta su propia sesión, porque el access token en curso sigue valiendo hasta que expire. **Cuando exista `sid`, esto se vuelve «las demás» sin tocar la pantalla**, solo el repositorio.

La casilla viene **apagada**: cambiar la contraseña no debe sacar a nadie de sus otros dispositivos sin habérselo pedido. Y si el cambio funciona pero cerrar las sesiones falla, el aviso de éxito **se queda** y el fallo se muestra aparte: la contraseña ya cambió y decir lo contrario sería peor.

Tres pruebas, una por criterio y una por el riesgo: que pida la actual y no toque las sesiones, que con la casilla marcada cierre todo y suelte esta sesión, y que un rechazo del servidor no cierre nada ni diga que se guardó.

## Avance de V2-M01.06

**Lo primero que apareció fue que la historia no se podía cumplir como estaba escrita.** El criterio pide nombre, correo, **teléfono**, **«cliente desde»** y vehículos; el contrato declaraba `Perfil` con `id`, `nombre` y `correo`, y `PerfilApp` del backend devolvía esos tres. La historia estaba marcada **sin** parte de backend y se corrigió a `B` al tomarla. No hizo falta migración: `cliente` ya tenía `telefono` y `created_at`.

**Qué quedó**

| Pieza | Qué resuelve |
| --- | --- |
| Contrato 2.23.0 | `Perfil` gana `telefono` y `clienteDesde` |
| `api/modelos/perfil.dart` | Los lee; la caché los guarda |
| `dominio/perfil_del_cliente.dart` | Distingue «no hay teléfono» de «hay uno vacío» |
| `datos/` y `presentacion/` | `RepositorioAcceso.perfil()`, `perfilProvider`, `PantallaMiPerfil` y la ruta `/mi-perfil` |
| Ajustes v1 | Una fila más que abre el perfil |
| Backend | `ClienteRegistrado` y `PerfilApp` con los dos campos |

**Las dos reglas no son simétricas, y de ahí sale casi todo**

- **El teléfono puede faltar**: la agencia no siempre lo captura. Es opcional en el contrato, y la pantalla dice «Sin teléfono registrado» en vez de dejar el renglón vacío, que parecería un error de la app. Un teléfono con solo espacios cuenta como que no hay.
- **«Cliente desde» siempre viene**, porque `cliente.created_at` es `not null`, así que va en `required`. Y es una **fecha**, no un instante: el servidor la resuelve en la zona de la agencia, porque convertirla en el celular haría que quien se registró el 1 de marzo a las 02:00 UTC apareciera como «desde febrero» en México.

**Dos lecturas, dos estados.** El perfil y el garaje se piden por separado y cada uno lleva el suyo: si los vehículos no cargan, el perfil se sigue viendo con un aviso pequeño. Perder los datos que el cliente vino a confirmar porque una lista no respondió sería peor. Por eso esa sección no usa `VistaAsincrona`, que pinta el error a pantalla completa. Los vehículos vienen del módulo `vehiculos` por su contrato público (regla R1).

**Esta historia vuelve alcanzable a V2-M01.09.** «Mis sesiones» tenía ruta y nada que llevara a ella; ahora se abre desde el perfil, y el perfil desde una fila más en Ajustes.

**Dos cosas que conviene que el equipo sepa**

- **La caché habría roto el perfil sin conexión**: guardaba solo `id`, `nombre` y `correo`, y releer esa copia con un campo obligatorio nuevo habría fallado. Ya guarda los cinco. No hizo falta tocar nada para las copias viejas: `_copia` descarta y borra la que no se puede leer con la forma de ahora.
- **En el backend, la zona de la agencia está definida en tres lugares** (`AgendaAppService`, `ServicioApp` y una copia privada en `RecoleccionService`). Se usó la de `ServicioApp`; unificarlas merece su propia historia.

**Pendiente:** demostrarlo en celular, que es lo único que le falta a su fila de `cumplimiento-ficha.md`. Editar teléfono y correo es V2-M01.07, que esta historia desbloquea.

## Avance de V2-M01.07

**Se hizo la mitad del correo. La del teléfono está bloqueada.**

El criterio pide confirmar con **un código enviado al dato nuevo**. Para el teléfono eso exige un SMS, y en el backend no hay nada: ni proveedor, ni configuración, solo SMTP. Se buscó antes de empezar. Mandar ese código al correo verificaría que el dueño de la cuenta autorizó el cambio, **no que el teléfono sea suyo**, que es justo para lo que sirve la verificación; y contratar un proveedor tiene costo, credenciales y configuración, así que es una decisión del equipo.

⚠️ **Queda pendiente preguntárselo.** La tabla se diseñó para los dos tipos —el `check` acepta `TELEFONO`— para que esa mitad no necesite otra migración.

**Qué quedó**

| Pieza | Qué resuelve |
| --- | --- |
| Contrato 2.26.0 | `PATCH /perfil` y `POST /perfil/verificaciones/{id}/confirmar` |
| `verificacion_contacto` (V57) | El dato nuevo espera aquí, con el código en BCrypt, 15 minutos y 5 intentos |
| `CambioDeContactoService` | Los dos pasos, separado como `RecuperacionContrasenaService` |
| `EnvioCorreos.enviarCodigoDeContacto` | El código va **al correo nuevo** |
| App | `pedirCambioDeCorreo`, `confirmarVerificacion`, tres fallos de dominio y `PantallaCambiarCorreo` |

**Las tres decisiones que mandan**

1. **El correo no se guarda hasta confirmar.** Vive en `valor_nuevo`. Guardarlo antes dejaría al cliente con un correo que no ha probado que es suyo y, como `cuenta_app.usuario` lo sigue (V2-T05.03), **sin poder entrar**.
2. **Pedir el cambio exige la contraseña actual.** No lo decía el criterio; se propuso aparte. El correo es la identidad con la que se entra, así que sin eso alguien con el celular desbloqueado podría cambiarlo al suyo, recibir el código en su buzón y quedarse con la cuenta. Mismo requisito y precedente que cancelar la cuenta.
3. **Los tres errores se distinguen por `Problema.codigo`**, y los tres códigos ya existían. La contraseña equivocada y el correo mal escrito llegan los dos como **400**; la pantalla señala cada uno en su campo. Confundirlos le diría a la persona que corrija lo que estaba bien.

**Lo que costó integrarlo, por si le sirve a alguien más**

El CI del backend encontró tres cosas en cadena, ninguna visible en una máquina sin Docker:

- **El PR no corría CI** porque tenía conflictos con `main`: GitHub no ejecuta los workflows de un PR que no puede fusionar, así que «no hay checks» se parece a «va despacio». Si un PR lleva minutos sin un solo check, revisar `mergeStateStatus` antes de esperar más.
- **Choque de números de migración.** Entró otra V55 mientras la historia se construía. **El rebase no lo detecta** —son archivos distintos—; solo Flyway al arrancar. El número se toma *después* de rebasar, mirando el directorio.
- **Dos constructores sin `@Autowired`**: el contexto de Spring no arranca. Ni `test-compile` ni `checkstyle` lo ven.

**Pendiente:** la mitad del teléfono (bloqueada por el SMS) y demostrar el cambio de correo en celular.

## Avance de V2-M01.09

**Qué quedó, en la app**

| Pieza | Qué resuelve |
| --- | --- |
| `api/modelos/sesion.dart` | `SesionActiva` del contrato 2.22.0 y el `dispositivo` opcional del login |
| `api/carecar_api.dart` + `carecar_api_http.dart` | Las tres operaciones de `/sesiones` |
| `cache/carecar_api_con_cache.dart` | La lista **no se guarda en copia local**, a propósito (ver abajo) |
| `nucleo/dispositivo/` | El nombre del equipo: la regla pura, aparte del plugin, y el borde que lee `device_info_plus` |
| `sesion/controlador_sesion.dart` | El login manda el nombre, con el lector como tercer parámetro **opcional** |
| `dominio/sesion_de_la_cuenta.dart` | El tipo de dominio, con `ultimaSenal` = último uso, o el inicio si nunca se refrescó |
| `dominio/antiguedad.dart` | En qué tramo cae «hace cuánto». Devuelve números y un tramo, nunca texto |
| `dominio/fallos_acceso.dart` | `SesionYaNoEsta`, para el 404 que no significa «ya no está» |
| `presentacion/proveedores_acceso.dart` | `sesionesProvider`, con las dos formas de cerrar |
| `presentacion/pantalla_sesiones.dart` | La pantalla, con los cinco estados |
| `presentacion/rutas_acceso.dart` | `rutasSesiones`, **sí registrada** (ver abajo) |

**Las tres decisiones que mandan en esta historia**

1. **Nunca decir que una sesión se cerró si no se cerró.** El backend crea una fila nueva en cada refresco, así que el `id` que la pantalla tiene en mano envejece: si la otra sesión se refrescó entremedias, el `DELETE` responde **404 y la sesión sigue viva con otro id**. Quitarla de la lista ahí le diría al cliente que echó al intruso cuando no lo hizo, que es lo contrario de lo que esta pantalla existe para responder. Así que un 404 relee la lista —para que la sesión vuelva con su id nuevo y el reintento funcione— y avisa. Sin conexión tampoco la quita: no significa «ya no está», significa que no se sabe.
2. **La lista no se guarda en copia local.** Una copia vieja diría que la sesión que se acaba de cerrar sigue abierta, o peor, que no hay ninguna intrusa cuando sí la hay. A «¿quién está dentro de mi cuenta ahora?» se responde con el servidor o no se responde. `cerrarTodas` sí limpia la copia, porque incluye la sesión de este teléfono.
3. **Cerrar todas avisa antes y cierra también aquí.** El access token en curso sigue valiendo hasta que expire, así que si la app se quedara dentro el cliente creería que no se cerró nada.

**Dos cosas que no eran obvias y conviene que queden escritas**

- **`GrupoLista` no deja que el lector de pantalla alcance lo que va en `fin`** (su propia documentación lo dice: «el `fin` no se lee»), porque envuelve la fila en `Semantics(excludeSemantics: true)`. Un botón ahí sería **inalcanzable con lector de pantalla**. Por eso la acción de cada fila es la fila completa, con lo hablado en `etiquetaFin`, y cada cierre pide confirmación —que además evita echar a un dispositivo con un toque sin querer al desplazarse. **Si alguien necesita un `fin` interactivo, hay que cambiar el componente**: es candidato a una historia de `V2-T02.xx`.
- **`/sesiones` sí se registra, hoy.** Va en su propia lista (`rutasSesiones`), aparte de `rutasAcceso`: las otras cuatro rutas del módulo siguen esperando a que el acceso se encienda porque sus caminos ya los sirven pantallas v1, pero `/sesiones` no existe en la v1, así que no choca con nada y no obliga a tocar las trece pruebas ajenas. Sin esto la pantalla existiría y nadie podría abrirla.

**Lo que esta historia NO puede hacer**

La lista **no marca «este dispositivo»**. El JWT lleva `uid` y `roles` pero no el id de la sesión, así que el servidor no sabe cuál de ellas está preguntando. Marcarlo exigiría un claim `sid` y tocar `JwtService`, `UsuarioAutenticado` y el filtro, que usan también el ERP y el CRM: es un cambio de `shared` con alcance mucho mayor que esta historia y **se propone aparte**. Mientras tanto, `DELETE /sesiones` se presenta como «cerrar sesión en todos los dispositivos», que incluye el propio y es la lectura segura.

**Dependencia nueva:** `device_info_plus`, autorizada por Jael el 26 de noviembre de 2026. Nada de lo que ya había da el modelo del equipo, y sin nombre la lista muestra todas las sesiones iguales. Queda detrás de `LectorDelDispositivo`, así que cambiarla toca una clase. No se lee ningún identificador del equipo: en iOS se manda `modelName` y no `name`, porque `name` es el nombre que la persona le puso al teléfono y sí la identifica.

**La parte del backend ya está** (`agencia-360-backend#108`): las tres columnas de `sesion_app` (V52), los tres endpoints y 16 pruebas de integración.

**Y de paso destapó un defecto que no era de esta historia.** `refrescar` tomaba como posible robo **cualquier** refresh token revocado y cerraba todas las sesiones de la cuenta, sin distinguir por qué se revocó. Con `/auth/cerrar-sesion` eso nunca se notaba, porque el mismo dispositivo borra sus tokens y no reintenta; pero cerrar una sesión **ajena** sí lo alcanza, porque ese dispositivo conserva su token y lo usa en su siguiente intento. Resultado: cerrar la sesión de una tablet dejaba al cliente fuera de su propio celular, y cerrar la de un celular robado le regalaba al ladrón una negación de servicio.

El arreglo guarda el motivo (`motivo_revocacion`, V53) y el cierre masivo se dispara **solo** cuando el token lo consumió un refresco, que es el único caso que delata una copia. La protección no se debilita y hay una prueba para eso. Ricardo, que definió la regla original, lo confirmó.

**Pendiente:** demostrarlo en celular, que es lo único que le falta a la fila de `cumplimiento-ficha.md`.

## Avance de V2-T01.10 (el acceso, encendido)

El inicio de sesión y el cambio obligatorio de la contraseña temporal (V2-M01.01 y V2-M01.03) **ya son lo que ve quien abre la app** (`ModuloMigrable.acceso`, v2 por defecto). Lo hizo Daniel como parte de «terminar de pasar las pantallas a v2»; es un PR propio y reversible (`--dart-define=MODULOS_V1=acceso`). Los tres bloqueos que se habían anotado aquí quedaron así:

| Bloqueo anotado | Cómo quedó |
| --- | --- |
| «¿Olvidaste tu contraseña?» muerto | **Era peor de lo anotado:** el botón de la v2 tenía el cuerpo vacío (`_olvide() {}`), no solo faltaba la pantalla de destino. Ahora va a `/recuperar` con el correo escrito (si parece correo) y lo sirve la recuperación que esté encendida |
| La recuperación v2 (V2-M01.04) | **No se enciende**: es el módulo `recuperacion`, aparte, y sigue en v1. El motivo no es de la pantalla sino del correo (abajo) |
| Las trece pruebas que miraban `PantallaLogin` | Diecinueve archivos de pruebas de rutas usan ahora `pantallaDeAcceso` (`test/ayudas/app_enrutada.dart`): una sola definición de qué pantalla es la de acceso |

**Por qué la recuperación v2 espera.** Al revisar el correo que manda el backend (`RecuperacionContrasenaService`) aparecieron tres cosas que juntas dejarían sin salida a quien olvida su contraseña:

1. El enlace es `carecar://restablecer-contrasena?token=…` (valor por omisión de `RECUPERACION_ENLACE`) y la app entiende `carecar://restablecer?token=…`. Tocarlo llevaría a una ruta que no existe.
2. El enlace universal `https://<host>/app/restablecer` usa `carecar.example.com`, un marcador: sin dominio real con `assetlinks.json` y `apple-app-site-association` abre el navegador, no la app.
3. El correo trae también el **código de 6 dígitos**, que solo la pantalla v1 sabe recibir. La v2 no tiene dónde escribirlo.

La v1 sí funciona hoy (correo con código). Encender la v2 sin resolver esto cambiaría algo que sirve por algo que no.

**Para encender la recuperación v2** (lo que sigue y a quién le toca decidir): (a) el dominio real y sus dos archivos de verificación (T01.03 lo dejó como `CONFIGURAR`), (b) que el backend mande el enlace que la app reconoce o que la app acepte también `restablecer-contrasena`, (c) probarlo en un celular con un correo real, que es también lo que le falta a la fila de `cumplimiento-ficha.md`, y (d) agregar `ModuloMigrable.recuperacion` a `InterruptorModulos.porDefecto`. Mientras tanto se prueba con `--dart-define=MODULOS_V2=recuperacion`.

**Pendiente:** demostrar el inicio de sesión v2 en un celular real (fila de `cumplimiento-ficha.md`). V2-M01.10 ya conectó «Cambiar contraseña» de Ajustes con la pantalla v2 (`/mi-contrasena`), y la prueba `test/nucleo/migracion/convivencia_acceso_test.dart` lo comprueba con el acceso v2 por defecto.
