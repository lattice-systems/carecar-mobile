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

## Avance de V2-T01.04

**Qué quedó**

- `lib/config/flavor.dart`: `enum Flavor { desarrollo, pruebas, produccion }` con nombre de app, permiso de http en claro y dirección por omisión. `Flavor.actual` lo fija `arrancar(flavor)` en `main.dart`; sin flavor vale `produccion` (el más restrictivo).
- Una entrada por ambiente: `lib/main_desarrollo.dart`, `main_pruebas.dart`, `main_produccion.dart`. `lib/main.dart` sin flavor equivale a `produccion`.
- `ApiConfig.resolver`: `--dart-define=API_BASE_URL` sobrescribe la dirección del flavor; `pruebas` y `produccion` rechazan `http://` aunque se lo pasen. Se acabó el error de arranque por falta de `API_BASE_URL`.

| Flavor | Nombre | applicationId / bundle id | API por omisión | HTTP en claro |
| --- | --- | --- | --- | --- |
| `desarrollo` | CareCar Dev | `com.carecar.carecar_mobile.dev` / `com.carecar.carecarMobile.dev` | `http://10.0.2.2:3000/api/v1/app` (Android) · `http://localhost:3000/...` | sí |
| `pruebas` | CareCar Pruebas | `...carecar_mobile.pruebas` / `...carecarMobile.pruebas` | backend en Azure | no |
| `produccion` | CareCar | `com.carecar.carecar_mobile` / `com.carecar.carecarMobile` | backend en Azure | no |

- **Android:** `productFlavors` en `android/app/build.gradle.kts` (nombre por `resValue app_name`, sufijo de `applicationId`, marcador `usesCleartextTraffic` que usa el manifiesto) e íconos por flavor en `android/app/src/<flavor>/res`.
- **iOS:** configuraciones `Debug|Release|Profile-<flavor>` en `Runner.xcodeproj`, un `ios/Flutter/<flavor>.xcconfig` (nombre, bundle id, ícono, plist) y un scheme compartido por flavor. ATS abierto solo en `ios/Runner/Info-desarrollo.plist` (copia de `Info.plist` más `NSAppTransportSecurity`); una prueba vigila que no se desfasen.
- **Íconos:** `tool/generar_iconos_flavor.py` pone una banda de color con etiqueta (DEV naranja, PRUEBAS azul) sobre el ícono de producción, sin arte nuevo.
- **CI:** `ci.yml` compila los tres flavors en Android y `desarrollo` y `produccion` en iOS; el IPA y el release usan `produccion`.
- Pruebas: `test/config/` (flavor, resolución de dirección, coherencia de los archivos nativos con `Flavor`).

**Decisiones**

- `pruebas` apunta al mismo backend de Azure que `produccion` porque no existe un ambiente de pruebas separado; cuando exista, solo cambia `Flavor.pruebas` (o se pasa `API_BASE_URL`).
- iOS se configuró sin Mac: la validación es el job `Build iOS (sin firma)` de CI, hoy en pausa (desde 2026-11-25 no corre salvo que la variable `MACOS_ACTIVO` valga `true`; ver [`docs/pausa-de-macos.md`](../../docs/pausa-de-macos.md)).
- Pendiente de otras historias: la galería de diseño (V2-T02.06) debe condicionarse a `Flavor.actual == Flavor.desarrollo` en vez de `kDebugMode`; V2-M22.09 (HTTPS fuera de local) completó el bloqueo: nativo, `ApiConfig`, manuales, teselas y CI.

## Avance de V2-T01.08

**Qué quedó**

