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

**Pendiente / fuera de alcance:** mover el código de `lib/api` y `lib/sesion` al núcleo (V2-T01.05, módulo por módulo); regla de dependencias automática (V2-T01.06).
