# `lib/modulos/` — un módulo funcional por carpeta

Cada módulo de la app v2 (acceso, vehículos, citas, catálogo, taller…) vive en `lib/modulos/<modulo>/`. Reglas completas en [`plan/arquitectura-v2.md`](../../plan/arquitectura-v2.md); aquí lo necesario para empezar.

```
lib/modulos/<modulo>/
├── <modulo>.dart        # contrato público: lo único que otros importan (incluye `rutas<Modulo>`)
├── datos/               # repositorio (implementación), DTO <-> modelo, fuentes remota/local
├── dominio/             # modelos inmutables, reglas puras e interfaz del repositorio (Dart puro)
└── presentacion/        # pantallas, proveedores Riverpod, widgets propios
```

## Cómo crear un módulo

1. Copia `lib/modulos/ejemplo/` (modelo vivo con pruebas en `test/modulos/ejemplo/`) y renómbralo.
2. **dominio/**: modelos y reglas sin importar Flutter ni `http`. Define ahí la interfaz del repositorio.
3. **datos/**: el repositorio real recibe `CarecarApi` (ver abajo), traduce DTO a modelos y mapea errores. Nunca crees tu propio `http.Client`.
4. **presentacion/**: un proveedor para el repositorio (sustituible en pruebas con `overrideWithValue`), uno por pantalla con `FutureProvider`/`AsyncNotifier`, y pantallas con `ConsumerWidget`. Los cinco estados los resuelve `VistaAsincrona` (ver "El núcleo de datos"); no los armes a mano.
5. **Rutas**: declara las de tu módulo (ver "Registrar las rutas de tu módulo").
6. **`<modulo>.dart`**: exporta solo lo que otros necesitan (pantalla raíz, modelos que viajan, proveedores públicos, la lista de rutas). Ver `ejemplo/ejemplo.dart`.

## Registrar las rutas de tu módulo

Navegación con `go_router` (ADR 0003, V2-T01.03). **Cada módulo expone sus rutas; el enrutador solo las junta.**

1. En `presentacion/rutas_<modulo>.dart` define el camino como constante y una lista de `RouteBase`:

   ```dart
   const rutaCitasLista = '/citas';
   final rutasCitas = <RouteBase>[
     GoRoute(path: rutaCitasLista, name: 'citas-lista', builder: (c, s) => const PantallaCitas(),
       routes: [GoRoute(path: ':id', name: 'cita-detalle', builder: (c, s) => PantallaCita(id: s.pathParameters['id']!))]),
   ];
   ```

2. Expórtala en `<modulo>.dart`: `export 'presentacion/rutas_citas.dart' show rutaCitasLista, rutasCitas;`
3. En `lib/nucleo/navegacion/registro_de_rutas.dart` agrega **una línea** en `rutasDeLaApp()`. Si tu módulo reemplaza algo de la v1, va detrás del interruptor v1/v2 (V2-T01.05): `...interruptor.rutas(ModuloMigrable.citas, rutasCitas),` y su valor en `ModuloMigrable`; guía en [`plan/arquitectura-v2.md`](../../plan/arquitectura-v2.md#migrar-un-módulo-con-el-interruptor-v1v2-v2-t0105). Un módulo sin equivalente en v1 usa `...rutasX,` (orden alfabético; es el único archivo del núcleo que importa módulos y solo su `<modulo>.dart`).
4. Reglas: nombres de ruta y caminos son de tu módulo y van en español sin acentos; para ir a otro módulo usa su constante (`<modulo>.dart`) o `context.goNamed`, nunca importes su `presentacion/`. Las rutas de módulos **exigen sesión** por defecto: sin sesión van al acceso y vuelven a ellas al entrar; el cambio obligatorio de contraseña también se respeta. Si una ruta debe ser pública, se agrega a `Rutas.publicas` (`nucleo/navegacion/rutas.dart`) con aviso al dueño de T01.
5. Enlaces: `carecar://<ruta>` y `https://<host>/app/<ruta>` llegan a la misma ruta (`carecar://citas/5` → `/citas/5`), así que **toda ruta tuya ya es alcanzable por enlace**. Por eso: parámetros por camino/consulta (`:id`, `?token=`), nunca objetos en `extra`.
6. Mientras no exista el tema v2 global, envuelve la pantalla con `Theme(data: TemaPista...)` como en `ejemplo/presentacion/rutas_ejemplo.dart`.
7. Prueba por ruta: monta `AppEnrutadaDePrueba` (`test/ayudas/app_enrutada.dart`) con tus fakes en `overrides`, `enrutadorDe(tester).go(tuRuta)` y comprueba la pantalla; ejemplo en `test/nucleo/navegacion/enrutador_test.dart`.

## Pantallas de pago y documentos

Si tu pantalla muestra datos de pago o documentos del cliente (M08, M09), envuélvela con `PantallaSegura` de `lib/nucleo/privacidad/` en el `builder` de la ruta: bloquea capturas en Android y se libera al salir. En pruebas sustituye `proteccionDeCapturaProvider` por `ProteccionDeCapturaFake`. Límites de iOS y detalle en [`docs/seguridad/ocultar-en-selector.md`](../../docs/seguridad/ocultar-en-selector.md).

## Textos de la pantalla

Ninguna cadena visible va en el código. Agrega la clave a `lib/l10n/app_es.arb` (con su `@clave` y una `description`) y a `app_en.arb`, corre `flutter gen-l10n` y úsala con `AppLocalizations.of(context).tuClave`. Si el texto lleva un dato, decláralo como placeholder (`"precioDesde": "Desde {precio}"`) y no concatenes en el código: el orden de las palabras cambia entre idiomas. El dominio nunca arma textos para la pantalla: entrega números y enums, y la presentación los traduce. La prueba `test/l10n/sin_cadenas_en_codigo_test.dart` falla si un archivo nuevo trae texto a mano. Ejemplo: `catalogo/presentacion/pantalla_catalogo.dart`.

## Qué te da el núcleo

| Necesitas | Lee |
| --- | --- |
| La API | `ref.watch(carecarApiProvider)` (`lib/nucleo/api/proveedores_api.dart`) |
| El cliente HTTP bajo la API | `apiClienteProvider` (`ApiCliente` = `ClienteApi` v1) |
| Acciones de sesión (iniciar, cerrar) | `ref.read(controladorSesionProvider)` (`lib/nucleo/sesion/`) |
| Reaccionar a la sesión | `ref.watch(estadoSesionProvider)` |
| Componentes y tokens | `lib/nucleo/diseno/` |
| Errores tipados | `Fallo` y sus preguntas (`lib/nucleo/datos/fallo.dart`) |
| Base del repositorio | `with RepositorioBase` (`lib/nucleo/datos/repositorio_base.dart`) |
| Los cinco estados | `VistaAsincrona` (`lib/nucleo/datos/vista_asincrona.dart`) |
| Fakes para pruebas | `RepositorioFalso` y `Fallos` (`test/ayudas/`) |

## El núcleo de datos

Lo que da `lib/nucleo/datos/` (V2-T01.08) para que todos los módulos resuelvan igual los cinco estados y prueben sin red.

### 1 · Los errores ya vienen tipados

`Fallo` es la jerarquía sellada `ExcepcionApi`: `SinConexion`, `CredencialesInvalidas`, `CuentaDesactivada`, `NoEncontrado`, `Conflicto`, `DatosInvalidos`, `DemasiadosIntentos`, `ErrorDelServidor`. **Su `mensaje` siempre se le puede mostrar al usuario** (el cliente ya aplica RIC-14: no enseña el `message` del backend en 400 ni en 5xx).

No preguntes por la clase: pregúntale al fallo.

| Pregunta | Qué responde |
| --- | --- |
| `esSinConexion` | No se pudo llegar al servidor |
| `sesionTerminada` | 401 o 403: hay que volver a entrar |
| `esReintentable` | Repetir la petición puede dar otro resultado |
| `codigo` | El código del contrato, **nunca nulo** (`CodigoProblema.desconocido` si no vino). Es con lo que se distinguen los dos 409 |
| `status` | El código HTTP, si lo hubo |

`falloDe(error)` convierte cualquier cosa en un `Fallo`, y deja pasar sin tocar las que ya lo son.

### 2 · El repositorio convierte o propaga

```dart
class RepositorioCatalogoApi with RepositorioBase implements RepositorioCatalogo {
  const RepositorioCatalogoApi(this._api);
  final CarecarApi _api;

  @override
  Future<List<ModeloVigente>> modelos() => pedir(() async {
    final dto = await _api.catalogo();
    return dto.map(_aModelo).toList(growable: false);   // el mapeo va DENTRO
  });
}
```

El mapeo va dentro de `pedir` a propósito: el cliente ya tipa sus errores, pero **la traducción del DTO no estaba protegida** y un campo que cambia en el backend llegaba a la pantalla sin tipar. Los `Error` (un `TypeError`, un índice fuera de rango) se propagan tal cual: son bugs nuestros, no fallas previstas, y conviene que el reporte de fallos vea su tipo real.

⚠️ **Traducir a un fallo de dominio va FUERA de `pedir`, no dentro.** Un fallo de dominio (`FranjaSinCupo`, `EnlaceNoValido`…) es una `Exception` normal, y `pedir` tipa todo lo que no sea `ExcepcionApi`: traducir dentro lo convertiría en `ErrorDelServidor` y la pantalla perdería el único dato que necesita.

```dart
@override
Future<void> restablecerConEnlace({required String token, required String nueva}) async {
  try {
    await pedir(() => _api.restablecerContrasena(...));
  } on DatosInvalidos catch (e) {                      // la traducción, fuera
    if (e.problema?.codigo == CodigoProblema.codigoInvalido) {
      throw const EnlaceNoValido();
    }
    rethrow;
  }
}
```

Ejemplo real y con prueba del caso: `acceso/datos/repositorio_acceso_api.dart` y `test/modulos/acceso/datos/repositorio_acceso_api_test.dart`.

### 3 · La pantalla pinta los cinco estados

```dart
VistaAsincrona<List<VehiculoGaraje>>(
  estado: ref.watch(garajeProvider),
  cargando: (_) => const Column(children: [Esqueleto(alto: 120), Esqueleto(alto: 120)]),
  datos: (_, vehiculos) => ListaDeVehiculos(vehiculos),
  vacio: (_) => const EstadoVacio(titulo: 'Aún no tienes vehículos'),
  alReintentar: () => ref.invalidate(garajeProvider),
)
```

- **El esqueleto lo das tú**: la guía pide que tenga la forma del contenido, y esa forma solo la conoce tu pantalla.
- **Sin `vacio`, una lista vacía pinta `datos`.** El núcleo no te inventa un estado: hay pantallas donde la lista vacía es un error de datos y no un estado normal.
- Mientras recarga con un dato previo **sigue viéndose el dato**, para que la lista no parpadee en cada refresco.
- La causa de `EstadoError` (genérico o sin conexión) y el texto los elige sola.

### 4 · El reintento automático ya está resuelto

Riverpod 3 reintenta solo cualquier proveedor que falle: hasta 10 veces, con espera que dobla de 200 ms a 6.4 s. Como todos nuestros fallos son `Exception`, sin política un 404 se pediría once veces y un 429 —que significa «deja de pedir»— otras once.

`main.dart` instala `reintentoDelNucleo` en el `ProviderScope`, así que **tus proveedores ya están cubiertos sin que hagas nada**: insiste con sin conexión y 5xx (hasta 3 veces) y no insiste con 400, 401, 403, 404, 409 ni 429.

El botón «Reintentar» sigue siendo necesario y es otra cosa: la política es lo que se arregla solo; el botón es la decisión del usuario cuando no se arregló.

### 5 · Fakes para probar sin red

```dart
final repositorio = RepositorioFalso(vehiculos, latencia: const Duration(milliseconds: 60));
repositorio.falla = Fallos.sinConexion();   // o .noEncontrado(), .conflicto(codigo), .servidor()…
repositorio.fallarUnaVez(Fallos.noEncontrado());   // falla una vez y luego funciona
```

`RepositorioFalso` usa la misma `RepositorioBase` que los repositorios de verdad, así que una prueba no puede ver un error sin tipar que en producción sí vendría tipado. Tiene `latencia`, `falla`, `fallarUnaVez`, `reventarUnaVez` (para simular un bug de mapeo) y contador de `llamadas`. Se **compone** dentro del fake de tu módulo, que es el que respeta tu interfaz.

`Fallos` arma un fallo por cada caso del contrato sin tener que construir un `Problema` a mano.

Ejemplo completo de los cinco estados y los ocho tipos de error de punta a punta: `test/nucleo/datos/nucleo_de_datos_test.dart`. Es la prueba que puedes copiar para tu pantalla cambiando el tipo y el repositorio.

## Reglas de dependencia

Las verifica `test/arquitectura/` (V2-T01.06) en cada `flutter test` y en el CI. Detalle y excepciones en [`plan/arquitectura-v2.md`](../../plan/arquitectura-v2.md#reglas-de-dependencia-verificadas-v2-t01-06).

- **R1** `modulos/a` **no importa** `modulos/b/datos`, `dominio` ni `presentacion`; solo `modulos/b/b.dart` (o se comunican por rutas). Cuenta cualquier `import`, `export` o `part`, relativo o `package:`.
- **R2** `nucleo/` no conoce módulos (la única excepción es `registro_de_rutas.dart`, y solo con `<modulo>.dart`).
- **R3** `modulos/` y `nucleo/` no importan `lib/pantallas`, `lib/widgets` ni `lib/tema` (v1).
- `dominio/` es Dart puro (se prueba sin Flutter).

Si la prueba falla verás `archivo:línea importa "<import>" -> R#: <qué hacer>`: exporta lo que necesitas en el `<modulo>.dart` del otro módulo (con `show`) y úsalo desde ahí.

## Pruebas

- Dominio: prueba de Dart puro (`test/modulos/<modulo>/..._test.dart`).
- Pantallas: `ProviderScope(overrides: [repositorioXProvider.overrideWithValue(fake)], child: ...)`.
- Riverpod 3 **reintenta solo** los proveedores que fallan, pero desde V2-T01.08 la política de la app ya decide por tipo de error (ver "El núcleo de datos", punto 4): **ya no hace falta poner `retry: (_, _) => null` en cada proveedor.** Los que ya lo tienen siguen funcionando —el del proveedor manda sobre el de la app—, solo quedan redundantes y además se pierden los reintentos útiles; los puede quitar el dueño del módulo cuando toque el archivo.
- Si tu prueba necesita ver un error que *sí* es reintentable (sin conexión, 5xx), monta el `ProviderScope` sin la política o pásale `retry: (_, _) => null`: con la política el fallo se cura solo y la pantalla pasa del error a los datos.

## Módulo `ejemplo`

Es solo un modelo para copiar. Su ruta (`/ejemplo/avisos`) se registra solo en desarrollo (`kDebugMode`). **Se elimina en V2-T01.07**, o antes si ya hay un módulo real que sirva de referencia.