- `lib/nucleo/datos/fallo.dart`: `Fallo` es la sellada `ExcepcionApi` renombrada (`typedef`, mismo patrón que `ApiCliente`), que ya cubre los seis casos que pide la historia. Encima, la extensión `CaraDelFallo` con `esSinConexion`, `sesionTerminada`, `esReintentable`, `codigo` (**nunca nulo**: `CodigoProblema.desconocido` si no vino, que es la regla RIC-15) y `status`. `falloDe(Object)` tipa cualquier cosa lanzada; una `ExcepcionApi` pasa idéntica, sin envolverse.
- `lib/nucleo/datos/repositorio_base.dart`: `mixin RepositorioBase` con `pedir<T>()`. De un repositorio sale un dato o un `Fallo`. Conserva la pila del error original con `Error.throwWithStackTrace`.
- `lib/nucleo/datos/vista_asincrona.dart`: `VistaAsincrona<T>` pinta los cinco estados desde un `AsyncValue` con `Esqueleto`, `EstadoVacio` y `EstadoError`, eligiendo sola la `CausaError`. Absorbe el ternario `error is SinConexion ? … : …` que estaba copiado en cada pantalla de `citas`, `catalogo` y `vehiculos`.
- `lib/nucleo/datos/reintento.dart`: `reintentoDelNucleo`, instalada en el `ProviderScope` de `main.dart`.
- `test/ayudas/repositorio_falso.dart` y `test/ayudas/fallos_de_prueba.dart`: repositorio en memoria con `latencia`, `falla`, `fallarUnaVez`, `reventarUnaVez` y contador de `llamadas`, y un constructor de `Fallo` por cada caso del contrato.
- **75 pruebas**: los cinco estados, los ocho tipos de error de punta a punta hasta lo que el usuario lee, el no-parpadeo al recargar, la pila preservada y tres de que no se filtra detalle técnico. `test/nucleo/datos/nucleo_de_datos_test.dart` es la que un módulo copia para su pantalla.
- Guía de uso en [`lib/modulos/README.md`](../../lib/modulos/README.md#el-núcleo-de-datos) y carpeta `datos/` agregada al árbol de [`../arquitectura-v2.md`](../arquitectura-v2.md).

**Hallazgos en el árbol actual**

- **La historia llega después de que los módulos ya resolvieron esto cinco veces.** `citas`, `catalogo`, `vehiculos` y `asistente` tienen repositorios, fakes y fallos tipados propios, y cada pantalla pinta sus estados a mano. El criterio «sin tocar las carpetas de los módulos» se respetó, así que **el núcleo queda construido y sin adoptar**: hace falta una historia de migración, o que cada dueño lo adopte al tocar su módulo. Adoptarlo es `with RepositorioBase` y envolver el cuerpo; no cambia firmas ni llamadores.
- **Riverpod 3 reintenta solo cualquier proveedor que falle** (hasta 10 veces, espera que dobla de 200 ms a 6.4 s; `ProviderContainer.defaultRetry` solo se salta los `Error`). El equipo ya lo sabía y lo documentó en `lib/modulos/README.md`, con `retry: (_, _) => null` por proveedor. Al revisar el árbol, **`vehiculoProvider` de `vehiculos` es el único que se quedó sin él**: hoy un 404 de un vehículo ajeno se pide once veces. Con la política en el `ProviderScope` queda cubierto sin tocar esa carpeta.
- `lib/api/excepciones.dart` (código v1): la clase `SinParametrosDeValuacion` quedó insertada **dentro del comentario de documentación de `DemasiadosIntentos`**, así que `DemasiadosIntentos` está sin documentar y la otra arrastra un párrafo sobre el 429 que no le toca. Solo cosmético; no se tocó por no mezclarlo con esta historia.

**Decisiones**

- **`Fallo` reutiliza `ExcepcionApi` en vez de ser una jerarquía nueva.** Las reglas de dependencia lo permiten explícitamente (`lib/api` y `lib/sesion` siguen autorizadas a través del núcleo hasta T01.05), los módulos ya cachan `SinConexion`, y una taxonomía paralela los obligaría a mapear dos veces. Cuando T01.05 mueva el código v1, cambia el `typedef` y ninguna pantalla.
- **El núcleo no repite la regla RIC-14.** `ClienteApi` ya elige entre el `message` del backend y un texto propio según el código, así que `ExcepcionApi.mensaje` siempre se puede mostrar. Un segundo lugar que decidiera lo mismo sería una segunda fuente de verdad.
- **Los `Error` se propagan sin convertir.** Un `TypeError` del mapeo es un bug nuestro, no una falla prevista: convertirlo haría que el reporte de fallos viera «error del servidor» en vez del tipo real y, peor, que Riverpod lo reintentara (no reintenta los `Error` pero sí las `Exception`), ejecutando el bug cuatro veces. La vista sigue protegida porque `VistaAsincrona` convierte al pintar. Consecuencia: un `FormatException` del mapeo sí se convierte y un `TypeError` no, aunque los dos puedan salir de la misma línea; se siguió la convención de Dart.
- **El reintento automático se decide por tipo de error, no todo o nada.** `retry: (_, _) => null` por proveedor funciona pero tira también los reintentos útiles y hay que acordarse en cada proveedor. La política del núcleo insiste con sin conexión y 5xx, y no con 400, 401, 403, 404, 409 ni 429 (insistir en un 429 alarga el bloqueo). Tope de **3** intentos y no 10: con la espera que dobla, diez dejan al usuario mirando un error más de medio minuto.
- **El esqueleto lo da el módulo**, no el núcleo: la guía de estilos pide que tenga la forma del contenido, y esa forma solo la conoce la pantalla.
- **Sin `vacio`, una lista vacía pinta `datos`.** El núcleo no inventa un estado que nadie pidió: en el garaje una lista vacía es un error de datos, porque no puede haber un cliente sin vehículo.
- **En «sin conexión» manda el texto del sistema de diseño**, no el del fallo: es una condición del teléfono y no una respuesta del servidor, y el componente ya dice qué hacer.

**Pendiente / fuera de alcance:** migrar los módulos que ya existen (historia nueva; `vehiculoProvider` es el caso con efecto hoy); que `lib/nucleo/datos_locales/` del árbol lo cree M21; reconocer TLS (`HandshakeException`) como sin conexión, que no entró por no agregar código sin prueba; y el comentario desacomodado de `lib/api/excepciones.dart`.
