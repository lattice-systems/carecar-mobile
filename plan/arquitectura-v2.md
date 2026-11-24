# Arquitectura objetivo de la app v2

Estado: **Aceptada**. T01.01 aceptó las decisiones 0001 a 0005, así que ya se puede migrar código por este documento.

## Forma

```
lib/
├── main_desarrollo.dart · main_pruebas.dart · main_produccion.dart   # flavors (T01.04)
├── app.dart                         # MaterialApp.router + tema v2 + localización
├── nucleo/                          # compartido por todos los módulos; no conoce módulos
│   ├── api/                         # ApiCliente (http + tokens + refresco), errores, idempotencia
│   ├── sesion/                      # sesión, biometría, almacén seguro
│   ├── datos_locales/               # base local cifrada y cola sin conexión (M21)
│   ├── navegacion/                  # rutas, deep links, guardias de sesión
│   ├── diseno/                      # tokens, tema, componentes v2 (T02)
│   ├── l10n/                        # ARB es/en (M20)
│   ├── notificaciones/              # FCM + locales (M06)
│   └── observabilidad/              # errores y eventos (M23)
└── modulos/
    └── <modulo>/                    # acceso, vehiculos, citas, catalogo, taller, …
        ├── datos/                   # repositorio + DTO ↔ modelo, fuente remota y local
        ├── dominio/                 # modelos inmutables y reglas puras (sin Flutter)
        └── presentacion/            # pantallas, controladores de estado, widgets propios
```

## Reglas

1. `modulos/a` **no importa** `modulos/b/datos` ni `modulos/b/presentacion`. Si dos módulos se necesitan, se comunican por rutas (navegación) o por un contrato publicado en `modulos/b/b.dart`. Lo verifica `test/arquitectura/` (T01.06, ver abajo).
2. `dominio/` es Dart puro: se prueba sin Flutter.
3. Toda llamada de red pasa por `nucleo/api`; ningún módulo crea su propio `http.Client`.
4. Toda pantalla usa componentes de `nucleo/diseno`. Prohibido `Color(0x…)`, tamaños de letra o `EdgeInsets` mágicos fuera de los tokens.
5. Cada pantalla resuelve cinco estados: cargando (esqueleto), con datos, vacío, error con reintento, sin conexión.
6. Cadenas visibles solo en ARB.

## Reglas de dependencia verificadas (V2-T01.06)

`test/arquitectura/reglas_de_dependencia_test.dart` recorre `lib/` (imports, exports y parts, relativos y `package:carecar_mobile/`) y falla en el CI si se rompe alguna. **Punto público de un módulo** = `lib/modulos/<m>/<m>.dart`; todo lo demás (`datos/`, `dominio/`, `presentacion/`) es interno.

| Regla | Qué prohíbe | Excepción |
| --- | --- | --- |
| R1 | Importar un archivo que no sea `modulos/<b>/<b>.dart` desde fuera de `<b>` (otro módulo, v1, `main.dart`). Un módulo sí usa sus propios internos. | Ninguna. |
| R2 | `lib/nucleo` importando `lib/modulos`. | Solo `nucleo/navegacion/registro_de_rutas.dart`, y solo contratos públicos (R1 sigue vigente). |
| R3 | `lib/modulos` y `lib/nucleo` importando `lib/pantallas`, `lib/widgets` o `lib/tema` (v1). `lib/api` y `lib/sesion` siguen permitidos a través de `nucleo/api` y `nucleo/sesion` hasta T01.05. | `excepcionesV1` en `verificador_dependencias.dart`: hoy `nucleo/navegacion/rutas_del_nucleo.dart` (monta pantallas v1). Se vacía con T01.05/T01.07. |

