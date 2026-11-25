# M22 · Seguridad y privacidad

| Campo | Valor |
| --- | --- |
| Hito | H2 (base) → H7 (MASVS) |
| Dueño | Daniel |
| Revisa | Ricardo |
| Ficha técnica | ✅ Sección 20. Seguridad y privacidad |
| Estado | En curso: M22.01, M22.02, M22.03, M22.04 y M22.07 implementadas (M22.01 a M22.04: falta demostrarlas en celular); M22.08 con su primera pasada (se repite al cerrar H6); M22.05, M22.06 y M22.09 hechas |

## Propósito

Datos del cliente protegidos y bajo su control, conforme a la LFPDPPP (derechos ARCO) y OWASP MASVS L1. Mueve O8.

## Datos

| Tabla | Campos | Notas |
| --- | --- | --- |
| `aviso_privacidad` ➕ | id, version, texto, vigente_desde | Versionado; nunca se edita uno publicado. |
| `aceptacion_aviso` ➕ | id, cuenta_app_id, aviso_privacidad_id, aceptado_en | Una por versión aceptada. |
| `solicitud_arco` ➕ | id, cliente_id, tipo (acceso/rectificacion/cancelacion/oposicion), estado, archivo_url, creada_en, resuelta_en | |

## Historias

| ID | Historia | Criterios de aceptación | B | Depende de |
| --- | --- | --- | --- | --- |
| V2-M22.01 | Como cliente quiero leer el aviso de privacidad real | Texto versionado del backend · aceptación registrada en primer ingreso y al cambiar de versión | ✅ | V2-M01.01 |
| V2-M22.02 | Como cliente quiero descargar mis datos (acceso ARCO) | Solicitud genera archivo con todos mis datos · aviso al estar listo | ✅ | V2-M01.06 |
| V2-M22.03 | Como cliente quiero pedir que borren mi cuenta (cancelación ARCO) | Flujo con confirmación · se desactiva `cuenta_app` y se anonimizan datos no obligatorios por ley; lo fiscal se conserva | ✅ | V2-M01.06 |
| V2-M22.04 | Como equipo queremos fijar certificados del servidor | Certificate pinning en release con plan de rotación | | V2-T04.02 |
| V2-M22.05 | Como equipo queremos detectar equipos comprometidos | Aviso (no bloqueo) en root/jailbreak; sin datos en caché si se detecta | | — |
| V2-M22.06 | Como equipo queremos ocultar datos en el selector de apps | Pantalla cubierta en segundo plano; capturas bloqueadas en pantallas de pago y documentos | | — |
| V2-M22.07 | Como equipo queremos logs sin datos personales | Lint/regla y prueba que falle si se registra correo, teléfono, VIN o token | | V2-T03.01 |
| V2-M22.08 | Como equipo queremos una revisión MASVS L1 | Checklist en `docs/seguridad/` con evidencia por control | | H6 |
| V2-M22.09 | Como equipo queremos HTTPS fuera de local | `API_BASE_URL` http solo en flavor de desarrollo | | V2-T04.01 |
| V2-M22.10 | Como cliente quiero saber qué proveedores externos reciben mis datos | El aviso de privacidad nombra el alojamiento (Azure y Neon), las teselas del mapa, el geocodificador del teléfono y al asistente (Gemini) · versión 2 vigente que todas las cuentas aceptan de nuevo | B | V2-M22.01 |
| V2-M22.11 | Como equipo queremos un escaneo periódico de dependencias | Escaneo semanal de `pubspec.lock`, Gradle y Pods en CI · aviso si aparece una vulnerabilidad alta o crítica | | V2-M22.08 |
| V2-M22.12 | Como equipo queremos que los tokens de iOS no viajen a otro equipo | Keychain con `first_unlock_this_device` · migración que no cierra sesiones · prueba | | V2-M22.08 |
| V2-M22.13 | Como equipo queremos que la caché no guarde lo que identifica | Caché cifrada (AES-256-GCM, llave en el almacenamiento seguro) · se borra, con su llave, al cerrar sesión · las copias en claro de versiones anteriores se borran al arrancar | | V2-M22.08 |
| V2-M22.14 | Como equipo queremos enlaces universales con el dominio real | `assetlinks.json` y `apple-app-site-association` servidos · o sin `autoVerify` mientras no existan | | V2-M22.08 |
| V2-M22.15 | Como equipo queremos un mensaje propio si falla un pin de certificado | Un certificado rechazado se distingue de la falta de red · un aviso global dice «No pudimos verificar que la conexión sea segura» y qué hacer, y se quita con la siguiente respuesta · las imágenes quedan con el cliente del sistema (riesgo aceptado) | | V2-M22.04 |
| V2-M22.16 | Como equipo queremos ofuscar el código de release | `--obfuscate --split-debug-info` en `release.yml` · símbolos subidos con los reportes de fallos | | V2-M23.01 |

