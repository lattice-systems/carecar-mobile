# T01 · Arquitectura v2 de la app

| Campo | Valor |
| --- | --- |
| Hito | H1 |
| Dueño | Daniel · Jael (V2-T01.08) |
| Revisa | Jael |
| Estado | Listo para historias |

Descripción del objetivo: [`../arquitectura-v2.md`](../arquitectura-v2.md). Decisiones: `docs/decisiones/0001`–`0005`.

## Historias

| ID | Historia | Criterios de aceptación | B | Depende de |
| --- | --- | --- | --- | --- |
| V2-T01.01 | Como equipo queremos aceptar o reemplazar las decisiones 0001–0005 | Cada ADR pasa a `Aceptada` o se reemplaza, con aprobación de SM y PO en el PR | | — |
| V2-T01.02 | Como equipo queremos el esqueleto `lib/nucleo` + `lib/modulos` | Carpetas, inyección de dependencias, `ApiCliente` del núcleo reutilizando el cliente v1, una pantalla de ejemplo con pruebas · la app v1 sigue funcionando | | V2-T01.01 |
| V2-T01.03 | Como equipo queremos navegación declarativa con deep links | Rutas tipadas · `carecar://` y enlaces universales https · redirección por sesión (login, cambio obligatorio) · prueba por ruta | | V2-T01.02 |
| V2-T01.04 | Como equipo queremos flavors `desarrollo`, `pruebas` y `produccion` | Nombre, ícono, `API_BASE_URL` y permisos de red por flavor | | V2-T01.02 |
| V2-T01.05 | Como equipo queremos migrar módulo por módulo sin romper v1 | Guía en `arquitectura-v2.md` · interruptor por módulo (v1/v2) hasta cerrar H2 | | V2-T01.03 |
| V2-T01.06 | Como equipo queremos reglas de dependencia entre módulos verificadas | Prueba/lint que falle si `modulos/a` importa internals de `modulos/b` | | V2-T01.02 |
| V2-T01.07 | Como equipo queremos retirar el código v1 al terminar H2 | `lib/pantallas`, `lib/widgets`, `lib/tema` eliminados · sin referencias | | H2 |
| V2-T01.08 | Como equipo queremos un núcleo de datos común para que cada módulo resuelva sus cinco estados igual y pruebe sin red | Errores de API tipados desde el `Problema` del contrato y los fallos de red: sin conexión, sesión vencida, no encontrado, conflicto con su código (p. ej. `FRANJA_SIN_CUPO`), validación y servidor · base de repositorio que convierte cada llamada en datos o en ese error · vista que pinta desde un `AsyncValue` los cinco estados (cargando con `Esqueleto`, datos, vacío con `EstadoVacio`, error con reintento y sin conexión con `EstadoError`) · fakes reutilizables en `test/ayudas/` (repositorio en memoria con latencia y fallo a pedido) · una prueba por estado y por tipo de error · guía de uso en `lib/modulos/README.md` · sin tocar las carpetas de los módulos | | V2-T01.02 |

## Avance de V2-T01.02

**Qué quedó**

- Dependencia `flutter_riverpod ^3.5.0` (sin generación de código; `go_router` es V2-T01.03 y `drift` V2-M21.01). `ProviderScope` en `main()`.
- `lib/nucleo/api/`: `ApiCliente` (typedef del `ClienteApi` v1, sin reescribirlo), `apiClienteProvider` y `carecarApiProvider`. Fallan con un mensaje claro si no están inyectados.
- `lib/nucleo/sesion/`: `controladorSesionProvider` (el `ControladorSesion` v1) y `estadoSesionProvider` (puente del `ChangeNotifier` a Riverpod).
- `main.dart` arma el cliente, la API y la sesión como siempre (la v1 no cambió) y los inyecta con `overrides` en un `ProviderScope` por fuera del `MaterialApp`.
- `lib/modulos/README.md` (convención `datos/ dominio/ presentacion/` + contrato `<modulo>.dart`) y módulo `lib/modulos/ejemplo/` con pantalla de cinco estados, repositorio fake y pruebas de dominio, widget y proveedores. Sin ruta; se borra en V2-T01.07.

**Cómo empiezan los demás**