**Cómo leer el error:** `archivo:línea importa "<import>" -> R#: <qué hacer>`. Ejemplo: `lib/modulos/citas/a.dart:3 importa "../vehiculos/datos/x.dart" -> R1: es interno del modulo "vehiculos"; importa su contrato publico modulos/vehiculos/vehiculos.dart o comunicate por rutas.` Arreglo: exporta lo necesario en `<m>.dart` (con `show`) e impórtalo desde ahí, o navega por la constante de ruta. No agregues excepciones sin avisar al dueño de T01. Las pruebas del propio verificador (casos en memoria) están en `test/arquitectura/verificador_dependencias_test.dart`.

## Inyección de dependencias (V2-T01.02)

Riverpod sin generación de código. `lib/nucleo/api` y `lib/nucleo/sesion` exponen proveedores (`carecarApiProvider`, `apiClienteProvider`, `controladorSesionProvider`, `estadoSesionProvider`) que `main.dart` inyecta con `overrides`; en pruebas se sustituyen por fakes. Guía de módulo: [`lib/modulos/README.md`](../lib/modulos/README.md).

## Navegación (V2-T01.03)

`go_router` (ADR 0003). `lib/nucleo/navegacion/` expone `enrutadorProvider` (el `GoRouter`), las rutas del núcleo tipadas (`Rutas`, `NombresRuta`), la guardia de sesión (`redirigirPorSesion`, función pura) y la traducción de enlaces (`EnlacesApp`: `carecar://` y `https://<host>/app/...` a rutas internas). Cada módulo publica sus rutas en su `<modulo>.dart`; `registro_de_rutas.dart` solo las junta. Guía: [`lib/modulos/README.md`](../lib/modulos/README.md).

## Mapas y ubicación (decisión 0006)

`lib/nucleo/mapas/` define `ProveedorUbicacion` (permiso y posición única, solo primer plano), `Geocodificador` (dirección a coordenadas y al revés), `Coordenada`, errores tipados y `ConfiguracionTeselas` (URL y atribución por `--dart-define`). Las implementaciones sobre `geolocator` y `geocoding` están aisladas y los fakes (`UbicacionFalsa`, `GeocodificadorFalso`) sirven para pruebas. Los módulos importan solo `mapas.dart`, nunca los paquetes. El componente `Mapa` es V2-T02.09. Guía: [`lib/nucleo/mapas/README.md`](../lib/nucleo/mapas/README.md).

## Migración desde v1

