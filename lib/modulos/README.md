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
4. **presentacion/**: un proveedor para el repositorio (sustituible en pruebas con `overrideWithValue`), uno por pantalla con `FutureProvider`/`AsyncNotifier`, y pantallas con `ConsumerWidget`. Resuelve los cinco estados (cargando con `Esqueleto`, datos, `EstadoVacio`, `EstadoError` con reintento, sin conexión) con componentes de `lib/nucleo/diseno`.
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
- Riverpod 3 **reintenta solo** los proveedores que fallan; si tu pantalla ofrece botón de reintento, pon `retry: (_, _) => null` en ese proveedor (como en `ejemplo`) para que el error se vea y el reintento sea del usuario.

## Módulo `ejemplo`

Es solo un modelo para copiar. Su ruta (`/ejemplo/avisos`) se registra solo en desarrollo (`kDebugMode`). **Se elimina en V2-T01.07**, o antes si ya hay un módulo real que sirva de referencia.