1. Lean `lib/modulos/README.md` y copien `lib/modulos/ejemplo/` con el nombre de su módulo.
2. Reciban la API con `ref.watch(carecarApiProvider)` en su repositorio; nunca un `http.Client` propio.
3. En pruebas, `ProviderScope(overrides: [carecarApiProvider.overrideWithValue(ApiFalsa())])` (`test/ayudas/api_falsa.dart`).
4. Ojo: Riverpod 3 reintenta solos los proveedores con error; apaga con `retry: (_, _) => null` si la pantalla tiene botón de reintento.
5. Navegación (rutas, deep links) llega con V2-T01.03; hasta entonces no registren rutas nuevas, usen su pantalla desde pruebas.

**Pendiente / fuera de alcance:** mover el código de `lib/api` y `lib/sesion` al núcleo (V2-T01.05, módulo por módulo); regla de dependencias automática (hecha en V2-T01.06).

## Avance de V2-T01.03

**Qué quedó**

- Dependencia `go_router ^18.1.4`.
- `lib/nucleo/navegacion/`: `enrutadorProvider` (el `GoRouter` en Riverpod), `Rutas`/`NombresRuta` (constantes y localizaciones tipadas), `guardia_sesion.dart` (`redirigirPorSesion`, pura), `enlaces.dart` (`EnlacesApp`), `rutas_del_nucleo.dart` y `registro_de_rutas.dart`.
- `main.dart` usa `MaterialApp.router`; `FlujoCareCar` desapareció. Las pantallas v1 no se reescribieron: se montan como rutas. La cortina de arranque sigue tapando la app mientras se restaura la sesión. Se quitó el `ProviderScope` exterior de `main()` (un alcance anidado no ve los proveedores del enrutador).
- Rutas del núcleo: `/` (inicio, privada), `/acceso`, `/recuperar?correo=`, `/restablecer?token=&correo=` (públicas), `/cambiar-contrasena` (solo con contraseña temporal). Módulo de ejemplo: `/ejemplo/avisos`, solo en `kDebugMode`.
- Guardia: sin sesión, ruta privada va a `/acceso?desde=<ruta>` y vuelve a ella tras entrar; con `debe_cambiar_contrasena` todo va a `/cambiar-contrasena` hasta cambiarla (la bandera `contrasenaCambiadaProvider` reemplaza el `_yaCambio` de v1); con sesión, `/acceso` lleva a `desde` o al inicio. `desde` solo acepta rutas internas. Una ruta inexistente cae en el inicio.
- Enlaces: `carecar://restablecer?token=123456&correo=a@b.mx` y `https://<host>/app/restablecer?...` llegan a `/restablecer`, que abre la pantalla v1 de recuperación en el paso del código (con `codigoInicial`). El flujo completo con enlace de un solo uso es V2-M01.04.
- Android: `intent-filter` `carecar://`, App Link `https` con `autoVerify` y `flutter_deeplinking_enabled`. iOS: `CFBundleURLTypes` y `FlutterDeepLinkingEnabled`.
- Pruebas: `test/nucleo/navegacion/` (una por ruta, guardia, enlaces, deep link entregado como lo hace el sistema operativo). `test/ayudas/app_enrutada.dart` monta la app con el enrutador real y fakes.

**Cómo registra rutas cada persona** (detalle en `lib/modulos/README.md`)

1. En su módulo: `presentacion/rutas_<modulo>.dart` con la constante del camino y `final rutas<Modulo> = <RouteBase>[...]`, exportada desde `<modulo>.dart`.
2. Una línea en `lib/nucleo/navegacion/registro_de_rutas.dart`: `...rutas<Modulo>,`. Nada más en el núcleo.
3. Son privadas por defecto (sesión y cambio de contraseña ya se resuelven); ya son alcanzables por `carecar://<ruta>` y `https://<host>/app/<ruta>`. Parámetros por camino o consulta, no `extra`.

**Falta del lado del dominio y de las cuentas (no es código de la app)**

- Host: hoy `carecar.example.com` (marcador). Cambiarlo en `EnlacesApp.hostEnlacesUniversales` y en el `android:host` del `AndroidManifest.xml`.
- Android App Links: publicar `https://<host>/.well-known/assetlinks.json` con el `package_name` `com.carecar.carecar_mobile` y la huella SHA-256 del certificado de firma (debug, release y la de Play App Signing).
- iOS enlaces universales: publicar `https://<host>/.well-known/apple-app-site-association` (sin extensión, `application/json`) con el `appID` `<TeamID>.com.carecar.carecarMobile` y `paths: ["/app/*"]`; y agregar la capacidad Associated Domains (`applinks:<host>`) al target Runner en Xcode (requiere la cuenta de Apple Developer). Hasta entonces el esquema `carecar://` funciona y los https abren el navegador.
- Los correos de V2-M01.04 deben usar `https://<host>/app/restablecer?token=...`.

