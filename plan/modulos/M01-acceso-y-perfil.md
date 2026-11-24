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
| V2-M01.03 | Como cliente con contraseña temporal quiero cambiarla obligatoriamente para proteger mi cuenta | Dado `debe_cambiar_contrasena`, no puedo navegar a otra pantalla hasta cambiarla · reglas en vivo (largo, número, mayúscula) · no acepta la temporal como nueva | | V2-M01.01 |
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
