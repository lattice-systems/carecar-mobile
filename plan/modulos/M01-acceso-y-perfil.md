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