- La v1 vive en `lib/api`, `lib/sesion`, `lib/pantallas`, `lib/widgets`, `lib/tema`. Se migra **módulo por módulo** (M01 → M02 → M03) detrás de un interruptor de rutas por módulo ([guía](#migrar-un-módulo-con-el-interruptor-v1v2-v2-t0105), T01.05).
- `lib/api/carecar_api.dart` y `cliente_api.dart` se reutilizan como base de `nucleo/api` (ya manejan tokens y refresco). Hoy `nucleo/api` los **envuelve** (`ApiCliente` = `ClienteApi`); el código físico se mueve en V2-T01.05.
- Al cerrar H2 se elimina el código v1 (T01.07) y `shadcn_ui` (T02.08).

## Migrar un módulo con el interruptor v1/v2 (V2-T01.05)

**Qué es.** `lib/nucleo/migracion/interruptor_modulos.dart`. Por cada módulo que existe en v1 (`lib/pantallas`) y en v2 (`lib/modulos/<m>`) decide cuál ve la persona usuaria. Es una decisión de compilación: un valor por defecto en código (hoy **todo en v1**, la app es la de siempre) que se sobrescribe con `--dart-define`; no es remoto y no lleva secretos.

| Estado del módulo | Rutas v2 | Tarjeta del menú v1 |
| --- | --- | --- |
| v1 (por defecto) | **No se registran**: un enlace a ellas cae en el inicio | Abre la pantalla v1 |
| v2 | Se registran (`/garaje`, `/citas`...) | Lleva a la ruta v2 |

Sobrescribir al compilar (`MODULOS_V2` enciende, `MODULOS_V1` apaga y gana si un módulo está en las dos; `todos` es válido en ambas; un nombre desconocido falla al arrancar):

```bash
flutter run --dart-define=API_BASE_URL=... --dart-define=MODULOS_V2=vehiculos,citas
flutter run --dart-define=API_BASE_URL=... --dart-define=MODULOS_V2=todos --dart-define=MODULOS_V1=catalogo
```

En código, `interruptorModulosProvider` entrega el `InterruptorModulos`; las pruebas lo sustituyen con `overrideWithValue` (`AppEnrutadaDePrueba(interruptor: ...)`, por omisión todo en v2).

**Guía paso a paso para migrar un módulo**

1. **Carpeta.** Crea `lib/modulos/<modulo>/` copiando `lib/modulos/ejemplo/` (datos, dominio, presentación, `<modulo>.dart`, rutas). Detalle en [`lib/modulos/README.md`](../lib/modulos/README.md). La v1 no se toca: sigue en `lib/pantallas` usando `lib/api` y `lib/sesion` como hasta hoy.
2. **Interruptor.** Agrega el módulo a `ModuloMigrable` (orden alfabético) y, en `lib/nucleo/navegacion/registro_de_rutas.dart`, envuelve su línea: `...interruptor.rutas(ModuloMigrable.<modulo>, rutas<Modulo>),`. Si la v1 tiene una tarjeta en el menú, agrega `ModuloMigrable.<modulo>: ruta<Principal>` a `destinosDeMenuV2` (el mismo archivo); el menú v1 la usará solo con el módulo en v2.
3. **Pruebas.** (a) la de tu módulo con `AppEnrutadaDePrueba` (todo en v2 por omisión); (b) en `test/nucleo/migracion/interruptor_rutas_test.dart` agrega tu módulo a las dos tablas: en v1 su ruta cae en el inicio y la tarjeta abre la pantalla v1, en v2 abre la v2. Con todo en v1 no debe cambiar ninguna prueba de la v1.
4. **Encender.** Desarrollo y pruebas: `--dart-define=MODULOS_V2=<modulo>` (o el valor del flavor cuando V2-T01.04 llegue a `main`). Producción: el módulo queda en v1 hasta que esté **completo** (criterios de su historia, cinco estados, accesibilidad); entonces se enciende su valor por defecto en `InterruptorModulos.porDefecto` en un PR propio, que se puede revertir sin tocar el módulo.
5. **Un módulo, un PR.** El interruptor permite integrar la v2 a medias sin que se vea; no lo uses para mezclar dos migraciones en un mismo PR.

**Cómo se retira (V2-T01.07).** Al cerrar H2, con todos los módulos en v2: se borran `lib/nucleo/migracion/`, `interruptorModulosProvider`, el parámetro `abrirEnV2` de `PantallaInicio` (que desaparece con `lib/pantallas`), `destinosDeMenuV2` y las pruebas de `test/nucleo/migracion/`; `registro_de_rutas.dart` vuelve a `...rutas<Modulo>,` sin envoltorio y el parámetro `interruptor` de `rutasDeLaApp` se quita. `grep -rn "migracion/\|ModuloMigrable\|MODULOS_V" lib test` debe quedar vacío.

**Reglas de dependencia.** El interruptor no agrega excepciones a `excepcionesV1` (`test/arquitectura/`): el archivo del núcleo que monta pantallas v1 sigue siendo `rutas_del_nucleo.dart`, y `nucleo/migracion/` no importa v1. Al migrar un módulo, quita de esa lista lo que ya no monte v1.

**Límites conocidos.** Los accesos rápidos del ícono (V2-M25.04) y el widget de cita (V2-M25.01) apuntan a rutas v2: con el módulo en v1 caen en el inicio. Es lo esperado: el módulo incompleto no se ve.

## Backend

Contrato compartido en `agencia-360-backend/docs/api/`. La app v2 consume `agencia360-api-app-v2.yaml` (T05.02), compatible con v1.