## Notas de implementación

### V2-M22.05 · Equipos comprometidos (hecha, PR #76)

- **Detección**: interfaz `DetectorIntegridad` en `lib/nucleo/seguridad/`; implementación real `DetectorIntegridadDelSistema` sobre [`safe_device`](https://pub.dev/packages/safe_device) y `DetectorIntegridadFalso` para pruebas. Los módulos nunca importan el paquete.
- **Por qué `safe_device`**: licencia MIT, publicador verificado, mantenido (1.4.1, 2026), Android e iOS, API de una llamada (`isJailBroken`). Descartados: `jailbreak_root_detection` (pub.dev no declara licencia), `flutter_jailbreak_detection` (sin publicar desde 2023) y `freerasp` (RASP completo con SDK nativo propio, desproporcionado para un aviso). Es una señal, no una garantía: un equipo comprometido puede ocultarlo.
- **Falla seguro**: `evaluarIntegridad` nunca lanza; un error o una espera mayor a 3 s da `desconocido` y la app arranca igual. `desconocido` permite el caché (sin señal de riesgo no se le quita la función sin conexión a nadie).
- **Aviso, no bloqueo**: `AvisoEquipoComprometido` muestra un `Aviso` de advertencia cerrable sobre la navegación. Usa tema Pista provisional hasta V2-T01.05. Probado en claro, oscuro y letra al 200 %.
- **Sin datos en caché**: `PoliticaDatosLocales.permiteCacheLocal` es `false` si el equipo está comprometido.
  - Aplicada hoy a `CarecarApiConCache` (no escribe, no lee y borra lo existente, también si la detección llega tarde) y al widget de inicio de la próxima cita (queda sin datos de cita).
  - Fuera de alcance de la política: tokens (ya en `flutter_secure_storage`) y preferencias que no son datos del cliente (idioma).
- **Contrato para V2-M21.01** (base local): antes de abrir, escribir o leer la base, consultar `ref.watch(politicaDatosLocalesProvider).permiteCacheLocal`; si es `false`, no crearla ni leerla, y escuchar la política para borrarla si cambia a comprometido. Añadir prueba equivalente a `test/cache/carecar_api_con_cache_test.dart` (grupo "equipo comprometido").
- **Pendiente**: `LSApplicationQueriesSchemes` (cydia) en iOS mejora la detección de jailbreak; se deja a la historia que toque `Info.plist` (T01.04/M22.06) para no pisar su alcance. Registro de la detección en logs: ninguno (sin datos personales).

- **V2-M22.06** (hecha, PR #77): `lib/nucleo/privacidad/` (`CubiertaEnSegundoPlano`, `PantallaSegura`, `ProteccionDeCaptura` con fake), canal Android `FLAG_SECURE` y cubierta nativa iOS. Diseño, límites (iOS no bloquea capturas) y uso en [`docs/seguridad/ocultar-en-selector.md`](../../docs/seguridad/ocultar-en-selector.md). Pendiente como historia nueva (Borrador): detectar captura/grabación en iOS (`UIScreen.isCaptured`) y tapar o avisar en pantallas de pago y documentos.

- **V2-M22.09 · HTTPS fuera de local**: solo el flavor `desarrollo` habla `http://` (el mock local). Capas:
  - **Nativo** (V2-T01.04): `usesCleartextTraffic` por flavor en Android y ATS abierto solo en `Info-desarrollo.plist`.
  - **API**: `ApiConfig` rechaza un `API_BASE_URL` con http en `pruebas` y `produccion`.
  - **Manual del vehículo**: `ManualesDeLaAgencia` no baja una URL firmada por http fuera de desarrollo; usa el manual incluido en la app (la firma se podría leer en el camino).
  - **Mapas**: `ConfiguracionTeselas` lanza si `TILES_URL` usa http fuera de desarrollo.
  - **CI**: `release.yml` e `ipa-sin-firma.yml` fallan antes de compilar si la variable `API_BASE_URL` no empieza con `https://`.
  - Pruebas: `test/config/`, `test/api/manuales_agencia_test.dart`, `test/nucleo/mapas/configuracion_teselas_test.dart`.

- **V2-M22.01 · Aviso de privacidad versionado** (PR #127, backend#96, contrato 2.13.0): el backend guarda cada versión del aviso (inmutable por disparador) y una aceptación por cuenta y versión; `GET /privacidad/aviso` y `POST /privacidad/aceptaciones` (idempotente, 409 `AVISO_NO_VIGENTE`). En la app, `VerificadorDeAviso` pregunta con cada sesión, la guardia del enrutador lleva a la puerta (`/privacidad/aceptar`) si falta aceptar, y «Aviso de privacidad» del perfil abre el texto del servidor. Sin conexión no se bloquea a nadie. Diseño, decisiones y límites en [`docs/seguridad/aviso-de-privacidad.md`](../../docs/seguridad/aviso-de-privacidad.md). Pendiente: que la agencia publique su texto definitivo como versión 2 (`POST /api/v1/avisos-privacidad`).

- **V2-M22.02 · Descargar mis datos (acceso ARCO)** (PR #129, backend#97, contrato 2.14.0): `POST /privacidad/arco/acceso` abre la solicitud (202); el backend arma un JSON con una sección por tabla de la cuenta, lo guarda en `archivo_arco` y avisa con el evento `arco.estado`. La app lista las solicitudes, sigue la pendiente (aviso en vivo y, por si el canal cae, cada 3 s) y entrega el archivo con la hoja de compartir sin dejarlo en el teléfono. Vence a los 7 días; solo lo descarga su cuenta, sin caché. «Privacidad y mis datos» (`/privacidad`) reúne el aviso y la descarga, y el perfil abre ese centro. Diseño, decisiones y límites en [`docs/seguridad/derechos-arco.md`](../../docs/seguridad/derechos-arco.md).

- **V2-M22.03 · Borrar mi cuenta (cancelación ARCO)** (PR #131, backend#99, contrato 2.15.0): `POST /privacidad/arco/cancelacion` `{contrasena}` borra o anonimiza lo que ninguna ley obliga a conservar, desactiva la cuenta y no deja que el CRM la reactive; todo en una transacción. La contraseña equivocada es 400 (no 401, que cerraría la sesión sin explicar) y cuenta como intento: a los 5, 429. En la app, «Eliminar mi cuenta» (en «Privacidad y mis datos») explica qué se borra y qué se conserva, pide la contraseña y un deslizar; al terminar cierra la sesión aunque la persona haya salido de la pantalla. Diseño, decisiones y límites en [`docs/seguridad/derechos-arco.md`](../../docs/seguridad/derechos-arco.md). Pendiente: la revisión legal de lo que se conserva y la demostración en celular.

- **V2-M22.04 · Fijar certificados del servidor** (PR #132): en `pruebas` y `produccion` la app solo confía en cinco raíces de la jerarquía pública de TLS de Azure (`lib/config/pines_tls.dart`) y no en las del teléfono; `desarrollo` (http contra el simulador) no fija. Se fijan **raíces y no el certificado del servidor**, porque Azure renueva el suyo cada pocos meses y cambia de intermedio sin avisar. Una dirección https sin anclas no arranca. La vigilancia semanal (`scripts/verificar-pines-tls.sh`, `.github/workflows/pines-tls.yml`) comprueba que el servidor real siga validando y avisa de vencimientos con 18 meses. Elección, evidencia, plan de rotación y qué hacer si algo se rompe: [`docs/seguridad/fijar-certificados.md`](../../docs/seguridad/fijar-certificados.md). Pendiente: instalar el APK de `pruebas` y entrar (el canario de los pines) antes de etiquetar una versión de `produccion`; fijar también las imágenes (`NetworkImage`).

- **V2-M22.10 · Aviso de privacidad con los proveedores externos** (PR #137, backend#100): la versión 1 decía que los datos solo se compartían con autoridades, pero el mapa, el geocodificador del sistema y el asistente mandan datos a terceros y la información vive en Azure y Neon. La migración `V45` publica la versión 2 (el aviso es inmutable: se publica otra versión), así que **al desplegar todas las cuentas deben leerla y aceptarla otra vez**. Cada afirmación sale del código: OpenStreetMap recibe la IP y la zona porque ningún build define `TILES_URL`; el geocodificador recibe el texto de la dirección o las coordenadas; a Gemini solo llega la pregunta sin lo que parezca correo, teléfono, placas o VIN, el modelo y año y la foto sin EXIF ni GPS, y Google puede usarlo en el nivel gratuito (ADR 0007). `Agencia.avisoPrivacidad` (lo que muestra el perfil v1) y el simulador dicen lo mismo que `V45`; `test/config/agencia_aviso_test.dart` lo vigila. Es un texto técnico, no asesoría legal: la agencia puede publicar el definitivo como versión 3.
- **V2-M22.13 · Caché de la API cifrada** (PR #138): la copia de las últimas lecturas (correo, nombre, VIN, placas, citas) ya no queda en texto plano en `SharedPreferences`. `CifradorAesGcm` (`lib/cache/cifrador_de_cache.dart`) la cifra con AES-256-GCM, una llave aleatoria del Keystore o el Keychain y la clave de la copia como dato asociado, así que una copia alterada o movida a otra clave no se descifra. Si no se puede cifrar, no se guarda nada; una copia inservible se descarta y la lectura falla como sin conexión. Al cerrar sesión se borran las copias de cualquier versión y se olvida la llave; las copias en claro de versiones anteriores se borran al arrancar. Agrega la dependencia `cryptography` (Apache 2.0, Dart puro). Detalle y límites en [`docs/seguridad/cache-cifrada.md`](../../docs/seguridad/cache-cifrada.md).
- **V2-M22.15 · Aviso de conexión no segura** (PR #139): con los certificados fijados, una red con filtros (WiFi público, escuela, trabajo) o un servidor que cambió de autoridad cortan la conexión y cada pantalla decía «sin conexión». `ClienteApi` reconoce el rechazo del certificado (`CERTIFICATE_VERIFY_FAILED`, comprobado con un servidor TLS real) y lo lanza como `ConexionNoSegura`, que **sigue siendo una `SinConexion`**: la caché y las 40 pantallas que ya la atrapan no cambian. Un `EstadoDeConexionSegura` global lo guarda y `AvisoConexionNoSegura` (en el `builder` de la app, como el aviso de equipo comprometido) explica qué pasó y qué hacer, en español e inglés; se quita con la siguiente respuesta del servidor, aunque sea de error. Otros fallos de TLS o de red no lo activan. Las imágenes de red quedan con la tienda del sistema: riesgo aceptado, ver [`fijar-certificados.md`](../../docs/seguridad/fijar-certificados.md).
- **V2-M22.08 · Revisión MASVS L1** (primera pasada, PR #133): [`docs/seguridad/revision-masvs-l1.md`](../../docs/seguridad/revision-masvs-l1.md) recorre los 24 controles de MASVS 2.0 con estado y evidencia: 8 cumplen, 9 cumplen en parte, 7 no aplican, ninguna brecha abierta. Es una revisión estática con las pruebas como evidencia, no una prueba de penetración. Encontró una brecha real, corregida en el mismo PR (Android dejaba encendidas las copias de seguridad; ahora una prueba vigila el manifiesto: copias, componentes accesibles, permisos y WebViews) y siete hallazgos para seguimiento (M22.10 a M22.16, `Borrador`); el más importante es que el aviso de privacidad no menciona a los proveedores de mapas. Pendiente: repetirla al cerrar H6 y que la lea el revisor de M22; comprobar en un teléfono lo que quedó en 🟡.

- **V2-M22.07 · Logs sin datos personales** (PR #126): `lib/nucleo/registro/` con `Registro.depurar`, único camino para escribir en el registro, que pasa el texto por `quitarDatosPersonales` (correo, teléfono, VIN y token). La guarda `test/arquitectura/registro_sin_datos_personales_test.dart` falla si algo en `lib/` escribe en la consola sin `Registro` o le interpola un dato personal. Los dos `debugPrint` que había (notificaciones) pasaron a `Registro`. Diseño, límites y cómo usarlo en [`docs/seguridad/registro-sin-datos-personales.md`](../../docs/seguridad/registro-sin-datos-personales.md). Pendiente: que el manejador de V2-M23.01 use el mismo redactor.
