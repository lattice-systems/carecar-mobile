# Revisión MASVS L1 (V2-M22.08) — primera pasada

Historia [V2-M22.08](../../plan/modulos/M22-seguridad-y-privacidad.md). Estándar: [OWASP MASVS 2.0](https://mas.owasp.org/MASVS/) (los documentos anteriores citan los identificadores de MASVS 1, `MSTG-…`; MASVS 2.0 agrupa los mismos requisitos en 24 controles). Perfil: **L1**. `NETWORK-2` (fijar certificados) es del perfil L2 y las `RESILIENCE` son del perfil R: se anotan como refuerzo.

**Estado: primera pasada completa.** Revisa a la app tal como está hoy; la historia depende de H6, así que se **repite al cerrar H6 y en H7**. Quien la hizo es quien escribió buena parte del código que revisa: conviene que la lea Ricardo (revisor de M22) antes de darla por buena.

## Cómo se hizo (y qué no es)

- **Revisión estática** del código de la app, del manifiesto de Android, de los `Info.plist` de iOS, de `pubspec.yaml` y de los flujos de CI, más las pruebas existentes como evidencia. Lo que el backend decide (autorización, bloqueo por intentos) se cita con sus pruebas, pero no se revisó el backend en sí.
- **No es una prueba de penetración** ni análisis dinámico en un teléfono: no se instrumentó la app, no se interceptó tráfico y no se inspeccionó el almacenamiento de un equipo real. Los controles que piden eso están marcados.
- Donde se pudo, la evidencia es **ejecutable**: una prueba que falla si el control se pierde (`test/arquitectura/superficie_nativa_test.dart`, `registro_sin_datos_personales_test.dart`, `test/config/flavors_nativos_test.dart`, `test/api/cliente_http_fijado_test.dart`).

Leyenda: ✅ cumple · 🟡 cumple en parte o con un pendiente · ⬜ no aplica o no se pretende · ❌ brecha abierta.

## Resumen

| ✅ cumple | 🟡 en parte | ⬜ no aplica | ❌ brecha |
| --- | --- | --- | --- |
| 8 | 9 | 7 | 0 |

La revisión encontró **una brecha real, corregida en el mismo PR** (copias de seguridad de Android, F1) y **siete hallazgos para seguimiento** (F2–F8, más abajo). Ninguno es crítico; el más importante para el negocio era F3 (el aviso de privacidad no mencionaba a los proveedores de mapas) y se cerró con la versión 2 del aviso (V2-M22.10).

## Controles

### STORAGE · Almacenamiento

| Control | Estado | Evidencia | Pendiente |
| --- | --- | --- | --- |
| **STORAGE-1** Guarda de forma segura los datos sensibles | 🟡 | Los dos tokens de sesión solo están en `flutter_secure_storage` (Keychain / Keystore) detrás del puerto `AlmacenSeguro` y se leen en cada petición (`lib/sesion/almacen_seguro.dart`, `almacen_sesion_test.dart`). En `SharedPreferences` solo hay el idioma y la copia de las últimas lecturas de la API (`lib/cache/`), dentro del contenedor de la app y **cifrada con AES-256-GCM** con una llave del Keystore o el Keychain (M22.13, [detalle](cache-cifrada.md)); se borra, con su llave, al cerrar sesión y no se guarda en equipos con root o jailbreak (M22.05). Los widgets de inicio se vacían al cerrar sesión (`sincronizador_de_widgets_test.dart`). | El Keychain de iOS usa la accesibilidad por omisión, que viaja en las copias cifradas, y ahí vive también la llave de la caché: F2. |
| **STORAGE-2** Evita fugas de datos sensibles | 🟡 | Registros sin datos personales (M22.07, `registro_sin_datos_personales_test.dart`). Selector de apps cubierto y capturas bloqueadas en pago y documentos (M22.06, [`ocultar-en-selector.md`](ocultar-en-selector.md)). **Copias de seguridad de Android apagadas** (`allowBackup="false"`, esta historia, `superficie_nativa_test.dart`). Contraseñas con `ocultarTexto`: el motor de Flutter las marca como campo de contraseña (sin sugerencias en Android, entrada segura en iOS; comportamiento del motor, sin prueba propia). `pubspec.yaml` no trae SDK de analítica, publicidad ni reportes de fallos. | Lo único que sale a terceros son las teselas del mapa (OpenStreetMap) y el geocodificador del sistema: F3. En iOS, las copias cifradas incluyen la caché: F5. |

### CRYPTO · Criptografía

| Control | Estado | Evidencia | Pendiente |
| --- | --- | --- | --- |
| **CRYPTO-1** Usa criptografía actual y bien aplicada | ⬜ | La app no implementa criptografía: una búsqueda en `lib/` no encuentra `Random`, hashes ni cifrados propios. El cifrado en reposo es del Keychain/Keystore y el de tránsito es TLS. | — |
| **CRYPTO-2** Administra las llaves como se debe | ⬜ | No maneja llaves: las del almacén seguro las administra la plataforma. | — |

### AUTH · Autenticación y autorización

| Control | Estado | Evidencia | Pendiente |
| --- | --- | --- | --- |
| **AUTH-1** Protocolos seguros de autenticación y autorización | ✅ | Usuario y contraseña (8–72, con letra y número); token de acceso con vencimiento (`expiresIn`, lo fija el servidor) y de refresco **de un solo uso que rota** (RIC-2); cerrar sesión **revoca** el refresco en el servidor (RIC-4); cinco intentos fallidos bloquean 15 minutos (RIC-5); cuenta desactivada → 403 y la app cierra la sesión (RIC-3). La autorización la decide el servidor: un recurso ajeno responde 404. Pruebas: `controlador_sesion_test.dart`, `login_contra_simulada_test.dart`, `guardia_sesion_test.dart` y, en el backend, `AccesoAppIntegrationTest`, `CancelacionIntegrationTest`. | — |
| **AUTH-2** Autenticación local segura | ⬜ | La app no ofrece autenticación local (biometría o PIN propio): la sesión se sostiene con el token del almacén seguro. | Una puerta biométrica para abrir la app sería un refuerzo; no es de L1. |
| **AUTH-3** Operaciones sensibles con autenticación adicional | ✅ | Eliminar la cuenta pide la **contraseña y deslizar** (M22.03); cambiar la contraseña pide la actual. | — |

### NETWORK · Comunicación

| Control | Estado | Evidencia | Pendiente |
| --- | --- | --- | --- |
| **NETWORK-1** Todo el tráfico va por canal seguro | ✅ | `https` obligatorio fuera de desarrollo: `ApiConfig` rechaza `http` en `pruebas` y `produccion`; `usesCleartextTraffic` y ATS dependen del flavor (`flavors_nativos_test.dart`, `api_config_test.dart`); la URL firmada de los manuales solo se baja por `https` (M22.09). | — |
| **NETWORK-2** *(L2)* Fija la identidad de los servidores propios | 🟡 | [V2-M22.04](fijar-certificados.md) (PR #132): en `pruebas` y `produccion` solo se confía en cinco raíces de Azure; con pruebas de TLS real y vigilancia semanal. | Instalar el APK de `pruebas` en un teléfono y entrar. No cubre las imágenes ni los plugins; un fallo de pines se ve como «sin conexión»: F7. |

### PLATFORM · Interacción con la plataforma

| Control | Estado | Evidencia | Pendiente |
| --- | --- | --- | --- |
| **PLATFORM-1** Usa IPC de forma segura | 🟡 | Android: **solo `MainActivity` es accesible desde otras apps**; widgets, receptores y servicios tienen `exported="false"` y todos lo declaran explícito (`superficie_nativa_test.dart`). Los enlaces `carecar://<ruta>` y `https://…/app/<ruta>` llegan a cualquier ruta, pero toda ruta privada pasa por la guardia de sesión (`guardia_sesion_test.dart`, `enlaces_test.dart`); el código de restablecer contraseña que viaja en un enlace solo adelanta el paso: la contraseña nueva la escribe la persona y el servidor valida el código. | No se revisó una por una que cada ruta exija una interacción explícita antes de hacer algo (las irreversibles sí: deslizar y contraseña); revisar al sumar rutas. Los App Links apuntan al dominio de ejemplo: F4. |
| **PLATFORM-2** Usa WebViews de forma segura | ✅ | La app no usa WebViews; una prueba falla si se agrega alguno (`superficie_nativa_test.dart`). | — |
| **PLATFORM-3** Usa la interfaz de forma segura | 🟡 | Capturas bloqueadas y pantalla cubierta en el selector (M22.06); contraseñas ocultas; sin datos sensibles en la interfaz más allá de los del propio cliente. | Android 7–11 no tiene protección propia contra superposiciones (tapjacking); Android 12+ ya las limita. Es del perfil L2. |

### CODE · Calidad del código y compilación

| Control | Estado | Evidencia | Pendiente |
| --- | --- | --- | --- |
| **CODE-1** Exige una versión de plataforma al día | 🟡 | `targetSdk` 35 (Android 15); iOS 15.0. | `minSdk` 24 (Android 7.0) es **decisión del PO**: llega sin parches de seguridad desde hace años. Riesgo aceptado y dicho aquí. |
| **CODE-2** Puede forzar actualizaciones | ⬜ | No hay mecanismo. La distribución es por APK y sideload, no por tiendas. | Si la distribución cambia, un aviso de «versión mínima» desde el backend. |
| **CODE-3** Solo usa componentes sin vulnerabilidades conocidas | 🟡 | `dependency-review` bloquea los PR que agregan o cambian dependencias con vulnerabilidades altas o críticas conocidas (`dependency-review.yml`); `flutter analyze` en CI. | No hay escaneo **periódico** de `pubspec.lock` ni de las dependencias de Gradle y Pods: F6. |
| **CODE-4** Valida y sanea lo que no es de confianza | ✅ | Lectura estricta de las respuestas (`leerTexto` y `leerEntero` en `lib/api/modelos/comun.dart`; lo que no cuadra sale como `RespuestaInvalida`), `ApiConfig` rechaza direcciones inválidas, `EnlacesApp.aRutaInterna` traduce los enlaces a rutas internas conocidas (`enlaces_test.dart`) y el servidor valida todo. | — |

### RESILIENCE · Resistencia a la ingeniería inversa *(perfil R)*

| Control | Estado | Evidencia | Pendiente |
| --- | --- | --- | --- |
| **RESILIENCE-1** Valida la integridad de la plataforma | ✅ | Aviso (no bloqueo) en equipos con root o jailbreak y sin caché local en ellos (M22.05: `detector_integridad.dart`, `politica_datos_locales.dart`). | — |
| **RESILIENCE-2** Antimanipulación | ⬜ | No se pretende. | — |
| **RESILIENCE-3** Antianálisis estático | ⬜ | No se pretende: los builds de release no usan `--obfuscate` ni `--split-debug-info`. | F8, junto con los símbolos de los reportes de fallos (M23.01). |
| **RESILIENCE-4** Antianálisis dinámico | ⬜ | No se pretende: sin detección de depuradores ni de instrumentación. | — |

### PRIVACY · Privacidad

| Control | Estado | Evidencia | Pendiente |
| --- | --- | --- | --- |
| **PRIVACY-1** Minimiza el acceso a datos y recursos sensibles | ✅ | Permisos de Android revisados, cada uno con su motivo, y una prueba que falla si aparece uno nuevo: red, notificaciones, reinicio (recordatorios) y ubicación precisa y aproximada (ayuda en carretera y recolección). La cámara y las fotos van por el selector del sistema, sin el permiso `CAMERA`; en iOS cada uso tiene su descripción. | — |
| **PRIVACY-2** Evita identificar a la persona | 🟡 | Sin SDK de analítica ni publicidad; registros redactados (M22.07). | Las teselas de OpenStreetMap reciben la IP y la zona que se mira, y el geocodificador del sistema recibe direcciones y coordenadas. Desde la versión 2 del aviso (V2-M22.10) se le dice a la persona (F3). |
| **PRIVACY-3** Es transparente sobre qué datos usa y para qué | 🟡 | Aviso de privacidad versionado, con aceptación obligatoria al entrar y al cambiar de versión (M22.01). | Desde la versión 2 (V2-M22.10) el aviso nombra a quién recibe datos: Azure, Neon, OpenStreetMap, el geocodificador del teléfono y Gemini (F3). Falta la revisión legal del texto y que la agencia publique el definitivo. |
| **PRIVACY-4** Da control sobre los datos | ✅ | Descargar mis datos (M22.02) y eliminar mi cuenta (M22.03). La rectificación y la oposición se atienden en la agencia. | — |

## Hallazgos y seguimiento

| # | Hallazgo | Control | Qué se hizo o se propone |
| --- | --- | --- | --- |
| **F1** | Android dejaba encendidas las copias de seguridad: la caché con VIN, placas y citas, y los datos cifrados de la sesión, viajaban a la copia de Google y salían por `adb`. | STORAGE-2 | **Corregido aquí**: `allowBackup="false"` y una prueba que vigila el manifiesto. |
| **F2** | El Keychain de iOS guarda los tokens con la accesibilidad por omisión (`unlocked`), que se incluye en las copias cifradas y puede restaurarse en otro equipo. | STORAGE-1 | V2-M22.12: `first_unlock_this_device`, migrando sin cerrar la sesión de nadie. |
| **F3** | Las teselas del mapa (OpenStreetMap) y el geocodificador del sistema reciben datos de ubicación; el aviso de privacidad dice que solo se comparte con autoridades. | PRIVACY-2/3, STORAGE-2 | **Cerrado** con la versión 2 del aviso (V2-M22.10, backend#100): nombra a Azure y Neon, OpenStreetMap, el geocodificador del teléfono y Gemini, y todas las cuentas deben aceptarla. Falta la revisión legal del texto. |
| **F4** | Los App Links (`autoVerify`) apuntan a `carecar.example.com`, que no sirve `assetlinks.json`. | PLATFORM-1 | V2-M22.14: dominio real o quitar el `autoVerify`. |
| **F5** | La caché de la API guarda datos personales sin cifrar, y en iOS entra en las copias cifradas. | STORAGE-1 | **Cerrado** con V2-M22.13: las copias se guardan cifradas (AES-256-GCM, llave en el Keystore o el Keychain) y se descartan si no se pueden descifrar. [Detalle](cache-cifrada.md). |
| **F6** | No hay escaneo periódico de dependencias. | CODE-3 | V2-M22.11: un escaneo semanal de `pubspec.lock`, Gradle y Pods. |
| **F7** | Los pines de certificados no cubren las imágenes y un fallo se ve como «sin conexión». | NETWORK-2 | V2-M22.15. |
| **F8** | Los builds de release no se ofuscan. | RESILIENCE-3 | V2-M22.16, junto con M23.01. |

Los números de historia son propuestas (estado `Borrador` en el [tablero](../../plan/tablero.md)): las prioriza el equipo.

## Qué vigilan las pruebas

| Prueba | Controles |
| --- | --- |
| `test/arquitectura/superficie_nativa_test.dart` | STORAGE-2 (copias), PLATFORM-1 (componentes accesibles), PLATFORM-2 (sin WebViews), PRIVACY-1 (permisos) |
| `test/arquitectura/registro_sin_datos_personales_test.dart` | STORAGE-2, PRIVACY-2 (registros) |
| `test/config/flavors_nativos_test.dart`, `test/api/api_config_test.dart` | NETWORK-1 |
| `test/api/cliente_http_fijado_test.dart`, `test/config/pines_tls_test.dart` | NETWORK-2 |
| `test/nucleo/navegacion/guardia_sesion_test.dart`, `enlaces_test.dart` | PLATFORM-1, CODE-4 |
| `test/sesion/` | AUTH-1 |

## Cómo repetirla

1. Releer cada fila con el código y los flujos de CI de ese momento; actualizar estado, evidencia y pendiente.
2. Si una prueba de la tabla anterior falla, **no se corrige el texto de la prueba**: se decide si el cambio es correcto y entonces se actualiza esta revisión.
3. Antes de cerrar H7: instalar el APK en un teléfono y comprobar a mano lo que aquí marca 🟡 por falta de demostración (copias, Keychain, pines, tráfico del mapa).
4. Cada SDK o permiso nuevo se revisa contra `STORAGE-2`, `PRIVACY-1` y `PRIVACY-3` **antes** de integrarse.