**Pendiente / fuera de alcance:** pestañas con `StatefulShellRoute` (cuando exista la barra de navegación de la app v2); migrar `PantallaInicio`, que sigue con su `Navigator` interno, módulo por módulo (V2-T01.05); pruebas de enlaces en dispositivo real (necesitan el dominio); tema v2 global.

## Avance de V2-T01.06

**Qué quedó**

- `test/arquitectura/verificador_dependencias.dart` (Dart puro, sin dependencias nuevas): lee fuentes, resuelve imports/exports/parts relativos y `package:carecar_mobile/` y devuelve violaciones con archivo, línea, import, regla y qué hacer.
- `test/arquitectura/verificador_dependencias_test.dart`: casos en memoria por regla (relativo, `package:`, `export`/`part`/condicionales, comentarios, módulo `widgets` vs `lib/widgets`, excepciones).
- `test/arquitectura/reglas_de_dependencia_test.dart`: recorre el `lib/` real; corre con `flutter test` y por tanto en el CI.
- Reglas R1 (internos de otro módulo), R2 (núcleo no conoce módulos) y R3 (v2 no importa interfaz v1) documentadas en `plan/arquitectura-v2.md` y `lib/modulos/README.md`.

**Hallazgos en el árbol actual**

- `vehiculos` importaba `citas/presentacion/rutas_citas.dart`: corregido a `citas/citas.dart` (ya exportaba las constantes).
- `nucleo/navegacion/rutas_del_nucleo.dart` monta pantallas v1 (`lib/pantallas`): excepción explícita `excepcionesV1`, se retira con T01.05/T01.07.

**Pendiente / fuera de alcance:** verificar que `dominio/` no importe Flutter ni `http` (regla 2 de la arquitectura; candidata a historia nueva) y que ningún módulo cree `http.Client` (regla 3).

## Avance de V2-T01.05

**Qué quedó**

- `lib/nucleo/migracion/`: `ModuloMigrable` (asistencia, catalogo, citas, vehiculos), `VersionModulo`, `InterruptorModulos` y `interruptorModulosProvider`. Valor por defecto en código: todo en v1. Se sobrescribe con `--dart-define=MODULOS_V2=<lista|todos>` y `MODULOS_V1=<lista|todos>` (v1 gana si hay choque; un nombre desconocido lanza `ArgumentError`). Sin servidor ni secretos.
- `registro_de_rutas.dart`: `rutasDeLaApp(interruptor)` solo registra las rutas v2 de un módulo si está en v2; `destinosDeMenuV2` dice a qué ruta lleva cada tarjeta del menú v1.
- `PantallaInicio` (v1) recibe `abrirEnV2`: con el módulo en v2 la tarjeta va a la ruta v2; sin él, abre la pantalla v1 igual que antes. El resto de la v1 no cambió.
- Pruebas: `test/nucleo/migracion/` (valores por defecto, `--dart-define`, rutas por módulo en v1 y v2, tarjetas del menú). `AppEnrutadaDePrueba` acepta `interruptor` (por omisión todo en v2; las pruebas de la v1 pasan `InterruptorModulos.porDefecto`).
- Guía paso a paso (carpeta, interruptor, pruebas, encender y retirar en V2-T01.07) en [`../arquitectura-v2.md`](../arquitectura-v2.md#migrar-un-módulo-con-el-interruptor-v1v2-v2-t0105). README con el comando.

**Decisiones**

- Con todo en v1 las rutas v2 **no existen** (no solo están ocultas): así una pantalla incompleta no se alcanza ni por `carecar://`. Consecuencia: los accesos rápidos y el widget de cita (M25) caen en el inicio mientras su módulo siga en v1.
- El valor por defecto es todo v1 hasta que cada módulo esté completo. Cuando V2-T01.04 (flavors) llegue a `main`, `desarrollo` y `pruebas` pueden pasar `MODULOS_V2` por flavor; no se acopló a `kDebugMode` para no esconder el comportamiento en el modo de compilación.
- La galería y el ejemplo siguen con `kDebugMode`, fuera del interruptor (no tienen v1).

**Pendiente / fuera de alcance:** mover físicamente `lib/api` y `lib/sesion` al núcleo (se hace con el primer módulo que lo necesite o en V2-T01.07); cablear `MODULOS_V2` por flavor (V2-T01.04); retirar todo en V2-T01.07.
