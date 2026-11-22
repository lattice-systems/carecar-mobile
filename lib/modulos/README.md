# `lib/modulos/` — un módulo funcional por carpeta

Cada módulo de la app v2 (acceso, vehículos, citas, catálogo, taller…) vive en `lib/modulos/<modulo>/`. Reglas completas en [`plan/arquitectura-v2.md`](../../plan/arquitectura-v2.md); aquí lo necesario para empezar.

```
lib/modulos/<modulo>/
├── <modulo>.dart        # contrato público: lo único que otros importan
├── datos/               # repositorio (implementación), DTO <-> modelo, fuentes remota/local
├── dominio/             # modelos inmutables, reglas puras e interfaz del repositorio (Dart puro)
└── presentacion/        # pantallas, proveedores Riverpod, widgets propios
```

## Cómo crear un módulo

1. Copia `lib/modulos/ejemplo/` (modelo vivo con pruebas en `test/modulos/ejemplo/`) y renómbralo.
2. **dominio/**: modelos y reglas sin importar Flutter ni `http`. Define ahí la interfaz del repositorio.
3. **datos/**: el repositorio real recibe `CarecarApi` (ver abajo), traduce DTO a modelos y mapea errores. Nunca crees tu propio `http.Client`.
4. **presentacion/**: un proveedor para el repositorio (sustituible en pruebas con `overrideWithValue`), uno por pantalla con `FutureProvider`/`AsyncNotifier`, y pantallas con `ConsumerWidget`. Resuelve los cinco estados (cargando con `Esqueleto`, datos, `EstadoVacio`, `EstadoError` con reintento, sin conexión) con componentes de `lib/nucleo/diseno`.
5. **`<modulo>.dart`**: exporta solo lo que otros necesitan (pantalla raíz, modelos que viajan, proveedores públicos). Ver `ejemplo/ejemplo.dart`.

## Qué te da el núcleo

| Necesitas | Lee |
| --- | --- |
| La API | `ref.watch(carecarApiProvider)` (`lib/nucleo/api/proveedores_api.dart`) |
| El cliente HTTP bajo la API | `apiClienteProvider` (`ApiCliente` = `ClienteApi` v1) |
| Acciones de sesión (iniciar, cerrar) | `ref.read(controladorSesionProvider)` (`lib/nucleo/sesion/`) |
| Reaccionar a la sesión | `ref.watch(estadoSesionProvider)` |
| Componentes y tokens | `lib/nucleo/diseno/` |

## Reglas de dependencia

- `modulos/a` **no importa** `modulos/b/datos` ni `modulos/b/presentacion`; solo `modulos/b/b.dart` o se comunican por rutas. Se verificará en V2-T01.06.
- `nucleo/` no conoce módulos.
- `dominio/` es Dart puro (se prueba sin Flutter).

## Pruebas

- Dominio: prueba de Dart puro (`test/modulos/<modulo>/..._test.dart`).
- Pantallas: `ProviderScope(overrides: [repositorioXProvider.overrideWithValue(fake)], child: ...)`.
- Riverpod 3 **reintenta solo** los proveedores que fallan; si tu pantalla ofrece botón de reintento, pon `retry: (_, _) => null` en ese proveedor (como en `ejemplo`) para que el error se vea y el reintento sea del usuario.

## Módulo `ejemplo`

Es solo un modelo para copiar. Sin ruta en la app (la navegación llega con V2-T01.03). **Se elimina en V2-T01.07**, o antes si ya hay un módulo real que sirva de referencia.
