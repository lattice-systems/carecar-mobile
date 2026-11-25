# M22 · Seguridad y privacidad

| Campo | Valor |
| --- | --- |
| Hito | H2 (base) → H7 (MASVS) |
| Dueño | Daniel |
| Revisa | Ricardo |
| Ficha técnica | ✅ Sección 20. Seguridad y privacidad |
| Estado | En curso: M22.01 implementada (falta demostrarla en celular); M22.05, M22.06 y M22.09 hechas |

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
